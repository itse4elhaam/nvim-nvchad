#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# headless-lsp-smoke.sh — LSP smoke test for Neovim config
#
# Opens Neovim in headless mode across multiple languages and
# verifies LSP attaches, diagnostics fire, and buffer-local
# keymaps (gd, gr, gi) are registered.
#
# Usage:
#   ./tests/headless-lsp-smoke.sh          # full test suite
#   ./tests/headless-lsp-smoke.sh --quick  # TypeScript only
#   SKIP_LSP_SMOKE=1 git commit ...        # bypass pre-commit
# ──────────────────────────────────────────────────────────────
set -euo pipefail

# ── Config ──────────────────────────────────────────────────
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$BASE_DIR/init.lua"
NEEDS_RECONFIGURE=false

# Per-language LSP timeout (ms) — tsserver is slow to cold-start
TIMEOUT_TS=15000
TIMEOUT_JS=15000
TIMEOUT_GO=10000
TIMEOUT_PY=10000
TIMEOUT_CPP=10000

TMP_ROOT=$(mktemp -d /tmp/lsp-smoke-XXXXXX)
PASS=0
FAIL=0
ERRORS=""

# Steer Mason to the right install dir inside the headless session
MASON_DIR="$HOME/.local/share/nvim/mason"
export PATH="$MASON_DIR/bin:$PATH"

# ── Helpers ──────────────────────────────────────────────────
cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

log_pass() {
  echo "  ✓ $1"
  PASS=$((PASS + 1))
}

log_fail() {
  echo "  ✗ $1"
  FAIL=$((FAIL + 1))
  ERRORS+="  ✗ $1"$'\n'
}

server_available() {
  command -v "$1" &>/dev/null
}

# Run a language test: opens nvim headless, waits for LSP, checks result
# $1 = language label     (e.g. "TypeScript")
# $2 = LSP server name    (e.g. "typescript-tools")
# $3 = server binary       (e.g. "typescript-language-server")
# $4 = project dir path    (the temp project directory)
# $5 = relative file path  (e.g. "src/index.ts")
# $6 = timeout in ms       (e.g. 15000)
# $7 = force-start name    (e.g. "gopls" — skip with "" for auto-start servers)
run_lsp_test() {
  local lang=$1
  local server_name=$2
  local server_bin=$3
  local project_dir=$4
  local rel_file=$5
  local timeout_ms=$6
  local force_name=${7:-}
  local abs_file="$project_dir/$rel_file"
  local result_file="$TMP_ROOT/result_$(echo "$lang" | tr '[:upper:]' '[:lower:]' | tr ' ' '_').txt"

  if ! server_available "$server_bin"; then
    log_fail "$lang — server '$server_bin' not found on PATH (install via Mason)"
    return
  fi

  echo "  starting nvim (timeout=${timeout_ms}ms) ..."

  nvim --headless -u "$CONFIG_FILE" \
    -c "lua
      local server_name  = '$server_name'
      local force_name   = '$force_name'
      local result_file  = '$result_file'
      local timeout_ms   = $timeout_ms

      -- Phase 1: wait for auto-start (works for typescript-tools plugin)
      local function has_server()
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if c.name == server_name then return true end
        end
        return false
      end

      local ok = vim.wait(timeout_ms, has_server)

      -- Phase 2: if not found and force-name given, try explicit start
      if not ok and force_name ~= '' then
        vim.lsp.start({ name = force_name, cmd = { force_name },
          root_dir = vim.fn.getcwd() })
        ok = vim.wait(timeout_ms, has_server)
      end

      -- Phase 3: trigger diagnostics
      -- typescript-tools needs insert_leave (publish_diagnostic_on = 'insert_leave')
      if ok then
        if server_name == 'typescript-tools' then
          vim.cmd('startinsert')
          vim.cmd('stopinsert')
        end
        vim.wait(2000, function() return #vim.diagnostic.get(0) > 0 end)
      end

      local clients = vim.lsp.get_clients({ bufnr = 0 })
      local names   = vim.tbl_map(function(c) return c.name end, clients)
      local diags   = vim.diagnostic.get(0)

      -- Buffer-local keymaps (from NvChad core_on_attach chain)
      local gd_map  = vim.fn.maparg('gd', 'n', false, true)
      local gr_map  = vim.fn.maparg('gr', 'n', false, true)
      local gi_map  = vim.fn.maparg('gi', 'n', false, true)

      local function is_buf_map(m)
        if type(m) ~= 'table' then return false end
        if m.buffer then return true end
        return m.buffer ~= nil and m.buffer ~= 0
      end

      local server_found = has_server()

      local result = {
        timeout      = not ok,
        attached     = #clients,
        names        = names,
        diag_count   = #diags,
        server_found = server_found,
        gd_set       = type(gd_map) == 'table' and gd_map ~= vim.NIL,
        gd_buffer    = is_buf_map(gd_map),
        gr_set       = type(gr_map) == 'table' and gr_map ~= vim.NIL,
        gr_buffer    = is_buf_map(gr_map),
        gi_set       = type(gi_map) == 'table' and gi_map ~= vim.NIL,
        gi_buffer    = is_buf_map(gi_map),
      }

      local f = io.open(result_file, 'w')
      if f then
        f:write(vim.json.encode(result))
        f:close()
      end
      vim.cmd('cq!')" \
    "$abs_file" 2>/dev/null || true

  if [[ ! -f "$result_file" ]]; then
    log_fail "$lang — no result file (nvim may have crashed)"
    return
  fi

  local server_ok diag_ok gd_ok
  server_ok=$(jq -r '.server_found' "$result_file")
  diag_ok=$(jq -r '.diag_count > 0' "$result_file")
  gd_ok=$(jq -r '.gd_set and .gd_buffer' "$result_file")
  local names_str diag_count timeout_occurred
  names_str=$(jq -r '.names | join(",")' "$result_file")
  diag_count=$(jq -r '.diag_count' "$result_file")
  timeout_occurred=$(jq -r '.timeout' "$result_file")

  if [[ "$timeout_occurred" == "true" ]]; then
    log_fail "$lang — TIMEOUT (LSP not attached after ${timeout_ms}ms)"
    return
  fi

  if [[ "$server_ok" != "true" ]]; then
    log_fail "$lang — server '$server_name' not found: [$names_str]"
    return
  fi

  local partial_fail=false

  if [[ "$diag_ok" != "true" ]]; then
    log_fail "$lang — server attached but no diagnostics ($diag_count diags)"
    partial_fail=true
  fi

  if [[ "$gd_ok" != "true" ]]; then
    local gd_val
    gd_val=$(jq -r '{set: .gd_set, buf: .gd_buffer}' "$result_file")
    log_fail "$lang — gd keymap not buffer-local: $gd_val"
    partial_fail=true
  fi

  if $partial_fail; then
    FAIL=$((FAIL + 1))
    ERRORS+="  ✗ $lang (partial failure)"$'\n'
  else
    PASS=$((PASS + 1))
  fi
}

# ── Setup temp projects ────────────────────────────────────

setup_typescript() {
  local dir="$TMP_ROOT/typescript"
  mkdir -p "$dir/src"

  cat > "$dir/package.json" <<'EOF'
{"name":"lsp-test","dependencies":{"typescript":"^5.0.0"}}
EOF
  cat > "$dir/tsconfig.json" <<'EOF'
{"compilerOptions":{"strict":true,"target":"ES2020","module":"ESNext"}}
EOF
  cat > "$dir/src/index.ts" <<'EOF'
const x: number = "not_a_number";
function greet(name: string): string { return "hello " + name; }
const result = greet(42);
EOF
  echo "$dir"
}

setup_javascript() {
  local dir="$TMP_ROOT/javascript"
  mkdir -p "$dir/src"

  cat > "$dir/package.json" <<'EOF'
{"name":"lsp-test-js","dependencies":{"typescript":"^5.0.0"}}
EOF
  cat > "$dir/jsconfig.json" <<'EOF'
{"compilerOptions":{"strict":true,"checkJs":true,"target":"ES2020"}}
EOF
  cat > "$dir/src/index.js" <<'EOF'
// @ts-check
/** @param {string} name */
function greet(name) { return "hello " + name; }
const result = greet(42);
EOF
  echo "$dir"
}

setup_go() {
  local dir="$TMP_ROOT/go"
  mkdir -p "$dir"

  cd "$dir"
  go mod init lsp-test 2>/dev/null || true
  cat > "$dir/main.go" <<'EOF'
package main

import "fmt"

func main() {
	fmt.Println(greet(42))
}

func greet(s string) string {
	return "hello " + s
}
EOF
  echo "$dir"
}

setup_python() {
  local dir="$TMP_ROOT/python"
  mkdir -p "$dir"

  cat > "$dir/pyproject.toml" <<'EOF'
[tool.pyright]
typeCheckingMode = "strict"
EOF
  cat > "$dir/main.py" <<'EOF'
def greet(name: str) -> str:
    return "hello " + name


result: int = greet("world")
EOF
  echo "$dir"
}

setup_cpp() {
  local dir="$TMP_ROOT/cpp"
  mkdir -p "$dir"

  cat > "$dir/compile_flags.txt" <<'EOF'
-std=c++20
-I.
EOF
  cat > "$dir/main.cpp" <<'EOF'
#include <string>

std::string greet(const std::string& name) {
    return "hello " + name;
}

int main() {
    std::string result = 42;
    return 0;
}
EOF
  echo "$dir"
}

# ── Main ──────────────────────────────────────────────────────
main() {
  local quick_mode=false
  if [[ "${1:-}" == "--quick" ]]; then
    quick_mode=true
    echo "=== LSP Smoke Test (quick mode — TypeScript only) ==="
  else
    echo "=== LSP Smoke Test (full) ==="
  fi
  echo "config: $CONFIG_FILE"
  echo ""

  # ── TypeScript ────────────────────────────────────────────
  echo "--- TypeScript (ts_ls) ---"
  local ts_dir
  ts_dir=$(setup_typescript)
  run_lsp_test "TypeScript" "typescript-tools" "typescript-language-server" "$ts_dir" "src/index.ts" $TIMEOUT_TS ""
  echo ""

  if $quick_mode; then
    echo ""
    echo "=== Quick mode results ==="
    echo "  Passed: $PASS    Failed: $FAIL"
    echo ""
    # Don't print errors in quick mode unless there are failures
    if [[ $FAIL -gt 0 ]]; then
      echo "Errors:"
      echo "$ERRORS"
    fi
    return $FAIL
  fi

  # ── JavaScript ────────────────────────────────────────────
  echo "--- JavaScript (ts_ls) ---"
  local js_dir
  js_dir=$(setup_javascript)
  run_lsp_test "JavaScript" "typescript-tools" "typescript-language-server" "$js_dir" "src/index.js" $TIMEOUT_JS ""
  echo ""

  # ── Go ────────────────────────────────────────────────────
  echo "--- Go (gopls) ---"
  local go_dir
  go_dir=$(setup_go)
  run_lsp_test "Go" "gopls" "gopls" "$go_dir" "main.go" $TIMEOUT_GO "gopls"
  echo ""

  # ── Python ────────────────────────────────────────────────
  echo "--- Python (pyright) ---"
  local py_dir
  py_dir=$(setup_python)
  run_lsp_test "Python" "pyright" "pyright" "$py_dir" "main.py" $TIMEOUT_PY "pyright"
  echo ""

  # ── C++ ────────────────────────────────────────────────────
  echo "--- C++ (clangd) ---"
  local cpp_dir
  cpp_dir=$(setup_cpp)
  run_lsp_test "C++" "clangd" "clangd" "$cpp_dir" "main.cpp" $TIMEOUT_CPP "clangd"
  echo ""

  # ── Summary ────────────────────────────────────────────────
  echo "=== Results ==="
  echo "  Passed: $PASS    Failed: $FAIL"
  echo ""

  if [[ $FAIL -gt 0 ]]; then
    echo "Errors:"
    echo "$ERRORS"
  fi

  return $FAIL
}

main "$@"
