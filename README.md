# RealTerra Engine

Open-source terrain generator for Roblox Studio on Windows.

## Install / update via CMD

Run these two commands in Windows CMD, then restart Roblox Studio:

```cmd
curl -fL -o "%TEMP%\realterra-install.ps1" https://raw.githubusercontent.com/raphaelsancho21-byte/RealTerra-Engine/main/installer/install.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\realterra-install.ps1"
```

The installer downloads and assembles both Luau source files into the local plugin at:
`%LOCALAPPDATA%\Roblox\Plugins\RealTerra.rbxmx`

## v0.4.1 - Real Earth beta (performance update)

A new Real Earth section appears in the RealTerra sidebar. It contains:

- 3D holographic globe in a ViewportFrame. Mouse-drag to rotate it and click to choose a location.
- Land outlines fetched from **Natural Earth 110m**; the globe grid remains usable without outline access.
- Latitude and longitude entry, with a quick city-preset cycling button.
- Selected area width: **200–1600 meters** (default **250m**, start small), scale: **0.5–2 Roblox studs per meter**.
- Real elevation samples from the **OpenTopoData Mapzen** global dataset (9×9 points, interpolated into Roblox terrain).
- Street and path geometry from **OpenStreetMap** via the public Overpass API, drawn as asphalt Parts following the sampled terrain.
- **No buildings**; city data only includes elevation and roads.
- Original procedural terrain generator remains available.

### How to use

1. Open RealTerra from Roblox Studio Plugins toolbar.
2. Scroll down to **04 REAL EARTH / BETA**.
3. Rotate and click the globe, choose a preset, or type coordinates.
4. Pick area width and scale. Start with **250m** to limit generation time.
5. Click **IMPORT REAL TERRAIN + ROADS**.
6. Grant the requested HTTP permissions in the plugin dialog when prompted.

### Data sources and credits

- Coastlines: [Natural Earth](https://www.naturalearthdata.com/), public-domain land polygons.
- Elevation: [OpenTopoData](https://www.opentopodata.org/), Mapzen elevation dataset, subject to dataset limitations.
- Road geometry: **© OpenStreetMap contributors**, licensed under [ODbL](https://www.openstreetmap.org/copyright). Provide appropriate attribution in games featuring imported OSM roads.

### Limitations and warnings

- **Experimental / untested in a live Studio environment.** Public web API availability can vary.
- Real geography is sampled and interpolated: 9×9 elevation points cannot reproduce fine ground detail. Relative relief is scaled and elevations beyond 300 studs are capped for performance. This is a geographic approximation, not a survey-grade reconstruction.
- Roads are straight line segments along mapped ways. Intersections, bridges, tunnels, sidewalks and complex road grading are not handled yet.
- If the Overpass API is unavailable, elevation-only terrain may be generated. The status message explains that streets were omitted.
- Imported terrain is written at the origin in this first version and **can overwrite existing Terrain** in the area. Back up your place or use a fresh project.
- The importer limits roads to **900 segments** and expects small regions.
- Don't import huge areas repeatedly: OpenTopoData's free API has usage limits (100 points per request, one call per second, 1000 calls/day).
- Real Earth imports create a \`RealTerra_RealWorld\` folder containing road parts and metadata. The terrain voxels are not removed automatically if you delete this folder.
- The globe requires HTTP permission to GitHub for coastline outlines; the elevation and road imports require HTTP permission to their respective services.
- Local Studio plugins cannot auto-replace themselves. Use CMD to install updates, then restart Studio.

## Procedural generator

The existing procedural tool still supports terrain seeds, Baseplate size matching, mountain generation with optional snow, varied trees and density controls.


### Performance changes in v0.4.1

- Terrain height sampled once per X/Z voxel column, rather than in every vertical layer.
- Voxel chunks increased to 32×32 for fewer engine calls.
- Fewer globe markers and less geometry overhead.
- Progress messages separate elevation download, OpenStreetMap download, voxel writing and road placement.
- Default real-world import area reduced to 250m.

The public Overpass and elevation services can still be slow or unavailable. Start in a blank Studio place and use a small area.
