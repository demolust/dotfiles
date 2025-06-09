local map = vim.keymap.set

-- Insert Mode --
-- Go to beginning and end
map("i", "<C-b>", "<ESC>^i", { desc = "Beginning of line" })
map("i", "<C-e>", "<End>", { desc = "End of line" })

-- Navigate within insert mode
map("i", "<C-h>", "<Left>", { desc = "Move left" })
map("i", "<C-l>", "<Right>", { desc = "Move right" })
map("i", "<C-j>", "<Down>", { desc = "Move down" })
map("i", "<C-k>", "<Up>", { desc = "Move up" })

-- Normal Mode --
map("n", "<Esc>", "<cmd> noh <CR>", { desc = "Clear highlights" })

-- Switch between windows
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })

-- Line numbers (as UI toggles)
map("n", "<leader>unu", "<cmd> set nu! <CR>", { desc = "Toggle line number" })
map("n", "<leader>unr", "<cmd> set rnu! <CR>", { desc = "Toggle relative number" })

-- View messages
map("n", "<leader>nm", "<cmd> messages <CR>", { desc = "View message history" })

-- Buffers
-- Move between opened buffers
map("n", "<Tab>", "<cmd> bnext <CR>", { desc = "Next Buffer" })
map("n", "<S-Tab>", "<cmd> bprevious <CR>", { desc = "Previous Buffer" })
-- Create a new named empty buffer
map("n", "<leader>bN", ":e ", { desc = "New Empty Buffer" })
-- Create a new empty buffer
map("n", "<leader>bn", "<cmd> enew <CR>", { desc = "New Empty Buffer" })
-- Close the current buffer
-- This logic specifically tries to close the buffer without closing the window layout
--map("n", "<leader>bx", function()
--  local bd = vim.api.nvim_get_current_buf()
--  if vim.bo.modified then
--    local choice = vim.fn.confirm("Save changes to " .. vim.fn.bufname() .. "?", "&Yes\n&No\n&Cancel")
--    if choice == 1 then
--      vim.cmd("write")
--    elseif choice == 3 then
--      return
--    end
--  end
--  vim.cmd("bdelete!")
--end, { desc = "Close Buffer" })
-- List all open buffers and prepare to switch (Set using plugin)
--vim.keymap.set("n", "<leader>bl", ":ls<CR>:b ", { desc = "List Buffers" })

-- File modifications 
map("n", "U", ":redo<cr>", { noremap = true, silent = true, desc = "Redo" })
map("n", ";", ":", { desc = "enter command mode", nowait = true })
map("n", "<", "<gv", { desc = "Indent line" })
map("n", ">", ">gv", { desc = "Indent line" })

-- Move through wrapped lines (Normal)
map("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { desc = "Move down", expr = true })
map("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { desc = "Move up", expr = true })
map("n", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { desc = "Move up", expr = true })
map("n", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { desc = "Move down", expr = true })

-- Terminal Mode --
map("t", "<C-x>", vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), { desc = "Escape terminal mode" })

-- Visual Mode --
map("v", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { desc = "Move up", expr = true })
map("v", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { desc = "Move down", expr = true })
map("v", "<", "<gv", { desc = "Indent line" })
map("v", ">", ">gv", { desc = "Indent line" })

-- Visual Block Mode
map("x", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { desc = "Move down", expr = true })
map("x", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { desc = "Move up", expr = true })
map("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', { desc = "Dont copy replaced text", silent = true })

-- Diagnostics
map("n", "<leader>co", function() vim.diagnostic.open_float() end, { desc = "Diagnostic messages in hover window" })
map("n", "<leader>cl", function() vim.diagnostic.setloclist() end, { desc = "Diagnostic messages in buffer window" })
-- Only to be used when not having snacks plugin
--map("n", "<leader>cs", function() vim.diagnostic.show() end, { desc = "Show diagnostic messages" })
--map("n", "<leader>ch", function() vim.diagnostic.hide() end, { desc = "Hide diagnostic messages" })

-- Deprecated
--map("n", "[d", function() vim.diagnostic.goto_prev() end, { desc = "Go to previous diagnostic message" })
--map("n", "]d", function() vim.diagnostic.goto_next() end, { desc = "Go to next diagnostic message" })
-- Defaults
--map("n", "za", "<cmd> foldtoggle <CR>", { desc = "Toggle folds" })
