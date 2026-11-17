<img width="267" height="50" alt="imagen" src="https://github.com/user-attachments/assets/fc6c519e-1405-4a74-b4f0-90454ffe624d" />

# Workspace Icons for Omarchy

A widget for the Omarchy bar that shows the icon of the open application in each workspace. Empty workspaces keep their number. When a workspace has multiple windows, it shows two split icons; occupied workspaces also keep a small number. The active workspace has an indicator underneath.

This is the `sirferra.workspaces` customization from my Omarchy configuration. It is based on the `omarchy.workspaces` widget and uses the same workspace and monitor assignments. Icons are found among the desktop launchers and icon theme installed on your computer; this repository does not include any applications or icons.

## Install from Git

Requires an Omarchy version that supports `omarchy plugin add` (prepared with Omarchy 4.5.0-3). With an Omarchy graphical session running:

```bash
omarchy plugin add https://github.com/sirferra/omarchy-workspaces-icons.git --enable
```

It automatically replaces `omarchy.workspaces` in the bar through `clonedFrom`. If the standard widget was not in the bar, this one is added to the left section.

To install it without GitHub, copy `manifest.json` and `Workspaces.qml` to `~/.config/omarchy/plugins/sirferra.workspaces/`, run `omarchy-shell shell rescanPlugins`, and then run `omarchy plugin enable sirferra.workspaces`.

## Customize icons

Edit `iconOverrides` near the beginning of `Workspaces.qml` to map a window's `class` or `appId` to an installed icon. Omarchy reloads user plugins when you save the file. To check the class of the active window, run:

```bash
hyprctl activewindow -j | jq -r '.class'
```

## Remove

```bash
omarchy plugin remove sirferra.workspaces
```

Omarchy restores the standard widget when you remove this clone.

## License

MIT. See [LICENSE](LICENSE). Based on Omarchy's workspace widget; the original copyright notice is retained in the license.
