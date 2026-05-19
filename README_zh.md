# deepseek.nvim

DeepSeek CLI 的 Neovim 集成。在 [Snacks.nvim](https://github.com/folke/snacks.nvim) 终端窗口中启动 [DeepSeek-TUI](https://github.com/Hmbown/DeepSeek-TUI)，支持无缝切换、聚焦以及 DeepSeek 原生快捷键透传。

## 特性

- **终端切换** — 在右侧分屏中显示/隐藏 DeepSeek CLI
- **智能聚焦** — 未聚焦时跳转到终端，已聚焦时隐藏终端
- **会话恢复** — 通过 `:DeepSeekResume` 继续上次的对话
- **交互模式** — `:DeepSeekRun` 启动交互式 TUI 流程
- **快捷键透传** — `<C-t>`（对话日志）、`<C-p>`（模糊文件）、`<C-r>`（恢复会话）通过 PTY 通道写入转发给 DeepSeek TUI，避免键映射递归

## 依赖

- Neovim >= 0.10
- [Snacks.nvim](https://github.com/folke/snacks.nvim)
- [DeepSeek-TUI](https://github.com/Hmbown/DeepSeek-TUI)（`deepseek` 需在 `$PATH` 中）

## 安装

### lazy.nvim

```lua
{
  "xiaopixiao/deepseek.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  keys = {
    { "<leader>ds", "<cmd>DeepSeek<cr>",       desc = "切换 DeepSeek" },
    { "<leader>df", "<cmd>DeepSeekFocus<cr>",   desc = "聚焦 DeepSeek" },
    { "<leader>dr", "<cmd>DeepSeekResume<cr>",  desc = "恢复会话" },
    { "<leader>dd", "<cmd>DeepSeekRun<cr>",     desc = "交互模式" },
  },
}
```

### 自定义配置

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
    { "<leader>ds", "<cmd>DeepSeek<cr>", desc = "切换 DeepSeek" },
  },
}
```

## 配置

`opts` 会直接传递给 `require("deepseek").setup(opts)`。

| 选项 | 类型 | 默认值 | 说明 |
|--------|------|---------|-------------|
| `terminal.split_side` | `"left"` \| `"right"` | `"right"` | 分屏打开方向 |
| `terminal.split_width_percentage` | `number` | `0.30` | 宽度比例 (0-1) |
| `terminal.auto_close` | `boolean` | `true` | 退出时自动关闭终端 buffer |
| `terminal.snacks_win_opts` | `table` | `{}` | 合并到 Snacks 终端 `win` 配置中 |
| `terminal_cmd` | `string?` | `nil` | 覆盖可执行文件路径（默认: `deepseek`） |
| `env` | `table<string,string>?` | `nil` | 额外的环境变量 |

## 命令

| 命令 | 说明 |
|---------|-------------|
| `:DeepSeek` | 切换终端（显示/隐藏） |
| `:DeepSeekFocus` | 智能聚焦 — 跳转到终端，或已聚焦时隐藏 |
| `:DeepSeekOpen` | 直接打开终端（无切换逻辑） |
| `:DeepSeekClose` | 关闭终端 |
| `:DeepSeekRun [args]` | 以交互 `run` 模式打开 |
| `:DeepSeekResume [name]` | 恢复已保存的会话 |

## 终端快捷键

以下快捷键在 DeepSeek 终端窗口中生效：

| 按键 | 操作 |
|-----|--------|
| `<C-t>` | 切换对话日志浮窗 |
| `<C-p>` | 打开模糊文件选择器 |
| `<C-r>` | 打开恢复会话选择器 |
| `<S-CR>` | 换行（Shift+Enter） |

快捷键通过 `nvim_chan_send` 转发到 PTY，绕过 Neovim 的键映射层 — 无递归、无输入卡死。

## 许可证

MIT
