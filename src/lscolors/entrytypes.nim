## This module handles the work which comes
## with types of filesystem entries, i.e. parsing
## them and extracting them from paths

import options, os, posix

type
  EntryType* = enum
    ## Represents an entry type
    etNormal,
    etRegularFile,
    etDirectory,
    etSymbolicLink,
    etFIFO,
    etSocket,
    etDoor,
    etBlockDevice,
    etCharacterDevice,
    etOrphanedSymbolicLink,
    etSetuid,
    etSetgid,
    etSticky,
    etOtherWritable,
    etStickyAndOtherWritable,
    etExecutableFile,
    etMissingFile,
    etCapabilities,
    etMultipleHardLinks,
    etLeftCode,
    etRightCode,
    etEndCode,
    etReset,
    etClearLine,

proc strToEntryType*(str: string): Option[EntryType] =
  ## Parses a string into an entry type if
  ## possible
  case str
  of "no": return some etNormal
  of "fi": return some etRegularFile
  of "di": return some etDirectory
  of "ln": return some etSymbolicLink
  of "pi": return some etFIFO
  of "so": return some etSocket
  of "do": return some etDoor
  of "bd": return some etBlockDevice
  of "cd": return some etCharacterDevice
  of "or": return some etOrphanedSymbolicLink
  of "su": return some etSetuid
  of "sg": return some etSetgid
  of "st": return some etSticky
  of "ow": return some etOtherWritable
  of "tw": return some etStickyAndOtherWritable
  of "ex": return some etExecutableFile
  of "mi": return some etMissingFile
  of "ca": return some etCapabilities
  of "mh": return some etMultipleHardLinks
  of "lc": return some etLeftCode
  of "rc": return some etRightCode
  of "ec": return some etEndCode
  of "rs": return some etReset
  of "cl": return some etClearLine
  else: return none EntryType

proc pathEntryType*(path: string): EntryType =
  ## Determines the entry type of this path
  var res: Stat
  if lstat(path, res) < 0:
    raise newException(OSError, "Error statting this file")

  if S_ISBLK(res.st_mode):
    return etBlockDevice

  if S_ISCHR(res.st_mode):
    return etCharacterDevice

  if S_ISDIR(res.st_mode):
    return etDirectory

  if S_ISFIFO(res.st_mode):
    return etFIFO

  if S_ISSOCK(res.st_mode):
    return etSocket

  if (res.st_mode.cint and S_ISUID) != 0'i32:
    return etSetuid

  if (res.st_mode.cint and S_ISGID) != 0'i32:
    return etSetgid

  if (res.st_mode.cint and S_ISVTX) != 0'i32:
    return etSticky

  if S_ISREG(res.st_mode):
    # Check if this file is executable
    if (res.st_mode.cint and S_IXUSR) != 0'i32:
      return etExecutableFile
    if (res.st_mode.cint and S_IXGRP) != 0'i32:
      return etExecutableFile
    if (res.st_mode.cint and S_IXOTH) != 0'i32:
      return etExecutableFile

    return etRegularFile

  if S_ISLNK(res.st_mode):
    # Check if the target exists
    var target = expandSymlink(path)
    if not target.isAbsolute:
      target = path.parentDir / target
    if stat(target, res) >= 0:
      return etSymbolicLink
    else:
      return etOrphanedSymbolicLink

  return etNormal
