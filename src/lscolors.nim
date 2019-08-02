## This is the main module of lscolors.
##
## Use it to parse a LS_COLORS string and then
## query the style which should be applied
## to a certain filesystem entry

import os, options, tables, strutils

import lscolors/[style, entrytypes]

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

proc parseLsColorsEnv*(): LsColors =
  ## Parses the LS_COLORS environment variable
  const
    envVar = "LS_COLORS"
  return parseLsColors(getEnv(envVar))

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
