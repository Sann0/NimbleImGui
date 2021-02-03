import ui, cmd, globals

import nimgl/[glfw, opengl, imgui]
import nimgl/imgui/[impl_opengl, impl_glfw]

converter flagToInt32(x: ImGuiWindowFlags): int32 = x.int32
converter int32ToFlag(x: int32): ImGuiWindowFlags = x.ImGuiWindowFlags

proc init =
  assert glfwInit()
  glfwWindowHint(GLFWDecorated, GLFWFalse)
  glfwWindowHint(GLFWResizable, GLFWFalse)
  glfwWindowHint(GLFWTransparentFramebuffer, GLFWTrue)
  glfwWindowHint(GLFWSamples, 5)
  GLFWWin = glfwCreateWindow(
    getVideoMode(glfwGetPrimaryMonitor()).width - 1,
    getVideoMode(glfwGetPrimaryMonitor()).height - 1,
    icon=false, title="Nimble ImGui"
  )
  GlfwWin.makeContextCurrent()
  assert glInit()
  igCreateContext()
  assert igGlfwInitForOpenGL(GLFWWin, true)
  assert igOpenGL3Init()
  igGetIO().iniFilename = "gui.ini"
  Modules = parseModules()
  Installed = parseInstalled()
  setAlpha(0.9)

proc uiLoop =
  var show = true
  igOpenGL3NewFrame()
  igGlfwNewFrame()
  igNewFrame()

  igBegin("Modules", show.addr)
  uiModules()
  igEnd()

  igBegin("Installed Modules")
  uiInstalledModules()
  igEnd()

  igBegin("Log")
  uiLog()
  igEnd()

  igRender()
  igOpenGL3RenderDrawData(igGetDrawData())
  if not show: 
    GLFWWin.setWindowShouldClose(true)

proc main =
  init()
  while not GLFWWin.windowShouldClose():
    glClear(GL_COLOR_BUFFER_BIT)
    glfwWaitEventsTimeout(0.05)
    uiLoop()

    if GLFWWin.getMouseButton(GLFWMouseButton.Button1) == 1 and not igGetIO().wantCaptureMouse:
      GLFWWin.iconifyWindow()

    GLFWWin.swapBuffers()
  

when isMainModule:
  main()