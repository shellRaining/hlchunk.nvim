ifndef VERBOSE
.SILENT:
endif

# pinned vendor commits (bump here to update; CI cache keys off this file)
PLENARY_COMMIT := 74b06c6c75e4eeb3108ec01852001636d85a932b
NEODEV_COMMIT  := 46aa467dca16cf3dfe27098042402066d2ae242d

VENDOR_DIR := .ci/vendor/pack/vendor/start

# local preview of CI: lint + format check + tests
ci: selene stylua test

# alias
lint: selene

selene:
	selene --config selene.toml lua/

test: dependencies
	@echo "Running hlchunk tests..."
	timeout 300 nvim -e \
		--headless \
		--noplugin \
		-u test/spec.lua \
		-c "PlenaryBustedDirectory test/features {minimal_init = 'test/spec.lua'}"

# check only
stylua:
	stylua --check .

# write formatting in place
fmt:
	stylua .

lua-language-server: dependencies
	rm -rf .ci/lua-language-server-log
	lua-language-server --configpath .luarc.json --logpath .ci/lua-language-server-log --check .
	[ -f .ci/lua-language-server-log/check.json ] && { cat .ci/lua-language-server-log/check.json 2>/dev/null; exit 1; } || true

# idempotent: clone (bare) on first run, then checkout the pinned commit every time
dependencies:
	@mkdir -p $(VENDOR_DIR)
	@if [ ! -d $(VENDOR_DIR)/plenary.nvim ]; then \
		git clone --no-checkout https://github.com/nvim-lua/plenary.nvim $(VENDOR_DIR)/plenary.nvim; \
	fi
	@cd $(VENDOR_DIR)/plenary.nvim && git fetch --depth 1 origin $(PLENARY_COMMIT) && git checkout $(PLENARY_COMMIT)
	@if [ ! -d $(VENDOR_DIR)/neodev.nvim ]; then \
		git clone --no-checkout https://github.com/folke/neodev.nvim $(VENDOR_DIR)/neodev.nvim; \
	fi
	@cd $(VENDOR_DIR)/neodev.nvim && git fetch --depth 1 origin $(NEODEV_COMMIT) && git checkout $(NEODEV_COMMIT)

.PHONY: ci lint test selene stylua fmt lua-language-server dependencies
