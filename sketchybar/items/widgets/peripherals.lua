local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Matched case-insensitively against the Bluetooth product name
local keyboard_pattern = "epomaker|rt65"

-- Commands always print a trailing status line so the exec callback always runs
local logi_battery = "$CONFIG_DIR/helpers/event_providers/logi_battery/bin/logi_battery; echo rc=$?"

-- Prints "<name>|<percent>" for every connected BLE device with a battery service
local ble_battery = "$CONFIG_DIR/helpers/event_providers/ble_battery/bin/ble_battery; echo rc=$?"

local peripherals = sbar.add("item", "widgets.peripherals", {
  position = "right",
  icon = {
    string = icons.peripherals.mouse,
    font = {
      style = settings.font.style_map["Regular"],
      size = 15.0,
    }
  },
  label = { font = { family = settings.font.text } },
  update_freq = 60,
  popup = { align = "center" }
})

local function popup_row(title)
  return sbar.add("item", {
    position = "popup." .. peripherals.name,
    icon = { string = title, width = 110, align = "left" },
    label = { string = "--", width = 170, align = "right" },
  })
end

local mouse_row = popup_row("MX Master 3S")
local keyboard_row = popup_row("RT65")
local updated_row = popup_row("Updated")

-- Last reading of each device, kept to show in the popup once it disconnects
local last_seen = {}

local function find_keyboard(output)
  for line in (output or ""):gmatch("[^\n]+") do
    local name, pct = line:match("^(.-)|(%d+)$")
    if name then
      local lname = name:lower()
      for word in keyboard_pattern:gmatch("[^|]+") do
        if lname:find(word, 1, true) then return tonumber(pct) end
      end
    end
  end
end

local function color_for(charge)
  if not charge then return colors.grey end
  if charge <= 10 then return colors.red end
  if charge <= 20 then return colors.orange end
  return colors.green
end

-- The RT65 only reports its level, so charging is inferred from the level rising.
-- It's cleared when the level drops, or when it hasn't risen for a while (full / unplugged).
local keyboard_state = { last = nil, charging = false, last_rise = 0 }
local charging_hold = 20 * 60

local function keyboard_charging(keyboard)
  local state, now = keyboard_state, os.time()
  if not keyboard then
    state.last, state.charging = nil, false
    return false
  end
  if state.last and keyboard > state.last then
    state.charging, state.last_rise = true, now
  elseif state.last and keyboard < state.last then
    state.charging = false
  elseif state.charging and now - state.last_rise > charging_hold then
    state.charging = false
  end
  state.last = keyboard
  return state.charging
end

local function status(name, charge, charging, estimated)
  local now = os.date("%H:%M")
  if charge then
    last_seen[name] = { charge = charge, time = now }
    if charging then return charge .. "% · charging" .. (estimated and " (est.)" or "") end
    return charge .. "%"
  end
  local seen = last_seen[name]
  if seen then return "not connected · " .. seen.charge .. "% at " .. seen.time end
  return "not connected"
end

local function render(mouse, mouse_charging, keyboard)
  local mouse_label = mouse and (mouse .. "%") or "--"
  if mouse_charging then mouse_label = mouse_label .. icons.peripherals.charging end
  local keyboard_label = keyboard and (keyboard .. "%") or "--"
  local kb_charging = keyboard_charging(keyboard)
  if kb_charging then keyboard_label = keyboard_label .. icons.peripherals.charging end

  mouse_row:set({ label = { string = status("mouse", mouse, mouse_charging) } })
  keyboard_row:set({ label = { string = status("keyboard", keyboard, kb_charging, true) } })
  updated_row:set({ label = { string = os.date("%H:%M:%S") } })

  local lowest = mouse
  if keyboard and (not lowest or keyboard < lowest) then lowest = keyboard end

  peripherals:set({
    icon = { color = color_for(mouse) },
    label = {
      string = mouse_label .. "  " .. icons.peripherals.keyboard .. " " .. keyboard_label,
      color = lowest and lowest <= 20 and color_for(lowest) or colors.white,
    },
  })
end

local function update()
  sbar.exec(logi_battery, function(mouse_out)
    local pct, chg = (mouse_out or ""):match("(%d+) (%d)")
    local mouse = tonumber(pct)
    local mouse_charging = chg == "1"

    sbar.exec(ble_battery, function(ble_out)
      render(mouse, mouse_charging, find_keyboard(ble_out))
    end)
  end)
end

peripherals:subscribe({"routine", "forced", "system_woke"}, update)

peripherals:subscribe("mouse.clicked", function()
  local drawing = peripherals:query().popup.drawing
  peripherals:set({ popup = { drawing = "toggle" } })
  if drawing == "off" then update() end
end)

sbar.add("bracket", "widgets.peripherals.bracket", { peripherals.name }, {
  background = { color = colors.bg1 }
})

sbar.add("item", "widgets.peripherals.padding", {
  position = "right",
  width = settings.group_paddings
})
