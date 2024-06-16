local version = vim.version()
if version.major == 0 and version.minor < 10 then
	vim.notify("nvim-dr-lsp requires at least nvim 0.10.", vim.log.levels.WARN)
	return
end

--------------------------------------------------------------------------------

local M = {}
local lsp = vim.lsp
local fn = vim.fn
--------------------------------------------------------------------------------

local lspCount = {}

---calculate number of references for entity under cursor asynchronously
---@async
local function requestLspRefCount()
	if fn.mode() ~= "n" then
		lspCount = {}
		return
	end
	local params = lsp.util.make_position_params(0)
	params.context = { includeDeclaration = false }
	local thisFileUri = vim.uri_from_fname(vim.api.nvim_buf_get_name(0))

	lsp.buf_request(0, "textDocument/references", params, function(error, refs)
		lspCount.refFile = 0
		lspCount.refWorkspace = 0
		if not error and refs then
			lspCount.refWorkspace = #refs
			for _, ref in pairs(refs) do
				if thisFileUri == ref.uri then lspCount.refFile = lspCount.refFile + 1 end
			end
		end
	end)
	lsp.buf_request(0, "textDocument/definition", params, function(error, defs)
		lspCount.defFile = 0
		lspCount.defWorkspace = 0
		if not error and defs then
			lspCount.defWorkspace = #defs
			for _, def in pairs(defs) do
				if thisFileUri == def.targetUri then lspCount.defFile = lspCount.defFile + 1 end
			end
		end
	end)
end

---Shows the number of definitions/references as identified by LSP. Shows count
---for the current file and for the whole workspace.
---@return string statusline text
---@nodiscard
function M.lspCount()
	local count = M.lspCountTable()
	if count == nil then return "" end

	-- format lsp references/definitions count to be displayed in the status bar
	local defs, refs = "", ""
	if count.workspace.definitions then
		defs = tostring(count.file.definitions)
		if count.file.definitions ~= count.workspace.definitions then
			defs = defs .. "(" .. tostring(count.workspace.definitions) .. ")"
		end
		defs = defs .. "D"
	end
	if count.workspace.references then
		refs = tostring(count.file.references)
		if count.file.references ~= count.workspace.references then
			refs = refs .. "(" .. tostring(count.workspace.references) .. ")"
		end
		refs = refs .. "R"
	end
	return "LSP: " .. defs .. " " .. refs
end

---@class LspCountSingleResult
---@field definitions number amount of definitions
---@field references number amount of references

---@class LspCountResult
---@field file LspCountSingleResult local file result
---@field workspace LspCountSingleResult workspace result

---Returns the number of definitions/references as identified by LSP as table
---for the current file and for the whole workspace.
---@return LspCountResult? table contains the lsp count results
---@nodiscard
function M.lspCountTable()
	-- abort when lsp loading or not capable of references
	local currentBufNr = fn.bufnr()
	local bufClients = lsp.get_clients { bufnr = currentBufNr }
	local lspProgress = vim.lsp.status()
	local lspLoading = lspProgress:find("[Ll]oad")
	local lspCapable = false
	for _, client in pairs(bufClients) do
		local capable = client.server_capabilities or {}
		if capable.referencesProvider and capable.definitionProvider then lspCapable = true end
	end
	if vim.api.nvim_get_mode().mode ~= "n" or lspLoading or not lspCapable then return nil end

	-- trigger count, abort when none
	requestLspRefCount() -- needs to be separated due to lsp calls being async
	if lspCount.refWorkspace == 0 and lspCount.defWorkspace == 0 then return nil end
	if not lspCount.refWorkspace then return nil end

	return {
		file = {
			definitions = lspCount.defFile,
			references = lspCount.refFile,
		},
		workspace = {
			definitions = lspCount.defWorkspace,
			references = lspCount.refWorkspace,
		},
	}
end

--------------------------------------------------------------------------------

return M
