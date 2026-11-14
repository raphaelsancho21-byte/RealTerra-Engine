
-- REALTERRA REAL WORLD ADDON v0.4.0
-- The installer appends this source to the core plugin as one Luau chunk.
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
 for lon=-180,175,5 do dot(lat,lon,2.525,gridColor,.018) end
end
for lon=-180,150,30 do
 for lat=-85,85,5 do dot(lat,lon,2.53,gridColor,.018) end
end
local selectionDot=dot(-22.9068,-43.1729,2.59,C.green,.14)
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
local areaBox=field("Area width in meters (200–1600)",800)
local worldScale=field("Studs per meter (0.5–2)",1)
local coordinateInfo=label("Selected: Rio de Janeiro, Brazil",12,C.muted,23)
local function setCoordinates(lat,lon,description)
 lat=math.clamp(lat,-85,85);lon=((lon+180)%360)-180
 selectedLat,selectedLon=lat,lon
 latBox.Text=string.format("%.5f",lat)
 lonBox.Text=string.format("%.5f",lon)
 coordinateInfo.Text=description or string.format("Selected: %.5f, %.5f",lat,lon)
 earthMarkers[#earthMarkers].v=globeVector(lat,lon)*2.59
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
   local stride=math.max(1,math.floor(#outline/45))
   for i=1,#outline,stride do
    local c=outline[i]
    if type(c)=="table" and type(c[1])=="number" then
     dot(c[2],c[1],2.545,landColor,.044)
     added+=1
     if added%150==0 then task.wait() end
    end
    if added>=2200 then break end
   end
   if added>=2200 then break end
  end
  if added>=2200 then break end
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
   status.Text="Downloading measured elevations..."
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
   status.Text="Downloading mapped streets..."
   local roads={}
   local query=string.format('[out:json][timeout:25];way["highway"](%0.6f,%0.6f,%0.6f,%0.6f);out geom;',south,west,north,east)
   local osmUrl="https://overpass.kumi.systems/api/interpreter?data="..HttpService:UrlEncode(query)
   local roadsOk,roadsData=pcall(function()return requestJson(osmUrl)end)
   if roadsOk and type(roadsData.elements)=="table" then
    roads=roadsData.elements
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
   local chunk=20
   local total=math.ceil(dimension/chunk)^2
   local done=0
   for cx=0,dimension-1,chunk do
    for cz=0,dimension-1,chunk do
     local nx=math.min(chunk,dimension-cx)
     local nz=math.min(chunk,dimension-cz)
     local mats,occs={},{}
     for xi=1,nx do
      mats[xi]={};occs[xi]={}
      local worldX=-edge+(cx+xi-.5)*4
      local uu=(worldX+width/2)/width
      for yi=1,layers do
       mats[xi][yi]={};occs[xi][yi]={}
       local ybottom=minY+(yi-1)*4
       for zi=1,nz do
        local worldZ=-edge+(cz+zi-.5)*4
        local vv=(worldZ+width/2)/width
        local active=math.abs(worldX)<=width/2 and math.abs(worldZ)<=width/2
        local elev=elevAt(heights,uu,vv)
        local height=math.min(300,math.max(2,(elev-minElevation)*elevationScale+4))
        local occ=active and math.clamp((height-ybottom)/4,0,1) or 0
        occs[xi][yi][zi]=occ
        mats[xi][yi][zi]=occ>0 and (height>110 and Enum.Material.Rock or Enum.Material.Grass) or Enum.Material.Air
       end
      end
     end
     local r=Region3.new(Vector3.new(-edge+cx*4,minY,-edge+cz*4),Vector3.new(-edge+(cx+nx)*4,ymax,-edge+(cz+nz)*4))
     Terrain:WriteVoxels(r,4,mats,occs)
     done+=1;status.Text=string.format("Building measured terrain: %d%%",math.floor(100*done/total))
     task.wait()
    end
   end
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
       end
      end
     end
    end
    if segmentCount>=900 then break end
   end
   folder:SetAttribute("RoadSegments",segmentCount)
   ChangeHistoryService:SetWaypoint("RealTerra real world import")
   status.Text=string.format("Imported REAL elevations and %d road segments. %.0fm area. No buildings.",segmentCount,meters)
  end)
  if not ok then status.Text="Real-world import failed: "..tostring(err) end
  running=false;realGenerate.Active=true
 end)
end)
