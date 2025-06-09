local function augroup(name, clear)
  if type(clear) ~= 'boolean' then
    clear = true
  end

  return vim.api.nvim_create_augroup(name, { clear = clear })
end
local icons = require 'custom.config.icons'

-- expose theme to vim.ui_theme. Will be assumed that the coloscheme set
-- vim.g.terminal_color_* (usually configurable by the colorscheme plugin)
vim.api.nvim_create_autocmd('ColorScheme', {
  group = augroup 'define_ui_theme',
  callback = function()
    local is_light = vim.o.background == 'light'
    -- stylua: ignore
    vim.g.ui_theme = {
      normal  = vim.g['terminal_color_' .. (is_light and 8  or 7 )],
      insert  = vim.g['terminal_color_' .. (is_light and 4  or 12)],
      replace = vim.g['terminal_color_' .. (is_light and 3  or 11)],
      visual  = vim.g['terminal_color_' .. (is_light and 5  or 13)],
      command = vim.g['terminal_color_' .. (is_light and 1  or 9 )],
      text    = vim.g['terminal_color_' .. (is_light and 15 or 0 )],
    }

    vim.cmd.highlight(string.format('FloatBorder guifg=%s', vim.g.ui_theme.normal))
    vim.cmd.highlight(string.format('FloatTitle guibg=%s guifg=%s gui=bold', vim.g.ui_theme.normal, vim.g.ui_theme.text))
  end,
})

-- clear vim.g.ui_theme before a new coloscheme is loaded
vim.api.nvim_create_autocmd('ColorSchemePre', {
  group = augroup 'clear_ui_theme',
  callback = function()
    local theme = {}

    for i = 0, 15 do
      theme['terminal_color_' .. i] = 'NONE'
    end

    vim.ui_theme = theme
  end,
})

return {
  'nvim-lualine/lualine.nvim',
  opts = {
    options = {
      globalstatus = vim.o.laststatus == 3,
      component_separators = '',
      section_separators = { left = '', right = '' },
    },
    sections = {
      lualine_a = {
        {
          'mode',
          icon = icons.neovim,
          separator = { left = '', right = '' },
          padding = { left = 1, right = 0 },
        },
      },
      lualine_b = {
        { 'branch', icon = icons.git.branch, 'diff', 'diagnostics', 'filename' },
      },
      lualine_c = {
        { '%=', padding = 0 },
        {
          'datetime',
          icon = icons.clock,
          style = '%H:%M ',
          separator = { left = '', right = '' },
          padding = 0,
        },
      },
      lualine_x = {},
      lualine_y = {
        {
          'filetype',
          fmt = function(name)
            return string.upper(name)
          end,
        },
      },
      lualine_z = {
        {
          function()
            local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
            local max_lnum = vim.api.nvim_buf_line_count(0)

            local ruler
            if lnum == 1 then
              ruler = 'TOP'
            elseif lnum == max_lnum then
              ruler = 'BOT'
            else
              ruler = string.format('%2d%%%%', math.floor(100 * lnum / max_lnum))
            end

            return string.format('%' .. string.len(vim.bo.textwidth) .. 'd %s', col + 1, ruler)
          end,
          separator = { left = '', right = '' },
          padding = { left = 0, right = 1 },
        },
      },
    },
  },
  config = function(_, opts)
    vim.opt.showmode = false
    vim.opt.fillchars:append {
      stl = '━',
      stlnc = '━',
    }

    local function lualine_theme()
      vim.cmd.highlight 'clear StatusLine'

      local theme = {}
      local ui_theme = vim.g.ui_theme

      local normal = vim.api.nvim_get_hl(0, { link = false, name = 'Normal' })
      local stl_fg = normal.fg and string.format('#%06x', normal.fg) or 'NONE'

      for _, mode in pairs {
        'normal',
        'insert',
        'visual',
        'replace',
        'command',
      } do
        theme[mode] = {
          a = { bg = ui_theme[mode], fg = ui_theme.text, gui = 'bold' },
          b = { bg = 'NONE', fg = stl_fg },
          c = { bg = 'NONE', fg = ui_theme[mode], gui = 'bold' },
        }
      end

      return theme
    end

    vim.api.nvim_create_autocmd('ColorScheme', {
      group = augroup 'lualine_reload',
      callback = function()
        vim.defer_fn(
          vim.schedule_wrap(function()
            local cfg = require('lualine').get_config()
            cfg.options.theme = lualine_theme()
            -- force reload
            package.loaded.lualine = nil
            require('lualine').setup(cfg)
          end),
          100
        )
      end,
    })

    local theme = lualine_theme()

    opts.options = opts.options or {}
    opts.options.theme = theme

    require('lualine').setup(opts)
  end,
}
