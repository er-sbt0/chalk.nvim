-- Chalk colorscheme for Neovim
-- A warm, chalk-inspired theme with excellent readability

-- Enable true color support (required for this colorscheme)
vim.o.termguicolors = true

-- Clear any existing colors
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end

-- Set colorscheme name
vim.g.colors_name = "chalk"

-- Load the theme
require("chalk").load()
