import nimgl/glfw

type 
  Module* = object
    name*, url*, descr*, license*, website*: string

  InstalledModule* = object
    name*, version*: string

var
  Log*: seq[string]
  Modules*: seq[Module]
  Installed*: seq[InstalledModule]
  GLFWWin*: GLFWWindow