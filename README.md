# deepseek.nvim

DeepSeek CLI integration for Neovim. Launches the [DeepSeek-TUI](https://github.com/Hmbown/DeepSeek-TUI) in a [Snacks.nvim](https://github.com/folke/snacks.nvim) terminal window, with seamless toggle, focus, and DeepSeek-native keyboard shortcuts pass-through.

## Features

- **Toggle terminal** — show/hide the DeepSeek CLI in a right-side split
- **Focus toggle** — jump to the terminal if unfocused, hide it if already focused
- **Session resume** — `:DeepSeekResume` to pick up where you left off
- **Interactive run** — `:DeepSeekRun` for the interactive TUI flow
- **Pass-through shortcuts** — `<C-t>` (conversation log), `<C-p>` (fuzzy files), `<C-r>` (resume session) are forwarded to DeepSeek TUI via PTY channel writes, avoiding key-mapping recursion

## Requirements

- Neovim >= 0.10
- [Snacks.nvim](https://github.com/folke/snacks.nvim)
- [DeepSeek CLI](https://github.com/Hmbown/DeepSeek-TUI) (`deepseek` on `$PATH`)

## Installation

### lazy.nvim

```lua
{
  "xiaopixiao/deepseek.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<leader>ds", "<cmd>DeepSeek<cr>",       desc = "Toggle DeepSeek" },
    { "<leader>df", "<cmd>DeepSeekFocus<cr>",   desc = "Focus DeepSeek" },
    { "<leader>dr", "<cmd>DeepSeekResume<cr>",  desc = "Resume session" },
    { "<leader>dd", "<cmd>DeepSeekRun<cr>",     desc = "Interactive run" },
  },
}
```

### With custom options

```lua
{
  "xiaopixiao/deepseek.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    terminal = {
      split_side = "left",
      split_width_percentage = 0.25,
      snacks_win_opts = {
        wo = { winblend = 100 },
      },
    },
  },
  keys = {
    { "<leader>ds", "<cmd>DeepSeek<cr>", desc = "Toggle DeepSeek" },
  },
}
```

## Configuration

`opts` is passed directly to `require("deepseek").setup(opts)`.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `terminal.split_side` | `"left"` \| `"right"` | `"right"` | Which side the split opens on |
| `terminal.split_width_percentage` | `number` | `0.30` | Width ratio (0-1) |
| `terminal.auto_close` | `boolean` | `true` | Auto-close terminal buffer on exit |
| `terminal.snacks_win_opts` | `table` | `{}` | Merged into Snacks terminal `win` config |
| `terminal_cmd` | `string?` | `nil` | Override the binary (default: `deepseek`) |
| `env` | `table<string,string>?` | `nil` | Extra environment variables |

## Commands

| Command | Description |
|---------|-------------|
| `:DeepSeek` | Toggle terminal (show/hide) |
| `:DeepSeekFocus` | Smart focus -- jump to terminal, or hide if already focused |
| `:DeepSeekOpen` | Open terminal without toggle logic |
| `:DeepSeekClose` | Close the terminal |
| `:DeepSeekRun [args]` | Open in interactive `run` mode |
| `:DeepSeekResume [name]` | Resume a saved session |

## Terminal Key Bindings

These are active inside the DeepSeek terminal window:

| Key | Action |
|-----|--------|
| `<C-t>` | Toggle conversation log overlay |
| `<C-p>` | Open fuzzy file picker |
| `<C-r>` | Open resume session picker |
| `<S-CR>` | New line (Shift+Enter) |

Keys are forwarded via `nvim_chan_send` to the PTY, bypassing Neovim's key-mapping layer -- no recursion, no input freeze.

This project is created by DeepSeek-v4-Pro.

## License

MIT
