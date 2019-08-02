import unittest, options

import lscolors/style

test "parse empty":
  let style = parseStyle("")
  assert style.isNone

test "parse bold":
  let style = parseStyle("01")
  assert style.get.fg.isNone
  assert style.get.bg.isNone
  assert style.get.font == FontStyle(bold: true, italic: false, underline: false)

test "parse yellow":
  let style = parseStyle("33")
  assert style.get.fg.get.kind == ck8
  assert style.get.fg.get.ck8Val == c8Yellow
  assert style.get.bg.isNone
  assert style.get.font == defaultFontStyle()

test "parse some fixed color":
  let style = parseStyle("38;5;220;1")
  assert style.get.fg.get.kind == ckFixed
  assert style.get.fg.get.ckFixedVal == 220u8
  assert style.get.bg.isNone
  assert style.get.font == FontStyle(bold: true, italic: false, underline: false)

test "parse some rgb color":
  let style = parseStyle("38;2;123;123;123;1")
  assert style.get.fg.get.kind == ckRGB
  assert style.get.fg.get.ckRGBVal == (123u8, 123u8, 123u8)
  assert style.get.bg.isNone
  assert style.get.font == FontStyle(bold: true, italic: false, underline: false)

test "parse some malformed color":
  let style = parseStyle("38;2;123")
  assert style.isNone
