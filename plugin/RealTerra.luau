-- RealTerra Engine v0.1.0: Roblox Studio plugin
local Terrain = workspace.Terrain
local HttpService = game:GetService("HttpService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local toolbar = plugin:CreateToolbar("RealTerra Engine")
local toggle = toolbar:CreateButton("RealTerra", "Open RealTerra terrain generator", "rbxassetid://4458901886")
toggle.ClickableWhenViewportHidden = true
local widget = plugin:CreateDockWidgetPluginGui("RealTerraEngineV01", DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, true, false, 350, 540, 300, 390))
widget.Title = "RealTerra Engine 0.1.0"
toggle.Click:Connect(function() widget.Enabled = not widget.Enabled end)
local pane = Instance.new("ScrollingFrame")
pane.Size = UDim2.fromScale(1,1); pane.BackgroundColor3 = Color3.fromRGB(20,29,25)
pane.BorderSizePixel = 0; pane.ScrollBarThickness = 4
pane.AutomaticCanvasSize = Enum.AutomaticSize.Y; pane.CanvasSize = UDim2.new()
pane.Parent = widget
local padding = Instance.new("UIPadding",pane)
padding.PaddingTop=UDim.new(0,14); padding.PaddingBottom=UDim.new(0,14)
padding.PaddingLeft=UDim.new(0,14);padding.PaddingRight=UDim.new(0,14)
local layout=Instance.new("UIListLayout",pane)
layout.Padding=UDim.new(0,9);layout.SortOrder=Enum.SortOrder.LayoutOrder
local function label(text)
 local obj=Instance.new("TextLabel");obj.Size=UDim2.new(1,0,0,30)
 obj.BackgroundTransparency=1;obj.Text=text;obj.TextSize=14
 obj.Font=Enum.Font.GothamMedium;obj.TextColor3=Color3.fromRGB(225,241,229)
 obj.TextWrapped=true;obj.TextXAlignment=Enum.TextXAlignment.Left
 obj.Parent=pane;return obj
end
local function field(title,default)
 label(title)
 local obj=Instance.new("TextBox");obj.Size=UDim2.new(1,0,0,35)
 obj.BackgroundColor3=Color3.fromRGB(35,47,40);obj.BorderSizePixel=0
 obj.TextColor3=Color3.new(1,1,1);obj.ClearTextOnFocus=false
 obj.Text=tostring(default);obj.TextSize=15;obj.Font=Enum.Font.Gotham
 obj.Parent=pane;Instance.new("UICorner",obj).CornerRadius=UDim.new(0,6)
 return obj
end
local function button(text,color)
 local obj=Instance.new("TextButton");obj.Size=UDim2.new(1,0,0,40)
 obj.Text=text;obj.Font=Enum.Font.GothamBold;obj.TextSize=14
 obj.TextColor3=Color3.new(1,1,1);obj.BackgroundColor3=color or Color3.fromRGB(65,151,96)
 obj.BorderSizePixel=0;obj.Parent=pane
 Instance.new("UICorner",obj).CornerRadius=UDim.new(0,6);return obj
end
label("REALTERRA  /  WORLD GENERATOR").TextSize=17
local seedBox=field("World seed",48291)
local sizeBox=field("Map size (128–1024 studs)",256)
local heightBox=field("Mountain height (8–100 studs)",40)
local densityBox=field("Tree density (0–100)",45)
local generate=button("Generate World")
local remove=button("Remove Generated Props",Color3.fromRGB(125,70,65))
local update=button("Check for Updates",Color3.fromRGB(62,100,125))
local status=label("Ready. Create a backup before generating.")
status.Size=UDim2.new(1,0,0,72)
local running=false
local function number(box,low,high)
 local v=tonumber(box.Text)
 if not v then return nil end
 return math.clamp(math.floor(v),low,high)
end
local function makeTree(folder,x,y,z,rng)
 local model=Instance.new("Model");model.Name="RT_Tree";model.Parent=folder
 local tall=rng:NextNumber(12,23)
 local trunk=Instance.new("Part");trunk.Name="Trunk";trunk.Anchored=true
 trunk.Material=Enum.Material.Wood;trunk.Color=Color3.fromRGB(91,68,47)
 trunk.Size=Vector3.new(2,tall,2);trunk.Position=Vector3.new(x,y+tall/2,z);trunk.Parent=model
 for n=1,3 do
  local crown=Instance.new("Part");crown.Name="Leaves";crown.Anchored=true
  crown.Shape=Enum.PartType.Ball;crown.CanCollide=false;crown.Material=Enum.Material.Grass
  crown.Color=Color3.fromRGB(40+rng:NextInteger(0,13),105+rng:NextInteger(0,20),43)
  local w=8+(3-n)*2
  crown.Size=Vector3.new(w,w*0.75,w)
  crown.Position=Vector3.new(x,y+tall*(0.7+n*0.14),z);crown.Parent=model
 end
end
generate.MouseButton1Click:Connect(function()
 if running then return end
 local seed=number(seedBox,-2147483647,2147483647)
 local size=number(sizeBox,128,1024)
 local amplitude=number(heightBox,8,100)
 local density=number(densityBox,0,100)
 if not seed or not size or not amplitude or not density then
  status.Text="Invalid numeric settings";return
 end
 if workspace:FindFirstChild("RealTerra_Generated") then
  status.Text="Remove previous props first. Terrain is NOT erased.";return
 end
 running=true;generate.Active=false
 task.spawn(function()
  local ok,err=pcall(function()
   ChangeHistoryService:SetWaypoint("Before RealTerra generation")
   local folder=Instance.new("Folder");folder.Name="RealTerra_Generated";folder.Parent=workspace
   local rng=Random.new(seed);local grid=math.floor(size/8);local heights={}
   for i=0,grid-1 do
    heights[i]={}
    for j=0,grid-1 do
     local x=(i-grid/2)*8+4;local z=(j-grid/2)*8+4
     local k=seed%10000
     local noise=math.noise(x/210,z/210,k)*0.65+math.noise(x/75,z/75,k+17)*0.28+math.noise(x/28,z/28,k+43)*0.07
     local h=math.max(8,math.floor(24+noise*amplitude))
     heights[i][j]=h
     local top=math.ceil(h/4)*4
     Terrain:FillBlock(CFrame.new(x,(top-16)/2,z),Vector3.new(8,top+16,8),Enum.Material.Grass)
    end
    if i%8==0 then
     status.Text=string.format("Generating terrain: %d%%",math.floor(i/grid*100))
     task.wait()
    end
   end
   local count=0
   for i=2,grid-3,2 do
    for j=2,grid-3,2 do
     if count<450 and rng:NextNumber(0,100)<density then
      local h=heights[i][j]
      if math.abs(h-heights[i+1][j])<=6 and math.abs(h-heights[i][j+1])<=6 then
       local x=(i-grid/2)*8+4;local z=(j-grid/2)*8+4
       makeTree(folder,x,math.ceil(h/4)*4,z,rng)
       count+=1
      end
     end
    end
    if i%12==0 then task.wait() end
   end
   folder:SetAttribute("Seed",seed);folder:SetAttribute("Version","0.1.0")
   ChangeHistoryService:SetWaypoint("RealTerra world generated")
   status.Text="Generated "..count.." trees. Terrain stays after prop cleanup."
  end)
  if not ok then status.Text="Generation failed: "..tostring(err) end
  running=false;generate.Active=true
 end)
end)
remove.MouseButton1Click:Connect(function()
 if running then return end
 local folder=workspace:FindFirstChild("RealTerra_Generated")
 if not folder then status.Text="No generated props found";return end
 ChangeHistoryService:SetWaypoint("Before removing RealTerra props")
 folder:Destroy()
 ChangeHistoryService:SetWaypoint("RealTerra props removed")
 status.Text="Removed props only. Terrain preserved for safety."
end)
local function versionParts(s)
 local a,b,c=s:match("^(%d+)%.(%d+)%.(%d+)$")
 if not a then return nil end
 return {tonumber(a),tonumber(b),tonumber(c)}
end
update.MouseButton1Click:Connect(function()
 status.Text="Checking GitHub..."
 task.spawn(function()
  local endpoint="https://raw.githubusercontent.com/raphaelsancho21-byte/RealTerra-Engine/main/version.json"
  local ok,body=pcall(function()return HttpService:GetAsync(endpoint,true)end)
  if not ok then status.Text="Unable to check updates. Enable plugin HTTP permissions.";return end
  local parsed,manifest=pcall(function()return HttpService:JSONDecode(body)end)
  if not parsed or type(manifest)~="table" or type(manifest.version)~="string" then
   status.Text="Invalid update manifest";return
  end
  local installed=versionParts("0.1.0");local newest=versionParts(manifest.version)
  if not newest then status.Text="Invalid version format";return end
  local newer=false
  for i=1,3 do
   if newest[i]>installed[i] then newer=true;break end
   if newest[i]<installed[i] then break end
  end
  if newer then
   status.Text="Update v"..manifest.version.." available! Rerun installer from GitHub, then restart Studio."
  else status.Text="You have the latest RealTerra v0.1.0" end
 end)
end)
