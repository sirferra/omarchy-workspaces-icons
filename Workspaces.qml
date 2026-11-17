import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "sirferra.workspaces"

  // Hyprland class / app ID -> icon name from the installed desktop launchers.
  // Add an entry here if a window reports an unexpected class.
  readonly property var iconOverrides: ({
    "teams-for-linux": "teams-for-linux",
    "firefox": "firefox",
    "code": "vscode",
    "code-oss": "vscode",
    "com.microsoft.vscode": "vscode",
    "dbeaver": "dbeaver",
    "io.dbeaver.dbeaver": "dbeaver",
    "bruno": "bruno",
    "foot": "foot",
    "footclient": "foot",
    "org.gnome.nautilus": "org.gnome.Nautilus",
    "nautilus": "org.gnome.Nautilus"
  })

  readonly property int slots: 10
  readonly property var monitor: {
    var window = root.QsWindow.window
    var screen = window ? window.screen : null
    return screen ? Hyprland.monitorFor(screen) : Hyprland.focusedMonitor
  }
  readonly property string monitorName: root.monitor ? root.monitor.name : ""
  property var blocks: ({})

  FileView {
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/monitor-workspaces"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      var next = {}
      var lines = String(text() || "").split("\n")
      for (var i = 0; i < lines.length; i++) {
        var fields = lines[i].split("\t")
        if (fields.length >= 3 && fields[1] !== "") next[fields[1]] = parseInt(fields[0], 10)
      }
      root.blocks = next
    }
  }

  readonly property int block: {
    var assigned = root.blocks[root.monitorName]
    if (assigned !== undefined) return assigned
    var active = root.monitor && root.monitor.activeWorkspace ? root.monitor.activeWorkspace.id : 1
    return Math.floor((active - 1) / root.slots)
  }

  function blockOf(id) { return Math.floor((id - 1) / root.slots) }
  function slotOf(id) { return (id - 1) % root.slots + 1 }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  function workspaceIds() {
    var base = root.block * root.slots
    var ids = [base + 1, base + 2, base + 3, base + 4, base + 5]
    var guests = []
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id <= 0) continue
      if (root.blockOf(id) === root.block) {
        if (ids.indexOf(id) === -1) ids.push(id)
      } else if (values[i].monitor && values[i].monitor.name === root.monitorName) {
        guests.push(id)
      }
    }
    ids.sort(function(left, right) { return left - right })
    guests.sort(function(left, right) { return left - right })
    return ids.concat(guests)
  }

  function appIdFor(toplevel) {
    if (!toplevel) return ""
    if (toplevel.wayland && toplevel.wayland.appId) return String(toplevel.wayland.appId)
    var client = toplevel.lastIpcObject
    return client && client.class ? String(client.class) : ""
  }

  function iconFor(toplevel) {
    var appId = appIdFor(toplevel)
    var override = iconOverrides[appId.toLowerCase()]
    var entry = DesktopEntries.heuristicLookup(appId)
    var iconName = override || (entry && entry.icon ? String(entry.icon) : appId)
    var source = Quickshell.iconPath(iconName, true)
    return source || Quickshell.iconPath("application-x-executable", true)
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    var expression = root.blockOf(id) === root.block
      ? "o.workspaces.focus(" + root.slotOf(id) + ", \"" + root.monitorName + "\")"
      : "hl.dsp.focus({ workspace = \"" + id + "\" })"
    root.bar.run("hyprctl dispatch " + Util.shellQuote(expression))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)
  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        id: workspaceButton
        required property int modelData
        readonly property var workspace: root.workspaceById(modelData)
        readonly property var windows: workspace ? workspace.toplevels.values : []
        readonly property bool focused: root.monitor !== null && root.monitor.activeWorkspace !== null && root.monitor.activeWorkspace.id === modelData
        readonly property string firstAppIcon: windows.length > 0 ? root.iconFor(windows[0]) : ""
        readonly property string secondAppIcon: windows.length > 1 ? root.iconFor(windows[1]) : ""

        bar: root.bar
        text: windows.length === 0 ? (root.slotOf(modelData) === 10 ? "0" : String(root.slotOf(modelData))) : ""
        labelVisible: windows.length === 0
        hasVisualContent: text !== "" || firstAppIcon !== ""
        opacity: windows.length > 0 || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(windows.length > 0 ? 28 : 20)
        fixedHeight: root.barSize
        tooltipText: windows.length === 1 ? root.appIdFor(windows[0]) : (windows.length > 1 ? windows.length + " windows" : "Workspace " + modelData)
        onPressed: function() { root.focusWorkspace(modelData) }

        Image {
          anchors.centerIn: parent
          width: 24
          height: width
          source: parent.firstAppIcon
          visible: parent.windows.length === 1
          fillMode: Image.PreserveAspectFit
          sourceSize.width: Math.round(width * Screen.devicePixelRatio)
          sourceSize.height: Math.round(height * Screen.devicePixelRatio)
          smooth: true
        }

        Item {
          anchors.centerIn: parent
          width: 24
          height: 24
          visible: workspaceButton.windows.length > 1

          Item {
            anchors.left: parent.left
            width: 12
            height: parent.height
            clip: true

            Image {
              anchors.left: parent.left
              width: 24
              height: 24
              source: workspaceButton.firstAppIcon
              fillMode: Image.PreserveAspectFit
              sourceSize.width: Math.round(width * Screen.devicePixelRatio)
              sourceSize.height: Math.round(height * Screen.devicePixelRatio)
              smooth: true
            }
          }

          Item {
            anchors.right: parent.right
            width: 12
            height: parent.height
            clip: true

            Image {
              anchors.right: parent.right
              width: 24
              height: 24
              source: workspaceButton.secondAppIcon
              fillMode: Image.PreserveAspectFit
              sourceSize.width: Math.round(width * Screen.devicePixelRatio)
              sourceSize.height: Math.round(height * Screen.devicePixelRatio)
              smooth: true
            }
          }
        }

        Rectangle {
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 1
          width: numberLabel.implicitWidth + 6
          height: 14
          radius: 4
          color: Color.bar.background
          border.color: workspaceButton.foreground
          border.width: 1
          visible: workspaceButton.windows.length > 0

          Text {
            id: numberLabel
            anchors.centerIn: parent
            text: root.slotOf(workspaceButton.modelData) === 10 ? "0" : String(root.slotOf(workspaceButton.modelData))
            color: workspaceButton.foreground
            font.family: workspaceButton.fontFamily
            font.pixelSize: 10
            font.bold: true
            renderType: Text.NativeRendering
          }
        }

        Rectangle {
          anchors.bottom: parent.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          width: Style.space(8)
          height: Style.space(2)
          radius: height / 2
          color: parent.foreground
          visible: parent.focused
        }
      }
    }
  }
}
