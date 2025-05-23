vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
-- Set <space> as the leader key

local harpoon = require 'harpoon'
harpoon:setup()

vim.keymap.set('n', '<leader>ha', function()
  harpoon:list():add()
end, { desc = '[h]arpoon [a]dd' })
vim.keymap.set('n', '<leader>he', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set('n', '<leader>h1', function()
  harpoon:list():select(1)
end)
vim.keymap.set('n', '<leader>h2', function()
  harpoon:list():select(2)
end)
vim.keymap.set('n', '<leader>h3', function()
  harpoon:list():select(3)
end)
vim.keymap.set('n', '<leader>h4', function()
  harpoon:list():select(4)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set('n', '<leader>hp', function()
  harpoon:list():prev()
end)
vim.keymap.set('n', '<leader>hn', function()
  harpoon:list():next()
end)

vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

vim.keymap.set('n', '<leader>gs', vim.cmd.Git, { desc = '[g]it [s]atus' })
vim.keymap.set('n', '<leader>gc', [[:Git commit -am ""<Left>]], { desc = '[g]it [c]ommit' })
vim.keymap.set('n', '<leader>gac', [[:Git commit --amend --all]], { desc = '[g]it [a]mend [c]ommit' })
