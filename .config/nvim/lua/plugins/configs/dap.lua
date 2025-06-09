local M = {}

M.setup = function()
  local dap = require("dap")
  local dapui = require("dapui")
  local dap_py = require("dap-python")
  local dap_go = require("dap-go")
  local keymaps = require("plugins.configs.keymaps")

  -- UI Setup
  dapui.setup()
  dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
  dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

  -- Language Configs
  local python_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
  dap_py.setup(python_path)
  dap_go.setup()

  -- Keymaps Application
  local function apply_keys(maps)
    if not maps then return end
    for _, map in ipairs(maps) do
      vim.keymap.set(map.mode or "n", map[1], map[2], { desc = map.desc })
    end
  end
  apply_keys(keymaps.dap_python)
  apply_keys(keymaps.dap_go)
end

return M
