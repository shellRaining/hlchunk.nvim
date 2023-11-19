local ft = require("hlchunk.utils.ts_node_type")
local fn = vim.fn
local treesitter = vim.treesitter

-- these are helper function for utils

---@param bufnr number check the bufnr has treesitter parser
local function has_treesitter(bufnr)
    local ok = pcall(require, "nvim-treesitter")
    if not ok then
        return false
    end

    local has_lang, lang = pcall(treesitter.language.get_lang, vim.bo[bufnr].filetype)
    if not has_lang then
        return false
    end

    local has, parser = pcall(treesitter.get_parser, bufnr, lang)
    if not has or not parser then
        return false
    end
    return true
end

---@param line? number
local function is_comment(line)
    line = line or fn.line(".")

    local str = fn.getline(line)
    str:trim()
    return str:match("^%-%-[^\r\n]*$") ~= nil
        or string.match(str, "^%s*/%*.-%*/%s*$") ~= nil
        or string.match(str, "^%s*//.*$") ~= nil
end

-- get the virtual indent of the given line
---@param rows_indent table<number, number>
---@param line number
---@return number
local function get_virt_indent(rows_indent, line)
    local cur = line + 1
    while rows_indent[cur] do
        if rows_indent[cur] == 0 then
            break
        elseif rows_indent[cur] > 0 then
            return rows_indent[cur]
        end
        cur = cur + 1
    end
    return -1
end

local function is_suit_type(node_type)
    local suit_types = ft[vim.bo.ft]
    if suit_types then
        return suit_types[node_type] and true or false
    end

    for _, rgx in ipairs(ft.default) do
        if node_type:find(rgx) then
            return true
        end
    end
    return false
end

-- this is utils module for hlchunk every mod
-- every method in this module should pass arguments as follow
-- 1. mod: BaseMod, for utils function to get mod options
-- 2. normal arguments
-- 3. opts: for utils function to get options specific for this function
-- every method in this module should return as follow
-- 1. return ret code, a enum value
-- 2. return ret value, a table or other something
local M = {}

---@enum CHUNK_RANGE_RETCODE
M.CHUNK_RANGE_RET = {
    OK = 0,
    CHUNK_ERR = 1,
    NO_CHUNK = 2,
    NO_TS = 3,
}

---@param mod BaseMod
---@param line? number the line number we want to get the chunk range, with 1-index
---@param opts? {use_treesitter: boolean}
---@return CHUNK_RANGE_RETCODE enum
---@return table<number, number>
---@diagnostic disable-next-line: unused-local
function M.get_chunk_range(mod, line, opts)
    opts = opts or { use_treesitter = false }
    line = line or fn.line(".")

    local beg_row, end_row

    if opts.use_treesitter then
        if not has_treesitter(0) then
            return M.CHUNK_RANGE_RET.NO_TS, {}
        end

        local cursor_node = treesitter.get_node()
        while cursor_node do
            local node_type = cursor_node:type()
            local node_start, _, node_end, _ = cursor_node:range()
            if node_start ~= node_end and is_suit_type(node_type) then
                ---@diagnostic disable-next-line: undefined-field
                return cursor_node:has_error() and M.CHUNK_RANGE_RET.CHUNK_ERR or M.CHUNK_RANGE_RET.OK,
                    {
                        node_start + 1,
                        node_end + 1,
                    }
            end
            cursor_node = cursor_node:parent()
        end
        return M.CHUNK_RANGE_RET.NO_CHUNK, {}
    else
        local base_flag = "nWz"
        local cur_row_val = fn.getline(line)
        local cur_col = fn.col(".")
        local cur_char = string.sub(cur_row_val, cur_col, cur_col)

        beg_row = fn.searchpair("{", "", "}", base_flag .. "b" .. (cur_char == "{" and "c" or ""))
        end_row = fn.searchpair("{", "", "}", base_flag .. (cur_char == "}" and "c" or ""))

        if beg_row <= 0 or end_row <= 0 or beg_row >= end_row then
            return M.CHUNK_RANGE_RET.NO_CHUNK, {}
        end

        if is_comment(beg_row) or is_comment(end_row) then
            return M.CHUNK_RANGE_RET.NO_CHUNK, {}
        end

        return M.CHUNK_RANGE_RET.OK, { beg_row, end_row }
    end
end

---@param mod BaseMod
---@param line? number the line number we want to get the indent range
---@param opts? {use_treesitter: boolean}
---@return table<number, number> | nil not include end point
function M.get_indent_range(mod, line, opts)
    -- TODO: fix bugs of this function, and ref the return value
    line = line or fn.line(".")
    opts = opts or { use_treesitter = false }

    local _, rows_indent_list = M.get_rows_indent(mod, nil, nil, {
        use_treesitter = opts.use_treesitter,
        virt_indent = true,
    })
    if not rows_indent_list or rows_indent_list[line] < 0 then
        return nil
    end

    local shiftwidth = fn.shiftwidth()
    if rows_indent_list[line + 1] and rows_indent_list[line + 1] == rows_indent_list[line] + shiftwidth then
        line = line + 1
    elseif rows_indent_list[line - 1] and rows_indent_list[line - 1] == rows_indent_list[line] + shiftwidth then
        line = line - 1
    end

    if rows_indent_list[line] <= 0 then
        return nil
    end

    local up = line
    local down = line
    local wbegin = fn.line("w0")
    local wend = fn.line("w$")

    while up >= wbegin and rows_indent_list[up] >= rows_indent_list[line] do
        up = up - 1
    end
    while down <= wend and rows_indent_list[down] >= rows_indent_list[line] do
        down = down + 1
    end
    up = math.max(up, wbegin)
    down = math.min(down, wend)

    return { up + 1, down - 1 }
end

---@enum ROWS_INDENT_RETCODE
M.ROWS_INDENT_RETCODE = {
    OK = 0,
    NO_TS = 1,
}

-- when virt_indent is false, there are three cases:
-- 1. the row has nothing, we set the value to -1
-- 2. the row has char however not have indent, we set the indent to 0
-- 3. the row has indent, we set its indent
--------------------------------------------------------------------------------
-- when virt_indent is true, the only difference is:
-- when the len of line val is 0, we set its indent by its context, example
-- 1. hello world
-- 2.    this is shellRaining
-- 3.
-- 4.    this is shellRaining
-- 5.
-- 6. this is shellRaining
-- the virtual indent of line 3 is 4, and the virtual indent of line 5 is 0
---@param mod BaseMod
---@param begRow? number
---@param endRow? number
---@param opts? {use_treesitter: boolean, virt_indent: boolean}
---@return ROWS_INDENT_RETCODE enum
---@return table<number, number>
function M.get_rows_indent(mod, begRow, endRow, opts)
    begRow = begRow or fn.line("w0")
    endRow = endRow or fn.line("w$")
    opts = opts or { use_treesitter = false, virt_indent = false }

    local rows_indent = {}
    local get_indent = fn.indent
    if opts.use_treesitter then
        local ts_indent_status, ts_indent = pcall(require, "nvim-treesitter.indent")
        if not ts_indent_status then
            return M.ROWS_INDENT_RETCODE.NO_TS, {}
        end
        get_indent = function(row)
            return ts_indent.get_indent(row) or 0
        end
    end

    for i = endRow, begRow, -1 do
        rows_indent[i] = get_indent(i)
        -- if use treesitter, no need to care virt_indent option, becasue it has handled by treesitter
        if (not opts.use_treesitter) and rows_indent[i] == 0 and #fn.getline(i) == 0 then
            rows_indent[i] = opts.virt_indent and get_virt_indent(rows_indent, i) or -1
        end
    end

    return M.ROWS_INDENT_RETCODE.OK, rows_indent
end

---@param lnum number (1-indexed)
function M.get_indent(lnum)
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = parsers.get_parser(bufnr)
  if not parser or not lnum then
    return -1
  end

  -- NOTE: this is just special case
  -- some languages like Python will actually have worse results when re-parsing at opened new line
  local root_lang = parsers.get_buf_lang(bufnr)
  if not M.avoid_force_reparsing[root_lang] then
    -- Reparse in case we got triggered by ":h indentkeys"
    parser:parse { vim.fn.line "w0" - 1, vim.fn.line "w$" - 1 }
  end

  -- Get language tree with smallest range around node that's not a comment parser
  local root, lang_tree ---@type TSNode, LanguageTree
  parser:for_each_tree(function(tstree, tree)
    if not tstree or M.comment_parsers[tree:lang()] then
      return
    end
    local local_root = tstree:root()
    if ts.is_in_node_range(local_root, lnum - 1, 0) then
      if not root or node_length(root) >= node_length(local_root) then
        root = local_root
        lang_tree = tree
      end
    end
  end)

  -- Not likely, but just in case...
  if not root then
    return 0
  end

  local q = get_indents(vim.api.nvim_get_current_buf(), root, lang_tree:lang())
  local is_empty_line = string.match(getline(lnum), "^%s*$") ~= nil
  local node ---@type TSNode
  if is_empty_line then
    local prevlnum = vim.fn.prevnonblank(lnum)
    local indent = vim.fn.indent(prevlnum)
    local prevline = vim.trim(getline(prevlnum))
    -- The final position can be trailing spaces, which should not affect indentation
    node = get_last_node_at_line(root, prevlnum, indent + #prevline - 1)
    if node:type():match "comment" then
      -- The final node we capture of the previous line can be a comment node, which should also be ignored
      -- Unless the last line is an entire line of comment, ignore the comment range and find the last node again
      local first_node = get_first_node_at_line(root, prevlnum, indent)
      local _, scol, _, _ = node:range()
      if first_node:id() ~= node:id() then
        -- In case the last captured node is a trailing comment node, re-trim the string
        prevline = vim.trim(prevline:sub(1, scol - indent))
        -- Add back indent as indent of prevline was trimmed away
        local col = indent + #prevline - 1
        node = get_last_node_at_line(root, prevlnum, col)
      end
    end
    if q["indent.end"][node:id()] then
      node = get_first_node_at_line(root, lnum)
    end
  else
    node = get_first_node_at_line(root, lnum)
  end

  local indent_size = vim.fn.shiftwidth()
  local indent = 0
  local _, _, root_start = root:start()
  if root_start ~= 0 then
    -- injected tree
    indent = vim.fn.indent(root:start() + 1)
  end

  -- tracks to ensure multiple indent levels are not applied for same line
  local is_processed_by_row = {}

  if q["indent.zero"][node:id()] then
    return 0
  end

  while node do
    -- do 'autoindent' if not marked as @indent
    if
      not q["indent.begin"][node:id()]
      and not q["indent.align"][node:id()]
      and q["indent.auto"][node:id()]
      and node:start() < lnum - 1
      and lnum - 1 <= node:end_()
    then
      return -1
    end

    -- Do not indent if we are inside an @ignore block.
    -- If a node spans from L1,C1 to L2,C2, we know that lines where L1 < line <= L2 would
    -- have their indentations contained by the node.
    if
      not q["indent.begin"][node:id()]
      and q["indent.ignore"][node:id()]
      and node:start() < lnum - 1
      and lnum - 1 <= node:end_()
    then
      return 0
    end

    local srow, _, erow = node:range()

    local is_processed = false

    if
      not is_processed_by_row[srow]
      and ((q["indent.branch"][node:id()] and srow == lnum - 1) or (q["indent.dedent"][node:id()] and srow ~= lnum - 1))
    then
      indent = indent - indent_size
      is_processed = true
    end

    -- do not indent for nodes that starts-and-ends on same line and starts on target line (lnum)
    local should_process = not is_processed_by_row[srow]
    local is_in_err = false
    if should_process then
      local parent = node:parent()
      is_in_err = parent and parent:has_error()
    end
    if
      should_process
      and (
        q["indent.begin"][node:id()]
        and (srow ~= erow or is_in_err or q["indent.begin"][node:id()]["indent.immediate"])
        and (srow ~= lnum - 1 or q["indent.begin"][node:id()]["indent.start_at_same_line"])
      )
    then
      indent = indent + indent_size
      is_processed = true
    end

    if is_in_err and not q["indent.align"][node:id()] then
      -- only when the node is in error, promote the
      -- first child's aligned indent to the error node
      -- to work around ((ERROR "X" . (_)) @aligned_indent (#set! "delimeter" "AB"))
      -- matching for all X, instead set do
      -- (ERROR "X" @aligned_indent (#set! "delimeter" "AB") . (_))
      -- and we will fish it out here.
      for c in node:iter_children() do
        if q["indent.align"][c:id()] then
          q["indent.align"][node:id()] = q["indent.align"][c:id()]
          break
        end
      end
    end
    -- do not indent for nodes that starts-and-ends on same line and starts on target line (lnum)
    if should_process and q["indent.align"][node:id()] and (srow ~= erow or is_in_err) and (srow ~= lnum - 1) then
      local metadata = q["indent.align"][node:id()]
      local o_delim_node, o_is_last_in_line ---@type TSNode|nil, boolean|nil
      local c_delim_node, c_is_last_in_line ---@type TSNode|nil, boolean|nil, boolean|nil
      local indent_is_absolute = false
      if metadata["indent.open_delimiter"] then
        o_delim_node, o_is_last_in_line = find_delimiter(bufnr, node, metadata["indent.open_delimiter"])
      else
        o_delim_node = node
      end
      if metadata["indent.close_delimiter"] then
        c_delim_node, c_is_last_in_line = find_delimiter(bufnr, node, metadata["indent.close_delimiter"])
      else
        c_delim_node = node
      end

      if o_delim_node then
        local o_srow, o_scol = o_delim_node:start()
        local c_srow = nil
        if c_delim_node then
          c_srow, _ = c_delim_node:start()
        end
        if o_is_last_in_line then
          -- hanging indent (previous line ended with starting delimiter)
          -- should be processed like indent
          if should_process then
            indent = indent + indent_size * 1
            if c_is_last_in_line then
              -- If current line is outside the range of a node marked with `@aligned_indent`
              -- Then its indent level shouldn't be affected by `@aligned_indent` node
              if c_srow and c_srow < lnum - 1 then
                indent = math.max(indent - indent_size, 0)
              end
            end
          end
        else
          -- aligned indent
          if c_is_last_in_line and c_srow and o_srow ~= c_srow and c_srow < lnum - 1 then
            -- If current line is outside the range of a node marked with `@aligned_indent`
            -- Then its indent level shouldn't be affected by `@aligned_indent` node
            indent = math.max(indent - indent_size, 0)
          else
            indent = o_scol + (metadata["indent.increment"] or 1)
            indent_is_absolute = true
          end
        end
        -- deal with the final line
        local avoid_last_matching_next = false
        if c_srow and c_srow ~= o_srow and c_srow == lnum - 1 then
          -- delims end on current line, and are not open and closed same line.
          -- then this last line may need additional indent to avoid clashes
          -- with the next. `indent.avoid_last_matching_next` controls this behavior,
          -- for example this is needed for function parameters.
          avoid_last_matching_next = metadata["indent.avoid_last_matching_next"] or false
        end
        if avoid_last_matching_next then
          -- last line must be indented more in cases where
          -- it would be same indent as next line (we determine this as one
          -- width more than the open indent to avoid confusing with any
          -- hanging indents)
          if indent <= vim.fn.indent(o_srow + 1) + indent_size then
            indent = indent + indent_size * 1
          else
            indent = indent
          end
        end
        is_processed = true
        if indent_is_absolute then
          -- don't allow further indenting by parent nodes, this is an absolute position
          return indent
        end
      end
    end

    is_processed_by_row[srow] = is_processed_by_row[srow] or is_processed

    node = node:parent()
  end

  return indent
end

---@param col number the column number
---@return boolean
function M.col_in_screen(col)
    local leftcol = vim.fn.winsaveview().leftcol
    return col >= leftcol
end

return M
