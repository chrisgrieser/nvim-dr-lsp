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
	local params = lsp.util.make_position_params(0) ---@diagnostic disable-line: missing-parameter
	params.context = { includeDeclaration = false }
	local thisFileUri = vim.uri_from_fname(fn.expand("%:p")) -- identifier in LSP response

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

---shows the number of definitions/references as identified by LSP. Shows count
---for the current file and for the whole workspace.
---@return string statusline text
---@nodiscard
function M.lspCount()
	-- abort when lsp loading or not capable of references
	local currentBufNr = fn.bufnr()
	local bufClients = lsp.get_active_clients { bufnr = currentBufNr }
	local lspProgress = lsp.util.get_progress_messages()
	local lspLoading = lspProgress.title and lspProgress.title:find("[Ll]oad")
	local lspCapable = false
	for _, client in pairs(bufClients) do
		local capable = client.server_capabilities
		if capable.referencesProvider and capable.definitionProvider then lspCapable = true end
	end
	if vim.api.nvim_get_mode().mode ~= "n" or lspLoading or not lspCapable then return "" end

	-- trigger count, abort when none
	requestLspRefCount() -- needs to be separated due to lsp calls being async
	if lspCount.refWorkspace == 0 and lspCount.defWorkspace == 0 then return "" end
	if not lspCount.refWorkspace then return "" end

	-- format lsp references/definitions count to be displayed in the status bar
	local defs, refs = "", ""
	if lspCount.defWorkspace then
		defs = tostring(lspCount.defFile)
		if lspCount.defFile ~= lspCount.defWorkspace then
			defs = defs .. "(" .. tostring(lspCount.defWorkspace) .. ")"
		end
		defs = defs .. "D"
	end
	if lspCount.refWorkspace then
		refs = tostring(lspCount.refFile)
		if lspCount.refFile ~= lspCount.refWorkspace then
			refs = refs .. "(" .. tostring(lspCount.refWorkspace) .. ")"
		end
		refs = refs .. "R"
	end
	return "LSP: " .. defs .. " " .. refs
end

-- Simple alternative to fidget.nvim, ignoring null-ls
-- based on snippet from u/folke https://www.reddit.com/r/neovim/comments/o4bguk/comment/h2kcjxa/
function M.lspProgress()
	local messages = (vim.version().minor > 9 and vim.version().major == 0) and vim.lsp.util.get_progress_messages() or vim.lsp.status()
	if #messages == 0 then return "" end
	local client = messages[1].name and messages[1].name .. ": " or ""
	if client:find("null%-ls") then return "" end
	local progress = messages[1].percentage or 0
	local task = messages[1].title or ""
	task = task:gsub("^(%w+).*", "%1") -- only first word

	local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
	local ms = vim.loop.hrtime() / 1000000
	local frame = math.floor(ms / 120) % #spinners
	return spinners[frame + 1] .. " " .. client .. progress .. "%% " .. task
end

--------------------------------------------------------------------------------

return M
