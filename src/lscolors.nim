## This is the main module of lscolors.
##
## Use it to parse a LS_COLORS string and then
## query the style which should be applied
## to a certain filesystem entry

import os, options, tables, strutils

import lscolors/[style, entrytypes]

const
  default = "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"
type
  Entry* = object
    ## Holds a path and its type
    path*:string
    typ*:EntryType

  RawRule = object
    ## Basically a string pair
    pattern:string
    color:string

  LsColors* = object
    ## Holds parsed LS_COLORS
    types*:TableRef[EntryType, Style]
    patterns*:seq[tuple[pattern:string, color:Style]]

proc rawParse(str: string): seq[RawRule] =
  for rule in str.split(':'):
    let splitted = rule.split('=')
    if splitted.len == 2:
      result.add(RawRule(pattern: splitted[0],
                         color: splitted[1]))

proc emptyLsColors*(): LsColors =
  ## Creates an empty LsColors object
  LsColors(types: newTable[EntryType, Style](),
           patterns: @[])

proc parseLsColors*(str: string): LsColors =
  ## Parse a LS_COLORS string
  result.types = newTable[EntryType, Style]()

  let raw = rawParse(str)
  for rule in raw:
    if (let style = rule.color.parseStyle; style.isSome):
      if (let entryType = rule.pattern.strToEntryType; entryType.isSome):
        result.types[entryType.get] = style.get
      else:
        result.patterns.add((rule.pattern, style.get))

proc defaultLsColors*(): LsColors =
  ## A set of default LS_COLORS
  return parseLsColors(default)

proc parseLsColorsEnv*(): LsColors =
  ## Parses the LS_COLORS environment variable.
  ## Defaults to `defaultLsColors` when no such
  ## environment variable exists
  const
    envVar = "LS_COLORS"
  if existsEnv(envVar):
    parseLsColors(getEnv(envVar))
  else:
    defaultLsColors()

proc pathMatchesPattern(path: string, pattern: string): bool =
  ## Returns true iff the path matches this pattern
  if path == "": return false
  if pattern == "": return false

  # We assume that LS_COLORS patterns are just
  # either exact file names or suffixes
  if pattern[0] == '*':
    return path.endsWith(pattern[1 .. pattern.high])
  else:
    return path == pattern

proc styleForDirEntry*(lsc:LsColors, entry:Entry): Style =
  ## Returns the style which should be used
  ## for this specific entry

  ## Pick style from type
  if entry.typ != etNormal and entry.typ != etRegularFile:
    return lsc.types[entry.typ]

  ## Pick style from path
  for pattern in lsc.patterns:
    if pathMatchesPattern(entry.path, pattern[0]):
      return pattern[1]

proc styleForPath*(lsc:LsColors, path:string): Style =
  ## Returns the style which should be used
  ## for this specific path
  styleForDirEntry(lsc, Entry(path: path, typ: path.pathEntryType()))
