return {
    name = 'dotnet-verify-picker',
    dir = vim.fn.stdpath('config'),
    dependencies = {
        'nvim-telescope/telescope.nvim',
        'nvim-lua/plenary.nvim',
    },
    config = function()
        local telescope = require('telescope')
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')
        local verify = require('utils.verify')

        -- Main picker function
        local function show_verify_picker()
            local scope = verify.get_search_scope()
            local received_files = verify.find_received_files(scope.dir, scope.pattern)

            if #received_files == 0 then
                if scope.type == 'class' then
                    vim.notify('No received snapshots found for class: ' .. scope.pattern, vim.log.levels.INFO)
                else
                    vim.notify('No received snapshots found in project', vim.log.levels.INFO)
                end
                return
            end

            local picker_title = scope.type == 'class' 
                and 'Verify Snapshots (Class: ' .. scope.pattern .. ')'
                or 'Verify Snapshots (Project)'

            pickers.new({}, {
                prompt_title = picker_title,
                finder = finders.new_table({
                    results = received_files,
                    entry_maker = function(entry)
                        -- Show relative path from git root for cleaner display
                        local display = vim.fn.fnamemodify(entry, ':~:.')
                        return {
                            value = entry,
                            display = display,
                            ordinal = display,
                        }
                    end,
                }),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)
                        verify.open_diff(selection.value)
                    end)
                    return true
                end,
            }):find()
        end

        -- Command to open diff for current file or show picker
        local function open_diff_smart()
            local current_file = vim.fn.expand('%:p')
            
            if verify.is_snapshot_file(current_file) then
                -- Current file is a snapshot file, open its diff directly
                if current_file:match('%.received%.') then
                    verify.open_diff(current_file)
                elseif current_file:match('%.verified%.') then
                    -- Find corresponding received file
                    local received = current_file:gsub('%.verified%.', '.received.')
                    if vim.fn.filereadable(received) == 1 then
                        verify.open_diff(received)
                    else
                        vim.notify('No corresponding received file found', vim.log.levels.WARN)
                    end
                end
            else
                -- Not in a snapshot file, show picker
                show_verify_picker()
            end
        end

        -- Accept current snapshot and close buffers
        local function accept_current()
            local current_file = vim.fn.expand('%:p')
            
            if not current_file:match('%.received%.') then
                vim.notify('Not in a received snapshot file', vim.log.levels.WARN)
                return
            end

            verify.accept_snapshot(current_file)
        end

        -- Reject current snapshot and close buffers
        local function reject_current()
            local current_file = vim.fn.expand('%:p')
            
            if not current_file:match('%.received%.') then
                vim.notify('Not in a received snapshot file', vim.log.levels.WARN)
                return
            end

            verify.reject_snapshot(current_file)
        end

        -- Set up keymaps
        vim.keymap.set('n', '<leader>vl', show_verify_picker, { desc = 'List Verify snapshots' })
        vim.keymap.set('n', '<leader>vd', open_diff_smart, { desc = 'Open Verify diff' })
        vim.keymap.set('n', '<leader>va', accept_current, { desc = 'Accept Verify snapshot' })
        vim.keymap.set('n', '<leader>vr', reject_current, { desc = 'Reject Verify snapshot' })
    end,
}
