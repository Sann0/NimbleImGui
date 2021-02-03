import strutils, browsers
import nimgl/imgui
import globals, cmd

# converter flagToInt32(x: ImGuiWindowFlags): int32 = x.int32
# converter int32ToFlag(x: int32): ImGuiWindowFlags = x.ImGuiWindowFlags

const
  debugColor = ImVec4(y: 0.6, z: 1, w: 1)
  installedColor = ImVec4(y: 1, z: 0.2, w: 1)

proc uiLog* =
  var
    autoscroll {.global.}: bool = true
    debug {.global.}: bool

  if igButton("Clear"):
    Log.setLen(0)
    DebugLog.setLen(0)
  igSameLine()
  igCheckBox("Autoscroll", autoscroll.addr)
  igSameLine()
  igCheckBox("Nimble", debug.addr)
  igBeginChild("scrolling", flags=ImGuiWindowFlags.NoBackground)
  igPushStyleVar(ImguiStyleVar.ItemSpacing, ImVec2(x: 0, y: 1))
  if debug:
    for l in DebugLog:
      igTextColored(debugColor, l.strip())
  for l in Log:
    igTextColored(installedColor, l)
  if autoscroll:
    igSetScrollHereY(1.0)
  igPopStyleVar()
  igEndChild()

proc setAlpha*(v: float32) =
  var style = igGetStyle()
  for i, c in style.colors:
    var vec = ImVec4(x: c.x, y: c.y, z: c.z, w: v)
    style.colors[i] = vec

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
  igBeginChild("installed", flags = ImGuiWindowFlags.NoBackground)
  igSeparator()
  igColumns(2, "modulelist", true)
  igSetColumnWidth(0, 200)
  igText("Name")
  igNextColumn()
  igText("Version")
  igNextColumn()
  igSeparator()
  for i, m in Installed:
    if igSelectable(m.name, selected == i, flags = ImGuiSelectableFlags.SpanAllColumns):
      selected = i
      selectedMod = m
    if igIsItemHovered() and igGetCurrentContext().hoveredIdTimer > 0.6:
      igBeginTooltip()
      igTextUnformatted(m.descr)
      igEndTooltip()
    igNextColumn()
    igText(m.version)
    igNextColumn()
  igEndChild()

proc uiModules* =
  var
    filterTxt {.global.} = " "
    selected {.global.} = -1
    selectedMod {.global.}: Module
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
  igDummy(ImVec2(x: 200))
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
  igColumns(3, "moduleheader", true)
  igSetColumnWidth(0, 150)
  igText("Name")
  igNextColumn()
  igSetColumnWidth(1, 125)
  igText("License") 
  igNextColumn()
  igText("Description")
  igSeparator()
  igEndColumns()
  igBeginChild("modules", flags=ImGuiWindowFlags.NoBackground)
  igColumns(3, "modulelist", true)
  igSetColumnWidth(0, 142)
  igSetColumnWidth(1, 125)
  var filterStr = $filterTxt.cstring
  for i, m in Modules:
    var installed: bool
    if filterStr.toLower() notin m.name.toLower() and 
    filterStr.toLower() notin m.descr.toLower(): continue
    for im in Installed:
      if im.name == m.name:
        igPushStyleColor(ImGuiCol.Text, installedColor)
        installed = true
    if igSelectable(m.name, selected == i, flags = ImGuiSelectableFlags.SpanAllColumns):
      selected = i
      selectedMod = m
    igNextColumn()
    igText(m.license)
    igNextColumn()
    igTextWrapped(m.descr)
    igNextColumn()
    if installed:
      igPopStyleColor()
  igSeparator()
  igEndChild()