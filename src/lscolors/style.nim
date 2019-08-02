## This module handles all the work associated
## with different styles and parsing them from
## the LS_COLORS string

import options, strutils, sequtils

type
  Color8* = enum
    ## A selection of the 8 terminal colors
    c8Black,
    c8Red,
    c8Green,
    c8Yellow,
    c8Blue,
    c8Magenta,
    c8Cyan,
    c8White,

  ColorFixed* = uint8 ## One color of the 256 terminal colors

  ColorRGB* = tuple[r:uint8, g:uint8, b:uint8] ## RBG colors

  ColorKind* = enum
    ## Three possible color descriptions
    ck8,
    ckFixed,
    ckRGB,
  Color* = object
    ## Represents a color of terminal text
    case kind*: ColorKind
    of ck8:
      ck8Val*: Color8
    of ckFixed:
      ckFixedVal*: ColorFixed
    of ckRGB:
      ckRGBVal*: ColorRGB

  FontStyle* = object
    ## Represents a font style
    bold*: bool
    italic*: bool
    underline*: bool

  Style* = object
    ## Represents a terminal output style
    fg*: Option[Color]
    bg*: Option[Color]
    font*: FontStyle

  ParseState = enum
    ## States of the finite automata parser
    psParse8,
    psParseFgNon8,
    psParseFg256,
    psParseFgRed,
    psParseFgGreen,
    psParseFgBlue,
    psParseBgNon8,
    psParseBg256,
    psParseBgRed,
    psParseBgGreen,
    psParseBgBlue,

proc defaultFontStyle*(): FontStyle =
  FontStyle(bold: false, italic: false, underline: false)

proc parseStyle*(str:string): Option[Style] =
  ## Parses the style description
  if str == "" or str == "0" or str == "00":
    return none Style

  var
    fg = none Color
    bg = none Color
    font = defaultFontStyle()

    state = psParse8
    red = 0u8
    green = 0u8

  # Run the finite automata-like parser
  for part in str.split(';').map(parseInt):
    case state:
    of psParse8:
      case part
      of 0: font = defaultFontStyle()
      of 1: font.bold = true
      of 3: font.italic = true
      of 4: font.underline = true
      of 30: fg = some Color(kind: ck8, ck8Val: c8Black)
      of 31: fg = some Color(kind: ck8, ck8Val: c8Red)
      of 32: fg = some Color(kind: ck8, ck8Val: c8Green)
      of 33: fg = some Color(kind: ck8, ck8Val: c8Yellow)
      of 34: fg = some Color(kind: ck8, ck8Val: c8Blue)
      of 35: fg = some Color(kind: ck8, ck8Val: c8Magenta)
      of 36: fg = some Color(kind: ck8, ck8Val: c8Cyan)
      of 37: fg = some Color(kind: ck8, ck8Val: c8White)
      of 38: state = psParseFgNon8
      of 39: fg = none Color
      of 40: bg = some Color(kind: ck8, ck8Val: c8Black)
      of 41: bg = some Color(kind: ck8, ck8Val: c8Red)
      of 42: bg = some Color(kind: ck8, ck8Val: c8Green)
      of 43: bg = some Color(kind: ck8, ck8Val: c8Yellow)
      of 44: bg = some Color(kind: ck8, ck8Val: c8Blue)
      of 45: bg = some Color(kind: ck8, ck8Val: c8Magenta)
      of 46: bg = some Color(kind: ck8, ck8Val: c8Cyan)
      of 47: bg = some Color(kind: ck8, ck8Val: c8White)
      of 48: discard # Todo
      of 49: bg = none Color
      else: break

    of psParseFgNon8:
      case part
      of 5: state = psParseFg256
      of 2: state = psParseFgRed
      else: return none Style
    of psParseFg256:
      fg = some Color(kind: ckFixed, ckFixedVal: uint8(part))
      state = psParse8
    of psParseFgRed:
      red = uint8(part)
      state = psParseFgGreen
    of psParseFgGreen:
      green = uint8(part)
      state = psParseFgBlue
    of psParseFgBlue:
      fg = some Color(kind: ckRGB, ckRGBVal: (red, green, uint8(part)))
      state = psParse8

    of psParseBgNon8:
      case part
      of 5: state = psParseBg256
      of 2: state = psParseBgRed
      else: return none Style
    of psParseBg256:
      bg = some Color(kind: ckFixed, ckFixedVal: uint8(part))
      state = psParse8
    of psParseBgRed:
      red = uint8(part)
      state = psParseBgGreen
    of psParseBgGreen:
      green = uint8(part)
      state = psParseBgBlue
    of psParseBgBlue:
      bg = some Color(kind: ckRGB, ckRGBVal: (red, green, uint8(part)))
      state = psParse8

  if state != psParse8: return none Style

  return some Style(fg: fg, bg: bg, font: font)
