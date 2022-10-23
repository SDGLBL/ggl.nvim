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

### Usage
- `GLineLink {line_num}` generate line link 
- `GPermaLink {line_num}` generate permaline link
