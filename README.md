# oil-nerdfont

Integrate [oil.nvim](https://github.com/stevearc/oil.nvim) with [vim-nerdfont](https://github.com/lambdalisue/vim-nerdfont).

## Requirements

- [oil.nvim](https://github.com/stevearc/oil.nvim)
- [vim-nerdfont](https://github.com/lambdalisue/vim-nerdfont)

## Quick start

```lua
require("oil-nerdfont").setup()
```

## Options

```lua
require("oil-nerdfont").setup({
  -- setting for highlight icon
  highlight = {
    -- highlight group name for directory icon
    directory = "OilDirIcon",
    -- highlight group name for file icon
    file = nil,
  }
})
```

## License

[zlib](https://github.com/Omochice/oil-nerdfont/blob/main/LICENSE).

