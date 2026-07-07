#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# headless-lsp-smoke.sh — LSP battery test for Neovim config
#
# Runs lsp-battery.lua across multiple languages to verify
# LSP clients survive 26 protocol methods + buf wrappers +
# stress cycles without dying (catches the WritingMode autocmd
# race condition where LSP float windows trigger set_writing_mode).
#
# Usage:
#   ./tests/headless-lsp-smoke.sh          # full battery
#   ./tests/headless-lsp-smoke.sh --quick  # TypeScript only
#   SKIP_LSP_SMOKE=1 git commit ...        # bypass pre-commit
# ──────────────────────────────────────────────────────────────
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$BASE_DIR/init.lua"
BATTERY="$BASE_DIR/tests/lsp-battery.lua"

TMP_ROOT=$(mktemp -d /tmp/lsp-smoke-XXXXXX)
PASS=0
FAIL=0
ERRORS=""

MASON_DIR="$HOME/.local/share/nvim/mason"
export PATH="$MASON_DIR/bin:$PATH"

cleanup() { rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

log_pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
log_fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); ERRORS+="  ✗ $1"$'\n'; }
server_available() { command -v "$1" &>/dev/null; }

# $1 = language label
# $2 = LSP server name (client name)
# $3 = server binary (for path check)
# $4 = project dir
# $5 = relative file path
# $6 = timeout ms for attach
run_battery() {
  local lang=$1 server_name=$2 server_bin=$3
  local project_dir=$4 rel_file=$5 timeout_ms=$6
  local abs_file="$project_dir/$rel_file"
  local result_file="$TMP_ROOT/result_$(echo "$lang" | tr '[:upper:]' '[:lower:]' | tr ' ' '_').txt"

  if ! server_available "$server_bin"; then
    log_fail "$lang — '$server_bin' not found on PATH (install via Mason)"
    return
  fi

  echo "  running battery (timeout=${timeout_ms}ms) ..."

  # Pre-start servers that don't auto-start in headless (gopls, clangd)
  # by briefly opening the file with the matching LSP config.
  if [[ "$server_name" != "typescript-tools" ]]; then
    nvim --headless -u "$CONFIG_FILE" \
      -c "lua vim.wait(1000)" \
      -c "q" "$abs_file" 2>/dev/null || true
  fi

  nvim --headless -u "$CONFIG_FILE" \
    -c "let g:test_lsp_server_name='$server_name'" \
    -c "let g:test_lsp_result_file='$result_file'" \
    -c "let g:test_lsp_timeout=$timeout_ms" \
    -c "luafile $BATTERY" \
    "$abs_file" 2>/dev/null || true

  if [[ ! -f "$result_file" ]]; then
    log_fail "$lang — no result file (nvim may have crashed)"
    return
  fi

  local total_fail
  total_fail=$(jq -r '.fail' "$result_file")
  local total_pass total_skip
  total_pass=$(jq -r '.pass' "$result_file")
  total_skip=$(jq -r '.skip' "$result_file")

  echo "    $total_pass pass / $total_fail fail / $total_skip skip"

  if [[ "$total_fail" -gt 0 ]]; then
    log_fail "$lang — $total_fail test(s) failed"
    # Show which ones failed
    jq -r '.detail[] | select(.status == "fail") | "      FAIL \(.method): \(.note)"' "$result_file" | head -5
  else
    log_pass "$lang"
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
    echo "=== LSP Battery Test (quick — TypeScript only) ==="
  else
    echo "=== LSP Battery Test (full) ==="
  fi
  echo "config: $CONFIG_FILE"
  echo ""

  echo "--- TypeScript (typescript-tools) ---"
  local ts_dir; ts_dir=$(setup_typescript)
  run_battery "TypeScript" "typescript-tools" "typescript-language-server" "$ts_dir" "src/index.ts" 15000
  echo ""

  if $quick_mode; then
    echo ""
    echo "=== Quick mode ==="
    echo "  Passed: $PASS    Failed: $FAIL"
    [[ $FAIL -gt 0 ]] && echo "Errors:" && echo "$ERRORS"
    return $FAIL
  fi

  echo "--- JavaScript (typescript-tools) ---"
  local js_dir; js_dir=$(setup_javascript)
  run_battery "JavaScript" "typescript-tools" "typescript-language-server" "$js_dir" "src/index.js" 15000
  echo ""

  echo "--- Go (gopls) ---"
  local go_dir; go_dir=$(setup_go)
  run_battery "Go" "gopls" "gopls" "$go_dir" "main.go" 10000
  echo ""

  echo "--- Python (pyright) ---"
  local py_dir; py_dir=$(setup_python)
  run_battery "Python" "pyright" "pyright" "$py_dir" "main.py" 10000
  echo ""

  echo "--- C++ (clangd) ---"
  local cpp_dir; cpp_dir=$(setup_cpp)
  run_battery "C++" "clangd" "clangd" "$cpp_dir" "main.cpp" 10000
  echo ""

  echo "=== Results ==="
  echo "  Passed: $PASS    Failed: $FAIL"
  echo ""
  [[ $FAIL -gt 0 ]] && echo "Errors:" && echo "$ERRORS"
  return $FAIL
}

main "$@"
