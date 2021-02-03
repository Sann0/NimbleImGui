import strutils, browsers
import globals, cmd
import nimgl/imgui

proc uiLog* =
  if igButton("Clear"):
    Log.setLen(0)
  for l in Log:
    igTextUnformatted(l)
  igSetScrollHereY(1.0)

proc setAlpha*(v: float32) = 
  for i, c in igGetStyle().colors:
    var vec = ImVec4(x: c.x, y: c.y, z: c.z, w: v)
    igGetStyle().colors[i] = vec

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
    style {.global.} = igStyleColorsDark
    transparency {.global.}: float32 = 0.9

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

  igSameLine()
  igText("Style:")
  igSameLine()  
  if igButton(if style == igStyleColorsDark: "Light" else: "Dark"):
    style = if style == igStyleColorsDark: igStyleColorsLight else: igStyleColorsDark
    style()
    setAlpha(transparency)
  igSameLine()
  igSetNextItemWidth(-1)
  if igSliderFloat("##Transparency", transparency.addr, 0.1, 1.0, format="Transparency: %.1f"):
    setAlpha(transparency)
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