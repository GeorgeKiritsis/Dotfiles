local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  icon = {
    font = {
      style = settings.font.style_map["Regular"],
      size = 19.0,
    }
  },
  label = { font = { family = settings.font.numbers } },
  update_freq = 180,
  popup = { align = "center" }
})

local remaining_time = sbar.add("item", {
  position = "popup." .. battery.name,
  icon = {
    string = "Time remaining:",
    width = 100,
    align = "left"
  },
  label = {
    string = "??:??h",
    width = 100,
    align = "right"
  },
})


battery:subscribe({"routine", "power_source_change", "system_woke"}, function()
  sbar.exec("pmset -g batt | grep -o '[0-9]*%'", function(batt_pct)
    local icon = "!"
    local label = "?"

    local charge = batt_pct and tonumber(batt_pct:match("(%d+)"))
    if charge then
      label = charge .. "%"
    end

    local color = colors.green

    sbar.exec("pmset -g batt | head -1", function(source_info)
      local charging = source_info and source_info:find("AC Power")

      if charging then
        icon = icons.battery.charging
      else
        if charge and charge > 80 then
          icon = icons.battery._100
        elseif charge and charge > 60 then
          icon = icons.battery._75
        elseif charge and charge > 40 then
          icon = icons.battery._50
        elseif charge and charge > 20 then
          icon = icons.battery._25
          color = colors.orange
        else
          icon = icons.battery._0
          color = colors.red
        end
      end

      local lead = ""
      if charge and charge < 10 then
        lead = "0"
      end

      battery:set({
        icon = {
          string = icon,
          color = color
        },
        label = { string = lead .. label },
      })
    end)
  end)
end)

battery:subscribe("mouse.clicked", function(env)
  local drawing = battery:query().popup.drawing
  battery:set( { popup = { drawing = "toggle" } })

  if drawing == "off" then
    sbar.exec("pmset -g batt", function(batt_info)
      local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
      local label = found and remaining .. "h" or "No estimate"
      remaining_time:set( { label = label })
    end)
  end
end)

sbar.add("bracket", "widgets.battery.bracket", { battery.name }, {
  background = { color = colors.bg1 }
})

sbar.add("item", "widgets.battery.padding", {
  position = "right",
  width = settings.group_paddings
})
