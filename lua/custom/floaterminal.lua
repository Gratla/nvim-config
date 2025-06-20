local floaterminal = {}
vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>')

floaterminal.create_floating_window = function(tmux_session_name, cmd)
  local opts = { tmux_session_name = tmux_session_name, cmd = cmd or '' }
  local width_ratio = 0.8
  local height_ratio = 0.8

  -- Get the editor's current dimensions
  local ui = vim.api.nvim_list_uis()[1]
  local screen_width = ui.width
  local screen_height = ui.height

  -- Calculate width and height in cells
  local width = math.floor(screen_width * width_ratio)
  local height = math.floor(screen_height * height_ratio)

  -- Center the window
  local row = math.floor((screen_height - height) / 2)
  local col = math.floor((screen_width - width) / 2)

  -- Create a new (scratch) buffer
  local buf = nil
  if opts.cmd and vim.startswith(opts.cmd, ':') then
    vim.cmd(opts.cmd:sub(2))
    buf = vim.api.nvim_get_current_buf()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == buf then
        vim.api.nvim_win_close(win, false)
      end
    end
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  -- Window options
  local window_opts = {
    style = 'minimal',
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = 'rounded',
  }

  -- Create the floating window
  vim.api.nvim_open_win(buf, true, window_opts)

  if (not opts.cmd or not vim.startswith(opts.cmd, ':')) and vim.bo[buf].buftype ~= 'terminal' then
    vim.cmd.terminal()
  end

  if vim.bo[buf].buftype == 'terminal' then
    local chan_id = vim.b[buf].terminal_job_id
    if opts.cmd ~= '' then
      vim.api.nvim_chan_send(chan_id, 'tmux new-session -A -s ' .. opts.tmux_session_name .. ' -- "' .. opts.cmd .. '; bash"\n')
    else
      vim.api.nvim_chan_send(chan_id, 'tmux new-session -A -s ' .. opts.tmux_session_name .. '\n')
    end
  end
end

vim.api.nvim_create_user_command('Floaterminal', function()
  floaterminal.create_floating_window 'terminal'
end, {})
vim.keymap.set({ 'n', 't' }, '<leader>tt', function()
  floaterminal.create_floating_window 'terminal'
end, { desc = '[t]oggle [t]erminal' })

return floaterminal
