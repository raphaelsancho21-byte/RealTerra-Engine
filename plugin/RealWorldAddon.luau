
-- REALTERRA REAL WORLD ADDON v0.5.0
-- The installer appends this source to the core plugin as one Luau chunk.

-- Capture procedural controls before adding geographic controls.
-- This allows organizing the legacy generators into separate visual tabs.
local __coreControls = {}
for _,child in ipairs(scroll:GetChildren()) do
 __coreControls[child] = true
end
section("04  REAL EARTH  /  BETA","Pick a point on the holographic globe or enter coordinates.")
local worldCard=Instance.new("Frame")
worldCard.Name="EarthSelector";worldCard.Size=UDim2.new(1,0,0,260)
worldCard.BackgroundColor3=C.panel;worldCard.BorderSizePixel=0;worldCard.Parent=scroll;round(worldCard)
local viewport=Instance.new("ViewportFrame")
viewport.Size=UDim2.fromScale(1,1);viewport.BackgroundColor3=Color3.fromRGB(12,24,29)
viewport.BorderSizePixel=0;viewport.Ambient=Color3.fromRGB(125,160,175)
viewport.LightColor=Color3.fromRGB(160,255,210);viewport.LightDirection=Vector3.new(-1,-1,-1)
viewport.Parent=worldCard;round(viewport)
local wmodel=Instance.new("WorldModel");wmodel.Parent=viewport
local cam=Instance.new("Camera");cam.CFrame=CFrame.lookAt(Vector3.new(0,0,7),Vector3.zero)
cam.FieldOfView=42;cam.Parent=viewport;viewport.CurrentCamera=cam
local sphere=Instance.new("Part");sphere.Name="Ocean";sphere.Shape=Enum.PartType.Ball
sphere.Size=Vector3.new(5,5,5);sphere.Anchored=true
sphere.Material=Enum.Material.SmoothPlastic;sphere.Color=Color3.fromRGB(18,62,80)
sphere.Parent=wmodel
local earthMarkers={}
local yaw,pitch=0,0
local function globeVector(lat,lon)
 local a,b=math.rad(lat),math.rad(lon)
 return Vector3.new(math.cos(a)*math.sin(b), math.sin(a),math.cos(a)*math.cos(b))
end
local function dot(lat,lon,rad,color,size)
 local p=Instance.new("Part")
 p.Anchored=true;p.CanCollide=false;p.CanQuery=false
 p.Shape=Enum.PartType.Ball;p.Size=Vector3.one*(size or .025)
 p.Color=color;p.Material=Enum.Material.Neon
 p.Parent=wmodel
 table.insert(earthMarkers,{p=p,v=globeVector(lat,lon)*rad})
 return p
end
local gridColor=Color3.fromRGB(28,111,120)
for lat=-60,60,30 do
 for lon=-180,170,10 do dot(lat,lon,2.525,gridColor,.018) end
end
for lon=-180,150,30 do
 for lat=-80,80,10 do dot(lat,lon,2.53,gridColor,.018) end
end
local selectionDot=dot(-22.9068,-43.1729,2.59,C.green,.14)
local selectionEntry=earthMarkers[#earthMarkers]
local function redrawEarth()
 local rot=CFrame.Angles(pitch,yaw,0)
 for i,entry in ipairs(earthMarkers) do
  entry.p.Position=rot:PointToWorldSpace(entry.v)
 end
end
redrawEarth()
local selectButton=Instance.new("TextButton")
selectButton.Size=UDim2.fromScale(1,1);selectButton.BackgroundTransparency=1
selectButton.Text="";selectButton.AutoButtonColor=false;selectButton.Parent=viewport
local globeHint=Instance.new("TextLabel")
globeHint.Size=UDim2.new(1,-12,0,23);globeHint.Position=UDim2.new(0,8,1,-29)
globeHint.BackgroundTransparency=.25;globeHint.BackgroundColor3=C.bg
globeHint.TextColor3=C.white;globeHint.Font=Enum.Font.Gotham
globeHint.TextSize=11;globeHint.Text="Drag to rotate  •  Click to select";globeHint.Parent=viewport
local selectedLat,selectedLon=-22.9068,-43.1729
local latBox=field("Latitude (-85 to 85)",-22.9068)
local lonBox=field("Longitude (-180 to 180)",-43.1729)
local areaBox=field("Area width in meters (200–1600)",250)
local worldScale=field("Studs per meter (0.5–2)",1)
local coordinateInfo=label("Selected: Rio de Janeiro, Brazil",12,C.muted,23)
local function setCoordinates(lat,lon,description)
 lat=math.clamp(lat,-85,85);lon=((lon+180)%360)-180
 selectedLat,selectedLon=lat,lon
 latBox.Text=string.format("%.5f",lat)
 lonBox.Text=string.format("%.5f",lon)
 coordinateInfo.Text=description or string.format("Selected: %.5f, %.5f",lat,lon)
 selectionEntry.v=globeVector(lat,lon)*2.59
 redrawEarth()
end
local dragging=false
local moved=false
local lastMouse=nil
local UserInputService=game:GetService("UserInputService")
selectButton.InputBegan:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 then
  dragging=true;moved=false;lastMouse=input.Position
 end
end)
UserInputService.InputChanged:Connect(function(input)
 if not dragging or input.UserInputType~=Enum.UserInputType.MouseMovement then return end
 local delta=input.Position-lastMouse;lastMouse=input.Position
 if delta.Magnitude>1 then
  moved=true
  yaw+=delta.X*.009;pitch=math.clamp(pitch+delta.Y*.009,-1.25,1.25)
  redrawEarth()
 end
end)
UserInputService.InputEnded:Connect(function(input)
 if not dragging or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
 dragging=false
 if moved then return end
 local position=UserInputService:GetMouseLocation()
 local rect=viewport.AbsoluteSize;local top=viewport.AbsolutePosition
 if rect.X<5 or rect.Y<5 then return end
 local nx=(position.X-top.X)/rect.X*2-1
 local ny=(position.Y-top.Y)/rect.Y*2-1
 local tan=math.tan(math.rad(cam.FieldOfView/2))
 local dir=Vector3.new(nx*tan*(rect.X/rect.Y),-ny*tan,-1).Unit
 local origin=Vector3.new(0,0,7)
 local b=2*origin:Dot(dir)
 local c=origin:Dot(origin)-6.25
 local disc=b*b-4*c
 if disc<0 then return end
 local t=(-b-math.sqrt(disc))/2
 if t<=0 then return end
 local hit=(origin+dir*t).Unit
 local inverse=CFrame.Angles(pitch,yaw,0):Inverse()
 local localHit=inverse:VectorToWorldSpace(hit)
 local lat=math.deg(math.asin(math.clamp(localHit.Y,-1,1)))
 local lon=math.deg(math.atan2(localHit.X,localHit.Z))
 setCoordinates(lat,lon)
end)
-- Actual Natural Earth 110m land outline, downloaded only for globe preview.
task.spawn(function()
 local url="https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_land.geojson"
 local ok,response=pcall(function()return HttpService:GetAsync(url)end)
 if not ok then globeHint.Text="Globe grid only (allow GitHub HTTP for continents)";return end
 local decoded,geo=pcall(function()return HttpService:JSONDecode(response)end)
 if not decoded or type(geo)~="table" then return end
 local landColor=Color3.fromRGB(95,180,113)
 local added=0
 for _,feature in ipairs(geo.features or {}) do
  local shape=feature.geometry or {}
  local polys=shape.type=="Polygon" and {shape.coordinates} or shape.coordinates or {}
  for _,poly in ipairs(polys) do
   local outline=poly[1] or {}
   local stride=math.max(1,math.ceil(#outline/18))
   for i=1,#outline,stride do
    local c=outline[i]
    if type(c)=="table" and type(c[1])=="number" then
     dot(c[2],c[1],2.545,landColor,.044)
     added+=1
     if added%120==0 then task.wait() end
    end
    if added>=650 then break end
   end
   if added>=650 then break end
  end
  if added>=650 then break end
 end
 redrawEarth()
 globeHint.Text="Natural Earth coastlines • Drag / select"
end)
local presets={
 {name="Rio de Janeiro",lat=-22.9068,lon=-43.1729},
 {name="Sao Paulo",lat=-23.5505,lon=-46.6333},
 {name="New York",lat=40.7128,lon=-74.006},
 {name="Tokyo",lat=35.6762,lon=139.6503},
 {name="Mount Fuji",lat=35.3606,lon=138.7274},
}
local presetButton=button("CITY PRESET  /  RIO DE JANEIRO",C.input)
local presetIndex=0
presetButton.MouseButton1Click:Connect(function()
 presetIndex=presetIndex%#presets+1
 local p=presets[presetIndex]
 setCoordinates(p.lat,p.lon,p.name)
 presetButton.Text="CITY PRESET  /  "..string.upper(p.name)
end)
local realGenerate=button("IMPORT REAL TERRAIN + ROADS",C.green)
local attribution=label("Elevation: OpenTopoData • Roads: © OpenStreetMap contributors (ODbL) • Globe: Natural Earth",11,C.muted,48)
local function requestJson(url)
 local result=HttpService:RequestAsync({Url=url,Method="GET",Headers={Accept="application/json"}})
 if not result.Success then error("HTTP "..tostring(result.StatusCode).." from geography service") end
 return HttpService:JSONDecode(result.Body)
end
local function mercatorScaleLat(lat)
 return 111320
end
local function elevAt(heights,x,z)
 -- 9x9 bilinear elevation interpolation, coordinates normalized to 0..1.
 local u=math.clamp(x,0,1)*8;local v=math.clamp(z,0,1)*8
 local ix=math.min(8,math.floor(u)+1)
 local iz=math.min(8,math.floor(v)+1)
 local fx=u-(ix-1);local fz=v-(iz-1)
 local a=heights[iz][ix];local b=heights[iz][ix+1]
 local c=heights[iz+1][ix];local d=heights[iz+1][ix+1]
 return ((a*(1-fx)+b*fx)*(1-fz)+(c*(1-fx)+d*fx)*fz)
end
local function roadWidth(kind,scale)
 local widths={motorway=12,trunk=10,primary=10,secondary=8,tertiary=7,
 residential=6,unclassified=6,service=4,living_street=5,footway=2,path=2,cycleway=2}
 return (widths[kind] or 5)*scale
end
realGenerate.MouseButton1Click:Connect(function()
 if running then return end
 local lat=tonumber(latBox.Text);local lon=tonumber(lonBox.Text)
 local meters=tonumber(areaBox.Text);local scale=tonumber(worldScale.Text)
 if not lat or not lon or not meters or not scale or lat~=lat or lon~=lon
  or lat< -85 or lat>85 or lon< -180 or lon>180
  or meters<200 or meters>1600 or scale<.5 or scale>2 then
  status.Text="Invalid region coordinates, area or scale.";return
 end
 if meters*scale>1600 then
  status.Text="Area exceeds 1600 studs. Reduce map width or scale for Studio performance.";return
 end
 if workspace:FindFirstChild("RealTerra_RealWorld") then
  status.Text="A real-world import already exists. Remove or rename it before importing another.";return
 end
 local latSpan=meters/111320
 local lonSpan=meters/(111320*math.cos(math.rad(lat)))
 local south,north=lat-latSpan/2,lat+latSpan/2
 local west,east=lon-lonSpan/2,lon+lonSpan/2
 if west< -180 or east>180 then status.Text="Area crosses the dateline; choose another center.";return end
 running=true;realGenerate.Active=false
 task.spawn(function()
  local ok,err=pcall(function()
   status.Text="Step 1/3: fetching real elevation data..."
   local locations={}
   for row=0,8 do
    for col=0,8 do
     local a=south+(row/8)*(north-south)
     local b=west+(col/8)*(east-west)
     table.insert(locations,string.format("%.6f,%.6f",a,b))
    end
   end
   local topoUrl="https://api.opentopodata.org/v1/mapzen?locations="..HttpService:UrlEncode(table.concat(locations,"|")).."&interpolation=bilinear"
   local heights={};local topo=requestJson(topoUrl)
   if not topo.results or #topo.results~=81 then error("Elevation service returned incomplete data") end
   local minElevation=math.huge
   local num=0
   for row=1,9 do
    heights[row]={}
    for col=1,9 do
     num+=1
     local v=topo.results[num].elevation
     if type(v)~="number" then error("No elevation data for this region") end
     heights[row][col]=v
     minElevation=math.min(minElevation,v)
    end
   end
   status.Text="Step 2/3: fetching OpenStreetMap roads (network wait)..."
   local roads={}
   local roadsAvailable=false
   local query=string.format('[out:json][timeout:12];way["highway"](%0.6f,%0.6f,%0.6f,%0.6f);out geom;',south,west,north,east)
   local osmUrl="https://overpass-api.de/api/interpreter?data="..HttpService:UrlEncode(query)
   local roadsOk,roadsData=pcall(function()return requestJson(osmUrl)end)
   if roadsOk and type(roadsData.elements)=="table" then
    roads=roadsData.elements
    roadsAvailable=true
   else
    status.Text="Road service unavailable; generating measured terrain without roads."
   end
   ChangeHistoryService:SetWaypoint("Before RealTerra real world import")
   local folder=Instance.new("Folder");folder.Name="RealTerra_RealWorld"
   folder:SetAttribute("Latitude",lat);folder:SetAttribute("Longitude",lon)
   folder:SetAttribute("AreaMeters",meters);folder:SetAttribute("Scale",scale)
   folder:SetAttribute("ElevationSource","OpenTopoData mapzen")
   folder:SetAttribute("RoadSource","OpenStreetMap contributors, ODbL")
   folder.Parent=workspace
   local width=meters*scale
   local resolution=4
   local edge=math.ceil((width/2)/4)*4
   local dimension=math.ceil(edge*2/4)
   local minY=-16
   local maxRel=0
   for i=1,9 do for j=1,9 do
    maxRel=math.max(maxRel,heights[i][j]-minElevation)
   end end
   local elevationScale=.55*scale
   local cappedHeight=math.min(300,maxRel*elevationScale)
   local ymax=(math.ceil((cappedHeight+32)/4))*4
   local layers=(ymax-minY)/4
   local chunk=32
   local total=math.ceil(dimension/chunk)^2
   local done=0
   status.Text="Step 3/3: generating terrain voxels..."
   for cx=0,dimension-1,chunk do
    for cz=0,dimension-1,chunk do
     local nx=math.min(chunk,dimension-cx)
     local nz=math.min(chunk,dimension-cz)
     -- Sample elevation only once for each horizontal column, not once per Y voxel.
     local surface={}
     for xi=1,nx do
      surface[xi]={}
      local worldX=-edge+(cx+xi-.5)*4
      local uu=(worldX+width/2)/width
      for zi=1,nz do
       local worldZ=-edge+(cz+zi-.5)*4
       local vv=(worldZ+width/2)/width
       local active=math.abs(worldX)<=width/2 and math.abs(worldZ)<=width/2
       local h=active and math.min(300,math.max(2,(elevAt(heights,uu,vv)-minElevation)*elevationScale+4)) or -math.huge
       surface[xi][zi]=h
      end
     end
     local mats,occs={},{}
     for xi=1,nx do
      mats[xi]={};occs[xi]={}
      for yi=1,layers do
       local materialRow,occupancyRow={},{}
       mats[xi][yi]=materialRow;occs[xi][yi]=occupancyRow
       local cellBottom=minY+(yi-1)*4
       for zi=1,nz do
        local h=surface[xi][zi]
        local occupancy=math.clamp((h-cellBottom)/4,0,1)
        occupancyRow[zi]=occupancy
        materialRow[zi]=occupancy>0 and (h>110 and Enum.Material.Rock or Enum.Material.Grass) or Enum.Material.Air
       end
      end
     end
     local r=Region3.new(Vector3.new(-edge+cx*4,minY,-edge+cz*4),Vector3.new(-edge+(cx+nx)*4,ymax,-edge+(cz+nz)*4))
     Terrain:WriteVoxels(r,4,mats,occs)
     done+=1;status.Text=string.format("Step 3/3: terrain %d%%",math.floor(100*done/total))
     task.wait()
    end
   end
   status.Text="Placing mapped roads..."
   local roadFolder=Instance.new("Folder");roadFolder.Name="Roads";roadFolder.Parent=folder
   local segmentCount=0
   for _,way in ipairs(roads) do
    if way.type=="way" and type(way.geometry)=="table" then
     local kind=(way.tags and way.tags.highway) or ""
     if kind~="" then
      local geom=way.geometry
      for i=2,#geom do
       if segmentCount>=900 then break end
       local a,b=geom[i-1],geom[i]
       local function point(geo)
        local u=(geo.lon-west)/(east-west)
        local v=(geo.lat-south)/(north-south)
        local x=(u-.5)*width
        local z=(v-.5)*width
        local height=math.min(300,math.max(2,(elevAt(heights,u,v)-minElevation)*elevationScale+4))
        return Vector3.new(x,height+.65,z)
       end
       local p0,p1=point(a),point(b)
       local delta=p1-p0
       if delta.Magnitude>.3 and math.abs(p0.X)<=width/2 and math.abs(p0.Z)<=width/2
          and math.abs(p1.X)<=width/2 and math.abs(p1.Z)<=width/2 then
        local segment=Instance.new("Part")
        segment.Name="OSM_"..kind;segment.Anchored=true;segment.CanCollide=true
        segment.Material=Enum.Material.Asphalt
        segment.Color=Color3.fromRGB(53,58,59)
        segment.Size=Vector3.new(roadWidth(kind,scale),.55,delta.Magnitude)
        segment.CFrame=CFrame.lookAt((p0+p1)/2,p1)
        segment.Parent=roadFolder
        segmentCount+=1
        if segmentCount%80==0 then
         status.Text="Placing mapped roads: "..segmentCount.." segments"
         task.wait()
        end
       end
      end
     end
    end
    if segmentCount>=900 then break end
   end
   folder:SetAttribute("RoadSegments",segmentCount)
   ChangeHistoryService:SetWaypoint("RealTerra real world import")
   status.Text=string.format("Imported elevation + %d road segments (%.0fm). %s",segmentCount,meters,roadsAvailable and "No buildings." or "Road API unavailable.")
  end)
  if not ok then status.Text="Real-world import failed: "..tostring(err) end
  running=false;realGenerate.Active=true
 end)
end)


-- REALTERRA WORKSPACE UI V0.5
-- Roblox plugins must live in DockWidgetPluginGui rather than StarterGui.
-- The floating window can be dragged via the native Studio titlebar,
-- resized, and docked; tabs organize editing tools.
local shell=Instance.new("Frame")
shell.Name="RealTerraWorkspace"
shell.Size=UDim2.fromScale(1,1)
shell.BackgroundColor3=C.bg;shell.BorderSizePixel=0
shell.Parent=widget

local bar=Instance.new("Frame")
bar.Name="Header"
bar.Size=UDim2.new(1,0,0,64)
bar.BackgroundColor3=C.panel;bar.BorderSizePixel=0;bar.Parent=shell
local title=Instance.new("TextLabel")
title.Name="AppTitle"
title.Position=UDim2.new(0,18,0,9)
title.Size=UDim2.new(1,-36,0,26)
title.BackgroundTransparency=1;title.Text="◈  REALTERRA ENGINE"
title.TextColor3=C.white;title.TextXAlignment=Enum.TextXAlignment.Left
title.Font=Enum.Font.GothamBold;title.TextSize=19;title.Parent=bar
local subtitle=Instance.new("TextLabel")
subtitle.Size=UDim2.new(1,-36,0,18);subtitle.Position=UDim2.new(0,18,0,37)
subtitle.BackgroundTransparency=1;subtitle.Text="PROCEDURAL  /  REAL EARTH   •   V0.5.0"
subtitle.TextColor3=C.muted;subtitle.Font=Enum.Font.Gotham
subtitle.TextSize=10;subtitle.TextXAlignment=Enum.TextXAlignment.Left;subtitle.Parent=bar

local navigation=Instance.new("Frame")
navigation.Name="Tabs";navigation.Position=UDim2.new(0,0,0,64)
navigation.Size=UDim2.new(1,0,0,46)
navigation.BackgroundColor3=C.bg;navigation.BorderSizePixel=0
navigation.Parent=shell
local navPadding=Instance.new("UIPadding")
navPadding.PaddingLeft=UDim.new(0,12);navPadding.PaddingRight=UDim.new(0,12)
navPadding.PaddingTop=UDim.new(0,5);navPadding.PaddingBottom=UDim.new(0,5)
navPadding.Parent=navigation
local navLayout=Instance.new("UIListLayout")
navLayout.FillDirection=Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
navLayout.SortOrder=Enum.SortOrder.LayoutOrder;navLayout.Padding=UDim.new(0,7)
navLayout.Parent=navigation
local content=Instance.new("Frame")
content.Name="Pages";content.Position=UDim2.new(0,0,0,110)
content.Size=UDim2.new(1,0,1,-110);content.BackgroundTransparency=1
content.ClipsDescendants=true;content.Parent=shell

local function page(name)
 local frame=Instance.new("ScrollingFrame")
 frame.Name=name;frame.Size=UDim2.fromScale(1,1)
 frame.CanvasSize=UDim2.new();frame.AutomaticCanvasSize=Enum.AutomaticSize.Y
 frame.BackgroundColor3=C.bg;frame.BorderSizePixel=0
 frame.ScrollBarThickness=5;frame.ScrollBarImageColor3=C.green
 frame.ScrollingDirection=Enum.ScrollingDirection.Y
 frame.Visible=false;frame.Parent=content
 local padding=Instance.new("UIPadding")
 padding.PaddingTop=UDim.new(0,15);padding.PaddingBottom=UDim.new(0,24)
 padding.PaddingLeft=UDim.new(0,16);padding.PaddingRight=UDim.new(0,16)
 padding.Parent=frame
 local list=Instance.new("UIListLayout")
 list.SortOrder=Enum.SortOrder.LayoutOrder;list.Padding=UDim.new(0,9);list.Parent=frame
 return frame
end

-- Keep existing generator UI and event bindings intact.
scroll.Name="ProceduralPage"
scroll.Parent=content
scroll.Position=UDim2.new()
scroll.Size=UDim2.fromScale(1,1)
scroll.Visible=true
local realPage=page("RealEarthPage")
local settingsPage=page("UpdatesPage")

-- Detach and reparent only the direct UI controls created by the Real Earth addon.
-- We preserve original visual order because all controls use automatic insertion order.
local incoming={}
for _,child in ipairs(scroll:GetChildren()) do
 if not __coreControls[child] and child:IsA("GuiObject") then
  table.insert(incoming,child)
 end
end
for _,child in ipairs(incoming) do child.Parent=realPage end

-- Place update controls in their own tab, preserving the events on the objects.
local updateHeading=Instance.new("TextLabel")
updateHeading.Size=UDim2.new(1,0,0,32)
updateHeading.BackgroundTransparency=1
updateHeading.Text="UPDATES  /  VERSION CONTROL"
updateHeading.TextSize=15;updateHeading.Font=Enum.Font.GothamBold
updateHeading.TextColor3=C.green
updateHeading.TextXAlignment=Enum.TextXAlignment.Left
updateHeading.Parent=settingsPage
local info=Instance.new("TextLabel")
info.Size=UDim2.new(1,0,0,105)
info.BackgroundTransparency=1;info.TextWrapped=true
info.TextXAlignment=Enum.TextXAlignment.Left;info.TextYAlignment=Enum.TextYAlignment.Top
info.TextColor3=C.muted;info.TextSize=13;info.Font=Enum.Font.Gotham
info.Text="Installed: v0.5.0\n\nCheck GitHub for new releases, then install via CMD and restart Studio. Local Studio plugins cannot safely overwrite their own source."
info.Parent=settingsPage
updates.Parent=settingsPage
updateLink.Parent=settingsPage
installBox.Parent=settingsPage
local updateStatus=Instance.new("TextLabel")
updateStatus.Size=UDim2.new(1,0,0,48)
updateStatus.BackgroundTransparency=1;updateStatus.TextWrapped=true
updateStatus.Font=Enum.Font.Gotham;updateStatus.TextSize=12
updateStatus.TextColor3=C.muted;updateStatus.TextXAlignment=Enum.TextXAlignment.Left
updateStatus.Text="Update checks require HTTP permission. The install command appears after clicking Open Update Page."
updateStatus.Parent=settingsPage

-- Shared status is kept on the generation page; surface it in the header
-- so real-world imports and update checks remain visible on every tab.
local notification=Instance.new("TextLabel")
notification.Name="LiveStatus";notification.Size=UDim2.new(1,-28,0,48)
notification.Position=UDim2.new(0,14,1,-54)
notification.BackgroundColor3=C.panel;notification.BackgroundTransparency=.06
notification.BorderSizePixel=0;notification.TextWrapped=true
notification.TextColor3=C.white;notification.Font=Enum.Font.Gotham
notification.TextSize=11;notification.ZIndex=10;notification.Parent=shell
round(notification)
content.Size=UDim2.new(1,0,1,-164)
local function syncStatus()
 notification.Text="  "..status.Text
end
status:GetPropertyChangedSignal("Text"):Connect(syncStatus)
syncStatus()
local pages={scroll,realPage,settingsPage}
local labels={"GENERATOR","REAL EARTH","UPDATES"}
local buttons={}
local function selectTab(index)
 for i,p in ipairs(pages) do
  p.Visible=i==index
  local b=buttons[i]
  if b then
   b.BackgroundColor3=i==index and C.green or C.input
   b.TextColor3=i==index and C.bg or C.white
  end
 end
end
for i,labelText in ipairs(labels) do
 local b=Instance.new("TextButton")
 b.Name=labelText:gsub(" ","").."Tab"
 b.Size=UDim2.new(0,math.floor(116),1,0)
 b.BackgroundColor3=C.input;b.BorderSizePixel=0
 b.Text=labelText;b.TextSize=11
 b.Font=Enum.Font.GothamBold;b.TextColor3=C.white
 b.LayoutOrder=i;b.Parent=navigation;round(b)
 buttons[i]=b
 b.MouseButton1Click:Connect(function()selectTab(i)end)
end
selectTab(1)
