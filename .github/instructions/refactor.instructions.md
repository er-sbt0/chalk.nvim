---
applyTo: '**'
---
# Chalk.nvim Refactoring Instructions

**Date**: 29 October 2025  
**Version**: Pre-refactor baseline  
**Objective**: Clean up dead code, improve structure, and enhance maintainability

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Phase 1: Investigation & Verification](#phase-1-investigation--verification)
3. [Phase 2: Critical Cleanups](#phase-2-critical-cleanups)
4. [Phase 3: Structural Improvements](#phase-3-structural-improvements)
5. [Phase 4: Code Quality](#phase-4-code-quality)
6. [Testing Checklist](#testing-checklist)
7. [Rollback Plan](#rollback-plan)

---

## Overview

### Issues Found
- **~24 language-specific files** potentially unused
- **Redundant entry point** files
- **Inconsistent patterns** across modules
- **~25-30% code reduction** potential

### Goals
- ✅ Remove dead code
- ✅ Improve maintainability
- ✅ Standardize patterns
- ✅ Maintain backward compatibility (where reasonable)

---

## Phase 1: Investigation & Verification

### Task 1.1: Verify Language Modules Usage

**File**: `lua/chalk/groups/treesitter.lua`

**Investigation**:
```lua
-- Line 7: Module is imported
local languages = require("chalk.groups.languages")

-- Search for: languages.load_all() or languages.load_language()
-- Expected: Should be called somewhere in setup() function
```

**Action**:
- [ ] Search entire codebase for `languages.load_all`
- [ ] Search entire codebase for `languages.load_language`
- [ ] Determine if language modules are:
  - ❌ Dead code (never used) → Mark for deletion
  - ⚠️ Incomplete feature → Document as TODO
  - ✅ Used indirectly → Keep and document

**Command**:
```bash
cd /home/eransa/code/chalk.nvim
grep -r "languages\.load" lua/
grep -r "load_all" lua/
grep -r "load_language" lua/
```

---

### Task 1.2: Verify Noice Plugin Integration

**Files**: 
- `lua/chalk/groups/plugins/noice.lua` (236 lines)
- `lua/chalk/config.lua` (line 96)

**Investigation**:
```lua
-- Config maps it:
["noice.nvim"] = "noice",

-- But is it loaded in groups/init.lua?
-- Check if M.has_group("noice") returns true
```

**Action**:
- [ ] Check if noice appears in enabled plugins list
- [ ] Verify `M.get_group("noice")` can find the module
- [ ] Test with noice.nvim installed
- [ ] Decision:
  - Keep if working
  - Remove if broken/unused

**Test**:
```lua
-- In Neovim with chalk loaded:
:lua vim.print(require("chalk.config").get_enabled_plugins())
:lua vim.print(require("chalk.groups").has_group("noice"))
```

---

### Task 1.3: Verify Cache System

**File**: `lua/chalk/util.lua:231`

**Investigation**:
```lua
function M.cache.clear()
  -- Clears dynamic color system cache
  -- Clears module cache
  -- But is there an actual cache implementation?
end
```

**Action**:
- [ ] Search for cache writes/reads
- [ ] Check if `opts.cache = true` does anything
- [ ] Determine if cache is:
  - Planned feature → Document
  - Partially implemented → Complete or remove
  - Unused → Remove function

---

## Phase 2: Critical Cleanups

### Task 2.1: Remove Language Modules (If Dead Code)

**Condition**: Only if Task 1.1 confirms they're unused

**Files to Delete**:
```
lua/chalk/groups/languages/
├── bash.lua
├── c.lua
├── cpp.lua
├── css.lua
├── diff.lua
├── dockerfile.lua
├── gitcommit.lua
├── go.lua
├── html.lua
├── init.lua
├── java.lua
├── javascript.lua
├── json.lua
├── lua.lua
├── markdown.lua
├── php.lua
├── python.lua
├── README.md
├── ruby.lua
├── rust.lua
├── sql.lua
├── toml.lua
├── typescript.lua
├── vim.lua
├── xml.lua
└── yaml.lua
```

**Steps**:
1. [ ] Create backup branch: `git checkout -b refactor/remove-language-modules`
2. [ ] Remove import from treesitter.lua:
```lua
-- REMOVE THIS LINE:
local languages = require("chalk.groups.languages")
```
3. [ ] Delete entire directory: `rm -rf lua/chalk/groups/languages/`
4. [ ] Test colorscheme loads without errors
5. [ ] Commit: `git commit -m "refactor: remove unused language-specific modules"`

**Alternative** (If keeping):
- [ ] Document why they exist
- [ ] Add integration code to actually use them
- [ ] Update treesitter.lua to call `languages.load_all(colors, opts)`

---

### Task 2.2: Simplify Entry Point

**Current Structure**:
```
lua/chalk.lua           → return require("chalk.init")
lua/chalk/init.lua      → Actual implementation
colors/chalk.lua        → require("chalk").load()
```

**Option A: Remove lua/chalk.lua** (Recommended)
```bash
# Users would require("chalk") which finds chalk/init.lua automatically
rm lua/chalk.lua
```

**Option B: Remove lua/chalk/init.lua**
```bash
# Keep chalk.lua as single entry point
mv lua/chalk/init.lua lua/chalk.lua
# Then update internal requires
```

**Recommendation**: Choose **Option A**
- More conventional for Neovim plugins
- `require("chalk")` automatically finds `chalk/init.lua`
- Simpler structure

**Steps**:
1. [ ] Delete `lua/chalk.lua`
2. [ ] Test: `require("chalk")` still works
3. [ ] Update documentation if needed
4. [ ] Commit: `git commit -m "refactor: remove redundant entry point"`

---

### Task 2.3: Handle Noice Plugin

**Based on Task 1.2 findings**:

**If Unused**:
```bash
rm lua/chalk/groups/plugins/noice.lua
```

**Update config.lua**:
```lua
-- REMOVE these lines (around line 96):
["noice.nvim"] = "noice",
```

**If Used but Broken**:
- [ ] Fix the integration
- [ ] Add to documented supported plugins list
- [ ] Test with noice.nvim

---

## Phase 3: Structural Improvements

### Task 3.1: Fix Print Statements

**File**: `lua/chalk/dynamic/dynamic.lua`

**Lines 369-375**:
```lua
-- BEFORE:
function M.show_overrides()
	local overrides = M.load_overrides()
	print("Active Color Overrides:")
	print(string.rep("-", 50))
	for group, color in pairs(overrides) do
		print(string.format("%-25s %s", group, color))
	end
	print(string.rep("-", 50))
	print(string.format("Total: %d overrides", vim.tbl_count(overrides)))
end

-- AFTER:
function M.show_overrides()
	local overrides = M.load_overrides()
	local lines = {
		"Active Color Overrides:",
		string.rep("-", 50),
	}
	
	for group, color in pairs(overrides) do
		table.insert(lines, string.format("%-25s %s", group, color))
	end
	
	table.insert(lines, string.rep("-", 50))
	table.insert(lines, string.format("Total: %d overrides", vim.tbl_count(overrides)))
	
	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end
```

**Steps**:
1. [ ] Replace print() calls with vim.notify()
2. [ ] Format multi-line output properly
3. [ ] Test `:ChalkShow` command
4. [ ] Commit: `git commit -m "refactor: replace print with vim.notify in dynamic module"`

---

### Task 3.2: Fix Duplicate Comment

**File**: `lua/chalk/colors/default.lua`

**Lines 8-9**:
```lua
-- BEFORE:
	-- === EMERALD FAMILY (Sophisticated sage greens) - Nature harmony ===
	-- === EMERALD FAMILY (Sophisticated sage greens) - Nature harmony ===
	emerald_1 = "#b7d0ae",

-- AFTER:
	-- === EMERALD FAMILY (Sophisticated sage greens) - Nature harmony ===
	emerald_1 = "#b7d0ae",
```

**Steps**:
1. [ ] Remove duplicate line
2. [ ] Check for other duplicates: `grep -n "===" lua/chalk/colors/default.lua | uniq -d`
3. [ ] Commit: `git commit -m "fix: remove duplicate color comment"`

---

### Task 3.3: Centralize Transparency Logic

**Current State**: Transparency handled in 3 places:
1. `lua/chalk/colors/init.lua:24-28` - Palette processing
2. `lua/chalk/groups/init.lua:118-181` - Highlight application
3. Individual plugin files

**Refactor Plan**:

Create new utility function:
```lua
-- lua/chalk/util.lua
---Apply transparency to a highlight definition
---@param hl table Highlight definition
---@return table Modified highlight
function M.make_transparent(hl)
	if type(hl) == "table" then
		hl.bg = "NONE"
		hl.ctermbg = "NONE"
	end
	return hl
end

---Apply transparency to multiple highlight groups
---@param highlights table Highlight groups
---@param group_names string[] Groups to make transparent
---@param colors table Color scheme (for accessing colors.none)
---@return table Modified highlights
function M.apply_transparency(highlights, group_names, colors)
	for _, group in ipairs(group_names) do
		if highlights[group] then
			highlights[group] = M.make_transparent(highlights[group])
		end
	end
	return highlights
end
```

**Steps**:
1. [ ] Add utility functions to `util.lua`
2. [ ] Update `groups/init.lua` to use utility
3. [ ] Update individual plugin files
4. [ ] Test with `transparent = true` config
5. [ ] Commit: `git commit -m "refactor: centralize transparency logic"`

---

### Task 3.4: Optimize has_group Implementation

**File**: `lua/chalk/groups/init.lua`

**Current** (lines 196-198):
```lua
function M.has_group(name)
	return M.get_group(name) ~= nil
end
```

**Problem**: Loads module just to check existence

**Better Approach**:
```lua
-- At top of file, define available groups
M.available_groups = {
	-- Base groups (always available)
	base = true,
	treesitter = true,
	
	-- Plugin groups (with files)
	telescope = true,
	nvim_cmp = true,
	gitsigns = true,
	which_key = true,
	bufferline = true,
	treesitter_context = true,
	nvim_tree = true,
	-- noice = true, -- Only if keeping noice
}

---Check if a group module exists
---@param name string Group name to check
---@return boolean Whether the group exists
function M.has_group(name)
	-- Fast path: check known groups first
	if M.available_groups[name] ~= nil then
		return M.available_groups[name]
	end
	
	-- Fallback: try to load (for dynamic/future groups)
	return M.get_group(name) ~= nil
end
```

**Steps**:
1. [ ] Add `M.available_groups` table
2. [ ] Update `has_group()` function
3. [ ] Test plugin detection still works
4. [ ] Commit: `git commit -m "perf: optimize has_group with lookup table"`

---

## Phase 4: Code Quality

### Task 4.1: Standardize Error Handling

**Pattern to Use**:
```lua
-- For user-facing operations (setup, load, etc.)
local ok, result = pcall(some_function)
if not ok then
	vim.notify("chalk.nvim: " .. result, vim.log.levels.ERROR)
	return nil
end

-- For optional features (plugins, etc.)
local ok, result = pcall(require, module_name)
if not ok then
	-- Silent failure, return nil
	return nil
end

-- For critical operations (should never fail)
-- No pcall, let it error naturally for debugging
```

**Files to Update**:
- `lua/chalk/util.lua:96-103` (M.mod function)
- `lua/chalk/config.lua` (plugin detection)
- `lua/chalk/groups/init.lua` (group loading)

**Steps**:
1. [ ] Audit all pcall usage
2. [ ] Categorize: user-facing vs optional vs critical
3. [ ] Apply appropriate pattern
4. [ ] Commit: `git commit -m "refactor: standardize error handling patterns"`

---

### Task 4.2: Document Deprecation Timeline

**File**: `lua/chalk/config.lua`

**Current** (lines 182-196):
```lua
	-- Handle legacy configuration format
	if opts.integrations and not opts.plugins then
		vim.notify("chalk.nvim: 'integrations' is deprecated, use 'plugins' instead", vim.log.levels.WARN)
		opts.plugins = opts.integrations
	end
```

**Add Deprecation Timeline**:
```lua
	-- Handle legacy configuration format
	-- DEPRECATED: Will be removed in v2.0.0 (target: Q2 2026)
	if opts.integrations and not opts.plugins then
		vim.notify(
			"chalk.nvim: 'integrations' is deprecated and will be removed in v2.0.0. Use 'plugins' instead",
			vim.log.levels.WARN
		)
		opts.plugins = opts.integrations
	end

	-- DEPRECATED: Will be removed in v2.0.0 (target: Q2 2026)
	if opts.custom_highlights and not opts.on_highlights then
		vim.notify(
			"chalk.nvim: 'custom_highlights' is deprecated and will be removed in v2.0.0. Use 'on_highlights' instead",
			vim.log.levels.WARN
		)
		-- ... rest of code
	end
```

**Steps**:
1. [ ] Add version numbers to deprecation notices
2. [ ] Update README with migration guide
3. [ ] Create CHANGELOG.md if not exists
4. [ ] Commit: `git commit -m "docs: add deprecation timeline for legacy config"`

---

### Task 4.3: Simplify Dynamic Module API

**File**: `lua/chalk/dynamic/init.lua`

**Current** (inconsistent):
```lua
-- Some functions are delegators:
M.adjust_brightness = function(...)
	return M.colors().adjust_brightness(...)
end

-- Others are accessors:
function M.colors()
	return require("chalk.dynamic.colors")
end
```

**Choose One Pattern**:

**Option A: Pure Submodule Access** (Cleaner)
```lua
local M = {}

---Access to enhanced color utilities
---@return table Colors module
function M.colors()
	return require("chalk.dynamic.colors")
end

---Access to dynamic color adjustment system
---@return table Dynamic module
function M.dynamic()
	return require("chalk.dynamic.dynamic")
end

-- Remove all delegator functions
-- Users call: require("chalk.dynamic").colors().adjust_brightness(...)
```

**Option B: Full Re-export** (More convenient)
```lua
local M = {}
local colors = require("chalk.dynamic.colors")
local dynamic = require("chalk.dynamic.dynamic")

-- Re-export everything at top level
M.adjust_brightness = colors.adjust_brightness
M.shift_hue = colors.shift_hue
-- ... etc for all functions

-- Don't expose submodules
```

**Recommendation**: **Option A** - clearer API boundaries

**Steps**:
1. [ ] Choose pattern
2. [ ] Update module
3. [ ] Update any callers
4. [ ] Update documentation
5. [ ] Commit: `git commit -m "refactor: simplify dynamic module API"`

---

## Testing Checklist

After each phase, verify:

### Basic Functionality
- [ ] `:colorscheme chalk` loads without errors
- [ ] Syntax highlighting works (open test files)
- [ ] `:ChalkToggle` or theme functions work
- [ ] No error messages in `:messages`

### Plugin Integration
- [ ] Telescope highlights apply
- [ ] nvim-cmp highlights apply  
- [ ] Gitsigns highlights apply
- [ ] Which-key highlights apply
- [ ] Bufferline highlights apply
- [ ] TreeSitter context highlights apply
- [ ] nvim-tree highlights apply

### Configuration
- [ ] `require("chalk").setup({})` works
- [ ] Variant switching works (default, light, oled)
- [ ] Transparency mode works
- [ ] Terminal colors apply
- [ ] Custom on_colors callback works
- [ ] Custom on_highlights callback works

### Dynamic Features
- [ ] `:ChalkIncreaseBrightness` works
- [ ] `:ChalkReset` works
- [ ] `:ChalkShow` displays correctly (after print fix)
- [ ] Color overrides persist

### Edge Cases
- [ ] Loading with no config
- [ ] Loading with partial config
- [ ] Switching variants multiple times
- [ ] Reload after changes

---

## Rollback Plan

### Git Workflow
```bash
# Before starting
git checkout -b refactor/cleanup
git tag pre-refactor

# If issues occur
git checkout main
git branch -D refactor/cleanup

# If you need to cherry-pick specific commits
git cherry-pick <commit-hash>
```

### Backup Critical Files
```bash
# Before major changes
mkdir -p backups/$(date +%Y%m%d)
cp lua/chalk/groups/init.lua backups/$(date +%Y%m%d)/
cp lua/chalk/config.lua backups/$(date +%Y%m%d)/
cp lua/chalk/theme.lua backups/$(date +%Y%m%d)/
```

---

## Commit Message Guidelines

Use conventional commits:

- `feat:` - New features
- `fix:` - Bug fixes
- `refactor:` - Code refactoring (no behavior change)
- `perf:` - Performance improvements
- `docs:` - Documentation only
- `style:` - Code style (formatting, etc.)
- `test:` - Adding tests
- `chore:` - Maintenance tasks

Examples:
```bash
git commit -m "refactor: remove unused language-specific modules"
git commit -m "fix: replace print with vim.notify in dynamic module"
git commit -m "perf: optimize has_group with lookup table"
git commit -m "docs: add deprecation timeline for legacy config"
```

---

## Success Criteria

Refactoring is complete when:

- [ ] All dead code removed or justified
- [ ] All tests passing
- [ ] No new errors in `:messages`
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] README.md updated (if needed)
- [ ] Code coverage maintained
- [ ] Performance not degraded
- [ ] All supported plugins still work

---

## Notes & Decisions

### Investigation Results (Fill in during Phase 1)

**Language Modules**:
- Status: [ ] Dead code / [ ] Incomplete / [ ] Working
- Decision: [ ] Remove / [ ] Keep / [ ] Fix
- Notes: 

**Noice Plugin**:
- Status: [ ] Working / [ ] Broken / [ ] Unused
- Decision: [ ] Keep / [ ] Remove / [ ] Fix
- Notes:

**Cache System**:
- Status: [ ] Implemented / [ ] Partial / [ ] Placeholder
- Decision: [ ] Complete / [ ] Remove / [ ] Document
- Notes:

---

## Questions for Maintainer

Before starting refactor, confirm:

1. **Language modules**: Were these intended for a specific feature? Can they be removed?
2. **Noice support**: Is this actively used? Should we keep it?
3. **API breaking changes**: Is a v2.0 acceptable for removing deprecations?
4. **Timeline**: Any deadline for this refactor?
5. **Backwards compatibility**: How important is it to maintain old APIs?

---

## Additional Resources

- [Neovim Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [LuaCATS Annotations](https://luals.github.io/wiki/annotations/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

**Last Updated**: 29 October 2025  
**Maintainer**: @lomes0  
**Review By**: Senior Lua/Neovim Developer
