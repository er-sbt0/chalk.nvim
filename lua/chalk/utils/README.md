# Chalk.nvim Utils

Simplified utility system for advanced chalk colorscheme features.

## 📁 Structure

```
utils/
├── init.lua        # Main entry point with convenient access functions
├── colors.lua      # Enhanced color manipulation (extends chalk.util)
├── dynamic.lua     # Real-time color adjustment system
├── transparency.lua # Transparency management
└── analyzer.lua    # Highlight analysis and debugging tools
```

## 🚀 Quick Start

```lua
-- Enable all utilities
require('chalk.utils').enable_all()

-- Or enable specific features
local utils = require('chalk.utils')
utils.dynamic().setup_commands()    -- Dynamic color adjustment
utils.transparency().setup_commands() -- Transparency controls
utils.analyzer().setup_commands()   -- Analysis tools

-- Quick setup with options
utils.quick_setup({
  enable_dynamic = true,
  enable_transparency_commands = true,
  enable_analyzer = true,
})
```

## 🎨 Dynamic Color System

Adjust colors in real-time based on TreeSitter syntax elements:

| Command | Description |
|---------|-------------|
| `:ChalkDynamicIncreaseBrightness` | Brighten color under cursor |
| `:ChalkDynamicDecreaseBrightness` | Darken color under cursor |
| `:ChalkDynamicNextColor` | Cycle to next color in wheel |
| `:ChalkDynamicWarmColor` | Apply warm color family |
| `:ChalkDynamicCoolColor` | Apply cool color family |
| `:ChalkDynamicSaturated` | Make color more saturated |
| `:ChalkDynamicMuted` | Make color more muted |
| `:ChalkDynamicReset` | Reset all colors |
| `:ChalkDynamicShow` | Show current overrides |
| `:ChalkDynamicInspect` | Inspect group under cursor |

## 🔍 Transparency

| Command | Description |
|---------|-------------|
| `:ChalkTransparencyToggle` | Toggle transparency |
| `:ChalkTransparencyEnable` / `:ChalkTransparencyDisable` | Direct control |
| `:ChalkTransparencyApply` / `:ChalkTransparencyRemove` | Override mode |

## 🔧 Analysis Tools

| Command | Description |
|---------|-------------|
| `:ChalkAnalyzeHighlights` | Show highlight statistics |
| `:ChalkListNonTransparent` | List groups with backgrounds |
| `:ChalkFindColor <hex> [bg]` | Find groups using a color |
| `:ChalkInspectGroup <name>` | Inspect specific group |

## 📚 API

```lua
local utils = require('chalk.utils')

-- Color manipulation
local colors = utils.colors()
colors.adjust_brightness("#ff0000", 20)  -- Brighter red
colors.shift_hue("#ff0000", 60)          -- Red to yellow
colors.apply_color_family("#ff0000", "cool", 1) -- Apply cool family

-- Dynamic adjustments
local dynamic = utils.dynamic()
dynamic.increase_brightness()  -- Adjust color under cursor
dynamic.change_color(1)       -- Next color in wheel

-- Transparency control
local transparency = utils.transparency()
transparency.toggle()         -- Toggle transparency
transparency.is_enabled()     -- Check status

-- Analysis
local analyzer = utils.analyzer()
analyzer.analyze_highlights()  -- Show statistics
analyzer.find_groups_with_color("#ff0000") -- Find usage
```

## 🔄 Migration from Old System

The new system consolidates the previous complex module structure:

- **Before**: 15+ files across 3 directory levels
- **After**: 5 focused files with clear responsibilities
- **API**: Fully backward compatible for main functions
- **Performance**: Faster loading, less memory usage
- **Maintenance**: Simpler structure, easier to understand

All previous functionality is preserved while eliminating redundancy and complexity.
