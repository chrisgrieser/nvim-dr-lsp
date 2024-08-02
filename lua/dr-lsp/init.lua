local version = vim.version()
if version.major == 0 and version.minor < 10 then
	vim.notify("nvim-dr-lsp requires at least nvim 0.10.", vim.log.levels.WARN)
	return
end
--------------------------------------------------------------------------------

local M = {}

---@param userConfig? DrLspConfig
function M.setup(userConfig) require("dr-lsp.config").setup(userConfig) end

---@return string statusline-text
function M.lspCount() return require("dr-lsp.statusline").lspCountFormatted() end

---@return LspCountResults?
function M.lspCountTable() return require("dr-lsp.statusline").lspCountTable() end

return M
