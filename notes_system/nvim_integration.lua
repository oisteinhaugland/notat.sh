-- nvim_integration.lua
-- Put this file in your lua path or require it from your init.lua

local M = {}

local function get_context()
    local line = vim.api.nvim_get_current_line()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    local filename = vim.fn.expand('%:p')
    local relative_path = vim.fn.fnamemodify(filename, ':.')
    return line, row, relative_path
end

function M.smart_open()
    local line, row, filename = get_context()
    
    -- Check for Source Link: "@ Source: path/to/file:line"
    local source_match = line:match("^@ Source: (.*)")
    if source_match then
        local file, line_num = source_match:match("([^:]+):(%d+)")
        if file and line_num then
            vim.cmd("edit " .. file)
            vim.cmd(line_num)
            return
        end
    end

    -- Check for Action Line: starts with symbol
    local action_match = line:match("^[.,=x>?]%s*(.*)")
    if action_match then
        local source = filename .. ":" .. row
        local clean_title = line:gsub("^[.,=x>?]%s*", "")
        local safe_title = clean_title:gsub(" ", "_"):gsub("[^%w_%-]", "")
        
        local notes_dir = os.getenv("NOTES_ACTIONS_DIR") or (os.getenv("HOME") .. "/notes/actions")
        local action_file = notes_dir .. "/" .. safe_title .. ".md"
        
        -- Create if not exists
        local f = io.open(action_file, "r")
        if f then
            f:close()
        else
            f = io.open(action_file, "w")
            if f then
                f:write("# ACTION: " .. clean_title .. "\n")
                f:write("@ Source: " .. source .. "\n")
                f:close()
                print("Created action note: " .. action_file)
            else
                print("Error creating file: " .. action_file)
                return
            end
        end
        
        vim.cmd("edit " .. action_file)
        return
    end
    
    print("No action or link found on line.")
end

function M.toggle_state(target_symbol)
    local line = vim.api.nvim_get_current_line()
    local current_symbol = line:match("^([.,=x>?])")
    
    if not current_symbol then
        print("Not an action line.")
        return
    end
    
    local new_symbol = target_symbol
    if current_symbol == target_symbol then
        new_symbol = "." -- Toggle back to open
    end
    
    local new_line = line:gsub("^" .. current_symbol, new_symbol, 1)
    vim.api.nvim_set_current_line(new_line)
end

function M.archive_current_note()
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file == "" then
        print("No file to archive.")
        return
    end

    local notes_base = os.getenv("NOTES_BASE_DIR") or (os.getenv("HOME") .. "/notes")
    local archive_base = os.getenv("NOTES_ARCHIVE_DIR") or (notes_base .. "/archive")

    -- Check if file is inside notes dir
    if not current_file:find(notes_base, 1, true) then
        print("File is not in notes directory.")
        return
    end

    -- Determine relative path and type
    local rel_path = current_file:sub(#notes_base + 2)
    local type_dir = rel_path:match("^([^/]+)")
    local filename = rel_path:match("[^/]+$")
    
    if not type_dir or not filename then
        print("Could not determine note type.")
        return
    end

    local target_dir = archive_base .. "/" .. type_dir
    local target_file = target_dir .. "/" .. filename

    -- Create target directory
    os.execute("mkdir -p " .. target_dir)

    -- Move file
    local success, err = os.rename(current_file, target_file)
    if success then
        print("Archived to: " .. target_dir .. "/" .. filename)
        -- We keep the buffer open but it now points to the new location? 
        -- Actually os.rename moves it on disk. Neovim buffer might get confused or show "file no longer exists".
        -- Best practice: Rename the buffer to the new location.
        vim.cmd("file " .. target_file)
    else
        print("Error archiving file: " .. err)
    end
end

function M.setup()
    vim.keymap.set('n', '<leader>o', M.smart_open, { noremap = true, silent = true, desc = "Smart Open Action/Link" })
    vim.keymap.set('n', '<leader>x', function() M.toggle_state('x') end, { noremap = true, silent = true, desc = "Toggle Action Closed" })
    vim.keymap.set('n', '<leader>a', function() M.toggle_state('=') end, { noremap = true, silent = true, desc = "Toggle Action Active" })
    vim.keymap.set('n', '<leader>,', function() M.toggle_state(',') end, { noremap = true, silent = true, desc = "Toggle Action Parked" })
    vim.keymap.set('n', '<leader>q', function() M.toggle_state('?') end, { noremap = true, silent = true, desc = "Toggle Action Question" })
    
    -- Archive
    vim.keymap.set('n', '<leader>A', M.archive_current_note, { noremap = true, silent = true, desc = "Archive Note" })
end

return M
