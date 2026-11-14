# RealTerra Engine
A free open-source procedural terrain generator plugin for Roblox Studio (Windows).

## Install via CMD
```cmd
curl -fL -o "%TEMP%\realterra-install.ps1" https://raw.githubusercontent.com/raphaelsancho21-byte/RealTerra-Engine/main/installer/install.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\realterra-install.ps1"
```

The installer places the local plugin at `%LOCALAPPDATA%\Roblox\Plugins\RealTerra.rbxmx`. Restart Roblox Studio, then open the RealTerra toolbar.

## Features (v0.1.0 preview)
- Dockable generator panel
- Seeded terrain with 3-layer coherent noise
- Adjustable map size, mountain height, tree density
- Simple placeholder trees
- Version check from GitHub (`version.json`)
- Manual update: rerun the installation command to install a newly published version

## Important limitations
- This is a prototype: trees are basic Parts, not detailed realistic meshes.
- Generation modifies `workspace.Terrain`. Use a new place or save a backup first.
- Remove Generated Props removes trees only, not terrain.
- Requires the Roblox Studio plugin to be allowed to make HTTP requests for update notifications.
- Review the installer script before executing it; it downloads public source from this repo.
