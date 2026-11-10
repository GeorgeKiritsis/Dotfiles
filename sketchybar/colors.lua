-- Gruvbox Dark
return {
  black = 0xff1d2021,
  white = 0xffebdbb2,
  red = 0xfffb4934,
  green = 0xffb8bb26,
  blue = 0xff83a598,
  yellow = 0xfffabd2f,
  orange = 0xfffe8019,
  magenta = 0xffd3869b,
  aqua = 0xff8ec07c,
  grey = 0xff928374,
  transparent = 0x00000000,

  bar = {
    bg = 0x00000000,
    border = 0xff3c3836,
  },
  popup = {
    bg = 0xf0282828,
    border = 0xff504945
  },
  bg1 = 0xff282828,
  bg2 = 0xff3c3836,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
