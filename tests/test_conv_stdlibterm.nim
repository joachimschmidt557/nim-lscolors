import unittest, terminal, options

import lscolors
import lscolors/[style, stdlibterm]

test "get empty style":
  let style = style.Style(font: style.defaultFontStyle(),
                          fg: none style.Color,
                          bg: none style.Color)
  assert style.getStyles == {}

test "get style":
  let style = style.Style(font: style.FontStyle(bold: true,
                                                italic: false,
                                                underline: true),
                          fg: none style.Color,
                          bg: none style.Color)
  assert style.getStyles == {styleBright, styleUnderscore}

test "get foreground color":
  let style = style.Style(font: style.defaultFontStyle(),
                          fg: some style.Color(kind: ck8, ck8Val: c8Blue),
                          bg: none style.Color)
  assert style.getForegroundColor.get == fgBlue

test "get background color":
  let style = style.Style(font: style.defaultFontStyle(),
                          fg: none style.Color,
                          bg: some style.Color(kind: ck8, ck8Val: c8Green))
  assert style.getBackgroundColor.get == bgGreen
