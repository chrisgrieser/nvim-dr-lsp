local version = vim.version()
if version.major == 0 and version.minor < 10 then
	vim.notify("nvim-dr-lsp requires at least nvim 0.10.", vim.log.levels.WARN)
	return
end
--------------------------------------------------------------------------------

local M = {}

---@return string statusline-text
---@nodiscard
function M.lspCount() return require("dr-lsp.statusline").lspCountFormatted() end

---@return LspCountResults?
---@nodiscard
function M.lspCountTable() return require("dr-lsp.statusline").lspCountTable() end

return M
