# chalk.nvim

A sophisticated Neovim colorscheme with dynamic color adjustment capabilities. Designed with earth tones and refined jewel accents for visual harmony and developer productivity.

![Neovim Version](https://img.shields.io/badge/Neovim-0.8%2B-green.svg)
![Lua](https://img.shields.io/badge/Made%20with-Lua-blueviolet.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## Features

- **Sophisticated Color Palette**: Earth tones with refined jewel accents designed for visual harmony
- **Dynamic Color Adjustment**: Real-time color modification with TreeSitter integration
- **Multiple Variants**: Default, light, and OLED-optimized themes
- **Smart Plugin Integration**: Auto-detection and custom highlights for popular plugins
- **High Performance**: Optimized caching system and lazy loading
- **Full Customization**: Extensive configuration options and callback system
- **Type Safety**: Complete TypeScript-like type definitions
- **Interactive Features**: Live color inspection and adjustment tools

## Screenshots

> Screenshots coming soon

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "your-username/chalk.nvim",
  priority = 1000, -- Load before other plugins
  config = function()
    require("chalk").setup({
      variant = "default",
      transparent = false,
    })
    vim.cmd.colorscheme("chalk")
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "your-username/chalk.nvim",
  config = function()
    require("chalk").setup()
    vim.cmd.colorscheme("chalk")
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'your-username/chalk.nvim'
```

## Configuration

### Basic Setup

```lua
require("chalk").setup({
  variant = "default", -- "default", "light", "oled"
  transparent = false,
  terminal_colors = true,
})
vim.cmd.colorscheme("chalk")
```

### Complete Configuration Reference

```lua
require("chalk").setup({
  -- Theme variants
  variant = "default", -- "default", "light", "oled"
  light_variant = "light", -- variant to use when vim.o.background = "light"

  -- Visual options
  transparent = false,
  terminal_colors = true,
  dim_inactive = false, -- dim inactive windows

  -- Performance
  cache = true, -- enable caching for better performance

  -- Style configurations for syntax elements
  styles = {
    comments = { italic = true },
    keywords = { bold = false, italic = false },
    functions = { bold = false, italic = false },
    variables = { italic = false },
    strings = { italic = false },
    types = { bold = false, italic = false },
    constants = { bold = false },
    operators = { bold = false },
  },

  -- Plugin integrations with auto-detection
  plugins = {
    -- Enable all detected plugins by default
    all = true,
    -- Auto-detect available plugins
    auto = true,
    
    -- Individual plugin controls (override auto-detection)
    treesitter = true,
    telescope = true,
    nvim_cmp = true,
    gitsigns = true,
    lualine = true,
    which_key = true,
    indent_blankline = true,
    nvim_tree = true,
    neo_tree = true,
    bufferline = true,
    dashboard = true,
    alpha = true,
    noice = true,
    notify = true,
    mini = true,
    leap = true,
    flash = true,
    navic = true,
    aerial = true,
  },

  -- Dynamic color features (optional)
  enable_dynamic_colors = true,
  dynamic_keymaps = true,
  dynamic_prefix = "<leader>c",
  dynamic_step = 0.1,

  -- Customization callbacks
  ---@param colors chalk.ColorScheme
  on_colors = function(colors)
    -- Modify colors before highlights are generated
    -- colors.primary = "#ff0000" -- Example: change primary color
    -- colors.comment = "#666666" -- Example: change comment color
  end,

  ---@param highlights chalk.Highlights
  ---@param colors chalk.ColorScheme  
  on_highlights = function(highlights, colors)
    -- Modify highlight groups after generation
    -- highlights.Normal = { fg = colors.fg, bg = colors.bg }
    -- highlights.Comment = { fg = colors.comment, italic = true }
  end,
})

vim.cmd.colorscheme("chalk")
```

### Package Manager Examples

#### Using lazy.nvim (Recommended)

```lua
{
  "your-username/chalk.nvim", 
  priority = 1000,
  config = function()
    require("chalk").setup({
      variant = "default",
      transparent = false,
      styles = {
        comments = { italic = true },
        keywords = { bold = true },
      },
      on_colors = function(colors)
        colors.comment = "#8a9199" -- Custom comment color
      end,
    })
    vim.cmd.colorscheme("chalk")
  end,
}
```

#### Manual Setup

```lua
require("chalk").setup({
  variant = "oled", -- for OLED displays
  transparent = true,
})
vim.cmd.colorscheme("chalk")
```

#### Useful Keymaps

```lua
-- Toggle between light and dark variants
vim.keymap.set("n", "<leader>tt", function() 
  require("chalk").toggle() 
end, { desc = "Toggle theme variant" })

-- Preview different variants without applying
vim.keymap.set("n", "<leader>tp", function()
  local colors = require("chalk").preview("light")
  print(vim.inspect(colors))
end, { desc = "Preview light variant" })
```

## Variants

### Default
Earth-toned palette with sophisticated jewel accents, perfect for extended coding sessions.

### Light
Optimized light theme with proper contrast ratios and reduced eye strain.

### OLED
Deep blacks and vibrant colors designed specifically for OLED displays.

## Dynamic Color Adjustment

Chalk.nvim includes a powerful dynamic color adjustment system:

### Commands

| Command | Description |
|---------|-------------|
| `:ChalkDynamicIncreaseBrightness` | Brighten highlight under cursor |
| `:ChalkDynamicDecreaseBrightness` | Darken highlight under cursor |
| `:ChalkDynamicNextColor` | Cycle to next color |
| `:ChalkDynamicPrevColor` | Cycle to previous color |
| `:ChalkDynamicWarmColor` | Apply warm color family |
| `:ChalkDynamicCoolColor` | Apply cool color family |
| `:ChalkDynamicReset` | Reset all colors |
| `:ChalkDynamicInspect` | Inspect group under cursor |

### Default Keymaps (when `dynamic_keymaps = true`)

```lua
-- Default prefix: <leader>c
<leader>c+ -- Increase brightness
<leader>c- -- Decrease brightness
<leader>cn -- Next color
<leader>cp -- Previous color
<leader>cw -- Warm color
<leader>cc -- Cool color
<leader>cr -- Reset colors
<leader>ci -- Inspect group
```

## Supported Plugins

Chalk.nvim automatically detects and provides custom highlights for:

- **Syntax**: TreeSitter, LSP semantic tokens
- **Navigation**: Telescope, Neo-tree, NvimTree
- **Completion**: nvim-cmp, LuaSnip
- **Git**: Gitsigns, Fugitive, DiffView
- **UI**: Bufferline, Lualine, Which-key, Noice
- **Utilities**: Dashboard, Alpha, Notify, Mini.nvim
- **And many more...**

## API Reference

### Core Functions

```lua
-- Setup and configuration
require("chalk").setup(opts)

-- Load colorscheme
require("chalk").load(opts)

-- Get color palette
local colors = require("chalk").get_colors("default")

-- Toggle between variants
require("chalk").toggle()

-- Preview variant without applying
local preview_colors = require("chalk").preview("light")

-- Access dynamic features
local dynamic = require("chalk").dynamic()
```

### Color Utilities

```lua
local util = require("chalk.util")

-- Color manipulation
local blended = util.blend("#ff0000", 0.5, "#000000")
local lighter = util.lighten("#ff0000", 0.2)
local darker = util.darken("#ff0000", 0.2)

-- Background/foreground blending
local bg_blend = util.blend_bg("#ff0000", 0.1)
local fg_blend = util.blend_fg("#ff0000", 0.1)
```

## Color Palette

The chalk.nvim color system is built around perceptually uniform color families:

### Earth Tones
- **Emerald**: Sophisticated sage greens (5 shades)
- **Lime**: Bright vibrant greens (5 shades)  
- **Turquoise**: Vibrant blue-greens (5 shades)

### Jewel Accents
- **Cyan**: Bright blue-cyan tones (5 shades)
- **Seafoam**: Soft green-blue tones (5 shades)
- **Violet**: Soft purple elegance (5 shades)

Each family provides harmonious gradients from light to dark, ensuring consistent visual hierarchy.

## Customization Examples

### Custom Comment Color
```lua
require("chalk").setup({
  on_colors = function(colors)
    colors.comment = "#7c8f8f"
  end,
})
```

### Custom Cursor Line
```lua
require("chalk").setup({
  on_highlights = function(highlights, colors)
    highlights.CursorLine = { 
      bg = colors.bg_2, 
      blend = 10 
    }
  end,
})
```

### Transparent Background
```lua
require("chalk").setup({
  transparent = true,
  on_highlights = function(highlights, colors)
    highlights.Normal = { fg = colors.fg, bg = "NONE" }
    highlights.NormalFloat = { fg = colors.fg, bg = "NONE" }
  end,
})
```

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Development Setup

1. Clone the repository
2. Create a symbolic link to your Neovim config
3. Test changes with different variants and plugins

### Adding Plugin Support

1. Create a new file in `lua/chalk/groups/plugins/`
2. Follow the existing plugin patterns
3. Add plugin detection in `lua/chalk/config.lua`

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [Tokyo Night](https://github.com/folke/tokyonight.nvim) architecture
- Color theory based on perceptual uniformity principles
- Community feedback and contributions

## Documentation

- [Architecture Guide](ARCHITECTURE.md) - Detailed technical documentation
- [Type Definitions](lua/chalk/types.lua) - TypeScript-like type safety
- Complete configuration examples are included above in the [Configuration](#configuration) section

---

<div align="center">

**[Back to Top](#chalknvim)**

Made with love for the Neovim community

</div>
