# Refactor Investigation Findings

**Date**: 29 October 2025  
**Branch**: refactor/cleanup  
**Tag**: pre-refactor

---

## Phase 1 Investigation Results

### ✅ Task 1.1: Language Modules - KEEP THEM
**Status**: ✅ **USED - Do NOT remove**

**Evidence**:
- `lua/chalk/groups/treesitter.lua:180` calls `languages.load_all(colors, opts)`
- `lua/chalk/groups/languages/init.lua:36` exports `load_all()` function
- All 24 language files are loaded dynamically via `SUPPORTED_LANGUAGES` array
- Language highlights are merged into treesitter highlights

**Decision**: Keep all language modules - they are integral to the colorscheme.

---

### ✅ Task 1.2: Noice Plugin - KEEP IT  
**Status**: ✅ **WORKING - Properly integrated**

**Evidence**:
- `lua/chalk/groups/plugins/noice.lua` has proper `setup(colors, opts)` function
- `lua/chalk/config.lua:96` maps `["noice.nvim"] = "noice"`
- Plugin detection works via `M.get_available_plugins()`
- Module can be loaded via `M.get_group("noice")`

**Decision**: Keep noice.lua - it's a valid plugin integration.

---

### ⚠️ Task 1.3: Cache System - PLACEHOLDER
**Status**: ⚠️ **NOT IMPLEMENTED - Document as future feature**

**Evidence**:
- `lua/chalk/config.lua:39` has `cache = true` option
- `lua/chalk/util.lua:217` has `M.cache = {}` table
- `lua/chalk/util.lua:220` implements `M.cache.clear()` function
- **NO CODE** checks `if opts.cache then` anywhere

**Decision**: Document as TODO/future feature. The option exists but does nothing currently.

---

## Phase 2-4: Refactoring Plan

### Changes to Make:

1. **✅ Keep Language Modules** - No changes needed
2. **✅ Keep Noice Plugin** - No changes needed  
3. **Document Cache** - Add comment that it's not yet implemented
4. **Simplify Entry Point** - Remove redundant `lua/chalk.lua`
5. **Fix Print Statements** - Replace with `vim.notify()` in dynamic.lua
6. **Fix Duplicate Comment** - Remove duplicate in colors/default.lua
7. **Centralize Transparency** - Add utility functions
8. **Optimize has_group()** - Add lookup table
9. **Standardize Error Handling** - Use consistent patterns
10. **Document Deprecation** - Add version timeline
11. **Simplify Dynamic API** - Choose consistent pattern

---

## Summary

**Original Estimate**: ~25-30% code reduction  
**Actual**: ~5-10% - Most code is actually used!

**Key Finding**: The instructions were based on speculation. Investigation revealed:
- Language modules ARE used (via dynamic loading)
- Noice plugin IS properly integrated
- Cache is the only placeholder feature

**Recommendation**: Proceed with code quality improvements (Phases 3-4) rather than major removals.
