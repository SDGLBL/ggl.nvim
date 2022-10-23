local config = require("ggl.config").config
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

local function get_file_path_relative_root()
  return vim.fn.fnamemodify(vim.fn.expand "%:h", ":p:~:.")
end

local function get_file_name()
  return vim.fn.expand "%:t"
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

  local file_path_relative_root = get_file_path_relative_root()

  local file_name = get_file_name()
  if file_name == "" then
    return
  end

  if file_path_relative_root ~= "" then
    return remote_origin_url
      .. "/tree/"
      .. branch_name
      .. "/"
      .. file_path_relative_root
      .. file_name
  else
    return remote_origin_url .. "/tree/" .. branch_name .. "/" .. file_name
  end
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

  local file_path_relative_root = get_file_path_relative_root()

  local file_name = get_file_name()
  if file_name == "" then
    return
  end

  if file_path_relative_root ~= "" then
    return remote_origin_url .. "/blob/" .. commit_id .. "/" .. file_path_relative_root .. file_name
  else
    return remote_origin_url .. "/blob/" .. commit_id .. "/" .. file_name
  end
end

return M
