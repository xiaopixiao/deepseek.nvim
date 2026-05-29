---DeepSeek terminal provider using Snacks.nvim.
---@module 'deepseek.terminal'

local M = {}

local snacks_available, Snacks = pcall(require, "snacks")
local terminal = nil

---@type DeepSeekTerminalConfig
local defaults = {
  split_side = "right",
  split_width_percentage = 0.30,
  auto_close = true,
  terminal_cmd = nil,
  env = {},
  snacks_win_opts = {},
}

M.defaults = defaults

---@return boolean
local function is_available()
  return snacks_available and Snacks and Snacks.terminal ~= nil
end

---Builds Snacks terminal options
---@param config DeepSeekTerminalConfig
---@param env_table table
---@param focus boolean|nil
---@return snacks.terminal.Opts
local function build_opts(config, env_table, focus)
  if focus == nil then
    focus = true
  end
  local opts = {
    start_insert = focus,
    auto_insert = focus,
    auto_close = false,
    win = vim.tbl_deep_extend("force", {
      position = config.split_side,
      width = config.split_width_percentage,
      height = 0,
      relative = "editor",
      keys = {
        deepseek_new_line = {
          "<S-CR>",
          function()
            vim.api.nvim_feedkeys("\\", "t", true)
            vim.defer_fn(function()
              vim.api.nvim_feedkeys("\r", "t", true)
            end, 10)
          end,
          mode = "t",
          desc = "New line",
        },
        deepseek_toggle_log = {
          "<C-t>",
          function()
            local chan = vim.bo[vim.api.nvim_get_current_buf()].channel
            if chan and chan > 0 then
              vim.api.nvim_chan_send(chan, "\x14")
            end
          end,
          mode = "t",
          desc = "Toggle conversation log",
        },
        deepseek_fuzzy_files = {
          "<C-p>",
          function()
            local chan = vim.bo[vim.api.nvim_get_current_buf()].channel
            if chan and chan > 0 then
              vim.api.nvim_chan_send(chan, "\x10")
            end
          end,
          mode = "t",
          desc = "Fuzzy file picker",
        },
        deepseek_resume_session = {
          "<C-r>",
          function()
            local chan = vim.bo[vim.api.nvim_get_current_buf()].channel
            if chan and chan > 0 then
              vim.api.nvim_chan_send(chan, "\x12")
            end
          end,
          mode = "t",
          desc = "Resume session picker",
        },
      },
    }, config.snacks_win_opts or {}),
  }
  -- Only include env when non-empty to avoid E475 from Neovim's termopen
  if env_table and not vim.tbl_isempty(env_table) then
    opts.env = env_table
  end
  if config.cwd then
    opts.cwd = config.cwd
  end
  return opts
end

---Setup event handlers for terminal instance
---@param term_instance table
---@param config DeepSeekTerminalConfig
local function setup_terminal_events(term_instance, config)
  if config.auto_close then
    term_instance:on("TermClose", function()
      if vim.v.event.status ~= 0 then
        vim.notify("DeepSeek exited with code " .. vim.v.event.status, vim.log.levels.WARN)
      end
      terminal = nil
      vim.schedule(function()
        term_instance:close({ buf = true })
        vim.cmd.checktime()
      end)
    end, { buf = true })
  end

  term_instance:on("BufWipeout", function()
    terminal = nil
  end, { buf = true })
end

---@param user_config DeepSeekTerminalConfig?
---@param p_terminal_cmd string?
---@param p_env table?
function M.setup(user_config, p_terminal_cmd, p_env)
  if user_config == nil then
    user_config = {}
  elseif type(user_config) ~= "table" then
    user_config = {}
  end

  if p_terminal_cmd == nil or type(p_terminal_cmd) == "string" then
    defaults.terminal_cmd = p_terminal_cmd
  end
  if p_env == nil or type(p_env) == "table" then
    defaults.env = p_env or {}
  end

  for k, v in pairs(user_config) do
    if k == "split_side" then
      if v == "left" or v == "right" then
        defaults.split_side = v
      end
    elseif k == "split_width_percentage" then
      if type(v) == "number" and v > 0 and v < 1 then
        defaults.split_width_percentage = v
      end
    elseif k == "auto_close" then
      if type(v) == "boolean" then
        defaults.auto_close = v
      end
    elseif k == "snacks_win_opts" then
      if type(v) == "table" then
        defaults.snacks_win_opts = v
      end
    elseif k == "cwd" then
      if v == nil or type(v) == "string" then
        defaults.cwd = v
      end
    end
  end
end

---Build command string and environment
---@param cmd_args string?
---@return string, table
local function get_command_and_env(cmd_args)
  local base_cmd = defaults.terminal_cmd or "codewhale"
  local cmd_string
  if cmd_args and cmd_args ~= "" then
    cmd_string = base_cmd .. " " .. cmd_args
  else
    cmd_string = base_cmd
  end
  return cmd_string, vim.deepcopy(defaults.env)
end

---Open terminal
---@param opts_override table?
---@param cmd_args string?
function M.open(opts_override, cmd_args)
  if not is_available() then
    vim.notify("deepseek.nvim: Snacks.nvim not available for terminal.", vim.log.levels.ERROR)
    return
  end

  local config = vim.deepcopy(defaults)
  if type(opts_override) == "table" then
    for k, v in pairs(opts_override) do
      if config[k] ~= nil then
        config[k] = v
      end
    end
  end

  local cmd_string, env_table = get_command_and_env(cmd_args)

  if terminal and terminal:buf_valid() then
    if not terminal.win or not vim.api.nvim_win_is_valid(terminal.win) then
      terminal:toggle()
      terminal:focus()
      if terminal.buf and vim.api.nvim_buf_get_option(terminal.buf, "buftype") == "terminal" then
        if terminal.win and vim.api.nvim_win_is_valid(terminal.win) then
          vim.api.nvim_win_call(terminal.win, function()
            vim.cmd("startinsert")
          end)
        end
      end
    else
      terminal:focus()
      if terminal.buf and vim.api.nvim_buf_get_option(terminal.buf, "buftype") == "terminal" then
        if terminal.win and vim.api.nvim_win_is_valid(terminal.win) then
          vim.api.nvim_win_call(terminal.win, function()
            vim.cmd("startinsert")
          end)
        end
      end
    end
    return
  end

  local opts = build_opts(config, env_table, true)
  local term_instance = Snacks.terminal.open(cmd_string, opts)
  if term_instance and term_instance:buf_valid() then
    setup_terminal_events(term_instance, config)
    terminal = term_instance
  else
    terminal = nil
    vim.notify("deepseek.nvim: Failed to open terminal.", vim.log.levels.ERROR)
  end
end

---Close terminal
function M.close()
  if terminal and terminal:buf_valid() then
    terminal:close()
  end
end

---Simple toggle: show/hide terminal
---@param opts_override table?
---@param cmd_args string?
function M.simple_toggle(opts_override, cmd_args)
  if not is_available() then
    vim.notify("deepseek.nvim: Snacks.nvim not available.", vim.log.levels.ERROR)
    return
  end

  if terminal and terminal:buf_valid() and terminal:win_valid() then
    terminal:toggle()
  elseif terminal and terminal:buf_valid() and not terminal:win_valid() then
    terminal:toggle()
  else
    M.open(opts_override, cmd_args)
  end
end

---Smart focus toggle: switch to terminal if not focused, hide if focused
---@param opts_override table?
---@param cmd_args string?
function M.focus_toggle(opts_override, cmd_args)
  if not is_available() then
    vim.notify("deepseek.nvim: Snacks.nvim not available.", vim.log.levels.ERROR)
    return
  end

  if terminal and terminal:buf_valid() and not terminal:win_valid() then
    terminal:toggle()
  elseif terminal and terminal:buf_valid() and terminal:win_valid() then
    local term_win = terminal.win
    local cur_win = vim.api.nvim_get_current_win()
    if term_win == cur_win then
      terminal:toggle()
    else
      vim.api.nvim_set_current_win(term_win)
      if terminal.buf and vim.api.nvim_buf_is_valid(terminal.buf) then
        if vim.api.nvim_buf_get_option(terminal.buf, "buftype") == "terminal" then
          vim.api.nvim_win_call(term_win, function()
            vim.cmd("startinsert")
          end)
        end
      end
    end
  else
    M.open(opts_override, cmd_args)
  end
end

---@return number?
function M.get_active_bufnr()
  if terminal and terminal:buf_valid() and terminal.buf then
    if vim.api.nvim_buf_is_valid(terminal.buf) then
      return terminal.buf
    end
  end
  return nil
end

return M
