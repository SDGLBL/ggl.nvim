# Generate github line link

This is a simple Neovim plugin for generating a github line link in a git repo.


## Usage

![Usage](/gifs/use.gif)


## Installation
With packer.nvim
``` lua
use {
    "SDGLBL/ggl.nvim",
    config = function()
      require("ggl").setup {}
    end,
    requires = { "rcarriga/nvim-notify" },
}
```

### Configuration

``` lua
require("ggl").setup {
  -- The register to use for saving the link which generated by the plugin
  register = "+",

  -- Methods of detecting the root directory.
  -- if one is not detected, the other is used as fallback. You can also delete or rearangne the detection methods.
  detection_methods = { "pattern", "lsp" },

  -- All the patterns used to detect root dir, when **"pattern"** is in
  -- detection_methods
  patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "package.json" },

  -- Table of lsp clients to ignore by name
  -- eg: { "efm", ... }
  ignore_lsp = {},

}
```

### Usage
- `GLineLink {line_num|start} {end}` generate line link 
- `GPermaLink {line_num|start} {end}` generate permaline link
