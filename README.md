<!-- LTeX: enabled=false -->
# nvim-dr-lsp 👨‍⚕️👩‍⚕️
<!-- LTeX: enabled=true -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-dr-lsp">
<img alt="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-dr-lsp/shield"/></a>

`D`efinitions and `R`eferences utility for the LSP. <!--codespell-ignore-->

Lightweight plugin that highlights definitions and references of the word under
the cursor and displays their count in the statusline.

![Showcase](https://github.com/chrisgrieser/nvim-dr-lsp/assets/73286100/8c6600c8-b16d-434f-8bdb-47b4a9dab7cb)

<!-- toc -->

- [Statusline Components](#statusline-components)
	* [`lspCount`](#lspcount)
	* [`lspProgress`](#lspprogress)
- [API: `lspCountTable`](#api-lspcounttable)
- [Installation](#installation)
- [Highlights of definition and references](#highlights-of-definition-and-references)
- [Customizing the components](#customizing-the-components)
- [Similar Plugins](#similar-plugins)
- [Credits](#credits)

<!-- tocstop -->

## Statusline Components

### `lspCount`
__Definitions and references inside current buffer__

```text
LSP: 2D 6R
```

__Definitions or references outside current buffer__

```text
LSP: 1(2)D 4(10)R
```

- 1 definition in the current buffer
- 2 definitions in the workspace
- 4 references in the current buffer
- 10 definitions in the workspace

### `lspProgress`
- LSP activity spinner, similar to
  [fidget.nvim](https://github.com/j-hui/fidget.nvim), but less obtrusive.
- Ignores `null-ls` and `none-ls`.

## API: `lspCountTable`
Returns the `lspCount` information as Lua table for custom formatting.

```lua
{
	file = {
		definitions = 1,
		references = 4,
	},
	workspace = {
		definitions = 2,
		references = 10,
	},
}
```

## Installation

```lua
-- lazy.nvim
{ "chrisgrieser/nvim-dr-lsp" },

-- packer
use { "chrisgrieser/nvim-dr-lsp" }
```

```lua
-- adding the components to lualine.nvim
{
	sections = {
		lualine_c = {
			{ require("dr-lsp").lspCount },
			{ require("dr-lsp").lspProgress },
		},
	}
}
```

There is no `.setup` call for this plugin. Just add the components to your
statusline.

## Highlights of definition and references
- Definitions are under-dashed, references are under-dotted.
- These are set up automatically for you as soon as the buffer is attached to an
  LSP client.
- To disable the highlights feature, set `vim.g.dr_lsp_no_highlight = true`
  before loading the plugin.

## Customizing the components
There are no built-in options to format the components, since formatting can
already be done with most statusline plugins. With Lualine, for example, you can
use the [`fmt` option](https://github.com/nvim-lualine/lualine.nvim#global-options):

```lua
lualine_c = {
	{ 
		require("dr-lsp").lspCount, 
		-- remove the letters from the component
		fmt = function(str) return str:gsub("[RD]", "") end,
	},
},
```

## Similar Plugins
- [LSP-Lens](https://github.com/VidocqH/lsp-lens.nvim)
- [Fidget.nvim](https://github.com/j-hui/fidget.nvim)
- [action-hints.nvim](https://github.com/roobert/action-hints.nvim)
- [symbol-usage.nvim](https://github.com/Wansmer/symbol-usage.nvim)

## Credits
<!-- LTeX: enabled=false -->
The basic idea for the progress component came from [folke](https://www.reddit.com/r/neovim/comments/o4bguk/comment/h2kcjxa/).
<!-- LTeX: enabled=true -->
<!-- vale Google.FirstPerson = NO -->
__About Me__  
In my day job, I am a sociologist studying the social mechanisms underlying the
digital economy. For my PhD project, I investigate the governance of the app
economy and how software ecosystems manage the tension between innovation and
compatibility. If you are interested in this subject, feel free to get in touch.

__Profiles__  
- [reddit](https://www.reddit.com/user/pseudometapseudo)
- [Discord](https://discordapp.com/users/462774483044794368/)
- [Academic Website](https://chris-grieser.de/)
- [Twitter](https://twitter.com/pseudo_meta)
- [Mastodon](https://pkm.social/@pseudometa)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'>
<img
	height='36'
	style='border:0px;height:36px;'
	src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
	border='0'
	alt='Buy Me a Coffee at ko-fi.com'
/></a>
