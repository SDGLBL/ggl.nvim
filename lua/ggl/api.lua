local utils = require "ggl.utils"

local M = {}

M.generate_line_link = function(...)
  local args = select(1, ...)
  local fargs = args["fargs"]
  local range = args["range"]

  local line_url = utils.generate_line_url()
  if line_url == nil then
    vim.notify("This file not in git repo or not a file buffer", vim.log.levels.ERROR)
  end

  if range == nil or range == 0 then
    if #fargs == 0 then
      utils.show_and_save_url_2_register(line_url .. "#L" .. vim.fn.line ".")
    elseif #fargs == 1 then
      local line_num = tonumber(fargs[1])
      if type(line_num) == "number" then
        utils.show_and_save_url_2_register(line_url .. "#L" .. line_num)
      else
        vim.notify("Invalid line number", vim.log.levels.ERROR)
      end
    elseif #fargs == 2 then
      local start_line_num = tonumber(fargs[1])
      local end_line_num = tonumber(fargs[2])
      if type(start_line_num) == "number" and type(end_line_num) == "number" then
        utils.show_and_save_url_2_register(
          line_url .. "#L" .. start_line_num .. "-" .. end_line_num
        )
      else
        vim.notify("Invalid line number", vim.log.levels.ERROR)
      end
    end
  else
    local start_line_num = args["line1"]
    local end_line_num = args["line2"]
    utils.show_and_save_url_2_register(line_url .. "#L" .. start_line_num .. "-" .. end_line_num)
  end
end

M.generate_permalink = function(...)
  local args = select(1, ...)
  local fargs = args["fargs"]
  local range = args["range"]

  local permalink = utils.generate_permalink()
  if permalink == nil then
    vim.notify("This file not in git repo or not a file buffer", vim.log.levels.ERROR)
  end

  if range == nil or range == 0 then
    if #fargs == 0 then
      utils.show_and_save_url_2_register(permalink .. "#L" .. vim.fn.line ".")
    elseif #fargs == 1 then
      local line_num = tonumber(fargs[1])
      if type(line_num) == "number" then
        utils.show_and_save_url_2_register(permalink .. "#L" .. line_num)
      else
        vim.notify("Invalid line number", vim.log.levels.ERROR)
      end
    elseif #fargs == 2 then
      local start_line_num = tonumber(fargs[1])
      local end_line_num = tonumber(fargs[2])
      if type(start_line_num) == "number" and type(end_line_num) == "number" then
        utils.show_and_save_url_2_register(
          permalink .. "#L" .. start_line_num .. "-" .. end_line_num
        )
      else
        vim.notify("Invalid line number", vim.log.levels.ERROR)
      end
    end
  else
    local start_line_num = args["line1"]
    local end_line_num = args["line2"]
    utils.show_and_save_url_2_register(permalink .. "#L" .. start_line_num .. "-" .. end_line_num)
  end
end

M.init = function()
  vim.api.nvim_create_user_command("GLineLink", M.generate_line_link, {
    range = true,
    nargs = "*",
  })

  vim.api.nvim_create_user_command("GPermaLink", M.generate_permalink, {
    range = true,
    nargs = "*",
  })
end

return M
