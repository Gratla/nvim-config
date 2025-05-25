vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
-- Set <space> as the leader key

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

vim.keymap.set('n', '<leader>gg', vim.cmd.Git, { desc = '[g]it' })
vim.keymap.set('n', '<leader>gs', [[:Git status<Enter>]], { desc = '[g]it [s]tatus' })
vim.keymap.set('n', '<leader>gaa', [[:Git add -A<Enter>]], { desc = '[g]it [a]dd [a]ll' })
vim.keymap.set('n', '<leader>gc', [[:Git commit -am ""<Left>]], { desc = '[g]it [c]ommit' })
vim.keymap.set('n', '<leader>gac', [[:Git commit --amend --all<Enter>]], { desc = '[g]it [a]mend [c]ommit' })
vim.keymap.set('n', '<leader>gp', [[:Git push<Enter>]], { desc = '[g]it [p]ush' })
vim.keymap.set('n', '<leader>gfp', [[:Git push --force-with-lease]], { desc = '[g]it [f]orce (with lease) [p]ush' })
vim.keymap.set('n', '<leader>gd', [[:Git diff<Enter>]], { desc = '[g]it [d]iff' })
vim.keymap.set('n', '<leader>gl', [[:Git log --all --decorate --oneline --graph<Enter>]], { desc = '[g]it [l]og' })
vim.keymap.set('n', '<leader>gb', [[:Git blame<Enter>]], { desc = '[g]it [b]lame' })
vim.keymap.set('n', '<leader>grh', [[:Git reset --hard]], { desc = '[g]it [r]eset [h]ard' })
vim.keymap.set('n', '<leader>grs', [[:Git reset --soft]], { desc = '[g]it [r]eset [s]oft' })

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
