local M = {}
--------------------------------------------------------------------------------

---@class LspCountResults
local nullCount = {
	file = {
		definitions = 0,
		references = 0,
	},
	workspace = {
		definitions = 0,
		references = 0,
	},
}
local lspCount = nullCount

--------------------------------------------------------------------------------

---calculate number of references for entity under cursor asynchronously
---@async
local function requestLspRefCount()
	if vim.fn.mode() ~= "n" then
		lspCount = vim.deepcopy(nullCount)
		return
	end
	local params = vim.lsp.util.make_position_params(0)
	params.context = { includeDeclaration = false }
	local thisFileUri = vim.uri_from_fname(vim.api.nvim_buf_get_name(0))

	vim.lsp.buf_request(0, "textDocument/references", params, function(error, refs)
		lspCount.file.references = 0
		lspCount.workspace.references = 0
		if not error and refs then
			lspCount.workspace.references = #refs
			for _, ref in pairs(refs) do
				if thisFileUri == ref.uri then
					lspCount.file.references = lspCount.file.references + 1
				end
			end
		end
	end)
	vim.lsp.buf_request(0, "textDocument/definition", params, function(error, defs)
		lspCount.file.definitions = 0
		lspCount.workspace.definitions = 0
		if not error and defs then
			lspCount.workspace.definitions = #defs
			for _, def in pairs(defs) do
				if thisFileUri == def.targetUri then
					lspCount.file.definitions = lspCount.file.definitions + 1
				end
			end
		end
	end)
end

---Returns the number of definitions/references as identified by LSP as table
---for the current file and for the whole workspace.
---@return LspCountResults?
---@nodiscard
function M.lspCountTable()
	-- GUARD
	local lspCapable = false
	for _, client in pairs(vim.lsp.get_clients { bufnr = 0 }) do
		local capable = client.server_capabilities or {}
		if capable.referencesProvider and capable.definitionProvider then lspCapable = true end
	end
	if vim.fn.mode() ~= "n" or not lspCapable then return end

	-- trigger count, needs to be separated due to lsp calls being async
	requestLspRefCount()

	if lspCount.workspace.definitions == 0 and lspCount.workspace.references == 0 then return end
	return lspCount
end

---Shows the number of definitions/references as identified by LSP. Shows count
---for the current file and for the whole workspace.
---@return string statusline-text
---@nodiscard
function M.lspCountFormatted()
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
	return ("LSP: %s %s"):format(defs, refs)
end

--------------------------------------------------------------------------------
return M
