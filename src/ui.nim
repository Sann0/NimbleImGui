import strutils, browsers
import globals, cmd
import nimgl/imgui

proc uiLog* =
  if igButton("Clear"):
    Log.setLen(0)
  for l in Log:
    igTextUnformatted(l)
  igSetScrollHereY(1.0)

proc uiInstalledModules* =
  var
    selected {.global.} = -1
    selectedMod {.global.}: InstalledModule
  
  if igButton("Refresh"):
    Installed = parseInstalled()
  igSameLine()
  if igButton("Uninstall") and selected != -1:
    uninstallModule(selectedMod.name)
    Installed = parseInstalled()
  igSameLine()
  if igButton("Reinstall") and selected != -1:
    installModule(selectedMod.name)
    Installed = parseInstalled()

  igSeparator()
  igColumns(2, "modulelist", true)
  igSetColumnWidth(0, 130)
  igText("Name")
  igNextColumn()
  igSetColumnWidth(1, 130)
  igText("Version")
  igNextColumn()
  igSeparator()

  for i, m in Installed:
    if igSelectable(m.name, selected == i, flags = ImGuiSelectableFlags.SpanAllColumns):
      selected = i
      selectedMod = m
    igNextColumn()
    igText(m.version)
    igNextColumn()

proc uiModules* =
  var
    filterTxt {.global.} = " "
    selected {.global.} = -1
    selectedMod {.global.} : Module

  if igButton("Update"):
    updateModules()
    Modules = parseModules()
  igSameLine()
  if igButton("Install") and selected != -1:
    installModule(selectedMod.name)
    Installed = parseInstalled()
  igSameLine()
  if igButton("Website") and selected != -1:
    Log.add("Visiting " & selectedMod.url)
    openDefaultBrowser(selectedMod.url)
  igSetNextItemWidth(-1)
  igInputText("##Filter", filterTxt, 50)
  igSeparator()
  igColumns(3, "modulelist", true)
  igSetColumnWidth(0, 130)
  igText("Name")
  igNextColumn()
  igSetColumnWidth(1, 130)
  igText("License") 
  igNextColumn()
  igText("Description")
  igNextColumn()
  igSeparator()
  var filterStr = $filterTxt.cstring
  for i, m in Modules:
    if filterStr.toLower() notin m.name.toLower() and 
    filterStr.toLower() notin m.descr.toLower(): continue
    if igSelectable(m.name, selected == i, flags = ImGuiSelectableFlags.SpanAllColumns):
      selected = i
      selectedMod = m
    igNextColumn()
    igText(m.license)
    igNextColumn()
    igText(m.descr)
    igNextColumn()

proc nativeStyle* =
  let 
    style = igGetStyle()
    hSpacing = 8.0
    vSpacing = 6.0

  style.displaySafeAreaPadding = ImVec2(x: 0, y: 0)
  style.windowPadding = ImVec2(x: hSpacing / 2, y: vSpacing)
  style.framePadding = ImVec2(x: hSpacing, y: vSpacing)
  style.itemSpacing = ImVec2(x: hSpacing, y: vSpacing)
  style.itemInnerSpacing = ImVec2(x: hSpacing, y: vSpacing)
  style.indentSpacing = 20
  style.windowRounding = 0
  style.frameRounding = 0
  style.windowBorderSize = 0
  style.frameBorderSize = 1
  style.popupBorderSize = 1
  style.scrollbarSize = 20
  style.scrollbarRounding = 0
  style.grabMinSize = 5
  style.grabRounding = 0

  let
    white = ImVec4(x: 1, y: 1, z: 1, w: 1)
    dark = ImVec4(x: 0, y: 0, z: 0, w: 0.2)
    darker = ImVec4(x: 0, y: 0, z: 0, w: 0.5)
    background = ImVec4(x: 0.95, y: 0.95, z: 0.95, w: 1)
    text = ImVec4(x: 0.1, y: 0.1, z: 0.1, w: 1)
    border = ImVec4(x: 0.6, y: 0.6, z: 0.6, w: 1)
    grab = ImVec4(x: 0.69, y: 0.69, z: 0.69, w: 1)
    header = ImVec4(x: 0.86, y: 0.86, z: 0.86, w: 1)
    active = ImVec4(x: 0, y: 0.47, z: 0.84, w: 1)
    hover = ImVec4(x: 0, y: 0.47, z: 0.84, w: 1)

  style.colors[ImGuiCol.TitleBg.int32] = white
  style.colors[ImGuiCol.TitleBgActive.int32] = header
  style.colors[ImGuiCol.Text.int32] = text
  style.colors[ImGuiCol.WindowBg.int32] = background
  style.colors[ImGuiCol.ChildBg.int32] = background
  style.colors[ImGuiCol.PopupBg.int32] = white
  style.colors[ImGuiCol.Border.int32] = border
  style.colors[ImGuiCol.BorderShadow.int32] = white
  style.colors[ImGuiCol.Button.int32] = header
  style.colors[ImGuiCol.ButtonHovered.int32] = hover
  style.colors[ImguiCol.ButtonActive.int32] = active
  style.colors[ImguiCol.FrameBg.int32] = white
  style.colors[ImGuiCol.FrameBgHovered.int32] = hover
  style.colors[ImGuiCol.FrameBgActive.int32] = active
  style.colors[ImGuiCol.MenuBarBg.int32] = header
  style.colors[ImGuiCol.Header.int32] = header
  style.colors[ImGuiCol.HeaderHovered.int32] = hover
  style.colors[ImGuiCol.HeaderActive.int32] = active
  style.colors[ImGuiCol.CheckMark.int32] = text
  style.colors[ImGuiCol.SliderGrab.int32] = grab
  style.colors[ImGuiCol.SliderGrabActive.int32] = darker
  style.colors[ImGuiCol.ScrollbarBg.int32] = header
  style.colors[ImGuiCol.ScrollbarGrab.int32] = grab
  style.colors[ImGuiCol.ScrollbarGrabHovered.int32] = dark
  style.colors[ImGuiCol.ScrollbarGrabActive.int32] = darker
