# RealTerra Engine

Open-source Roblox Studio terrain generation plugin for Windows.

## Install / update via CMD

Run in Windows CMD:

\`\`\`cmd
curl -fL -o "%TEMP%\realterra-install.ps1" https://raw.githubusercontent.com/raphaelsancho21-byte/RealTerra-Engine/main/installer/install.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\realterra-install.ps1"
\`\`\`

Restart Roblox Studio. The local plugin is written to \`%LOCALAPPDATA%\Roblox\Plugins\RealTerra.rbxmx\`.

## RealTerra Engine v0.3.0

- Smoother **4-stud voxel** terrain via chunked \`Terrain:WriteVoxels\`, replacing the original block-column terrain.
- Procedural rolling hills and mountain peaks.
- **Snow on tall mountain peaks** (checkbox). Snow is only enabled with Mountain strength >= 90 and elevations above the alpine threshold; smaller hills stay green or rocky.
- More detailed procedural tree models: broadleaf trees and conifers with varied sizes and crown shapes.
- Trees distributed across the whole generated grassy area using seeded jitter and forest-density noise; steep slopes, rock and snow avoided.
- **Match Baseplate size** checkbox uses the X/Z dimensions of a BasePart named \`Baseplate\`. Axis-aligned Baseplates supported.
- Seed, mountain intensity, tree density and generation status controls.
- **Check for Updates** checks the version manifest and opens update instructions if a new version is published. **Open Update Page** opens the GitHub page and reveals a copyable CMD command within the plugin.

### Important limitations

- Local Studio plugins **cannot silently self-replace their installed .rbxmx file** with a supported public API. To install an update, use the CMD command and restart Studio. The button makes the update procedure visible and accessible; it does not silently install.
- Save or duplicate your place before generation: the tool **overwrites voxel terrain inside the generation region**.
- **Remove Generated Trees** does not undo terrain generation. Use Studio undo or a saved backup if needed.
- The Baseplate itself is not removed.
- Rotated or tilted Baseplates are refused in this version (terrain voxels are world-axis-aligned). Baseplates must be 8–2048 studs in X and Z.
- Very large maps can take substantial time, RAM and Studio memory.
- Trees are procedural Parts, not imported realistic 3D mesh models.
- Plugin HTTP access may require permission to check updates.
- Review the public installer before running it.
