# Workspaces con iconos para Omarchy

Widget para la barra de Omarchy que muestra el icono de la aplicación abierta en cada espacio de trabajo. Los espacios vacíos conservan su número. Si hay varias ventanas, muestra dos iconos partidos; los espacios ocupados también conservan un número pequeño. El espacio activo tiene una marca inferior.

Es la personalización `lean.workspaces` extraída de mi configuración de Omarchy. Se basa en el widget `omarchy.workspaces` y usa las mismas asignaciones de espacios de trabajo y monitores. Los iconos se buscan entre los launchers y el tema de iconos instalados en la PC; no se incluyen aplicaciones ni iconos en este repo.

## Instalar desde Git

Requiere Omarchy con `omarchy plugin add` (preparado con Omarchy 4.5.0-3). Con la sesión gráfica de Omarchy iniciada:

```bash
omarchy plugin add https://github.com/TU_USUARIO/omarchy-workspaces-icons.git --enable
```

Reemplaza automáticamente `omarchy.workspaces` en la barra gracias a `clonedFrom`. Si el widget estándar no estaba en la barra, se agrega a la sección izquierda.

Para instalarlo sin GitHub, copiá `manifest.json` y `Workspaces.qml` a `~/.config/omarchy/plugins/lean.workspaces/`, ejecutá `omarchy-shell shell rescanPlugins` y después `omarchy plugin enable lean.workspaces`.

## Personalizar iconos

Editá `iconOverrides` al comienzo de `Workspaces.qml` para asociar el `class` o `appId` de una ventana con un icono instalado. Omarchy recarga los plugins de usuario al guardar. Podés consultar la clase de la ventana activa con:

```bash
hyprctl activewindow -j | jq -r '.class'
```

## Quitar

```bash
omarchy plugin remove lean.workspaces
```

Omarchy restaura el widget estándar al quitar este clon.
