# Makefile for Lua tests

# Lua interpreter command
LUA := lua

# LuaUnit test runner command
LUAUNIT := luaunit

# Test files
TEST_FILES := $(wildcard *.lua)

# Colors
GREEN=\033[32m
RED=\033[31m
NC=\033[0m # No Color

.PHONY: test

test:
	@for file in $(TEST_FILES); do \
		echo "$(GREEN)Running test: $$file$(NC)"; \
		$(LUA) $$file; \
		if [ $$? -ne 0 ]; then \
			echo "$(RED)Test failed: $$file$(NC)"; \
		fi; \
		echo ""; \
	done

test_luaunit:
	@for file in $(TEST_FILES); do \
		echo "Running test: $$file"; \
		$(LUAUNIT) $$file; \
	done
