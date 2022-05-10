local scan_dir = require("plenary.scandir").scan_dir
local Path = require("plenary.path")

local config = {
  project_configs_parent_dir = "~/.config/dotnvim"
}

local function module_name(parent_dir)
  local file_path = Path:new(parent_dir .. "/module_name")

  if file_path:exists() then 
    print(file_path.filename .. " exists!")
    local io = require("io")
    local name_file = io.open(file_path.filename, "r")
    local name = name_file:read("*l")
    name_file:close()
    return name
  end
end

local function load_config_from_parent_dir_if_exists(cwd, parent_dir)
  local paths = vim.split(cwd, "/") 
  local p = Path:new(parent_dir)
  if not p:exists() then
    p:mkdir({ parents = true })
  end

  if p:is_dir() then
    local configured_projects = scan_dir(p.filename, { 
      add_dirs = true,
      only_dirs = true,
      depth = 1,
    })

    for index = #paths, 1, -1 do
      local file_path_part = paths[index]
      for _, project_config_dir in pairs(configured_projects) do
        local project_config_parts = vim.split(project_config_dir, "/")
        local project_config = project_config_parts[#project_config_parts]
        if file_path_part == project_config then
          local project_config_dir = parent_dir .. "/" .. project_config
          local root_init_lua = Path:new(project_config_dir .. "/init.lua")
          if root_init_lua:exists() and root_init_lua:is_file() then
            dofile(root_init_lua.filename)
            return true
          end

          local mod_name = module_name(project_config_dir) or project_config
          local mod_path = Path:new(project_config_dir .. "/lua")
          if mod_path:exists() and mod_path:is_dir() then
            local init_path = mod_path .. "/?/init.lua"
            local files_path = mod_path .. "/?.lua"
            package.path = package.path .. ";" .. init_path .. ";" .. files_path
            require(mod_name)
            return true
          end
        end
      end
    end
  end

  return false
end

local function load_config_from_file_path_if_exists(cwd)
  local paths = vim.split(cwd, "/")
  table.remove(paths, 1)

  local s = "/"

  for _=1,#paths do
    local str_path = s .. table.concat(paths, s) .. "/.nvim" 
    local p = Path:new(str_path)

    if p:exists() then
      if p:is_file() then
        dofile(str_path)
        return true
      elseif p:is_dir() then
        local directory = Path:new(str_path .. s .. "lua")

        if directory:exists() and directory:is_dir() then
          local init_path = directory.filename .. "/?/init.lua"
          local files_path = directory.filename .. "/?.lua"
          local mod_name = module_name(p.filename) or paths[#paths]
          package.path = package.path .. ";" .. files_path .. ";" .. init_path
          require(mod_name)
          return true
        end
      end
    end

    table.remove(paths)
  end

  return false
end

local function setup(params)
  local raw_parent_dir = vim.fn.expand(params.parent_dir or config.project_configs_parent_dir)
  local cwd = vim.fn.getcwd()
  load_config_from_file_path_if_exists(cwd)
  load_config_from_parent_dir_if_exists(cwd, raw_parent_dir)
end

return {
  setup = setup
}

