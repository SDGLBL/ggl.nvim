local config = require("ggl.config").config
local glob = require "ggl.globtopattern"
local uv = vim.loop
local M = {}

local function get_remote_origin_url()
  return vim.fn.trim(vim.fn.system "git config --get remote.origin.url")
end

local function get_branch_name()
  return vim.fn.trim(vim.fn.system "git branch --show-current")
end

local function get_commit_id()
  return vim.fn.trim(vim.fn.system "git rev-parse HEAD")
end

local function get_file_path()
  return vim.fn.expand "%:p"
end

---@diagnostic disable-next-line: deprecated, unused-function, unused-local
local function get_file_name()
  return vim.fn.expand "%:t"
end

local function find_lsp_root()
  local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
  local clients = vim.lsp.buf_get_clients()
  if next(clients) == nil then
    return nil
  end

  for _, client in pairs(clients) do
    local filetypes = client.config.filetypes
    if filetypes and vim.tbl_contains(filetypes, buf_ft) then
      if not vim.tbl_contains(config.ignore_lsp, client.name) then
        return client.config.root_dir, client.name
      end
    end
  end
end

local function find_pattern_root()
  local search_dir = vim.fn.expand("%:p:h", true)
  if vim.fn.has "win32" > 0 then
    search_dir = search_dir:gsub("\\", "/")
  end

  local last_dir_cache = ""
  local curr_dir_cache = {}

  local function get_parent(path)
    path = path:match "^(.*)/"
    if path == "" then
      path = "/"
    end
    return path
  end

  local function get_files(file_dir)
    last_dir_cache = file_dir
    curr_dir_cache = {}

    local dir = uv.fs_scandir(file_dir)
    if dir == nil then
      return
    end

    while true do
      local file = uv.fs_scandir_next(dir)
      if file == nil then
        return
      end

      table.insert(curr_dir_cache, file)
    end
  end

  local function is(dir, identifier)
    dir = dir:match ".*/(.*)"
    return dir == identifier
  end

  local function sub(dir, identifier)
    local path = get_parent(dir)
    while true do
      if is(path, identifier) then
        return true
      end
      local current = path
      path = get_parent(path)
      if current == path then
        return false
      end
    end
  end

  local function child(dir, identifier)
    local path = get_parent(dir)
    return is(path, identifier)
  end

  local function has(dir, identifier)
    if last_dir_cache ~= dir then
      get_files(dir)
    end
    local pattern = glob.globtopattern(identifier)
    for _, file in ipairs(curr_dir_cache) do
      if file:match(pattern) ~= nil then
        return true
      end
    end
    return false
  end

  local function match(dir, pattern)
    local first_char = pattern:sub(1, 1)
    if first_char == "=" then
      return is(dir, pattern:sub(2))
    elseif first_char == "^" then
      return sub(dir, pattern:sub(2))
    elseif first_char == ">" then
      return child(dir, pattern:sub(2))
    else
      return has(dir, pattern)
    end
  end

  -- breadth-first search
  while true do
    for _, pattern in ipairs(config.patterns) do
      local exclude = false
      if pattern:sub(1, 1) == "!" then
        exclude = true
        pattern = pattern:sub(2)
      end
      if match(search_dir, pattern) then
        if exclude then
          break
        else
          return search_dir, "pattern " .. pattern
        end
      end
    end

    local parent = get_parent(search_dir)
    if parent == search_dir or parent == nil then
      return nil
    end

    search_dir = parent
  end
end

local function get_project_root()
  -- returns project root, as well as method
  for _, detection_method in ipairs(config.detection_methods) do
    if detection_method == "lsp" then
      local root, lsp_name = find_lsp_root()
      if root ~= nil then
        return root, '"' .. lsp_name .. '"' .. " lsp"
      end
    elseif detection_method == "pattern" then
      local root, method = find_pattern_root()
      if root ~= nil then
        return root, method
      end
    end
  end
end

M.show_and_save_url_2_register = function(url)
  if url ~= "" and url ~= nil then
    vim.notify(url)
    vim.fn.setreg(config.register, url)
  end
end

--- @return string | nil
M.generate_line_url = function()
  local remote_origin_url = get_remote_origin_url()
  if remote_origin_url == "" then
    return
  end

  local branch_name = get_branch_name()
  if branch_name == "" then
    return
  end

  local file_path = get_file_path()
  local project_root = get_project_root()

  -- delete project root from file path
  if project_root ~= nil then
    file_path = file_path:gsub(project_root, "")
  end

  return remote_origin_url .. "/tree/" .. branch_name .. file_path
end

M.generate_permalink = function()
  local remote_origin_url = get_remote_origin_url()
  if remote_origin_url == "" then
    return
  end

  local branch_name = get_branch_name()
  if branch_name == "" then
    return
  end

  local commit_id = get_commit_id()
  if commit_id == "" then
    return
  end

  local file_path = get_file_path()
  local project_root = get_project_root()

  -- delete project root from file path
  if project_root ~= nil then
    file_path = file_path:gsub(project_root, "")
  end

  return remote_origin_url .. "/blob/" .. commit_id .. file_path
end

return M
