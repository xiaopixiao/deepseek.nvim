---DeepSeek Neovim Integration
---Launches the DeepSeek CLI in a Snacks.nvim terminal window.
---@module 'deepseek'

local M = {}

M.state = {
  initialized = false,
}

---@param opts DeepSeekConfig?
function M.setup(opts)
  opts = opts or {}

  local terminal_ok, terminal = pcall(require, "deepseek.terminal")
  if terminal_ok and type(terminal.setup) == "function" then
    local term_opts = opts.terminal or {}
    terminal.setup(term_opts, opts.terminal_cmd, opts.env)
  end

  M._create_commands()

  M.state.initialized = true
end

---Register user commands
function M._create_commands()
  local terminal_ok, terminal = pcall(require, "deepseek.terminal")

  if not terminal_ok then
    return
  end

  vim.api.nvim_create_user_command("DeepSeek", function(opts)
    local cmd_args = opts.args and opts.args ~= "" and opts.args or nil
    terminal.simple_toggle({}, cmd_args)
  end, {
    nargs = "*",
    desc = "Toggle the DeepSeek terminal window",
  })

  vim.api.nvim_create_user_command("DeepSeekFocus", function(opts)
    local cmd_args = opts.args and opts.args ~= "" and opts.args or nil
    terminal.focus_toggle({}, cmd_args)
  end, {
    nargs = "*",
    desc = "Smart focus/toggle DeepSeek terminal (switches to terminal if not focused, hides if focused)",
  })

  vim.api.nvim_create_user_command("DeepSeekOpen", function(opts)
    local cmd_args = opts.args and opts.args ~= "" and opts.args or nil
    terminal.open({}, cmd_args)
  end, {
    nargs = "*",
    desc = "Open the DeepSeek terminal window",
  })

  vim.api.nvim_create_user_command("DeepSeekClose", function()
    terminal.close()
  end, {
    desc = "Close the DeepSeek terminal window",
  })

  vim.api.nvim_create_user_command("DeepSeekRun", function(opts)
    local cmd_args = opts.args and opts.args ~= "" and "run " .. opts.args or "run"
    terminal.open({}, cmd_args)
  end, {
    nargs = "*",
    desc = "Open DeepSeek terminal in run mode (interactive)",
  })

  vim.api.nvim_create_user_command("DeepSeekResume", function(opts)
    local cmd_args = opts.args and opts.args ~= "" and "resume " .. opts.args or "resume"
    terminal.open({}, cmd_args)
  end, {
    nargs = "*",
    desc = "Resume a saved DeepSeek session",
  })
end

return M
