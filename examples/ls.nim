import os, terminal, options

import ../src/lscolors
import ../src/lscolors/stdlibterm

when isMainModule:
  let lsc = parseLsColorsEnv()
  for kind, path in walkDir(getCurrentDir()):
    let style = lsc.styleForPath(path)
    stdout.styledWriteLine(style.getStyles(),
                           style.getForegroundColor().get(fgDefault),
                           style.getBackgroundColor().get(bgDefault),
                           path)
