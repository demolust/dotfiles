local Snacks = require("snacks")
local Tree = require("snacks.explorer.tree")
local uv = vim.uv or vim.loop

local sort_params = {
  field = "name", -- "name", "size", "time"
  reverse = false,
}

-- Helper to fetch stats (cached on the node)
local function get_node_stat(node)
  if node.size and node.mtime then
    return node
  end
  local stat = uv.fs_stat(node.path)
  if stat then
    node.size = stat.size
    node.mtime = stat.mtime.sec
  else
    node.size = 0
    node.mtime = 0
  end
  return node
end

-- Monkey-Patch Tree:walk to inject custom sorting
function Tree:walk(node, fn, opts)
  local abort = fn(node)
  if abort ~= nil then
    return abort
  end

  local children = vim.tbl_values(node.children)

  -- CUSTOM SORT LOGIC START
  table.sort(children, function(a, b)
    -- Always keep directories on top
    if a.dir ~= b.dir then
      return a.dir
    end

    local sort_field = sort_params.field
    local ret = false

    if sort_field == "name" then
      ret = a.name < b.name
    elseif sort_field == "size" then
      local sa = get_node_stat(a).size
      local sb = get_node_stat(b).size
      if sa == sb then ret = a.name < b.name else ret = sa < sb end
    elseif sort_field == "time" then
      local ta = get_node_stat(a).mtime
      local tb = get_node_stat(b).mtime
      if ta == tb then ret = a.name < b.name else ret = ta < tb end
    end

    if sort_params.reverse then
      return not ret
    end
    return ret
  end)
  -- CUSTOM SORT LOGIC END

  for c, child in ipairs(children) do
    child.last = c == #children
    abort = false
    if child.dir and (child.open or (opts and opts.all)) then
      abort = self:walk(child, fn, opts)
    else
      abort = fn(child)
    end
    if abort then
      return true
    end
  end
  return false
end

-- Custom Actions
--local custom_actions = {}
_G.ExplorerActions = {}

function _G.ExplorerActions.cycle_sort()
  --local Snacks = require("snacks")
  local p = Snacks.picker.get()[1] -- Get the active picker
  if not p then return Snacks.notify.warn("No active picker") end
  local modes = { "name", "time", "size" }
  local current_idx = 1
  for i, v in ipairs(modes) do
    if v == sort_params.field then current_idx = i end
  end

  local next_idx = (current_idx % #modes) + 1
  sort_params.field = modes[next_idx]

  Snacks.notify.info("Sorting by: " .. sort_params.field)
  p:find()
end

function _G.ExplorerActions.reverse_sort()
  --local Snacks = require("snacks")
  local p = Snacks.picker.get()[1] -- Get the active picker
  if not p then return Snacks.notify.warn("No active picker") end
  sort_params.reverse = not sort_params.reverse

  local dir = sort_params.reverse and "Descending" or "Ascending"
  Snacks.notify.info("Sort order: " .. dir)
  p:find()
end


