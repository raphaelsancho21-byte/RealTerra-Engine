# RealTerra Engine

Free, open-source procedural terrain generator plugin for Roblox Studio on Windows.

## Install / update via CMD

Run these commands in CMD (one at a time):

```cmd
curl -fL -o "%TEMP%\realterra-install.ps1" https://raw.githubusercontent.com/raphaelsancho21-byte/RealTerra-Engine/main/installer/install.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\realterra-install.ps1"
```

Restart Roblox Studio, then click **RealTerra** in the Plugins toolbar.

The installer writes the local plugin to:
`%LOCALAPPDATA%\Roblox\Plugins\RealTerra.rbxmx`.

## Version 0.2.0

- Redesigned dark, green-accented dockable generator UI
- **Match Baseplate size** checkbox: matches a `BasePart` named `Baseplate` in Workspace (including nested descendants), using its X and Z dimensions and its center position
- Supports rectangular Baseplates, not just square maps
- Manual map-size entry disabled while Baseplate mode is active
- Seed, relief intensity and tree density controls
- Procedural voxel terrain and simple placeholder trees
- Progress and status messages
- Check-for-updates button (reads GitHub's `version.json`)

### How to use Baseplate matching

1. Place a `Part` named exactly **Baseplate** into Workspace.
2. Set its **Size** to your desired world dimensions.
3. Open RealTerra; check **Match Baseplate size**.
4. Click **Generate World**.

**Note:** Terrain is generated over/around the Baseplate; the Baseplate itself is not removed. Hide or remove the Baseplate after generation if necessary.

## Caveats

- This is still a preview: trees are placeholder Parts, not realistic meshes.
- Generation writes to `workspace.Terrain` and can overwrite existing terrain in its area. **Save or duplicate your place first.**
- **Remove Generated Props** only removes generated tree models, not terrain.
- Re-running generation after props cleanup writes terrain again. This does not automatically erase older terrain.
- Baseplate dimensions accepted: 8–4096 studs in X and Z. Large worlds may take substantial time and memory to generate.
- Plugins need HTTP permission to check updates.
- Updates are **not silently installed**. Run the installer again and restart Studio.
- The installer downloads plugin source directly from this repo. Review the script before executing it.
