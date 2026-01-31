local M = {}

-- Get git root directory (works with worktrees)
local function get_git_root()
    local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
    if vim.v.shell_error == 0 and git_root then
        return git_root
    end
    error('Not in a git repository')
end

-- Find all .received files using ripgrep
function M.find_received_files(dir, pattern)
    local root = dir or get_git_root()
    local cmd = string.format(
        "rg --files --glob '%s' %s",
        pattern or '*.received.*',
        vim.fn.shellescape(root)
    )
    
    local handle = io.popen(cmd)
    if not handle then
        error('Failed to run ripgrep')
    end
    
    local result = handle:read("*a")
    handle:close()
    
    local files = {}
    for file in result:gmatch("[^\n]+") do
        table.insert(files, file)
    end
    
    return files
end

-- Get current class name from buffer
function M.get_current_class_name()
    local filename = vim.fn.expand('%:t:r')  -- filename without extension
    
    -- Match *Should or *Test patterns
    if filename:match('Should$') or filename:match('Test$') then
        return filename
    end
    
    return nil
end

-- Get search scope based on context
function M.get_search_scope()
    local class_name = M.get_current_class_name()
    local root = get_git_root()
    
    if class_name then
        return {
            type = 'class',
            class_name = class_name,
            pattern = class_name .. '.*.received.*',
            dir = root
        }
    else
        return {
            type = 'project',
            pattern = '*.received.*',
            dir = root
        }
    end
end

-- Check if file is a snapshot and what type
function M.is_snapshot_file(filepath)
    if filepath:match('%.received%.') then
        return true, 'received'
    elseif filepath:match('%.verified%.') then
        return true, 'verified'
    end
    return false, nil
end

-- Convert received path to verified path
function M.get_verified_path(received_path)
    return received_path:gsub('%.received%.', '.verified.')
end

-- Setup optimal diff options
local function setup_diff_options()
    -- Better diff algorithm
    vim.opt_local.diffopt:append('algorithm:patience')
    
    -- Ignore whitespace changes
    vim.opt_local.diffopt:append('iwhite')
    
    -- Show context lines
    vim.opt_local.diffopt:append('context:3')
    
    -- Vertical splits
    vim.opt_local.diffopt:append('vertical')
    
    -- Character-level highlighting (Neovim 0.9+)
    vim.opt_local.diffopt:append('linematch:60')
    
    -- Don't wrap lines
    vim.opt_local.wrap = false
    
    -- Sync scrolling
    vim.opt_local.scrollbind = true
    
    -- Disable folding in diff mode
    vim.opt_local.foldenable = false
    vim.opt_local.foldcolumn = '0'
end

-- Open diff view in new tab
function M.open_diff(received_path)
    local verified_path = M.get_verified_path(received_path)
    local verified_exists = vim.fn.filereadable(verified_path) == 1
    
    -- Open new tab
    vim.cmd('tabnew')
    
    if not verified_exists then
        -- New snapshot - show only received
        vim.notify(
            '[New snapshot - no verified file exists yet]',
            vim.log.levels.WARN
        )
        vim.cmd('edit ' .. vim.fn.fnameescape(received_path))
        return
    end
    
    -- Open verified file in the new tab
    vim.cmd('edit ' .. vim.fn.fnameescape(verified_path))
    vim.cmd('diffthis')
    setup_diff_options()
    
    -- Open received file in vertical split
    vim.cmd('vsplit ' .. vim.fn.fnameescape(received_path))
    vim.cmd('diffthis')
    setup_diff_options()
    
    -- Focus on received (right side)
    vim.cmd('wincmd l')
end

-- Close diff windows and return to previous state
function M.close_diff_windows()
    -- Exit diff mode
    vim.cmd('diffoff!')
    
    -- Close all windows except one
    vim.cmd('only')
end

-- Accept snapshot (copy received → verified, delete received, close tab)
function M.accept_snapshot(received_path)
    local verified_path = M.get_verified_path(received_path)
    local basename = vim.fn.fnamemodify(received_path, ':t')
    
    -- Copy file
    local success, err = pcall(function()
        local content = vim.fn.readfile(received_path)
        vim.fn.writefile(content, verified_path)
    end)
    
    if not success then
        vim.notify(
            '✗ Failed to accept snapshot: ' .. tostring(err),
            vim.log.levels.ERROR
        )
        return false
    end
    
    -- Delete received file
    vim.fn.delete(received_path)
    
    -- Close the tab
    vim.cmd('tabclose')
    
    -- Success notification
    vim.notify(
        '✓ Accepted: ' .. basename,
        vim.log.levels.INFO
    )
    
    return true
end

-- Reject snapshot (delete received, close tab)
function M.reject_snapshot(received_path)
    local basename = vim.fn.fnamemodify(received_path, ':t')
    
    -- Delete received file
    vim.fn.delete(received_path)
    
    -- Close the tab
    vim.cmd('tabclose')
    
    -- Notification
    vim.notify(
        '✗ Rejected: ' .. basename,
        vim.log.levels.WARN
    )
    
    return true
end

return M
