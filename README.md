## dotnvim

Extend your neovim configuration on a per-project basis.

### What is it?
dotnvim allows you to create project specific neovim configurations so you don't have to pile on configurations you only need in specific circumstances. When you open neovim and the plugin is loaded it will source your configuration files.

### How do I use it?
Add the plugin. Here's an example for packer using the defaults:
```lua
use { 
  "Steven0351/dotnvim",
  requires = "nvim-lua/plenary.nvim",
  config = function()
    require("dotnvim").setup {}
  end
}
```

Currently the default options are 
```lua
{
  project_configs_parent_dir = "~/.config/dotnvim"
}
```

There are two primary ways to use it

#### In the project itself
Create a `.nvim` file with your configurations. For example:
```lua
-- .nvim 
local lspconfig = require("lspconfig")
lspconfig.sumneko_lua.setup {}
```

If you need something a bit more complex, you can create a lua module inside of an `.nvim` directory:
```bash
.nvim
└── lua
    └── yourmodule
        ├── init.lua
        └── other.lua
```
If you have more than one module directory under `.nvim/lua`, you will need to disambiguate the lua module by creating a `module_name` file at the root of the `.nvim` directory containing the name of the module you want to load:

```bash
.nvim
├── module_name
└── lua
    ├── module_one
    │   └── init.lua
    └── module_two
        └── init.lua
```

```bash
$ cat .nvim/module_name
module_one
```
#### In a config directory
In your `project_configs_parent_dir`, create a folder that matches the folder name of the project you want to source configurations for. For example, if I had a project at `~/Projects/web/my-cool-spa`, you would create a folder in `~/.config/dotnvim/my-cool-spa` (assuming you leave the default configuration directory).

Once you've created your project specific directory, you can either put your configuration in a `init.lua` file in the root of that directory, or create a lua module at `lua/yourmodule`:
```bash
project_configuration_parent_dir
└── project_name
    └── init.lua
```
or
```bash
project_configuration_parent_dir
└── project_name
    └── lua
        └── yourmodule
            ├── init.lua
            └── other.lua
```

If you have more than one module directory under `.nvim/lua`, you will need to disambiguate the lua module by creating a `module_name` file at the root of the `project_name` directory.

### Security
This plugin loads arbitrary code to be executed. Be mindful of what you are cloning and loading. At some point I may add some security features to allow users to preview what is  attempting to be loaded before doing so, but this is not currently a priority for me since the usage is targeted at my needs.

### Contributing
Issues are disabled. If you want to fix something, open a PR. I make no guarantees on accepting additional features that I do not intend to use myself.
