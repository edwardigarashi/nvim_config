Here’s a clear, easy-to-understand manual and command reference tailored to your current Neovim setup:

---

# 🚀 **Neovim Custom Manual**

This manual covers your current plugins, custom keybindings, and features for quick reference.

---

## 🛠 **Plugins Installed**

| Plugin              | Description                       |
| ------------------- | --------------------------------- |
| **Packer.nvim**     | Plugin manager for Neovim         |
| **Mason.nvim**      | LSP installer & manager           |
| **LSPconfig**       | Configure language servers easily |
| **rust-tools.nvim** | Enhanced Rust tooling             |
| **nvim-cmp**        | Autocompletion engine             |
| **vim-vsnip**       | Snippet engine                    |
| **Telescope.nvim**  | Powerful fuzzy finder             |
| **nvim-treesitter** | Better syntax highlighting        |
| **vimspector**      | Powerful debugging system         |

---

## 💻 **Core Commands (Normal Mode)**

| Keybinding              | Action                    | Provided by    |
| ----------------------- | ------------------------- | -------------- |
| `<leader>ff`            | Find files (fuzzy search) | Telescope.nvim |
| `<leader>fg`            | Search text in files      | Telescope.nvim |
| `<leader>fb`            | List & switch buffers     | Telescope.nvim |
| `<leader>fh`            | Search Neovim help        | Telescope.nvim |
| `<leader>ft`            | Open floating terminal    | Floaterm       |
| `t`                     | Toggle floating terminal  | Floaterm       |
| `<Esc>` (Terminal mode) | Close floating terminal   | Floaterm       |

***Note:** `<leader>` is usually set to backslash `\`. Check with `:echo mapleader`. You can set it explicitly with:*

```lua
vim.g.mapleader = ' '
```

(to set `<leader>` to the spacebar)

---

## 🐛 **Debugging (Vimspector)**

| Keybinding        | Action                           |
| ----------------- | -------------------------------- |
| `<F9>`            | Launch/start debugger session    |
| `<F5>` or `<F11>` | Step Over                        |
| `<F8>`            | Reset/stop debugger              |
| `<F10>`           | Step Into function               |
| `<F12>`           | Step Out of function             |
| `Db`              | Toggle breakpoint                |
| `Dw`              | Add a watch expression           |
| `De`              | Evaluate expression under cursor |

---

## ⚙ **Rust Development**

| Keybinding     | Action                           | Provided by     |
| -------------- | -------------------------------- | --------------- |
| `<Ctrl-Space>` | Hover actions (Rust-specific)    | rust-tools.nvim |
| `<Leader>a`    | Code action menu (Rust-specific) | rust-tools.nvim |

---

## ✨ **Autocompletion (nvim-cmp)**

| Keybinding       | Action                          |
| ---------------- | ------------------------------- |
| `<Tab>`          | Select next completion item     |
| `<Shift-Tab>`    | Select previous completion item |
| `<Ctrl-Space>`   | Trigger manual completion       |
| `<Enter>`        | Confirm selection               |
| `<Ctrl-f>`       | Scroll completion docs down     |
| `<Ctrl-Shift-f>` | Scroll completion docs up       |
| `<Ctrl-e>`       | Close completion menu           |

**Completion Sources Enabled:**

* File paths (`🖫`)
* Language Server Protocol (`λ`)
* Lua runtime API completion
* Buffer content (`Ω`)
* Snippets (`⋗`)
* Math calculation

---

## 🌳 **Treesitter (Syntax highlighting)**

* Syntax highlighting and code navigation improvements are enabled for:

  * Lua
  * Rust
  * TOML

---

## 📦 **Mason LSP Manager**

Mason automatically manages installation of your language servers.
To open Mason UI:

```vim
:Mason
```

* Icons in Mason UI:

  * Installed package: ``
  * Pending installation: ``
  * Uninstalled: ``

---

## 🚧 **Diagnostics (LSP errors & warnings)**

| Sign/Icon | Meaning |
| --------- | ------- |
| ``       | Error   |
| ``       | Warning |
| ``       | Hint    |
| ``       | Info    |

* Diagnostics float automatically shows on cursor hold.
* Sign column (`signcolumn=yes`) always visible on the left.

---

## 🔍 **Telescope Quick Reference**

| Command (run from `:`)  | Action                      |
| ----------------------- | --------------------------- |
| `:Telescope find_files` | Fuzzy-find file by name     |
| `:Telescope live_grep`  | Search content within files |
| `:Telescope buffers`    | Manage open buffers         |
| `:Telescope help_tags`  | Quickly navigate help docs  |

---

## 💻 **Floaterm (Floating Terminal)**

| Command           | Action                     |
| ----------------- | -------------------------- |
| `:FloatermNew`    | Open new floating terminal |
| `:FloatermToggle` | Toggle floating terminal   |

---

## 🚨 **Debugging Commands (Vimspector)**

| Command                               | Action                  |
| ------------------------------------- | ----------------------- |
| `:call vimspector#Launch()`           | Launch debugger         |
| `:call vimspector#StepOver()`         | Step over code line     |
| `:call vimspector#StepInto()`         | Step into function call |
| `:call vimspector#StepOut()`          | Step out of function    |
| `:call vimspector#ToggleBreakpoint()` | Toggle breakpoint       |
| `:call vimspector#AddWatch()`         | Add expression watch    |
| `:call vimspector#Evaluate()`         | Evaluate expression     |

---

## 📝 **General Tips**

* **Restart Neovim** after changing plugins (`:PackerSync` to auto-update).
* Use `:checkhealth` periodically to verify configuration health.

---

## 🚀 **Recommended workflow**

* Edit code → `<leader>ff` quickly opens files.
* Live grep (`<leader>fg`) helps to search codebase instantly.
* Toggle debugger quickly with `<F9>`.
* Use Rust-specific hover (`Ctrl-space`) frequently for code hints.

---

✅ **You now have a comprehensive manual for your customized Neovim setup.**
Keep this reference handy and happy coding!

