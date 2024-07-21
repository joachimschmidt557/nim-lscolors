## This module contains procedures which help
## converting styles from lscolors to the terminal
## module from the nim standard library

import terminal, options

import style

proc getStyles*(s: style.Style): set[terminal.Style] =
  ## Get a set of styles from this style
  if s.font.bold:
    result.incl styleBright
  if s.font.italic:
    result.incl styleItalic
  if s.font.underline:
    result.incl styleUnderscore

proc getForegroundColor*(s: style.Style): Option[ForegroundColor] =
  ## Get the foreground color from this style
  if s.fg.isNone:
    return none ForegroundColor

  let color = s.fg.get
  case color.kind:
  of ck8:
    case color.ck8Val
    of c8Black: return some fgBlack
    of c8Red: return some fgRed
    of c8Green: return some fgGreen
    of c8Yellow: return some fgYellow
    of c8Blue: return some fgBlue
    of c8Magenta: return some fgMagenta
    of c8Cyan: return some fgCyan
    of c8White: return some fgWhite
  else:
    return none ForegroundColor

proc getBackgroundColor*(s: style.Style): Option[BackgroundColor] =
  ## Get the background color from this style
  if s.bg.isNone:
    return none BackgroundColor

  let color = s.bg.get
  case color.kind:
  of ck8:
    case color.ck8Val
    of c8Black: return some bgBlack
    of c8Red: return some bgRed
    of c8Green: return some bgGreen
    of c8Yellow: return some bgYellow
    of c8Blue: return some bgBlue
    of c8Magenta: return some bgMagenta
    of c8Cyan: return some bgCyan
    of c8White: return some bgWhite
  else:
    return none BackgroundColor
