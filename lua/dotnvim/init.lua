local scan_dir = require("plenary.scandir").scan_dir
local Path = require("plenary.path")

local config = {
  project_configs_parent_dir = "~/.config/dotnvim"
}

local scan_args = { 
  add_dirs = true,
  only_dirs = true,
  depth = 1,
}

local function module_name(parent_dir)
  local mod_full_path = scan_dir(parent_dir, scan_args)[1]
  if not mod_full_path then
    return nil
  end

  local mod_name_parts = vim.split(mod_full_path, "/")
  local mod_name = mod_name_parts[#mod_name_parts]
  return mod_name
end

local function load_config_from_parent_dir_if_exists(cwd, parent_dir)
  local paths = vim.split(cwd, "/") 
  local p = Path:new(parent_dir)
  if not p:exists() then
    p:mkdir({ parents = true })
  end

  if p:is_dir() then
    local configured_projects = scan_dir(p.filename, scan_args)

    for index = #paths, 1, -1 do
      local file_path_part = paths[index]
      for _, project_config_dir in pairs(configured_projects) do
        local project_config_parts = vim.split(project_config_dir, "/")
        local project_config = project_config_parts[#project_config_parts]
        if file_path_part == project_config then

          local project_config_dir = parent_dir .. "/" .. project_config
          local root_init_lua = Path.new(project_config_dir .. "/init.lua")
          if root_init_lua:is_file() then
            dofile(root_init_lua.filename)
            return true
          end

          local lua_path = Path:new(project_config_dir .. "/lua")
          if lua_path:is_dir() then
            local init_path = lua_path .. "/?/init.lua"
            local files_path = lua_path .. "/?.lua"

            local mod_name = module_name(lua_path.filename)

            if not mod_name then
              vim.notify("No module located in " .. lua_path.filename, "ERROR", { title = "dotnvim"})
              return false
            end

            package.path = package.path .. ";" .. init_path .. ";" .. files_path
            require(mod_name)
            return true
          end
          vim.notify("Configuration directory present for " .. project_config .. " but it does not contain an init.lua or lua module", "WARN", { title = "dotnvim"})
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
    local parent_path =  s .. table.concat(paths, s)
    local str_path = parent_path .. "/.nvim" 
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
          local mod_name = module_name(directory.filename) 
          if not mod_name then
              vim.notify("No module located in " .. directory.filename, "ERROR", { title = "dotnvim"})
              return false
          end
          package.path = package.path .. ";" .. files_path .. ";" .. init_path
          require(mod_name)
          return true
        end
      end

      vim.notify(".nvim present for " .. parent_path .. " but is not a file or directory containing a lua module", "WARN", { title = "dotnvim"})
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

