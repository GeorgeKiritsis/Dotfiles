local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Padding item required because of bracket
sbar.add("item", { width = 5 })

local apple = sbar.add("item", {
  icon = {
    font = { size = 17.0 },
    string = icons.apple,
    color = colors.orange,
    padding_right = 10,
    padding_left = 10,
  },
  label = { drawing = false },
  background = {
    color = colors.bg1,
    border_color = colors.bg2,
    border_width = 1
  },
  padding_left = 1,
  padding_right = 1,
  click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0"
})

-- Padding item required because of bracket
sbar.add("item", { width = 7 })
