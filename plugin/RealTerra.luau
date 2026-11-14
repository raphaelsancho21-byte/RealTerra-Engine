-- RealTerra Engine v0.4.1
-- Procedural voxel terrain, selective alpine snow, and varied forests.
local Terrain = workspace.Terrain
local HttpService = game:GetService("HttpService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local VERSION = "0.4.1"
local UPDATE_URL = "https://github.com/raphaelsancho21-byte/RealTerra-Engine#install--update-via-cmd"
local MANIFEST_URL = "https://raw.githubusercontent.com/raphaelsancho21-byte/RealTerra-Engine/main/version.json"
local INSTALL_CMD = 'curl -fL -o "%TEMP%\\realterra-install.ps1" https://raw.githubusercontent.com/raphaelsancho21-byte/RealTerra-Engine/main/installer/install.ps1 && powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\\realterra-install.ps1"'

local toolbar=plugin:CreateToolbar("RealTerra Engine")
local toggle=toolbar:CreateButton("RealTerra","Open RealTerra Engine","rbxassetid://4458901886")
toggle.ClickableWhenViewportHidden=true
local widget=plugin:CreateDockWidgetPluginGui("RealTerraEnginePanel", DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right,true,false,390,650,330,450))
widget.Title="RealTerra Engine | "..VERSION
toggle.Click:Connect(function()widget.Enabled=not widget.Enabled end)
local C={bg=Color3.fromRGB(17,24,22),panel=Color3.fromRGB(27,39,33),input=Color3.fromRGB(39,53,44),
green=Color3.fromRGB(98,201,128),white=Color3.fromRGB(235,247,237),muted=Color3.fromRGB(155,180,161),red=Color3.fromRGB(159,76,78)}
local scroll=Instance.new("ScrollingFrame")
scroll.Name="Content";scroll.Size=UDim2.fromScale(1,1);scroll.BackgroundColor3=C.bg;scroll.BorderSizePixel=0
scroll.ScrollBarThickness=5;scroll.ScrollBarImageColor3=C.green;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.CanvasSize=UDim2.new();scroll.Parent=widget
local pad=Instance.new("UIPadding");pad.PaddingTop=UDim.new(0,14);pad.PaddingBottom=UDim.new(0,20)
pad.PaddingLeft=UDim.new(0,15);pad.PaddingRight=UDim.new(0,15);pad.Parent=scroll
local stack=Instance.new("UIListLayout");stack.SortOrder=Enum.SortOrder.LayoutOrder
stack.Padding=UDim.new(0,8);stack.Parent=scroll
local function round(o) local v=Instance.new("UICorner");v.CornerRadius=UDim.new(0,7);v.Parent=o end
local function label(t,s,col,h,bold)
 local o=Instance.new("TextLabel");o.Size=UDim2.new(1,0,0,h or 24);o.BackgroundTransparency=1
 o.Text=t;o.TextWrapped=true;o.TextXAlignment=Enum.TextXAlignment.Left;o.TextYAlignment=Enum.TextYAlignment.Center
 o.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham;o.TextSize=s or 13;o.TextColor3=col or C.white
 o.Parent=scroll;return o
end
local function section(t,description)
 label(t,14,C.green,26,true)
 if description then label(description,12,C.muted,32) end
end
local function field(t,value)
 label(t,12,C.muted,19,true)
 local o=Instance.new("TextBox");o.Size=UDim2.new(1,0,0,38);o.BackgroundColor3=C.input
 o.Text=tostring(value);o.ClearTextOnFocus=false;o.BorderSizePixel=0
 o.TextSize=14;o.Font=Enum.Font.Gotham;o.TextColor3=C.white;o.Parent=scroll;round(o);return o
end
local function button(t,col)
 local o=Instance.new("TextButton");o.Size=UDim2.new(1,0,0,41);o.BackgroundColor3=col
 o.BorderSizePixel=0;o.Text=t;o.TextSize=14;o.Font=Enum.Font.GothamBold
 o.TextColor3=C.white;o.Parent=scroll;round(o);return o
end
local function check(t)
 local checked=false
 local o=button("  ☐  "..t,C.panel)
 o.TextXAlignment=Enum.TextXAlignment.Left;o.Font=Enum.Font.GothamMedium
 local function redraw()o.Text="  "..(checked and "☑" or "☐").."  "..t end
 o.MouseButton1Click:Connect(function()checked=not checked;redraw()end)
 return function()return checked end,o
end
label("REALTERRA  /  WORLD GENERATOR",18,C.white,33,true)
label("Smooth landscapes  •  Alpine peaks  •  Forests",12,C.muted,22)
section("01  WORLD","Optional Baseplate matching supports rectangular maps.")
local isBaseplate,baseCheck=check("Match Baseplate size")
local mapSize=field("Manual map size (128–1024 studs)",256)
local baseInfo=label("Manual mode: centered at origin",12,C.muted,20)
local function findBase()
 local b=workspace:FindFirstChild("Baseplate",true)
 if b and b:IsA("BasePart") then return b end
 return nil
end
baseCheck.MouseButton1Click:Connect(function()
 local b=findBase()
 if isBaseplate() and b then
  baseInfo.Text=string.format("Baseplate: %.0f × %.0f studs",b.Size.X,b.Size.Z)
 elseif isBaseplate() then baseInfo.Text="Baseplate not found in Workspace"
 else baseInfo.Text="Manual mode: centered at origin" end
 mapSize.TextEditable=not isBaseplate()
 mapSize.BackgroundColor3=isBaseplate() and C.panel or C.input
end)
local seedBox=field("World seed",48291)
local mountainBox=field("Mountain strength (8–140)",85)
local snowOn=check("Snow on tall mountain peaks")
section("02  FOREST","Trees scatter across grassy slopes, avoiding steep rock and snow.")
local densityBox=field("Forest density (0–100)",72)
section("03  GENERATION","Voxel resolution: 4 studs. Save your place before generating.")
local generate=button("GENERATE WORLD",C.green)
local remove=button("REMOVE GENERATED TREES",C.red)
local updates=button("CHECK FOR UPDATES",C.input)
local updateLink=button("OPEN UPDATE PAGE",C.panel)
local installBox=Instance.new("TextBox")
installBox.Size=UDim2.new(1,0,0,76);installBox.BackgroundColor3=C.input
installBox.Text=INSTALL_CMD;installBox.TextWrapped=true;installBox.MultiLine=true
installBox.ClearTextOnFocus=false;installBox.TextEditable=true
installBox.TextSize=11;installBox.Font=Enum.Font.Code;installBox.TextColor3=C.white
installBox.Visible=false;installBox.Parent=scroll;round(installBox)
local status=label("Ready to generate.",12,C.muted,66)
local running=false
local function getNumber(box,lo,hi)
 local n=tonumber(box.Text)
 if not n or n~=n then return nil end
 return math.clamp(math.floor(n),lo,hi)
end
local function smoothstep(edge0,edge1,value)
 local t=math.clamp((value-edge0)/(edge1-edge0),0,1)
 return t*t*(3-2*t)
end
local function heightAt(x,z,seed,mountain)
 -- Domain-warped, directional ridged multifractal terrain.
 -- Ridge lines and mountain ranges replace the rounded isolated domes.
 local k=(seed%9999)*.103
 local warpX=math.noise(x/360+k,z/360,k+11)*78
 local warpZ=math.noise(x/390+k,z/390,k+27)*78
 local px=x+warpX
 local pz=z+warpZ
 local lowland=math.noise(px/320,pz/320,k+42)*8
  +math.noise(px/125,pz/125,k+56)*3
 -- Rotated anisotropic ridge field: stretches crests into mountain chains.
 local u=px*.83+pz*.56
 local v=-px*.56+pz*.83
 local macro=math.noise(u/680,v/440,k+63)
 local rangeMask=.16+.84*smoothstep(-.25,.32,macro)
 local function ridge(a,b,offset)
  local n=math.noise(a,b,k+offset)
  local r=1-math.min(1,math.abs(n)*1.65)
  return r*r
 end
 local spine=ridge(u/285,v/105,79)
 local branches=ridge(u/135,v/64,91)
 local detail=ridge(u/62,v/35,108)
 local strata=(spine*.72+branches*.22+detail*.06)
 -- Offset keeps valleys clear; multiplying by mask organizes entire ranges.
 local uplift=mountain*1.65*rangeMask*math.max(0,strata-.18)^1.4
 local foothills=math.noise(px/190,pz/190,k+115)*mountain*.065
 return math.max(12,25+lowland+foothills+uplift)
end
local function surfaceMaterial(height,mountain,snow)
 -- Snow needs both a truly high summit and high mountain-strength setting.
 if snow and mountain>=90 and height>=28+mountain*.70 then return Enum.Material.Snow end
 if height>=28+mountain*.48 and mountain>=60 then return Enum.Material.Rock end
 if height<=22 then return Enum.Material.Ground end
 return Enum.Material.Grass
end
local function part(parent,name,shape,size,cf,color,material,collision)
 local o=Instance.new("Part")
 o.Name=name;o.Shape=shape;o.Size=size;o.CFrame=cf;o.Anchored=true
 o.Color=color;o.Material=material;o.CanCollide=collision;o.CastShadow=true
 o.TopSurface=Enum.SurfaceType.Smooth;o.BottomSurface=Enum.SurfaceType.Smooth
 o.Parent=parent;return o
end
local function createTree(folder,pos,rng,pine)
 local model=Instance.new("Model");model.Name=pine and "RT_Pine" or "RT_Oak";model.Parent=folder
 local height=pine and rng:NextNumber(24,38) or rng:NextNumber(17,28)
 local radius=pine and rng:NextNumber(5,7) or rng:NextNumber(6,9)
 local wood=Color3.fromRGB(91+rng:NextInteger(-8,8),70,49)
 local green=Color3.fromRGB(38+rng:NextInteger(-9,12),94+rng:NextInteger(-9,19),48+rng:NextInteger(-5,12))
 part(model,"Trunk",Enum.PartType.Cylinder,Vector3.new(height,2.4,2.4),
  CFrame.new(pos+Vector3.new(0,height*.5,0))*CFrame.Angles(0,0,math.rad(90)),
  wood,Enum.Material.Wood,true)
 if pine then
  for level=1,5 do
   local width=radius*(1.55-level*.17)
   part(model,"Pine Crown",Enum.PartType.Ball,Vector3.new(width*2,5.2,width*2),
    CFrame.new(pos+Vector3.new(0,height*(.35+level*.13),0)),green,Enum.Material.Grass,false)
  end
 else
  for n=1,5 do
   local angle=(n/5)*math.pi*2+rng:NextNumber(-.2,.2)
   local offset=Vector3.new(math.cos(angle)*radius*.4,rng:NextNumber(-1,3),math.sin(angle)*radius*.4)
   part(model,"Broadleaf Crown",Enum.PartType.Ball,Vector3.new(radius*1.6,radius*1.1,radius*1.6),
    CFrame.new(pos+Vector3.new(0,height*.79,0)+offset),green,Enum.Material.Grass,false)
  end
  part(model,"Top Crown",Enum.PartType.Ball,Vector3.new(radius*1.5,radius*1.25,radius*1.5),
   CFrame.new(pos+Vector3.new(0,height*.98,0)),green,Enum.Material.Grass,false)
 end
end
local function voxelWrite(width,depth,centerY,originX,originZ,seed,mountain,snow)
 local step=4
 -- Chunked WriteVoxels creates continuous slopes, unlike FillBlock columns.
 local minX=math.floor((originX-width/2)/4)*4
 local maxX=math.ceil((originX+width/2)/4)*4
 local minZ=math.floor((originZ-depth/2)/4)*4
 local maxZ=math.ceil((originZ+depth/2)/4)*4
 local bottom=math.floor((centerY-16)/4)*4
 local top=math.ceil((centerY+mountain*2.4+64)/4)*4
 local voxY=(top-bottom)/4
 local totalX=(maxX-minX)/4
 local totalZ=(maxZ-minZ)/4
 local chunk=24
 local done=0
 local chunkTotal=math.ceil(totalX/chunk)*math.ceil(totalZ/chunk)
 for startX=0,totalX-1,chunk do
  for startZ=0,totalZ-1,chunk do
   local nx=math.min(chunk,totalX-startX)
   local nz=math.min(chunk,totalZ-startZ)
   local materials,occupancy={},{}
   for xi=1,nx do
    materials[xi]={};occupancy[xi]={}
    local wx=minX+(startX+xi-.5)*4
    for yi=1,voxY do
     local matRow,occRow={},{}
     materials[xi][yi]=matRow;occupancy[xi][yi]=occRow
     local cellBottom=bottom+(yi-1)*4
     for zi=1,nz do
      local wz=minZ+(startZ+zi-.5)*4
      local inside=math.abs(wx-originX)<=width/2 and math.abs(wz-originZ)<=depth/2
      local h=centerY+heightAt(wx-originX,wz-originZ,seed,mountain)
      local fill=inside and math.clamp((h-cellBottom)/4,0,1) or 0
      occRow[zi]=fill
      matRow[zi]=fill>0 and surfaceMaterial(h-centerY,mountain,snow) or Enum.Material.Air
     end
    end
   end
   local r=Region3.new(Vector3.new(minX+startX*4,bottom,minZ+startZ*4),
    Vector3.new(minX+(startX+nx)*4,top,minZ+(startZ+nz)*4))
   Terrain:WriteVoxels(r,4,materials,occupancy)
   done+=1
   status.Text=string.format("Smoothing terrain: %d%%",math.floor(done/chunkTotal*100))
   task.wait()
  end
 end
end
generate.MouseButton1Click:Connect(function()
 if running then return end
 local seed=getNumber(seedBox,-2147483647,2147483647)
 local mountain=getNumber(mountainBox,8,140)
 local density=getNumber(densityBox,0,100)
 local size=getNumber(mapSize,128,1024)
 if not seed or not mountain or not density or (not isBaseplate() and not size) then
  status.Text="Invalid settings. Please enter numbers.";return
 end
 local base=isBaseplate() and findBase() or nil
 if isBaseplate() and not base then status.Text="Baseplate not found.";return end
 if base and math.abs(base.CFrame.UpVector:Dot(Vector3.yAxis))<.999 then
  status.Text="Tilted Baseplates not supported in voxel mode.";return
 end
 if base and (math.abs(base.CFrame.RightVector.X)<.999 or math.abs(base.CFrame.LookVector.Z)<.999) then
  status.Text="Rotated Baseplates are not supported in voxel mode.";return
 end
 local width=base and base.Size.X or size
 local depth=base and base.Size.Z or size
 if width<8 or depth<8 or width>2048 or depth>2048 then
  status.Text="World dimensions must be 8–2048 studs.";return
 end
 if workspace:FindFirstChild("RealTerra_Generated") then
  status.Text="Remove previous trees before generating again. Save first!";return
 end
 local x=base and base.Position.X or 0
 local z=base and base.Position.Z or 0
 local y=base and (base.Position.Y+base.Size.Y/2) or 0
 running=true;generate.Active=false
 task.spawn(function()
  local ok,err=pcall(function()
   ChangeHistoryService:SetWaypoint("Before RealTerra generation")
   local folder=Instance.new("Folder");folder.Name="RealTerra_Generated";folder.Parent=workspace
   voxelWrite(width,depth,y,x,z,seed,mountain,snowOn())
   local rng=Random.new(seed)
   local count=0
   local spacing=18
   for ix=0,math.floor(width/spacing)-1 do
    for iz=0,math.floor(depth/spacing)-1 do
     if count>=950 then break end
     local lx=-width/2+(ix+rng:NextNumber(.15,.85))*spacing
     local lz=-depth/2+(iz+rng:NextNumber(.15,.85))*spacing
     local h=heightAt(lx,lz,seed,mountain)
     local gradient=math.max(
      math.abs(heightAt(lx+4,lz,seed,mountain)-heightAt(lx-4,lz,seed,mountain))/8,
      math.abs(heightAt(lx,lz+4,seed,mountain)-heightAt(lx,lz-4,seed,mountain))/8
     )
     local forestNoise=math.noise((lx+seed%1000)/165,(lz+seed%1000)/165,9)
     local chance=density/100*math.clamp(.78+forestNoise*.60,.22,1.12)
     local ground=surfaceMaterial(h,mountain,snowOn())
     if ground==Enum.Material.Grass and gradient<.48 and rng:NextNumber()<chance then
      createTree(folder,Vector3.new(x+lx,y+h,z+lz),rng,rng:NextNumber()<.38)
      count+=1
     end
    end
    if ix%4==0 then
     status.Text="Planting forests: "..count.." trees"
     task.wait()
    end
   end
   folder:SetAttribute("Seed",seed)
   folder:SetAttribute("Version",VERSION)
   folder:SetAttribute("Width",width);folder:SetAttribute("Depth",depth)
   ChangeHistoryService:SetWaypoint("RealTerra generated")
   status.Text=string.format("Complete: %.0f × %.0f studs, %d trees.",width,depth,count)
  end)
  if not ok then status.Text="Error: "..tostring(err) end
  running=false;generate.Active=true
 end)
end)
remove.MouseButton1Click:Connect(function()
 if running then return end
 local folder=workspace:FindFirstChild("RealTerra_Generated")
 if not folder then status.Text="No generated trees found.";return end
 ChangeHistoryService:SetWaypoint("Before removal")
 folder:Destroy()
 ChangeHistoryService:SetWaypoint("RealTerra trees removed")
 status.Text="Trees removed. Terrain is preserved."
end)
local function versionParts(value)
 local a,b,c=value:match("^(%d+)%.(%d+)%.(%d+)$")
 if not a then return nil end
 return {tonumber(a),tonumber(b),tonumber(c)}
end
local function newerThan(a,b)
 local x,y=versionParts(a),versionParts(b)
 if not x or not y then return false end
 for i=1,3 do
  if x[i]~=y[i] then return x[i]>y[i] end
 end
 return false
end
local function openUpdatePage()
 installBox.Visible=true
 local ok=pcall(function()plugin:OpenWikiPage(UPDATE_URL)end)
 if not ok then status.Text="Copy the CMD command shown above to update." end
end
updateLink.MouseButton1Click:Connect(openUpdatePage)
updates.MouseButton1Click:Connect(function()
 status.Text="Checking published version..."
 task.spawn(function()
  local ok,body=pcall(function()return HttpService:GetAsync(MANIFEST_URL,true)end)
  if not ok then
   status.Text="GitHub check unavailable. Allow HTTP requests, or open the update page."
   installBox.Visible=true;return
  end
  local parsed,data=pcall(function()return HttpService:JSONDecode(body)end)
  if not parsed or type(data)~="table" or type(data.version)~="string" then
   status.Text="Invalid version manifest.";return
  end
  if newerThan(data.version,VERSION) then
   status.Text="Update v"..data.version.." found. Opening instructions; copy CMD command below."
   openUpdatePage()
  else
   status.Text="Up to date: v"..VERSION.."."
  end
 end)
end)
