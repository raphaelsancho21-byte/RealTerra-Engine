param([string]$Owner = "raphaelsancho21-byte", [string]$Repo = "RealTerra-Engine")
$ErrorActionPreference = "Stop"
$base = "https://raw.githubusercontent.com/$Owner/$Repo/main"
$core = (Invoke-WebRequest -Uri "$base/plugin/RealTerra.luau" -UseBasicParsing).Content
$realWorld = (Invoke-WebRequest -Uri "$base/plugin/RealWorldAddon.luau" -UseBasicParsing).Content
$source = $core + "`n" + $realWorld
if (-not $source -or $source -notmatch "RealTerra Engine") { throw "Invalid plugin source" }
if ($source.Contains("]]>")) { throw "Unsupported XML CDATA sequence" }
$xml = '<?xml version="1.0" encoding="utf-8"?>' + "`n" +
'<roblox version="4"><Item class="Script" referent="RBX0"><Properties><string name="Name">RealTerra Engine</string><ProtectedString name="Source"><![CDATA[' + $source + ']]></ProtectedString></Properties></Item></roblox>'
$folder = Join-Path $env:LOCALAPPDATA "Roblox\Plugins"
New-Item -ItemType Directory -Path $folder -Force | Out-Null
$target = Join-Path $folder "RealTerra.rbxmx"
$tmp = "$target.tmp"
[System.IO.File]::WriteAllText($tmp,$xml,[System.Text.UTF8Encoding]::new($false))
if (Test-Path $target) { Copy-Item $target "$target.bak" -Force }
Move-Item -Path $tmp -Destination $target -Force
Write-Host "RealTerra installed to $target" -ForegroundColor Green
Write-Host "Restart Roblox Studio to load the plugin."