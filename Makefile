.PHONY: test test-quick test-full clean

test:
	@echo "=== LSP Smoke Test (quick) ==="
	@./tests/headless-lsp-smoke.sh --quick

test-quick: test

test-full:
	@echo "=== LSP Smoke Test (full) ==="
	@./tests/headless-lsp-smoke.sh

clean:
	@rm -rf /tmp/lsp-smoke-*
	@echo "cleaned temp test artifacts"
