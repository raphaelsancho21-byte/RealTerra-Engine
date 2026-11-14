-- RealTerra Engine v0.2.0 | Studio local plugin
local Terrain = workspace.Terrain
local HttpService = game:GetService("HttpService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local VERSION = "0.2.0"
local toolbar = plugin:CreateToolbar("RealTerra Engine")
local toggle = toolbar:CreateButton("RealTerra", "Open the RealTerra world generator", "rbxassetid://4458901886")
toggle.ClickableWhenViewportHidden = true
local widget = plugin:CreateDockWidgetPluginGui("RealTerraEnginePanel", DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, true, false, 390, 620, 330, 450))
widget.Title = "RealTerra Engine | " .. VERSION
toggle.Click:Connect(function() widget.Enabled = not widget.Enabled end)

local COLORS = {
 bg=Color3.fromRGB(17,24,22), panel=Color3.fromRGB(26,37,32),
 input=Color3.fromRGB(38,53,45), border=Color3.fromRGB(58,79,65),
 main=Color3.fromRGB(91,194,120), text=Color3.fromRGB(233,246,236),
 muted=Color3.fromRGB(153,177,160), danger=Color3.fromRGB(154,78,77)
}
local scroll=Instance.new("ScrollingFrame")
scroll.Name="Content";scroll.BackgroundColor3=COLORS.bg;scroll.BorderSizePixel=0
scroll.Size=UDim2.fromScale(1,1);scroll.CanvasSize=UDim2.new()
scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.ScrollBarThickness=5
scroll.ScrollBarImageColor3=COLORS.main;scroll.Parent=widget
local pad=Instance.new("UIPadding")
pad.PaddingTop=UDim.new(0,15);pad.PaddingBottom=UDim.new(0,20)
pad.PaddingLeft=UDim.new(0,16);pad.PaddingRight=UDim.new(0,16);pad.Parent=scroll
local stack=Instance.new("UIListLayout")
stack.SortOrder=Enum.SortOrder.LayoutOrder;stack.Padding=UDim.new(0,9);stack.Parent=scroll
local function corner(obj,r)
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 7);c.Parent=obj
end
local function text(str,size,color,height,bold)
 local l=Instance.new("TextLabel")
 l.BackgroundTransparency=1;l.BorderSizePixel=0;l.Size=UDim2.new(1,0,0,height or 25)
 l.Text=str;l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
 l.TextSize=size or 13;l.TextColor3=color or COLORS.text
 l.TextWrapped=true;l.TextXAlignment=Enum.TextXAlignment.Left;l.Parent=scroll
 return l
end
local function section(heading,subtitle)
 text(heading,14,COLORS.main,24,true)
 if subtitle then text(subtitle,12,COLORS.muted,32) end
end
local function field(title,default,placeholder)
 text(title,12,COLORS.muted,20,true)
 local inp=Instance.new("TextBox")
 inp.Size=UDim2.new(1,0,0,37);inp.BackgroundColor3=COLORS.input
 inp.BorderSizePixel=0;inp.Font=Enum.Font.Gotham;inp.TextSize=14
 inp.TextColor3=COLORS.text;inp.Text=tostring(default)
 inp.PlaceholderText=placeholder or "";inp.PlaceholderColor3=COLORS.muted
 inp.ClearTextOnFocus=false;inp.Parent=scroll;corner(inp)
 return inp
end
local function button(title,color)
 local btn=Instance.new("TextButton")
 btn.Size=UDim2.new(1,0,0,42);btn.BorderSizePixel=0
 btn.BackgroundColor3=color;btn.Text=title;btn.TextColor3=COLORS.bg
 btn.Font=Enum.Font.GothamBold;btn.TextSize=14;btn.Parent=scroll;corner(btn)
 return btn
end
text("REALTERRA  /  ENGINE",20,COLORS.text,33,true)
text("Procedural world tools  •  v"..VERSION,12,COLORS.muted,22)
section("01  TERRAIN", "Choose a fixed map size or match your Baseplate.")
local useBaseplate=false
local check=Instance.new("TextButton")
check.Size=UDim2.new(1,0,0,44);check.BackgroundColor3=COLORS.panel
check.BorderSizePixel=0;check.Font=Enum.Font.GothamMedium
check.TextSize=13;check.TextColor3=COLORS.text
check.TextXAlignment=Enum.TextXAlignment.Left;check.Parent=scroll;corner(check)
local function checkVisual()
 check.Text=(useBaseplate and "  ☑" or "  ☐").."  Match Baseplate size"
end
checkVisual()
local sizeBox=field("Manual size (studs, 128–1024)",256)
local dimensions=text("Manual mode: square area",12,COLORS.muted,20)
local function findBaseplate()
 local base=workspace:FindFirstChild("Baseplate",true)
 if base and base:IsA("BasePart") then return base end
 return nil
end
local function refreshBaseplate()
 sizeBox.TextEditable=not useBaseplate
 sizeBox.BackgroundColor3=useBaseplate and COLORS.panel or COLORS.input
 if useBaseplate then
  local b=findBaseplate()
  if b then
   dimensions.Text=string.format("Baseplate area: %.0f × %.0f studs",b.Size.X,b.Size.Z)
  else dimensions.Text="Baseplate not found: name a Part 'Baseplate'" end
 else dimensions.Text="Manual mode: square area" end
end
check.MouseButton1Click:Connect(function()
 useBaseplate=not useBaseplate;checkVisual();refreshBaseplate()
end)
local seedBox=field("World seed",48291)
local heightBox=field("Relief intensity (8–100)",40)
section("02  NATURE","Trees are placeholder models in this preview.")
local densityBox=field("Tree density (0–100)",45)
section("03  ACTIONS")
local generate=button("GENERATE WORLD",COLORS.main)
local remove=button("REMOVE GENERATED PROPS",COLORS.danger)
remove.TextColor3=COLORS.text
local update=button("CHECK FOR UPDATES",COLORS.input)
update.TextColor3=COLORS.text
local status=text("Ready. Save your place before generation.",12,COLORS.muted,62)
local running=false
local function numeric(box,lo,hi)
 local v=tonumber(box.Text)
 if not v or v~=v then return nil end
 return math.clamp(math.floor(v),lo,hi)
end
local function makeTree(folder,position,rng)
 local model=Instance.new("Model");model.Name="RT_Tree";model.Parent=folder
 local tall=rng:NextNumber(12,23)
 local trunk=Instance.new("Part")
 trunk.Name="Trunk";trunk.Anchored=true;trunk.Material=Enum.Material.Wood
 trunk.Color=Color3.fromRGB(91,68,47);trunk.Size=Vector3.new(2,tall,2)
 trunk.Position=position+Vector3.new(0,tall/2,0);trunk.Parent=model
 for n=1,3 do
  local leaf=Instance.new("Part")
  leaf.Name="Canopy";leaf.Anchored=true;leaf.CanCollide=false
  leaf.Shape=Enum.PartType.Ball;leaf.Material=Enum.Material.Grass
  leaf.Color=Color3.fromRGB(42+rng:NextInteger(0,15),104+rng:NextInteger(0,22),45)
  local w=8+(3-n)*2;leaf.Size=Vector3.new(w,w*.75,w)
  leaf.Position=position+Vector3.new(0,tall*(.7+n*.14),0);leaf.Parent=model
 end
end
local function sampleHeight(x,z,seed,amplitude)
 local s=seed%10000
 local noise=math.noise(x/210,z/210,s)*.65
  +math.noise(x/75,z/75,s+17)*.28
  +math.noise(x/28,z/28,s+43)*.07
 return math.max(8,math.floor(24+noise*amplitude))
end
generate.MouseButton1Click:Connect(function()
 if running then return end
 local seed=numeric(seedBox,-2147483647,2147483647)
 local amplitude=numeric(heightBox,8,100)
 local density=numeric(densityBox,0,100)
 local size=numeric(sizeBox,128,1024)
 if not seed or not amplitude or not density or (not useBaseplate and not size) then
  status.Text="Please enter valid numeric settings.";return
 end
 local base=useBaseplate and findBaseplate() or nil
 if useBaseplate and not base then
  status.Text="Baseplate not found. Add a Part named Baseplate.";return
 end
 if workspace:FindFirstChild("RealTerra_Generated") then
  status.Text="A RealTerra world exists. Remove its props first. Existing terrain is not cleared.";return
 end
 local width=base and base.Size.X or size
 local depth=base and base.Size.Z or size
 if width<8 or depth<8 or width>4096 or depth>4096 then
  status.Text="Baseplate X/Z dimensions must be 8–4096 studs.";return
 end
 local center=base and base.CFrame or CFrame.new()
 local y0=base and base.Size.Y/2 or 0
 local cell=8
 local cols=math.max(1,math.ceil(width/cell))
 local rows=math.max(1,math.ceil(depth/cell))
 local rng=Random.new(seed)
 local heights={}
 running=true;generate.Active=false;generate.AutoButtonColor=false
 task.spawn(function()
  local ok,err=pcall(function()
   ChangeHistoryService:SetWaypoint("Before RealTerra world generation")
   local folder=Instance.new("Folder");folder.Name="RealTerra_Generated";folder.Parent=workspace
   for i=1,cols do
    heights[i]={}
    for j=1,rows do
     local x=-width/2+(i-.5)*cell
     local z=-depth/2+(j-.5)*cell
     local actualW=math.min(cell,width-(i-1)*cell)
     local actualD=math.min(cell,depth-(j-1)*cell)
     x=-width/2+(i-1)*cell+actualW/2
     z=-depth/2+(j-1)*cell+actualD/2
     local h=sampleHeight(x,z,seed,amplitude)
     heights[i][j]=h
     local top=math.ceil(h/4)*4
     local localCenter=Vector3.new(x,y0+(top-16)/2,z)
     Terrain:FillBlock(center*CFrame.new(localCenter),Vector3.new(actualW,top+16,actualD),Enum.Material.Grass)
    end
    if i%6==0 then
     status.Text=string.format("Building terrain: %d%%",math.floor(i/cols*100))
     task.wait()
    end
   end
   local count=0
   for i=2,cols-1,2 do
    for j=2,rows-1,2 do
     if count<750 and rng:NextNumber(0,100)<density then
      local h=heights[i][j]
      if math.abs(h-heights[i+1][j])<=6 and math.abs(h-heights[i][j+1])<=6 then
       local actualW=math.min(cell,width-(i-1)*cell)
       local actualD=math.min(cell,depth-(j-1)*cell)
       local x=-width/2+(i-1)*cell+actualW/2
       local z=-depth/2+(j-1)*cell+actualD/2
       local world=(center*CFrame.new(x,y0+math.ceil(h/4)*4,z)).Position
       makeTree(folder,world,rng);count+=1
      end
     end
    end
    if i%8==0 then task.wait() end
   end
   folder:SetAttribute("Seed",seed)
   folder:SetAttribute("Width",width);folder:SetAttribute("Depth",depth)
   folder:SetAttribute("Version",VERSION)
   ChangeHistoryService:SetWaypoint("RealTerra world generated")
   status.Text=string.format("Done! %.0f × %.0f studs, %d trees. Terrain remains if props are removed.",width,depth,count)
  end)
  if not ok then status.Text="Generation failed: "..tostring(err) end
  running=false;generate.Active=true;generate.AutoButtonColor=true
 end)
end)
remove.MouseButton1Click:Connect(function()
 if running then return end
 local folder=workspace:FindFirstChild("RealTerra_Generated")
 if not folder then status.Text="No RealTerra props found.";return end
 ChangeHistoryService:SetWaypoint("Before removing RealTerra props")
 folder:Destroy()
 ChangeHistoryService:SetWaypoint("RealTerra props removed")
 status.Text="Removed props. Terrain preserved."
end)
local function parse(v)
 local a,b,c=v:match("^(%d+)%.(%d+)%.(%d+)$")
 if not a then return nil end
 return {tonumber(a),tonumber(b),tonumber(c)}
end
update.MouseButton1Click:Connect(function()
 status.Text="Checking GitHub for updates..."
 task.spawn(function()
  local endpoint="https://raw.githubusercontent.com/raphaelsancho21-byte/RealTerra-Engine/main/version.json"
  local ok,body=pcall(function() return HttpService:GetAsync(endpoint,true) end)
  if not ok then status.Text="Update check failed. Allow HTTP access for this plugin.";return end
  local parsed,manifest=pcall(function()return HttpService:JSONDecode(body)end)
  if not parsed or type(manifest)~="table" or type(manifest.version)~="string" then
   status.Text="Invalid update manifest.";return
  end
  local old,new=parse(VERSION),parse(manifest.version)
  if not new then status.Text="Invalid version in manifest.";return end
  local newer=false
  for i=1,3 do
   if new[i]>old[i] then newer=true;break end
   if new[i]<old[i] then break end
  end
  if newer then
   status.Text="Version "..manifest.version.." available! Re-run the CMD installer, then restart Studio."
  else status.Text="RealTerra is up to date (v"..VERSION..")." end
 end)
end)
