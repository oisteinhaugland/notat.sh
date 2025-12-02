-- nvim_integration.lua
-- Put this in your lua path or require from init.lua

local M = {}

-- Default config, can be overridden in setup
M.config = {
    notes_dir        = os.getenv("NOTES_BASE_DIR")    or (os.getenv("HOME") .. "/notes"),
    actions_dir      = os.getenv("NOTES_ACTIONS_DIR") or (os.getenv("HOME") .. "/notes/actions"),
    archive_dir      = os.getenv("NOTES_ARCHIVE_DIR") or nil, -- resolved in setup
}

-- Normalize paths
local function norm(...)
    return vim.fs.normalize(vim.fs.joinpath(...))
end

-- Get current context
local function get_context()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_get_current_line()
    local filename = vim.api.nvim_buf_get_name(0)
    return line, row, filename
end

-- Smart open function
-- Smart open function
function M.smart_open()
    local line, row, filename = get_context()

    --------------------------------------------------------------------
    -- 1. Detect @ Source: file:line
    --------------------------------------------------------------------
    local src = line:match("^@%s*Source:%s*(.-)%s*$")
    if src then
        local file, linen = src:match("^(.-):(%d+)$")
        if file and linen then
            vim.cmd.edit(vim.fs.normalize(file))
            vim.api.nvim_win_set_cursor(0, { tonumber(linen), 0 })
            return
        end
    end

    --------------------------------------------------------------------
    -- 2. Detect Markdown links [text](file:line)
    --------------------------------------------------------------------
    local md_file = line:match("%[.-%]%((.-)%)")
    if md_file then
        local path, linen = md_file:match("^(.-):(%d+)$")
        path = path or md_file
        linen = tonumber(linen) or 1
        vim.cmd.edit(vim.fs.normalize(path))
        vim.api.nvim_win_set_cursor(0, { linen, 0 })
        return
    end

    --------------------------------------------------------------------
    -- 3. Detect plain file references file:line
    --------------------------------------------------------------------
    local file_ref, linen_ref = line:match("([%w%/%.%-_]+):(%d+)")
    if file_ref and linen_ref then
        vim.cmd.edit(vim.fs.normalize(file_ref))
        vim.api.nvim_win_set_cursor(0, { tonumber(linen_ref), 0 })
        return
    end

    --------------------------------------------------------------------
    -- 4. Detect action lines starting with [.,=x>?]
    --------------------------------------------------------------------
    -- Fix: Allow whitespace before symbol (^%s*)
    -- Fix: Capture both symbol and text correctly
    local symbol, text = line:match("^%s*([.,=x>?])%s*(.*)")
    
    if symbol then
        local clean = text or ""
        -- Trim trailing whitespace
        clean = clean:gsub("%s+$", "")
        
        -- If title is empty, prompt user
        if clean == "" then
            vim.ui.input({ prompt = "Enter action title: " }, function(input)
                if input and input ~= "" then
                    M.create_action_note(input, filename, row)
                else
                    vim.notify("Action creation cancelled (empty title).", vim.log.levels.WARN)
                end
            end)
            return
        end

        M.create_action_note(clean, filename, row)
        return
    end

    vim.notify("No action or link found on this line.", vim.log.levels.WARN)
end

function M.create_action_note(title, source_file, source_row)
    local safe = title:gsub(" ", "_"):gsub("[^%w_%-]", "")
    -- Fallback if safe title is empty (e.g. title was just symbols)
    if safe == "" then
        safe = "Untitled_Action_" .. os.time()
    end
    
    local action_file = norm(M.config.actions_dir, safe .. ".md")

    if vim.fn.filereadable(action_file) == 0 then
        vim.fn.mkdir(M.config.actions_dir, "p")
        vim.fn.writefile({
            "# ACTION: " .. title,
            "@ Source: " .. source_file .. ":" .. source_row,
            ""
        }, action_file)
        vim.notify("Created: " .. action_file, vim.log.levels.INFO)
    end

    vim.cmd.edit(action_file)
end

-- Toggle action state
-- Toggle action state
function M.toggle_state(target)
    local line = vim.api.nvim_get_current_line()
    -- Fix: Allow whitespace before symbol
    local sym = line:match("^%s*([.,=x>?])")

    if not sym then
        vim.notify("Not an action line.", vim.log.levels.INFO)
        return
    end

    local new = (sym == target) and "." or target
    -- Replace the first occurrence of the symbol
    local updated = line:gsub(sym, new, 1)
    vim.api.nvim_set_current_line(updated)
end

-- Archive current note
function M.archive_current_note()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        vim.notify("No file to archive.", vim.log.levels.WARN)
        return
    end

    local notes = M.config.notes_dir
    local archive = M.config.archive_dir or norm(notes, "archive")

    if not file:find(vim.fs.normalize(notes), 1, true) then
        vim.notify("File not in notes directory.", vim.log.levels.ERROR)
        return
    end

    local rel = vim.fn.fnamemodify(file, ":p"):sub(#notes + 2)
    local type_dir = rel:match("^([^/]+)")
    local name = vim.fn.fnamemodify(file, ":t")

    if not type_dir then
        vim.notify("Couldn't detect note type.", vim.log.levels.ERROR)
        return
    end

    local target_dir = norm(archive, type_dir)
    local target_file = norm(target_dir, name)

    vim.fn.mkdir(target_dir, "p")

    local ok, err = vim.loop.fs_rename(file, target_file)
    if not ok then
        vim.notify("Archive error: " .. err, vim.log.levels.ERROR)
        return
    end

    vim.api.nvim_buf_set_name(0, target_file)
    vim.notify("Archived → " .. target_file, vim.log.levels.INFO)
end

-- Setup keymaps
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})

    vim.keymap.set('n', '<leader>o', M.smart_open, { desc = "Smart Open Action/Link" })
    vim.keymap.set('n', '<leader>x', function() M.toggle_state('x') end, { desc = "Mark Closed" })
    vim.keymap.set('n', '<leader>a', function() M.toggle_state('=') end, { desc = "Mark Active" })
    vim.keymap.set('n', '<leader>,', function() M.toggle_state(',') end, { desc = "Mark Parked" })
    vim.keymap.set('n', '<leader>q', function() M.toggle_state('?') end, { desc = "Mark Question" })
    vim.keymap.set('n', '<leader>A', M.archive_current_note, { desc = "Archive Note" })
end

return M

