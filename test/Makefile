# Makefile for Lua tests

# Lua interpreter command
LUA := lua

# LuaUnit test runner command
LUAUNIT := luaunit

# Test files
TEST_FILES := $(wildcard *.lua)

.PHONY: test

test:
	@for file in $(TEST_FILES); do \
		echo "Running test: $$file"; \
		$(LUA) $$file; \
	done

test_luaunit:
	@for file in $(TEST_FILES); do \
		echo "Running test: $$file"; \
		$(LUAUNIT) $$file; \
	done
