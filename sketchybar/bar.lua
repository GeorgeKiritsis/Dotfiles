local colors = require("colors")

-- Equivalent to the --bar domain
-- Transparent bar: every group draws its own pill ("islands")
sbar.bar({
  topmost = "window",
  height = 36,
  color = colors.bar.bg,
  margin = 10,
  y_offset = 6,
  padding_right = 4,
  padding_left = 4,
})
