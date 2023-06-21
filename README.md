<!-- LTeX: enabled=false --><!-- vale off -->
# nvim-dr-lsp

Lightweight status line component showing the number of LSP `D`efinitions and `R`eferences of the token under the cursor. A second component shows loading progress.

![Showcase](https://github.com/chrisgrieser/nvim-dr-lsp/assets/73286100/8c6600c8-b16d-434f-8bdb-47b4a9dab7cb)

## Table of Contents
<!--toc:start-->
- [Table of Contents](#table-of-contents)
- [Components](#components)
	- [`lspCount`](#lspcount)
	- [`lspProgress`](#lspprogress)
- [Installation](#installation)
- [Formatting the components](#formatting-the-components)
- [Similar Plugins](#similar-plugins)
- [Credits](#credits)
<!--toc:end-->
<!-- LTeX: enabled=true --><!-- vale on -->

## Components

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
- Ignores `null-ls`
- Shows LSP activity spinner, similar to [fidget.nvim](https://github.com/j-hui/fidget.nvim), but less obtrusive.

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

## Formatting the components
There are no builtin options to format the components, since formatting can already be done with most statusline plugins. With lualine, for example, you can use the [`fmt` component option](https://github.com/nvim-lualine/lualine.nvim#global-options):

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
- [LSP-Lens](https://github.com/VidocqH/lsp-lens.nvim): Also shows definition & reference counts but as virtual lines.
- [Fidget.nvim](https://github.com/j-hui/fidget.nvim): Also shows LSP progress,
  more customizable but above the status line.

## Credits
<!-- LTeX: enabled=false --><!-- vale off -->
Basic for the progress component from [folke](https://www.reddit.com/r/neovim/comments/o4bguk/comment/h2kcjxa/).
<!-- LTeX: enabled=true --><!-- vale on -->
<!-- vale Google.FirstPerson = NO -->
__About Me__  
In my day job, I am a sociologist studying the social mechanisms underlying the digital economy. For my PhD project, I investigate the governance of the app economy and how software ecosystems manage the tension between innovation and compatibility. If you are interested in this subject, feel free to get in touch.

__Profiles__  
- [reddit](https://www.reddit.com/user/pseudometapseudo)
- [Discord](https://discordapp.com/users/462774483044794368/)
- [Academic Website](https://chris-grieser.de/)
- [Twitter](https://twitter.com/pseudo_meta)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

__Buy Me a Coffee__  
<br>
<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
