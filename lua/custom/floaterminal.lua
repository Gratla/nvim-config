vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>')

local state = {
  floating = {
    buf = -1,
    win = -1,
    cmd = nil,
  },
}

function create_floating_window(opts)
  opts = opts or {}
  local width_ratio = opts.width_ratio or 0.8
  local height_ratio = opts.height_ratio or 0.8

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
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  elseif opts.cmd and vim.startswith(opts.cmd, ':') then
    vim.cmd(opts.cmd:sub(2))
    buf = vim.api.nvim_get_current_buf()
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
  local win = vim.api.nvim_open_win(buf, true, window_opts)

  if (not opts.cmd or not vim.startswith(opts.cmd, ':')) and vim.bo[buf].buftype ~= 'terminal' then
    vim.cmd.terminal()
  end

  if opts.cmd and vim.bo[buf].buftype == 'terminal' then
    local chan_id = vim.b[buf].terminal_job_id
    vim.api.nvim_chan_send(chan_id, opts.cmd .. '\n')
  end

  return { buf = buf, win = win, cmd = opts.cmd }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

vim.api.nvim_create_user_command('Floaterminal', toggle_terminal, {})
vim.keymap.set({ 'n', 't' }, '<leader>tt', toggle_terminal, { desc = '[t]oggle [t]erminal' })
