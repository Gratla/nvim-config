-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ':m -2<Enter>gv')

vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

vim.keymap.set('x', '<leader>p', '"_dP')

vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')

vim.keymap.set('n', 'Q', '<nop>')

vim.keymap.set('n', '<leader>rr', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz')
vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz')
vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')

vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- Reset default view

vim.keymap.set('n', '<leader>pd', ':%bd|e#<Enter>', { desc = '[p]repare [d]efault view' })

-- Remap Harpoon
local harpoon = require 'harpoon'
harpoon:setup()

vim.keymap.set('n', '<leader>a', function()
  harpoon:list():add()
end, { desc = 'harpoon [a]dd' })
vim.keymap.set('n', '<leader>e', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = 'harpoon [e]dit' })

vim.keymap.set('n', '<leader>1', function()
  harpoon:list():select(1)
end, { desc = 'harpoon 1' })
vim.keymap.set('n', '<leader>2', function()
  harpoon:list():select(2)
end, { desc = 'harpoon 2' })
vim.keymap.set('n', '<leader>3', function()
  harpoon:list():select(3)
end, { desc = 'harpoon 3' })
vim.keymap.set('n', '<leader>4', function()
  harpoon:list():select(4)
end, { desc = 'harpoon 4' })

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set('n', '<leader>hp', function()
  harpoon:list():prev()
end)
vim.keymap.set('n', '<leader>hn', function()
  harpoon:list():next()
end)

vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- Git
local function open_or_reuse_fugitive()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match '^fugitive://' then
      vim.api.nvim_set_current_win(win)
    end
  end
end

local function open_fugitive()
  open_or_reuse_fugitive()
  vim.cmd 'Git'
end
vim.keymap.set('n', '<leader>gg', open_fugitive, { desc = '[g]it' })

vim.keymap.set('n', '<leader>gs', [[:Git status<Enter>]], { desc = '[g]it [s]tatus' })
vim.keymap.set('n', '<leader>gaa', [[:Git add -A<Enter>]], { desc = '[g]it [a]dd [a]ll' })
local function git_commit_with_ticket()
  local result = vim.system({ 'git', 'rev-parse', '--abbrev-ref', 'HEAD' }):wait()
  local branch_name = vim.trim(result.stdout)
  local ticket_name = branch_name:match '([^/]+)'
  local commit_message_prefix = ''
  if ticket_name ~= nil and ticket_name ~= 'master' then
    commit_message_prefix = ticket_name .. ': '
  end
  local commit_cmd = ':Git commit -am "' .. commit_message_prefix .. '"<Left>'
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(commit_cmd, true, false, true), 'n', true)
end
vim.keymap.set('n', '<leader>gc', git_commit_with_ticket, { desc = '[g]it [c]ommit' })
vim.keymap.set('n', '<leader>gac', [[:Git commit --amend --all<Enter>]], { desc = '[g]it [a]mend [c]ommit' })
vim.keymap.set('n', '<leader>gp', [[:Git push<Enter>]], { desc = '[g]it [p]ush' })
vim.keymap.set('n', '<leader>gfp', [[:Git push --force-with-lease]], { desc = '[g]it [f]orce (with lease) [p]ush' })
vim.keymap.set('n', '<leader>gu', [[:Git pull<Enter>]], { desc = '[g]it [u]pdate (pull)' })

local function git_diff()
  local current_file = vim.fn.expand '%'
  open_or_reuse_fugitive()
  vim.cmd 'Git'
  vim.fn.search(current_file, 'cw')
  vim.api.nvim_input '='
end
vim.keymap.set('n', '<leader>gd', git_diff, { desc = '[g]it [d]iff' })
vim.keymap.set('n', '<leader>gl', [[:Git log --all --decorate --oneline --graph<Enter>]], { desc = '[g]it [l]og' })
vim.keymap.set('n', '<leader>gb', [[:Git blame<Enter>]], { desc = '[g]it [b]lame' })
vim.keymap.set('n', '<leader>grh', [[:Git reset --hard]], { desc = '[g]it [r]eset [h]ard' })
vim.keymap.set('n', '<leader>grs', [[:Git reset --soft]], { desc = '[g]it [r]eset [s]oft' })
local function git_fetch_rebase_master()
  vim.cmd ':Git fetch'
  vim.cmd ':Git rebase origin/master'
end
vim.keymap.set('n', '<leader>grm', git_fetch_rebase_master, { desc = '[g]it [r]ebase [m]aster' })

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local function git_branch_switcher()
  -- Get list of local branches using git
  vim.cmd ':Git fetch'
  local branches = vim.fn.systemlist "git branch --format='%(refname:short)'"

  pickers
    .new({}, {
      prompt_title = 'Git Switch or Create Branch',
      finder = finders.new_table {
        results = branches,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          local user_input = picker:_get_prompt()

          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          local input = (selection and selection[1]) or user_input or vim.fn.input 'Branch name: '

          vim.fn.system(string.format('git show-ref --verify --quiet refs/heads/%s', input))
          if vim.v.shell_error == 0 then
            vim.cmd(':Git switch ' .. input)
          else
            vim.cmd(':Git switch -c ' .. input)
          end
        end)
        return true
      end,
    })
    :find()
end

vim.keymap.set('n', '<leader>gn', git_branch_switcher, { desc = '[g]it switch/create bra[n]ch' })

-- Git signs

vim.keymap.set('n', '<leader>gir', ':Gitsigns reset_hunk<Enter>', { desc = '[g]it [i]line [r]eset hunk' })
vim.keymap.set('n', '<leader>gip', ':Gitsigns preview_hunk<Enter>', { desc = '[g]it [i]line [p]review hunk' })

-- Refactoring

vim.keymap.set('x', '<leader>re', ':Refactor extract<Enter>', { desc = '[r]efactor [e]xtract' })
vim.keymap.set('x', '<leader>rf', ':Refactor extract_to_file<Enter>', { desc = '[r]efactor extract to [f]ile' })

vim.keymap.set('x', '<leader>rv', ':Refactor extract_var<Enter>', { desc = '[r]efactor [e]xtract [v]ar' })

vim.keymap.set('x', '<leader>ri', ':Refactor inline_var<Enter>', { desc = '[r]efactor [i]nline var' })

vim.keymap.set('x', '<leader>rI', ':Refactor inline_func<Enter>', { desc = '[r]efactor [I]nline function' })

vim.keymap.set('x', '<leader>rb', ':Refactor extract_block<Enter>', { desc = '[r]efactor extract [b]lock' })
vim.keymap.set('x', '<leader>rbf', ':Refactor extract_block_to_file<Enter>', { desc = '[r]efactor extract [b]lock to [f]ile' })

-- Java
vim.keymap.set('n', '<leader>mr', function()
  vim.fn.system '~/.config/tmux/scripts/tmux-windowizer run'

  local run_command = 'mvn package && java -jar $(ls target/*.jar)'
  local full_command = string.format('tmux send-keys -t run "%s"<Enter>', run_command)
  local system_command = vim.api.nvim_replace_termcodes(full_command, true, false, true)
  vim.fn.system(system_command)
end, { desc = '[m]nv [r]un' })

vim.keymap.set('n', '<leader>mT', function()
  vim.fn.system '~/.config/tmux/scripts/tmux-windowizer test'

  local run_command = 'mvn test'
  local full_command = string.format('tmux send-keys -t test "%s"<Enter>', run_command)
  local system_command = vim.api.nvim_replace_termcodes(full_command, true, false, true)
  vim.fn.system(system_command)
end, { desc = '[m]vn [T]est all' })

-- Testing
vim.keymap.set('n', '<leader>tn', ':TestNearest -strategy=neovim_sticky <Enter>', { desc = '[t]est [n]earest' })
vim.keymap.set('n', '<leader>ta', ':TestSuite -strategy=neovim_sticky <Enter>', { desc = '[t]est [a]ll' })
vim.keymap.set('n', '<leader>tv', ':TestVisit<Enter>', { desc = '[t]est [v]isit' })
