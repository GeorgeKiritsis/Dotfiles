local colors = require("colors")
local settings = require("settings")

-- wttr.in resolves the location from the IP; set e.g. "Athens" to pin it
local location = ""
local popup_width = 250

-- wttr.in weather codes -> Material Design weather glyphs
local function condition(code, night)
  code = tonumber(code) or 0
  local groups = {
    { codes = { 113 }, icon = night and "\u{F0594}" or "\u{F0599}", color = night and colors.blue or colors.yellow },
    { codes = { 116 }, icon = night and "\u{F0F31}" or "\u{F0595}", color = colors.white },
    { codes = { 119, 122 }, icon = "\u{F0590}", color = colors.grey },
    { codes = { 143, 248, 260 }, icon = "\u{F0591}", color = colors.grey },
    { codes = { 200, 386, 389, 392, 395 }, icon = "\u{F067E}", color = colors.yellow },
    { codes = { 299, 302, 305, 308, 356, 359 }, icon = "\u{F0596}", color = colors.blue },
    { codes = { 179, 227, 230, 323, 326, 329, 332, 335, 338, 368, 371 }, icon = "\u{F0598}", color = colors.white },
    { codes = { 182, 185, 281, 284, 311, 314, 317, 320, 350, 362, 365, 374, 377 }, icon = "\u{F067F}", color = colors.aqua },
  }
  for _, g in ipairs(groups) do
    for _, c in ipairs(g.codes) do
      if c == code then return g.icon, g.color end
    end
  end
  -- everything else in wttr.in's table is some kind of light rain/drizzle
  return "\u{F0597}", colors.blue
end

-- "05:22 PM" -> minutes since midnight
local function minutes(t)
  local h, m, ampm = t:match("(%d+):(%d+) (%a+)")
  if not h then return nil end
  h = tonumber(h) % 12 + (ampm == "PM" and 12 or 0)
  return h * 60 + tonumber(m)
end

local weather = sbar.add("item", "widgets.weather", {
  position = "right",
  update_freq = 900,
  icon = {
    string = "\u{F0599}",
    color = colors.grey,
    font = { size = 15.0 },
  },
  label = {
    string = "??°",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 12.0,
    },
  },
  padding_right = settings.paddings + 6,
  popup = { align = "center", height = 26 },
})

sbar.add("bracket", "widgets.weather.bracket", { weather.name }, {
  background = { color = colors.bg1 }
})

sbar.add("item", "widgets.weather.padding", {
  position = "right",
  width = settings.group_paddings
})

local header = sbar.add("item", {
  position = "popup." .. weather.name,
  width = popup_width,
  align = "center",
  icon = { drawing = false },
  label = {
    string = "????",
    font = { size = 15, style = settings.font.style_map["Bold"] },
  },
  background = { height = 2, color = colors.grey, y_offset = -13 },
})

local function row(name)
  return sbar.add("item", {
    position = "popup." .. weather.name,
    icon = { align = "left", string = name, width = popup_width / 2 },
    label = { align = "right", string = "??", width = popup_width / 2 },
  })
end

local desc = row("Now:")
local feels = row("Feels like:")
local humidity = row("Humidity:")
local wind = row("Wind:")
local sun = row("Sun:")

-- Next few 3-hour slots
local slots = {}
for i = 1, 4 do
  slots[i] = sbar.add("item", {
    position = "popup." .. weather.name,
    icon = { align = "left", string = "--:--", width = popup_width / 3 },
    label = { align = "right", string = "??", width = popup_width * 2 / 3 },
  })
end

local function update()
  local url = "https://wttr.in/" .. location .. "?format=j1"
  sbar.exec("curl -sf --max-time 10 '" .. url .. "'", function(data)
    if type(data) ~= "table" or not data.current_condition then return end
    local now = data.current_condition[1]
    local today = data.weather[1]
    local astro = today.astronomy[1]

    local t = os.date("*t")
    local now_min = t.hour * 60 + t.min
    local rise, set = minutes(astro.sunrise), minutes(astro.sunset)
    local night = rise and set and (now_min < rise or now_min > set)

    local icon, color = condition(now.weatherCode, night)
    weather:set({
      icon = { string = icon, color = color },
      label = { string = now.temp_C .. "°" },
    })

    local area = data.nearest_area[1]
    header:set({ label = area.areaName[1].value .. ", " .. area.country[1].value })
    desc:set({ label = now.weatherDesc[1].value })
    feels:set({ label = now.FeelsLikeC .. "°C" })
    humidity:set({ label = now.humidity .. "%" })
    wind:set({ label = now.windspeedKmph .. " km/h " .. now.winddir16Point })
    sun:set({ label = astro.sunrise .. " / " .. astro.sunset })

    -- Collect upcoming slots from today and tomorrow
    local upcoming = {}
    for d = 1, 2 do
      for _, h in ipairs(data.weather[d].hourly) do
        local hour = tonumber(h.time) // 100
        if d == 2 or hour * 60 > now_min then
          upcoming[#upcoming + 1] = { hour = hour, h = h }
        end
      end
    end
    for i, slot in ipairs(slots) do
      local u = upcoming[i]
      if u then
        local s_icon, s_color = condition(u.h.weatherCode, u.hour < 7 or u.hour > 18)
        slot:set({
          icon = { string = string.format("%02d:00", u.hour) },
          label = {
            string = s_icon .. "  " .. u.h.tempC .. "°  " .. u.h.chanceofrain .. "% rain",
            color = s_color,
          },
        })
      end
    end
  end)
end

weather:subscribe({ "routine", "forced", "system_woke" }, update)

weather:subscribe("mouse.clicked", function(env)
  weather:set({ popup = { drawing = "toggle" } })
end)

weather:subscribe("mouse.exited.global", function(env)
  weather:set({ popup = { drawing = false } })
end)
