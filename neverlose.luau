-- Neverlose
if game.GameId~=6035872082 then warn("[Neverlose for RIVALS] This script only supports RIVALS");return end
local source=[=====[
-- Neverlose

-- BEGIN GENERATED STARTUP GUARD
local STARTUP_SOURCE=[====[
-- Read-only startup checks. Never require a controller while the native loader owns it.
local M={universeId=6035872082}
local function find(root,path)
 for part in path:gmatch('[^/]+')do root=root and root:FindFirstChild(part)end
 return root
end
function M.probe()
 if game.GameId~=0 and game.GameId~=M.universeId then return nil,'wrong game' end
 if not game:IsLoaded()then return nil,'Roblox loading' end
 if game.GameId~=M.universeId then return nil,'wrong game' end
 local p=game:GetService('Players').LocalPlayer
 local ps=p and p:FindFirstChild('PlayerScripts');local pg=p and p:FindFirstChild('PlayerGui')
 if not (ps and pg and workspace.CurrentCamera)then return nil,'waiting for player/camera' end
 -- The same native ScreenGui moves from its module into PlayerGui, then is destroyed
 -- after Close() finishes. Check both locations, including the closing blur effect.
 local rf=game:GetService('ReplicatedFirst')
 if find(rf,'Root/LoadingScreen/LoadingScreen')or pg:FindFirstChild('LoadingScreen')or game:GetService('Lighting'):FindFirstChild('LoadingScreen')then return nil,'RIVALS loading screen' end
 local gui=pg:FindFirstChild('MainGui');if not gui then return nil,'waiting for game interface' end
 local rs=game:GetService('ReplicatedStorage')
 local token={ps,pg,gui,workspace.CurrentCamera}
 local fighter=find(ps,'Controllers/FighterController')
 if fighter then
  for _,spec in ipairs({
   {ps,'Controllers/FighterController'},{ps,'Controllers/CameraController'},
   {ps,'Controllers/MechanicsController'},{ps,'Modules/ClientReplicatedClasses/ClientFighter/ClientItem/ClientViewModel'},
   {ps,'Modules/ItemTypes/Gun'},{rs,'Modules/ItemLibrary'},{rs,'Modules/CosmeticLibrary'},{rs,'Modules/Utility'},
  })do
   local dependency=find(spec[1],spec[2]);if not dependency then return nil,'waiting for game modules' end
   table.insert(token,dependency)
  end
 else
  for _,path in ipairs({'Modules/Client/Controllers/GunController','Modules/Client/Controllers/CameraController','Modules/Client/CameraPOV','Assets/Operators/Operator1'})do
   local dependency=find(rs,path);if not dependency then return nil,'waiting for game modules' end
   table.insert(token,dependency)
  end
 end
 return token,'ready'
end
function M.same(a,b)
 if not a or not b or #a~=#b then return false end
 for i,v in ipairs(a)do if v~=b[i]then return false end end
 return true
end
function M.wait(timeout,cancel)
 local deadline=os.clock()+(timeout or 180);local stable,since;local reason
 repeat
  if cancel and cancel()then return false,'cancelled' end
  local token;token,reason=M.probe()
  if reason=='wrong game'then return false,reason end
  if not M.same(token,stable)then stable,since=token,os.clock()end
  if token and os.clock()-(since or os.clock())>=2 then return true end
  task.wait(.25)
 until os.clock()>=deadline
 return false,'Timed out waiting for '..tostring(reason)
end
return M
]====]
local Startup=assert(loadstring(STARTUP_SOURCE,"Neverlose for RIVALS / Startup"))()
local startupReady,startupReason=Startup.wait(180)
if not startupReady then warn("[Neverlose for RIVALS] "..tostring(startupReason));return end
-- END GENERATED STARTUP GUARD
local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local RunService = cloneref(game:GetService("RunService"))
local LocalPlayer = Players.LocalPlayer

local httpRequest = request or http_request or (syn and syn.request)
local ROOT = "neverlose_ui"
local ICON_DIR = ROOT .. "/icons_v3"
local ICON_DATA -- filled in at the bottom of the file

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

-- Colours sampled from 1080p footage of the menu and the official docs screenshots.
local Theme = {
	Content = rgb(8, 8, 13),
	Group = rgb(3, 13, 26),
	Line = rgb(5, 26, 38),
	Field = rgb(7, 15, 24),
	FieldStroke = rgb(3, 28, 46),
	Label = rgb(153, 176, 189),
	Title = rgb(232, 238, 242),
	Dim = rgb(96, 112, 126),
	NavHeader = rgb(60, 69, 82),
	NavText = rgb(232, 239, 250),
	NavTextActive = rgb(215, 244, 254),
	NavIcon = rgb(72, 147, 178),
	NavIconActive = rgb(66, 153, 194),
	NavActive = rgb(8, 47, 66),
	SidebarEdge = rgb(15, 20, 28),
	SidebarTint = rgb(2, 11, 24),
	SidebarSeeThrough = 0.12,
	Logo = rgb(254, 254, 255),
	HeaderIcon = rgb(247, 246, 251),
	Button = rgb(13, 126, 168),
	ButtonHover = rgb(20, 141, 186),
	TabActive = rgb(5, 69, 102),
	KnobOff = rgb(125, 138, 148),
	TrackOff = rgb(3, 5, 13),
	KnobOn = rgb(26, 149, 209),
	TrackOn = rgb(4, 40, 62),
	TrackOnStroke = rgb(5, 66, 96),
	SliderTrack = rgb(11, 25, 41),
	SliderFill = rgb(52, 110, 196),
	SliderKnob = rgb(78, 136, 222),
	Value = rgb(120, 134, 148),
	Name = rgb(231, 242, 252),
	Link = rgb(61, 149, 194),
	Popup = rgb(8, 18, 30),
	PopupHover = rgb(12, 29, 46),
}

-- Window metrics (pixels, measured at 1080p)
local WIN_W, WIN_H = 835, 688
local WIN_RADIUS = 8
local SIDEBAR_W = 192
local CONTENT_W = WIN_W - SIDEBAR_W
local HEADER_H = 69
local COL_W = 296
local ROW_H = 31

---------------------------------------------------------------------------------------------
-- Assets
---------------------------------------------------------------------------------------------

local function ensureFolder(path)
	if not isfolder(path) then
		makefolder(path)
	end
end

local function download(path, url)
	if isfile(path) then
		return true
	end
	if not httpRequest then
		return false
	end
	local ok, res = pcall(httpRequest, { Url = url, Method = "GET" })
	if ok and res and res.StatusCode == 200 and res.Body and #res.Body > 1000 then
		writefile(path, res.Body)
		return true
	end
	return false
end

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64_LOOKUP = {}
for i = 1, #B64 do
	B64_LOOKUP[B64:sub(i, i)] = i - 1
end

local function base64Decode(data)
	data = data:gsub("[^%w%+/]", "")
	local out = table.create and table.create(#data) or {}
	local n = 0
	for i = 1, #data, 4 do
		local a = B64_LOOKUP[data:sub(i, i)] or 0
		local b = B64_LOOKUP[data:sub(i + 1, i + 1)] or 0
		local c = B64_LOOKUP[data:sub(i + 2, i + 2)]
		local d = B64_LOOKUP[data:sub(i + 3, i + 3)]
		local v = a * 262144 + b * 4096 + (c or 0) * 64 + (d or 0)
		n += 1
		out[n] = string.char(bit32.rshift(v, 16) % 256)
		if c then
			n += 1
			out[n] = string.char(bit32.rshift(v, 8) % 256)
		end
		if d then
			n += 1
			out[n] = string.char(v % 256)
		end
	end
	return table.concat(out, "", 1, n)
end

local MULISH_URL = "https://raw.githubusercontent.com/googlefonts/mulish/main/fonts/ttf/"

local function loadFontFamily()
	local faces = {
		{ "Regular", 400, "Mulish-Regular.ttf" },
		{ "Medium", 500, "Mulish-Medium.ttf" },
		{ "SemiBold", 600, "Mulish-SemiBold.ttf" },
		{ "Bold", 700, "Mulish-Bold.ttf" },
		{ "ExtraBold", 800, "Mulish-ExtraBold.ttf" },
	}
	local family = { name = "NeverloseMulish", faces = {} }
	for _, face in ipairs(faces) do
		local path = ROOT .. "/fonts/" .. face[3]
		if download(path, MULISH_URL .. face[3]) then
			table.insert(family.faces, {
				name = face[1],
				weight = face[2],
				style = "normal",
				assetId = getcustomasset(path),
			})
		end
	end
	if #family.faces == 0 then
		return nil
	end
	local jsonPath = ROOT .. "/fonts/mulish.json"
	writefile(jsonPath, HttpService:JSONEncode(family))
	return getcustomasset(jsonPath)
end

ensureFolder(ROOT)
ensureFolder(ROOT .. "/fonts")
ensureFolder(ICON_DIR)

-- Keep font registrations and loaded faces across menu reloads in this client session.
local fontEnv = getgenv and getgenv() or {}
local fontCache = fontEnv.NeverloseFontCache
if type(fontCache) ~= "table" or fontCache.version ~= 1 then
	fontCache = { version = 1, ready = false, warmups = 0 }
	fontEnv.NeverloseFontCache = fontCache
end
local okFamily, familyId = true, fontCache.familyId
if not familyId then
	okFamily, familyId = pcall(loadFontFamily)
	if okFamily then fontCache.familyId = familyId end
end
local function fontOf(weight)
	if okFamily and familyId then
		return Font.new(familyId, weight)
	end
	return Font.new("rbxasset://fonts/families/GothamSSm.json", weight)
end

local Fonts = fontCache.fonts or {
	Regular = fontOf(Enum.FontWeight.Regular),
	Medium = fontOf(Enum.FontWeight.Medium),
	SemiBold = fontOf(Enum.FontWeight.SemiBold),
	Bold = fontOf(Enum.FontWeight.Bold),
	ExtraBold = fontOf(Enum.FontWeight.ExtraBold),
	Logo = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold),
}
fontCache.fonts = Fonts
if not fontCache.ready then
	local textService = game:GetService("TextService")
	local allReady = true
	for name, face in pairs(Fonts) do
		local params = Instance.new("GetTextBoundsParams")
		params.Font = face
		params.Size = name == "Logo" and 30 or 16
		params.Width = 4096
		params.Text = "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 0123456789 !?.,:;+-/%()[] °•×→"
		local loaded, err = pcall(function() textService:GetTextBoundsAsync(params) end)
		fontCache.warmups += 1
		params:Destroy()
		if not loaded then allReady = false; fontCache.lastError = tostring(err) end
	end
	fontCache.ready = allReady
end

local Icons = {}
local function loadIcons()
	for name, data in pairs(ICON_DATA) do
		local path = ICON_DIR .. "/" .. name .. ".png"
		if not isfile(path) then
			writefile(path, base64Decode(data))
		end
		local ok, id = pcall(getcustomasset, path)
		if ok then
			Icons[name] = id
		end
	end
end

---------------------------------------------------------------------------------------------
-- Instance helpers
---------------------------------------------------------------------------------------------

local function create(className, props, children)
	local inst = Instance.new(className)
	local parent = props.Parent
	props.Parent = nil
	for key, value in pairs(props) do
		inst[key] = value
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function corner(radius)
	return create("UICorner", { CornerRadius = typeof(radius) == "UDim" and radius or UDim.new(0, radius) })
end

local function stroke(color, thickness)
	local s = create("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	-- keep the stroke inside the frame so sizes match the reference pixel-for-pixel
	pcall(function()
		s.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	end)
	return s
end

local function text(props)
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	props.FontFace = props.FontFace or Fonts.SemiBold
	return create("TextLabel", props)
end

local function icon(name, size, color, props)
	props = props or {}
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	props.Image = Icons[name .. "_" .. size] or ""
	props.ImageColor3 = color
	props.Size = UDim2.fromOffset(size, size)
	return create("ImageLabel", props)
end

local function frame(props, children)
	props.BorderSizePixel = 0
	return create("Frame", props, children)
end

local function hitbox(props)
	props.BackgroundTransparency = 1
	props.BorderSizePixel = 0
	props.Text = ""
	props.AutoButtonColor = false
	return create("TextButton", props)
end

local function tween(inst, time, props, style)
	local t = TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function toHex(c)
	return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end


local function fromHex(s)
	s = tostring(s or ""):gsub("#", "")
	local r, g, b = tonumber(s:sub(1, 2), 16), tonumber(s:sub(3, 4), 16), tonumber(s:sub(5, 6), 16)
	if r and g and b then
		return Color3.fromRGB(r, g, b)
	end
	return Color3.new(1, 1, 1)
end

local function keyName(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Unknown then
			return nil
		end
		return input.KeyCode.Name
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		return "MB2"
	elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
		return "MB3"
	end
	return nil
end

local function copyValue(v)
	if type(v) == "table" then
		local t = {}
		for k, x in pairs(v) do
			t[k] = x
		end
		return t
	end
	return v
end

---------------------------------------------------------------------------------------------
-- Menu
---------------------------------------------------------------------------------------------

local installGameAdapter = (function()
-- Fighter / ClientItem runtime bridge. Older OperatorPresenter builds use their original adapters.
local ShotPacket=(function()
 local M={}
 function M.read(data,key,codec)
  local value=data[key]
  if typeof(value)=='CFrame'then return value end
  if type(value)=='table'then return codec:DecodeCFrame(value)end
 end
 function M.write(data,key,value,codec,encoded)
  data[key]=value and (encoded and codec:EncodeCFrame(value)or value)or nil
 end
 return M
end)()
local KatanaDeflect=(function()
 local M={}
 function M.new(clock)
  local windows=setmetatable({},{__mode='k'})
  local function katana(w)return w and (w.Name=='Katana'or w.Info and w.Info.Name=='Katana')end
  return {
   start=function(w)
    if katana(w)then windows[w]={hash=w._deflect_hash,expires=clock()+(tonumber(w.Info.DeflectDuration)or 0)}end
   end,
   stop=function(w)windows[w]={hash=w._deflect_hash,expires=0}end,
   active=function(w)
    if not katana(w)then return false end
    local window=windows[w]
    if window and window.hash==w._deflect_hash then return clock()<window.expires end
    -- Handles loading this menu halfway through an existing native deflect.
    return w:Get('FOVOffset')==5
   end,
  }
 end
 return M
end)()
local ShieldGuard=(function()
 local M={}
 function M.active(w)
  if not w or w._destroyed or not (w.Name=='Riot Shield'or w.Info and w.Info.Name=='Riot Shield')then return false end
  -- Native Ammo is shield durability; cosmetics and delayed broken animations are not authoritative.
  return (tonumber(w:Get('Ammo'))or 0)>0
 end
 function M.fighter(f)
  if not f then return false end
  if M.active(f.EquippedItem)then return true end
  -- A holstered Riot Shield also protects its carrier's back.
  for _,w in pairs(f.Items or {})do if M.active(w)then return true end end
  return false
 end
 return M
end)()
local CataloguePreview=(function()
 local M={}
 function M.build(asset,wrapController,wrap,inverted,collection)
  assert(asset and asset:IsA('Model'),'Weapon model assets are not ready')
  local copy=assert(asset:Clone(),'Weapon model could not be cloned');copy.Name='WeaponPreview'
  local properties;local disposed=false
  local function dispose()
   if disposed then return end;disposed=true
   -- Native animated wrap objects have their own connections and need explicit disposal.
   for _,entry in pairs(properties or {})do
    for _,object in pairs(entry.Cleanup or {})do pcall(function()object:Destroy()end)end
    for _,child in pairs(entry.OriginalChildren or {})do if not child.Parent then pcall(function()child:Destroy()end)end end
   end
   properties=nil
  end
  local ok,err=pcall(function()
   for _,child in ipairs(copy:GetChildren())do
    local contexts=child:GetAttribute('AnimationContexts');local idle=false
    if type(contexts)=='string'then for context in contexts:gmatch('[^,]+')do if context:match('^%s*(.-)%s*$')=='Idle'then idle=true end end end
    if type(contexts)=='string'and not idle then child:Destroy()end
   end
   -- Bare Fists stores its visible hands in the helper rig instead of a weapon body.
   local helper=copy:FindFirstChild('_fake');local bodyVisible=false
   for _,node in ipairs(copy:GetDescendants())do
    if node:IsA('BasePart')and node.Transparency<1 and not(helper and node:IsDescendantOf(helper))then bodyVisible=true;break end
   end
   if helper and not bodyVisible then
    for _,name in ipairs({'LeftArm','RightArm'})do
     local hand=helper:FindFirstChild(wrap and wrap~='Original'and name..'Wrapped'or name)or helper:FindFirstChild(name..'Wrapped')or helper:FindFirstChild(name)
     if hand then hand.Parent=copy end
    end
   end
   if helper then helper:Destroy()end
   local visible=0
   for _,node in ipairs(copy:GetDescendants())do
    if node:IsA('BasePart')then
     node.Anchored=true;node.CanCollide=false;node.CanTouch=false;node.CanQuery=false;node.LocalTransparencyModifier=0
     if node.Transparency<1 then visible=visible+1 end
    elseif node:IsA('LuaSourceContainer')or node:IsA('Sound')or node:IsA('ParticleEmitter')or node:IsA('Light')or node:IsA('JointInstance')or node:IsA('Constraint')then node:Destroy()end
   end
   assert(visible>0,'Weapon model has no visible preview parts')
   if wrap and wrap~='Original'then
    assert(wrapController,'Weapon finishes are not ready')
    properties=wrapController:RecordOriginalWrapProperties(copy)
    wrapController:ApplyWrap(properties,{Name=wrap,Inverted=inverted==true})
   end
   local nodes=copy:GetDescendants();table.insert(nodes,copy)
   for _,node in ipairs(nodes)do for _,tag in ipairs(collection:GetTags(node))do collection:RemoveTag(node,tag)end end
   local bounds=copy:GetBoundingBox();copy:PivotTo(CFrame.new(-bounds.Position)*copy:GetPivot())
   copy.Destroying:Connect(dispose)
  end)
  if not ok then dispose();copy:Destroy();error(err,0)end
  return copy,dispose
 end
 return M
end)()
return function(connect,cleanups,getValue,isMenuOpen)
 local Players=game:GetService('Players')
 local RS=game:GetService('ReplicatedStorage')
 local Run=game:GetService('RunService')
 local UIS=game:GetService('UserInputService')
 local Collection=game:GetService('CollectionService')
 local player=Players.LocalPlayer
 local ps=player:FindFirstChild('PlayerScripts')
 local controllers=ps and ps:FindFirstChild('Controllers')
 if not (controllers and controllers:FindFirstChild('FighterController')) then return nil end
 local function requireAt(root,path)
  for part in path:gmatch('[^/]+') do root=root and root:FindFirstChild(part) end
  if not root then return nil end
  local previous=getthreadidentity and getthreadidentity()
  if setthreadidentity then setthreadidentity(2)end
  local ok,value=pcall(require,root)
  if setthreadidentity and previous then setthreadidentity(previous)end
  return ok and value or nil
 end
 local fc=requireAt(controllers,'FighterController')
 local camera=requireAt(controllers,'CameraController')
 local mechanics=requireAt(controllers,'MechanicsController')
 local playerData=requireAt(controllers,'PlayerDataController')
 local enemies=requireAt(controllers,'EnemyController')
 local wrapController=requireAt(controllers,'WrapController')
 local duels=requireAt(controllers,'DuelController')
 local duelLibrary=requireAt(RS,'Modules/DuelLibrary')
 local items=requireAt(RS,'Modules/ItemLibrary')
 local cosmetics=requireAt(RS,'Modules/CosmeticLibrary')
 local utility=requireAt(RS,'Modules/Utility')
 local jointsClass=requireAt(ps,'Modules/ClientReplicatedClasses/ClientFighter/ClientFighterCharacter/Joints')
 local vmClass=requireAt(ps,'Modules/ClientReplicatedClasses/ClientFighter/ClientItem/ClientViewModel')
 local gunClass=requireAt(ps,'Modules/ItemTypes/Gun')
 local katanaClass=requireAt(ps,'Modules/Items/Katana')
 local scopeClass=requireAt(ps,'Modules/ClientReplicatedClasses/ClientFighter/ClientItem/ItemInterface/Mouse/Scope')
 local flashClass=requireAt(ps,'Modules/ClientReplicatedClasses/ClientFighter/FighterInterface/Flashed')
 local smokeClass=requireAt(ps,'Modules/ClientReplicatedClasses/ClientFighter/FighterInterface/SmokeScreen')
 if not (fc and camera and items and vmClass and gunClass and utility) then error('Fighter runtime is not ready; re-execute after the client loads.') end
 local A={native=true,name='Fighter1076',thirdPerson=false,targetGroups={Head={'Head'},Body={'Body'}},skinChoices={'Original'},weaponChoices={},modelChoices={}}
 A.defaultFov=camera._base_fov
 A.mapChoices={'Select a map'}
 A.mapVoteSupported=duels~=nil and duelLibrary~=nil
 if duelLibrary and type(duelLibrary.Maps)=='table'then
  local names={};for name in pairs(duelLibrary.Maps)do if type(name)=='string'then table.insert(names,name)end end
  table.sort(names);for _,name in ipairs(names)do table.insert(A.mapChoices,name)end
 end
 local diagnostics={adapter=A.name,errors=0,skin='Original',skinApplications=0,seedSupported=false}
 local stopped=false
 local function atGameIdentity(fn)
  local previous=getthreadidentity and getthreadidentity()
  if setthreadidentity then setthreadidentity(2)end
  local result=table.pack(pcall(fn))
  if setthreadidentity and previous then setthreadidentity(previous)end
  if not result[1]then error(result[2],0)end
  return table.unpack(result,2,result.n)
 end
 local function hook(object,name,wrap,bag)
  if type(object)~='table' or type(object[name])~='function' then return end
  local had=rawget(object,name);local original=object[name];local replacement=wrap(original)
  object[name]=replacement
  table.insert(bag or cleanups,function()if object[name]==replacement then object[name]=had end end)
 end
 local function signal()
  local event=Instance.new('BindableEvent')
  table.insert(cleanups,function()event:Destroy()end)
  return {Connect=function(_,fn)return event.Event:Connect(fn)end,Fire=function(_,...)event:Fire(...)end}
 end
 local function localFighter()return fc.LocalFighter end
 local function item()local f=localFighter();return f and f.EquippedItem end
 local pitchProvider
 local nativeCameraReplicationLoop=fc._CameraReplicationLoop
 A.pitchSupported=type(nativeCameraReplicationLoop)=='function'and type(utility.EncodeCameraRotation)=='function'and type(jointsClass)=='table'and type(jointsClass.Update)=='function'
 function A.canReplicatePitch()
  local f=localFighter()
  return f~=nil and f:Get('IsSpectating')==true and not not camera:GetPublicState()
 end
 function A.setPitchProvider(fn)
  local previous=pitchProvider;pitchProvider=fn
  return function()if pitchProvider==fn then pitchProvider=previous end end
 end
 if A.pitchSupported then
  hook(utility,'EncodeCameraRotation',function(original)return function(self,rotation,...)
   -- Only the game's periodic cosmetic camera report uses the posed pitch.
   -- Other encodes and all shot/camera CFrames retain the true aiming direction.
   if debug.info(2,'f')==nativeCameraReplicationLoop and rotation==camera.Rotation and pitchProvider then
    local pitch=pitchProvider()
    if type(pitch)=='number'then
     diagnostics.pitchReports=(diagnostics.pitchReports or 0)+1
     rotation=Vector2.new(pitch,rotation.Y)
    end
   end
   return original(self,rotation,...)
  end end)
  hook(jointsClass,'Update',function(original)return function(self,dt,data,...)
   if self.ClientFighterCharacter.ClientFighter==localFighter()and pitchProvider and typeof(data.CameraRotationRaw)=='Vector2'then
    local pitch=pitchProvider()
    if type(pitch)=='number'then
     data=table.clone(data);data.CameraRotationRaw=Vector2.new(pitch,data.CameraRotationRaw.Y)
    end
   end
   return original(self,dt,data,...)
  end end)
 end
 local owners,entries={},{}
 local nextRefresh=0
 local function refresh(force)
  if not force and os.clock()<nextRefresh then return end
  nextRefresh=os.clock()+.2;table.clear(owners);table.clear(entries)
  local localActor=localFighter();local environment=localActor and localActor:Get('EnvironmentID')
  for _,f in pairs(fc.Objects)do
   local e=f.Entity;local owner=f.Player or e and e.Model
   if owner and e and e.Model and e.Model.Parent then
    entries[owner]={fighter=f,entity=e};if owner==player or e:Get('EnvironmentID')==environment then table.insert(owners,owner)end
   end
  end
  for _,e in pairs(enemies and enemies.Objects or {})do
   if e.Model and e.Model.Parent and e.Humanoid and not entries[e.Model] then entries[e.Model]={entity=e};if e:Get('EnvironmentID')==environment then table.insert(owners,e.Model)end end
  end
 end
 local function entry(owner)refresh();return entries[owner]end
 local deflection=KatanaDeflect.new(os.clock)
 hook(katanaClass,'_StartDeflecting',function(original)return function(self,...)
  local result=table.pack(original(self,...));deflection.start(self);return table.unpack(result,1,result.n)
 end end)
 hook(katanaClass,'_StopDeflecting',function(original)return function(self,...)
  local result=table.pack(original(self,...));deflection.stop(self);return table.unpack(result,1,result.n)
 end end)
 function A.isDeflecting(owner)
  local r=entry(owner)
  return deflection.active(r and r.fighter and r.fighter.EquippedItem)
 end
 function A.isShielding(owner)
  local r=entry(owner)
  return ShieldGuard.fighter(r and r.fighter)
 end
 function A.health(owner)
  local r=entry(owner);local e=r and r.entity
  if not e then return 0,0 end
  return e:GetHealth(),e:GetMaxHealth()
 end
 function A.datum(owner,names)
  local r=entry(owner);if not r then return nil end
  local f,e=r.fighter,r.entity;local w=f and f.EquippedItem
  for _,n in ipairs(names)do
   if n=='BotHealth' or n=='Health' then return e:GetHealth()
   elseif n=='BotMaxHealth' or n=='MaxHealth' then return e:GetMaxHealth()
   elseif n=='Dead' then return not e:IsAlive()
   elseif n=='CurrentWeapon' then return w and w.Name
   elseif n=='Ammo' then return w and w:Get('Ammo')
   elseif n=='MaxAmmo' then return w and w.Info.MaxAmmo
   elseif n=='Aiming' or n=='OwnAiming' then return w and w:Get('IsAiming')
   elseif n=='Team' then return f and f:Get('TeamID') or e:Get('TeamID') end
  end
 end
 local function hostile(_,owner)
  if owner==player then return false end
  local r=entry(owner);local f=localFighter()
  if not (r and f and f.Entity) then return false end
  if r.entity:Get('EnvironmentID')~=f:Get('EnvironmentID') then return false end
  local lookup=f:GetEntityLookupParams()
  return (lookup.TeamkillEnabled or not (lookup.TeamID and r.entity:Get('TeamID')==lookup.TeamID))==true
 end
 local participant={}
 function participant.All()refresh();return table.clone(owners)end
 function participant.BodyOf(owner)local r=entry(owner);return r and r.entity.Model end
 function participant.NameOf(owner)return owner.Name end
 function participant.ByIdOf(id)for _,p in ipairs(Players:GetPlayers())do if p.UserId==id then return p end end end
 local localVisualProvider
 function A.setLocalVisualProvider(fn)
  local previous=localVisualProvider;localVisualProvider=fn
  return function()if localVisualProvider==fn then localVisualProvider=previous end end
 end
 local merc={GetVisual=function(owner)
  if owner==player and localVisualProvider then local model=localVisualProvider();if model and model.Parent then return model end end
  return participant.BodyOf(owner)
 end}
 local hostility={IsHostile=hostile,TeamOf=function(owner)return A.datum(owner,{'Team'})end}
 function A.zones(owner,small)
  local r=entry(owner);local result={}
  if small==nil then local w=item();small=w and w.Info.RaycastGrabSmallHitboxes or false end
  if r then for _,part in pairs(r.entity:GetHitboxes(small))do
   if part.Name=='HitboxHead' or part.Name=='HitboxHeadSmall'then result.Head=part elseif part.Name=='HitboxBody' or part.Name=='HitboxBodySmall'then result.Body=part end
  end end
  return result
 end
 function A.zone(part)return (part.Name=='HitboxHead' or part.Name=='HitboxHeadSmall')and 'Head'or 'Body'end
 function A.weaponIcon(name)local info=items.Items[name];return info and info.Image end
 function A.sampleSpread(direction,angle,index,samples)
  local phi=index*2.399963229728653
  return (CFrame.lookAt(Vector3.zero,direction)*CFrame.Angles(0,0,phi)*CFrame.Angles(math.rad(angle)*(index+.5)/samples,0,0)).LookVector
 end
 function A.chassis(owner)
  local r=entry(owner);local result={}
  if r then
   for _,p in pairs(r.entity:GetHitboxes())do table.insert(result,{part=p})end
   if #result==0 then for _,p in ipairs(r.entity.Model:GetChildren())do
    if p:IsA('BasePart') and p.Name~='HumanoidRootPart' and (p.Name=='Head' or p.Name:find('Torso') or p.Name:find('Arm') or p.Name:find('Leg') or p.Name:find('Hand') or p.Name:find('Foot'))then table.insert(result,{part=p})end
   end end
  end
  return result
 end
 function A.actorModels()
  local result={}
  for _,f in pairs(fc.Objects)do if f.Entity and f.Entity.Model then table.insert(result,f.Entity.Model)end end
  for _,e in pairs(enemies and enemies.Objects or {})do if e.Humanoid and e.Model then table.insert(result,e.Model)end end
  return result
 end
 local cosmeticCache=setmetatable({},{__mode='k'})
 function A.paintCosmetics(model,enabled,refresh)
  local saved=cosmeticCache[model]
  if not enabled then
   if saved then for node,props in pairs(saved)do if node.Parent then for prop,value in pairs(props)do node[prop]=value end end end end
   cosmeticCache[model]=nil;return
  end
  if not saved then saved={};cosmeticCache[model]=saved;refresh=true end
  if refresh then for _,node in ipairs(model:GetDescendants())do if not saved[node]then
   if node:IsA('Shirt')then saved[node]={ShirtTemplate=node.ShirtTemplate}
   elseif node:IsA('Pants')then saved[node]={PantsTemplate=node.PantsTemplate}
   elseif node:IsA('ShirtGraphic')then saved[node]={Graphic=node.Graphic}
   elseif node:IsA('SpecialMesh')then saved[node]={TextureId=node.TextureId,VertexColor=node.VertexColor}
   elseif node:IsA('Decal')or node:IsA('Texture')then saved[node]={Transparency=node.Transparency}end
  end end end
  for node,props in pairs(saved)do if node.Parent then
   for prop in pairs(props)do
    local value=prop=='Transparency' and 1 or prop=='VertexColor' and Vector3.one or ''
    if node[prop]~=value then node[prop]=value end
   end
  end end
 end
 table.insert(cleanups,function()for model in pairs(cosmeticCache)do A.paintCosmetics(model,false)end end)
 function A.avatarTemplate()
  return atGameIdentity(function()
   local f=localFighter();local e=f and f.Entity
   if not e then return nil end
   local clone=e.Visibility:CloneModel()
   for _,part in ipairs(clone:GetDescendants())do if part:IsA('BasePart')or part:IsA('Decal')then part.LocalTransparencyModifier=0 end end
   local idle
   local animator=e.Model:FindFirstChildWhichIsA('Animator',true)
   if animator then for _,track in ipairs(animator:GetPlayingAnimationTracks())do
    if track.Looped and track.Priority==Enum.AnimationPriority.Idle and track.Animation then idle=track.Animation:Clone();break end
   end end
   return clone,idle
  end)
 end
 local nativeWeapons,bulletDefs={},{}
 for name,info in pairs(items.Items)do
  local spec=table.clone(info)
  spec.Category=info.Class=='Secondary' and 'Pistol' or name=='Sniper' and 'Sniper' or name=='Uzi' and 'SMG' or 'Rifle'
  spec.HeadshotMult=(info.CriticalDamage or info.ShootDamage or 0)/math.max(info.ShootDamage or 1,.001)
  spec.Projectile=name;spec.Range=10000;spec.SpreadAngle=0
  nativeWeapons[name]=spec
  bulletDefs[name]={Speed=info.IsProjectile and info.ProjectileSpeed or 0,MaxDistance=10000,Acceleration=Vector3.new(0,-(info.ProjectileGravity or 0),0)}
 end
 local damage={}
 function damage.BaseDamageAtDistance(spec,distance)
  local start=spec.RaycastDamageDropoffStartDistance or math.huge
  local finish=spec.RaycastDamageDropoffEndDistance or start
  local blend=finish>start and math.clamp((distance-start)/(finish-start),0,1) or (distance>start and 1 or 0)
  return (spec.ShootDamage or 0)*(1+((spec.RaycastDamageDropoffMultiplier or 1)-1)*blend)
 end
 function damage.Multiplier()return 1 end
 local gun={Fired=signal()}
 local beforeShot={}
 function A.onBeforeShot(fn)
  beforeShot[fn]=true;return function()beforeShot[fn]=nil end
 end
 hook(gunClass,'StartShooting',function(original)return function(self,...)
  if self.ClientFighter==localFighter()then for fn in pairs(beforeShot)do fn()end end
  return original(self,...)
 end end)
 local weapons=setmetatable({},{__mode='k'})
 local function weapon()
  local w=item();if not w then return nil end
  if not weapons[w] then
   local wrapper={}
   function wrapper:TimeUntilNextPull()return math.max(0,math.max(w._shoot_cooldown or 0,w._shoot_cooldown_no_ammo or 0)-tick())end
   function wrapper:ReleaseTrigger()end
   weapons[w]=setmetatable(wrapper,{__index=function(_,key)
    if key=='Name' then return w.Name elseif key=='Model' then return w.ViewModel and w.ViewModel.Model
    elseif key=='MagAmmo' then return w:Get('Ammo') elseif key=='MaxMagSize' then return w.Info.MaxAmmo
    elseif key=='IsReloading' then return tick()<(w._reload_cooldown or 0)
    elseif key=='BurstFiring' then return false elseif key=='FireMode' then return 'auto' end
   end})
  end
  return weapons[w]
 end
 setmetatable(gun,{__index=function(_,key)
  local f,w=localFighter(),item()
  if key=='Weapon' then return weapon() elseif key=='Enabled' then return f and f:IsAlive() and f:IsActive()
  elseif key=='AimHeld' then return w and w:Get('IsAiming') elseif key=='AimAmount' then return w and w.ViewModel and w.ViewModel.CurrentAimValue or 0
  elseif key=='SwapPhase' then return w and w:IsEquipping() and 'equipping' or 'idle'
  elseif key=='FireHeld' then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
  elseif key=='_launcher' then return w and w.Info.IsProjectile elseif key=='_isGenericItem' then return w and w.Info.Type~='Gun' end
 end})
 function gun:ShouldBlockWeaponInput()
  local f,w=localFighter(),item()
  return not (f and w and f:IsAlive() and f:IsActive() and camera:GetCurrentSubject()==f and atGameIdentity(function()return f:CanUseWeapon(w.Name)end))
 end
 local function eye()
  local f=localFighter()
  return f and f.Entity and camera:GetCameraCFrame(f) or workspace.CurrentCamera.CFrame
 end
 local avatar,avatarParts,avatarSaved,avatarConnection=nil,{},{}
 local avatarTransparencySaved={}
 local avatarHiddenProvider
 function A.setAvatarHiddenProvider(fn)
  local previous=avatarHiddenProvider;avatarHiddenProvider=fn
  return function()if avatarHiddenProvider==fn then avatarHiddenProvider=previous end end
 end
 local function restoreAvatar()
  for part,value in pairs(avatarSaved)do if part.Parent then
   part.LocalTransparencyModifier=value
   if avatarTransparencySaved[part]~=nil then part.Transparency=avatarTransparencySaved[part]end
  end end
  table.clear(avatarSaved)
  table.clear(avatarTransparencySaved)
 end
 function A.firstPerson(owner)
  local r=entry(owner);local f=r and r.fighter
  return f and camera:GetCurrentSubject()==f and camera.CameraState:GetPublicState()=='FirstPerson' and f:IsActive()==true
 end
 function A.restoreVisibility(owner)
  local r=owner and entry(owner);local f=r and r.fighter or localFighter();local e=f and f.Entity
  if e and e.Visibility then e.Visibility:_Verify(true)end
 end
 local function enforceAvatar()
  local f=localFighter();local e=f and f.Entity;local model=e and e.Model
  if model~=avatar then
   restoreAvatar();if avatarConnection then avatarConnection:Disconnect()end
   avatar=model;table.clear(avatarParts)
   local function add(part)if part:IsA('BasePart')or part:IsA('Decal')then table.insert(avatarParts,part)end end
   if model then
    for _,part in ipairs(model:GetDescendants())do add(part)end
    avatarConnection=model.DescendantAdded:Connect(add)
    A.restoreVisibility()
   end
  end
  if A.firstPerson(player)or avatarHiddenProvider and avatarHiddenProvider()==true then
   for _,part in ipairs(avatarParts)do if part.Parent and part:IsDescendantOf(avatar)then
    if avatarSaved[part]==nil then avatarSaved[part]=part.LocalTransparencyModifier end
    if avatarTransparencySaved[part]==nil then avatarTransparencySaved[part]=part.Transparency end
    part.LocalTransparencyModifier=1
    part.Transparency=1 -- The native head renderer independently resets its local modifier.
   elseif avatarSaved[part]~=nil then
    if part.Parent then
     part.LocalTransparencyModifier=avatarSaved[part]
     if avatarTransparencySaved[part]~=nil then part.Transparency=avatarTransparencySaved[part]end
    end
    avatarSaved[part]=nil
    avatarTransparencySaved[part]=nil
   end end
  elseif next(avatarSaved) then restoreAvatar();A.restoreVisibility()end
 end
 function A.refreshAvatarVisibility()return atGameIdentity(enforceAvatar)end
 table.insert(cleanups,function()atGameIdentity(function()
  if avatarConnection then avatarConnection:Disconnect()end
  restoreAvatar();A.restoreVisibility()
 end)end)
 local pov={GetEyeCFrame=eye,GetEyePosition=function()return eye().Position end}
 function gun:GetFireDirectionUnspread()return eye().LookVector end
 function gun:GetAimDirection()return self:GetFireDirectionUnspread()end
 function gun:GetFireDirection()return self:GetFireDirectionUnspread()end
 function gun:GetActiveProjectileMuzzleWorldCFrame()
  local w=item();local vm=w and w.ViewModel;local attachment=vm and vm:GetMuzzleAttachment()
  return attachment and attachment.WorldCFrame or eye()
 end
 function gun:GetMuzzleWorldPosition()return self:GetActiveProjectileMuzzleWorldCFrame().Position end
 function gun:_GetEffectiveBloomDeg()
  local f,w=localFighter(),item();if not w then return 0 end
  local info=w.Info
  local velocity=f.Entity and f.Entity.RootPart.AssemblyLinearVelocity.Magnitude or 0
  local spread=(info.ShootSpread or 0)+math.min(info.ShootSpreadPerVelocityLimit or 0,velocity*(info.ShootSpreadPerVelocityUnit or 0))
  return spread*math.min(w:IsFullyAiming() and (info.AimSpreadMultiplier or 1) or 1,f:IsCrouching() and .75 or 1)
 end
 function gun:StartAiming()local f=localFighter();if f then return atGameIdentity(function()return f:Input('StartAiming')end)end end
 function gun:StopAiming()local f=localFighter();if f then return atGameIdentity(function()return f:Input('FinishAiming')end)end end
 function gun:FireWeapon()
  if self:ShouldBlockWeaponInput() then return false end
  local f,w=localFighter(),item()
  if not (w.Info.IsRaycast and w.Info.Type=='Gun') or w:IsEquipping() or tick()<math.max(w._shoot_cooldown or 0,w._shoot_cooldown_no_ammo or 0,w._reload_cooldown or 0)then return false end
  local before=w._last_shot
  atGameIdentity(function()f:Input('StartShooting')end) -- Native input owns ammo, reloads, cooldowns and replication.
  return w._last_shot~=before
 end
 local bullets={ShotEmitted=signal(),HitConfirmed=signal()}
 local combat={LocalHit=signal()}
 function bullets.ProjectileParams()
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.IgnoreWater=true
  local f=localFighter();local list=f and Collection:GetTagged('RaycastWhitelist'..(f:Get('EnvironmentID') or '')) or {}
  local lookup=f and f:GetEntityLookupParams()
  for _,owner in ipairs(participant.All())do
   local r=entry(owner)
   if owner~=player and lookup and r and lookup:IsValidTarget(r.entity)then for _,part in pairs(A.zones(owner))do table.insert(list,part)end end
  end
  params.FilterDescendantsInstances=list;return params
 end
 function bullets:AssistSupported(name)local info=items.Items[name];return info and info.Type=='Gun' and info.IsRaycast and (info.ShootDamage or 0)>0 end
 function bullets:PredictHit(name,origin,direction,muzzle,slack,predicate)
  local params=bullets.ProjectileParams()
  local hit=workspace:Raycast(origin,direction*10000,params)
  -- Native eye and muzzle must both clear the map.
  if hit and predicate(hit.Instance) then
   if muzzle and (muzzle.Position-origin).Magnitude>.1 then
    local clearance=workspace:Raycast(muzzle.Position,hit.Position-muzzle.Position,params)
    if clearance and not predicate(clearance.Instance) then return nil end
   end
   return hit.Instance
  end
 end
 local active=setmetatable({},{__index=function(_,key)
  if key=='_yawCurrent' or key=='_yawTarget' then return camera.Rotation.Y elseif key=='_pitchCurrent' or key=='_pitchTarget' then return camera.Rotation.X end
 end,__newindex=function(_,key,value)
  if key=='_yawCurrent' or key=='_yawTarget' then camera:SetRotation(Vector2.new(camera.Rotation.X,value))
  elseif key=='_pitchCurrent' or key=='_pitchTarget' then camera:SetRotation(Vector2.new(value,camera.Rotation.Y)) end
 end})
 local render={_active=active,_render=function()end}
 -- Mechanics owns character facing independently of the camera render pass.
 -- Apply the body-only pose after its final write, preserving the native movement update.
 hook(mechanics,'_UpdateCharacterRotation',function(original)return function(self,...)
  local result=table.pack(original(self,...))
  if not stopped then render._render(active)end
  if not stopped then enforceAvatar()end
  return table.unpack(result,1,result.n)
 end end)
 local nativeMoveFn,nativeMoveArgs
 local move={SpeedMultiplier=1,GetWishDir=function()
  local f=localFighter()
  if not (nativeMoveFn and f)then return Vector3.zero end
  return nativeMoveFn(f,table.unpack(nativeMoveArgs or {},1,nativeMoveArgs and nativeMoveArgs.n or 0))
 end}
 setmetatable(move,{__index=function(_,key)
  if key=='Velocity'then local f=localFighter();local root=f and f.Entity and f.Entity.RootPart;return root and root.AssemblyLinearVelocity or Vector3.zero end
 end,__newindex=function(self,key,value)
  if key=='Velocity'then local f=localFighter();local root=f and f.Entity and f.Entity.RootPart;if root then root.AssemblyLinearVelocity=value end
  else rawset(self,key,value)end
 end})
 local lastOverride,lastPOV=camera._third_person_override,camera.CameraState._pov_state
 local viewOwned=false
 local nativeFov=workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or camera._base_fov
 local function gameSetting(name,fallback)
  if playerData then local ok,value=pcall(function()return atGameIdentity(function()return playerData:GetSetting(name)end)end);if ok and value~=nil then return value end end
  return fallback
 end
 A.worldStatus={requested=false,active=false,phase='first person',errors=0}
 local function nativeView(dt)
  local f,w=localFighter(),item()
  local requested=getValue('World/View/Thirdperson')==true
  local want=requested and f and f:IsAlive() and f:IsActive() and camera:GetCurrentSubject()==f
  if w and w.Info.AimScopePercent and w:Get('IsAiming') then want=false end
  if want then
   if not viewOwned then lastOverride=camera._third_person_override;lastPOV=camera.CameraState._pov_state;viewOwned=true end
   if camera._third_person_override~=true then camera:SetThirdPersonOverride(true)end
   if camera.CameraState._pov_state~='ThirdPerson' then camera.CameraState:_SetPOVState('ThirdPerson')end
   camera._pov_spring.Target=Vector3.new(1.1,.45,(tonumber(getValue('World/View/Distance')) or 120)/20)
  elseif viewOwned then
   camera:SetThirdPersonOverride(lastOverride);camera.CameraState:_SetPOVState(lastPOV or 'FirstPerson');viewOwned=false
  end
  A.thirdPerson=want==true;A.worldStatus.requested=requested;A.worldStatus.active=A.thirdPerson
  A.worldStatus.phase=A.thirdPerson and 'native third person' or 'first person'
 end
 hook(camera,'_Modal',function(original)return function(self,...)return isMenuOpen() or original(self,...)end end)
 hook(camera,'_InputChanged',function(original)return function(self,...)if not isMenuOpen()then return original(self,...)end end end)
 hook(camera,'Update',function(original)return function(self,dt,...)
  if stopped then return original(self,dt,...)end
  nativeView(dt)
  local result=table.pack(original(self,dt,...))
  local cam=workspace.CurrentCamera
  if cam then
   if not self.IsFrozen and self.CameraState:GetPublicState()~=self.CameraState.States.CustomFreecam then nativeFov=cam.FieldOfView end
   local requestedFov=tonumber(getValue('World/View/Override FOV'))
   -- Apply after the native camera, so ADS, sprinting and recoil cannot alter it.
   if requestedFov then cam.FieldOfView=math.clamp(requestedFov,30,120)end
  end
  return table.unpack(result,1,result.n)
 end end)
 local posePending=false
 connect(Run.RenderStepped,function(dt)
  if stopped or posePending then return end;posePending=true
  task.defer(function()
   posePending=false
   if not stopped then render._render(active,dt);enforceAvatar()end
  end)
 end)
 table.insert(cleanups,function()
  stopped=true
  if viewOwned then camera:SetThirdPersonOverride(lastOverride);camera.CameraState:_SetPOVState(lastPOV or 'FirstPerson')end
  if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=nativeFov end
  atGameIdentity(function()camera:Update(0)end)
 end)
 local boundFighter,boundItem;local fighterCleanup,itemCleanup={},{}
 local function clear(list)for i=#list,1,-1 do pcall(list[i]);list[i]=nil end end
 local lastSkinVM,lastSkinName,lastSkinInvert
 local shotTargetProvider,hideScopeProvider,hideShotsProvider
 function A.setShotTargetProvider(fn)
  local previous=shotTargetProvider;shotTargetProvider=fn;return function()if shotTargetProvider==fn then shotTargetProvider=previous end end
 end
 function A.setHideScopeProvider(fn)
  local previous=hideScopeProvider;hideScopeProvider=fn;return function()if hideScopeProvider==fn then hideScopeProvider=previous end end
 end
 function A.setHideShotsProvider(fn)
  local previous=hideShotsProvider;hideShotsProvider=fn;return function()if hideShotsProvider==fn then hideShotsProvider=previous end end
 end
 function A.hideShotsActive()
  return not stopped and hideShotsProvider~=nil and hideShotsProvider()==true
 end
 local scopeOwned=setmetatable({},{__mode='k'})
 local nativeScopeActive=scopeClass and scopeClass.SetActive
 local function updateScope(scope)
  if not scope or scope._destroyed or not scope.Frame or not scope.Frame.Parent then return end
  if hideScopeProvider and hideScopeProvider()then scopeOwned[scope]=true;scope.Frame.Visible=false
  elseif scopeOwned[scope]then scopeOwned[scope]=nil;nativeScopeActive(scope,scope:IsActive())end
 end
 for _,method in ipairs({'SetActive','Update'})do
  hook(scopeClass,method,function(original)return function(self,...)
   local result=table.pack(original(self,...));updateScope(self);return table.unpack(result,1,result.n)
  end end)
 end
 table.insert(cleanups,function()atGameIdentity(function()
  for scope in pairs(scopeOwned)do if not scope._destroyed and scope.Frame.Parent then nativeScopeActive(scope,scope:IsActive())end end
 end)end)
 local visualSwap=nil
 local nativeGetWrap=vmClass.GetWrap
 local smokeParts={}
 local smokeEffects={}
 function A.scope()
  local w=item();local mouse=w and w.ItemInterface and w.ItemInterface.Mouse
  return mouse and mouse.Scope and mouse.Scope.Frame
 end
 local function skinSelection(weaponName)
  weaponName=weaponName or item() and item().Name
  local name=getValue('Skin Changer/Local/Wrap',weaponName)
  if getValue('Skin Changer/Local/Enabled',weaponName)~=true or name=='Original' or not (cosmetics and cosmetics.Cosmetics[name] and cosmetics.Cosmetics[name].WrapGroups) then return nil end
  return {Name=name,Inverted=getValue('Skin Changer/Local/Inverted',weaponName)==true}
 end
 for name in pairs(items.Items)do if items.ViewModels[name] then
  table.insert(A.weaponChoices,name);A.modelChoices[name]={'Original',name}
 end end
 local modelCount=0
 if cosmetics then for name,info in pairs(cosmetics.Cosmetics)do
  if info.Type=='Skin' and A.modelChoices[info.ItemName] and items.ViewModels[name] then
   table.insert(A.modelChoices[info.ItemName],name);modelCount=modelCount+1
  end
 end end
 table.sort(A.weaponChoices)
 for _,choices in pairs(A.modelChoices)do table.sort(choices,function(a,b)if a=='Original'then return true elseif b=='Original'then return false end;return a:lower()<b:lower()end)end
 diagnostics.modelSkins=modelCount;diagnostics.weapons=#A.weaponChoices
 function A.createVisual(base,modelName,clientItem)
  local current=item();local original=current and current.ViewModel
  if not original then error('The equipped viewmodel is not ready.')end
  if not table.find(A.modelChoices[base] or {},modelName)then error('This skin does not belong to '..tostring(base))end
  local owner=clientItem or setmetatable({Name=base,Info=items.Items[base],ClientFighter=localFighter()},{__index=current})
  local encoded={[original:ToEnum('Name')]=modelName}
  if clientItem then
   for _,key in ipairs({'Wrap','Charm'})do local value=original:Get(key);if value~=nil then encoded[original:ToEnum(key)]=value end end
  end
  return atGameIdentity(function()return vmClass.new({Data=encoded},owner)end)
 end
 function A.preview(base,modelName,wrap,inverted)
  return atGameIdentity(function()
   modelName=modelName=='Original'and base or modelName
   assert(modelName==base or table.find(A.modelChoices[base]or {},modelName),'This skin does not belong to '..tostring(base))
   if wrap and wrap~='Original'then assert(cosmetics and cosmetics.Cosmetics[wrap]and cosmetics.Cosmetics[wrap].WrapGroups,'Weapon finish is not available')end
   local folder=ps:FindFirstChild('Assets');folder=folder and folder:FindFirstChild('ViewModels')
   local asset=folder and utility:LookThrough(folder,modelName)
   return CataloguePreview.build(asset,wrapController,wrap,inverted,Collection)
  end)
 end
 local function restoreVisual()
  local s=visualSwap;visualSwap=nil
  if not s then return end
  if s.item.ViewModel==s.replacement then
   s.item.ViewModel=s.original
   if not s.original._destroyed then
    local previous=rawget(s.original,'GetWrap')
    s.original.GetWrap=function(self)return nativeGetWrap(self)end
    local ok,err=pcall(s.original._UpdateWrap,s.original);s.original.GetWrap=previous
    if not ok then error(err,0)end
    if s.item.IsEquipped then s.original:SetParent(s.parent);s.original:Equip(true);s.original._equip_spring.Value=1 end
    if s.item.ChangeShootAnimationNamePrefix and s.prefix then s.item:ChangeShootAnimationNamePrefix(s.prefix)end
   end
  elseif not s.original._destroyed then
   s.original:Destroy()
  end
  if not s.replacement._destroyed then s.replacement:Destroy()end
 end
 local function updateVisual(w)
  local enabled=w and getValue('Skin Changer/Local/Enabled',w.Name)==true
  local model=enabled and getValue('Skin Changer/Local/Model',w.Name) or 'Original'
  if model==nil then model='Original'end
  if visualSwap and (visualSwap.item~=w or visualSwap.model~=model or w.ViewModel~=visualSwap.replacement)then restoreVisual()end
  if not (w and enabled and model~='Original' and table.find(A.modelChoices[w.Name] or {},model)) then return end
  if visualSwap then return end
  local original=w.ViewModel
  if not original or original._destroyed or original.Name==model then return end
  local replacement=A.createVisual(w.Name,model,w)
  if stopped or item()~=w or w.ViewModel~=original then replacement:Destroy();return end
  visualSwap={item=w,original=original,replacement=replacement,model=model,prefix=w._shoot_animation_name_prefix,parent=original.Model.Parent}
  original:Unequip();original:SetParent(RS.Assets.Temp.ViewModels)
  w.ViewModel=replacement
  if w.IsEquipped then replacement:Equip(true);replacement._equip_spring.Value=1 end
  if w.ChangeShootAnimationNamePrefix and w._shoot_animation_name_prefix then w:ChangeShootAnimationNamePrefix(w._shoot_animation_name_prefix)end
  diagnostics.model=model
 end
 if cosmetics then for name,info in pairs(cosmetics.Cosmetics)do
  if info.WrapGroups and name~='MISSING_WRAP' then table.insert(A.skinChoices,name)end
 end end
 table.sort(A.skinChoices,function(a,b)if a=='Original'then return true elseif b=='Original'then return false end;return a:lower()<b:lower()end)
 hook(vmClass,'GetWrap',function(original)return function(self,...)
  if self.ClientItem and self.ClientItem.ClientFighter==localFighter() then
   local selected=skinSelection(self.ClientItem.Name);if selected then return selected end
  end
  return original(self,...)
 end end)
 local originalShake=camera._shake_enabled;local quietOwned=false
 hook(smokeClass,'Update',function(original)return function(self,...)
  local result=table.pack(original(self,...))
  if table.find(getValue('World/Removals/Removals') or {},'Smoke')then self:Hide()end
  return table.unpack(result,1,result.n)
 end end)
 local nativeFlashVisibility=flashClass and flashClass._UpdateVisibility
 hook(flashClass,'_UpdateVisibility',function(original)return function(self,...)
  if table.find(getValue('World/Removals/Removals') or {},'Flash') then
   for _,objects in pairs(self._flash_objects)do for _,pair in pairs(objects)do
    pcall(function()pair[1].Parent=nil end)
   end end
   return
  end
  return original(self,...)
 end end)
 hook(vmClass,'ApplyRecoil',function(original)return function(self,...)
  local removals=getValue('World/Removals/Removals') or {}
  if self.ClientItem.ClientFighter==localFighter() and table.find(removals,'Visual Recoil')then return end
  return original(self,...)
 end end)
 hook(vmClass,'PlayHitmarkerSound',function(original)return function(self,critical,volume,...)
  if self.ClientItem.ClientFighter==localFighter() then bullets.HitConfirmed:Fire(nil,0,critical==true,eye().Position)end
  return original(self,critical,volume,...)
 end end)
 local function bind()
  local f,w=localFighter(),item()
  atGameIdentity(function()updateVisual(w)end)
  if f~=boundFighter then
   clear(fighterCleanup);boundFighter=f
   if f then
    hook(f,'GetCameraData',function(original)return function(self,...)
     local data=original(self,...)
     if not isMenuOpen() and not gun:ShouldBlockWeaponInput() then
      -- Network calls use encoded CFrame tables; local tracer calls request raw
      -- CFrames. Keep the complete packet in the format returned by the game.
      local encoded=type(data[string.char(0)])=='table'
      local shotFrame=ShotPacket.read(data,string.char(0),utility)
      local cameraFrame=ShotPacket.read(data,string.char(1),utility)
      if not (shotFrame and cameraFrame)then return data end
      local point,part,offset
      local shotOrigin=shotFrame.Position
      if shotTargetProvider then point,part,offset=shotTargetProvider(shotOrigin)end
      if point and part and part.Parent then
       data=table.clone(data)
       for _,key in ipairs({string.char(0),string.char(1)})do
        local cf=ShotPacket.read(data,key,utility)
        if (point-cf.Position).Magnitude>.001 then ShotPacket.write(data,key,CFrame.lookAt(cf.Position,point),utility,encoded)end
       end
       data[string.char(2)]=part
       ShotPacket.write(data,string.char(3),offset or part.CFrame:ToObjectSpace(CFrame.new(point)),utility,encoded)
       -- Native local tracers pass an already sampled spread rotation. Preserve it:
       -- their target reference must describe the spread ray, not the center aim point.
       local spread=select(2,...)
       if typeof(spread)=='CFrame' then
        local cf=ShotPacket.read(data,string.char(1),utility);local params=bullets.ProjectileParams()
        local direction=(cf*spread).LookVector
        local far=cf.Position+direction*10000
        local first=workspace:Raycast(cf.Position,direction*10000,params)
        if first then far=first.Position end
        local hit=workspace:Raycast(shotOrigin,far-shotOrigin,params)
        if hit and hit.Instance:IsA('BasePart')then
         data[string.char(2)]=hit.Instance
         ShotPacket.write(data,string.char(3),hit.Instance.CFrame:ToObjectSpace(CFrame.new(hit.Position)),utility,encoded)
        else data[string.char(2)]=nil;data[string.char(3)]=nil end
       end
       return data
      end
      local direction=gun:GetFireDirectionUnspread()
      local native=eye().LookVector
      if direction and (direction-native).Magnitude>1e-6 then
       data=table.clone(data)
       for _,key in ipairs({string.char(0),string.char(1)})do
        local cf=ShotPacket.read(data,key,utility)
        ShotPacket.write(data,key,CFrame.lookAt(cf.Position,cf.Position+direction),utility,encoded)
       end
       data[string.char(2)]=nil;data[string.char(3)]=nil
      end
     end
     return data
    end end,fighterCleanup)
    local nativeMove=f.GetMoveVector
    nativeMoveFn=nativeMove
    hook(f,'GetMoveVector',function()return function(self,...)
     if self~=localFighter()then return nativeMove(self,...)end
     local previous=nativeMoveArgs;nativeMoveArgs=table.pack(...)
     local result=table.pack(pcall(move.GetWishDir,move));nativeMoveArgs=previous
     if not result[1]then error(result[2],0)end
     if typeof(result[2])=='Vector3' then result[2]=result[2]*move.SpeedMultiplier end
     return table.unpack(result,2,result.n)
    end end,fighterCleanup)
   end
  end
  if w~=boundItem then
   clear(itemCleanup);boundItem=w
   if w and w.Shot then
    local c=w.Shot:Connect(function()gun.Fired:Fire()end);table.insert(itemCleanup,function()c:Disconnect()end)
    hook(w,'_Tracers',function(original)return function(self,data,...)
     if data.IsLocal and data.RaycastResults and data.RaycastResults[1] then
      local origin=eye().Position;local pos=data.RaycastResults[1].Position
      if pos then
       bullets.ShotEmitted:Fire(nil,origin,(pos-origin).Unit)
       local delta=pos-origin
       local hit=delta.Magnitude>.01 and workspace:Raycast(origin,delta+delta.Unit*.2,bullets.ProjectileParams())
       if hit and (hit.Position-pos).Magnitude<1 then combat.LocalHit:Fire(nil,pos)end
      end
     end
     return original(self,data,...)
    end end,itemCleanup)
   end
  end
  local vm=w and w.ViewModel;local selected=skinSelection(w and w.Name)
  local name=selected and selected.Name or 'Original';local invert=selected and selected.Inverted or false
  if vm~=lastSkinVM or name~=lastSkinName or invert~=lastSkinInvert then
   if lastSkinVM and not lastSkinVM._destroyed and lastSkinVM~=vm then
    -- A holstered viewmodel may remain alive; restore its native wrap immediately.
    local old=lastSkinVM.ClientItem.ClientFighter
    if old==f then
     -- _UpdateWrap on the old model must see its native replicated cosmetic.
     local previous=rawget(lastSkinVM,'GetWrap')
     lastSkinVM.GetWrap=function(self)return nativeGetWrap(self)end
     local ok,err=pcall(lastSkinVM._UpdateWrap,lastSkinVM);lastSkinVM.GetWrap=previous
     if not ok then error(err,0)end
    end
   end
   lastSkinVM,lastSkinName,lastSkinInvert=vm,name,invert
   if vm and not vm._destroyed then vm:_UpdateWrap();diagnostics.skinApplications=diagnostics.skinApplications+1 end
   diagnostics.skin=name;diagnostics.weapon=w and w.Name or nil
  end
  diagnostics.model=vm and vm.Name or nil
  local quiet=table.find(getValue('World/Removals/Removals') or {},'Visual Recoil')~=nil
  if quiet then
   if not quietOwned then originalShake=camera._shake_enabled;quietOwned=true end
   camera._shake_enabled=false
  elseif quietOwned then camera._shake_enabled=gameSetting('Camera Shake',originalShake);quietOwned=false end
  local subject=camera:GetCurrentSubject() or f
  local mouse=subject and subject.EquippedItem and subject.EquippedItem.ItemInterface and subject.EquippedItem.ItemInterface.Mouse
  if mouse then updateScope(mouse.Scope)end
  local flash=subject and subject.FighterInterface and subject.FighterInterface.Flashed
  if flash then flash:_UpdateVisibility()end
  local hideSmoke=table.find(getValue('World/Removals/Removals') or {},'Smoke')~=nil
  if hideSmoke then
   for _,inst in ipairs(Collection:GetTagged('SmokeCloud'))do
    if inst:IsA('BasePart')then
     if smokeParts[inst]==nil then smokeParts[inst]=inst.LocalTransparencyModifier end
     inst.LocalTransparencyModifier=1
    end
    local nodes=inst:GetDescendants();table.insert(nodes,inst)
    for _,node in ipairs(nodes)do
     if node:IsA('ParticleEmitter')or node:IsA('Beam')or node:IsA('Trail')or node:IsA('Smoke')or node:IsA('Fire')then
      if smokeEffects[node]==nil then smokeEffects[node]=node.Enabled;if node:IsA('ParticleEmitter')then node:Clear()end end
      node.Enabled=false
     end
    end
   end
   local screen=f and f.FighterInterface and f.FighterInterface.SmokeScreen
   if screen then screen:Hide()end
  else
   for part,value in pairs(smokeParts)do if part.Parent then part.LocalTransparencyModifier=value end;smokeParts[part]=nil end
   for node,value in pairs(smokeEffects)do if node.Parent then node.Enabled=value end;smokeEffects[node]=nil end
  end
 end
 local binding=false
 connect(Run.Heartbeat,function()
  if stopped or binding then return end;binding=true
  local ok,err=pcall(function()atGameIdentity(bind)end)
  binding=false
  if not ok then diagnostics.errors=diagnostics.errors+1;diagnostics.lastError=tostring(err);if diagnostics.errors==1 then warn('[Neverlose for RIVALS adapter] '..tostring(err))end end
 end)
 table.insert(cleanups,function()atGameIdentity(function()
  clear(itemCleanup);clear(fighterCleanup);if quietOwned then camera._shake_enabled=gameSetting('Camera Shake',originalShake)end
  restoreVisual()
  for _,f in pairs(fc.Objects)do
   local flash=f.FighterInterface and f.FighterInterface.Flashed
   if flash and nativeFlashVisibility then pcall(nativeFlashVisibility,flash)end
  end
  for part,value in pairs(smokeParts)do if part.Parent then part.LocalTransparencyModifier=value end end
  for node,value in pairs(smokeEffects)do if node.Parent then node.Enabled=value end end
  -- The class GetWrap hook is removed later in reverse cleanup order. Override only this VM
  -- during restoration, preserving native data and the original method owner.
  if lastSkinVM and not lastSkinVM._destroyed then
   local had=rawget(lastSkinVM,'GetWrap');lastSkinVM.GetWrap=function(self)return nativeGetWrap(self)end
   pcall(lastSkinVM._UpdateWrap,lastSkinVM);lastSkinVM.GetWrap=had
  end
 end)end)
 local map={
  ['Shared/Participant']=participant,['Shared/Combat/Hostility']=hostility,
  ['Client/Controllers/MercPlayerController']=merc,['Client/Controllers/GunController']=gun,
  ['Client/CameraPOV']=pov,['Client/Controllers/CameraController']=render,['Client/QuakeMove']=move,
  ['Shared/BodyDamage']=damage,['Shared/Weapons/WeaponCartridge']={SpecFor=function(_,name)return nativeWeapons[name]end},
  ['Client/Controllers/BulletController']=bullets,['Registries/Weapons']=nativeWeapons,['Registries/BulletDefs']=bulletDefs,
  ['Client/CombatSignals']=combat,
  ['Shared/Units']={StudsToMeters=function(n)return n*.28 end},
 }
 function A.resolve(path)return map[path:gsub('^Modules/','')]end
 function A.status()return table.clone(diagnostics)end
 function A.blocked()return gun:ShouldBlockWeaponInput() and 'game input blocked' or nil end
 function A.poseBlocked()
  local f=localFighter()
  if not (f and f.Entity and f:IsAlive() and f:IsActive() and camera:GetCurrentSubject()==f)then return 'not active character'end
  if f:IsSliding() or f:IsEmoting()then return 'sliding or emoting'end
 end
 function A.nativeItem()return item()end
 function A.nativeFighter()return localFighter()end
 local function mapVoteSnapshot()
  local duel=duels and duels:GetDuel(player)
  local dueler=duel and not duel._destroyed and duel:GetDueler(player)
  if not dueler then return nil end
  local voting=duel.DuelInterface and duel.DuelInterface.Voting
  return {duel=duel,options=duel:Get('VoteOptions'),kind=duel:Get('VoteOptionsType'),mode=duel:Get('VoteSelectionMode'),lastVote=dueler:Get('LastVote'),open=voting and voting:IsOpen()==true}
 end
 function A.mapVoteSnapshot()return atGameIdentity(mapVoteSnapshot)end
 function A.voteMap(name)
  return atGameIdentity(function()
   local vote=mapVoteSnapshot()
   if not(vote and vote.open and vote.kind=='Maps'and type(vote.options)=='table')then return false,'not voting for maps' end
   if tostring(vote.mode):lower():find('ban',1,true)then return false,'map banning phase' end
   for _,option in pairs(vote.options)do
    if option.Name==name then
     if option.IsBanned then return false,'map banned' end
     if vote.lastVote==name then return true,'already voted' end
     RS.Remotes.Duels.Vote:FireServer(name) -- The exact request used by the native map button.
     return true,'requested'
    end
   end
   return false,'preferred map unavailable'
  end)
 end
 function A.character()local f=localFighter();return f and f.Entity and f.Entity.Model end
 refresh(true);atGameIdentity(bind);atGameIdentity(enforceAvatar)
 return A
end

end)()

local installSkinPreview = (function()
-- A local turntable using the exact model and wrap selected for each weapon.
return function(page,adapter,Store,connect,cleanups,getValue,isMenuOpen)
 local Run=game:GetService('RunService')
 local UIS=game:GetService('UserInputService')
 local function make(class,props,parent)
  local object=Instance.new(class);for k,v in pairs(props)do object[k]=v end;object.Parent=parent;return object
 end
 local inner=page:FindFirstChild('Inner')
 for _,name in ipairs({'Left','Right'})do local col=inner:FindFirstChild(name);if col then col.Position=UDim2.new(col.Position.X.Scale,col.Position.X.Offset,0,318)end end
 local left=inner.Left
 local width=left.Size.X.Offset*2+11
 local card=make('Frame',{Name='SkinPreview',Position=UDim2.fromOffset(20,18),Size=UDim2.fromOffset(width,282),BackgroundColor3=Color3.fromRGB(5,14,25),BorderSizePixel=0,ClipsDescendants=true},inner)
 make('UICorner',{CornerRadius=UDim.new(0,7)},card)
 make('UIStroke',{Color=Color3.fromRGB(18,43,64),Thickness=1},card)
 make('UIGradient',{Rotation=80,Color=ColorSequence.new(Color3.fromRGB(12,29,46),Color3.fromRGB(3,9,18))},card)
 local function label(value,y,size,color)
  return make('TextLabel',{Position=UDim2.fromOffset(18,y),Size=UDim2.new(1,-36,0,size+7),BackgroundTransparency=1,Text=value,Font=Enum.Font.GothamMedium,TextSize=size,TextColor3=color,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=4},card)
 end
 label('LOCAL COLLECTION',14,10,Color3.fromRGB(81,153,205))
 local title=label('Weapon preview',33,19,Color3.fromRGB(234,242,250))
 local subtitle=label('',60,11,Color3.fromRGB(125,151,174))
 -- Fine grid below the turntable provides depth without obscuring dark finishes.
 for i=0,10 do make('Frame',{Position=UDim2.new(i/10,0,0,216),Size=UDim2.fromOffset(1,65),BackgroundColor3=Color3.fromRGB(21,42,59),BackgroundTransparency=.58,BorderSizePixel=0,Rotation=(i-5)*-5},card)end
 for _,y in ipairs({220,234,254,279})do make('Frame',{Position=UDim2.fromOffset(0,y),Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.fromRGB(21,42,59),BackgroundTransparency=.55,BorderSizePixel=0},card)end
 local viewport=make('ViewportFrame',{Name='Turntable',Active=true,Position=UDim2.fromOffset(8,76),Size=UDim2.new(1,-16,0,174),BackgroundTransparency=1,Ambient=Color3.fromRGB(155,163,180),LightColor=Color3.fromRGB(255,242,221),LightDirection=Vector3.new(-.8,-1,-.7),ZIndex=3},card)
 local camera=make('Camera',{FieldOfView=35},viewport);viewport.CurrentCamera=camera
 local world=make('WorldModel',{},viewport)
 local hint=label('Drag to rotate  /  scroll to zoom',257,10,Color3.fromRGB(104,134,158))
 hint.TextXAlignment=Enum.TextXAlignment.Center
 local status=label('',119,12,Color3.fromRGB(147,181,207));status.TextXAlignment=Enum.TextXAlignment.Center
 local model,signature,pending,stopped=nil,nil,false,false
 local disposeModel,requestedKey;local retryAt,failures=0,0
 local yaw,pitch,zoom=-.45,.12,1
 local radius=3;local drag=false;local lastMouse
 local generation=0
 local diagnostics={builds=0,errors=0,parts=0,retries=0,phase='idle'}
 local function releaseModel()
  if disposeModel then pcall(disposeModel);disposeModel=nil end
  if model then model:Destroy();model=nil end
 end
 local function selection()
  local weapon=Store.contexts.skins
  return weapon,getValue('Skin Changer/Local/Model') or 'Original',getValue('Skin Changer/Local/Wrap') or 'Original',getValue('Skin Changer/Local/Inverted')==true
 end
 local function rebuild()
  local weapon,skin,wrap,inverted=selection()
  local key=tostring(weapon)..'|'..skin..'|'..wrap..'|'..tostring(inverted)
  if key~=requestedKey then requestedKey=key;generation=generation+1;retryAt=0;failures=0 end
  if model and not model.Parent then releaseModel();signature=nil end
  if key==signature and model then status.Visible=false;diagnostics.phase='ready';return end
  if pending or os.clock()<retryAt then return end
  pending=true;local ticket=generation;diagnostics.phase='loading'
  title.Text=skin=='Original' and weapon or skin
  subtitle.Text=weapon..'   /   '..(wrap=='Original' and 'Original finish' or wrap)..(inverted and '  ·  Inverted' or '')
  status.Text='Loading model...';status.Visible=true
  task.spawn(function()
   local ok,result,dispose=pcall(adapter.preview,weapon,skin,wrap,inverted)
   pending=false
   if stopped or ticket~=generation then if dispose then pcall(dispose)end;if ok and result then result:Destroy()end;return end
   if not ok then
    failures=failures+1;retryAt=os.clock()+math.min(.5*2^(failures-1),5)
    diagnostics.errors=diagnostics.errors+1;diagnostics.retries=diagnostics.retries+1;diagnostics.lastError=tostring(result);diagnostics.phase='waiting for assets'
    status.Text='Waiting for model assets...';return
   end
   releaseModel();model=result;disposeModel=dispose;model.Parent=world;signature=key
   local _,size=model:GetBoundingBox();radius=math.max(size.Magnitude*.5,.2)
   diagnostics.builds=diagnostics.builds+1;diagnostics.model=skin;diagnostics.weapon=weapon;diagnostics.wrap=wrap;diagnostics.parts=0
   for _,part in ipairs(model:GetDescendants())do if part:IsA('BasePart')then diagnostics.parts=diagnostics.parts+1 end end
   diagnostics.phase='ready';diagnostics.lastError=nil;failures=0;status.Visible=false;yaw,pitch,zoom=-.45,.12,1
  end)
 end
 connect(viewport.InputBegan,function(input)
  if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then drag=true;lastMouse=Vector2.new(input.Position.X,input.Position.Y)end
 end)
 connect(UIS.InputEnded,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then drag=false end end)
 connect(viewport.InputChanged,function(input)
  if input.UserInputType==Enum.UserInputType.MouseWheel then zoom=math.clamp(zoom-input.Position.Z*.08,.65,1.8)end
 end)
 connect(UIS.InputChanged,function(input)
  if drag and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then
   local point=Vector2.new(input.Position.X,input.Position.Y)
   if lastMouse then local delta=point-lastMouse;yaw=yaw-delta.X*.008;pitch=math.clamp(pitch+delta.Y*.006,-1.1,1.1)end
   lastMouse=point
  end
 end)
 connect(Run.RenderStepped,function(dt)
  if stopped or not page.Visible or not isMenuOpen()then drag=false;return end
  rebuild()
  if model then
   if not drag and getValue('Skin Changer/Preview/Auto Rotate')~=false then yaw=yaw+math.min(dt,.1)*.2 end
   local aspect=math.max(viewport.AbsoluteSize.X/math.max(viewport.AbsoluteSize.Y,1),.1)
   local half=math.rad(camera.FieldOfView*.5)
   local distance=radius/math.sin(math.atan(math.tan(half)*math.min(aspect,1)))*1.15*zoom
   local direction=Vector3.new(math.cos(yaw)*math.cos(pitch),math.sin(pitch),math.sin(yaw)*math.cos(pitch))
   camera.CFrame=CFrame.lookAt(direction*distance,Vector3.zero)
  end
 end)
 table.insert(cleanups,function()stopped=true;generation=generation+1;releaseModel();card:Destroy()end)
 return {status=function()return table.clone(diagnostics)end}
end

end)()

local installCustomModels = (function()
-- Visual-only custom mesh rigs. Native character, hitboxes and animation tracks stay in place.
local CustomRig=(function()
 local M={}
 local aliases={hips='LowerTorso',pelvis='LowerTorso',spine='LowerTorso',spine1='UpperTorso',spine2='UpperTorso',chest='UpperTorso',upperchest='UpperTorso',neck='Head',head='Head',torso='UpperTorso',root='HumanoidRootPart',rootpart='HumanoidRootPart'}
 local japanese={['腰']='LowerTorso',['下半身']='LowerTorso',['上半身']='UpperTorso',['上半身2']='UpperTorso',['首']='Head',['頭']='Head'}
 local body={'Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot','HumanoidRootPart'}
 for _,name in ipairs(body)do aliases[name:lower()]=name end
 for _,side in ipairs({'Left','Right'})do
  local s=side:lower();local jp=side=='Left'and '左'or '右'
  for name,target in pairs({arm='UpperArm',upperarm='UpperArm',forearm='LowerArm',lowerarm='LowerArm',hand='Hand',upleg='UpperLeg',thigh='UpperLeg',upperleg='UpperLeg',leg='LowerLeg',calf='LowerLeg',lowerleg='LowerLeg',foot='Foot',toebase='Foot'})do aliases[s..name]=side..target end
  aliases[s..'shoulder']='UpperTorso'
  for name,target in pairs({['腕']='UpperArm',['ひじ']='LowerArm',['手首']='Hand',['足']='UpperLeg',['足D']='UpperLeg',['ひざ']='LowerLeg',['ひざD']='LowerLeg',['足首']='Foot',['足首D']='Foot'})do
   japanese[jp..name]=side..target;japanese[name..(side=='Left'and '.L'or '.R')]=side..target
  end
  japanese['肩'..(side=='Left'and '.L'or '.R')]='UpperTorso'
 end
 function M.canonical(name)
  if japanese[name]then return japanese[name]end
  local n=name:lower():gsub('[^%w]',''):gsub('^mixamorig',''):gsub('^bip001','')
  n=n:gsub('^jbipc',''):gsub('^jbipl','left'):gsub('^jbipr','right')
  return aliases[n]
 end
 function M.align(a,b)
  a=a.Unit;b=b.Unit
  local dot=math.clamp(a:Dot(b),-1,1)
  if dot>.999999 then return CFrame.identity end
  local cross=a:Cross(b)
  if cross.Magnitude<.00001 then cross=a:Cross(math.abs(a.Y)<.9 and Vector3.yAxis or Vector3.xAxis)end
  return CFrame.fromAxisAngle(cross.Unit,math.acos(dot))
 end
 function M.source(model)
  local parts,rest={},{}
  for _,name in ipairs(body)do local p=model:FindFirstChild(name);if p and p:IsA('BasePart')then parts[name]=p end end
  local root=parts.HumanoidRootPart
  if not root then return nil end
  rest.HumanoidRootPart=CFrame.identity
  local links={}
  for _,joint in ipairs(model:GetDescendants())do
   if joint:IsA('Motor6D')or joint:IsA('AnimationConstraint')then
    local ok,p0,p1,c0,c1=pcall(function()return joint.Part0,joint.Part1,joint.C0,joint.C1 end)
    if ok and p0 and p1 then
     if joint.Name=='Waist'or joint.Name=='Neck'then c0=CFrame.new(c0.Position);c1=CFrame.new(c1.Position)end
     table.insert(links,{p0.Name,p1.Name,c0,c1})
    end
   end
  end
  for _=1,18 do for _,j in ipairs(links)do if rest[j[1]]and not rest[j[2]]then rest[j[2]]=rest[j[1]]*j[3]*j[4]:Inverse()end end end
  for name,p in pairs(parts)do if not rest[name]then rest[name]=root.CFrame:ToObjectSpace(p.CFrame)end end
  return {model=model,root=root,parts=parts,rest=rest}
 end
 function M.sanitize(model)
  local collection=game:GetService('CollectionService')
  local remove={}
  for _,n in ipairs(model:GetDescendants())do
   for _,tag in ipairs(collection:GetTags(n))do collection:RemoveTag(n,tag)end
   if n:IsA('LuaSourceContainer')or n:IsA('Humanoid')or n:IsA('AnimationController')or n:IsA('Animator')or n:IsA('RemoteEvent')or n:IsA('RemoteFunction')or n:IsA('ProximityPrompt')or n:IsA('ClickDetector')or n:IsA('TouchTransmitter')or n:IsA('Sound')or n:IsA('LayerCollector')then table.insert(remove,n)
   elseif n:IsA('BasePart')then
    n.Anchored=true;n.CanCollide=false;n.CanTouch=false;n.CanQuery=false;n.Massless=true;n.LocalTransparencyModifier=0
    if n.Name=='HumanoidRootPart'or n.Name=='RootPart'then n.Transparency=1 end
   end
  end
  for _,n in ipairs(remove)do n:Destroy()end
 end
 function M.build(template,height,scale)
  local model=template:Clone()
  local ok,result=pcall(function()
   M.sanitize(model)
   local _,size=model:GetBoundingBox()
   assert(size.Y>.01,'The model has no visible geometry')
   local factor=height/size.Y*scale
   assert(factor>0 and factor<100000,'Invalid model dimensions')
   model:ScaleTo(model:GetScale()*factor)
   local box,scaled=model:GetBoundingBox()
   local origin=CFrame.new(box.Position.X,box.Position.Y-scaled.Y*.5+scaled.Y*.53,box.Position.Z)
   local r={model=model,parts={},bones={},followers={},effects={},mapped=0,origin=origin,height=scaled.Y,joints=0}
   local byPart,links={},{}
   for _,n in ipairs(model:GetDescendants())do if n:IsA('AnimationConstraint')then
    local good,p0,p1,c0,c1=pcall(function()return n.Part0,n.Part1,n.C0,n.C1 end)
    if good and p0 and p1 then
     local motor=Instance.new('Motor6D');motor.Name=n.Name;motor.Part0=p0;motor.Part1=p1;motor.C0=c0;motor.C1=c1;motor.Parent=p0
    end
    n:Destroy()
   end end
   for _,n in ipairs(model:GetDescendants())do
    if n:IsA('BasePart')then
     local p={part=n,bind=origin:ToObjectSpace(n.CFrame),name=M.canonical(n.Name)}
     byPart[n]=p;table.insert(r.parts,p)
    elseif n:IsA('JointInstance')or n:IsA('AnimationConstraint')then
     local good,p0,p1,c0,c1=pcall(function()return n.Part0,n.Part1,n.C0,n.C1 end)
     if good and p0 and p1 then links[p1]={parent=p0,c0=c0,c1=c1,joint=n};r.joints=r.joints+1 end
    elseif n:IsA('WeldConstraint')then
     if n.Part0 and n.Part1 then links[n.Part1]={parent=n.Part0,offset=n.Part0.CFrame:ToObjectSpace(n.Part1.CFrame),joint=n};r.joints=r.joints+1 end
    elseif n:IsA('ParticleEmitter')or n:IsA('Beam')or n:IsA('Trail')or n:IsA('Light')then
     table.insert(r.effects,{object=n,enabled=n.Enabled})
    end
   end
   local function depth(p,seen)
    seen=seen or {};if seen[p]then return 0 end;seen[p]=true
    local link=links[p];return link and byPart[link.parent]and 1+depth(link.parent,seen)or 0
   end
   for _,p in ipairs(r.parts)do p.link=links[p.part];p.depth=depth(p.part);if p.name and p.name~='HumanoidRootPart'then r.mapped=r.mapped+1 end end
   table.sort(r.parts,function(a,b)return a.depth<b.depth end)
   local groups={}
   for _,n in ipairs(model:GetDescendants())do if n:IsA('Bone')then
    n.Transform=CFrame.identity
    local name=M.canonical(n.Name)
    local root=n.Parent;local d=0
    while root and root:IsA('Bone')do d=d+1;root=root.Parent end
    if root and root:IsA('BasePart')then
     local group=groups[root]
     if not group then group={root=root,names={},bones={},score=0};groups[root]=group end
     group.names[n.Name]=n;table.insert(group.bones,{bone=n,depth=d})
     if name and name~='HumanoidRootPart'then group.score=group.score+1 end
    end
    if name and name~='HumanoidRootPart'then
     table.insert(r.bones,{bone=n,name=name,bind=origin:ToObjectSpace(n.WorldCFrame),depth=d,root=root})
     r.mapped=r.mapped+1
    end
   end end
   local primary
   for _,group in pairs(groups)do
    if not primary or group.score>primary.score or group.score==primary.score and #group.bones>#primary.bones then primary=group end
   end
   local drivers={}
   if primary then for _,group in pairs(groups)do if group~=primary then
    local matches={}
    for _,b in ipairs(group.bones)do
     local driver=primary.names[b.bone.Name]
     if driver then b.driver=driver;table.insert(matches,b)end
    end
    if #matches>0 then
     for _,b in ipairs(matches)do drivers[b.bone]=b.driver;table.insert(r.followers,b)end
     -- One anchored assembly and one pose clock for body, clothing and separate hair rigs.
     local part=byPart[group.root]
     if part and not part.link then
      local offset=primary.root.CFrame:ToObjectSpace(group.root.CFrame)
      local weld=Instance.new('Weld');weld.Name='CustomRigCompanion';weld.Part0=primary.root;weld.Part1=group.root;weld.C0=offset;weld.C1=CFrame.identity;weld.Parent=primary.root
      part.link={parent=primary.root,c0=offset,c1=CFrame.identity,joint=weld}
      r.joints=r.joints+1
     end
    end
   end end end
   for _,b in ipairs(r.bones)do b.driver=drivers[b.bone]end
   table.sort(r.followers,function(a,b)return a.depth<b.depth end)
   for _,p in ipairs(r.parts)do
    local cursor=p;local seen={}
    while cursor and not seen[cursor]do
     seen[cursor]=true
     local group=groups[cursor.part]
     if group and group.score>=3 then p.boneDriven=true;break end
     cursor=cursor.link and byPart[cursor.link.parent]
    end
   end
   table.sort(r.bones,function(a,b)return a.depth<b.depth end)
   local nextBody={LeftUpperArm='LeftLowerArm',RightUpperArm='RightLowerArm',LeftLowerArm='LeftHand',RightLowerArm='RightHand',LeftUpperLeg='LeftLowerLeg',RightUpperLeg='RightLowerLeg',LeftLowerLeg='LeftFoot',RightLowerLeg='RightFoot'}
   local byName={};for _,p in ipairs(r.parts)do if p.name then byName[p.name]=p end end
   for _,p in ipairs(r.parts)do
    local child=byName[nextBody[p.name]]
    if child then p.direction=child.bind.Position-p.bind.Position;if p.direction.Magnitude<.0001 then p.direction=nil end end
   end
   for _,b in ipairs(r.bones)do
    local nextName=nextBody[b.name]
    local nearest
    if nextName then for _,child in ipairs(r.bones)do
     if child.name==nextName and child.bone:IsDescendantOf(b.bone)and (not nearest or child.depth<nearest.depth)then nearest=child end
    end end
    if nearest then b.direction=nearest.bind.Position-b.bind.Position
    elseif b.name=='LeftHand'or b.name=='RightHand'then
     local parent=b.bone.Parent
     while parent and parent:IsA('Bone')do
      if M.canonical(parent.Name)==b.name:gsub('Hand','LowerArm')then b.direction=b.bind.Position-origin:PointToObjectSpace(parent.WorldPosition);break end
      parent=parent.Parent
     end
    end
    if b.direction and b.direction.Magnitude<.0001 then b.direction=nil end
   end
   assert(r.mapped>=3,'No supported body rig found. Use R15, Mixamo, VRM or MMD bone names.')
   -- Shared skinned meshes find their skeleton through the imported rigid joints.
   -- Keep those connections and anchor each assembly root instead of every mesh.
   for _,p in ipairs(r.parts)do
    p.part.Anchored=not (p.link and p.link.joint and (p.link.joint:IsA('JointInstance')or p.link.joint:IsA('WeldConstraint')))
   end
   for _,n in ipairs(model:GetDescendants())do if n:IsA('Constraint')and not n:IsA('WeldConstraint')then n:Destroy()end end
   return r
  end)
  if not ok then model:Destroy();error(result,0)end
  return result
 end
 function M.visible(r,show)
  for _,p in ipairs(r.parts)do p.part.LocalTransparencyModifier=show and 0 or 1 end
  for _,e in ipairs(r.effects)do e.object.Enabled=show and e.enabled or false end
 end
 function M.pose(r,source,anchor)
  local deltas={}
  local sourceFrame=source and source.root.CFrame
  if source then for name,p in pairs(source.parts)do
   if p.Parent then deltas[name]=sourceFrame:ToObjectSpace(p.CFrame).Rotation*source.rest[name].Rotation:Inverse()end
  end end
  for _,p in ipairs(r.parts)do
   local link=p.link
   -- Static skinned carriers inherit the anchored root through their existing joints.
   -- Rewriting their CFrames/near-identity Motor6D transforms causes separate skin rebuilds.
   if not link or not p.boneDriven and p.name and p.name~='HumanoidRootPart'then
   if p.rest~= (source and source.rest)then p.neutral=nil end
   if not p.neutral then
    local rest=source and source.rest[p.name]or CFrame.identity
    p.neutral=p.direction and M.align(p.direction,rest:VectorToWorldSpace(-Vector3.yAxis))*p.bind.Rotation or p.bind.Rotation
    p.rest=source and source.rest
   end
   local rotation=anchor.Rotation*(deltas[p.name]or CFrame.identity)*p.neutral
   if link and link.parent.Parent then
    if link.c0 then
     local pivot=link.parent.CFrame*link.c0
     p.part.CFrame=CFrame.new(pivot.Position-rotation:VectorToWorldSpace(link.c1.Position))*rotation
    else p.part.CFrame=link.parent.CFrame*link.offset end
   else p.part.CFrame=anchor*p.bind end
   if p.name and not link then p.part.CFrame=CFrame.new(p.part.Position)*rotation end
   if link and link.joint and link.joint:IsA('Motor6D')then
    link.joint.Transform=link.c0:Inverse()*link.parent.CFrame:ToObjectSpace(p.part.CFrame)*link.c1
   end
   end
  end
  for _,b in ipairs(r.bones)do
   if not b.driver then
   local bone=b.bone;local parent=bone.Parent
   local parentFrame=parent:IsA('Bone')and parent.TransformedWorldCFrame or parent.CFrame
   local base=parentFrame*bone.CFrame
   if b.direction and b.rest~= (source and source.rest)then b.neutral=nil end
   if not b.neutral then
    local rest=source and source.rest[b.name]or CFrame.identity
    b.neutral=b.direction and M.align(b.direction,rest:VectorToWorldSpace(-Vector3.yAxis))*b.bind.Rotation or b.bind.Rotation
    b.rest=source and source.rest
   end
   local rotation=anchor.Rotation*(deltas[b.name]or CFrame.identity)*b.neutral
   bone.Transform=base:ToObjectSpace(CFrame.new(base.Position)*rotation)
   end
  end
  for _,b in ipairs(r.followers)do
   local parent=b.bone.Parent
   local frame=parent:IsA('Bone')and parent.TransformedWorldCFrame or parent.CFrame
   b.bone.Transform=(frame*b.bone.CFrame):ToObjectSpace(b.driver.TransformedWorldCFrame)
  end
 end
 return M
end)()

return function(page,adapter,getValue,connect,cleanups,isMenuOpen,notify)
 local Run=game:GetService('RunService')
 local UIS=game:GetService('UserInputService')
 local player=game:GetService('Players').LocalPlayer
 if isfolder and makefolder and not isfolder('neverlose_ui/models')then pcall(makefolder,'neverlose_ui/models')end
 local function get(path)return getValue('Model Changer/'..path)end
 local stopped,pending,template,signature,requested=false,false,nil,nil,nil
 local generation,revision=0,0
 local live,preview,source,liveKey,previewKey,boundCharacter
 local hidden=false
 local diagnostics={phase='disabled',errors=0,parts=0,bones=0,mapped=0,loads=0,localOnly=true}
 local folder=Instance.new('Folder');folder.Name='NeverloseCustomVisuals';folder.Parent=workspace
 table.insert(cleanups,adapter.setAvatarHiddenProvider(function()return hidden end))
 table.insert(cleanups,adapter.setLocalVisualProvider(function()return hidden and live and live.model or nil end))
 local function destroyRig(r)if r then r.model:Destroy()end end
 local function resetLive()
  hidden=false;destroyRig(live);live=nil;liveKey=nil
  adapter.refreshAvatarVisibility()
 end
 local function assetKey()
  local mode=get('Selection/Source')
  local value=mode=='Anime Example'and '6669297625'or mode=='Local File'and tostring(get('Selection/File')or '')or tostring(get('Selection/Asset ID')or '')
  return mode..':'..value,mode,value
 end
 local function loadAsset(mode,value)
  local uri
  if mode=='Local File'then
   assert(type(getcustomasset)=='function','Local model files are unavailable in this executor')
   assert(value:lower():match('%.rbxm$')or value:lower():match('%.rbxmx$'),'Choose a .rbxm or .rbxmx model file')
   assert(isfile(value),'Model file not found in executor workspace: '..value)
   uri=getcustomasset(value)
  else
   local id=value:match('^%s*(%d+)%s*$')or value:match('rbxassetid://(%d+)')or value:match('/asset/(%d+)')or value:match('[?&]id=(%d+)')
   assert(id and tonumber(id)>0,'Enter a model asset ID or Creator Store model link')
   uri='rbxassetid://'..id
  end
  local prior=getthreadidentity and getthreadidentity()
  if setthreadidentity then setthreadidentity(8)end
  local ok,objects=pcall(function()return game:GetObjects(uri)end)
  if setthreadidentity and prior then setthreadidentity(prior)end
  assert(ok,objects)
  local group=Instance.new('Model');group.Name='Custom Character'
  for _,object in ipairs(objects)do CustomRig.sanitize(object);object.Parent=group end
  local count=0;for _,p in ipairs(group:GetDescendants())do if p:IsA('BasePart')then count=count+1 end end
  if count==0 or count>400 then group:Destroy();error('Choose a character model with 1–400 parts',0)end
  return group
 end
 local function request(force)
  local key,mode,value=assetKey()
  if not force and key==requested then return end
  requested=key;generation=generation+1;local ticket=generation;pending=true
  diagnostics.phase='loading';diagnostics.lastError=nil
  task.spawn(function()
   local ok,result=pcall(function()
    local model=loadAsset(mode,value)
    local valid,rig=pcall(CustomRig.build,model,5.5,1)
    if not valid then model:Destroy();error(rig,0)end
    rig.model:Destroy();return model
   end)
   if stopped or ticket~=generation then if ok then result:Destroy()end;return end
   pending=false
   if not ok then
    diagnostics.errors=diagnostics.errors+1;diagnostics.lastError=tostring(result);diagnostics.phase='load failed'
    notify('Model Changer',tostring(result));return
   end
   if template then template:Destroy()end
   template=result;signature=key;revision=revision+1;diagnostics.loads=diagnostics.loads+1
   diagnostics.name=mode=='Anime Example'and 'YYB Hatsune Miku'or mode=='Local File'and value:match('[^/\\]+$')or 'Custom asset '..value
  end)
 end
 local function bodyHeight(s)
  if not s then return 5.5 end
  if s.height then return s.height end
  local lo,hi=math.huge,-math.huge
  for name,p in pairs(s.parts)do if name~='HumanoidRootPart'then
   local y=s.rest[name].Position.Y;lo=math.min(lo,y-p.Size.Y*.5);hi=math.max(hi,y+p.Size.Y*.5)
  end end
  s.height=hi>lo and hi-lo or 5.5
  return s.height
 end
 local make=function(class,props,parent)local o=Instance.new(class);for k,v in pairs(props)do o[k]=v end;o.Parent=parent;return o end
 local inner=page.Inner
 for _,name in ipairs({'Left','Right'})do local col=inner[name];col.Position=UDim2.new(col.Position.X.Scale,col.Position.X.Offset,0,318)end
 local width=inner.Left.Size.X.Offset*2+11
 local card=make('Frame',{Name='CustomModelPreview',Position=UDim2.fromOffset(20,18),Size=UDim2.fromOffset(width,282),BackgroundColor3=Color3.fromRGB(5,14,25),BorderSizePixel=0,ClipsDescendants=true},inner)
 make('UICorner',{CornerRadius=UDim.new(0,7)},card)
 make('UIStroke',{Color=Color3.fromRGB(18,43,64)},card)
 local function label(text,y,size,color)return make('TextLabel',{Position=UDim2.fromOffset(18,y),Size=UDim2.new(1,-36,0,size+8),BackgroundTransparency=1,Text=text,Font=Enum.Font.GothamMedium,TextSize=size,TextColor3=color,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},card)end
 label('CUSTOM CHARACTER  /  LOCAL VISUAL',12,10,Color3.fromRGB(81,153,205))
 local title=label('Custom model preview',31,18,Color3.fromRGB(234,242,250))
 local statusLabel=label('Choose a model asset or local rig file',58,11,Color3.fromRGB(136,163,185))
 local view=make('ViewportFrame',{Active=true,Position=UDim2.fromOffset(8,78),Size=UDim2.new(1,-16,0,171),BackgroundTransparency=1,Ambient=Color3.fromRGB(175,175,188),LightColor=Color3.fromRGB(255,245,235),LightDirection=Vector3.new(-.6,-1,-.6)},card)
 local camera=make('Camera',{FieldOfView=35},view);view.CurrentCamera=camera
 local world=make('WorldModel',{},view)
 local hint=label('Drag to rotate  /  scroll to zoom',256,10,Color3.fromRGB(104,134,158));hint.TextXAlignment=Enum.TextXAlignment.Center
 local yaw,pitch,zoom,drag,lastMouse=-math.pi*.5,.08,1,false,nil
 connect(view.InputBegan,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then drag=true;lastMouse=Vector2.new(input.Position.X,input.Position.Y)end end)
 connect(UIS.InputEnded,function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then drag=false end end)
 connect(view.InputChanged,function(input)if input.UserInputType==Enum.UserInputType.MouseWheel then zoom=math.clamp(zoom-input.Position.Z*.08,.6,2)end end)
 connect(UIS.InputChanged,function(input)if drag and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then
  local point=Vector2.new(input.Position.X,input.Position.Y);local d=point-lastMouse;lastMouse=point;yaw=yaw-d.X*.008;pitch=math.clamp(pitch+d.Y*.006,-1,1)
 end end)
 local function update(dt)
  if stopped then return end
  local native=adapter.character()
  if native~=boundCharacter or source and not source.root.Parent or not source and native and native:FindFirstChild('HumanoidRootPart')then
   boundCharacter=native;source=native and CustomRig.source(native)or nil;liveKey=nil;previewKey=nil
  end
  local showPreview=page.Visible and isMenuOpen()
  local enabled=get('Selection/Enabled')==true
  if enabled or showPreview then request(false)end
  local scale=math.clamp(tonumber(get('Fitting/Scale'))or 100,25,250)/100
  local height=bodyHeight(source)
  local key=tostring(revision)..':'..scale..':'..string.format('%.2f',height)
  local facing=CFrame.Angles(0,math.rad(tonumber(get('Fitting/Facing'))or 0),0)
  local offset=CFrame.new(0,(tonumber(get('Fitting/Height'))or 0)/100,0)*facing
  if enabled and template and source and source.model.Parent then
   if liveKey~=key then
    local new=CustomRig.build(template,height,scale);new.model.Name='NeverloseCustomCharacter';new.model.Parent=folder
    destroyRig(live);live=new;liveKey=key
   end
   local fp=adapter.firstPerson(player)==true
   CustomRig.pose(live,source,source.root.CFrame*offset)
   CustomRig.visible(live,not fp)
   hidden=true;adapter.refreshAvatarVisibility()
   diagnostics.parts=#live.parts;diagnostics.bones=#live.bones;diagnostics.mapped=live.mapped;diagnostics.sharedBones=#live.followers
   diagnostics.phase=fp and 'first person hidden'or pending and 'loading'or 'active'
  elseif live then resetLive()end
  if not enabled and not pending then diagnostics.phase='disabled'end
  if showPreview and template then
   if previewKey~=key then local new=CustomRig.build(template,height,scale);new.model.Parent=world;destroyRig(preview);preview=new;previewKey=key end
   CustomRig.pose(preview,source,offset)
   if not drag and get('Preview/Auto Rotate')~=false then yaw=yaw+math.min(dt,.1)*.25 end
   local radius=math.max(height*scale*.65,1)
   local aspect=math.max(view.AbsoluteSize.X/math.max(view.AbsoluteSize.Y,1),.1)
   local half=math.atan(math.tan(math.rad(camera.FieldOfView*.5))*math.min(aspect,1))
   local direction=Vector3.new(math.cos(yaw)*math.cos(pitch),math.sin(pitch),math.sin(yaw)*math.cos(pitch))
   local center=Vector3.new(0,-height*scale*.03,0)
   camera.CFrame=CFrame.lookAt(center+direction*radius/math.sin(half)*zoom,center)
  end
  title.Text=diagnostics.name or 'Custom model preview'
  statusLabel.Text=diagnostics.lastError and diagnostics.lastError:sub(1,115)or pending and 'Loading custom mesh rig…'or live and (#live.parts..' mesh parts  ·  '..#live.bones..' body bones  ·  '..diagnostics.phase)or 'Preview only  ·  enable to replace your local appearance'
 end
 local binding='NeverloseCustomModel'..tostring(math.random(100000,999999))
 Run:BindToRenderStep(binding,Enum.RenderPriority.Last.Value+3,function(dt)
  local ok,err=pcall(update,dt)
  if not ok then
   diagnostics.errors=diagnostics.errors+1;diagnostics.lastError=tostring(err);diagnostics.phase='model error';resetLive()
   if diagnostics.errors==1 then warn('[Model Changer] '..tostring(err))end
  end
 end)
 table.insert(cleanups,function()
  stopped=true;generation=generation+1;Run:UnbindFromRenderStep(binding);resetLive();destroyRig(preview)
  if template then template:Destroy()end;folder:Destroy();card:Destroy()
 end)
 return {status=function()return table.clone(diagnostics)end,reload=function()request(true)end}
end

end)()

local installLiveESP = (function()
-- Conservative screen-space occlusion regions. Never bridge visible cells.
local OcclusionMask=(function()
 local M={}
 function M.rectangles(grid,cols,rows,limit)
  local cells={};for i,v in ipairs(grid) do cells[i]=v==true end
  local result={}
  for _=1,limit do
   local heights={};for x=1,cols do heights[x]=0 end
   local best,area=nil,0
   for y=1,rows do
    for x=1,cols do heights[x]=cells[(y-1)*cols+x] and heights[x]+1 or 0 end
    local stack={}
    for x=1,cols+1 do
     local height=x<=cols and heights[x] or 0
     local left=x
     while #stack>0 and stack[#stack].height>height do
      local item=table.remove(stack);left=item.left
      local size=item.height*(x-item.left)
      if size>area then area=size;best={item.left,y-item.height+1,x-1,y} end
     end
     if height>0 and (#stack==0 or stack[#stack].height<height) then table.insert(stack,{left=left,height=height}) end
    end
   end
   if not best then break end
   table.insert(result,best)
   for y=best[2],best[4] do for x=best[1],best[3] do cells[(y-1)*cols+x]=false end end
  end
  return result
 end
 return M
end)()
-- Live ESP for the game's Participant / OperatorPresenter pipeline.
-- Embedded in neverlose_ui.lua so the menu remains a single-file script.
return function(menuGui, Store, connect, cleanups, adapter)
 local RS = game:GetService('ReplicatedStorage')
 local Players = game:GetService('Players')
 local RunService = game:GetService('RunService')
 local localPlayer = Players.LocalPlayer
 local modules = RS:FindFirstChild('Modules')
 local function module(path)
  if adapter then return adapter.resolve(path) end
  local node = modules
  for name in path:gmatch('[^/]+') do node = node and node:FindFirstChild(name) end
  if not node then return nil end
  local ok, result = pcall(require, node)
  return ok and result or nil
 end
 local participant = module('Shared/Participant')
 local hostility = module('Shared/Combat/Hostility')
 local merc = module('Client/Controllers/MercPlayerController')
 local presenter = module('Client/Character/OperatorPresenter')
 local pov = module('Client/Controllers/MercPOVController')
 local gun = module('Client/Controllers/GunController')
 local silhouettes = module('Shared/Weapons/WeaponSilhouette')
 local units = module('Shared/Units')
 local records, stopped = {}, false
 local stats = { targets = 0, rendered = 0, errors = 0, adapter = adapter and adapter.name or 'OperatorPresenter', details = {} }
 local overlay = Instance.new('ScreenGui')
 overlay.Name, overlay.IgnoreGuiInset, overlay.ResetOnSpawn = 'NeverloseESP', true, false
 overlay.DisplayOrder, overlay.ZIndexBehavior = 999, Enum.ZIndexBehavior.Sibling
 overlay.Parent = localPlayer:WaitForChild('PlayerGui')
 local function make(class, props, parent)
  local o = Instance.new(class)
  for k,v in pairs(props) do o[k] = v end
  o.Parent = parent
  return o
 end
 local function setting(ctx, path)
  path = 'Players/' .. path
  local v = Store.values[path .. '@' .. ctx]
  if v == nil then v = Store.defaults[path] end
  return v
 end
 local function color(ctx,path)
  local s = tostring(setting(ctx,path .. '/Color') or 'FFFFFF'):gsub('#','')
  return Color3.fromRGB(tonumber(s:sub(1,2),16) or 255,tonumber(s:sub(3,4),16) or 255,tonumber(s:sub(5,6),16) or 255)
 end
 local function body(owner)
  return participant and participant.BodyOf(owner) or (owner:IsA('Player') and owner.Character or owner:FindFirstChildWhichIsA('Model'))
 end
 local function visual(owner)
  local v = merc and merc.GetVisual(owner)
  if not v and presenter then v = presenter.RigOf(owner) end
  if not v and owner == localPlayer and pov and pov._state then v = pov._state.visual end
  return v and v.Parent and v or nil
 end
 local function team(owner)
  if hostility then return hostility.TeamOf(owner) end
  return owner:GetAttribute('Team')
 end
 local function context(owner)
  if owner == localPlayer then return 'Local' end
  if hostility then return hostility.IsHostile(localPlayer,owner) and 'Enemies' or 'Teammates' end
  local t = team(owner)
  return t and t ~= 'Neutral' and t == team(localPlayer) and 'Teammates' or 'Enemies'
 end

 -- Text and line primitives. ESP text is Arial with a hard black outline, like the original.
 local FONT, FONT_BOLD = Font.fromEnum(Enum.Font.Arial), Font.fromEnum(Enum.Font.ArialBold)
 local BLACK, WHITE = Color3.new(0,0,0), Color3.new(1,1,1)
 local function label(parent,size,bold)
  return make('TextLabel',{BackgroundTransparency=1,BorderSizePixel=0,FontFace=bold and FONT_BOLD or FONT,TextSize=size or 12,TextColor3=WHITE,TextStrokeTransparency=0,TextStrokeColor3=BLACK,Text='',Visible=false},parent)
 end
 local function line(parent)
  return make('Frame',{BorderSizePixel=0,BackgroundColor3=WHITE,AnchorPoint=Vector2.new(.5,.5),Visible=false},parent)
 end
 local function outlined(parent,c)
  local f=make('Frame',{BackgroundTransparency=1,BorderSizePixel=0,Visible=false},parent)
  local s=make('UIStroke',{Thickness=1,Color=c or BLACK},f)
  pcall(function() s.BorderStrokePosition=Enum.BorderStrokePosition.Inner end)
  return f,s
 end
 local function segment(o,a,b,c,thickness)
  local d=b-a
  o.Position=UDim2.fromOffset((a.X+b.X)/2,(a.Y+b.Y)/2)
  o.Size=UDim2.fromOffset(d.Magnitude,thickness or 1)
  o.Rotation=math.deg(math.atan2(d.Y,d.X))
  o.BackgroundColor3, o.Visible=c,true
 end

 ---------------------------------------------------------------------------------------
 -- Chams
 --
 -- No Highlights and nothing in the world is made see-through. The operator rig is invisible
 -- body-shaped chassis MeshParts with wrapped garment MeshParts on top. Two layers:
 --   visible  the real garments are recoloured in place (lit, shaded). The world hides them
 --            behind walls by itself, so this layer is exact to the pixel.
 --   hidden   a copy of the rig lives in a ViewportFrame drawn above the world, painted in the
 --            hidden colour. Its camera copies the real one every frame, and every frame it copies
 --            the real joints' Transform (AnimationConstraint, Motor6D, Bone): the garments are
 --            layered clothing that deform from those joints, so the pose matches exactly. The
 --            weapon is placed by CFrame. The layer is clipped on screen to the walls that rays
 --            from the camera actually hit, so it only covers the body where a wall is in front
 --            of it and the two colours meet along the wall's edge.
 ---------------------------------------------------------------------------------------
 -- all hidden layers share one container under the 2D overlay
 local layers=make('Frame',{Name='HiddenLayers',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=1},overlay)
 local materials={Flat=Enum.Material.SmoothPlastic,Glow=Enum.Material.Neon,Metallic=Enum.Material.Metal,Glass=Enum.Material.Glass,Forcefield=Enum.Material.ForceField,Foil=Enum.Material.Foil,Marble=Enum.Material.Marble}
 local LIT={Flat=true,Glow=true,Metallic=true,Foil=true,Marble=true,Glass=true,Forcefield=true}

 -- One recipe for both the real parts and the copy.
 local function surface(p,mode,c,opacity,baseTransparency)
  for _,a in ipairs(p:GetChildren()) do if a:IsA('SurfaceAppearance') and a.Parent then a.Parent=nil end end
  if p:IsA('MeshPart') and p.TextureID~='' then p.TextureID='' end
  local m=materials[mode] or materials.Flat
  local shade=mode=='Glow' and c:Lerp(BLACK,.3) or c
  if p.Material~=m then p.Material=m end
  if adapter then p.MaterialVariant='' end
  if p.Color~=shade then p.Color=shade end
  p.Reflectance=mode=='Metallic' and .35 or 0
  local t=baseTransparency+(1-opacity)*(1-baseTransparency)
  if mode=='Glass' then t=math.max(t,.55) end
  if p.Transparency~=t then p.Transparency=t end
 end
 -- Remember a real surface the first time it is modified so it can be put back exactly.
 local function saveSurface(r,p)
  local s=r.surfaces[p]
  if s then return s end
  s={material=p.Material,variant=p.MaterialVariant,color=p.Color,reflectance=p.Reflectance,transparency=p.Transparency,appearances={}}
  if p:IsA('MeshPart') then s.texture=p.TextureID end
  for _,a in ipairs(p:GetChildren()) do
   if a:IsA('SurfaceAppearance') then table.insert(s.appearances,a) end
  end
  r.surfaces[p]=s
  return s
 end
 local function resetPart(r,p)
  local s=r.surfaces[p]
  if not s then return end
  if p.Parent then
   p.Material=s.material;p.MaterialVariant=s.variant or ''; p.Color=s.color; p.Reflectance=s.reflectance; p.Transparency=s.transparency
   if s.texture~=nil then p.TextureID=s.texture end
   for _,a in ipairs(s.appearances) do if a.Parent~=p then a.Parent=p end end
  else
   for _,a in ipairs(s.appearances) do a:Destroy() end
  end
  r.surfaces[p]=nil
 end
 local function restore(r)
  if adapter and r.model then adapter.paintCosmetics(r.model,false)end
  for p in pairs(r.surfaces) do resetPart(r,p) end
  r.litSig=nil
 end

 -- Other characters standing in front are not walls: the one behind is simply covered.
 local function isActor(inst)
  for _,name in ipairs({'MercPlayers','MockPlayers','OperatorBots'}) do
   local folder=workspace:FindFirstChild(name)
   if folder and inst:IsDescendantOf(folder) then return true end
  end
  return false
 end
 -- The first solid thing between the camera and a point, if any. See-through helpers
 -- (trigger volumes, invisible blockers) are skipped.
 local function blocker(origin,target,base)
  local dir=target-origin
  local params,list=base,nil
  for _=1,4 do
   local hit=workspace:Raycast(origin,dir,params)
   if not hit then return nil end
   local inst=hit.Instance
   if inst:IsA('Terrain') then return inst end
   if not (inst.Transparency>=.95 or (not inst.CanCollide and inst.Transparency>=.2) or isActor(inst)) then return inst end
   if not list then list=table.clone(base.FilterDescendantsInstances) end
   table.insert(list,inst)
   params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances=list
  end
  return nil
 end
 local function rayParams(r)
  local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
  local ignore=adapter and adapter.actorModels() or {r.model}
  local b=body(r.owner)
  if b then table.insert(ignore,b) end
  if localPlayer.Character then table.insert(ignore,localPlayer.Character) end
  if pov and pov._state and pov._state.visual then table.insert(ignore,pov._state.visual) end
  params.FilterDescendantsInstances=ignore
  return params
 end
 -- Rays to both sides and the centre of every body part. Whatever they hit is a wall in front
 -- of the target; a wall stays on the list briefly after the last hit so edges do not flicker.
 local function sampleBody(r,cam,now)
  r.occTime=now
  local origin,right,params=cam.CFrame.Position,cam.CFrame.RightVector,rayParams(r)
  local hidden=0
  for _,c in ipairs(r.chassis) do
   local center=c.part.Position
   local off=right*(c.part.Size.Magnitude*.2)
   local any=false
   for _,point in ipairs({center-off,center,center+off}) do
    local hit=blocker(origin,point,params)
    if hit then r.walls[hit]=now; any=true end
   end
   if any then hidden+=1 end
  end
  for wall,seen in pairs(r.walls) do if now-seen>.2 or not wall.Parent then r.walls[wall]=nil end end
  r.visibility=#r.chassis>0 and 1-hidden/#r.chassis or 1
 end
 -- Sample the body-sized image in camera space. Each cell compares map depth
 -- with the actual chassis hit, so disjoint walls do not paint the gap between them.
 local function sampleMask(r,cam,now)
  local box=r.maskBox
  if not box then return end
  local size=overlay.AbsoluteSize
  local x0,y0=math.clamp(box[1],0,size.X),math.clamp(box[2],0,size.Y)
  local x1,y1=math.clamp(box[3],0,size.X),math.clamp(box[4],0,size.Y)
  if x1<=x0 or y1<=y0 then r.maskData=nil;return end
  local cols=math.clamp(math.ceil((x1-x0)/10),4,12)
  local rows=math.clamp(math.ceil((y1-y0)/10),6,18)
  local include=RaycastParams.new();include.FilterType=Enum.RaycastFilterType.Include
  local parts={};for _,c in ipairs(r.chassis) do if c.part.Parent then table.insert(parts,c.part) end end
  include.FilterDescendantsInstances=parts
  local exclude=rayParams(r)
  local origin=cam.CFrame.Position
  local depth=math.max(.1,(r.maskCenter-origin):Dot(cam.CFrame.LookVector))
  local grid={};local hidden=0
  table.clear(r.walls)
  for y=1,rows do for x=1,cols do
   local px=x0+(x-.5)*(x1-x0)/cols
   local py=y0+(y-.5)*(y1-y0)/rows
   local ray=cam:ViewportPointToRay(px,py)
   local distance=depth/math.max(.05,ray.Direction:Dot(cam.CFrame.LookVector))
   local bodyHit=workspace:Raycast(origin,ray.Direction*(distance+12),include)
   if bodyHit then distance=(bodyHit.Position-origin).Magnitude end
   local wall=blocker(origin,origin+ray.Direction*math.max(.01,distance-.04),exclude)
   local covered=wall~=nil
   grid[(y-1)*cols+x]=covered
   if covered then hidden+=1;r.walls[wall]=now end
  end end
  local rects=OcclusionMask.rectangles(grid,cols,rows,4)
  if hidden>0 and not r.hadMask then r.maskSince=now end
  r.hadMask=hidden>0
  r.maskData={cols=cols,rows=rows,rects=rects,box={x0,y0,x1,y1}}
  r.visibility=1-hidden/(cols*rows)
  r.maskRays=cols*rows*2
  r.occTime=now
  r.maskCamera=cam.CFrame
 end
 -- Screen rectangle covered by a wall (its box projected), or the whole screen when that cannot be
 -- known (terrain, or a wall reaching behind the camera).
 local function wallRect(cam,inst,size)
  if not inst:IsA('BasePart') or inst:IsA('Terrain') then return 0,0,size.X,size.Y end
  local cf,s=inst.CFrame,inst.Size/2
  local x0,y0,x1,y1=math.huge,math.huge,-math.huge,-math.huge
  for ix=-1,1,2 do for iy=-1,1,2 do for iz=-1,1,2 do
   local q=cam:WorldToViewportPoint(cf:PointToWorldSpace(Vector3.new(s.X*ix,s.Y*iy,s.Z*iz)))
   if q.Z<.05 then return 0,0,size.X,size.Y end
   x0,y0,x1,y1=math.min(x0,q.X),math.min(y0,q.Y),math.max(x1,q.X),math.max(y1,q.Y)
  end end end
  return x0,y0,x1,y1
 end

 -- A layer is a clipped, full-screen ViewportFrame with a camera that copies the real one.
 local function newLayer()
  local clip=make('Frame',{Name='ChamsLayer',BackgroundTransparency=1,ClipsDescendants=true,Visible=false},layers)
  local vp=make('ViewportFrame',{BackgroundTransparency=1,Ambient=Color3.fromRGB(128,132,145),LightColor=Color3.fromRGB(255,252,245)},clip)
  local world=make('WorldModel',{},vp)
  local cam=make('Camera',{},vp)
  vp.CurrentCamera=cam
  return {clip=clip,vp=vp,world=world,cam=cam}
 end
 local function showLayer(layer,cam,x0,y0,x1,y1,z)
  local size=overlay.AbsoluteSize
  layer.clip.Visible=true
  layer.clip.Position,layer.clip.Size=UDim2.fromOffset(x0,y0),UDim2.fromOffset(x1-x0,y1-y0)
  layer.clip.ZIndex=z
  layer.vp.Position,layer.vp.Size=UDim2.fromOffset(-x0,-y0),UDim2.fromOffset(size.X,size.Y)
  layer.cam.CFrame,layer.cam.FieldOfView=cam.CFrame,cam.FieldOfView
  layer.vp.LightDirection=(cam.CFrame.LookVector*.45+cam.CFrame.RightVector*.25-Vector3.yAxis).Unit
 end
 -- Copies of the rig: r.clone sits in the hidden layer, r.frontClone in the front layer.
 local function destroyClone(r)
  r.maskData=nil;r.hadMask=false;r.maskSince=nil;r.maskCamera=nil;r.occTime=0
  for _,entry in pairs(r.extraMasks or {}) do if entry.clone then entry.clone.model:Destroy() end;entry.layer.clip:Destroy() end
  r.extraMasks={}
  if r.clone then r.clone.model:Destroy() end
  if r.frontClone then r.frontClone.model:Destroy() end
  r.clone,r.frontClone=nil,nil
  if r.layer then r.layer.clip.Visible=false end
  if r.front then r.front.clip.Visible=false end
 end
 local function cloneRig(r,layer,hidden)
  local ok,model=pcall(function() return r.model:Clone() end)
  if not ok or not model then r.cloneRetry=os.clock()+1; return nil end
  if adapter then
   local collection=game:GetService('CollectionService')
   local nodes=model:GetDescendants();table.insert(nodes,model)
   for _,node in ipairs(nodes)do for _,tag in ipairs(collection:GetTags(node))do collection:RemoveTag(node,tag)end end
  end
  local c={model=model,joints={},bones={},rigid={},meshes={},map={}}
  -- real and copied trees are matched by name, class and order among siblings
  local function walk(a,b)
   local buckets={}
   for _,x in ipairs(a:GetChildren()) do
    local k=x.Name..'|'..x.ClassName
    buckets[k]=buckets[k] or {}
    table.insert(buckets[k],x)
   end
   local seen={}
   for _,y in ipairs(b:GetChildren()) do
    local k=y.Name..'|'..y.ClassName
    seen[k]=(seen[k] or 0)+1
    local x=buckets[k] and buckets[k][seen[k]]
    if not x or y:IsA('LuaSourceContainer') or y:IsA('Sound') or y:IsA('ParticleEmitter') or y:IsA('Highlight') or y:IsA('BillboardGui') or y:IsA('Light') then
     y:Destroy()
    else
     if y:IsA('AnimationConstraint') or y:IsA('Motor6D') then table.insert(c.joints,{x,y})
     elseif y:IsA('Bone') then table.insert(c.bones,{x,y})
     elseif adapter and y:IsA('SpecialMesh') then table.insert(c.meshes,{x,y})
     elseif y:IsA('BasePart') then
      c.map[x]=y
      y.CanCollide,y.CanQuery,y.CanTouch,y.CastShadow=false,false,false,false
     end
     walk(x,y)
    end
   end
  end
  walk(r.model,model)
  if adapter and hidden~=false then adapter.paintCosmetics(model,true,true)end
  c.root=model:FindFirstChild('HumanoidRootPart') or model.PrimaryPart
  c.realRoot=r.model:FindFirstChild('HumanoidRootPart') or r.model.PrimaryPart
  if not (c.root and c.realRoot) then model:Destroy(); r.cloneRetry=os.clock()+1; return nil end
  -- The weapon (anything nested below the rig) is placed by the game directly, not through the
  -- skeleton, so its parts follow the real ones by CFrame and lose their welds.
  local rigid={}
  for x,y in pairs(c.map) do
   if adapter or x.Parent~=r.model then rigid[y]=true; table.insert(c.rigid,{x,y}) end
   y.Anchored=y==c.root or rigid[y]==true
  end
  for _,d in ipairs(model:GetDescendants()) do
   local a,b
   if d:IsA('JointInstance') or d:IsA('WeldConstraint') then a,b=d.Part0,d.Part1
   elseif d:IsA('AnimationConstraint') then a,b=d.Attachment0 and d.Attachment0.Parent,d.Attachment1 and d.Attachment1.Parent end
   if (a and rigid[a]) or (b and rigid[b]) then d:Destroy() end
  end
  for i=#c.joints,1,-1 do if not c.joints[i][2].Parent then table.remove(c.joints,i) end end
  local hum=model:FindFirstChildOfClass('Humanoid')
  if hum then hum.EvaluateStateMachine=false; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
  model.Parent=layer.world
  return c
 end
 local function buildClone(r)
  if r.clone then r.clone.model:Destroy(); r.clone=nil end
  r.layer=r.layer or newLayer()
  r.clone=cloneRig(r,r.layer)
  r.cloneSig=nil
 end
 local function poseClone(c)
  if c.realRoot.Parent then c.root.CFrame=c.realRoot.CFrame end
  for _,j in ipairs(c.joints) do
   j[2].Transform=j[1].Transform
   if adapter and j[1]:IsA('Motor6D') then j[2].C0=j[1].C0;j[2].C1=j[1].C1
   elseif adapter and j[1]:IsA('AnimationConstraint') then
    for _,key in ipairs({'Attachment0','Attachment1'})do if j[1][key] and j[2][key]then j[2][key].CFrame=j[1][key].CFrame end end
   end
  end
  for _,b in ipairs(c.bones) do b[2].Transform=b[1].Transform end
  for _,w in ipairs(c.rigid) do w[2].CFrame=w[1].CFrame;if adapter and w[2].Size~=w[1].Size then w[2].Size=w[1].Size end end
  for _,mesh in ipairs(c.meshes or {})do mesh[2].Scale=mesh[1].Scale;mesh[2].Offset=mesh[1].Offset end
 end

 local function chamsOff(r)
  restore(r)
  destroyClone(r)
  table.clear(r.walls)
 end
 local function destroy(r)
  for _,c in ipairs(r.modelConnections or {}) do c:Disconnect() end
  chamsOff(r)
  if r.layer then r.layer.clip:Destroy() end
  if r.front then r.front.clip:Destroy() end
  r.ui:Destroy()
 end
 local function updateChams(r,ctx,cam,now,detail,onScreen,dead)
  local function get(p) return setting(ctx,p) end
  local visibleOn=get('Chams/Visible')==true
  local hiddenOn=get('Chams/Through Walls')==true
  local mode=get('Chams/Material') or 'Flat'
  if not LIT[mode] then mode='Flat' end
  local opacity=math.clamp((tonumber(get('Chams/Opacity')) or 100)/100,.1,1)
  local visibleColor,hiddenColor=color(ctx,'Chams/Visible'),color(ctx,'Chams/Through Walls')
  detail.chams={mode=mode,visible=visibleOn,hidden=hiddenOn}
  r.hiddenRect=nil
  r.chamsOn=visibleOn or hiddenOn
  if not r.chamsOn then chamsOff(r); return end

  -- hidden layer; a ragdoll is driven by physics, not joints, so it only gets the visible layer
  local hiddenLayer=hiddenOn and not dead and #r.chassis>0
  if hiddenLayer then
   if r.clone and r.cloneDirty and now-(r.topologyTime or 0)>.3 then destroyClone(r) end
   if not r.clone and now>=(r.cloneRetry or 0) then buildClone(r); r.cloneDirty=false; r.litSig=nil end
  elseif r.clone then destroyClone(r); table.clear(r.walls) end

  -- visible layer: the real garments
  local sig=mode..'|'..visibleColor:ToHex()..'|'..opacity
  if visibleOn then
   if sig~=r.litSig or r.litDirty then
    if adapter then adapter.paintCosmetics(r.model,true,true)end
    r.litSig,r.litDirty=sig,false
    for _,p in ipairs(r.parts) do
     if p.Parent then surface(p,mode,visibleColor,opacity,saveSurface(r,p).transparency) end
    end
   end
  elseif next(r.surfaces) then restore(r) end
  if adapter and visibleOn then adapter.paintCosmetics(r.model,true,false)end

  local c=r.clone
  if c then
   local layer=r.layer
   if onScreen then
    local moved=not r.maskCamera or (cam.CFrame.Position-r.maskCamera.Position).Magnitude>.08 or cam.CFrame.LookVector:Dot(r.maskCamera.LookVector)<.99998
    local old=r.maskData and r.maskData.box;local box=r.maskBox
    local actorMoved=old and box and (math.abs(old[1]-box[1])>1 or math.abs(old[2]-box[2])>1 or math.abs(old[3]-box[3])>1 or math.abs(old[4]-box[4])>1)
    if moved or actorMoved or now-r.occTime>=.066 then sampleMask(r,cam,now) end
   end
   layer.clip.Visible=false
   for _,entry in pairs(r.extraMasks or {}) do
    entry.layer.clip.Visible=false
    if entry.clone and now-(entry.used or now)>2 then entry.clone.model:Destroy();entry.clone=nil;entry.signature=nil end
   end
   local data=r.maskData
   -- Keep tested regions in the screen coordinates that were actually raycast.
   -- Retiling an old mask to a moving body would drag hidden color across a wall edge.
   local box=data and data.box
   local show=onScreen and data and box and #data.rects>0
   detail.walls=0;for _ in pairs(r.walls) do detail.walls+=1 end
   detail.maskRegions=show and #data.rects or 0
   detail.occlusionRays=r.maskRays or 0
   if show then
    local size=overlay.AbsoluteSize
    local bx0,by0=math.clamp(box[1],0,size.X),math.clamp(box[2],0,size.Y)
    local bx1,by1=math.clamp(box[3],0,size.X),math.clamp(box[4],0,size.Y)
    local hsig=mode..'|'..hiddenColor:ToHex()..'|'..opacity
    local union=nil
    for index,rect in ipairs(data.rects) do
     local activeLayer,activeClone,signature=layer,c,r.cloneSig
     if index>1 then
      r.extraMasks=r.extraMasks or {}
      local entry=r.extraMasks[index]
      if not entry then entry={layer=newLayer()};r.extraMasks[index]=entry end
      entry.used=now
      if not entry.clone and now>=(entry.retry or 0) then entry.clone=cloneRig(r,entry.layer);if not entry.clone then entry.retry=now+.5 end end
      activeLayer,activeClone,signature=entry.layer,entry.clone,entry.signature
     end
     if activeClone then
      local x0=math.floor(bx0+(rect[1]-1)*(bx1-bx0)/data.cols)
      local y0=math.floor(by0+(rect[2]-1)*(by1-by0)/data.rows)
      local x1=math.ceil(bx0+rect[3]*(bx1-bx0)/data.cols)
      local y1=math.ceil(by0+rect[4]*(by1-by0)/data.rows)
      showLayer(activeLayer,cam,x0,y0,x1,y1,8001-2*math.min(math.floor(r.dist),4000))
      -- A short opacity entrance softens visibility changes without interpolating pose.
      activeLayer.vp.ImageTransparency=1-math.clamp((now-(r.maskSince or now))/.08,0,1)
      poseClone(activeClone)
      if signature~=hsig then
       for _,p in ipairs(r.parts) do
        local copy=activeClone.map[p]
        if copy then surface(copy,mode,hiddenColor,opacity,(r.surfaces[p] and r.surfaces[p].transparency) or p.Transparency) end
       end
       if index==1 then r.cloneSig=hsig else r.extraMasks[index].signature=hsig end
      end
      union=union and {math.min(union[1],x0),math.min(union[2],y0),math.max(union[3],x1),math.max(union[4],y1)} or {x0,y0,x1,y1}
     end
    end
    r.hiddenRect=union
   end
   detail.chamsMethod='RigMaterial+ViewportHidden'
  else
   detail.chamsMethod='RigMaterial'
  end
  detail.visibility=r.visibility
 end

 local function newRecord(owner)
  local r={owner=owner,bones={},parts={},boxParts={},surfaces={},walls={},chassis={},lastScan=0,lastStep=0,lastSeen=0,occTime=0,dist=0}
  r.ui=make('Frame',{Name=owner.Name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=2},overlay)
  r.boxOuter=outlined(r.ui,BLACK); r.box,r.boxStroke=outlined(r.ui,WHITE); r.boxInner=outlined(r.ui,BLACK)
  r.modelConnections={}
  r.name=label(r.ui,13); r.weapon=label(r.ui,12); r.hpText=label(r.ui,10,true)
  r.flags={}
  for i=1,7 do r.flags[i]=label(r.ui,10,true) end
  r.icon=make('ImageLabel',{BackgroundTransparency=1,Visible=false,ScaleType=Enum.ScaleType.Fit},r.ui)
  r.health=make('Frame',{BorderSizePixel=0,BackgroundColor3=BLACK,Visible=false},r.ui)
  r.healthFill=make('Frame',{BorderSizePixel=0,AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,1,1,-1)},r.health)
  r.ammo=make('Frame',{BorderSizePixel=0,BackgroundColor3=BLACK,Visible=false},r.ui)
  r.ammoFill=make('Frame',{BorderSizePixel=0,Position=UDim2.fromOffset(1,1)},r.ammo)
  r.arrow=label(r.ui,22); r.arrow.Text=utf8.char(9650); r.arrow.TextXAlignment=Enum.TextXAlignment.Center
  r.ring=make('Frame',{AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Visible=false},r.ui)
  make('UICorner',{CornerRadius=UDim.new(1,0)},r.ring)
  r.ringStroke=make('UIStroke',{Thickness=2},r.ring)
  r.weaponView=make('ViewportFrame',{BackgroundTransparency=1,Visible=false,Ambient=WHITE,LightColor=BLACK},r.ui)
  -- glow: concentric rings around the box, so the player's own model is never tinted
  r.aura={}
  for i=1,4 do
   local f,st=outlined(r.ui,WHITE)
   st.Thickness=3
   make('UICorner',{CornerRadius=UDim.new(0,3+i*2)},f)
   r.aura[i]={f=f,s=st}
  end
  records[owner]=r
  return r
 end
 -- Only anatomical joints from the driving skeleton belong in the overlay.
 -- Clothing meshes can carry duplicates and helper bones far outside the body.
 local aliases={
  Head={'head'}, Chest={'uppertorso','spine2','upperchest','chest','spine1','spine','torso'},
  Hips={'hips','pelvis','lowertorso'},
  LShoulder={'leftarm','leftupperarm','lupperarm'}, LElbow={'leftforearm','leftlowerarm','lforearm'}, LHand={'lefthand','lhand'},
  RShoulder={'rightarm','rightupperarm','rupperarm'}, RElbow={'rightforearm','rightlowerarm','rforearm'}, RHand={'righthand','rhand'},
  LHip={'leftupleg','leftupperleg','lthigh'}, LKnee={'leftleg','leftlowerleg','lcalf'}, LFoot={'leftfoot','lfoot'},
  RHip={'rightupleg','rightupperleg','rthigh'}, RKnee={'rightleg','rightlowerleg','rcalf'}, RFoot={'rightfoot','rfoot'},
 }
 local links={{'Head','Chest'},{'Chest','Hips'},
  {'Chest','LShoulder'},{'LShoulder','LElbow'},{'LElbow','LHand'},
  {'Chest','RShoulder'},{'RShoulder','RElbow'},{'RElbow','RHand'},
  {'Hips','LHip'},{'LHip','LKnee'},{'LKnee','LFoot'},
  {'Hips','RHip'},{'RHip','RKnee'},{'RKnee','RFoot'}}
 -- The 2D box follows the body, not the arms or the weapon, so it stays put while aiming.
 local boxNames={Head=true,UpperTorso=true,LowerTorso=true,LeftUpperLeg=true,RightUpperLeg=true,LeftLowerLeg=true,RightLowerLeg=true,LeftFoot=true,RightFoot=true}
 local function normalized(name)
  return name:lower():gsub('^.*:', ''):gsub('mixamorig',''):gsub('[^%a%d]','')
 end
 local function worldPosition(node)
  if node:IsA('Bone') then return node.TransformedWorldCFrame.Position end
  if node:IsA('Attachment') then return node.WorldPosition end
  return node.Position
 end
 local function resetModel(r,v)
  for _,c in ipairs(r.modelConnections) do c:Disconnect() end
  table.clear(r.modelConnections)
  restore(r)
  destroyClone(r)
  r.model=v; r.scanDirty=true; r.joints={}; r.parts={}; r.boxParts={}; r.chassis={}; r.occTime=0; r.cloneDirty=false; r.cloneRetry=nil; table.clear(r.walls)
  if v then
   local function topologyChanged(node)
    -- Footstep sounds, emitters and removed textures do not change the rig.
    if node:IsA('BasePart') or node:IsA('Bone') or node:IsA('WrapLayer') or node:IsA('WrapTarget') or node:IsA('Motor6D') or node:IsA('AnimationConstraint') or adapter and (node:IsA('Shirt')or node:IsA('Pants')or node:IsA('ShirtGraphic')or node:IsA('SpecialMesh')or node:IsA('Decal')) then
     r.scanDirty=true; r.litDirty=true; r.cloneDirty=true; r.topologyTime=os.clock()
    end
   end
   table.insert(r.modelConnections,v.DescendantAdded:Connect(topologyChanged))
   table.insert(r.modelConnections,v.DescendantRemoving:Connect(topologyChanged))
  end
  if #r.bones==0 then
   for _,pair in ipairs(links) do table.insert(r.bones,{keys=pair,line=line(r.ui)}) end
  end
 end
 local function scan(r,now)
  if not r.scanDirty then return end
  r.scanDirty=false
  r.joints,r.parts,r.boxParts,r.chassis={},{},{},{}
  local byName={}
  -- Prefer the skeleton below the root to any copies in garment MeshParts.
  local root=r.model.PrimaryPart or r.model:FindFirstChild('RootPart')
  local driving=root and root:GetDescendants() or {}
  for _,node in ipairs(driving) do
   if node:IsA('Bone') then byName[normalized(node.Name)]=node end
  end
  for _,node in ipairs(r.model:GetDescendants()) do
   if node:IsA('Bone') or node:IsA('BasePart') then
    local key=normalized(node.Name)
    if not byName[key] then byName[key]=node end
   end
   -- lenses and other see-through parts keep their own look under chams
   local saved=r.surfaces[node]
   if node:IsA('BasePart') and (saved and saved.transparency or node.Transparency)<.1 then table.insert(r.parts,node) end
  end
  for _,node in ipairs(r.model:GetChildren()) do
   if node:IsA('BasePart') then
    if boxNames[node.Name] then table.insert(r.boxParts,node) end
    -- the invisible body parts under the clothes are what the rays aim at
    if node:IsA('MeshPart') and node.Name~='HumanoidRootPart' and node.Transparency>=.99 then
     table.insert(r.chassis,{part=node})
    end
   end
  end
  if adapter then r.chassis=adapter.chassis(r.owner) end
  for key,names in pairs(aliases) do
   for _,name in ipairs(names) do if byName[name] then r.joints[key]=byName[name]; break end end
  end
 end
 -- Clip a segment to the camera near plane before projection, then to the viewport.
 local function projectSegment(cam,a,b)
  local ac,bc=cam.CFrame:PointToObjectSpace(a),cam.CFrame:PointToObjectSpace(b)
  local near=.1
  if ac.Z>-near and bc.Z>-near then return nil end
  if ac.Z>-near then a=a:Lerp(b,(-near-ac.Z)/(bc.Z-ac.Z))
  elseif bc.Z>-near then b=b:Lerp(a,(-near-bc.Z)/(ac.Z-bc.Z)) end
  local pa,pb=cam:WorldToViewportPoint(a),cam:WorldToViewportPoint(b)
  local x,y,dx,dy=pa.X,pa.Y,pb.X-pa.X,pb.Y-pa.Y
  local lo,hi=0,1
  local function clip(p,q)
   if math.abs(p)<1e-6 then return q>=0 end
   local t=q/p
   if p<0 then if t>hi then return false end; lo=math.max(lo,t)
   else if t<lo then return false end; hi=math.min(hi,t) end
   return true
  end
  local size=cam.ViewportSize
  if not (clip(-dx,x) and clip(dx,size.X-x) and clip(-dy,y) and clip(dy,size.Y-y)) then return nil end
  return Vector2.new(x+dx*lo,y+dy*lo),Vector2.new(x+dx*hi,y+dy*hi)
 end
 local function datum(owner,b,names)
  if adapter then local value=adapter.datum(owner,names);if value~=nil then return value end end
  for _,n in ipairs(names) do
   local v=owner:GetAttribute(n)
   if v==nil and b then v=b:GetAttribute(n) end
   if v~=nil then return v end
  end
  return nil
 end
 -- World-aligned box around the body parts, padded a little, projected to the screen.
 local function worldBox(parts)
  local lo,hi
  for _,part in ipairs(parts) do
   if part.Parent then
    local cf,s=part.CFrame,part.Size/2
    for ix=-1,1,2 do for iy=-1,1,2 do for iz=-1,1,2 do
     local p=cf:PointToWorldSpace(Vector3.new(s.X*ix,s.Y*iy,s.Z*iz))
     if lo then lo=Vector3.new(math.min(lo.X,p.X),math.min(lo.Y,p.Y),math.min(lo.Z,p.Z)); hi=Vector3.new(math.max(hi.X,p.X),math.max(hi.Y,p.Y),math.max(hi.Z,p.Z))
     else lo,hi=p,p end
    end end end
   end
  end
  return lo,hi
 end
 local function projectBox(cam,lo,hi)
  local mn,mx=Vector2.new(math.huge,math.huge),Vector2.new(-math.huge,-math.huge)
  local count=0
  for ix=0,1 do for iy=0,1 do for iz=0,1 do
   local q=cam:WorldToViewportPoint(Vector3.new(ix==0 and lo.X or hi.X,iy==0 and lo.Y or hi.Y,iz==0 and lo.Z or hi.Z))
   if q.Z>.1 then
    count+=1
    mn=Vector2.new(math.min(mn.X,q.X),math.min(mn.Y,q.Y)); mx=Vector2.new(math.max(mx.X,q.X),math.max(mx.Y,q.Y))
   end
  end end end
  return mn,mx,count
 end
 local function showText(o,value,x,y,w,c)
  o.Text=tostring(value); o.Position=UDim2.fromOffset(x,y); o.Size=UDim2.fromOffset(w,o.TextSize+4)
  o.TextColor3=c or WHITE; o.Visible=true
 end
 local flagStyle={Aiming={'AIM',Color3.fromRGB(255,205,100)},Credits={'$',Color3.fromRGB(135,225,115)},['Local Ping']={'MS',Color3.fromRGB(255,130,130)},Distance={'M',Color3.fromRGB(190,200,215)}}
 local function render(r,cam,dt,now)
  r.ui.Visible=false
  local owner=r.owner
  local detail={name=owner.Name,reason='no visual'}
  stats.details[owner.Name]=detail
  local v=visual(owner)
  if v~=r.model then resetModel(r,v) end
  if not v then chamsOff(r); return end
  local ctx=context(owner)
  detail.context=ctx
  local function get(p) return setting(ctx,p) end
  local b=body(owner)
  local hum=b and b:FindFirstChildOfClass('Humanoid')
  local hp=tonumber(datum(owner,b,{'BotHealth','Health'})) or (hum and hum.Health)
  local maxHp=tonumber(datum(owner,b,{'BotMaxHealth','MaxHealth'})) or (hum and hum.MaxHealth)
  local dead=datum(owner,b,{'Dead'})==true or (hp and hp<=0) or v:GetAttribute('Dead')==true or v:GetAttribute('Ragdolled')==true
  if dead and not get('Chams/Ragdolls') then chamsOff(r); detail.reason='dead'; return end
  local proxyRoot=b and (b:FindFirstChild('HumanoidRootPart') or b.PrimaryPart)
  if owner==localPlayer then
   if adapter and adapter.firstPerson(owner) then
    local changed=next(r.surfaces)~=nil
    chamsOff(r)
    if changed then adapter.restoreVisibility(owner)end
    detail.reason='first person self';return
   end
   local head=b and b:FindFirstChild('Head')
   local anchor=head or proxyRoot
   if (pov and pov._state and pov._state.visual==v) or (anchor and (cam.CFrame.Position-anchor.Position).Magnitude<2.5) then
    chamsOff(r); detail.reason='first person self'; return
   end
  end
  scan(r,now)
  local points,positions={},{}
  for key,node in pairs(r.joints) do
   if node.Parent then
    local p=worldPosition(node)
    if p.X==p.X and p.Y==p.Y and p.Z==p.Z then positions[key]=p; table.insert(points,p) end
   end
  end
  detail.joints=#points
  if #points<4 then
   chamsOff(r); detail.reason='waiting for driving skeleton'; return
  end
  local center=positions.Hips or positions.Chest or points[1]
  r.dist=(center-cam.CFrame.Position).Magnitude
  detail.distance=r.dist
  r.ui.Visible=true
  for _,o in ipairs({r.boxOuter,r.box,r.boxInner,r.name,r.weapon,r.hpText,r.icon,r.weaponView,r.health,r.ammo,r.arrow,r.ring}) do o.Visible=false end
  for _,f in ipairs(r.flags) do f.Visible=false end
  for _,a in ipairs(r.aura) do a.f.Visible=false end
  for _,bone in ipairs(r.bones) do bone.line.Visible=false end
  local viewport=cam.ViewportSize
  local mn,mx,count
  if #r.boxParts>=4 then
   local lo,hi=worldBox(r.boxParts)
   -- breathing room: a little above the helmet and below the boots, never thinner than a shoulder
   local pad=Vector3.new(.15,.12,.15)
   lo,hi=lo-pad,hi+pad
   local cx,cz=(lo.X+hi.X)/2,(lo.Z+hi.Z)/2
   local hx,hz=math.max((hi.X-lo.X)/2*.88,.95),math.max((hi.Z-lo.Z)/2*.88,.95)
   mn,mx,count=projectBox(cam,Vector3.new(cx-hx,lo.Y,cz-hz),Vector3.new(cx+hx,hi.Y+.1,cz+hz))
  else
   mn,mx,count=Vector2.new(math.huge,math.huge),Vector2.new(-math.huge,-math.huge),0
   local right,up=cam.CFrame.RightVector,cam.CFrame.UpVector
   local scale=positions.Head and positions.Hips and math.clamp((positions.Head-positions.Hips).Magnitude/2.4,.25,4) or 1
   for key,p in pairs(positions) do
    local radius=(key=='Head' and .4 or (key=='Chest' or key=='Hips') and .32 or .18)*scale
    for _,offset in ipairs({right*radius+up*radius,-right*radius-up*radius,right*radius-up*radius,-right*radius+up*radius}) do
     local q=cam:WorldToViewportPoint(p+offset)
     if q.Z>.1 then count+=1; mn=Vector2.new(math.min(mn.X,q.X),math.min(mn.Y,q.Y)); mx=Vector2.new(math.max(mx.X,q.X),math.max(mx.Y,q.Y)) end
    end
   end
  end
  local onScreen=count>0 and mx.X>=0 and mx.Y>=0 and mn.X<=viewport.X and mn.Y<=viewport.Y
  -- a chams failure must not take the 2D overlay down with it
  r.screenBox=nil
  r.maskCenter=center
  r.maskBox=onScreen and {mn.X-(mx.X-mn.X)*.2,mn.Y,mx.X+(mx.X-mn.X)*.2,mx.Y} or nil
  local okChams,errChams=pcall(updateChams,r,ctx,cam,now,detail,onScreen,dead)
  if not okChams then
   chamsOff(r); stats.errors+=1; detail.chamsError=tostring(errChams)
   if stats.lastError~=tostring(errChams) then stats.lastError=tostring(errChams); warn('[Neverlose for RIVALS ESP] chams: '..tostring(errChams)) end
  end
  if not onScreen then
   detail.reason='off screen'
   if get('Other/Out of FOV Arrows') then
    local p=cam.CFrame:PointToObjectSpace(center)
    local direction=Vector2.new(p.X,-p.Y)
    if direction.Magnitude<.001 then direction=Vector2.new(0,1) end
    direction=direction.Unit
    local radius=math.min(viewport.X,viewport.Y)*.4
    local at=viewport/2+direction*radius
    showText(r.arrow,utf8.char(9650),at.X-14,at.Y-14,28,color(ctx,'Other/Out of FOV Arrows'))
    r.arrow.Size=UDim2.fromOffset(28,28); r.arrow.Rotation=math.deg(math.atan2(direction.Y,direction.X))+90
    r.arrow.TextTransparency=math.clamp((r.dist-60)/240,0,.55)
   end
   return
  end
  local x,y=math.floor(mn.X+.5),math.floor(mn.Y+.5)
  local w,h=math.max(math.floor(mx.X-mn.X+.5),6),math.max(math.floor(mx.Y-mn.Y+.5),10)
  x,y=math.clamp(x,-3000,3000),math.clamp(y,-3000,3000); w,h=math.min(w,6000),math.min(h,6000)
  detail.reason=dead and 'ragdoll' or 'drawn'
  detail.bounds={x=x,y=y,width=w,height=h}
  if r.chamsOn then r.screenBox={x,y,w,h} end
  if dead then return end
  stats.rendered+=1
  if get('ESP/Bounding Box')==true then
   r.boxOuter.Visible,r.box.Visible,r.boxInner.Visible=true,true,true
   r.boxOuter.Position,r.boxOuter.Size=UDim2.fromOffset(x-1,y-1),UDim2.fromOffset(w+2,h+2)
   r.box.Position,r.box.Size=UDim2.fromOffset(x,y),UDim2.fromOffset(w,h)
   r.boxInner.Position,r.boxInner.Size=UDim2.fromOffset(x+1,y+1),UDim2.fromOffset(math.max(w-2,0),math.max(h-2,0))
   r.boxStroke.Color=color(ctx,'ESP/Bounding Box')
  end
  if get('Glow/Enabled') then
   local gc,style=color(ctx,'Glow/Enabled'),get('Glow/Style')
   local pulse=.5+.5*math.sin(now*3.2)
   for i,a in ipairs(r.aura) do
    local pad=2+i*3
    a.f.Visible=true
    a.f.Position=UDim2.fromOffset(x-pad,y-pad); a.f.Size=UDim2.fromOffset(w+pad*2,h+pad*2)
    a.s.Color=gc
    local base=style=='Outline' and (i==1 and .1 or i==2 and .55 or 1) or (.5+i*.11)
    a.s.Transparency=style=='Pulse' and math.clamp(base+(1-pulse)*.4,0,1) or base
   end
  end
  if get('ESP/Name') then showText(r.name,participant and participant.NameOf(owner) or owner.Name,x-60,y-20,w+120,color(ctx,'ESP/Name')); r.name.TextXAlignment=Enum.TextXAlignment.Center end
  if get('ESP/Health Bar') and hp and maxHp and maxHp>0 then
   local ratio=hp==math.huge and 1 or math.clamp(hp/maxHp,0,1)
   local fillH=math.floor((h)*ratio+.5)
   r.health.Visible=true; r.health.Position=UDim2.fromOffset(x-8,y-1); r.health.Size=UDim2.fromOffset(5,h+2)
   r.healthFill.Size=UDim2.new(1,-2,0,fillH); r.healthFill.BackgroundColor3=Color3.fromRGB(235,70,70):Lerp(Color3.fromRGB(90,225,110),ratio)
   if ratio<.995 then showText(r.hpText,math.ceil(hp),x-38,y+h-fillH-6,26); r.hpText.TextXAlignment=Enum.TextXAlignment.Right end
  end
  local weapon=datum(owner,b,{'CurrentWeapon'})
  local ammo=tonumber(datum(owner,b,{'Ammo','CurrentAmmo','MagazineAmmo'}))
  local capacity=tonumber(datum(owner,b,{'MaxAmmo','MagazineSize'}))
  if owner==localPlayer and gun and gun.Weapon then
   local state=gun.Weapon
   ammo=tonumber(state.MagAmmo) or ammo
   capacity=tonumber(state.MaxMagSize) or capacity
   weapon=state.Name or weapon
  end
  local bottom=y+h+3
  if get('ESP/Ammo') and ammo and capacity and capacity>0 then
   r.ammo.Visible=true; r.ammo.Position=UDim2.fromOffset(x-1,bottom); r.ammo.Size=UDim2.fromOffset(w+2,5)
   r.ammoFill.Size=UDim2.new(math.clamp(ammo/capacity,0,1),math.clamp(ammo/capacity,0,1)>0 and -2 or 0,1,-2); r.ammoFill.BackgroundColor3=color(ctx,'ESP/Ammo'); bottom+=7
  end
  local mode=get('ESP/Weapon')
  if weapon and weapon~='' and mode~='Disabled' then
   if mode=='Icon' or mode=='Text + Icon' then
    if adapter then
     r.icon.Image=adapter.weaponIcon(weapon) or '';r.icon.Visible=r.icon.Image~=''
     r.icon.Position=UDim2.fromOffset(math.floor(x+w/2-28),bottom);r.icon.Size=UDim2.fromOffset(56,22)
     if r.icon.Visible then bottom=bottom+23 end
    else
    if r.iconWeapon~=weapon then
     r.iconWeapon=weapon; r.weaponView.CurrentCamera=nil; r.weaponView:ClearAllChildren()
     -- the baked world model is the whole gun (the gunsmith model is only a stub); it stacks every
     -- attachment variant, so keep one per slot and draw it as a flat white silhouette
     local assets=RS:FindFirstChild('Assets')
     local baked=assets and assets:FindFirstChild('WorldModelsBaked')
     local source=baked and baked:FindFirstChild(weapon)
     if source and source:IsA('Model') then
      local clone=source:Clone()
      local all=clone:FindFirstChild('AllAttachments')
      if all then
       for _,slot in ipairs(all:GetChildren()) do
        for i,variant in ipairs(slot:GetChildren()) do if i>1 then variant:Destroy() end end
       end
      end
      for _,d in ipairs(clone:GetDescendants()) do
       if d:IsA('Sound') then d.PlayOnRemove=false; d:Destroy()
       elseif d:IsA('LuaSourceContainer') or d:IsA('ParticleEmitter') or d:IsA('Light') or d:IsA('SurfaceAppearance') or d:IsA('Decal') then d:Destroy()
       elseif d:IsA('BasePart') then
        d.Anchored,d.Color,d.Material=true,WHITE,Enum.Material.SmoothPlastic
        if d:IsA('MeshPart') then d.TextureID='' end
       end
      end
      clone.Parent=r.weaponView
      local cf,size=clone:GetBoundingBox()
      local camera=make('Camera',{FieldOfView=25},r.weaponView)
      local direction=silhouettes and silhouettes.View(weapon).LookVector or Vector3.new(1,0,0)
      camera.CFrame=CFrame.lookAt(cf.Position-direction*math.max(size.Magnitude*1.4,1),cf.Position)
      r.weaponView.CurrentCamera=camera
     end
    end
    if r.weaponView.CurrentCamera~=nil then
     r.weaponView.Visible=true
     r.weaponView.Position=UDim2.fromOffset(math.floor(x+w/2-30),bottom-1)
     r.weaponView.Size=UDim2.fromOffset(60,22); bottom+=21
    end
    end
   end
   if mode=='Text' or mode=='Text + Icon' then showText(r.weapon,weapon,x-60,bottom-1,w+120); r.weapon.TextXAlignment=Enum.TextXAlignment.Center end
  end
  local rows=0
  local function flag(text,c)
   rows+=1
   local o=r.flags[rows]
   if o then showText(o,text,x+w+5,y+(rows-1)*11-1,90,c); o.TextXAlignment=Enum.TextXAlignment.Left end
  end
  for _,name in ipairs(get('ESP/Flags') or {}) do
   local style=flagStyle[name]
   if name=='Aiming' and datum(owner,b,{'OwnAiming','Aiming'})==true then flag(style[1],style[2])
   elseif name=='Credits' then local n=datum(owner,b,{'Money','MatchIC'}); if n then flag(tostring(n)..' IC',style[2]) end
   elseif name=='Local Ping' then local n=tonumber(datum(owner,b,{'Ping'})); if not n and owner==localPlayer then n=localPlayer:GetNetworkPing()*2000 end; if n then flag(math.floor(n)..' '..style[1],style[2]) end
   elseif name=='Distance' then
    local m=units and units.StudsToMeters and units.StudsToMeters(r.dist) or r.dist*.28
    flag(math.floor(m+.5)..style[1],style[2])
   end
  end
  if dormant then flag('DORMANT',Color3.fromRGB(190,190,190)) end
  if get('ESP/Skeleton') then
   for _,bone in ipairs(r.bones) do
    local a,c=positions[bone.keys[1]],positions[bone.keys[2]]
    if a and c then
     local pa,pb=projectSegment(cam,a,c)
     if pa then segment(bone.line,pa,pb,color(ctx,'ESP/Skeleton')) end
    end
   end
  end
  if get('Other/Footstep Indicators') and proxyRoot then
   local moving=r.lastPosition and (proxyRoot.Position-r.lastPosition).Magnitude/math.max(dt,.001)>2
   r.lastPosition=proxyRoot.Position
   if moving and now-r.lastStep>.4 then r.lastStep=now end
   local age=now-r.lastStep
   if age<.4 then
    r.ring.Visible=true; r.ring.Position=UDim2.fromOffset(x+w/2,y+h); r.ring.Size=UDim2.fromOffset(20+age*100,8+age*30)
    r.ringStroke.Color=color(ctx,'Other/Footstep Indicators'); r.ringStroke.Transparency=age/.4
   end
  end
 end
 local lastDiscover=0
 -- The game's presenter uses RenderStepped connections, so subscribe after it
 -- instead of running in an earlier BindToRenderStep pass with the previous pose.
 local function renderFrame(dt)
  if stopped then return end
  local cam=workspace.CurrentCamera
  if not cam then overlay.Enabled=false; for _,r in pairs(records) do chamsOff(r) end; return end
  overlay.Enabled=true
  local now=os.clock()
  local started=now
  if now-lastDiscover>.25 then
   lastDiscover=now
   local all=participant and participant.All() or Players:GetPlayers()
   local seen={}
   for _,owner in ipairs(all) do
    seen[owner]=true
    if not records[owner] then
     local ok,err=pcall(newRecord,owner)
     if not ok then stats.errors+=1; stats.lastError=tostring(err) end
    end
   end
   for owner,r in pairs(records) do if not seen[owner] then destroy(r); records[owner]=nil end end
   stats.targets=#all
  end
  stats.rendered=0
  stats.chamsTargets=0
  stats.details={}
  for _,r in pairs(records) do
   local ok,err=pcall(render,r,cam,dt,now)
   if not ok then
    r.ui.Visible=false; chamsOff(r)
    stats.errors+=1
    if stats.lastError~=tostring(err) then stats.lastError=tostring(err); warn('[Neverlose for RIVALS ESP] '..tostring(err)) end
   end
   if ok and (r.clone or next(r.surfaces)) then stats.chamsTargets+=1 end
  end
  -- A target that stands in front of a farther target's hidden layer is drawn once more, as it
  -- looks in the world, just above that layer and only where they overlap, so a visible player
  -- in front of a wall is never painted over by someone behind it.
  for _,y in pairs(records) do
   local box,want=y.screenBox,nil
   if box and y.model then
    local padX,padY=box[3]*.6,box[4]*.08
    local bx0,by0,bx1,by1=box[1]-padX,box[2]-padY,box[1]+box[3]+padX,box[2]+box[4]+padY
    for _,x in pairs(records) do
     local h=x.hiddenRect
     if x~=y and h and x.dist>y.dist+.5 then
      local ix0,iy0,ix1,iy1=math.max(bx0,h[1]),math.max(by0,h[2]),math.min(bx1,h[3]),math.min(by1,h[4])
      if ix1>ix0 and iy1>iy0 then
       want=want and {math.min(want[1],ix0),math.min(want[2],iy0),math.max(want[3],ix1),math.max(want[4],iy1)} or {ix0,iy0,ix1,iy1}
      end
     end
    end
   end
   if want then
    -- the copy is taken from the rig as it looks right now, chams and all, and retaken on change
    local sig=(y.litSig or 'plain')..'|'..tostring(y.model)
    if y.frontClone and (y.frontSig~=sig or y.cloneDirty) then y.frontClone.model:Destroy(); y.frontClone=nil end
    if not y.frontClone then
     y.front=y.front or newLayer()
     y.frontClone=cloneRig(y,y.front,false)
     y.frontSig=sig
    end
    if y.frontClone then
     showLayer(y.front,cam,math.floor(want[1]),math.floor(want[2]),math.ceil(want[3]),math.ceil(want[4]),8000-2*math.min(math.floor(y.dist),4000))
     poseClone(y.frontClone)
    end
    y.frontUsed=now
   elseif y.front then
    y.front.clip.Visible=false
    if y.frontClone and now-(y.frontUsed or 0)>2 then y.frontClone.model:Destroy(); y.frontClone=nil end
   end
  end
  -- smoothed cost of one ESP frame, for status()
  stats.frameMs=(stats.frameMs or 0)*.9+(os.clock()-started)*100
 end
 -- Sample after all ordinary RenderStepped callbacks, including the presenter.
 -- A single pending update avoids accumulating work if a frame is delayed.
 local pending=false
 local renderConnection=connect(RunService.RenderStepped,function(dt)
  if pending or stopped then return end
  pending=true
  task.defer(function()
   pending=false
   if not stopped then renderFrame(dt) end
  end)
 end)
 local function cleanup()
  stopped=true; renderConnection:Disconnect()
  for _,r in pairs(records) do destroy(r) end
  table.clear(records); overlay:Destroy()
 end
 table.insert(cleanups,cleanup)
 return {status=function() return table.clone(stats) end}
end

end)()

local installWorldVisuals = (function()
-- World page visuals for the game's own client controllers.
-- Embedded in neverlose_ui.lua next to the live ESP; getValue reads "World/..." settings.
return function(getValue, connect, cleanups, adapter)
 local RS=game:GetService('ReplicatedStorage')
 local Players=game:GetService('Players')
 local RunService=game:GetService('RunService')
 local Lighting=game:GetService('Lighting')
 local SoundService=game:GetService('SoundService')
 local localPlayer=Players.LocalPlayer
 local modules=RS:FindFirstChild('Modules')
 local function module(path)
  if adapter then return adapter.resolve(path) end
  local node=modules
  for name in path:gmatch('[^/]+') do node=node and node:FindFirstChild(name) end
  if not node then return nil end
  local ok,result=pcall(require,node)
  return ok and result or nil
 end
 local bullets=module('Client/Controllers/BulletController')
 local combat=module('Client/CombatSignals')
 local fps=module('Client/Controllers/FPSController')
 local gun=module('Client/Controllers/GunController')
 local throwable=module('Client/Controllers/ThrowableController')
 local exposure=module('Client/Controllers/ExposureController')
 local pov=module('Client/CameraPOV')
 local presenter=module('Client/Character/OperatorPresenter')
 local merc=module('Client/Controllers/MercPlayerController')
 local povBody=module('Client/Controllers/MercPOVController')
 local WHITE,BLACK=Color3.new(1,1,1),Color3.new(0,0,0)
 local function setting(path) return getValue('World/'..path) end
 local function on(path) return setting(path)==true end
 local function color(path)
  local s=tostring(setting(path..'/Color') or 'FFFFFF'):gsub('#','')
  return Color3.fromRGB(tonumber(s:sub(1,2),16) or 255,tonumber(s:sub(3,4),16) or 255,tonumber(s:sub(5,6),16) or 255)
 end
 local function removed(name) return table.find(setting('Removals/Removals') or {},name)~=nil end
 local function make(class,props,parent)
  local o=Instance.new(class)
  for k,v in pairs(props) do o[k]=v end
  o.Parent=parent
  return o
 end
 -- Replace a function on one of the game's controller tables; put the original back on unload.
 local function hook(target,name,wrap)
  if type(target)~='table' or type(target[name])~='function' then return false end
  local had,original=rawget(target,name),target[name]
  local replacement=wrap(original);target[name]=replacement
  table.insert(cleanups,function() if target[name]==replacement then target[name]=had end end)
  return true
 end
 local thirdPerson=false
 local overlay=make('ScreenGui',{Name='NeverloseWorld',IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=998,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},localPlayer:WaitForChild('PlayerGui'))
 local world=make('Folder',{Name='NeverloseWorldFX'},workspace)
 table.insert(cleanups,function() overlay:Destroy(); world:Destroy() end)

 ---------------------------------------------------------------------------------------
 -- Removals (Post Processing and shadows are handled by the menu itself)
 ---------------------------------------------------------------------------------------
 -- Effects the game re-enables every frame are held off the moment it does.
 local held={}
 local function holdOff(inst,prop,want,active)
  if held[inst] then return end
  held[inst]=true
  local function enforce() if active() and inst[prop]~=want then inst[prop]=want end end
  local c=inst:GetPropertyChangedSignal(prop):Connect(enforce)
  table.insert(cleanups,function() c:Disconnect() end)
  enforce()
 end
 local function flashOff() return removed('Flash') end
 local function smokeOff() return removed('Smoke') end
 -- Flash: the game brightens exposure and blurs; drop its exposure share and the blur.
 hook(exposure,'SetContribution',function(original)
  return function(self,key,value,...)
   if key=='Flashbang' and flashOff() then value=nil end
   return original(self,key,value,...)
  end
 end)
 local function watchLighting(child)
  if child.Name=='FlashbangBlur' then holdOff(child,'Enabled',false,flashOff)
  elseif child.Name=='TeargasBlur' or child.Name=='TeargasColorCorrection' then holdOff(child,'Enabled',false,smokeOff) end
 end
 for _,child in ipairs(Lighting:GetChildren()) do watchLighting(child) end
 connect(Lighting.ChildAdded,watchLighting)
 -- Smoke: the tear gas cloud and the drifting smoke emitters around it.
 local smokeHidden={}
 local function isSmoke(inst)
  if not inst:IsA('ParticleEmitter') then return false end
  local name=inst.Name:lower()
  if name:find('smoke') or name:find('gas') or name:find('cloud') then return true end
  local model=inst:FindFirstAncestorWhichIsA('Model')
  return model~=nil and (model.Name:find('Teargas')~=nil or model.Name:find('Smoke')~=nil)
 end
 local function hideSmoke(inst)
  if smokeHidden[inst]~=nil or not isSmoke(inst) then return end
  smokeHidden[inst]=inst.Enabled
  inst.Enabled=false
  inst:Clear()
 end
 local smokeActive=false
 connect(workspace.DescendantAdded,function(inst)
  if smokeActive and inst:IsA('ParticleEmitter') then task.defer(hideSmoke,inst) end
 end)
 local function setSmoke(active)
  if active==smokeActive then return end
  smokeActive=active
  if active then
   for _,inst in ipairs(workspace:GetDescendants()) do if inst:IsA('ParticleEmitter') then hideSmoke(inst) end end
  else
   for inst,enabled in pairs(smokeHidden) do if inst.Parent then inst.Enabled=enabled end end
   table.clear(smokeHidden)
  end
 end
 table.insert(cleanups,function() setSmoke(false) end)
 -- Scope overlay: the black surround, cover, lens relief and blackout; the reticle stays.
 local SCOPE_PARTS={EdgeLeft=true,EdgeRight=true,EdgeTop=true,EdgeBottom=true,Cover=true,Relief=true,Blackout=true}
 local scopeHidden={}
 local function stepScope(active)
  if active then
   local gui=adapter and adapter.scope() or localPlayer.PlayerGui:FindFirstChild('ScopeOverlay')
   if gui then
    for _,d in ipairs(gui:GetDescendants()) do
     if (SCOPE_PARTS[d.Name] or adapter and (d.Name=='Circle' or d.Name=='Blur')) and d:IsA('GuiObject') then
      if scopeHidden[d]==nil then scopeHidden[d]=d.Visible end
      if d.Visible then d.Visible=false end
     end
    end
   end
  elseif next(scopeHidden) then
   for d,visible in pairs(scopeHidden) do if d.Parent then d.Visible=visible end end
   table.clear(scopeHidden)
  end
 end
 table.insert(cleanups,function() stepScope(false) end)
 -- Visual recoil: the camera's shake spring stops taking impulses and the FOV kick is held at
 -- rest, just before the camera renders. The aim recoil spring is left alone.
 local quiet={}
 local function stepRecoil(active)
  local cam=fps and fps.camera
  local shake=type(cam)=='table' and rawget(cam,'_recoilShakeSpring')
  if active and type(shake)=='table' then
   if quiet[shake]==nil then quiet[shake]=rawget(shake,'accelerate') or false; rawset(shake,'accelerate',function() end) end
   shake.p=Vector3.zero; shake.v=Vector3.zero
   local kick=rawget(cam,'_fovRecoilSpring')
   if kick then pcall(function() kick:setPos(0); kick:setVel(0) end) end
  elseif not active and next(quiet) then
   for spring,original in pairs(quiet) do rawset(spring,'accelerate',original or nil) end
   table.clear(quiet)
  end
 end
 RunService:BindToRenderStep('NeverloseRecoil',Enum.RenderPriority.Camera.Value-1,function()
  stepRecoil(removed('Visual Recoil'))
 end)
 table.insert(cleanups,function() RunService:UnbindFromRenderStep('NeverloseRecoil'); stepRecoil(false) end)

 ---------------------------------------------------------------------------------------
 -- Effects
 ---------------------------------------------------------------------------------------
 local fading={}
 local function fadeOut(duration,update,finish)
  table.insert(fading,{start=os.clock(),duration=duration,update=update,finish=finish})
 end
 connect(RunService.Heartbeat,function()
  local now=os.clock()
  for i=#fading,1,-1 do
   local f=fading[i]
   local k=(now-f.start)/f.duration
   if k>=1 then table.remove(fading,i); f.finish()
   else f.update(k) end
  end
 end)
 table.insert(cleanups,function() for _,f in ipairs(fading) do pcall(f.finish) end; table.clear(fading) end)
 local function excludeParams(extra)
  local params=RaycastParams.new()
  params.FilterType=Enum.RaycastFilterType.Exclude
  local list={world,workspace.CurrentCamera}
  if localPlayer.Character then table.insert(list,localPlayer.Character) end
  for _,e in ipairs(extra or {}) do table.insert(list,e) end
  params.FilterDescendantsInstances=list
  params.IgnoreWater=true
  return params
 end

 -- Bullet tracers: a glowing beam from the muzzle to where the shot landed.
 local tracers=0
 local function tracer(from,to,c)
  if tracers>=48 then return end
  tracers+=1
  local a0=make('Attachment',{WorldPosition=from},workspace.Terrain)
  local a1=make('Attachment',{WorldPosition=to},workspace.Terrain)
  local beam=make('Beam',{Attachment0=a0,Attachment1=a1,Color=ColorSequence.new(c),Width0=.07,Width1=.07,FaceCamera=true,LightEmission=1,LightInfluence=0,Segments=1,
   Transparency=NumberSequence.new(0)},a0)
  local glow=make('Beam',{Attachment0=a0,Attachment1=a1,Color=ColorSequence.new(c),Width0=.18,Width1=.18,FaceCamera=true,LightEmission=.6,LightInfluence=0,Segments=1,
   Transparency=NumberSequence.new(.88)},a0)
  fadeOut(1.6,function(k)
   local t=k*k
   beam.Transparency=NumberSequence.new(t)
   glow.Transparency=NumberSequence.new(.88+.12*t)
  end,function() a0:Destroy(); a1:Destroy(); tracers-=1 end)
 end
 local function muzzle(fallback)
  if gun and type(gun.GetMuzzleWorldPosition)=='function' then
   local ok,p=pcall(gun.GetMuzzleWorldPosition,gun)
   if ok and typeof(p)=='Vector3' then return p end
  end
  return fallback
 end
 if bullets and bullets.ShotEmitted then
  connect(bullets.ShotEmitted,function(_,origin,direction)
   if not on('Effects/Bullet Tracers') or typeof(origin)~='Vector3' or typeof(direction)~='Vector3' then return end
   local dir=direction.Magnitude>0 and direction.Unit or Vector3.new(0,0,-1)
   local hit=workspace:Raycast(origin,dir*2000,excludeParams())
   local to=hit and hit.Position or origin+dir*2000
   -- shots leave from the eye; in first person the line starts at the gun so it can be seen
   tracer(thirdPerson and origin or muzzle(origin),to,color('Effects/Bullet Tracers'))
  end)
 end

 -- Bullet impacts: a small box where each round hit a surface.
 local impacts=0
 local function impact(position,c)
  if impacts>=96 then return end
  impacts+=1
  local anchor=make('Part',{Anchored=true,CanCollide=false,CanQuery=false,CanTouch=false,Transparency=1,Size=Vector3.new(.05,.05,.05),CFrame=CFrame.new(position)},world)
  local box=make('BoxHandleAdornment',{Adornee=anchor,Size=Vector3.new(.22,.22,.22),Color3=c,Transparency=.25,AlwaysOnTop=false,ZIndex=1},anchor)
  local edge=make('SelectionBox',{Adornee=anchor,Color3=c,LineThickness=.012,SurfaceTransparency=1,Transparency=0},anchor)
  anchor.Size=Vector3.new(.22,.22,.22)
  fadeOut(4,function(k)
   local t=math.max(0,(k-.6)/.4)
   box.Transparency=.25+.75*t; edge.Transparency=t
  end,function() anchor:Destroy(); impacts-=1 end)
 end
 if combat and combat.LocalHit then
  connect(combat.LocalHit,function(_,position)
   if on('Effects/Bullet Impacts') and typeof(position)=='Vector3' then impact(position,color('Effects/Bullet Impacts')) end
  end)
 end

 -- Hit marker: four short white strokes around the crosshair, red on a headshot.
 local marker=make('Frame',{Name='HitMarker',AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(40,40),BackgroundTransparency=1,Visible=false},overlay)
 local strokes={}
 for i=0,3 do
  local angle=math.rad(45+i*90)
  local dir=Vector2.new(math.cos(angle),math.sin(angle))
  local s=make('Frame',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(20+dir.X*10,20+dir.Y*10),Size=UDim2.fromOffset(9,2),Rotation=math.deg(angle),BackgroundColor3=WHITE,BorderSizePixel=0},marker)
  make('UIStroke',{Color=BLACK,Thickness=1,Transparency=.3},s)
  strokes[i+1]=s
 end
 local markerToken=0

 -- Hit sound: tiny generated tones (8-bit PCM WAV) loaded as custom assets.
 local function wav(seconds,sample)
  local rate=22050
  local n=math.floor(seconds*rate)
  local bytes=table.create(n)
  for i=1,n do
   local v=sample((i-1)/rate)
   bytes[i]=string.char(math.clamp(math.floor(v*110+128),0,255))
  end
  local pcm=table.concat(bytes)
  return 'RIFF'..string.pack('<I4',36+n)..'WAVEfmt '..string.pack('<I4I2I2I4I4I2I2',16,1,1,rate,rate,1,8)..'data'..string.pack('<I4',n)..pcm
 end
 local TONES={
  Click=function(t) return (math.random()*2-1)*math.exp(-t*900)*.6+math.sin(t*2*math.pi*2600)*math.exp(-t*160)*.5 end,
  Bell=function(t) local e=math.exp(-t*7) return (math.sin(t*2*math.pi*1568)+.45*math.sin(t*2*math.pi*2352)+.25*math.sin(t*2*math.pi*3136))*e*.55 end,
  Bubble=function(t) return math.sin(2*math.pi*(380*t+2600*t*t))*math.exp(-t*22)*(t<.004 and t/.004 or 1)*.9 end,
 }
 local LENGTH={Click=.06,Bell=.55,Bubble=.18}
 local soundIds={}
 local function soundId(name)
  if soundIds[name]~=nil then return soundIds[name] or nil end
  soundIds[name]=false
  local ok,id=pcall(function()
   if not isfolder('neverlose_ui/sounds') then makefolder('neverlose_ui/sounds') end
   local path='neverlose_ui/sounds/'..name:lower()..'.wav'
   if not isfile(path) then writefile(path,wav(LENGTH[name],TONES[name])) end
   return getcustomasset(path)
  end)
  if ok and id then soundIds[name]=id end
  return soundIds[name] or nil
 end
 local function hitSound()
  local choice=setting('Effects/Hit Sound')
  if not TONES[choice] then return end
  local id=soundId(choice)
  if not id then
   -- no custom assets: fall back to the game's own hitmarker sound
   local sounds=RS:FindFirstChild('Assets') and RS.Assets:FindFirstChild('Sounds')
   local own=sounds and sounds:FindFirstChild('Hitmarker')
   id=own and own.SoundId
  end
  if not id then return end
  local s=make('Sound',{SoundId=id,Volume=1.6},SoundService)
  s:Play()
  s.Ended:Once(function() s:Destroy() end)
  task.delay(3,function() if s.Parent then s:Destroy() end end)
 end
 if bullets and bullets.HitConfirmed then
  connect(bullets.HitConfirmed,function(_,_,headshot)
   if on('Effects/Hit Marker') then
    markerToken+=1
    local token=markerToken
    local c=headshot and Color3.fromRGB(255,70,70) or WHITE
    for _,s in ipairs(strokes) do s.BackgroundColor3=c; s.BackgroundTransparency=0 end
    marker.Visible=true
    fadeOut(.45,function(k)
     if token~=markerToken then return end
     for _,s in ipairs(strokes) do s.BackgroundTransparency=math.max(0,(k-.35)/.65) end
    end,function() if token==markerToken then marker.Visible=false end end)
   end
   hitSound()
  end)
 end

 -- Grenade prediction: the throw the game would make right now, simulated with the same launch
 -- numbers (camera spawn point, ThrowSpeed, UpSpeed, the player's run speed, the 240 cap) and
 -- workspace gravity, bouncing off surfaces until the fuse runs out.
 local arc={}
 for i=1,90 do arc[i]=make('Frame',{AnchorPoint=Vector2.new(.5,.5),BorderSizePixel=0,BackgroundColor3=WHITE,Visible=false},overlay) end
 local landing=make('Frame',{AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Visible=false},overlay)
 make('UICorner',{CornerRadius=UDim.new(1,0)},landing)
 local landingStroke=make('UIStroke',{Color=WHITE,Thickness=2},landing)
 local function hideArc() for _,l in ipairs(arc) do l.Visible=false end; landing.Visible=false end
 local function predict()
  local projectile=throwable and throwable.Active and not throwable._throwing and type(throwable._entry)=='table' and throwable._entry.Projectile
  local cam=workspace.CurrentCamera
  if type(projectile)~='table' or not cam then return nil end
  local cf=cam.CFrame
  local pos=(cf*CFrame.new(0,-.6,-(projectile.SpawnDistance or 2))).Position
  local vel=cf.LookVector*(projectile.ThrowSpeed or 55)+Vector3.yAxis*(projectile.UpSpeed or 18)
  local root=localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
  if root then local v=root.AssemblyLinearVelocity; vel+=Vector3.new(v.X,0,v.Z) end
  if vel.Magnitude>240 then vel=vel.Unit*240 end
  local g=workspace.Gravity
  local params=excludeParams()
  local points={pos}
  local t,step,fuse=0,1/60,math.min(projectile.FuseTime or 2.5,4)
  local bounces=0
  while t<fuse and #points<400 do
   local nextVel=vel-Vector3.new(0,g*step,0)
   local delta=(vel+nextVel)/2*step
   local hit=workspace:Raycast(pos,delta,params)
   if hit then
    pos=hit.Position+hit.Normal*.15
    vel=(nextVel-2*nextVel:Dot(hit.Normal)*hit.Normal)*.4
    bounces+=1
    table.insert(points,pos)
    if vel.Magnitude<4 or bounces>5 then break end
   else
    pos+=delta
    vel=nextVel
    table.insert(points,pos)
   end
   t+=step
  end
  return points
 end
 local function drawArc(points,cam)
  local c=color('Effects/Grenade Prediction')
  -- keep about 90 segments however long the throw is
  local stride=math.max(1,math.ceil((#points-1)/#arc))
  local n=0
  for i=1,#points-1,stride do
   local a,b=points[i],points[math.min(i+stride,#points)]
   local pa,va=cam:WorldToViewportPoint(a)
   local pb,vb=cam:WorldToViewportPoint(b)
   n+=1
   local l=arc[n]
   if l and pa.Z>.1 and pb.Z>.1 then
    local d=Vector2.new(pb.X-pa.X,pb.Y-pa.Y)
    l.Position=UDim2.fromOffset((pa.X+pb.X)/2,(pa.Y+pb.Y)/2)
    l.Size=UDim2.fromOffset(d.Magnitude,2)
    l.Rotation=math.deg(math.atan2(d.Y,d.X))
    l.BackgroundColor3=c
    l.BackgroundTransparency=(n%2==0) and .35 or 0
    l.Visible=true
   elseif l then l.Visible=false end
  end
  for i=n+1,#arc do arc[i].Visible=false end
  local last=cam:WorldToViewportPoint(points[#points])
  landing.Visible=last.Z>.1
  if landing.Visible then
   local r=math.clamp(260/last.Z,6,40)
   landing.Position=UDim2.fromOffset(last.X,last.Y); landing.Size=UDim2.fromOffset(r*2,r)
   landingStroke.Color=c
  end
 end

 ---------------------------------------------------------------------------------------
 -- View
 ---------------------------------------------------------------------------------------
 local state=adapter and adapter.worldStatus or {requested=false,active=false,phase='first person',distance=0,errors=0}
 local visibility=function()end
 if not (adapter and adapter.native) then
 -- Viewmodel FOV: move the weapon along the view axis (further for a wider FOV); faded out
 -- while aiming so the sights stay where the game puts them. In third person it is put out of
 -- sight below the camera.
 hook(gun,'GetViewmodelOffset',function(original)
  return function(self,...)
   local offset,b,c=original(self,...)
   if typeof(offset)~='CFrame' then return offset,b,c end
   local fov=tonumber(setting('View/Viewmodel FOV')) or 68
   local push=(fov-68)*-.012*(1-math.clamp(self.AimAmount or 0,0,1))
   if push~=0 then offset=offset+Vector3.new(0,0,push) end
   return offset,b,c
  end
 end)
 -- Keep the native eye and muzzle transforms intact. Only the displayed camera moves.
 local presenting=false

 local hidden={};local shown={};local resolved=nil;local boom=0;local lastResolve=os.clock()
 local function restore(values)
  for part,value in pairs(values) do if part.Parent then part.LocalTransparencyModifier=value end;values[part]=nil end
 end
 local function present(want)
  if presenting==want or not presenter then return end
  presenting=want;presenter.SetViewPresentSelf(want)
 end
 visibility=function(active)
  local sources={}
  if active then
   local visual=povBody and povBody._state and povBody._state.visual
   if visual then sources[visual]=true end
   if gun and gun.Weapon and gun.Weapon.Model then sources[gun.Weapon.Model]=true end
  end
  for part,value in pairs(hidden) do
   local keep=false
   for model in pairs(sources) do if part:IsDescendantOf(model) then keep=true;break end end
   if not keep then if part.Parent then part.LocalTransparencyModifier=value end;hidden[part]=nil end
  end
  for model in pairs(sources) do for _,part in ipairs(model:GetDescendants()) do
   if part:IsA('BasePart') or part:IsA('Decal') then
    if hidden[part]==nil then hidden[part]=part.LocalTransparencyModifier end
    part.LocalTransparencyModifier=1
   end
  end end
  local rig=active and merc and merc.GetVisual(localPlayer)
  for part,value in pairs(shown) do
   if not rig or not part:IsDescendantOf(rig) then if part.Parent then part.LocalTransparencyModifier=value end;shown[part]=nil end
  end
  if rig then for _,part in ipairs(rig:GetDescendants()) do if part:IsA('BasePart') or part:IsA('Decal') then
   if shown[part]==nil then shown[part]=part.LocalTransparencyModifier end
   part.LocalTransparencyModifier=0
  end end end
 end
 local function wanted()
  local char=localPlayer.Character;local hum=char and char:FindFirstChildOfClass('Humanoid')
  local vehicle=localPlayer:GetAttribute('VehicleId')
  return on('View/Thirdperson') and hum and hum.Health>0 and localPlayer:GetAttribute('Deployed')~=false
   and not localPlayer:GetAttribute('Spectating') and not (type(vehicle)=='string' and vehicle~='')
 end
 local function cameraParams()
  local extra={}
  local rig=merc and merc.GetVisual(localPlayer)
  if rig then table.insert(extra,rig) end
  if gun and gun.Weapon and gun.Weapon.Model then table.insert(extra,gun.Weapon.Model) end
  local visual=povBody and povBody._state and povBody._state.visual
  if visual then table.insert(extra,visual) end
  local params=excludeParams(extra);params.RespectCanCollide=true
  return params
 end
 hook(pov,'Resolve',function(original)
  return function(eye,...)
   local cf=original(eye,...)
   local want=wanted()==true;state.requested=want;present(want)
   local rig=want and merc and merc.GetVisual(localPlayer)
   local scope=gun and gun._ScopeAmount and gun:_ScopeAmount() or 0
   thirdPerson=want and rig~=nil and scope<.15 and typeof(eye)=='CFrame'
   state.phase=not want and 'first person' or not rig and 'waiting for body' or scope>=.15 and 'scoped' or 'third person'
   local now=os.clock();local dt=math.clamp(now-lastResolve,0,.1);lastResolve=now
   if not thirdPerson then boom=0;resolved=nil;state.active=false;visibility(false);return cf end
   local offset=Vector3.new(1.1,.45,(tonumber(setting('View/Distance')) or 120)/20)
   local delta=eye:VectorToWorldSpace(offset)
   local params=cameraParams()
   local ok,hit=pcall(workspace.Spherecast,workspace,eye.Position,.35,delta,params)
   if not ok then hit=workspace:Raycast(eye.Position,delta,params) end
   local allowed=hit and math.max(0,hit.Distance-.12) or delta.Magnitude
   if allowed<boom then boom=allowed else boom=boom+(allowed-boom)*(1-math.exp(-16*dt)) end
   state.distance=boom;state.collision=hit~=nil
   if boom<1 then thirdPerson=false;resolved=nil;state.active=false;visibility(false);return cf end
   resolved=eye.Rotation+(eye.Position+delta.Unit*boom)
   state.active=true;visibility(true)
   return resolved
  end
 end)
 -- Aim at the shoulder camera's crosshair, but launch from the original eye.
 -- Ragebot wraps this later and supplies its target direction when tracking.
 hook(gun,'GetFireDirectionUnspread',function(original)
  return function(self,...)
   if thirdPerson and resolved and pov then
    local eye=pov.GetEyePosition()
    local hit=workspace:Raycast(resolved.Position,resolved.LookVector*2000,cameraParams())
    local point=hit and hit.Position or resolved.Position+resolved.LookVector*2000
    local delta=point-eye
    if delta.Magnitude>.001 then return delta.Unit end
   end
   return original(self,...)
  end
 end)
 table.insert(cleanups,function()thirdPerson=false;present(false);restore(hidden);restore(shown)end)

 end
 RunService:BindToRenderStep('NeverloseWorldVisuals',Enum.RenderPriority.Last.Value,function()
  setSmoke(removed('Smoke'))
  stepScope(removed('Scope Overlay'))
  if adapter then thirdPerson=adapter.thirdPerson end
  local ok,err=pcall(visibility,thirdPerson)
  if not ok then state.errors=state.errors+1;state.lastError=tostring(err) end
  local cam=workspace.CurrentCamera
  local points=on('Effects/Grenade Prediction') and cam and predict()
  if points and #points>1 then drawArc(points,cam) else hideArc() end
 end)
 table.insert(cleanups,function() RunService:UnbindFromRenderStep('NeverloseWorldVisuals') end)
 return {
  status=function()return table.clone(state)end,
  testHit=function(headshot) if bullets and bullets.HitConfirmed then bullets.HitConfirmed:Fire(nil,25,headshot==true,Vector3.zero) end end,
  testTracer=function(from,to) tracer(from,to,color('Effects/Bullet Tracers')) end,
  testImpact=function(position) impact(position,color('Effects/Bullet Impacts')) end,
 }
end

end)()

local installRagebot = (function()
-- Ragebot for the custom Participant / OperatorPresenter weapon pipeline.
local RageMath=(function()
 local M={}
 function M.profile(name,cfg)
  local n=tostring(name):lower(); local kind=tostring(cfg.Category or cfg.WeaponType or ''):lower()
  if n=='sniper' or n:find('awp') or n:find('awm') then return 'AWP' end
  if n:find('scout') or n:find('ssg') then return 'Scout' end
  if kind:find('sniper') or n:find('scar20') or n:find('g3sg') then return 'Auto Snipers' end
  if n:find('deagle') or n:find('eagle') or n:find('revolver') or tostring(cfg.AmmoType):find('50') then return 'Heavy Pistols' end
  if kind:find('pistol') or n=='m18' or n:find('glock') or n:find('m1911') or n:find('p226') then return 'Pistols' end
  if kind:find('smg') or n:find('ump') or n:find('mp5') or n:find('mp7') or n:find('mp9') or n:find('p90') or n:find('vector') or n:find('uzi') then return 'SMG' end
  return 'Rifles'
 end
 function M.setting(store,path,profile)
  local value=store.values[path..'@'..profile]
  if value==nil then value=store.values[path..'@Global'] end
  if value==nil then value=store.defaults[path] end
  return value
 end
 function M.chance(radius,distance,spreadDegrees)
  if distance<=.001 or spreadDegrees<=.00001 then return 100 end
  local spread=math.tan(math.rad(math.min(spreadDegrees,89)))*distance
  return math.clamp((radius/math.max(spread,.00001))^2*100,0,100)
 end
 -- Ray/OBB test in the hitbox's local coordinates.
 function M.rayBox(origin,direction,half,maxDistance)
  local enter,leave=0,maxDistance or math.huge
  for _,axis in ipairs({'X','Y','Z'}) do
   local o,d,h=origin[axis],direction[axis],half[axis]
   if math.abs(d)<1e-8 then if o < -h or o > h then return false end
   else
    local a,b=(-h-o)/d,(h-o)/d
    if a>b then a,b=b,a end
    enter=math.max(enter,a);leave=math.min(leave,b)
    if enter>leave then return false end
   end
  end
  return leave>=0 and enter<=leave
 end
 function M.cone(base,degrees,u,v)
  local z=math.cos(math.rad(degrees));z=z+(1-z)*u
  local r=math.sqrt(math.max(0,1-z*z));local phi=v*2*math.pi
  local forward=base.Unit
  local right=forward:Cross(math.abs(forward.Y)>.99 and Vector3.xAxis or Vector3.yAxis).Unit
  local up=right:Cross(forward).Unit
  return (right*(r*math.cos(phi))+up*(r*math.sin(phi))+forward*z).Unit
 end
 function M.compensate(desired,degrees,u,v)
  local base=desired.Unit
  for _=1,24 do
   local actual=M.cone(base,degrees,u,v)
   if (actual-desired).Magnitude<2e-6 then return base end
   local axis=actual:Cross(desired)
   if axis.Magnitude<1e-10 then break end
   base=CFrame.fromAxisAngle(axis.Unit,math.atan2(axis.Magnitude,actual:Dot(desired))):VectorToWorldSpace(base).Unit
  end
  return nil
 end
 function M.better(a,b,priority,bodyAim)
  if not b then return true end
  if bodyAim=='Prefer' and a.body~=b.body then return a.body end
  if priority=='Lowest Health' and a.health~=b.health then return a.health<b.health end
  if priority=='Lowest Distance' and a.distance~=b.distance then return a.distance<b.distance end
  if priority=='Hit Chance' and a.chance~=b.chance then return a.chance>b.chance end
  if a.damage~=b.damage then return a.damage>b.damage end
  if a.chance~=b.chance then return a.chance>b.chance end
  if a.angle~=b.angle then return a.angle<b.angle end
  return a.distance<b.distance
 end
 return M
end)()
return function(Store,connect,cleanups,isMenuOpen,notify,adapter)
 local RS=game:GetService('ReplicatedStorage')
 local Players=game:GetService('Players')
 local RunService=game:GetService('RunService')
 local UIS=game:GetService('UserInputService')
 local localPlayer=Players.LocalPlayer
 local function module(path)
  if adapter then return adapter.resolve(path) end
  local node=RS
  for name in path:gmatch('[^/]+') do node=node and node:FindFirstChild(name) end
  if not node then return nil end
  local ok,value=pcall(require,node)
  return ok and value or nil
 end
 local gun=module('Modules/Client/Controllers/GunController')
 local bullets=module('Modules/Client/Controllers/BulletController')
 local pov=module('Modules/Client/CameraPOV')
 local cameraController=module('Modules/Client/Controllers/CameraController')
 local spreadUtil=module('Modules/Shared/SpreadUtil')
 local movement=module('Modules/Client/QuakeMove')
 local participants=module('Modules/Shared/Participant')
 local merc=module('Modules/Client/Controllers/MercPlayerController')
 local hostility=module('Modules/Shared/Combat/Hostility')
 local damageModel=module('Modules/Shared/BodyDamage')
 local penetration=module('Modules/Shared/Penetration')
 local cartridge=module('Modules/Shared/Weapons/WeaponCartridge')
 local weapons=module('Registries/Weapons') or {}
 local bulletDefs=module('Registries/BulletDefs') or {}
 local state={phase='idle',profile='Global',scans=0,shots=0,errors=0,unsupported={}}
 local target,stopped,scanning=nil,false,false
 local records={}; local lastDiscovery=0; local lastScan=-math.huge
 local ownScope=false; local stopMovement=false
 local function get(path,profile)
  return RageMath.setting(Store,'Ragebot/'..path,profile or state.profile)
 end
 local function hook(object,name,wrap)
  if type(object)~='table' or type(object[name])~='function' then return false end
  local original=object[name]
  local replacement=wrap(original)
  object[name]=replacement
  table.insert(cleanups,function() if object[name]==replacement then object[name]=original end end)
  return true
 end
 local function body(owner)
  return participants and participants.BodyOf(owner) or (owner:IsA('Player') and owner.Character or nil)
 end
 local function health(owner,model)
  if adapter then return adapter.health(owner) end
  if owner:GetAttribute('Dead')==true or model:GetAttribute('Dead')==true or model:GetAttribute('Ragdolled')==true then return 0 end
  local value=tonumber(owner:GetAttribute('BotHealth'))
  local b=body(owner)
  local humanoid=b and b:FindFirstChildOfClass('Humanoid') or model:FindFirstChildOfClass('Humanoid')
  return value or (humanoid and humanoid.Health) or 0
 end
 local function hostile(owner)
  return owner~=localPlayer and hostility and hostility.IsHostile(localPlayer,owner)
 end
 local function deflecting(owner)
  return get('Accuracy/Anti-Katana')==true and adapter and adapter.isDeflecting and adapter.isDeflecting(owner)==true
 end
 local function protectionReason(owner)
  if deflecting(owner)then return 'katana deflecting'end
  if get('Accuracy/Anti-Shield')==true and adapter and adapter.isShielding and adapter.isShielding(owner)==true then return 'shield protected'end
 end
 local function enabled(profile)
  return get('Main/Enabled','Global')==true and get('Main/Enabled',profile)==true
 end
 local function blocked()
  if stopped or not enabled() then return 'disabled' end
  if isMenuOpen() or UIS:GetFocusedTextBox() then return 'menu open' end
  if not gun or not bullets or not pov or not participants or not merc or not hostility or not damageModel then return 'missing game adapter' end
  if adapter then local why=adapter.blocked();if why then return why end end
  if not gun.Weapon or not gun.Enabled then return 'no active weapon' end
  local character=(adapter and adapter.character() or localPlayer.Character)
  local hum=character and character:FindFirstChildOfClass('Humanoid')
  if not hum or hum.Health<=0 or localPlayer:GetAttribute('Deployed')==false then return 'not deployed' end
  if gun:ShouldBlockWeaponInput() then return 'game input blocked' end
  if gun._launcher or gun._isGenericItem or gun.ItemDisabled then return 'unsupported weapon' end
  if gun.Weapon.IsReloading or gun.SwapPhase~='idle' then return 'weapon busy' end
  return nil
 end
 -- Peek at a clone only; the original spread function advances the live RNG normally.
 local spreadRng=nil
 if spreadUtil and debug.getupvalues then
  local ok,values=pcall(debug.getupvalues,spreadUtil.RandomConeDirection)
  if ok then for _,value in pairs(values) do
   if typeof(value)=='Random' and pcall(function()return value:Clone()end) then spreadRng=value;break end
  end end
 end
 state.seedSupported=spreadRng~=nil;state.seedCorrections=0;state.seedFailures=0
 local spreadDepth=0
 local function seedActive()
  return spreadRng~=nil and enabled() and get('Accuracy/Seed Prediction')==true and not blocked()
 end
 local function seedBase(direction,angle)
  local copy=spreadRng:Clone()
  return RageMath.compensate(direction,angle,copy:NextNumber(),copy:NextNumber())
 end
 local function scoped(original,...)
  spreadDepth=spreadDepth+1
  local result=table.pack(pcall(original,...))
  spreadDepth=spreadDepth-1
  if not result[1] then error(result[2],0) end
  return table.unpack(result,2,result.n)
 end
 hook(spreadUtil,'RandomConeDirection',function(original)
  return function(direction,angle,...)
   if spreadDepth>0 and angle>0 and seedActive() then
    local base=seedBase(direction.Unit,angle)
    if base then
     local result=original(base,angle,...)
     state.seedCorrections=state.seedCorrections+1
     state.seedError=(result-direction.Unit).Magnitude
     return result
    end
    state.seedFailures=state.seedFailures+1
   end
   return original(direction,angle,...)
  end
 end)
 hook(gun,'GetFireDirection',function(original)
  return function(self,...)if self==gun then return scoped(original,self,...) end;return original(self,...)end
 end)
 hook(bullets,'Discharge',function(original)
  return function(self,name,...)
   if gun and gun.Weapon and name==gun.Weapon.Name then return scoped(original,self,name,...) end
   return original(self,name,...)
  end
 end)
 hook(gun,'ApplyRecoil',function(original)
  return function(self,...)if self==gun and seedActive() then return end;return original(self,...)end
 end)
 for _,name in ipairs({'Recoil','RecoilRock'}) do
  hook(cameraController,name,function(original)
   return function(self,...)if self==cameraController._active and seedActive() then return end;return original(self,...)end
  end)
 end
 local function release()
  target=nil; stopMovement=false; state.target=nil
  if ownScope then
   if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and gun and gun.AimHeld and not gun._aimLatched then gun:StopAiming() end
   ownScope=false
  end
 end
 local groups=adapter and adapter.targetGroups or {Head={'Head'},Chest={'UpperTorso','Torso'},Stomach={'LowerTorso'},Arms={'LeftUpperArm','RightUpperArm','LeftLowerArm','RightLowerArm'},Legs={'LeftUpperLeg','RightUpperLeg','LeftLowerLeg','RightLowerLeg'},Feet={'LeftFoot','RightFoot'}}
 local function refreshRecords(now)
  if now-lastDiscovery<.3 then return end
  lastDiscovery=now
  local seen={}
  for _,owner in ipairs(participants.All()) do
   if hostile(owner) then
    seen[owner]=true
    local model=merc.GetVisual(owner)
    local old=records[owner]
    if model and (not old or old.model~=model or now-(old.lastBuild or 0)>1) then
     local map={}
     for _,part in ipairs(model:GetDescendants()) do
      if part:IsA('BasePart') then
       local zone=part:GetAttribute('MercBodyPart') or part.Name
       if not map[zone] or part.CanQuery then map[zone]=part end
      end
     end
     if adapter then map=adapter.zones(owner) end
     records[owner]={owner=owner,model=model,zones=map,lastBuild=now}
    elseif not model then records[owner]=nil end
   end
  end
  for owner in pairs(records) do if not seen[owner] then records[owner]=nil end end
 end
 local function isPartOf(instance,record)
  return instance and instance:IsDescendantOf(record.model)
 end
 local function trace(record,origin,point,spec,params,muzzle)
  local delta=point-origin
  if delta.Magnitude<.001 then return nil end
  local direction=delta.Unit
  -- Use the game's own muzzle-clearance and glass-aware predictor first.
  local predicted=bullets:PredictHit(gun.Weapon.Name,origin,direction,muzzle,0,function(part) return isPartOf(part,record) end)
  if predicted then return predicted,1 end
  if not get('Main/Automatic Penetration') or not penetration then return nil end
  local pen=penetration.NewState(spec)
  if not pen then return nil end
  local exclude=table.clone(params.FilterDescendantsInstances)
  local rayParams=RaycastParams.new()
  rayParams.FilterType=Enum.RaycastFilterType.Exclude
  rayParams.IgnoreWater=params.IgnoreWater;rayParams.CollisionGroup=params.CollisionGroup
  params=rayParams
  local start=origin
  for _=1,5 do
   params.FilterDescendantsInstances=exclude
   local hit=workspace:Raycast(start,point-start,params)
   if not hit then break end
   if isPartOf(hit.Instance,record) then return hit.Instance,penetration.Carry(pen) end
   local ownerId=hit.Instance:GetAttribute('OwnerUserId')
   local owner=ownerId and participants.ByIdOf(ownerId)
   if not owner or not hostile(owner) then break end
   local rig=merc.GetVisual(owner)
   local zone=hit.Instance:GetAttribute('MercBodyPart') or hit.Instance.Name
   if not rig or not penetration.Pass(pen,zone) then break end
   table.insert(exclude,rig)
   start=hit.Position+direction*.02
  end
  return nil
 end
 local function pointFor(candidate,origin,spec)
  local base=candidate.part.CFrame:PointToWorldSpace(candidate.offset)
  local def=bulletDefs[spec.Projectile]
  if not def or (def.Speed or 0)<=0 then return base end
  local b=body(candidate.owner)
  local root=b and b:FindFirstChild('HumanoidRootPart')
  local velocity=root and root.AssemblyLinearVelocity or candidate.velocity or Vector3.zero
  local acceleration=def.Acceleration or Vector3.zero
  local point=base
  for _=1,5 do
   local time=(point-origin).Magnitude/def.Speed
   point=base+velocity*time-acceleration*(.5*time*time)
  end
  return point
 end
 local function spreadChance(candidate,origin,point,spec,samples)
  local angle=math.max(0,gun:_GetEffectiveBloomDeg())+math.deg(spec.SpreadAngle or 0)
  if angle<.00001 then return 100 end
  if seedActive() and seedBase((point-origin).Unit,gun:_GetEffectiveBloomDeg()) and seedBase((point-origin).Unit,math.deg(spec.SpreadAngle or 0)) then return 100 end
  local delta=point-origin
  if delta.Magnitude<.001 then return 100 end
  local direction=delta.Unit
  local right=direction:Cross(Vector3.yAxis)
  if right.Magnitude<.001 then right=direction:Cross(Vector3.xAxis) end
  right=right.Unit
  local up=right:Cross(direction).Unit
  local cf=candidate.part.CFrame
  local lead=point-cf:PointToWorldSpace(candidate.offset)
  local localOrigin=cf:PointToObjectSpace(origin-lead)
  local half=candidate.part.Size*.49
  local maxDistance=(bulletDefs[spec.Projectile] or {}).MaxDistance or spec.Range or 1000
  local cap=math.cos(math.rad(math.min(angle,89)))
  local hits=0
  for i=0,samples-1 do
   local cosine=1-(1-cap)*(i+.5)/samples
   local sine=math.sqrt(math.max(0,1-cosine*cosine))
   local phi=i*2.399963229728653
   local ray=adapter and adapter.sampleSpread(direction,angle,i,samples) or direction*cosine+(right*math.cos(phi)+up*math.sin(phi))*sine
   if RageMath.rayBox(localOrigin,cf:VectorToObjectSpace(ray),half,maxDistance) then hits+=1 end
  end
  return hits/samples*100
 end
 local function specFor(weapon)
  return cartridge and cartridge.SpecFor(localPlayer,weapon.Name) or weapons[weapon.Name]
 end
 local function discover()
  if scanning then return target end
  scanning=true
  local ok,result=pcall(function()
   local weapon=gun and gun.Weapon
   if not weapon then state.phase='no active weapon'; return nil end
   local spec=specFor(weapon)
   if not spec then state.phase='missing weapon specification'; return nil end
   state.profile=RageMath.profile(weapon.Name,weapons[weapon.Name] or spec)
   state.weapon=weapon.Name
   local why=blocked()
   if why then state.phase=why; return nil end
   if not bullets:AssistSupported(weapon.Name) then state.phase='unsupported projectile'; return nil end
   local now=os.clock(); refreshRecords(now)
   local eye=pov.GetEyeCFrame(); local origin=eye.Position
   local params=bullets.ProjectileParams(localPlayer)
   local muzzle=gun:GetActiveProjectileMuzzleWorldCFrame()
   local best=nil;local protected=0;local shielded=0;local damageRejected=0;local bestDamage=0
   local minDamage=tonumber(get('Accuracy/Minimum Damage')) or 0
   local fov=tonumber(get('Main/Field of View')) or 180
   local selected=get('Selection/Hitboxes') or {}
   local multi=get('Selection/Multipoint') or {}
   local bodyAim=get('Selection/Body Aim') or 'Default'
   for owner,record in pairs(records) do
    local hp=health(owner,record.model)
    if adapter then record.zones=adapter.zones(owner)end
    local protection=hp>0 and record.model.Parent and hostile(owner)and protectionReason(owner)
    if protection=='katana deflecting'then protected+=1
    elseif protection=='shield protected'then shielded+=1 end
    if hp>0 and record.model.Parent and hostile(owner) and not protection then
     for _,group in ipairs(selected) do
      if bodyAim~='Force' or group~='Head' then
       for _,zone in ipairs(groups[group] or {}) do
        local part=record.zones[zone]
        if part and part.Parent then
         local offsets={Vector3.zero}
         if table.find(multi,group) then
          local scale=(tonumber(get(group=='Head' and 'Selection/Head Scale' or 'Selection/Body Scale')) or 50)/100*.5
          table.insert(offsets,Vector3.new(part.Size.X*scale,0,0));table.insert(offsets,Vector3.new(-part.Size.X*scale,0,0))
          table.insert(offsets,Vector3.new(0,part.Size.Y*scale,0));table.insert(offsets,Vector3.new(0,-part.Size.Y*scale,0))
         end
         for pointIndex,offset in ipairs(offsets) do
          local candidate={owner=owner,model=record.model,part=part,offset=offset,health=hp,body=group~='Head',weapon=weapon}
          local point=pointFor(candidate,origin,spec)
          local delta=point-origin; local distance=delta.Magnitude
          if distance>.01 and distance<=((bulletDefs[spec.Projectile] or {}).MaxDistance or spec.Range or 1000) then
           local angle=math.deg(math.acos(math.clamp(eye.LookVector:Dot(delta.Unit),-1,1)))
           if angle<=fov then
            local hit,carry=trace(record,origin,part.CFrame:PointToWorldSpace(offset),spec,params,muzzle)
            if hit then
             local actualZone=(adapter and adapter.zone(hit)) or hit:GetAttribute('MercBodyPart') or hit.Name
             local damage=damageModel.BaseDamageAtDistance(spec,distance)*(actualZone=='Head' and (spec.HeadshotMult or 1) or damageModel.Multiplier(actualZone))*carry
             bestDamage=math.max(bestDamage,damage)
             if minDamage>0 and damage<minDamage and damage<hp then damageRejected+=1 end
             if (bodyAim~='Force' or actualZone~='Head') and (minDamage==0 or damage>=minDamage or damage>=hp) then
              candidate.body=actualZone~='Head'
              candidate.point=point;candidate.distance=distance;candidate.angle=angle;candidate.damage=damage
              candidate.chance=spreadChance(candidate,origin,point,spec,24)
              candidate.penetrated=carry<1
              if RageMath.better(candidate,best,get('Selection/Target'),bodyAim) then best=candidate end
              if pointIndex==1 then break end
             end
            end
           end
          end
         end
        end
       end
      end
     end
    end
   end
   state.scans+=1;state.deflectingTargets=protected;state.shieldedTargets=shielded
   state.minimumDamage=minDamage;state.bestAvailableDamage=bestDamage;state.damageRejected=damageRejected
   state.phase=best and 'tracking' or damageRejected>0 and 'damage below minimum' or protected>0 and 'katana deflecting' or shielded>0 and 'shield protected' or 'no valid target'
   if best then best.expires=now+.15; state.target={name=participants.NameOf(best.owner),zone=best.part.Name,damage=best.damage,chance=best.chance,distance=best.distance,penetrated=best.penetrated} else state.target=nil end
   return best
  end)
  scanning=false
  if not ok then
   state.errors+=1;state.lastError=tostring(result);state.phase='error'
   if state.errors==1 then warn('[Neverlose for RIVALS Ragebot] '..state.lastError) end
   return nil
  end
  return result
 end
 local function validTarget()
  if not target or not gun or target.weapon~=gun.Weapon or os.clock()>target.expires or not target.part.Parent or not target.model.Parent or not hostile(target.owner) or health(target.owner,target.model)<=0 then return nil end
  if blocked() then return nil end
  local protection=protectionReason(target.owner)
  if protection then state.phase=protection;return nil end
  return target
 end
 if adapter then
  table.insert(cleanups,adapter.setShotTargetProvider(function(origin)
   local candidate=validTarget();if not candidate then return end
   local point=pointFor(candidate,origin,specFor(gun.Weapon))
   return point,candidate.part,CFrame.new(candidate.part.CFrame:PointToObjectSpace(point))
  end))
  table.insert(cleanups,adapter.setHideScopeProvider(function()return get('Accuracy/Hide Scope')==true end))
  table.insert(cleanups,adapter.setHideShotsProvider(function()
   local w=gun and gun.Weapon
   if stopped or not w or not bullets:AssistSupported(w.Name)then return false end
   -- Resolve the equipped profile immediately, including switches between render steps.
   local profile=RageMath.profile(w.Name,weapons[w.Name]or {})
   return enabled(profile)and get('Accuracy/Hide Shots',profile)==true
  end))
 end
 local legacyScope,legacyScopeEnabled
 local function hideLegacyScope()
  if adapter then return end
  local gui=localPlayer.PlayerGui:FindFirstChild('ScopeOverlay')
  if legacyScope and (gui~=legacyScope or get('Accuracy/Hide Scope')~=true)then
   if legacyScope.Parent then legacyScope.Enabled=legacyScopeEnabled end;legacyScope=nil
  end
  if gui and gui:IsA('ScreenGui')and get('Accuracy/Hide Scope')==true then
   if not legacyScope then legacyScope=gui;legacyScopeEnabled=gui.Enabled end
   gui.Enabled=false
  end
 end
 table.insert(cleanups,function()if legacyScope and legacyScope.Parent then legacyScope.Enabled=legacyScopeEnabled end end)
 hook(gun,'GetFireDirectionUnspread',function(original)
  return function(self,...)
   local candidate=validTarget()
   if candidate then
    local origin=pov.GetEyePosition();local point=pointFor(candidate,origin,specFor(self.Weapon))
    local delta=point-origin
    if delta.Magnitude>.001 then return delta.Unit end
   end
   return original(self,...)
  end
 end)
 hook(movement,'GetWishDir',function(original)
  return function(self,...)
   if not stopped and not blocked() then
    if stopMovement then
     if get('Accuracy/Auto Stop')=='Full' then self.Velocity=Vector3.new(0,self.Velocity.Y,0) end
     return Vector3.zero
    end
   end
   return original(self,...)
  end
 end)
 local function step()
  if stopped then return end
  if gun and gun.Weapon then state.profile=RageMath.profile(gun.Weapon.Name,weapons[gun.Weapon.Name] or {}) end
  hideLegacyScope()
  local why=blocked()
  if why then state.phase=why;release();return end
  local now=os.clock()
  if now-lastScan>=.05 then target=discover();lastScan=now end
  local candidate=validTarget()
  if not candidate then release();return end
  local threshold=tonumber(get('Accuracy/Hit Chance')) or 0
  state.requiredHitChance=threshold
  local ready=candidate.chance>=threshold
  local scopeReady=true
  local stopMode=get('Accuracy/Auto Stop') or 'Disabled'
  local wait=gun.Weapon:TimeUntilNextPull()
  stopMovement=stopMode=='Early' or stopMode=='Full' or stopMode=='Between Shots' and wait>0
  if get('Accuracy/Auto Scope') and (state.profile=='AWP' or state.profile=='Scout' or state.profile=='Auto Snipers') then
   if not gun.AimHeld then gun:StartAiming();ownScope=true end
   if (gun.AimAmount or 0)<.9 then ready=false;scopeReady=false;state.phase='scoping' end
  end
  if not get('Main/Silent Aim') and cameraController and cameraController._active then
   local eye=pov.GetEyePosition()
   local cam=workspace.CurrentCamera
   local aimOrigin=cam and (cam.CFrame.Position-eye).Magnitude>.5 and cam.CFrame.Position or eye
   local dir=(pointFor(candidate,eye,specFor(gun.Weapon))-aimOrigin).Unit
   local camera=cameraController._active
   local yaw=math.atan2(-dir.X,-dir.Z);local pitch=math.asin(math.clamp(dir.Y,-1,1))
   camera._yawTarget=yaw;camera._yawCurrent=yaw;camera._pitchTarget=pitch;camera._pitchCurrent=pitch
  end
  -- Re-check the live hitbox, muzzle clearance, damage and current spread immediately
  -- before firing. Acquisition can be up to one scan old; the shot must not be.
  if get('Main/Automatic Fire') and wait<=0 then
   local spec=specFor(gun.Weapon)
   local origin=pov.GetEyePosition()
   local current=candidate.part.CFrame:PointToWorldSpace(candidate.offset)
   local record=records[candidate.owner]
   local hit,carry
   -- Preserve both returns from the native trace.
   if record then hit,carry=trace(record,origin,current,spec,bullets.ProjectileParams(localPlayer),gun:GetActiveProjectileMuzzleWorldCFrame()) end
   if not hit then state.phase='shot obstructed';target=nil;return end
   local zone=(adapter and adapter.zone(hit)) or hit:GetAttribute('MercBodyPart') or hit.Name
   local dealt=damageModel.BaseDamageAtDistance(spec,(current-origin).Magnitude)*(zone=='Head' and (spec.HeadshotMult or 1) or damageModel.Multiplier(zone))*(carry or 1)
   local minimum=tonumber(get('Accuracy/Minimum Damage')) or 0
   if minimum>0 and dealt<minimum and dealt<health(candidate.owner,candidate.model) then state.phase='damage below minimum';return end
   candidate.chance=spreadChance(candidate,origin,pointFor(candidate,origin,spec),spec,64)
   ready=scopeReady and candidate.chance>=threshold
   if state.target then state.target.chance=candidate.chance;state.target.damage=dealt end
   state.accuracySamples=64
  end
  state.currentHitChance=candidate.chance
  if not ready then state.phase=scopeReady and 'waiting for accuracy' or 'scoping';return end
  if get('Main/Automatic Fire') and wait<=0 and not gun.Weapon.BurstFiring then
   local protection=protectionReason(candidate.owner)
   if protection then state.phase=protection;release();return end
   gun.Weapon:ReleaseTrigger()
   if gun:FireWeapon() then state.shots+=1;state.phase='fired' end
  end

 end
 local pending=false
 connect(RunService.RenderStepped,function()
  if pending or stopped then return end
  pending=true
  task.defer(function()
   pending=false
   if stopped then return end
   local ok,err=pcall(step)
   if not ok then release();state.errors+=1;state.lastError=tostring(err);state.phase='error';if state.errors==1 then warn('[Neverlose for RIVALS Ragebot] '..state.lastError) end end
  end)
 end)
 table.insert(cleanups,function() stopped=true;release();table.clear(records) end)
 return {
  status=function() local copy=table.clone(state);copy.unsupported=table.clone(state.unsupported);if state.target then copy.target=table.clone(state.target) end;return copy end,
  scan=function() target=discover();return target and {name=participants.NameOf(target.owner),zone=target.part.Name,damage=target.damage,chance=target.chance} or nil end,
 }
end

end)()

local installLegitbot = (function()
-- Camera aim assist through the game's native camera controller. Never fires a weapon.
local LegitMath={}
function LegitMath.wrap(angle)return (angle+math.pi)%(2*math.pi)-math.pi end
function LegitMath.alpha(smoothing,dt)return 1-math.exp(-60*math.clamp(dt,0,.1)/math.max(1,smoothing))end
function LegitMath.angle(current,target,smoothing,dt)return current+LegitMath.wrap(target-current)*LegitMath.alpha(smoothing,dt)end
return function(Store,connect,cleanups,isMenuOpen,adapter)
 local Players=game:GetService('Players')
 local RS=game:GetService('ReplicatedStorage')
 local Run=game:GetService('RunService')
 local UIS=game:GetService('UserInputService')
 local player=Players.LocalPlayer
 local function module(path)
  if adapter then return adapter.resolve(path)end
  local node=RS:FindFirstChild('Modules')
  for name in path:gmatch('[^/]+')do node=node and node:FindFirstChild(name)end
  if not node then return nil end
  local ok,value=pcall(require,node);return ok and value or nil
 end
 local participants=module('Shared/Participant')
 local hostility=module('Shared/Combat/Hostility')
 local merc=module('Client/Controllers/MercPlayerController')
 local gun=module('Client/Controllers/GunController')
 local bullets=module('Client/Controllers/BulletController')
 local pov=module('Client/CameraPOV')
 local cameraController=module('Client/Controllers/CameraController')
 local function get(path)
  local key='Legitbot/'..path;local value=Store.values[key]
  if value==nil then value=Store.defaults[key]end
  return value
 end
 local function rgba()
  local s=tostring(get('Visuals/FOV Circle/Color')or '69A7FF'):gsub('#','')
  return Color3.fromRGB(tonumber(s:sub(1,2),16)or 105,tonumber(s:sub(3,4),16)or 167,tonumber(s:sub(5,6),16)or 255)
 end
 local overlay=Instance.new('ScreenGui');overlay.Name='NeverloseLegit';overlay.IgnoreGuiInset=true;overlay.ResetOnSpawn=false;overlay.DisplayOrder=997;overlay.Parent=player:WaitForChild('PlayerGui')
 local circle=Instance.new('Frame');circle.Name='AimFOV';circle.BackgroundTransparency=1;circle.AnchorPoint=Vector2.new(.5,.5);circle.Visible=false;circle.Parent=overlay
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(1,0);corner.Parent=circle
 local stroke=Instance.new('UIStroke');stroke.Thickness=1;stroke.Transparency=.4;stroke.Parent=circle
 local state={phase='disabled',errors=0,aimFrames=0}
 local stopped=false;local target;local acquired=0
 local function clear(phase)target=nil;state.target=nil;state.phase=phase end
 local function held()
  if get('Main/Activation')=='Always'then return true end
  local key=get('Main/Aim Key')or 'Mouse2'
  local buttons={Mouse1=Enum.UserInputType.MouseButton1,Mouse2=Enum.UserInputType.MouseButton2,Mouse3=Enum.UserInputType.MouseButton3}
  if buttons[key]then return UIS:IsMouseButtonPressed(buttons[key])end
  local ok,code=pcall(function()return Enum.KeyCode[key]end)
  return ok and code~=Enum.KeyCode.Unknown and UIS:IsKeyDown(code)
 end
 local function blocked()
  if get('Main/Enabled')~=true then return 'disabled'end
  if isMenuOpen() or UIS:GetFocusedTextBox()then return 'menu open'end
  local rage=Store.values['Ragebot/Main/Enabled@Global']
  if rage==nil then rage=Store.defaults['Ragebot/Main/Enabled']end
  if rage==true then return 'Ragebot priority'end
  if not (participants and hostility and merc and gun and bullets and pov and cameraController and cameraController._active)then return 'missing game adapter'end
  if not gun.Weapon or not gun.Enabled then return 'no active weapon'end
  if gun:ShouldBlockWeaponInput()then return 'game input blocked'end
  if adapter then local w=adapter.nativeItem();if w and w.Info.Type~='Gun'then return 'not a gun'end end
  local character=adapter and adapter.character()or player.Character
  local hum=character and character:FindFirstChildOfClass('Humanoid')
  if not hum or hum.Health<=0 then return 'not deployed'end
 end
 local function health(owner,model)
  if adapter then return adapter.health(owner)end
  if owner:GetAttribute('Dead')or model:GetAttribute('Dead')then return 0 end
  local body=participants.BodyOf(owner);local hum=body and body:FindFirstChildOfClass('Humanoid')
  return tonumber(owner:GetAttribute('BotHealth'))or hum and hum.Health or 0
 end
 local function visible(model,from,point,params)
  local delta=point-from
  if delta.Magnitude<.001 then return true end
  local hit=workspace:Raycast(from,delta,params)
  return not hit or hit.Instance:IsDescendantOf(model)
 end
 local function selectTarget(cam,radius)
  local size=cam.ViewportSize;local center=size*.5
  local eye=pov.GetEyePosition();local params=bullets.ProjectileParams(player)
  local maxDistance=tonumber(get('Selection/Maximum Distance'))or 1000
  local hitbox=get('Aim/Hitbox')or 'Head'
  local best,bestScore
  for _,owner in ipairs(participants.All())do if owner~=player and (get('Selection/Team Check')==false or hostility.IsHostile(player,owner))then
   local model=merc.GetVisual(owner)
   if model and model.Parent and health(owner,model)>0 then
    local zones=adapter and adapter.zones(owner)or {}
    local head=zones.Head or model:FindFirstChild('Head',true)
    local body=zones.Body or model:FindFirstChild('UpperTorso',true)or model:FindFirstChild('Torso',true)
    local choices={}
    if hitbox~='Body' and head then table.insert(choices,head)end
    if hitbox~='Head' and body then table.insert(choices,body)end
    for _,part in ipairs(choices)do if part and part:IsA('BasePart')and part.Parent then
     local point=part.Position;local distance=(point-eye).Magnitude
     local screen,onScreen=cam:WorldToViewportPoint(point)
     local pixels=(Vector2.new(screen.X,screen.Y)-center).Magnitude
     if onScreen and screen.Z>.1 and distance<=maxDistance and pixels<=radius then
      local clearLine=get('Selection/Visible Only')==false or visible(model,eye,point,params)and visible(model,cam.CFrame.Position,point,params)
      if clearLine then
       local locked=get('Selection/Target Lock')~=false and target and target.owner==owner and target.part==part
       local score=locked and -1 or pixels
       if not bestScore or score<bestScore then
        bestScore=score;best={owner=owner,model=model,part=part,distance=distance,pixels=pixels}
       end
      end
     end
    end end
   end
  end end
  return best
 end
 local function step(dt)
  local cam=workspace.CurrentCamera
  local radius=math.clamp(tonumber(get('Aim/Field of View'))or 100,10,500)
  circle.Visible=not stopped and cam~=nil and get('Main/Enabled')==true and get('Visuals/FOV Circle')==true and not isMenuOpen()
  if cam then circle.Position=UDim2.fromOffset(cam.ViewportSize.X*.5,cam.ViewportSize.Y*.5);circle.Size=UDim2.fromOffset(radius*2,radius*2);stroke.Color=rgba()end
  local why=blocked();if why then if why=='Ragebot priority'then circle.Visible=false end;clear(why);return end
  if not held()then clear('waiting for aim key');return end
  if not cam then clear('no camera');return end
  local candidate=selectTarget(cam,radius)
  if not candidate then clear('no visible target');return end
  if not target or target.owner~=candidate.owner or target.part~=candidate.part then acquired=os.clock()end
  target=candidate
  state.target={name=participants.NameOf(candidate.owner),hitbox=candidate.part.Name,pixels=candidate.pixels,distance=candidate.distance}
  if os.clock()-acquired<(tonumber(get('Selection/Reaction Delay'))or 80)/1000 then state.phase='reaction delay';return end
  if candidate.pixels<=(tonumber(get('Aim/Deadzone'))or 2)then state.phase='inside deadzone';return end
  local delta=candidate.part.Position-cam.CFrame.Position
  if delta.Magnitude<.001 then return end
  local direction=delta.Unit;local look=cam.CFrame.LookVector
  local wantYaw=math.atan2(-direction.X,-direction.Z);local viewYaw=math.atan2(-look.X,-look.Z)
  local wantPitch=math.asin(math.clamp(direction.Y,-1,1));local viewPitch=math.asin(math.clamp(look.Y,-1,1))
  local controller=cameraController._active
  local baseYaw=controller._yawCurrent;local basePitch=controller._pitchCurrent
  if type(baseYaw)~='number'or type(basePitch)~='number'then clear('camera not ready');return end
  local smoothing=tonumber(get('Aim/Smoothing'))or 8
  local yaw=LegitMath.angle(baseYaw,baseYaw+LegitMath.wrap(wantYaw-viewYaw),smoothing,dt)
  local pitch=math.clamp(basePitch+(wantPitch-viewPitch)*LegitMath.alpha(smoothing,dt),math.rad(-89.8),math.rad(89.8))
  controller._yawTarget=yaw;controller._yawCurrent=yaw;controller._pitchTarget=pitch;controller._pitchCurrent=pitch
  state.phase='aiming';state.aimFrames=state.aimFrames+1
 end
 Run:BindToRenderStep('NeverloseLegitAim',Enum.RenderPriority.Camera.Value-1,function(dt)
  if stopped then return end
  local ok,err=pcall(step,dt)
  if not ok then clear('error');state.errors=state.errors+1;state.lastError=tostring(err);if state.errors==1 then warn('[Neverlose for RIVALS Legitbot] '..state.lastError)end end
 end)
 table.insert(cleanups,function()stopped=true;clear('unloaded');Run:UnbindFromRenderStep('NeverloseLegitAim');overlay:Destroy()end)
 return {status=function()local copy=table.clone(state);if state.target then copy.target=table.clone(state.target)end;return copy end}
end

end)()

local installAntiAim = (function()
-- Body-pose anti aim: the player's camera and weapon direction stay independent.
local AntiMath=(function()
 local M={}
 function M.wrap(a) return (a+math.pi)%(2*math.pi)-math.pi end
 function M.pitch(mode)
  if mode=='Down'then return -math.rad(80)elseif mode=='Up'then return math.rad(80)elseif mode=='Forward'then return 0 end
 end
 function M.randomHold(previous,angleRoll,timeRoll,speed)
  local value=angleRoll*2-1
  if previous~=nil then
   -- Exclude nearby angles across the wrap too, including at 180-degree amplitude.
   value=(previous+.35+angleRoll*1.3+1)%2-1
  end
  return value,math.max(.13,1/math.max(speed,.1))*(.8+.6*timeRoll)
 end
 function M.yaw(base,add,mode,amount,speed,time,random)
  local phase=math.floor(time*speed)%2==0 and -1 or 1
  local offset=0
  if mode=='Center' then offset=phase*amount*.5
  elseif mode=='Offset' then offset=phase>0 and amount or 0
  elseif mode=='Random' or mode=='Random Hold' then offset=(random or 0)*amount
  elseif mode=='Spin' then offset=time*speed*math.rad(45) end
  return M.wrap(base+add+offset)
 end
 return M
end)()
return function(getValue,connect,cleanups,isMenuOpen,notify,adapter)
 local RS=game:GetService('ReplicatedStorage')
 local Players=game:GetService('Players')
 local RunService=game:GetService('RunService')
 local UIS=game:GetService('UserInputService')
 local localPlayer=Players.LocalPlayer
 local function module(path)
  if adapter then return adapter.resolve(path) end
  local n=RS.Modules
  for p in path:gmatch('[^/]+') do n=n and n:FindFirstChild(p) end
  if not n then return nil end
  local ok,value=pcall(require,n);return ok and value or nil
 end
 local camera=module('Client/Controllers/CameraController')
 local pov=module('Client/CameraPOV')
 local gun=module('Client/Controllers/GunController')
 local movement=module('Client/QuakeMove')
 local participants=module('Shared/Participant')
 local merc=module('Client/Controllers/MercPlayerController')
 local hostility=module('Shared/Combat/Hostility')
 local state={phase='disabled',errors=0,unsupported={}}
 local stopped=false;local shotUntil=0;local saved=nil;local slow=nil;local lastSlow=nil
 local rng=Random.new();local random=0;local randomTick=-1
 local heldRandom,nextRandomAt,heldSpeed,lastModifier=nil,0,nil,nil
 local function get(path)return getValue('Anti Aim/'..path)end
 local function hideShotsActive()
  local active=adapter and adapter.hideShotsActive()or false
  state.hideShots=active
  return active
 end
 local function view()
  if pov then return pov.GetEyeCFrame() end
  local cam=workspace.CurrentCamera
  return cam and cam.CFrame or CFrame.identity
 end
 local function normalYaw()
  local dir=view().LookVector
  return math.atan2(-dir.X,-dir.Z)
 end
 local function releasePose()
  state.pitch=nil
  nextRandomAt=0
  if not saved then return end
  if saved.humanoid.Parent then saved.humanoid.AutoRotate=saved.autoRotate end
  if saved.root.Parent then saved.root.CFrame=CFrame.new(saved.root.Position)*CFrame.Angles(0,normalYaw(),0) end
  saved=nil
 end
 local function resetSlow()
  if slow~=nil and movement then
   if movement.SpeedMultiplier==lastSlow then movement.SpeedMultiplier=slow end
   slow,lastSlow=nil,nil
  end
 end
 local ladderParams=RaycastParams.new()
 ladderParams.FilterType=Enum.RaycastFilterType.Exclude
 ladderParams.IgnoreWater=true
 ladderParams.RespectCanCollide=true
 local ladderCheckAt,ladderCharacter,ladderRoot,ladderApproach=0,nil,nil,false
 local function usingLadder(char,hum)
  if hum:GetState()==Enum.HumanoidStateType.Climbing then return true end
  local root=char:FindFirstChild('HumanoidRootPart')
  local direction=hum.MoveDirection*Vector3.new(1,0,1)
  if not root or direction.Magnitude<.05 then ladderCheckAt=0;return false end
  local now=os.clock()
  if char==ladderCharacter and root==ladderRoot and now<ladderCheckAt then return ladderApproach end
  ladderCharacter,ladderRoot,ladderCheckAt,ladderApproach=char,root,now+.03,false
  local excluded={char}
  if workspace.CurrentCamera then table.insert(excluded,workspace.CurrentCamera)end
  ladderParams.FilterDescendantsInstances=excluded
  local reach=math.max(root.Size.X,root.Size.Z)*.5+1.5
  local ray=direction.Unit*reach
  for _,height in ipairs({0,1.5,-1.5})do
   local hit=workspace:Raycast(root.Position+Vector3.new(0,height,0),ray,ladderParams)
   if hit and hit.Instance:IsA('TrussPart')then ladderApproach=true;break end
  end
  return ladderApproach
 end
 local function reason()
  local hideShots=hideShotsActive()
  if stopped or get('Main/Enable Anti Aim')~=true then return 'disabled' end
  if not adapter and (isMenuOpen() or UIS:GetFocusedTextBox()) then return 'menu open' end
  local char=(adapter and adapter.character() or localPlayer.Character)
  local hum=char and char:FindFirstChildOfClass('Humanoid')
  if not char or not hum or hum.Health<=0 or localPlayer:GetAttribute('Deployed')==false then return 'not deployed' end
  if get('Movement/Allow Ladder')==true and usingLadder(char,hum)then return 'ladder' end
  if adapter then local why=adapter.poseBlocked();if why then return why end end
  local vehicle=localPlayer:GetAttribute('VehicleId')
  if localPlayer:GetAttribute('Spectating') or type(vehicle)=='string' and vehicle~='' then return 'spectating or vehicle' end
  local preview=adapter and isMenuOpen()
  if not preview and gun then
   if gun:ShouldBlockWeaponInput() or gun.Weapon and gun.Weapon.IsReloading then return 'weapon action' end
   if not hideShots and (gun.FireHeld or gun.AimHeld)then return 'weapon action' end
  end
  if not hideShots and os.clock()<shotUntil then return 'shot or interaction' end
  if not preview and (UIS:IsKeyDown(Enum.KeyCode.E)or not hideShots and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1))then return 'shot or interaction' end
  return nil
 end
 local function targetYaw(root,fallback)
  if not participants or not merc or not hostility then return fallback end
  local best,angle=nil,fallback
  for _,owner in ipairs(participants.All()) do
   if owner~=localPlayer and hostility.IsHostile(localPlayer,owner) then
    local model=merc.GetVisual(owner)
    local head=model and (model:FindFirstChild('Head') or model.PrimaryPart)
    local actorBody=participants.BodyOf(owner)
    local actorHum=actorBody and actorBody:FindFirstChildOfClass('Humanoid') or model and model:FindFirstChildOfClass('Humanoid')
    local hp=adapter and adapter.health(owner) or tonumber(owner:GetAttribute('BotHealth')) or (actorHum and actorHum.Health) or 0
    if head and hp>0 and not model:GetAttribute('Dead') and not model:GetAttribute('Ragdolled') then
     local d=head.Position-root.Position
     if d.Magnitude>.01 and Vector3.new(d.X,0,d.Z).Magnitude>.01 and (not best or d.Magnitude<best) then best=d.Magnitude;angle=math.atan2(-d.X,-d.Z) end
    end
   end
  end
  return angle
 end
 local function apply()
  local why=reason()
  if why then state.phase=why;releasePose();resetSlow();return end
  local char=(adapter and adapter.character() or localPlayer.Character);local hum=char:FindFirstChildOfClass('Humanoid');local root=char:FindFirstChild('HumanoidRootPart')
  if not root then state.phase='missing root';releasePose();return end
  if saved and saved.character~=char then releasePose() end
  if not saved then saved={character=char,root=root,humanoid=hum,autoRotate=hum.AutoRotate} end
  local now=os.clock();local speed=math.max(tonumber(get('Main/Modifier Speed')) or 6,.1)
  local modifier=get('Main/Yaw Modifier')
  if modifier=='Random Hold'then
   if lastModifier~=modifier or speed~=heldSpeed or now>=nextRandomAt then
    local duration
    heldRandom,duration=AntiMath.randomHold(heldRandom,rng:NextNumber(),rng:NextNumber(),speed)
    nextRandomAt=now+duration;heldSpeed=speed
   end
   random=heldRandom
  else
   local tick=math.floor(now*speed)
   if lastModifier~=modifier or tick~=randomTick then randomTick=tick;random=rng:NextNumber(-1,1)end
  end
  lastModifier=modifier
  local yaw=normalYaw();local base=get('Main/Yaw Base')
  if base=='Backward' then yaw=yaw+math.pi elseif base=='Away from Targets' then yaw=targetYaw(root,yaw)+math.pi end
  yaw=AntiMath.yaw(yaw,math.rad(tonumber(get('Main/Yaw Add')) or 0),modifier,math.rad(tonumber(get('Main/Modifier Amount')) or 45),speed,now,random)
  hum.AutoRotate=false
  root.CFrame=CFrame.new(root.Position)*CFrame.Angles(0,yaw,0)
  local slowMode=get('Movement/Slow Walk')
  if movement and slowMode~='Disabled' and not isMenuOpen() then
   if slow==nil then slow=movement.SpeedMultiplier end
   lastSlow=slow*(slowMode=='Slower' and .25 or .45);movement.SpeedMultiplier=lastSlow
  else resetSlow() end
  state.phase=adapter and isMenuOpen() and 'preview' or 'active';state.yaw=math.deg(yaw);state.modifier=modifier
 end
 local function hook(object,name,wrap)
  if type(object)~='table' or type(object[name])~='function' then return false end
  local original=object[name];local replacement=wrap(original);object[name]=replacement
  table.insert(cleanups,function()if object[name]==replacement then object[name]=original end end)
  return true
 end
 local hooked=hook(camera,'_render',function(original)
  return function(self,...)
   -- The camera may read body offsets before writing its own yaw. Give that
   -- calculation the normal facing, then apply the body-only pose afterward.
   if self==camera._active and saved and saved.root.Parent then saved.root.CFrame=CFrame.new(saved.root.Position)*CFrame.Angles(0,normalYaw(),0) end
   local result=table.pack(original(self,...))
   if self==camera._active then
    local ok,err=pcall(apply)
    if not ok then state.errors+=1;state.lastError=tostring(err);releasePose() end
   end
   return table.unpack(result,1,result.n)
  end
 end)
 local function beforeShot()
  shotUntil=os.clock()+.18
  if not hideShotsActive()then releasePose()end
 end
 hook(gun,'FireWeapon',function(original)
  return function(self,...)
   beforeShot()
   return original(self,...)
  end
 end)
 if adapter then table.insert(cleanups,adapter.onBeforeShot(beforeShot))end
 if adapter and adapter.pitchSupported then
  table.insert(cleanups,adapter.setPitchProvider(function()
   local pitch=AntiMath.pitch(get('Main/Pitch'))
   if pitch==nil or reason()or not adapter.canReplicatePitch()then state.pitch=nil;return nil end
   state.pitch=math.deg(pitch)
   return pitch
  end))
 end
 connect(RunService.Heartbeat,function()
  if stopped then return end
  local why=reason()
  if why then state.phase=why;releasePose();resetSlow() end
  if not hooked or not camera._active then local ok,err=pcall(apply);if not ok then state.errors+=1;state.lastError=tostring(err);releasePose() end end
 end)
 table.insert(cleanups,function()stopped=true;releasePose();resetSlow()end)
 return {status=function()local copy=table.clone(state);copy.unsupported=table.clone(state.unsupported);return copy end}
end

end)()

local installMovement = (function()
-- Native Fighter movement controls. No camera/input replacement or persistent game-data edits.
return function(getValue,connect,cleanups,isMenuOpen,adapter)
 local state={supported=false,phase='unavailable',errors=0,extraJumpsUsed=0,extraJumps=0,crouchReports=0,speedMultiplier=1,slideMultiplier=1,fakeCrouch=false}
 local function status()return table.clone(state)end
 if not (adapter and adapter.native)then return {status=status}end
 local Players=game:GetService('Players');local Run=game:GetService('RunService');local UIS=game:GetService('UserInputService')
 local function native(fn)
  local prior=getthreadidentity and getthreadidentity();if setthreadidentity then setthreadidentity(2)end
  local out=table.pack(pcall(fn));if setthreadidentity and prior then setthreadidentity(prior)end
  if not out[1]then error(out[2],0)end;return table.unpack(out,2,out.n)
 end
 local ps=Players.LocalPlayer:FindFirstChild('PlayerScripts')
 local controllers=ps and ps:FindFirstChild('Controllers');local script=controllers and controllers:FindFirstChild('MechanicsController')
 local ok,mc=pcall(function()return script and native(function()return require(script)end)end)
 if not (ok and type(mc)=='table'and type(mc._GetWalkSpeed)=='function'and type(mc.DoubleJumpRequest)=='function'and type(mc.DoubleJump)=='function'and type(mc._UpdateServerState)=='function')then return {status=status}end
 state.supported=true;state.phase='disabled'
 local stopped=false;local hooks={};local boundEntity;local jumpsUsed=0;local nextJumpAt=0;local crouchOwner;local boostedSlide
 local lastSpeed,lastEntity=1,nil
 local reporter=mc._UpdateServerState
 local function get(path)return getValue('Main/'..path)end
 local function factor(toggle,amount,maximum)
  if get(toggle)~=true then return 1 end
  local value=tonumber(get(amount))or 100
  if value~=value then value=100 end
  return math.clamp(value/100,1,maximum)
 end
 local function eligible()
  if stopped or isMenuOpen()or UIS:GetFocusedTextBox()then return end
  local f=adapter.nativeFighter();local e=f and f.Entity;local hum=e and e.Humanoid
  if not (f and mc.LocalFighter==f and e and hum and hum.Parent and f:IsAlive()and f:IsActive())then return end
  if mc:IsFrozen()or mc:AreInputsDisabled()or hum.Sit then return end
  if hum:GetState()==Enum.HumanoidStateType.Climbing then return end
  return f,e
 end
 local function hook(name,wrap)
  local had=rawget(mc,name);local original=mc[name];local replacement=wrap(original)
  mc[name]=replacement
  table.insert(hooks,function()if mc[name]==replacement then mc[name]=had end end)
 end
 local function resetFlight(e)
  if e~=boundEntity then boundEntity=e;jumpsUsed=0;nextJumpAt=0 end
  state.extraJumpsUsed=jumpsUsed
 end
 local function wantsCrouch()
  if get('Posture/Fake Crouch')~=true or mc.IsSliding then return end
  return eligible()
 end
 local function ownCrouch(f,e)
  crouchOwner={fighter=f,entity=e};state.fakeCrouch=true
 end
 local function releaseCrouch()
  local owned=crouchOwner
  if owned and mc.LocalFighter==owned.fighter and owned.fighter.Entity==owned.entity then
   reporter(mc,'IsCrouching',mc.IsCrouching==true)
   state.crouchReports=state.crouchReports+1
  end
  crouchOwner=nil;state.fakeCrouch=false
 end
 hook('_UpdateServerState',function(original)return function(self,key,...)
  if self==mc and key=='IsCrouching'then
   local f,e=wantsCrouch()
   if f then ownCrouch(f,e);state.crouchReports=state.crouchReports+1;return original(self,key,true)end
  end
  return original(self,key,...)
 end end)
 hook('_GetWalkSpeed',function(original)return function(self,forSlide,...)
  local value=original(self,forSlide,...)
  if self~=mc or not eligible()then return value end
  -- Slide uses its own tested multiplier, rather than stacking it with walking speed.
  local multiplier
  if self.IsSliding and forSlide then
   multiplier=factor('Movement/Fast Slide','Movement/Slide Speed',1.25)
   if multiplier>1 then boostedSlide={entity=mc.LocalFighter.Entity,factor=multiplier}end
  else multiplier=factor('Movement/Speed Boost','Movement/Walk Speed',2)end
  return value*multiplier
 end end)
 hook('DoubleJumpRequest',function(original)return function(self,...)
  if self~=mc or get('Air Movement/Extra Air Jumps')~=true then return original(self,...)end
  local f,e=eligible()
  if not f or mc.IsSliding or f:Get('DisableDoubleJumping')then return original(self,...)end
  resetFlight(e)
  if f:IsGrounded()then jumpsUsed=0;state.extraJumpsUsed=0;return original(self,...)end
  local w=f.EquippedItem;local id=w and w:Get('ObjectID')
  local used=id and (mc._double_jumps_used[id]or 0)or 0
  local out=table.pack(original(self,...))
  -- Consume the game's own allowance first. The separate budget follows the entire flight,
  -- so swapping weapons or toggling the setting cannot refill the additional jumps.
  if not id or (mc._double_jumps_used[id]or 0)>used then return table.unpack(out,1,out.n)end
  local limit=tonumber(get('Air Movement/Additional Jumps'))or 2
  if limit~=limit then limit=2 end
  limit=math.clamp(math.floor(limit),1,5)
  if jumpsUsed<limit and os.clock()>=nextJumpAt then
   self:DoubleJump();jumpsUsed=jumpsUsed+1;nextJumpAt=os.clock()+.1
   state.extraJumpsUsed=jumpsUsed;state.extraJumps=state.extraJumps+1
  end
  return table.unpack(out,1,out.n)
 end end)
 local function update()
  local current=adapter.nativeFighter();local e=current and current.Entity
  resetFlight(e)
  if current and e and current:IsGrounded()then jumpsUsed=0;state.extraJumpsUsed=0 end
  local f=eligible()
  local walk=f and factor('Movement/Speed Boost','Movement/Walk Speed',2)or 1
  state.speedMultiplier=walk
  state.slideMultiplier=f and factor('Movement/Fast Slide','Movement/Slide Speed',1.25)or 1
  if boostedSlide then
   if boostedSlide.entity~=e or not mc.IsSliding then boostedSlide=nil
   elseif state.slideMultiplier~=boostedSlide.factor then mc:StopSliding();boostedSlide=nil end
  end
  if walk~=lastSpeed or e~=lastEntity then
   mc:_UpdateWalkSpeed();lastSpeed,lastEntity=walk,e
  end
  local crouchF,crouchE=wantsCrouch()
  if crouchF then
   if not crouchOwner or crouchOwner.fighter~=crouchF or crouchOwner.entity~=crouchE then
    reporter(mc,'IsCrouching',true);ownCrouch(crouchF,crouchE);state.crouchReports=state.crouchReports+1
   end
  elseif crouchOwner then releaseCrouch()end
  local requested=get('Movement/Speed Boost')==true or get('Movement/Fast Slide')==true or get('Air Movement/Extra Air Jumps')==true or get('Posture/Fake Crouch')==true
  state.phase=not requested and 'disabled'or f and 'active'or isMenuOpen()and 'menu open'or 'waiting for character'
 end
 connect(Run.Heartbeat,function()
  if stopped then return end
  local good,err=pcall(function()native(update)end)
  if not good then state.errors=state.errors+1;state.lastError=tostring(err);if state.errors==1 then warn('[Neverlose for RIVALS movement] '..tostring(err))end end
 end)
 table.insert(cleanups,function()
  stopped=true
  for i=#hooks,1,-1 do hooks[i]()end
  local good,err=pcall(function()native(function()
   if boostedSlide and mc.LocalFighter and mc.LocalFighter.Entity==boostedSlide.entity then mc:StopSliding()end
   boostedSlide=nil;releaseCrouch();mc:_UpdateWalkSpeed()
  end)end)
  state.phase='unloaded';state.speedMultiplier=1;state.slideMultiplier=1
  if not good then state.errors=state.errors+1;state.lastError=tostring(err)end
 end)
 return {status=status}
end

end)()

local installAutoVote = (function()
-- Prefer one native map option. Never vote during weapon voting or map banning.
return function(getValue,connect,cleanups,adapter)
 local state={supported=adapter and adapter.mapVoteSupported==true or false,phase='disabled',requests=0,errors=0}
 local function status()return table.clone(state)end
 if not state.supported then state.phase='unavailable';return {status=status}end
 local stopped=false;local nextCheck=0;local ballots=setmetatable({},{__mode='k'})
 local function step()
  if getValue('Main/Automation/Auto Vote')~=true then state.phase='disabled';return end
  local selected=getValue('Main/Automation/Preferred Map')
  state.map=selected
  if type(selected)~='string'or selected==''or selected=='Select a map'then state.phase='choose a map';return end
  local vote=adapter.mapVoteSnapshot()
  if not vote then state.phase='waiting for duel';return end
  if not(vote.open and vote.kind=='Maps'and type(vote.options)=='table')then ballots[vote.duel]=nil;state.phase='waiting for map vote';return end
  if tostring(vote.mode):lower():find('ban',1,true)then state.phase='map banning phase';return end
  local names={};local choice
  for _,option in pairs(vote.options)do
   table.insert(names,option.Name)
   if option.Name==selected then choice=option end
  end
  table.sort(names);local key=tostring(vote.mode)..'/'..table.concat(names,'\0')
  local ballot=ballots[vote.duel]
  if not ballot or ballot.key~=key then ballot={key=key,sent={}};ballots[vote.duel]=ballot end
  if not choice then state.phase='preferred map unavailable';return end
  if choice.IsBanned then state.phase='map banned';return end
  if vote.lastVote==selected then state.phase='voted';ballot.sent[selected]={confirmed=true};return end
  local sent=ballot.sent[selected]
  if sent and sent.confirmed then state.phase='vote completed';return end
  if sent and (sent.attempts>=2 or os.clock()-sent.at<1.5)then state.phase='waiting for vote confirmation';return end
  local accepted,reason=adapter.voteMap(selected)
  if accepted then
   ballot.sent[selected]={attempts=(sent and sent.attempts or 0)+1,at=os.clock(),confirmed=reason=='already voted'}
   if reason=='requested'then state.requests=state.requests+1 end
   state.phase=reason=='already voted'and 'voted'or 'vote requested'
  else state.phase=reason or 'vote unavailable' end
 end
 connect(game:GetService('RunService').Heartbeat,function()
  if stopped or os.clock()<nextCheck then return end
  nextCheck=os.clock()+.25
  local ok,err=pcall(step)
  if not ok then state.errors=state.errors+1;state.phase='error';state.lastError=tostring(err);if state.errors==1 then warn('[Neverlose for RIVALS Auto Vote] '..tostring(err))end end
 end)
 table.insert(cleanups,function()stopped=true;state.phase='unloaded';table.clear(ballots)end)
 return {status=status}
end

end)()

local installAutoExecute = (function()
-- Requeue once per server; wait for the game's own loader without requiring its modules.
local QUEUE_VERSION=3
local BOOTSTRAP=[=[
task.spawn(function()
 local env=getgenv()
 local Startup=(function()
__STARTUP_SOURCE__
 end)()
 if game.GameId~=0 and game.GameId~=Startup.universeId then return end
 local job=game.JobId or 'local'
 local function hasMenu()
  local m=env.NeverloseMenu
  if not m then return false end
  if m._jobId and m._jobId~=job then return false end
  if type(m.isAlive)=='function'then local ok,alive=pcall(m.isAlive);return ok and alive==true end
  return true
 end
 if hasMenu()then return end
 local root='neverlose_ui';local http=game:GetService('HttpService')
 local function state()
  local ok,value=pcall(function()return http:JSONDecode(readfile(root..'/autoexecute.json'))end)
  return ok and type(value)=='table'and value or nil
 end
 local settings=state()
 if not(settings and settings.enabled and settings.universeId==Startup.universeId)then return end
 local deadline=os.clock()+180
 while type(env.NeverloseAutoExecuteStarting)=='table'and env.NeverloseAutoExecuteStarting.job==job and (env.NeverloseAutoExecuteStarting.expires or 0)>os.clock()do
  settings=state()
  if hasMenu()or not(settings and settings.enabled)then return end
  if os.clock()>=deadline then warn('[Neverlose for RIVALS Auto Execute] Another startup did not finish');return end
  task.wait(.25)
 end
 if hasMenu()then return end
 local owner={job=job,expires=deadline}
 env.NeverloseAutoExecuteStarting=owner
 -- The queue that brought us here has been consumed. The new menu must queue the next hop.
 env.NeverloseAutoExecuteQueued=nil;env.NeverloseAutoExecuteQueueVersion=nil
 env.NeverloseAutoExecuteBootStatus={phase='waiting for native loading screen'}
 local ok,err=xpcall(function()
  for attempt=1,3 do
   local ready,why=Startup.wait(math.max(0,deadline-os.clock()),function()
    settings=state()
    return hasMenu()or not(settings and settings.enabled and settings.universeId==Startup.universeId)
   end)
   if not ready then
    if why=='cancelled'or why=='wrong game'then return end
    error(why,0)
   end
   settings=state()
   if hasMenu()or not(settings and settings.enabled)then return end
   local source=readfile(root..'/autoexecute.lua')
   local chunk,problem=loadstring(source,'Neverlose for RIVALS / Auto Execute');assert(chunk,problem)
   env.NeverloseMenuSource=source;env.NeverloseTeleportValues=settings.values
   env.NeverloseAutoExecuteBootStatus.phase='starting menu'
   local started,result=pcall(chunk)
   if started and hasMenu()then return end
   local message=tostring(result or 'Menu startup did not finish')
   local transient=message:find('runtime is not ready',1,true)or message:find('not a valid member',1,true)or message:find('attempt to index nil',1,true)
   if not transient or attempt==3 or os.clock()>=deadline then error(message,0)end
  end
 end,debug.traceback)
 if env.NeverloseAutoExecuteStarting==owner then env.NeverloseAutoExecuteStarting=nil end
 env.NeverloseAutoExecuteBootStatus={phase=hasMenu()and 'ready'or ok and 'cancelled'or 'error',error=not ok and tostring(err)or nil}
 if not ok then warn('[Neverlose for RIVALS Auto Execute] '..tostring(err))end
end)
]=]
return function(api,connect,cleanups,env,root,startupSource)
 local player=game:GetService('Players').LocalPlayer
 local http=game:GetService('HttpService')
 local path='Settings/Menu/Auto Execute'
 local queue=queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)or (fluxus and fluxus.queue_on_teleport)
 local stopped=false;local revision=0;local cachedSource
 local status={supported=type(queue)=='function',enabled=false,queued=env.NeverloseAutoExecuteQueued==true,errors=0}
 local function persist(enabled)
  writefile(root..'/autoexecute.json',http:JSONEncode({version=2,enabled=enabled,universeId=6035872082,values=api.snapshot()}))
 end
 local function prepare()
  if stopped then return false end
  status.enabled=api.get(path)==true
  local ok,err=pcall(function()
   if status.enabled then
    assert(game.GameId==6035872082,'Auto Execute only supports RIVALS')
    assert(status.supported,'This executor does not support queue_on_teleport')
    assert(type(startupSource)=='string','Startup guard source is missing; run the current loader')
    if type(env.NeverloseMenuSource)=='string'and env.NeverloseMenuSource~=cachedSource then
     writefile(root..'/autoexecute.lua',env.NeverloseMenuSource);cachedSource=env.NeverloseMenuSource
    end
    assert(isfile(root..'/autoexecute.lua'),'Run neverlose_loader.lua once to cache the current script')
   end
   persist(status.enabled)
   if status.enabled and (not env.NeverloseAutoExecuteQueued or env.NeverloseAutoExecuteQueueVersion~=QUEUE_VERSION)then
    local bootstrap=BOOTSTRAP:gsub('__STARTUP_SOURCE__',function()return startupSource end)
    assert(queue(bootstrap)~=false,'The executor rejected the teleport queue request')
    env.NeverloseAutoExecuteQueued=true;env.NeverloseAutoExecuteQueueVersion=QUEUE_VERSION
   end
   status.queued=env.NeverloseAutoExecuteQueued==true
  end)
  if not ok then
   status.errors=status.errors+1;status.lastError=tostring(err);status.enabled=false
   pcall(persist,false)
   if api.get(path)==true then api.set(path,false)end
   api.notify('Auto Execute',tostring(err))
  end
  return ok
 end
 local changed=api.onAnyChanged(function(changedPath)
  if stopped then return end
  revision=revision+1
  if changedPath==path then prepare()
  elseif api.get(path)==true then
   local pending=revision
   task.delay(.2,function()if not stopped and pending==revision then prepare()end end)
  end
 end)
 connect(player.OnTeleport,function(event)
  if event==Enum.TeleportState.Started or event==Enum.TeleportState.InProgress then prepare()
  elseif event==Enum.TeleportState.Failed then
   -- A failed teleport does not consume the executor's queued script.
   prepare()
  end
 end)
 table.insert(cleanups,function()
  stopped=true;revision=revision+1;changed:Disconnect();status.enabled=false
  pcall(persist,false)
 end)
 prepare()
 return {status=function()return table.clone(status)end}
end

end)()

local function main()
	if setthreadidentity then setthreadidentity(8) end
	loadIcons()

	local env = getgenv and getgenv() or {}
	local reloadValues = env.NeverloseTeleportValues
	if env.NeverloseMenu and env.NeverloseMenu.snapshot then
		local ok,values=pcall(env.NeverloseMenu.snapshot)
		if ok then reloadValues=values end
	end
	-- Keep the exact snapshot available if startup fails before the API is installed.
	env.NeverloseTeleportValues = reloadValues
	if env.NeverloseMenu and env.NeverloseMenu.unload then
		pcall(env.NeverloseMenu.unload)
	end
	local guiParent = (gethui and gethui()) or cloneref(game:GetService("CoreGui"))
	local previous = guiParent:FindFirstChild("NeverloseMenu")
	if previous then
		previous:Destroy()
	end
	if env.NeverloseMenuConnections then
		for _, c in ipairs(env.NeverloseMenuConnections) do
			pcall(function()
				c:Disconnect()
			end)
		end
	end
	if env.NeverloseMenuCleanups then
		for i=#env.NeverloseMenuCleanups,1,-1 do
			if setthreadidentity then setthreadidentity(8) end
			pcall(env.NeverloseMenuCleanups[i])
		end
	end
	local connections = {}
	local cleanups = {}
	env.NeverloseMenuCleanups = cleanups
	env.NeverloseMenuConnections = connections
	local function connect(signal, fn)
		local c = signal:Connect(fn)
		table.insert(connections, c)
		return c
	end

	local api = {}
	local selectPage -- assigned in the navigation section
	local notify -- assigned in the notifications section
	local currentPage
	local dpiScale = 1

	---------------------------------------------------------------------------------------
	-- Value store: every control reads/writes here, keyed by "Page/Group/Label".
	-- Pages with tabs (Players) or a weapon picker (Ragebot) keep one set per tab.
	---------------------------------------------------------------------------------------
	local Store = {
		values = {},
		defaults = {},
		kinds = {},
		controls = {},
		listeners = {},
		any = {},
		contexts = {},
		pageOf = {},
		rerender = {},
		index = {},
		binds = {},
		held = {},
		captureUntil = 0,
	}

	local function storeKey(path)
		local ctx = Store.contexts[Store.pageOf[path] or ""]
		return ctx and (path .. "@" .. ctx) or path
	end
	local function getValue(path, context)
		local v = Store.values[context and (path .. "@" .. context) or storeKey(path)]
		if v == nil and Store.pageOf[path] == "skins" then v = Store.values[path] end
		if v == nil and Store.pageOf[path] == "ragebot" then v = Store.values[path .. "@Global"] end
		if v == nil then
			v = Store.defaults[path]
		end
		return copyValue(v)
	end
	local function fire(path, value)
		for _, fn in ipairs(Store.listeners[path] or {}) do
			task.spawn(fn, copyValue(value))
		end
		for _, fn in ipairs(Store.any) do
			task.spawn(fn, path, copyValue(value))
		end
	end
	local function setValue(path, value)
		Store.values[storeKey(path)] = copyValue(value)
		for _, apply in ipairs(Store.controls[path] or {}) do
			apply(copyValue(value))
		end
		fire(path, value)
	end
	local function declare(path, kind, default, pageKey)
		if Store.defaults[path] == nil then
			Store.defaults[path] = copyValue(default)
			Store.kinds[path] = kind
			Store.pageOf[path] = pageKey
		end
	end
	local function register(path, apply)
		Store.controls[path] = Store.controls[path] or {}
		table.insert(Store.controls[path], apply)
		apply(getValue(path))
		return function()
			local list = Store.controls[path]
			for i, f in ipairs(list) do
				if f == apply then
					table.remove(list, i)
					break
				end
			end
		end
	end
	local function onChanged(path, fn)
		Store.listeners[path] = Store.listeners[path] or {}
		table.insert(Store.listeners[path], fn)
		return {
			Disconnect = function()
				local list = Store.listeners[path]
				for i, f in ipairs(list) do
					if f == fn then
						table.remove(list, i)
						break
					end
				end
			end,
		}
	end
	local function refreshPaths(filter)
		for path in pairs(Store.defaults) do
			if not filter or filter(path) then
				local v = getValue(path)
				for _, apply in ipairs(Store.controls[path] or {}) do
					apply(copyValue(v))
				end
				fire(path, v)
			end
		end
	end
	local function setContext(pageKey, ctx)
		Store.contexts[pageKey] = ctx
		refreshPaths(function(p)
			return Store.pageOf[p] == pageKey
		end)
	end
	Store.contexts.ragebot = "Global"
	Store.contexts.players = "Enemies"

	---------------------------------------------------------------------------------------
	-- Window
	---------------------------------------------------------------------------------------
	local gui = create("ScreenGui", {
		Name = "NeverloseMenu",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 1000,
	})
	table.insert(cleanups, function() gui:Destroy() end)
	pcall(function()
		if protectgui then
			protectgui(gui)
		end
	end)

	local menuBasePosition = UDim2.fromScale(0.5, 0.5)
	local holder = frame({
		Name = "Holder",
		Visible = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = menuBasePosition,
		Size = UDim2.fromOffset(WIN_W, WIN_H),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	local holderScale = create("UIScale", { Scale = 1, Parent = holder })
	local menuMotion = create("NumberValue", { Value = 0 })
	local menuOpen = false
	local gameAdapter = installGameAdapter(connect, cleanups, getValue, function() return menuOpen end)
	local function applyMenuMotion()
		local offset = math.floor((1 - menuMotion.Value) * 8 + 0.5)
		holder.Position = UDim2.new(menuBasePosition.X.Scale, menuBasePosition.X.Offset, menuBasePosition.Y.Scale, menuBasePosition.Y.Offset + offset)
	end
	connect(menuMotion.Changed, applyMenuMotion)
	applyMenuMotion()

	local window = create("CanvasGroup", {
		Name = "Window",
		GroupTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Active = true,
		Parent = holder,
	})

	-- frees the mouse in first-person games while the menu is open
	local mouseUnlock = create("TextButton", {
		Name = "MouseUnlock",
		Modal = true,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.fromOffset(0, 0),
		Parent = window,
	})

	-- The sidebar is an acrylic panel: the game behind it is blurred (see the blur section
	-- further down) and covered by a navy tint that lets ~12% of it through. The content
	-- side is solid. Measured from footage where bright objects passed behind the menu.
	frame({
		Name = "SidebarTint",
		Size = UDim2.fromOffset(SIDEBAR_W + 10, WIN_H),
		BackgroundColor3 = Theme.SidebarTint,
		BackgroundTransparency = Theme.SidebarSeeThrough,
		Parent = window,
	}, { corner(WIN_RADIUS) })
	frame({
		Name = "ContentBackground",
		Position = UDim2.fromOffset(SIDEBAR_W, 0),
		Size = UDim2.fromOffset(CONTENT_W, WIN_H),
		BackgroundColor3 = Theme.Content,
		Parent = window,
	}, { corner(WIN_RADIUS) })
	frame({
		Name = "ContentSquareEdge",
		Position = UDim2.fromOffset(SIDEBAR_W, 0),
		Size = UDim2.fromOffset(WIN_RADIUS + 2, WIN_H),
		BackgroundColor3 = Theme.Content,
		Parent = window,
	})
	local sidebar = frame({
		Name = "Sidebar",
		Size = UDim2.fromOffset(SIDEBAR_W, WIN_H),
		BackgroundTransparency = 1,
		Parent = window,
	})
	frame({
		Name = "Edge",
		Position = UDim2.fromOffset(SIDEBAR_W - 1, 0),
		Size = UDim2.fromOffset(1, WIN_H),
		BackgroundColor3 = Theme.SidebarEdge,
		Parent = window,
	})

	local logoArea = frame({
		Name = "LogoArea",
		Size = UDim2.fromOffset(SIDEBAR_W, 60),
		BackgroundTransparency = 1,
		Parent = sidebar,
	})
	-- blue halo: a dark-blue stroked copy behind, plus a teal copy nudged left for the edge fringe
	local glow = text({
		Name = "LogoGlow",
		Text = "NEVERLOSE",
		FontFace = Fonts.Logo,
		TextSize = 30,
		TextColor3 = rgb(0, 40, 78),
		Position = UDim2.fromOffset(15, 19),
		Size = UDim2.fromOffset(170, 30),
		Parent = logoArea,
	})
	create("UIStroke", {
		Color = rgb(0, 30, 62),
		Thickness = 2.2,
		Transparency = 0.15,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
		LineJoinMode = Enum.LineJoinMode.Round,
		Parent = glow,
	})
	text({
		Name = "LogoFringe",
		Text = "NEVERLOSE",
		FontFace = Fonts.Logo,
		TextSize = 30,
		TextColor3 = rgb(52, 140, 184),
		TextTransparency = 0.1,
		Position = UDim2.fromOffset(14, 19),
		Size = UDim2.fromOffset(170, 30),
		Parent = logoArea,
	})
	text({
		Name = "Logo",
		Text = "NEVERLOSE",
		FontFace = Fonts.Logo,
		TextSize = 30,
		TextColor3 = Theme.Logo,
		Position = UDim2.fromOffset(15, 19),
		Size = UDim2.fromOffset(170, 30),
		Parent = logoArea,
	})

	local NAV = {
		{ "Aimbot", { { "Ragebot", "ragebot" }, { "Legitbot", "legitbot" }, { "Anti Aim", "antiaim" } } },
		{ "Visuals", { { "Players", "players" }, { "World", "world" } } },
		{ "Miscellaneous", { { "Main", "main" }, { "Scripts", "scripts" }, { "Configs", "configs" } } },
	}

	if gameAdapter then table.insert(NAV[2][2], {"Skin Changer", "skins"}) end
	if gameAdapter then table.insert(NAV[2][2], {"Model Changer", "models"}) end
	local navHighlight = frame({
		Name = "Active",
		Position = UDim2.fromOffset(9, 0),
		Size = UDim2.fromOffset(172, 30),
		BackgroundColor3 = Theme.NavActive,
		Parent = sidebar,
	}, { corner(5) })
	table.insert(Store.rerender, function()
		navHighlight.BackgroundColor3 = Theme.NavActive
	end)

	-- measured: first item box at y=90, items every 35px, 69px from a section's last item
	-- to the next section's first; section headers sit 20px above their first item
	local navButtons = {}
	local y = 90
	for _, section in ipairs(NAV) do
		text({
			Name = section[1],
			Text = section[1],
			FontFace = Fonts.SemiBold,
			TextSize = 13,
			TextColor3 = Theme.NavHeader,
			Position = UDim2.fromOffset(20, y - 20),
			Size = UDim2.fromOffset(160, 16),
			Parent = sidebar,
		})
		for _, item in ipairs(section[2]) do
			local name, key = item[1], item[2]
			local btn = hitbox({
				Name = name,
				Position = UDim2.fromOffset(9, y),
				Size = UDim2.fromOffset(172, 30),
				Parent = sidebar,
			})
			local ico = icon(key == "skins" and "players" or key, 14, Theme.NavIcon, {
				Position = UDim2.fromOffset(13, 7),
				Parent = btn,
			})
			local lbl = text({
				Text = name,
				FontFace = Fonts.SemiBold,
				TextSize = 15,
				TextColor3 = Theme.NavText,
				Position = UDim2.fromOffset(41, 0),
				Size = UDim2.fromOffset(130, 30),
				Parent = btn,
			})
			navButtons[key] = { button = btn, icon = ico, label = lbl, y = btn.Position.Y.Offset, title = name }
			y += 35
		end
		y += 69 - 35
	end

	-- profile
	create("ImageLabel", {
		Name = "Avatar",
		Position = UDim2.fromOffset(14, 640),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = rgb(18, 30, 46),
		BorderSizePixel = 0,
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
		Parent = sidebar,
	}, { corner(UDim.new(1, 0)) })
	text({
		Name = "Username",
		Text = LocalPlayer.Name,
		FontFace = Fonts.SemiBold,
		TextSize = 15,
		TextColor3 = Theme.Name,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(58, 649),
		Size = UDim2.fromOffset(124, 17),
		Parent = sidebar,
	})

	---------------------------------------------------------------------------------------
	-- Content + header
	---------------------------------------------------------------------------------------
	local content = frame({
		Name = "Content",
		Position = UDim2.fromOffset(SIDEBAR_W, 0),
		Size = UDim2.fromOffset(CONTENT_W, WIN_H),
		BackgroundTransparency = 1,
		Parent = window,
	})
	local header = frame({
		Name = "Header",
		Size = UDim2.fromOffset(CONTENT_W, HEADER_H),
		BackgroundTransparency = 1,
		Parent = content,
	})
	frame({
		Name = "HeaderLine",
		Position = UDim2.fromOffset(0, HEADER_H),
		Size = UDim2.fromOffset(CONTENT_W, 2),
		BackgroundColor3 = Theme.Line,
		Parent = content,
	})

	local function field(props)
		local f = frame({
			Name = props.Name or "Field",
			Position = props.Position,
			Size = props.Size,
			AnchorPoint = props.AnchorPoint,
			BackgroundColor3 = Theme.Field,
			Parent = props.Parent,
		})
		corner(props.Radius or 3).Parent = f
		local s = stroke(Theme.FieldStroke, 1)
		s.Parent = f
		return f, s
	end

	-- HUD (watermark, keybind list) and notifications sit outside the window so they stay
	-- visible while the menu is closed. Popups go on top of everything.
	local hud = frame({ Name = "HUD", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = gui })
	local toastHolder = frame({
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(300, 500),
		BackgroundTransparency = 1,
		Parent = gui,
	}, {
		create("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local popupLayer = frame({
		Name = "Popups",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 50,
		Parent = gui,
	})

	---------------------------------------------------------------------------------------
	-- Popups (dropdown lists, colour pickers, panels). Kept as a stack so a dropdown
	-- inside a panel can open its own list without closing the panel.
	---------------------------------------------------------------------------------------
	-- AbsolutePosition leaves out the top bar inset while the mouse location includes it,
	-- so everything is converted into the popup layer's own space.
	local function mouseAbs()
		return UserInputService:GetMouseLocation() + popupLayer.AbsolutePosition
	end
	local function toLayer(pos)
		return pos - popupLayer.AbsolutePosition
	end
	local function isInside(obj, pos)
		local ap, as = obj.AbsolutePosition, obj.AbsoluteSize
		return pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
	end

	local popupStack = {}
	local function levelOf(obj)
		for i = #popupStack, 1, -1 do
			if obj:IsDescendantOf(popupStack[i].frame) then
				return i
			end
		end
		return 0
	end
	local function closePopupsAbove(level)
		for i = #popupStack, level + 1, -1 do
			local p = table.remove(popupStack, i)
			pcall(p.close)
		end
	end
	local function closePopup()
		closePopupsAbove(0)
	end
	local function pushPopup(popupFrame, owner, close)
		create("UIScale", { Scale = dpiScale, Parent = popupFrame })
		table.insert(popupStack, { frame = popupFrame, owner = owner, close = close })
	end
	local function topOwner()
		local p = popupStack[#popupStack]
		return p and p.owner
	end
	connect(UserInputService.InputBegan, function(input)
		if #popupStack == 0 then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local pos = mouseAbs()
			for i = #popupStack, 1, -1 do
				local p = popupStack[i]
				if isInside(p.frame, pos) or (p.owner and p.owner.Parent and isInside(p.owner, pos)) then
					closePopupsAbove(i)
					return
				end
			end
			closePopup()
		elseif input.KeyCode == Enum.KeyCode.Escape then
			closePopupsAbove(#popupStack - 1)
		end
	end)

	-- places a popup of the given (unscaled) size under `owner`, flipping above it near the bottom
	local function popupPosition(owner, w, h, alignRight)
		local ap, os_ = toLayer(owner.AbsolutePosition), owner.AbsoluteSize
		local screen = popupLayer.AbsoluteSize
		local sw, sh = w * dpiScale, h * dpiScale
		local x = alignRight and (ap.X + os_.X - sw) or ap.X
		local yy = ap.Y + os_.Y + 3
		if yy + sh > screen.Y - 8 then
			yy = ap.Y - sh - 3
		end
		x = math.clamp(x, 8, math.max(8, screen.X - sw - 8))
		return UDim2.fromOffset(x, yy)
	end

	---------------------------------------------------------------------------------------
	-- Controls. Each returns its root plus an `apply(value)` that updates the visuals
	-- without reporting back; user input calls `onUser(newValue)`.
	---------------------------------------------------------------------------------------
	local Controls = {}

	function Controls.switch(parent, onUser)
		local root = hitbox({
			Name = "Switch",
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromOffset(26, 14),
			Parent = parent,
		})
		local track = frame({
			Name = "Track",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(26, 13),
			BackgroundColor3 = Theme.TrackOff,
			Parent = root,
		}, { corner(UDim.new(1, 0)) })
		local trackStroke = stroke(Theme.FieldStroke, 1)
		trackStroke.Parent = track
		local knob = frame({
			Name = "Knob",
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = Theme.KnobOff,
			Parent = root,
		}, { corner(UDim.new(1, 0)) })

		local state, initialised = false, false
		local function render(animate)
			local knobProps = {
				Position = UDim2.fromOffset(state and 12 or 0, 0),
				BackgroundColor3 = state and Theme.KnobOn or Theme.KnobOff,
			}
			local trackProps = { BackgroundColor3 = state and Theme.TrackOn or Theme.TrackOff }
			local strokeProps = { Color = state and Theme.TrackOnStroke or Theme.FieldStroke }
			if animate then
				tween(knob, 0.16, knobProps)
				tween(track, 0.16, trackProps)
				tween(trackStroke, 0.16, strokeProps)
			else
				knob.Position = knobProps.Position
				knob.BackgroundColor3 = knobProps.BackgroundColor3
				track.BackgroundColor3 = trackProps.BackgroundColor3
				trackStroke.Color = strokeProps.Color
			end
		end
		local function apply(v)
			local changed = (v == true) ~= state
			state = v == true
			render(initialised and changed)
			initialised = true
		end
		local function toggle()
			state = not state
			render(true)
			onUser(state)
		end
		connect(root.MouseButton1Click, toggle)
		table.insert(Store.rerender, function()
			render(false)
		end)
		return root, apply, toggle
	end

	function Controls.slider(parent, opts, onUser)
		local min, max = opts.min, opts.max
		local step = opts.step or 1
		local value = opts.default
		local trackW = 92
		local root = frame({
			Name = "Slider",
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromOffset(trackW + 40, 16),
			BackgroundTransparency = 1,
			Parent = parent,
		})
		local valueLabel = text({
			Name = "Value",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromOffset(34, 16),
			FontFace = Fonts.SemiBold,
			TextSize = 12,
			TextColor3 = Theme.Value,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = root,
		})
		local hit = hitbox({ Name = "Hit", Size = UDim2.fromOffset(trackW, 16), Parent = root })
		local track = frame({
			Name = "Track",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(trackW, 3),
			BackgroundColor3 = Theme.SliderTrack,
			Parent = hit,
		}, { corner(UDim.new(1, 0)) })
		local fill = frame({
			Name = "Fill",
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Theme.SliderFill,
			Parent = track,
		}, { corner(UDim.new(1, 0)) })
		local knob = frame({
			Name = "Knob",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = Theme.SliderKnob,
			Parent = track,
		}, { corner(UDim.new(1, 0)) })

		local function format(v)
			if opts.format then
				return opts.format(v)
			end
			local s = (step < 1) and string.format("%.1f", v) or tostring(math.floor(v + 0.5))
			return s .. (opts.suffix or "")
		end
		local function render()
			local a = (value - min) / (max - min)
			fill.Size = UDim2.fromScale(a, 1)
			knob.Position = UDim2.fromScale(a, 0.5)
			valueLabel.Text = format(value)
		end
		local function apply(v)
			value = math.clamp(tonumber(v) or opts.default, min, max)
			render()
		end
		table.insert(Store.rerender, function()
			fill.BackgroundColor3 = Theme.SliderFill
			knob.BackgroundColor3 = Theme.SliderKnob
		end)

		local dragging = false
		local function updateFromMouse()
			local mx = mouseAbs().X
			local a = math.clamp((mx - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			local v = min + (max - min) * a
			v = math.floor(v / step + 0.5) * step
			v = math.clamp(v, min, max)
			if v ~= value then
				value = v
				render()
				onUser(value)
			end
		end
		connect(hit.MouseButton1Down, function()
			dragging = true
			updateFromMouse()
			tween(knob, 0.12, { Size = UDim2.fromOffset(14, 14) })
		end)
		connect(UserInputService.InputChanged, function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				updateFromMouse()
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
				tween(knob, 0.12, { Size = UDim2.fromOffset(12, 12) })
			end
		end)
		-- scroll wheel nudges the value while hovering
		connect(hit.MouseWheelForward, function()
			value = math.clamp(value + step, min, max)
			render()
			onUser(value)
		end)
		connect(hit.MouseWheelBackward, function()
			value = math.clamp(value - step, min, max)
			render()
			onUser(value)
		end)
		return root, apply
	end

	local function openList(owner, options, isSelected, pick, multi, width)
		closePopupsAbove(levelOf(owner))
		local itemH = 22
		width = width or (owner.AbsoluteSize.X / dpiScale)
		local maxVisible = 10
		local visible = math.min(#options, maxVisible)
		local searchH = #options > 20 and 30 or 0
		local fullH = visible * itemH + 4 + searchH
		local list = frame({
			Name = "List",
			Position = popupPosition(owner, width, fullH),
			Size = UDim2.fromOffset(width, 0),
			ClipsDescendants = true,
			BackgroundColor3 = Theme.Popup,
			Parent = popupLayer,
		})
		corner(3).Parent = list
		stroke(Theme.FieldStroke, 1).Parent = list
		local scroller = create("ScrollingFrame", {
			Position = UDim2.fromOffset(2, 2 + searchH),
			Size = UDim2.new(1, -4, 1, -4 - searchH),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = #options > maxVisible and 2 or 0,
			ScrollBarImageColor3 = rgb(40, 55, 70),
			CanvasSize = UDim2.fromOffset(0, #options * itemH),
			Parent = list,
		})
		local entries = {}
		local function refresh()
			for i, e in ipairs(entries) do
				local sel = isSelected(i)
				e.label.TextColor3 = sel and Theme.Title or Theme.Value
				if e.check then
					e.check.Visible = sel
				end
			end
		end
		for i, opt in ipairs(options) do
			local b = hitbox({
				Position = UDim2.fromOffset(0, (i - 1) * itemH),
				Size = UDim2.new(1, 0, 0, itemH),
				BackgroundColor3 = Theme.PopupHover,
				Parent = scroller,
			})
			corner(2).Parent = b
			local l = text({
				Text = opt,
				FontFace = Fonts.SemiBold,
				TextSize = 13,
				Position = UDim2.fromOffset(7, 0),
				Size = UDim2.new(1, -26, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = b,
			})
			local check
			if multi then
				check = icon("check", 10, Theme.NavIcon, {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -7, 0.5, 0),
					Parent = b,
				})
			end
			entries[i] = { label = l, check = check, button = b }
			connect(b.MouseEnter, function()
				b.BackgroundTransparency = 0
			end)
			connect(b.MouseLeave, function()
				b.BackgroundTransparency = 1
			end)
			connect(b.MouseButton1Click, function()
				pick(i)
				refresh()
				if not multi then
					closePopupsAbove(levelOf(owner))
				end
			end)
		end
		if searchH > 0 then
			local search = create("TextBox", {Name="Search", Position=UDim2.fromOffset(6,5),Size=UDim2.new(1,-12,0,22),BackgroundColor3=Theme.Field,BorderSizePixel=0,Text="",PlaceholderText="Search...",ClearTextOnFocus=false,FontFace=Fonts.SemiBold,TextSize=12,TextColor3=Theme.Title,PlaceholderColor3=Theme.Dim,TextXAlignment=Enum.TextXAlignment.Left,Parent=list})
			corner(3).Parent=search
			create("UIPadding",{PaddingLeft=UDim.new(0,6),Parent=search})
			connect(search:GetPropertyChangedSignal("Text"),function()
				local query=search.Text:lower();local count=0
				for i,e in ipairs(entries)do
					local show=options[i]:lower():find(query,1,true)~=nil
					e.button.Visible=show
					if show then e.button.Position=UDim2.fromOffset(0,count*itemH);count=count+1 end
				end
				scroller.CanvasSize=UDim2.fromOffset(0,count*itemH);scroller.CanvasPosition=Vector2.zero;scroller.ScrollBarThickness=count>maxVisible and 2 or 0
			end)
		end
		refresh()
		tween(list, 0.12, { Size = UDim2.fromOffset(width, fullH) })
		pushPopup(list, owner, function()
			list:Destroy()
		end)
	end

	function Controls.dropdown(parent, opts, onUser)
		local options = opts.options
		local multi = opts.multi
		local selected = multi and {} or 1
		local width = opts.width or 130
		local height = opts.height or 22
		local root, rootStroke = field({
			Name = "Dropdown",
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromOffset(width, height),
			Parent = parent,
		})
		local valueLabel = text({
			Name = "Value",
			FontFace = Fonts.SemiBold,
			TextSize = opts.textSize or 14,
			TextColor3 = Theme.Label,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(opts.padding or 8, 0),
			Size = UDim2.new(1, -(opts.padding or 8) - 22, 1, 0),
			Parent = root,
		})
		icon("chevron", opts.chevron or 10, Theme.Label, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			Parent = root,
		})
		local function current()
			if multi then
				local names = {}
				for i, opt in ipairs(options) do
					if selected[i] then
						table.insert(names, opt)
					end
				end
				return names
			end
			return options[selected]
		end
		local function render()
			if multi then
				local names = current()
				valueLabel.Text = #names > 0 and table.concat(names, ", ") or "Select"
			else
				valueLabel.Text = options[selected] or "-"
			end
		end
		local function apply(v)
			if multi then
				selected = {}
				for _, name in ipairs(type(v) == "table" and v or {}) do
					local i = table.find(options, name)
					if i then
						selected[i] = true
					end
				end
			else
				selected = table.find(options, v) or 1
			end
			render()
		end
		apply(opts.default)
		local hit = hitbox({ Size = UDim2.fromScale(1, 1), Parent = root })
		connect(hit.MouseEnter, function()
			tween(rootStroke, 0.15, { Color = rgb(9, 52, 80) })
		end)
		connect(hit.MouseLeave, function()
			tween(rootStroke, 0.15, { Color = Theme.FieldStroke })
		end)
		connect(hit.MouseButton1Click, function()
			if topOwner() == root then
				closePopupsAbove(levelOf(root))
				return
			end
			openList(root, options, function(i)
				if multi then
					return selected[i] == true
				end
				return selected == i
			end, function(i)
				if multi then
					selected[i] = not selected[i] or nil
				else
					selected = i
				end
				render()
				onUser(current())
			end, multi, width)
		end)
		return root, apply
	end

	local function hsvPopup(owner, color, onChange)
		closePopupsAbove(levelOf(owner))
		local h, s, v = color:ToHSV()
		local pop = frame({
			Name = "ColorPicker",
			Position = popupPosition(owner, 190, 186, true),
			Size = UDim2.fromOffset(190, 186),
			BackgroundColor3 = Theme.Popup,
			Parent = popupLayer,
		})
		corner(4).Parent = pop
		stroke(Theme.FieldStroke, 1).Parent = pop
		local sv = frame({
			Name = "SV",
			Position = UDim2.fromOffset(8, 8),
			Size = UDim2.fromOffset(150, 144),
			BackgroundColor3 = Color3.fromHSV(h, 1, 1),
			Parent = pop,
		}, { corner(3) })
		frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = sv }, {
			corner(3),
			create("UIGradient", { Transparency = NumberSequence.new(0, 1) }),
		})
		frame({ Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), Parent = sv }, {
			corner(3),
			create("UIGradient", { Transparency = NumberSequence.new(1, 0), Rotation = 90 }),
		})
		local svCursor = frame({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(8, 8),
			BackgroundTransparency = 1,
			Parent = sv,
		}, { corner(UDim.new(1, 0)), stroke(Color3.new(1, 1, 1), 1.5) })
		local hue = frame({
			Name = "Hue",
			Position = UDim2.fromOffset(168, 8),
			Size = UDim2.fromOffset(14, 144),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = pop,
		}, {
			corner(3),
			create("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
					ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
					ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
					ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
					ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
					ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
				}),
			}),
		})
		local hueCursor = frame({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(1, 4, 0, 4),
			BackgroundTransparency = 1,
			Parent = hue,
		}, { corner(2), stroke(Color3.new(1, 1, 1), 1.5) })
		-- hex entry under the picker
		local hexBox = create("TextBox", {
			Position = UDim2.fromOffset(8, 158),
			Size = UDim2.fromOffset(174, 20),
			BackgroundColor3 = Theme.Field,
			BorderSizePixel = 0,
			FontFace = Fonts.SemiBold,
			TextSize = 13,
			TextColor3 = Theme.Label,
			ClearTextOnFocus = false,
			Text = toHex(color),
			Parent = pop,
		}, { corner(3), stroke(Theme.FieldStroke, 1) })

		local function render(report)
			sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			svCursor.Position = UDim2.fromScale(s, 1 - v)
			hueCursor.Position = UDim2.fromScale(0.5, h)
			local c = Color3.fromHSV(h, s, v)
			if not hexBox:IsFocused() then
				hexBox.Text = toHex(c)
			end
			if report then
				onChange(c)
			end
		end
		render(false)

		local mode
		local function update()
			local m = mouseAbs()
			if mode == "sv" then
				s = math.clamp((m.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
				v = 1 - math.clamp((m.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
			elseif mode == "hue" then
				h = math.clamp((m.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 0.999)
			end
			render(true)
		end
		local svHit = hitbox({ Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = sv })
		local hueHit = hitbox({ Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = hue })
		local conns = {
			svHit.MouseButton1Down:Connect(function()
				mode = "sv"
				update()
			end),
			hueHit.MouseButton1Down:Connect(function()
				mode = "hue"
				update()
			end),
			UserInputService.InputChanged:Connect(function(input)
				if mode and input.UserInputType == Enum.UserInputType.MouseMovement then
					update()
				end
			end),
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					mode = nil
				end
			end),
			hexBox.FocusLost:Connect(function()
				local c = fromHex(hexBox.Text)
				h, s, v = c:ToHSV()
				render(true)
			end),
		}
		pushPopup(pop, owner, function()
			for _, c in ipairs(conns) do
				c:Disconnect()
			end
			pop:Destroy()
		end)
	end

	function Controls.color(parent, onUser)
		local root = frame({
			Name = "Color",
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromOffset(16, 12),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = parent,
		}, { corner(3) })
		stroke(Theme.FieldStroke, 1).Parent = root
		local function apply(hex)
			root.BackgroundColor3 = fromHex(hex)
		end
		local hit = hitbox({ Size = UDim2.new(1, 6, 1, 8), Position = UDim2.fromOffset(-3, -4), Parent = root })
		connect(hit.MouseButton1Click, function()
			if topOwner() == root then
				closePopupsAbove(levelOf(root))
				return
			end
			hsvPopup(root, root.BackgroundColor3, function(c)
				root.BackgroundColor3 = c
				onUser(toHex(c))
			end)
		end)
		return root, apply
	end

	function Controls.keybind(parent, onUser, width)
		local root, rootStroke = field({
			Name = "Keybind",
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromOffset(width or 74, 22),
			Parent = parent,
		})
		local label = text({
			FontFace = Fonts.SemiBold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
			Parent = root,
		})
		local value, listening = "None", false
		local function render()
			label.Text = listening and "..." or value
			label.TextColor3 = (value == "None" and not listening) and Theme.Value or Theme.Label
			rootStroke.Color = listening and Theme.KnobOn or Theme.FieldStroke
		end
		local function apply(v)
			value = v or "None"
			render()
		end
		local hit = hitbox({ Size = UDim2.fromScale(1, 1), Parent = root })
		connect(hit.MouseButton1Click, function()
			if listening then
				return
			end
			listening = true
			Store.captureUntil = math.huge
			render()
			local conn
			conn = UserInputService.InputBegan:Connect(function(input)
				local name
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					name = false -- clicking cancels
				elseif input.KeyCode == Enum.KeyCode.Escape then
					name = false
				elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
					name = "None"
				else
					name = keyName(input)
					if not name then
						return
					end
				end
				conn:Disconnect()
				listening = false
				Store.captureUntil = os.clock() + 0.25
				if name then
					value = name
					onUser(value)
				end
				render()
			end)
			table.insert(connections, conn)
		end)
		return root, apply
	end

	function Controls.gear(parent, onClick)
		local root = hitbox({
			Name = "Settings",
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromOffset(13, 13),
			Parent = parent,
		})
		local img = icon("gear", 13, Theme.Dim, { Parent = root })
		connect(root.MouseEnter, function()
			tween(img, 0.15, { ImageColor3 = Theme.Label })
		end)
		connect(root.MouseLeave, function()
			tween(img, 0.15, { ImageColor3 = Theme.Dim })
		end)
		if onClick then
			connect(root.MouseButton1Click, function()
				onClick(root)
			end)
		end
		return root
	end

	function Controls.button(parent, label, iconName, width, height, style)
		local function baseColor()
			if style == "danger" then
				return rgb(150, 38, 46)
			elseif style == "dim" then
				return Theme.Button:Lerp(Theme.Group, 0.55)
			end
			return Theme.Button
		end
		local root = frame({
			Name = label,
			Size = UDim2.fromOffset(width, height),
			BackgroundColor3 = baseColor(),
			Parent = parent,
		}, { corner(3) })
		local row = frame({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(width, height),
			BackgroundTransparency = 1,
			Parent = root,
		}, {
			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 9),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		local img
		if iconName then
			img = icon(iconName, 11, Color3.new(1, 1, 1), { LayoutOrder = 1, Parent = row })
		end
		local labelObj = text({
			Text = label,
			FontFace = Fonts.Bold,
			TextSize = height >= 28 and 14 or 13,
			TextColor3 = Color3.new(1, 1, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, height),
			LayoutOrder = 2,
			Parent = row,
		})
		local hit = hitbox({ Size = UDim2.fromScale(1, 1), Parent = root })
		local hovering = false
		connect(hit.MouseEnter, function()
			hovering = true
			tween(root, 0.15, { BackgroundColor3 = baseColor():Lerp(Color3.new(1, 1, 1), 0.08) })
		end)
		connect(hit.MouseLeave, function()
			hovering = false
			tween(root, 0.15, { BackgroundColor3 = baseColor() })
		end)
		table.insert(Store.rerender, function()
			if not hovering then
				root.BackgroundColor3 = baseColor()
			end
		end)
		return root, hit, labelObj, img
	end

	function Controls.tabs(parent, names, position, onSelect)
		local segW = 100
		local root = frame({
			Name = "Tabs",
			Position = position,
			Size = UDim2.fromOffset(segW * #names, 29),
			BackgroundTransparency = 1,
			Parent = parent,
		}, { corner(3) })
		stroke(Theme.FieldStroke, 1).Parent = root
		local active = frame({
			Name = "Active",
			Position = UDim2.fromOffset(1, 1),
			Size = UDim2.fromOffset(segW, 27),
			BackgroundColor3 = Theme.TabActive,
			Parent = root,
		}, { corner(2) })
		table.insert(Store.rerender, function()
			active.BackgroundColor3 = Theme.TabActive
		end)
		local labels, dividers = {}, {}
		local currentTab = 1
		local function render()
			for i, l in ipairs(labels) do
				l.TextColor3 = (i == currentTab) and Color3.new(1, 1, 1) or Theme.Label
			end
			for i, d in ipairs(dividers) do
				d.Visible = not (i == currentTab or i + 1 == currentTab)
			end
		end
		for i, name in ipairs(names) do
			local b = hitbox({
				Position = UDim2.fromOffset((i - 1) * segW, 0),
				Size = UDim2.fromOffset(segW, 29),
				Parent = root,
			})
			labels[i] = text({
				Text = name,
				FontFace = Fonts.Bold,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Center,
				Size = UDim2.fromScale(1, 1),
				Parent = b,
			})
			if i < #names then
				dividers[i] = frame({
					Position = UDim2.fromOffset(i * segW - 2, 5),
					Size = UDim2.fromOffset(1, 19),
					BackgroundColor3 = Theme.FieldStroke,
					Parent = root,
				})
			end
			connect(b.MouseButton1Click, function()
				if currentTab == i then
					return
				end
				currentTab = i
				tween(active, 0.18, {
					Position = UDim2.fromOffset(1 + (i - 1) * segW, 1),
					Size = UDim2.fromOffset(i == #names and segW - 2 or segW, 27),
				})
				render()
				if onSelect then
					onSelect(i, name)
				end
			end)
		end
		render()
		return root
	end

	-- single-line text input styled like the other fields
	function Controls.input(parent, props)
		local root = field({
			Name = "Input",
			Position = props.Position,
			Size = props.Size,
			AnchorPoint = props.AnchorPoint,
			Parent = parent,
		})
		local box = create("TextBox", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(props.padding or 8, 0),
			Size = UDim2.new(1, -(props.padding or 8) * 2, 1, 0),
			FontFace = Fonts.SemiBold,
			TextSize = props.textSize or 14,
			TextColor3 = Theme.Title,
			PlaceholderText = props.placeholder or "",
			PlaceholderColor3 = Theme.Dim,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Text = props.text or "",
			Parent = root,
		})
		return root, box
	end

	---------------------------------------------------------------------------------------
	-- Notifications
	---------------------------------------------------------------------------------------
	local history = {}
	local toastOrder = 0
	notify = function(title, body, kind)
		table.insert(history, 1, { title = title, body = body or "", time = os.date("%H:%M:%S"), kind = kind })
		if #history > 30 then
			table.remove(history)
		end
		if getValue("Main/Interface/Notifications") == false then
			return
		end
		toastOrder += 1
		local card = create("CanvasGroup", {
			Name = "Toast",
			Size = UDim2.fromOffset(300, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.Group,
			BorderSizePixel = 0,
			GroupTransparency = 1,
			LayoutOrder = toastOrder,
			Parent = toastHolder,
		}, { corner(4), stroke(Theme.FieldStroke, 1) })
		frame({
			Name = "Accent",
			Size = UDim2.new(0, 2, 1, 0),
			BackgroundColor3 = kind == "error" and rgb(222, 70, 80) or Theme.KnobOn,
			Parent = card,
		})
		local inner = frame({
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = card,
		}, {
			create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 9) }),
			create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
		text({
			Text = title,
			FontFace = Fonts.Bold,
			TextSize = 14,
			TextColor3 = Theme.Title,
			Size = UDim2.new(1, 0, 0, 17),
			LayoutOrder = 1,
			Parent = inner,
		})
		if body and body ~= "" then
			text({
				Text = body,
				FontFace = Fonts.SemiBold,
				TextSize = 13,
				TextColor3 = Theme.Label,
				TextWrapped = true,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2,
				Parent = inner,
			})
		end
		tween(card, 0.2, { GroupTransparency = 0 })
		task.delay(4, function()
			if card.Parent then
				tween(card, 0.35, { GroupTransparency = 1 })
				task.wait(0.4)
				card:Destroy()
			end
		end)
	end

	---------------------------------------------------------------------------------------
	-- Panels: small floating group boxes used for row settings (binds), menu settings,
	-- text prompts and the notification log.
	---------------------------------------------------------------------------------------
	local buildRow -- defined below

	local function openPanel(owner, title, width, build)
		closePopupsAbove(levelOf(owner))
		local panel = frame({
			Name = "Panel",
			Size = UDim2.fromOffset(width, 60),
			BackgroundColor3 = Theme.Group,
			Parent = popupLayer,
		}, { corner(5) })
		stroke(Theme.FieldStroke, 1).Parent = panel
		text({
			Text = title,
			FontFace = Fonts.Bold,
			TextSize = 15,
			TextColor3 = Theme.Title,
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -20, 0, 30),
			Parent = panel,
		})
		frame({
			Position = UDim2.fromOffset(5, 30),
			Size = UDim2.new(1, -10, 0, 2),
			BackgroundColor3 = Theme.Line,
			Parent = panel,
		})
		local rows = frame({
			Name = "Rows",
			Position = UDim2.fromOffset(0, 47),
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			Parent = panel,
		}, { create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
		local handles = {}
		local bodyHeight = build(rows, handles, width)
		local h = 47 + bodyHeight + 5
		rows.Size = UDim2.new(1, 0, 0, bodyHeight)
		panel.Size = UDim2.fromOffset(width, h)
		panel.Position = popupPosition(owner, width, h, true)
		pushPopup(panel, owner, function()
			for _, release in ipairs(handles) do
				release()
			end
			panel:Destroy()
		end)
		return panel
	end

	local function openBindPanel(owner, path, labelText)
		openPanel(owner, labelText, 230, function(rows, handles, width)
			buildRow(rows, { "keybind", "Key" }, 1, width, path, handles, Store.pageOf[path])
			buildRow(rows, { "dropdown", "Mode", { "Toggle", "Hold", "Always" }, 1 }, 2, width, path, handles, Store.pageOf[path])
			return ROW_H * 2
		end)
	end

	local function prompt(owner, title, placeholder, confirmText, initial, onConfirm)
		local box
		openPanel(owner, title, 300, function(rows)
			local row = frame({ Size = UDim2.new(1, 0, 0, ROW_H), BackgroundTransparency = 1, Parent = rows })
			local _, b = Controls.input(row, {
				Position = UDim2.fromOffset(10, 4),
				Size = UDim2.fromOffset(300 - 20 - 88, 24),
				placeholder = placeholder,
				text = initial,
				textSize = 13,
			})
			box = b
			local btn, hit = Controls.button(row, confirmText, nil, 80, 24)
			btn.Position = UDim2.fromOffset(300 - 10 - 80, 4)
			local function submit()
				local value = box.Text
				closePopupsAbove(levelOf(owner))
				onConfirm(value)
			end
			connect(hit.MouseButton1Click, submit)
			connect(box.FocusLost, function(enter)
				if enter then
					submit()
				end
			end)
			return ROW_H
		end)
		task.defer(function()
			if box and box.Parent then
				box:CaptureFocus()
			end
		end)
	end

	---------------------------------------------------------------------------------------
	-- Rows and groups
	---------------------------------------------------------------------------------------
	buildRow = function(parent, spec, order, width, base, handles, pageKey, searchMeta)
		local kind, labelText = spec[1], spec[2]
		local path = base .. "/" .. labelText
		local row = frame({
			Name = labelText,
			Size = UDim2.new(1, 0, 0, ROW_H),
			BackgroundTransparency = 1,
			LayoutOrder = order,
			Parent = parent,
		})
		local labelObj = text({
			Name = "Label",
			Text = labelText,
			FontFace = Fonts.SemiBold,
			TextSize = 14,
			TextColor3 = Theme.Label,
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -20, 1, 0),
			Parent = row,
		})
		local right = width - 10
		local function place(obj, w)
			obj.Position = UDim2.new(0, right, 0.5, 0)
			right -= w + 8
		end
		local function hold(release)
			if handles then
				table.insert(handles, release)
			end
		end
		local toggleFn

		if kind == "toggle" then
			declare(path, "toggle", spec[3] == true, pageKey)
			local sw, apply, toggle = Controls.switch(row, function(v)
				setValue(path, v)
			end)
			place(sw, 26)
			hold(register(path, apply))
			toggleFn = toggle
		elseif kind == "slider" then
			local o = spec[3]
			declare(path, "slider", o.default, pageKey)
			local s, apply = Controls.slider(row, o, function(v)
				setValue(path, v)
			end)
			place(s, 132)
			hold(register(path, apply))
		elseif kind == "dropdown" or kind == "multi" then
			local options = spec[3]
			local default
			if kind == "multi" then
				default = {}
				for _, i in ipairs(spec[4] or {}) do
					table.insert(default, options[i])
				end
			else
				default = options[spec[4] or 1]
			end
			declare(path, kind, default, pageKey)
			local d, apply = Controls.dropdown(row, { options = options, default = default, multi = kind == "multi" }, function(v)
				setValue(path, v)
			end)
			place(d, 130)
			hold(register(path, apply))
		elseif kind == "color" then
			declare(path, "color", toHex(spec[3]), pageKey)
			local c, apply = Controls.color(row, function(v)
				setValue(path, v)
			end)
			place(c, 16)
			hold(register(path, apply))
		elseif kind == "keybind" then
			declare(path, "keybind", spec[3] or "None", pageKey)
			local k, apply = Controls.keybind(row, function(v)
				setValue(path, v)
			end)
			place(k, 74)
			hold(register(path, apply))
		elseif kind == "input" then
			declare(path, "input", spec[3] or "", pageKey)
			local field, box = Controls.input(row, {Size=UDim2.fromOffset(154,24),text=spec[3] or "",placeholder=spec.placeholder or "",textSize=12})
			field.AnchorPoint=Vector2.new(1,.5)
			place(field,154)
			labelObj.Size=UDim2.new(1,-180,1,0)
			hold(register(path,function(v)if not box:IsFocused()then box.Text=tostring(v or "")end end))
			connect(box.FocusLost,function()setValue(path,box.Text)end)
		elseif kind == "button" then
			local b, hit = Controls.button(row, spec[3] or labelText, nil, 96, 22, spec.style)
			b.AnchorPoint = Vector2.new(1, 0.5)
			place(b, 96)
			connect(hit.MouseButton1Click, function()
				if spec.callback then
					spec.callback(b)
				end
			end)
		end

		if spec.color then
			local cpath = path .. "/Color"
			declare(cpath, "color", toHex(spec.color), pageKey)
			local c, apply = Controls.color(row, function(v)
				setValue(cpath, v)
			end)
			place(c, 16)
			hold(register(cpath, apply))
		end
		if spec.gear and kind == "toggle" then
			declare(path .. "/Key", "keybind", "None", pageKey)
			declare(path .. "/Mode", "dropdown", "Toggle", pageKey)
			Store.binds[path] = labelText
			local g = Controls.gear(row, function(gearObj)
				if topOwner() == gearObj then
					closePopupsAbove(levelOf(gearObj))
					return
				end
				openBindPanel(gearObj, path, labelText)
			end)
			place(g, 13)
		end
		if toggleFn then
			-- clicking the free space left of the controls also flips the switch
			local labelHit = hitbox({
				Name = "LabelHit",
				Position = UDim2.fromOffset(6, 0),
				Size = UDim2.new(0, math.max(20, right - 6), 1, 0),
				Parent = row,
			})
			connect(labelHit.MouseButton1Click, toggleFn)
		end
		if searchMeta then
			table.insert(Store.index, {
				label = labelText,
				path = path,
				pageKey = pageKey,
				pageTitle = searchMeta.pageTitle,
				group = searchMeta.group,
				row = row,
			})
		end
		return row
	end

	local function buildGroup(column, spec, order, pageKey, pageTitle)
		local rows = spec.rows
		local h = 47 + #rows * ROW_H + 5
		local g = frame({
			Name = spec.title,
			Size = UDim2.new(1, 0, 0, h),
			BackgroundColor3 = Theme.Group,
			LayoutOrder = order,
			Parent = column,
		}, { corner(5) })
		text({
			Name = "Title",
			Text = spec.title,
			FontFace = Fonts.Bold,
			TextSize = 15,
			TextColor3 = Theme.Title,
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -20, 0, 30),
			Parent = g,
		})
		frame({
			Name = "Line",
			Position = UDim2.fromOffset(5, 30),
			Size = UDim2.new(1, -10, 0, 2),
			BackgroundColor3 = Theme.Line,
			Parent = g,
		})
		local rowsFrame = frame({
			Name = "Rows",
			Position = UDim2.fromOffset(0, 47),
			Size = UDim2.new(1, 0, 0, #rows * ROW_H),
			BackgroundTransparency = 1,
			Parent = g,
		}, { create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
		for i, r in ipairs(rows) do
			buildRow(rowsFrame, r, i, COL_W, pageTitle .. "/" .. spec.title, nil, pageKey, { pageTitle = pageTitle, group = spec.title })
		end
		return g
	end

	local pagesHolder = frame({
		Name = "Pages",
		Position = UDim2.fromOffset(0, HEADER_H + 2),
		Size = UDim2.fromOffset(CONTENT_W, WIN_H - HEADER_H - 2),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = content,
	})

	local function newPageFrame(name)
		return create("ScrollingFrame", {
			Name = name,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = rgb(27, 37, 48),
			ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ElasticBehavior = Enum.ElasticBehavior.Never,
			Visible = false,
			Parent = pagesHolder,
		})
	end

	local function columnsPage(pageKey, title, left, right)
		local sc = newPageFrame(title)
		local inner = frame({
			Name = "Inner",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = sc,
		}, { create("UIPadding", { PaddingTop = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20) }) })
		for ci, groups in ipairs({ left, right }) do
			local col = frame({
				Name = ci == 1 and "Left" or "Right",
				Position = UDim2.fromOffset(ci == 1 and 20 or 20 + COL_W + 11, 0),
				Size = UDim2.fromOffset(COL_W, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Parent = inner,
			}, { create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
			for gi, gspec in ipairs(groups) do
				local supported = {}
				for _, row in ipairs(gspec.rows) do
					if row.supported ~= false and not (gameAdapter and row.legacyOnly) and not (not gameAdapter and row.nativeOnly) then table.insert(supported, row) end
				end
				gspec.rows = supported
				buildGroup(col, gspec, gi, pageKey, title)
			end
		end
		return sc
	end

	local function listPage(title)
		local sc = newPageFrame(title)
		frame({
			Name = "Inner",
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = sc,
		}, {
			create("UIPadding", { PaddingTop = UDim.new(0, 20), PaddingBottom = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20) }),
			create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
		})
		return sc
	end

	-- a card in the Scripts / Configs lists
	local function listCard(parent, order, info)
		local card = frame({
			Name = info.title,
			Size = UDim2.new(1, 0, 0, 54),
			BackgroundColor3 = Theme.Group,
			LayoutOrder = order,
			Parent = parent,
		}, { corner(4) })
		local nameLabel = text({
			Text = info.title,
			FontFace = Fonts.Bold,
			TextSize = 14,
			TextColor3 = Theme.Title,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(12, 9),
			Size = UDim2.fromOffset(330, 17),
			Parent = card,
		})
		local meta, link = toHex(Theme.Value), toHex(Theme.Link)
		local parts = {}
		for i = 1, #info.meta, 2 do
			table.insert(parts, string.format('<font color="%s">%s</font> <font color="%s">%s</font>', meta, info.meta[i], link, info.meta[i + 1]))
		end
		text({
			RichText = true,
			Text = table.concat(parts, "     "),
			FontFace = Fonts.SemiBold,
			TextSize = 12,
			Position = UDim2.fromOffset(12, 29),
			Size = UDim2.fromOffset(330, 16),
			Parent = card,
		})
		local btn, btnHit = Controls.button(card, info.loaded and info.loadedText or "Load", info.loaded and "check" or "play", 82, 24, info.loaded and "dim" or nil)
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.Position = UDim2.new(1, -12, 0.5, 0)
		connect(btnHit.MouseButton1Click, info.onLoad)

		local x = -12 - 82 - 16
		local actions = {
			{ "trash", "delete" },
			{ "copy", "duplicate" },
			{ "share", "share" },
			{ "pencil", "rename" },
		}
		for _, a in ipairs(actions) do
			local hb = hitbox({
				Name = a[2],
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, x, 0.5, 0),
				Size = UDim2.fromOffset(18, 18),
				Parent = card,
			})
			local img = icon(a[1], 13, Theme.Label, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Parent = hb,
			})
			local armed = false
			connect(hb.MouseEnter, function()
				if not armed then
					tween(img, 0.15, { ImageColor3 = Theme.Title })
				end
			end)
			connect(hb.MouseLeave, function()
				if not armed then
					tween(img, 0.15, { ImageColor3 = Theme.Label })
				end
			end)
			connect(hb.MouseButton1Click, function()
				if a[2] == "delete" then
					-- first click arms, second click within 2.5s deletes
					if not armed then
						armed = true
						img.ImageColor3 = rgb(222, 70, 80)
						notify(info.title, "Click the bin again to delete.")
						task.delay(2.5, function()
							armed = false
							if img.Parent then
								img.ImageColor3 = Theme.Label
							end
						end)
						return
					end
					info.onDelete()
				elseif a[2] == "rename" then
					nameLabel.Visible = false
					local _, box = Controls.input(card, {
						Position = UDim2.fromOffset(8, 6),
						Size = UDim2.fromOffset(240, 22),
						text = info.title,
						textSize = 14,
						padding = 4,
					})
					box:CaptureFocus()
					box.FocusLost:Connect(function(enter)
						local newName = box.Text
						box.Parent:Destroy()
						nameLabel.Visible = true
						if enter and newName ~= "" and newName ~= info.title then
							info.onRename(newName)
						end
					end)
				elseif a[2] == "share" then
					info.onShare()
				elseif a[2] == "duplicate" then
					info.onCopy()
				end
			end)
			x -= 26
		end
		return card
	end

	local function clearList(page)
		local inner = page:FindFirstChild("Inner")
		for _, child in ipairs(inner:GetChildren()) do
			if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
				child:Destroy()
			end
		end
		return inner
	end

	local function emptyNote(inner, msg)
		text({
			Text = msg,
			FontFace = Fonts.SemiBold,
			TextSize = 14,
			TextColor3 = Theme.Dim,
			Size = UDim2.new(1, 0, 0, 40),
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = inner,
		})
	end

	---------------------------------------------------------------------------------------
	-- Local visual features (World page). Only the local camera and lighting change, and
	-- everything is put back when switched off or when the menu unloads.
	---------------------------------------------------------------------------------------
	local Lighting = cloneref(game:GetService("Lighting"))
	local camera = workspace.CurrentCamera
	local original = {
		ClockTime = Lighting.ClockTime,
		Ambient = Lighting.Ambient,
		FogStart = Lighting.FogStart,
		FogEnd = Lighting.FogEnd,
		FogColor = Lighting.FogColor,
		GlobalShadows = Lighting.GlobalShadows,
		FieldOfView = camera and camera.FieldOfView or 70,
	}
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		original.AtmosphereDensity = atmosphere.Density
		original.AtmosphereColor = atmosphere.Color
	end
	local defaultFov = gameAdapter and gameAdapter.defaultFov or math.floor(original.FieldOfView + 0.5)
	local defaultAmbient = toHex(original.Ambient)

	---------------------------------------------------------------------------------------
	-- Page content
	---------------------------------------------------------------------------------------
	local HITBOXES = gameAdapter and { "Head", "Body" } or { "Head", "Chest", "Stomach", "Arms", "Legs", "Feet" }
	local function pct(v)
		return tostring(math.floor(v + 0.5)) .. "%"
	end

	local pages = {}
	local headerWidgets = {}

	pages.ragebot = columnsPage("ragebot", "Ragebot", {
		{
			title = "Main",
			rows = {
				{ "toggle", "Enabled", false, gear = true },
				{ "toggle", "Silent Aim", true },
				{ "toggle", "Automatic Fire", true },
				{ "toggle", "Automatic Penetration", true, legacyOnly = true },
				{ "slider", "Field of View", { min = 0, max = 180, default = 180, suffix = "°" } },
			},
		},
		{
			title = "Accuracy",
			rows = {
				{ "slider", "Hit Chance", { min = 0, max = 100, default = 62, format = pct } },
				{ "toggle", "Seed Prediction", false, legacyOnly = true },
				{ "slider", "Minimum Damage", { min = 0, max = 100, default = gameAdapter and 10 or 30, format = function(v)
					return v == 0 and "Auto" or tostring(math.floor(v))
				end } },
				{ "dropdown", "Auto Stop", { "Disabled", "Early", "Full", "Between Shots" }, 2 },
				{ "toggle", "Auto Scope", true },
				{ "toggle", "Hide Scope", false },
				{ "toggle", "Hide Shots", false, nativeOnly = true },
				{ "toggle", "Anti-Katana", true, nativeOnly = true },
				{ "toggle", "Anti-Shield", true, nativeOnly = true },
			},
		},
	}, {
		{
			title = "Selection",
			rows = {
				{ "dropdown", "Target", { "Highest Damage", "Lowest Distance", "Hit Chance", "Lowest Health" }, 1 },
				{ "multi", "Hitboxes", HITBOXES, gameAdapter and { 1, 2 } or { 1, 2, 3 } },
				{ "multi", "Multipoint", HITBOXES, { 1, 2 } },
				{ "slider", "Head Scale", { min = 0, max = 100, default = 50, format = pct } },
				{ "slider", "Body Scale", { min = 0, max = 100, default = 60, format = pct } },
				{ "dropdown", "Body Aim", { "Default", "Prefer", "Force" }, 1 },
			},
		},
	})

	pages.legitbot = columnsPage("legitbot", "Legitbot", {
		{title="Main",rows={
			{"toggle","Enabled",false},
			{"keybind","Aim Key","Mouse2"},
			{"dropdown","Activation",{"Hold","Always"},1},
		}},
		{title="Aim",rows={
			{"slider","Field of View",{min=10,max=500,default=100,suffix=" px"}},
			{"slider","Smoothing",{min=1,max=30,default=8}},
			{"slider","Deadzone",{min=0,max=20,default=2,suffix=" px"}},
			{"dropdown","Hitbox",{"Head","Body","Closest"},1},
		}},
	}, {
		{title="Selection",rows={
			{"toggle","Team Check",true},
			{"toggle","Visible Only",true},
			{"toggle","Target Lock",true},
			{"slider","Reaction Delay",{min=0,max=300,default=80,suffix=" ms"}},
			{"slider","Maximum Distance",{min=50,max=2000,default=1000}},
		}},
		{title="Visuals",rows={{"toggle","FOV Circle",true,color=rgb(105,167,255)}}},
	})

	pages.antiaim = columnsPage("antiaim", "Anti Aim", {
		{
			title = "Main",
			rows = {
				{ "toggle", "Enable Anti Aim", false },
				{ "dropdown", "Pitch", { "Disabled", "Down", "Up", "Forward" }, 1, nativeOnly = true, supported = gameAdapter and gameAdapter.pitchSupported },
				{ "dropdown", "Yaw Base", { "Forward", "Backward", "Away from Targets" }, gameAdapter and 2 or 1 },
				{ "slider", "Yaw Add", { min = -180, max = 180, default = 0 } },
				{ "dropdown", "Yaw Modifier", { "Disabled", "Center", "Offset", "Random", "Random Hold", "Spin" }, 1 },
				{ "slider", "Modifier Amount", { min = 0, max = 180, default = 45 } },
				{ "slider", "Modifier Speed", { min = 1, max = 20, default = 6 } },
			},
		},
	}, {
		{
			title = "Movement",
			rows = {
				{ "dropdown", "Slow Walk", { "Disabled", "Slow", "Slower" }, 1 },
				{ "toggle", "Allow Ladder", true },
			},
		},
	})

	pages.players = columnsPage("players", "Players", {
		{
			title = "ESP",
			rows = {
				{ "toggle", "Bounding Box", true, color = rgb(255, 255, 255) },
				{ "toggle", "Name", true, color = rgb(255, 255, 255) },
				{ "toggle", "Health Bar", true },
				{ "dropdown", "Weapon", { "Disabled", "Text", "Icon", "Text + Icon" }, 3 },
				{ "toggle", "Ammo", false, color = rgb(80, 140, 255) },
				{ "multi", "Flags", gameAdapter and { "Aiming", "Local Ping", "Distance" } or { "Aiming", "Credits", "Local Ping", "Distance" }, { 1, 2 } },
				{ "toggle", "Skeleton", false, color = rgb(255, 255, 255) },
			},
		},
		{
			title = "Glow",
			rows = {
				{ "toggle", "Enabled", false, color = rgb(170, 90, 255) },
				{ "dropdown", "Style", { "Default", "Pulse", "Outline" }, 1 },
			},
		},
	}, {
		{
			title = "Chams",
			rows = {
				{ "toggle", "Visible", true, color = rgb(150, 200, 60) },
				{ "toggle", "Through Walls", true, color = rgb(60, 120, 180) },
				{ "dropdown", "Material", { "Flat", "Glow", "Metallic", "Foil", "Marble", "Glass", "Forcefield" }, 1 },
				{ "slider", "Opacity", { min = 10, max = 100, default = 100, format = pct } },
				{ "toggle", "Ragdolls", false },
			},
		},
		{
			title = "Other",
			rows = {
				{ "toggle", "Out of FOV Arrows", false, color = rgb(255, 255, 255) },
				{ "toggle", "Footstep Indicators", false, color = rgb(80, 140, 255) },
			},
		},
	})

	pages.world = columnsPage("world", "World", {
		{
			title = "Ambience",
			rows = {
				{ "toggle", "Night Mode", false, gear = true },
				{ "slider", "Brightness", { min = 0, max = 200, default = 100, format = pct } },
				{ "color", "World Color", rgb(255, 255, 255) },
				{ "color", "Ambient Light", original.Ambient },
				{ "toggle", "Fog", false, color = rgb(120, 130, 150) },
			},
		},
		{
			title = "Removals",
			rows = {
				{ "multi", "Removals", { "Visual Recoil", "Smoke", "Flash", "Scope Overlay", "Post Processing" }, {} },
				{ "toggle", "Remove Shadows", false },
			},
		},
	}, {
		{
			title = "Effects",
			rows = {
				{ "toggle", "Bullet Tracers", true, color = rgb(80, 140, 255) },
				{ "toggle", "Bullet Impacts", false, color = rgb(255, 80, 80) },
				{ "toggle", "Hit Marker", true },
				{ "dropdown", "Hit Sound", { "Disabled", "Click", "Bell", "Bubble" }, 1 },
				{ "toggle", "Grenade Prediction", true, color = rgb(255, 255, 255), legacyOnly = true },
			},
		},
		{
			title = "View",
			rows = {
				{ "slider", "Override FOV", { min = 30, max = 120, default = defaultFov, suffix = "°" } },
				{ "slider", "Viewmodel FOV", { min = 40, max = 100, default = 68 }, legacyOnly = true },
				{ "toggle", "Thirdperson", false, gear = true },
				{ "slider", "Distance", { min = 30, max = 300, default = 120 } },
			},
		},
	})

	pages.main = columnsPage("main", "Main", {
		{
			title = "Interface",
			rows = {
				{ "toggle", "Watermark", true },
				{ "toggle", "Keybind List", true },
				{ "toggle", "Notifications", true },
			},
		},
		{
			title = "Movement",
			rows = {
				{ "toggle", "Speed Boost", false, gear = true, nativeOnly = true },
				{ "slider", "Walk Speed", { min = 100, max = 200, default = 150, format = pct }, nativeOnly = true },
				{ "toggle", "Fast Slide", false, gear = true, nativeOnly = true },
				{ "slider", "Slide Speed", { min = 100, max = 125, default = 125, format = pct }, nativeOnly = true },
			},
		},
	}, {
		{
			title = "Air Movement",
			rows = {
				{ "toggle", "Extra Air Jumps", false, gear = true, nativeOnly = true },
				{ "slider", "Additional Jumps", { min = 1, max = 5, default = 2 }, nativeOnly = true },
			},
		},
		{
			title = "Posture",
			rows = {
				{ "toggle", "Fake Crouch", false, gear = true, nativeOnly = true },
			},
		},
		{
			title = "Automation",
			rows = {
				{ "toggle", "Auto Vote", false, nativeOnly = true, supported = gameAdapter and gameAdapter.mapVoteSupported == true },
				{ "dropdown", "Preferred Map", gameAdapter and gameAdapter.mapChoices or { "Select a map" }, 1, nativeOnly = true, supported = gameAdapter and gameAdapter.mapVoteSupported == true },
			},
		},
	})

	local skinModelOptions
	if gameAdapter then
		local equipped = gameAdapter.nativeItem()
		local first = equipped and equipped.Name or table.find(gameAdapter.weaponChoices, "Assault Rifle") and "Assault Rifle" or gameAdapter.weaponChoices[1]
		Store.contexts.skins = first
		skinModelOptions = table.clone(gameAdapter.modelChoices[first])
		pages.skins = columnsPage("skins", "Skin Changer", {{title="Local",rows={
			{"toggle", "Enabled", false},
			{"dropdown", "Model", skinModelOptions, 1},
			{"dropdown", "Wrap", gameAdapter.skinChoices, 1},
			{"toggle", "Inverted", false},
		}}}, {{title="Preview",rows={{"toggle", "Auto Rotate", true}}}})
		api.skinPreview = installSkinPreview(pages.skins, gameAdapter, Store, connect, cleanups, getValue, function() return menuOpen end)
		pages.models = columnsPage("models", "Model Changer", {{title="Selection",rows={
			{"toggle","Enabled",false},
			{"dropdown","Source",{"Anime Example","Asset ID","Local File"},1},
			{"input","Asset ID","",placeholder="Custom model ID"},
			{"input","File","neverlose_ui/models/character.rbxm"},
			{"button","Load Model","Reload",callback=function()if api.models then api.models.reload()end end},
		}}}, {{title="Fitting",rows={
			{"slider","Scale",{min=50,max=150,default=100,format=pct}},
			{"slider","Height",{min=-200,max=200,default=0,format=function(v)return string.format("%.2f",v/100).." studs"end}},
			{"slider","Facing",{min=-180,max=180,default=0,suffix="°"}},
		}},{title="Preview",rows={{"toggle","Auto Rotate",true}}}})
	end

	pages.scripts = listPage("Scripts")
	pages.configs = listPage("Configs")

	-- menu settings (header gear); declared up front so they work before the panel is opened
	local SETTINGS = "Settings/Menu"
	local DEFAULT_ACCENT = Theme.KnobOn
	declare(SETTINGS .. "/Menu Key", "keybind", "Delete")
	declare(SETTINGS .. "/DPI Scale", "dropdown", "100%")
	declare(SETTINGS .. "/Accent Color", "color", toHex(DEFAULT_ACCENT))
	declare(SETTINGS .. "/Background Blur", "toggle", true)
	declare(SETTINGS .. "/Auto Execute", "toggle", false)

	---------------------------------------------------------------------------------------
	-- Header: Save, page widgets, icons
	---------------------------------------------------------------------------------------
	local currentConfig -- name of the loaded config
	local saveConfig, loadConfig -- assigned in the configs section

	local saveBtn, saveStroke = field({ Name = "Save", Position = UDim2.fromOffset(20, 20), Size = UDim2.fromOffset(100, 29), Parent = header })
	icon("save", 15, Theme.Label, { Position = UDim2.fromOffset(20, 8), Parent = saveBtn })
	local saveLabel = text({
		Text = "Save",
		FontFace = Fonts.SemiBold,
		TextSize = 15,
		TextColor3 = Theme.Label,
		Position = UDim2.fromOffset(48, 1),
		Size = UDim2.fromOffset(50, 29),
		Parent = saveBtn,
	})
	local saveHit = hitbox({ Size = UDim2.fromScale(1, 1), Parent = saveBtn })
	connect(saveHit.MouseEnter, function()
		tween(saveStroke, 0.15, { Color = rgb(9, 52, 80) })
	end)
	connect(saveHit.MouseLeave, function()
		tween(saveStroke, 0.15, { Color = Theme.FieldStroke })
	end)
	connect(saveHit.MouseButton1Click, function()
		saveLabel.TextColor3 = Theme.Title
		tween(saveLabel, 0.6, { TextColor3 = Theme.Label })
		saveConfig(currentConfig or "default")
	end)

	-- Ragebot: weapon group picker, each group keeps its own settings
	do
		local weapons = { "Global", "Pistols", "Heavy Pistols", "Auto Snipers", "Scout", "AWP", "Rifles", "SMG" }
		local d = Controls.dropdown(header, {
			options = weapons,
			default = "Global",
			width = 185,
			height = 29,
			textSize = 14,
			padding = 10,
			chevron = 12,
		}, function(v)
			setContext("ragebot", v)
		end)
		d.AnchorPoint = Vector2.new(0, 0)
		d.Position = UDim2.fromOffset(134, 20)
		headerWidgets.ragebot = d
	end
	if gameAdapter then
		local picker = Controls.dropdown(header, {options=gameAdapter.weaponChoices,default=Store.contexts.skins,width=185,height=29,textSize=14,padding=10,chevron=12},function(weapon)
			table.clear(skinModelOptions)
			for _,name in ipairs(gameAdapter.modelChoices[weapon]) do table.insert(skinModelOptions,name) end
			setContext("skins", weapon)
		end)
		picker.AnchorPoint=Vector2.new(0,0);picker.Position=UDim2.fromOffset(134,20)
		headerWidgets.skins=picker
	end

	-- Players: enemies / teammates / local, each keeps its own settings
	headerWidgets.players = Controls.tabs(header, { "Enemies", "Teammates", "Local" }, UDim2.fromOffset(134, 20), function(_, name)
		setContext("players", name)
	end)

	-- Scripts / Configs: sort order + create
	local listSort = { scripts = "By name", configs = "By date" }
	local rebuildScripts, rebuildConfigs, createScript -- assigned below
	for _, key in ipairs({ "scripts", "configs" }) do
		local group = frame({
			Name = key .. "Header",
			Size = UDim2.fromOffset(340, 29),
			Position = UDim2.fromOffset(134, 20),
			BackgroundTransparency = 1,
			Parent = header,
		})
		local d = Controls.dropdown(group, {
			options = { "By name", "By date" },
			default = listSort[key],
			width = 185,
			height = 29,
			textSize = 14,
			padding = 10,
			chevron = 12,
		}, function(v)
			listSort[key] = v
			if key == "scripts" then
				rebuildScripts()
			else
				rebuildConfigs()
			end
		end)
		d.AnchorPoint = Vector2.new(0, 0)
		d.Position = UDim2.fromOffset(0, 0)
		local b, hit = Controls.button(group, "Create", "plus", 130, 29)
		b.Position = UDim2.fromOffset(185 + 23, 0)
		connect(hit.MouseButton1Click, function()
			if key == "configs" then
				prompt(b, "New config", "Config name", "Create", "", function(name)
					saveConfig(name)
				end)
			else
				prompt(b, "New script", "Script name", "Create", "", function(name)
					createScript(name)
				end)
			end
		end)
		headerWidgets[key] = group
	end

	-- search field (replaces the page widgets while searching)
	local searchField, searchBox = Controls.input(header, {
		Position = UDim2.fromOffset(134, 20),
		Size = UDim2.fromOffset(300, 29),
		placeholder = "Search settings",
		textSize = 14,
		padding = 10,
	})
	searchField.Visible = false
	local searching = false

	local headerIconButtons = {}
	local headerIcons = { { "discord", 20, 137 }, { "comments", 19, 100 }, { "gear", 16, 63 }, { "search", 16, 29 } }
	for _, info in ipairs(headerIcons) do
		local btn = hitbox({
			Name = info[1],
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(CONTENT_W - info[3] + 1, 35),
			Size = UDim2.fromOffset(24, 24),
			Parent = header,
		})
		local isDiscord = info[1] == "discord"
		local img = icon(info[1], info[2], isDiscord and Color3.new(1, 1, 1) or Theme.HeaderIcon, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Parent = btn,
		})
		local hint
		if isDiscord then
			btn:SetAttribute("Invite", "https://discord.gg/neverlose-rivals")
			btn.BackgroundColor3 = Theme.NavActive
			corner(4).Parent = btn
			hint = text({Name="DiscordHint",Text="Open Discord invite",TextSize=11,TextColor3=Theme.Label,TextXAlignment=Enum.TextXAlignment.Right,AnchorPoint=Vector2.new(1,0),Position=UDim2.fromOffset(CONTENT_W-125,53),Size=UDim2.fromOffset(160,14),Visible=false,Parent=header})
			connect(btn.MouseButton1Click, function()
				local invite = "https://discord.gg/neverlose-rivals"
				local opened = false
				local open = openurl or open_url
				if type(open) == "function" then
					local ok, result = pcall(open, invite)
					opened = ok and result ~= false
				end
				if not opened then
					local ok, result = pcall(function() return game:GetService("GuiService"):OpenBrowserWindow(invite) end)
					opened = ok and result ~= false
				end
				if opened then return end
				local copy = setclipboard or toclipboard
				if type(copy) == "function" and pcall(copy, invite) then
					notify("Discord", "Browser opening is blocked. Invite copied: discord.gg/neverlose-rivals")
				else
					local box
					openPanel(btn, "Discord invite", 310, function(rows)
						local _, input = Controls.input(rows, {Position=UDim2.fromOffset(10,4),Size=UDim2.fromOffset(290,25),text=invite,textSize=12})
						box = input
						return ROW_H
					end)
					task.defer(function()if box and box.Parent then box:CaptureFocus();box.SelectionStart=1;box.CursorPosition=#invite+1 end end)
				end
			end)
		end
		connect(btn.MouseEnter, function()
			if hint then hint.Visible=true;tween(btn,0.15,{BackgroundTransparency=0.3})else tween(img, 0.15, { ImageColor3 = Theme.NavIcon })end
		end)
		connect(btn.MouseLeave, function()
			if hint then hint.Visible=false;tween(btn,0.15,{BackgroundTransparency=1})else tween(img, 0.15, { ImageColor3 = Theme.HeaderIcon })end
		end)
		headerIconButtons[info[1]] = btn
	end

	local function updateHeaderWidgets()
		for k, w in pairs(headerWidgets) do
			w.Visible = (not searching) and k == currentPage
		end
		searchField.Visible = searching
	end

	---------------------------------------------------------------------------------------
	-- Search
	---------------------------------------------------------------------------------------
	local function flashRow(entry)
		local page = pages[entry.pageKey]
		local rowTop = (entry.row.AbsolutePosition.Y - page.AbsolutePosition.Y) / dpiScale + page.CanvasPosition.Y
		page.CanvasPosition = Vector2.new(0, math.max(0, rowTop - 90))
		local hl = frame({
			Name = "Flash",
			Position = UDim2.fromOffset(4, 1),
			Size = UDim2.new(1, -8, 1, -2),
			BackgroundColor3 = Theme.KnobOn,
			BackgroundTransparency = 0.7,
			ZIndex = 0,
			Parent = entry.row,
		}, { corner(4) })
		tween(hl, 1.4, { BackgroundTransparency = 1 })
		task.delay(1.5, function()
			hl:Destroy()
		end)
	end

	local function setSearching(on)
		searching = on
		if on then
			searchBox.Text = ""
			updateHeaderWidgets()
			searchBox:CaptureFocus()
		else
			closePopup()
			searchBox:ReleaseFocus()
			updateHeaderWidgets()
		end
	end

	local searchResults = {}
	local function goToResult(entry)
		setSearching(false)
		selectPage(entry.pageKey)
		task.delay(0.05, function()
			flashRow(entry)
		end)
	end

	local function showResults(query)
		closePopupsAbove(0)
		searchResults = {}
		query = query:lower()
		if query == "" then
			return
		end
		for _, entry in ipairs(Store.index) do
			local hay = (entry.label .. " " .. entry.group .. " " .. entry.pageTitle):lower()
			if hay:find(query, 1, true) then
				table.insert(searchResults, entry)
				if #searchResults >= 8 then
					break
				end
			end
		end
		local itemH = 36
		local h = math.max(1, #searchResults) * itemH + 6
		local list = frame({
			Name = "SearchResults",
			Position = popupPosition(searchField, 300, h),
			Size = UDim2.fromOffset(300, h),
			BackgroundColor3 = Theme.Popup,
			Parent = popupLayer,
		}, { corner(3), stroke(Theme.FieldStroke, 1) })
		if #searchResults == 0 then
			text({
				Text = "Nothing found",
				TextColor3 = Theme.Dim,
				TextSize = 13,
				Position = UDim2.fromOffset(10, 3),
				Size = UDim2.new(1, -20, 0, itemH),
				Parent = list,
			})
		end
		for i, entry in ipairs(searchResults) do
			local b = hitbox({
				Position = UDim2.fromOffset(3, 3 + (i - 1) * itemH),
				Size = UDim2.new(1, -6, 0, itemH),
				BackgroundColor3 = Theme.PopupHover,
				Parent = list,
			}, nil)
			corner(3).Parent = b
			text({
				Text = entry.label,
				FontFace = Fonts.Bold,
				TextSize = 13,
				TextColor3 = Theme.Title,
				Position = UDim2.fromOffset(8, 3),
				Size = UDim2.new(1, -16, 0, 16),
				Parent = b,
			})
			text({
				Text = entry.pageTitle .. "  ›  " .. entry.group,
				FontFace = Fonts.SemiBold,
				TextSize = 12,
				TextColor3 = Theme.Value,
				Position = UDim2.fromOffset(8, 18),
				Size = UDim2.new(1, -16, 0, 14),
				Parent = b,
			})
			connect(b.MouseEnter, function()
				b.BackgroundTransparency = 0
			end)
			connect(b.MouseLeave, function()
				b.BackgroundTransparency = 1
			end)
			connect(b.MouseButton1Click, function()
				goToResult(entry)
			end)
		end
		pushPopup(list, searchField, function()
			list:Destroy()
		end)
	end

	connect(searchBox:GetPropertyChangedSignal("Text"), function()
		if searching then
			showResults(searchBox.Text)
		end
	end)
	connect(searchBox.FocusLost, function(enter)
		if enter and searchResults[1] then
			goToResult(searchResults[1])
		elseif searchBox.Text == "" then
			setSearching(false)
		end
	end)
	connect(headerIconButtons.search.MouseButton1Click, function()
		setSearching(not searching)
	end)

	---------------------------------------------------------------------------------------
	-- Menu settings panel (header gear) and notification log (chat icon)
	---------------------------------------------------------------------------------------
	connect(headerIconButtons.gear.MouseButton1Click, function()
		local owner = headerIconButtons.gear
		if topOwner() == owner then
			closePopup()
			return
		end
		openPanel(owner, "Menu", 260, function(rows, handles, width)
			buildRow(rows, { "keybind", "Menu Key", "Delete" }, 1, width, SETTINGS, handles)
			buildRow(rows, { "dropdown", "DPI Scale", { "75%", "90%", "100%", "110%", "125%", "150%" }, 3 }, 2, width, SETTINGS, handles)
			buildRow(rows, { "color", "Accent Color", DEFAULT_ACCENT }, 3, width, SETTINGS, handles)
			buildRow(rows, { "toggle", "Background Blur", true }, 4, width, SETTINGS, handles)
			buildRow(rows, { "toggle", "Auto Execute", false }, 5, width, SETTINGS, handles)
			buildRow(rows, { "button", "Reset Accent", "Reset", callback = function()
				setValue(SETTINGS .. "/Accent Color", toHex(DEFAULT_ACCENT))
			end }, 6, width, SETTINGS, handles)
			buildRow(rows, { "button", "Unload Menu", "Unload", style = "danger", callback = function()
				api.unload()
			end }, 7, width, SETTINGS, handles)
			return ROW_H * 7
		end)
	end)

	connect(headerIconButtons.comments.MouseButton1Click, function()
		local owner = headerIconButtons.comments
		if topOwner() == owner then
			closePopup()
			return
		end
		openPanel(owner, "Notifications", 320, function(rows)
			local count = math.min(#history, 8)
			if count == 0 then
				text({ Text = "Nothing yet", TextColor3 = Theme.Dim, TextSize = 13, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 0, ROW_H), Parent = rows })
				return ROW_H
			end
			for i = 1, count do
				local item = history[i]
				text({
					RichText = true,
					Text = string.format('<font color="%s">%s</font>  <font color="%s"><b>%s</b></font>  %s', toHex(Theme.Dim), item.time, toHex(Theme.Title), item.title, item.body),
					TextColor3 = Theme.Label,
					TextSize = 13,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Size = UDim2.new(1, -20, 0, ROW_H),
					Position = UDim2.fromOffset(10, 0),
					LayoutOrder = i,
					Parent = frame({ Size = UDim2.new(1, 0, 0, ROW_H), BackgroundTransparency = 1, LayoutOrder = i, Parent = rows }),
				})
			end
			return count * ROW_H
		end)
	end)

	---------------------------------------------------------------------------------------
	-- Configs (workspace/neverlose_ui/configs/*.json)
	---------------------------------------------------------------------------------------
	local CONFIG_DIR = ROOT .. "/configs"
	ensureFolder(CONFIG_DIR)
	local function sanitize(name)
		name = tostring(name or ""):gsub("[^%w%s%-_%.]", ""):gsub("^%s+", ""):gsub("%s+$", "")
		return name ~= "" and name or nil
	end
	local function configFile(name)
		return CONFIG_DIR .. "/" .. name .. ".json"
	end
	local function readJson(path)
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(path))
		end)
		return ok and data or nil
	end
	local function listConfigs()
		local out = {}
		for _, f in ipairs(listfiles(CONFIG_DIR)) do
			local name = f:match("([^/\\]+)%.json$")
			if name then
				local data = readJson(f) or {}
				table.insert(out, { name = name, saved = tonumber(data.saved) or 0, author = data.author or "?" })
			end
		end
		table.sort(out, function(a, b)
			if listSort.configs == "By date" then
				return a.saved > b.saved
			end
			return a.name:lower() < b.name:lower()
		end)
		return out
	end

	local configAliases = {
		["World/View/Field of View"] = "World/View/Override FOV",
		["Anti Aim/Misc/Slow Walk"] = "Anti Aim/Movement/Slow Walk",
		["Players/Other/Footstep Sounds"] = "Players/Other/Footstep Indicators",
		["Main/Other/Hit Sound"] = "World/Effects/Hit Sound",
	}
	local function supportedConfig(values)
		local result = {}
		for key, value in pairs(values) do
			local path, context = key:match("^(.-)@([^@]+)$")
			path = path or key
			local original = path
			for old, new in pairs(configAliases) do
				if path == old or path:sub(1, #old + 1) == old .. "/" then path = new .. path:sub(#old + 1); break end
			end
			local page = Store.pageOf[path]
			local validContext = not context or page == "skins" and gameAdapter and table.find(gameAdapter.weaponChoices, context) or page == "players" and table.find({"Enemies", "Teammates", "Local"}, context) or page == "ragebot" and table.find({"Global", "Pistols", "Heavy Pistols", "Auto Snipers", "Scout", "AWP", "Rifles", "SMG"}, context)
			if Store.defaults[path] ~= nil and validContext then
				if gameAdapter and (path == "Ragebot/Selection/Hitboxes" or path == "Ragebot/Selection/Multipoint") and type(value) == "table" then
					local selected = {}
					for _, zone in ipairs(value) do
						zone = zone == "Head" and "Head" or "Body"
						if not table.find(selected, zone) then table.insert(selected, zone) end
					end
					value = selected
				elseif path == "Players/ESP/Flags" and type(value) == "table" then
					local flags, rename = {}, {Scoped="Aiming", Money="Credits", Ping="Local Ping"}
					for _, flag in ipairs(value) do
						flag = rename[flag] or flag
						if table.find({"Aiming", "Credits", "Local Ping", "Distance"}, flag) and not table.find(flags, flag) then table.insert(flags, flag) end
					end
					value = flags
				elseif path == "Anti Aim/Main/Yaw Base" and value == "At Targets" then
					value = "Away from Targets"
				elseif path == "Anti Aim/Movement/Slow Walk" then
					value = value == "Default" and "Slow" or value == "Slide" and "Slower" or value
				end
				local newKey = path .. (context and "@" .. context or "")
				if original == path or result[newKey] == nil then result[newKey] = value end
			end
		end
		return result
	end

	saveConfig = function(name, quiet)
		name = sanitize(name)
		if not name then
			notify("Config", "Enter a name first.", "error")
			return false
		end
		writefile(configFile(name), HttpService:JSONEncode({
			name = name,
			author = LocalPlayer.Name,
			saved = os.time(),
			values = supportedConfig(Store.values),
		}))
		currentConfig = name
		writefile(ROOT .. "/last_config.txt", name)
		if not quiet then
			notify("Config saved", name)
		end
		if rebuildConfigs then
			rebuildConfigs()
		end
		return true
	end

	loadConfig = function(name, quiet)
		local data = isfile(configFile(name)) and readJson(configFile(name))
		if not data or type(data.values) ~= "table" then
			notify("Config", "Couldn't read " .. tostring(name), "error")
			return false
		end
		Store.values = supportedConfig(data.values)
		currentConfig = name
		writefile(ROOT .. "/last_config.txt", name)
		refreshPaths()
		if not quiet then
			notify("Config loaded", name)
		end
		if rebuildConfigs then
			rebuildConfigs()
		end
		return true
	end

	rebuildConfigs = function()
		local inner = clearList(pages.configs)
		local list = listConfigs()
		if #list == 0 then
			emptyNote(inner, "No configs yet. Press Create or Save to make one.")
			return
		end
		for i, cfg in ipairs(list) do
			listCard(inner, i, {
				title = cfg.name,
				meta = { "Modified:", os.date("%d.%m %H:%M", cfg.saved), "Author:", cfg.author },
				loaded = cfg.name == currentConfig,
				loadedText = "Loaded",
				onLoad = function()
					loadConfig(cfg.name)
				end,
				onRename = function(newName)
					newName = sanitize(newName)
					if not newName then
						return
					end
					writefile(configFile(newName), readfile(configFile(cfg.name)))
					delfile(configFile(cfg.name))
					if currentConfig == cfg.name then
						currentConfig = newName
						writefile(ROOT .. "/last_config.txt", newName)
					end
					rebuildConfigs()
				end,
				onShare = function()
					if setclipboard then
						setclipboard(readfile(configFile(cfg.name)))
						notify("Copied", cfg.name .. " is on your clipboard.")
					end
				end,
				onCopy = function()
					local n = cfg.name .. " copy"
					while isfile(configFile(n)) do
						n = n .. "+"
					end
					writefile(configFile(n), readfile(configFile(cfg.name)))
					rebuildConfigs()
				end,
				onDelete = function()
					delfile(configFile(cfg.name))
					if currentConfig == cfg.name then
						currentConfig = nil
					end
					notify("Config deleted", cfg.name)
					rebuildConfigs()
				end,
			})
		end
	end

	---------------------------------------------------------------------------------------
	-- Scripts (workspace/neverlose_ui/scripts/*.lua): Load runs them with the menu API
	---------------------------------------------------------------------------------------
	local SCRIPT_DIR = ROOT .. "/scripts"
	local SCRIPT_META = ROOT .. "/scripts_meta.json"
	ensureFolder(SCRIPT_DIR)
	local scriptMeta = readJson(SCRIPT_META) or {}
	local function saveScriptMeta()
		writefile(SCRIPT_META, HttpService:JSONEncode(scriptMeta))
	end
	local function scriptFile(name)
		return SCRIPT_DIR .. "/" .. name .. ".lua"
	end
	local loadedScripts = {}

	local SCRIPT_TEMPLATE = [[
-- %s
-- Scripts in workspace/neverlose_ui/scripts appear on the Scripts page; press Load to run.
-- The menu API is available as getgenv().NeverloseMenu.
local menu = getgenv().NeverloseMenu

menu.notify("%s", "Script loaded")

-- react to a setting (paths are "Page/Group/Label")
menu.onChanged("World/Ambience/Night Mode", function(on)
	print("Night mode:", on)
end)

-- read a value at any time
print("Watermark is", menu.get("Main/Interface/Watermark") and "on" or "off")
]]

	createScript = function(name)
		name = sanitize(name)
		if not name then
			notify("Script", "Enter a name first.", "error")
			return
		end
		if not isfile(scriptFile(name)) then
			writefile(scriptFile(name), string.format(SCRIPT_TEMPLATE, name, name))
		end
		scriptMeta[name] = os.time()
		saveScriptMeta()
		notify("Script created", "workspace/" .. scriptFile(name))
		rebuildScripts()
	end

	local function listScripts()
		local out = {}
		for _, f in ipairs(listfiles(SCRIPT_DIR)) do
			local name, ext = f:match("([^/\\]+)%.(luau?)$")
			if name then
				local ok, src = pcall(readfile, f)
				table.insert(out, {
					name = name,
					file = f,
					modified = scriptMeta[name] or 0,
					lines = ok and select(2, src:gsub("\n", "\n")) + 1 or 0,
					ext = ext,
				})
			end
		end
		table.sort(out, function(a, b)
			if listSort.scripts == "By date" then
				return a.modified > b.modified
			end
			return a.name:lower() < b.name:lower()
		end)
		return out
	end

	local function runScript(entry)
		local ok, src = pcall(readfile, entry.file)
		if not ok then
			notify("Script", "Couldn't read " .. entry.name, "error")
			return
		end
		local fn, err = loadstring(src, "=" .. entry.name)
		if not fn then
			notify("Script error", tostring(err), "error")
			return
		end
		loadedScripts[entry.name] = true
		task.spawn(function()
			local okRun, runErr = pcall(fn)
			if not okRun then
				notify("Script error", entry.name .. ": " .. tostring(runErr), "error")
			end
		end)
		notify("Script loaded", entry.name)
		rebuildScripts()
	end

	rebuildScripts = function()
		local inner = clearList(pages.scripts)
		local list = listScripts()
		if #list == 0 then
			emptyNote(inner, "No scripts yet. Press Create, or drop .lua files into workspace/neverlose_ui/scripts.")
			return
		end
		for i, entry in ipairs(list) do
			listCard(inner, i, {
				title = entry.name,
				meta = {
					"Modified:",
					entry.modified > 0 and os.date("%d.%m %H:%M", entry.modified) or "-",
					"Lines:",
					tostring(entry.lines),
				},
				loaded = loadedScripts[entry.name],
				loadedText = "Run",
				onLoad = function()
					runScript(entry)
				end,
				onRename = function(newName)
					newName = sanitize(newName)
					if not newName then
						return
					end
					writefile(scriptFile(newName), readfile(entry.file))
					delfile(entry.file)
					scriptMeta[newName], scriptMeta[entry.name] = os.time(), nil
					saveScriptMeta()
					rebuildScripts()
				end,
				onShare = function()
					if setclipboard then
						setclipboard(readfile(entry.file))
						notify("Copied", entry.name .. " source is on your clipboard.")
					end
				end,
				onCopy = function()
					local n = entry.name .. " copy"
					while isfile(scriptFile(n)) do
						n = n .. "+"
					end
					writefile(scriptFile(n), readfile(entry.file))
					scriptMeta[n] = os.time()
					saveScriptMeta()
					rebuildScripts()
				end,
				onDelete = function()
					delfile(entry.file)
					scriptMeta[entry.name] = nil
					saveScriptMeta()
					notify("Script deleted", entry.name)
					rebuildScripts()
				end,
			})
		end
	end

	-- first run: drop an example in so the page isn't empty
	if #listfiles(SCRIPT_DIR) == 0 then
		writefile(scriptFile("example"), string.format(SCRIPT_TEMPLATE, "example", "Example script"))
		scriptMeta.example = os.time()
		saveScriptMeta()
	end

	---------------------------------------------------------------------------------------
	-- HUD: watermark and keybind list (drag them while the menu is open)
	---------------------------------------------------------------------------------------
	local function makeDraggable(handle, target)
		local dragStart, startPos
		connect(handle.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and holder.Visible then
				dragStart = input.Position
				startPos = target.Position
			end
		end)
		connect(UserInputService.InputChanged, function(input)
			if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
				local d = input.Position - dragStart
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragStart = nil
			end
		end)
	end

	local watermark = frame({
		Name = "Watermark",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Theme.Group,
		Active = true,
		Visible = false,
		Parent = hud,
	}, {
		corner(4),
		stroke(Theme.FieldStroke, 1),
		create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	text({
		Text = "NEVERLOSE",
		FontFace = Fonts.Logo,
		TextSize = 13,
		TextColor3 = Theme.Logo,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 26),
		LayoutOrder = 1,
		Parent = watermark,
	})
	local watermarkInfo = text({
		RichText = true,
		FontFace = Fonts.SemiBold,
		TextSize = 13,
		TextColor3 = Theme.Label,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 26),
		LayoutOrder = 2,
		Parent = watermark,
	})
	makeDraggable(watermark, watermark)

	local keybindPanel = frame({
		Name = "Keybinds",
		Position = UDim2.new(0, 16, 0.42, 0),
		Size = UDim2.fromOffset(190, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Group,
		Active = true,
		Visible = false,
		Parent = hud,
	}, {
		corner(4),
		stroke(Theme.FieldStroke, 1),
		create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
		create("UIPadding", { PaddingBottom = UDim.new(0, 5) }),
	})
	local keybindTitle = frame({ Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = 0, Parent = keybindPanel })
	text({
		Text = "Keybinds",
		FontFace = Fonts.Bold,
		TextSize = 14,
		TextColor3 = Theme.Title,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		Parent = keybindTitle,
	})
	frame({ Position = UDim2.new(0, 5, 1, -2), Size = UDim2.new(1, -10, 0, 2), BackgroundColor3 = Theme.Line, Parent = keybindTitle })
	makeDraggable(keybindPanel, keybindPanel)

	local keybindCount = 0
	local function updateKeybindVisibility()
		keybindPanel.Visible = getValue("Main/Interface/Keybind List") == true and (keybindCount > 0 or holder.Visible)
	end
	local function refreshKeybindList()
		for _, child in ipairs(keybindPanel:GetChildren()) do
			if child.Name == "Entry" then
				child:Destroy()
			end
		end
		local count = 0
		for path, labelText in pairs(Store.binds) do
			local key = getValue(path .. "/Key")
			local mode = getValue(path .. "/Mode")
			local active = getValue(path) == true
			if key and key ~= "None" and mode ~= "Always" and active then
				count += 1
				local entry = frame({ Name = "Entry", Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = count, Parent = keybindPanel })
				text({ Text = labelText, TextSize = 13, TextColor3 = Theme.Label, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -90, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = entry })
				text({
					Text = "[" .. (mode == "Hold" and "holding" or "toggled") .. "]",
					TextSize = 12,
					TextColor3 = Theme.Value,
					TextXAlignment = Enum.TextXAlignment.Right,
					Position = UDim2.new(1, -90, 0, 0),
					Size = UDim2.fromOffset(80, 22),
					Parent = entry,
				})
			end
		end
		keybindCount = count
		updateKeybindVisibility()
	end
	table.insert(Store.any, function(path)
		if Store.binds[path] or path:find("/Key$") or path:find("/Mode$") or path == "Main/Interface/Keybind List" then
			task.defer(refreshKeybindList)
		end
	end)

	local fps, fpsFrames, fpsTime = 60, 0, 0
	connect(RunService.RenderStepped, function(dt)
		fpsFrames += 1
		fpsTime += dt
		if fpsTime >= 0.5 then
			fps = math.floor(fpsFrames / fpsTime + 0.5)
			fpsFrames, fpsTime = 0, 0
		end
	end)
	local Stats = cloneref(game:GetService("Stats"))
	local function pingMs()
		local ok, v = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		if ok and v then
			return math.floor(v + 0.5)
		end
		local ok2, p = pcall(function()
			return LocalPlayer:GetNetworkPing() * 2000
		end)
		return ok2 and math.floor(p + 0.5) or 0
	end
	task.spawn(function()
		while not gui:GetAttribute("Unloaded") do
			watermark.Visible = getValue("Main/Interface/Watermark") == true
			if watermark.Visible then
				local sep = string.format('<font color="%s">|</font>', toHex(Theme.Dim))
				watermarkInfo.Text = table.concat({
					LocalPlayer.Name,
					sep,
					fps .. " fps",
					sep,
					pingMs() .. " ms",
					sep,
					os.date("%H:%M"),
				}, " ")
			end
			task.wait(0.5)
		end
	end)

	---------------------------------------------------------------------------------------
	-- Local visual features
	---------------------------------------------------------------------------------------
	local colorFx = create("ColorCorrectionEffect", { Name = "NeverloseColor", Enabled = false, Parent = camera })
	local disabledFx = {}

	local function applyColorFx()
		local brightness = getValue("World/Ambience/Brightness") or 100
		local tint = getValue("World/Ambience/World Color") or "#FFFFFF"
		colorFx.Brightness = (brightness - 100) / 250
		colorFx.TintColor = fromHex(tint)
		colorFx.Enabled = brightness ~= 100 or tint:upper() ~= "#FFFFFF"
	end
	onChanged("World/Ambience/Brightness", applyColorFx)
	onChanged("World/Ambience/World Color", applyColorFx)
	onChanged("World/Ambience/Night Mode", function(on)
		Lighting.ClockTime = on and 0 or original.ClockTime
	end)
	onChanged("World/Ambience/Ambient Light", function(hex)
		Lighting.Ambient = hex:upper() == defaultAmbient:upper() and original.Ambient or fromHex(hex)
	end)
	local function applyFog()
		local on = getValue("World/Ambience/Fog") == true
		local c = fromHex(getValue("World/Ambience/Fog/Color"))
		if on then
			Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor = 0, 260, c
			if atmosphere then
				atmosphere.Density, atmosphere.Color = 0.55, c
			end
		else
			Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor = original.FogStart, original.FogEnd, original.FogColor
			if atmosphere then
				atmosphere.Density, atmosphere.Color = original.AtmosphereDensity, original.AtmosphereColor
			end
		end
	end
	onChanged("World/Ambience/Fog", applyFog)
	onChanged("World/Ambience/Fog/Color", applyFog)
	onChanged("World/Removals/Remove Shadows", function(on)
		Lighting.GlobalShadows = (not on) and original.GlobalShadows or false
	end)
	onChanged("World/Removals/Removals", function(list)
		local removePost = table.find(list or {}, "Post Processing") ~= nil
		if removePost then
			for _, fx in ipairs(Lighting:GetChildren()) do
				if fx:IsA("PostEffect") and fx.Enabled and not disabledFx[fx] then
					disabledFx[fx] = true
					fx.Enabled = false
				end
			end
		else
			for fx in pairs(disabledFx) do
				if fx.Parent then
					fx.Enabled = true
				end
			end
			disabledFx = {}
		end
	end)
	onChanged("World/View/Override FOV", function(v)
		local cam = workspace.CurrentCamera
		if not gameAdapter and cam then cam.FieldOfView = math.clamp(tonumber(v) or defaultFov, 30, 120) end
	end)
	connect(RunService.RenderStepped, function()
		local cam = workspace.CurrentCamera
		if not gameAdapter and cam then
			local fov = math.clamp(tonumber(getValue("World/View/Override FOV")) or defaultFov, 30, 120)
			if cam.FieldOfView ~= fov then cam.FieldOfView = fov end
		end
		if getValue("World/Ambience/Night Mode") == true and Lighting.ClockTime ~= 0 then
			Lighting.ClockTime = 0
		end
	end)

	table.insert(cleanups, function()
		Lighting.ClockTime = original.ClockTime
		Lighting.Ambient = original.Ambient
		Lighting.FogStart, Lighting.FogEnd, Lighting.FogColor = original.FogStart, original.FogEnd, original.FogColor
		Lighting.GlobalShadows = original.GlobalShadows
		if atmosphere then
			atmosphere.Density, atmosphere.Color = original.AtmosphereDensity, original.AtmosphereColor
		end
		for fx in pairs(disabledFx) do
			if fx.Parent then
				fx.Enabled = true
			end
		end
		if not gameAdapter and workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = original.FieldOfView
		end
		colorFx:Destroy()
	end)

	---------------------------------------------------------------------------------------
	-- Menu settings: accent colour, DPI scale
	---------------------------------------------------------------------------------------
	local ORIGINAL_THEME = {}
	for k, v in pairs(Theme) do
		ORIGINAL_THEME[k] = v
	end
	local ACCENT_KEYS = { "KnobOn", "TrackOn", "TrackOnStroke", "SliderFill", "SliderKnob", "Button", "TabActive", "NavActive", "Link" }
	local function applyAccent(c)
		if toHex(c) == toHex(DEFAULT_ACCENT) then
			for _, k in ipairs(ACCENT_KEYS) do
				Theme[k] = ORIGINAL_THEME[k]
			end
		else
			local black, white = Color3.new(0, 0, 0), Color3.new(1, 1, 1)
			Theme.KnobOn = c
			Theme.TrackOn = c:Lerp(black, 0.72)
			Theme.TrackOnStroke = c:Lerp(black, 0.55)
			Theme.SliderFill = c:Lerp(black, 0.1)
			Theme.SliderKnob = c:Lerp(white, 0.15)
			Theme.Button = c:Lerp(black, 0.2)
			Theme.TabActive = c:Lerp(black, 0.58)
			Theme.NavActive = c:Lerp(black, 0.7)
			Theme.Link = c
		end
		for _, fn in ipairs(Store.rerender) do
			pcall(fn)
		end
	end
	onChanged(SETTINGS .. "/Accent Color", function(hex)
		applyAccent(fromHex(hex))
	end)
	onChanged(SETTINGS .. "/DPI Scale", function(v)
		dpiScale = (tonumber(tostring(v):match("%d+")) or 100) / 100
		holderScale.Scale = dpiScale
		closePopup()
	end)

	local function buildPreview()
		---------------------------------------------------------------------------------------
		-- ESP preview: a panel beside the window on the Players page that shows the current
		-- ESP / chams / glow settings on the game's own operator, drawn the same way the live ESP
		-- draws them. The operator template is cloned into a ViewportFrame, holds the AR15 and plays
		-- the game's idle. A low wall stands in front of its legs. The visible chams recolour the
		-- model's own parts; the hidden colour is a second, identical copy in a ViewportFrame that is
		-- clipped to the wall's rectangle on screen, which is exactly how the in-game chams work.
		-- The box and skeleton are projected from the clone's animated body parts. Nothing here
		-- reads or touches live players.
		---------------------------------------------------------------------------------------
		local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
		local PREVIEW_SOURCE = {
			model = { "Assets", "Operators", "Operator1" },
			-- the baked world model holds every attachment variant; keep one per category
			weapon = {
				model = { "Assets", "WorldModelsBaked", "AR15" },
				label = "AR15",
				attachments = {
					Barrels = "Barrel145M4",
					Handguards = "M4Handguard",
					MuzzleDevices = "A2FlashHider",
					Magazine = "STANAG30",
					Stocks = "StockMagpul",
					PistolGrips = "GripA2",
					Optics = "ACOG4x",
				},
			},
			-- the game's own standing idle
			animation = { "Assets", "CharacterSelectorStuff", "OperatorIdle" },
		}
		local function resolvePath(path)
			local node = ReplicatedStorage
			for _, name in ipairs(path) do
				node = node and node:FindFirstChild(name)
			end
			return node
		end
		local templateModel = resolvePath(PREVIEW_SOURCE.model)
		local idle = resolvePath(PREVIEW_SOURCE.animation)
		if gameAdapter then
			templateModel, idle = gameAdapter.avatarTemplate()
			if templateModel then table.insert(cleanups,function()templateModel:Destroy();if idle then idle:Destroy()end end)end
		end

		local PV_W, PV_H = 300, WIN_H
		local STAGE_W, STAGE_H = PV_W - 20, PV_H - 64
		local preview = create("CanvasGroup", {
			Name = "ESPPreview",
			GroupTransparency = 1,
			Position = UDim2.fromOffset(WIN_W + 12, 0),
			Size = UDim2.fromOffset(PV_W, PV_H),
			BackgroundColor3 = Theme.Content,
			Active = true,
			Visible = false,
			Parent = holder,
		}, { corner(WIN_RADIUS) })
		text({ Text = "ESP Preview", FontFace = Fonts.Bold, TextSize = 15, TextColor3 = Theme.Title, Position = UDim2.fromOffset(16, 0), Size = UDim2.fromOffset(150, 44), Parent = preview })
		local pvContext = text({
			Text = "",
			TextSize = 13,
			TextColor3 = Theme.Value,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -136, 0, 0),
			Size = UDim2.fromOffset(120, 44),
			Parent = preview,
		})
		frame({ Position = UDim2.fromOffset(6, 44), Size = UDim2.new(1, -12, 0, 2), BackgroundColor3 = Theme.Line, Parent = preview })
		local stage = frame({
			Name = "Stage",
			Position = UDim2.fromOffset(10, 54),
			Size = UDim2.fromOffset(STAGE_W, STAGE_H),
			BackgroundColor3 = rgb(7, 12, 20),
			ClipsDescendants = true,
			Parent = preview,
		}, { corner(6) })

		-- the same look as the live overlay: Arial with a hard black outline, black-white-black box
		local ESP_FONT, ESP_BOLD = Font.fromEnum(Enum.Font.Arial), Font.fromEnum(Enum.Font.ArialBold)
		local BLACK, WHITE = Color3.new(0, 0, 0), Color3.new(1, 1, 1)
		local function espText(size, bold, z)
			return create("TextLabel", {
				BackgroundTransparency = 1,
				FontFace = bold and ESP_BOLD or ESP_FONT,
				TextSize = size,
				TextColor3 = WHITE,
				TextStrokeTransparency = 0,
				TextStrokeColor3 = BLACK,
				ZIndex = z or 6,
				Parent = stage,
			})
		end
		local function outlined(color, z)
			local f = frame({ BackgroundTransparency = 1, ZIndex = z or 5, Parent = stage })
			local s = create("UIStroke", { Color = color, Thickness = 1, Parent = f })
			pcall(function()
				s.BorderStrokePosition = Enum.BorderStrokePosition.Inner
			end)
			return f, s
		end

		-- 3D: the model world and the clipped hidden layer
		local function newViewport(parent, z)
			local vp = create("ViewportFrame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(STAGE_W, STAGE_H),
				Ambient = rgb(150, 152, 162),
				LightColor = rgb(255, 252, 245),
				LightDirection = Vector3.new(-0.45, -1, -0.6),
				ZIndex = z,
				Parent = parent,
			})
			local world = create("WorldModel", { Parent = vp })
			local cam = create("Camera", { FieldOfView = 24, Parent = vp })
			vp.CurrentCamera = cam
			return { vp = vp, world = world, cam = cam }
		end
		local mainView = newViewport(stage, 2)
		local hiddenClip = frame({ Name = "HiddenLayer", BackgroundTransparency = 1, ClipsDescendants = true, Visible = false, ZIndex = 3, Parent = stage })
		local hiddenView = newViewport(hiddenClip, 3)

		local R15 = {
			"Head", "UpperTorso", "LowerTorso",
			"LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand",
			"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot",
		}
		local BOX_PARTS = { "Head", "UpperTorso", "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot" }
		local function equipWeapon(model, world)
			if gameAdapter then return nil end
			local cfg = PREVIEW_SOURCE.weapon
			local src = resolvePath(cfg.model)
			local torso = model:FindFirstChild("UpperTorso", true)
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if not (src and torso and humanoid) then
				return nil
			end
			local gun = src:Clone()
			gun.Name = "PreviewWeapon"
			local all = gun:FindFirstChild("AllAttachments")
			if all then
				for _, category in ipairs(all:GetChildren()) do
					local keep = cfg.attachments[category.Name]
					for _, variant in ipairs(category:GetChildren()) do
						if variant.Name ~= keep then
							variant:Destroy()
						end
					end
				end
			end
			for _, d in ipairs(gun:GetDescendants()) do
				if d:IsA("Motor6D") or d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("LuaSourceContainer") then
					d:Destroy()
				end
			end
			local root = gun.PrimaryPart or gun:FindFirstChild("RootPart")
			local fire = root and root:FindFirstChild("HandRef_Fire")
			local support = root and root:FindFirstChild("HandRef_Support")
			if not (root and fire and support) then
				gun:Destroy()
				return nil
			end
			gun.Parent = world
			-- size the rifle to the operator: about twice the width of the torso
			local _, size = gun:GetBoundingBox()
			gun:ScaleTo(torso.Size.X * 2.1 / math.max(size.X, size.Y, size.Z))
			-- shoulder it: the "fire" hand reference lands on the right of the chest, barrel pointing forward
			local fireTarget = torso.CFrame:PointToWorldSpace(Vector3.new(1.05, 0.15, -1.2))
			local rootCF = CFrame.new(fireTarget) * (torso.CFrame.Rotation * CFrame.Angles(0, math.rad(4), 0))
			gun:PivotTo(rootCF * gun:GetPivot():ToObjectSpace(root.CFrame):Inverse())
			gun:PivotTo(gun:GetPivot() + (fireTarget - fire.WorldPosition))
			for _, d in ipairs(gun:GetDescendants()) do
				if d:IsA("BasePart") then
					d.Anchored = false
					d.CanCollide = false
					d.CanQuery = false
					d.CanTouch = false
					d.Massless = true
					if d ~= root then
						create("WeldConstraint", { Part0 = root, Part1 = d, Parent = d })
					end
				end
			end
			create("WeldConstraint", { Part0 = torso, Part1 = root, Parent = root })
			-- invisible elbow hints so the elbows tuck down instead of flaring out
			local function pole(offset)
				local p = create("Part", {
					Size = Vector3.new(0.2, 0.2, 0.2),
					Transparency = 1,
					CanCollide = false,
					CanQuery = false,
					CanTouch = false,
					Massless = true,
					CFrame = torso.CFrame * CFrame.new(offset),
					Parent = model,
				})
				create("WeldConstraint", { Part0 = torso, Part1 = p, Parent = p })
				return p
			end
			local function arm(upper, hand, target, poleOffset)
				create("IKControl", {
					Type = Enum.IKControlType.Position,
					ChainRoot = model:FindFirstChild(upper, true),
					EndEffector = model:FindFirstChild(hand, true),
					Target = target,
					Pole = pole(poleOffset),
					Weight = 1,
					SmoothTime = 0,
					Parent = humanoid,
				})
			end
			arm("RightUpperArm", "RightHand", fire, Vector3.new(3.0, -1.8, 0.6))
			arm("LeftUpperArm", "LeftHand", support, Vector3.new(-3.0, -2.0, -0.8))
			return gun
		end
		local function buildRig(view)
			if not templateModel then
				return nil
			end
			local ok, rig = pcall(function()
				local model = templateModel:Clone()
				if gameAdapter then
					local collection=game:GetService('CollectionService');local nodes=model:GetDescendants();table.insert(nodes,model)
					for _,node in ipairs(nodes)do for _,tag in ipairs(collection:GetTags(node))do collection:RemoveTag(node,tag)end end
				end
				for _, d in ipairs(model:GetDescendants()) do
					if gameAdapter and (d:IsA('BasePart')or d:IsA('Decal'))then d.LocalTransparencyModifier=0 end
					if d:IsA("LuaSourceContainer") or d:IsA("BillboardGui") or d:IsA("Sound") then
						d:Destroy()
					end
				end
				model.Parent = view.world
				model:PivotTo(CFrame.new(0, 0, 0))
				local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
				if root then
					root.Anchored = true
				end
				local hum = model:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.EvaluateStateMachine = false
					hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				end
				local body = {}
				for _, n in ipairs(R15) do
					body[n] = model:FindFirstChild(n, true)
				end
				local gun = equipWeapon(model, view.world)
				-- every visible surface, rifle included, remembers how it looked
				local parts = {}
				local function collect(root)
					for _, d in ipairs(root:GetDescendants()) do
						if d:IsA("BasePart") and d.Transparency < 0.1 then
							local sas = {}
							for _, c in ipairs(d:GetChildren()) do
								if c:IsA("SurfaceAppearance") then
									table.insert(sas, c)
								end
							end
							table.insert(parts, {
								part = d,
								color = d.Color,
								material = d.Material,
								variant = d.MaterialVariant,
								transparency = d.Transparency,
								reflectance = d.Reflectance,
								tex = d:IsA("MeshPart") and d.TextureID or nil,
								sas = sas,
							})
						end
					end
				end
				collect(model)
				if gun then
					collect(gun)
				end
				local track
				local animator = model:FindFirstChildWhichIsA("Animator", true)
				if animator and idle and idle:IsA("Animation") then
					local okTrack, t = pcall(function()
						return animator:LoadAnimation(idle)
					end)
					if okTrack and t then
						t.Looped = true
						t:Play(0)
						track = t
					end
				end
				return { view = view, model = model, gun = gun, body = body, parts = parts, track = track }
			end)
			return ok and rig or nil
		end
		local rigMain = buildRig(mainView)
		local rigHidden = rigMain and buildRig(hiddenView) or nil
		if rigMain and not (rigHidden and next(rigMain.body)) then
			rigMain.model:Destroy()
			rigMain = nil
		end
		if not rigMain then
			mainView.vp.Visible = false
			text({
				Text = gameAdapter and "Player model unavailable" or "Operator model unavailable",
				TextSize = 12,
				TextColor3 = Theme.Dim,
				TextXAlignment = Enum.TextXAlignment.Center,
				Position = UDim2.fromOffset(0, STAGE_H / 2 - 7),
				Size = UDim2.fromOffset(STAGE_W, 14),
				Parent = stage,
			})
		end

		-- the same chams recipe as the live ESP
		local MATERIALS = {
			Flat = Enum.Material.SmoothPlastic,
			Glow = Enum.Material.Neon,
			Metallic = Enum.Material.Metal,
			Foil = Enum.Material.Foil,
			Marble = Enum.Material.Marble,
			Glass = Enum.Material.Glass,
			Forcefield = Enum.Material.ForceField,
		}
		local function paintRig(rig, on, color, mode, opacity)
			if gameAdapter then gameAdapter.paintCosmetics(rig.model,on,true)end
			for _, e in ipairs(rig.parts) do
				local p = e.part
				if not on then
					p.Color, p.Material, p.Transparency, p.Reflectance = e.color, e.material, e.transparency, e.reflectance
					p.MaterialVariant=e.variant or ""
					for _, sa in ipairs(e.sas) do
						if sa.Parent ~= p then
							sa.Parent = p
						end
					end
					if e.tex then
						p.TextureID = e.tex
					end
				else
					for _, sa in ipairs(e.sas) do
						sa.Parent = nil
					end
					if e.tex then
						p.TextureID = ""
					end
					p.Material = MATERIALS[mode] or MATERIALS.Flat
					if gameAdapter then p.MaterialVariant="" end
					p.Color = mode == "Glow" and color:Lerp(BLACK, 0.3) or color
					p.Reflectance = mode == "Metallic" and 0.35 or 0
					local t = e.transparency + (1 - opacity) * (1 - e.transparency)
					if mode == "Glass" then
						t = math.max(t, 0.55)
					end
					p.Transparency = t
				end
			end
		end

		-- camera framing from the resting pose; the wall and floor are placed from the same numbers
		local orbit
		local wall, floor
		if rigMain then
			local lo, hi
			for _, part in pairs(rigMain.body) do
				local s = part.Size / 2
				for ix = -1, 1, 2 do
					for iy = -1, 1, 2 do
						for iz = -1, 1, 2 do
							local p = part.CFrame:PointToWorldSpace(Vector3.new(s.X * ix, s.Y * iy, s.Z * iz))
							lo = lo and Vector3.new(math.min(lo.X, p.X), math.min(lo.Y, p.Y), math.min(lo.Z, p.Z)) or p
							hi = hi and Vector3.new(math.max(hi.X, p.X), math.max(hi.Y, p.Y), math.max(hi.Z, p.Z)) or p
						end
					end
				end
			end
			local height = hi.Y - lo.Y
			local root = rigMain.model.PrimaryPart or rigMain.body.UpperTorso
			local facing = root.CFrame.LookVector
			local center = (lo + hi) / 2
			-- the model fills about half the stage, a little below the middle so the name has room
			local viewHeight = height / 0.52
			orbit = {
				center = center + Vector3.new(0, height * 0.04, 0),
				ground = Vector3.new(center.X, lo.Y, center.Z),
				height = height,
				-- yaw that puts the camera in front of the operator
				front = math.atan2(facing.X, -facing.Z),
				dist = viewHeight / (2 * math.tan(math.rad(24 / 2))),
			}
			wall = create("Part", {
				Name = "Cover",
				Anchored = true,
				CanCollide = false,
				Material = Enum.Material.Concrete,
				Color = rgb(78, 86, 98),
				Size = Vector3.new(height * 0.72, height * 0.42, 0.4),
				Parent = mainView.world,
			})
			create("Part", {
				Name = "CoverCap",
				Anchored = true,
				CanCollide = false,
				Material = Enum.Material.Concrete,
				Color = rgb(104, 112, 125),
				Size = Vector3.new(height * 0.72 + 0.12, 0.12, 0.55),
				Parent = wall,
			})
			floor = create("Part", {
				Name = "Floor",
				Anchored = true,
				CanCollide = false,
				Shape = Enum.PartType.Cylinder,
				Material = Enum.Material.SmoothPlastic,
				Color = rgb(16, 23, 34),
				Size = Vector3.new(0.1, height * 1.3, height * 1.3),
				CFrame = CFrame.new(orbit.ground - Vector3.new(0, 0.05, 0)) * CFrame.Angles(0, 0, math.rad(90)),
				Parent = mainView.world,
			})
		end
		-- the camera orbits the model; dragging the stage changes viewYaw (front three-quarter view)
		local DEFAULT_YAW = (orbit and orbit.front or 0) + math.rad(32)
		local viewYaw = DEFAULT_YAW
		local function applyYaw()
			if not orbit then
				return
			end
			local toCamera = Vector3.new(math.sin(viewYaw), 0, -math.cos(viewYaw))
			local camCF = CFrame.lookAt(orbit.center + toCamera * orbit.dist + Vector3.new(0, orbit.height * 0.04, 0), orbit.center)
			-- pan right a little so the model sits left of centre and the flags fit beside it
			camCF = camCF + camCF.RightVector * (orbit.height * 0.07)
			mainView.cam.CFrame = camCF
			hiddenView.cam.CFrame = camCF
			-- the wall always stands between the camera and the legs
			local base = orbit.ground + toCamera * (orbit.height * 0.28)
			local mid = base + Vector3.new(0, wall.Size.Y / 2, 0)
			wall.CFrame = CFrame.lookAt(mid, mid + toCamera)
			wall.CoverCap.CFrame = wall.CFrame * CFrame.new(0, wall.Size.Y / 2 + 0.06, 0)
		end
		applyYaw()

		-- projects a world point through the preview camera into stage pixels
		local function project(worldPoint)
			local cam = mainView.cam
			local rel = cam.CFrame:PointToObjectSpace(worldPoint)
			if rel.Z >= -0.05 then
				return nil
			end
			local t = math.tan(math.rad(cam.FieldOfView) / 2)
			local nx = rel.X / (-rel.Z * t * (STAGE_W / STAGE_H))
			local ny = rel.Y / (-rel.Z * t)
			return Vector2.new((nx * 0.5 + 0.5) * STAGE_W, (0.5 - ny * 0.5) * STAGE_H)
		end

		-- ESP elements around the player (positioned by layout())
		local auras = {}
		for k = 1, 4 do
			local f, s = outlined(WHITE, 4)
			s.Thickness = 3
			corner(3 + k * 2).Parent = f
			auras[k] = { frame = f, stroke = s }
		end
		local boxOuter = outlined(BLACK, 5)
		local boxMain, boxMainStroke = outlined(WHITE, 5)
		local boxInner = outlined(BLACK, 5)
		local pvName = espText(13, false)
		pvName.Text = LocalPlayer.DisplayName
		pvName.TextXAlignment = Enum.TextXAlignment.Center

		local HEALTH = 78
		local hpBack = frame({ BackgroundColor3 = BLACK, ZIndex = 5, Parent = stage })
		local hpFill = frame({
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 1, 1, -1),
			BackgroundColor3 = rgb(235, 70, 70):Lerp(rgb(90, 225, 110), HEALTH / 100),
			ZIndex = 5,
			Parent = hpBack,
		})
		local hpText = espText(10, true)
		hpText.Text = tostring(HEALTH)
		hpText.TextXAlignment = Enum.TextXAlignment.Right

		local AMMO = 0.8
		local ammoBack = frame({ BackgroundColor3 = BLACK, ZIndex = 5, Parent = stage })
		local ammoFill = frame({ Position = UDim2.fromOffset(1, 1), BackgroundColor3 = WHITE, ZIndex = 5, Parent = ammoBack })

		local pvWeaponText = espText(12, false)
		pvWeaponText.Text = gameAdapter and gameAdapter.nativeItem() and gameAdapter.nativeItem().Name or PREVIEW_SOURCE.weapon.label
		pvWeaponText.TextXAlignment = Enum.TextXAlignment.Center
		-- weapon icon: the game's own gunsmith model, like the live ESP
		local pvWeaponIcon = create("ViewportFrame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(60, 22),
			Ambient = WHITE,
			LightColor = BLACK,
			ZIndex = 6,
			Parent = stage,
		})
		do
			local src = resolvePath(PREVIEW_SOURCE.weapon.model)
			if src and src:IsA("Model") then
				local ok = pcall(function()
					-- the same flat white silhouette the live ESP draws, with this preview's attachments
					local clone = src:Clone()
					local all = clone:FindFirstChild("AllAttachments")
					if all then
						for _, slot in ipairs(all:GetChildren()) do
							local keep = PREVIEW_SOURCE.weapon.attachments[slot.Name]
							for i, variant in ipairs(slot:GetChildren()) do
								if (keep and variant.Name ~= keep) or (not keep and i > 1) then
									variant:Destroy()
								end
							end
						end
					end
					for _, d in ipairs(clone:GetDescendants()) do
						if d:IsA("Sound") or d:IsA("LuaSourceContainer") or d:IsA("ParticleEmitter") or d:IsA("Light") or d:IsA("SurfaceAppearance") or d:IsA("Decal") then
							d:Destroy()
						elseif d:IsA("BasePart") then
							d.Anchored, d.Color, d.Material = true, WHITE, Enum.Material.SmoothPlastic
							if d:IsA("MeshPart") then
								d.TextureID = ""
							end
						end
					end
					clone.Parent = pvWeaponIcon
					local cf, size = clone:GetBoundingBox()
					local camera = create("Camera", { FieldOfView = 25, Parent = pvWeaponIcon })
					-- side view: look along the weapon's thinnest axis
					local direction = cf.RightVector
					if size.Y < size.X and size.Y < size.Z then
						direction = cf.UpVector
					elseif size.Z < size.X and size.Z < size.Y then
						direction = cf.LookVector
					end
					camera.CFrame = CFrame.lookAt(cf.Position - direction * math.max(size.Magnitude * 1.4, 1), cf.Position)
					pvWeaponIcon.CurrentCamera = camera
				end)
				if not ok then
					pvWeaponIcon:ClearAllChildren()
				end
			end
		end

		local nativeWeaponIcon
		local nativeWeaponName
		if gameAdapter then
			nativeWeaponName = gameAdapter.nativeItem() and gameAdapter.nativeItem().Name
			nativeWeaponIcon = create("ImageLabel",{Name="NativeWeaponIcon",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit,Image=gameAdapter.weaponIcon(nativeWeaponName) or "",Parent=pvWeaponIcon})
		end

		local FLAGS = {
			{ "Aiming", "AIM", rgb(255, 205, 100) },
			{ "Credits", "58 IC", rgb(135, 225, 115) },
			{ "Local Ping", "38 MS", rgb(255, 130, 130) },
			{ "Distance", "12M", rgb(190, 200, 215) },
		}
		local flagLabels = {}
		for i, f in ipairs(FLAGS) do
			local l = espText(10, true)
			l.Text = f[2]
			l.TextColor3 = f[3]
			l.TextXAlignment = Enum.TextXAlignment.Left
			l.Size = UDim2.fromOffset(70, 11)
			flagLabels[i] = l
		end

		local BONES = {
			{ "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
			{ "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
			{ "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
			{ "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
			{ "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
		}
		local boneLines = {}
		for i = 1, #BONES do
			boneLines[i] = frame({ AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = WHITE, Visible = false, ZIndex = 5, Parent = stage })
		end
		local ring = frame({ AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Visible = false, ZIndex = 4, Parent = stage }, { corner(UDim.new(1, 0)) })
		local ringStroke = create("UIStroke", { Color = WHITE, Thickness = 2, Parent = ring })

		text({
			Text = rigMain and "Drag to rotate" or "",
			TextSize = 11,
			TextColor3 = Theme.Dim,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.fromOffset(0, STAGE_H - 22),
			Size = UDim2.fromOffset(STAGE_W, 14),
			ZIndex = 6,
			Parent = stage,
		})

		local state = { flags = {}, ammo = false, icon = false, text = false, skeleton = false, ring = false, glow = false, glowStyle = "Default", hidden = false }
		local function pv(path)
			return getValue("Players/" .. path)
		end
		local function layout(x, y, w, h)
			boxOuter.Position, boxOuter.Size = UDim2.fromOffset(x - 1, y - 1), UDim2.fromOffset(w + 2, h + 2)
			boxMain.Position, boxMain.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(w, h)
			boxInner.Position, boxInner.Size = UDim2.fromOffset(x + 1, y + 1), UDim2.fromOffset(w - 2, h - 2)
			pvName.Position, pvName.Size = UDim2.fromOffset(x - 60, y - 20), UDim2.fromOffset(w + 120, 17)
			local fillH = math.floor(h * HEALTH / 100 + 0.5)
			hpBack.Position, hpBack.Size = UDim2.fromOffset(x - 8, y - 1), UDim2.fromOffset(5, h + 2)
			hpFill.Size = UDim2.new(1, -2, 0, fillH)
			hpText.Position, hpText.Size = UDim2.fromOffset(x - 38, y + h - fillH - 6), UDim2.fromOffset(26, 14)
			local bottom = y + h + 3
			ammoBack.Position, ammoBack.Size = UDim2.fromOffset(x - 1, bottom), UDim2.fromOffset(w + 2, 5)
			ammoFill.Size = UDim2.new(AMMO, -2, 1, -2)
			if state.ammo then
				bottom += 7
			end
			pvWeaponIcon.Position = UDim2.fromOffset(math.floor(x + w / 2 - 30), bottom - 1)
			if state.icon then
				bottom += 21
			end
			pvWeaponText.Position, pvWeaponText.Size = UDim2.fromOffset(x - 60, bottom - 1), UDim2.fromOffset(w + 120, 16)
			local row = 0
			for i, label in ipairs(flagLabels) do
				if state.flags[i] then
					label.Position = UDim2.fromOffset(x + w + 5, y + row * 11 - 1)
					row += 1
				end
			end
			for k, a in ipairs(auras) do
				local pad = 2 + k * 3
				a.frame.Position, a.frame.Size = UDim2.fromOffset(x - pad, y - pad), UDim2.fromOffset(w + pad * 2, h + pad * 2)
			end
			ring.Position = UDim2.fromOffset(x + w / 2, y + h)
		end

		local function refreshPreview()
			pvContext.Text = Store.contexts.players or ""
			-- chams
			local mode = pv("Chams/Material")
			if not MATERIALS[mode] then
				mode = "Flat"
			end
			local opacity = math.clamp((tonumber(pv("Chams/Opacity")) or 100) / 100, 0.1, 1)
			if rigMain then
				paintRig(rigMain, pv("Chams/Visible") == true, fromHex(pv("Chams/Visible/Color")), mode, opacity)
				paintRig(rigHidden, true, fromHex(pv("Chams/Through Walls/Color")), mode, opacity)
			end
			state.hidden = pv("Chams/Through Walls") == true
			-- glow rings around the box
			state.glow = pv("Glow/Enabled") == true
			state.glowStyle = pv("Glow/Style")
			local glowColor = fromHex(pv("Glow/Enabled/Color"))
			for _, a in ipairs(auras) do
				a.frame.Visible = state.glow
				a.stroke.Color = glowColor
			end
			-- box, name, health
			local boxOn = pv("ESP/Bounding Box") == true
			boxOuter.Visible, boxMain.Visible, boxInner.Visible = boxOn, boxOn, boxOn
			boxMainStroke.Color = fromHex(pv("ESP/Bounding Box/Color"))
			pvName.Visible = pv("ESP/Name") == true
			pvName.TextColor3 = fromHex(pv("ESP/Name/Color"))
			local hpOn = pv("ESP/Health Bar") == true
			hpBack.Visible, hpText.Visible = hpOn, hpOn
			-- ammo and weapon stack under the box
			state.ammo = pv("ESP/Ammo") == true
			ammoBack.Visible = state.ammo
			ammoFill.BackgroundColor3 = fromHex(pv("ESP/Ammo/Color"))
			local weaponMode = pv("ESP/Weapon")
			state.icon = (weaponMode == "Icon" or weaponMode == "Text + Icon") and (nativeWeaponIcon and nativeWeaponIcon.Image~="" or pvWeaponIcon.CurrentCamera ~= nil)
			state.text = weaponMode == "Text" or weaponMode == "Text + Icon"
			pvWeaponIcon.Visible = state.icon
			pvWeaponText.Visible = state.text
			-- flags down the right side of the box
			local selected = pv("ESP/Flags") or {}
			for i, f in ipairs(FLAGS) do
				local on = table.find(selected, f[1]) ~= nil
				state.flags[i] = on
				flagLabels[i].Visible = on
			end
			-- skeleton and footstep ring
			state.skeleton = pv("ESP/Skeleton") == true
			local skColor = fromHex(pv("ESP/Skeleton/Color"))
			for _, l in ipairs(boneLines) do
				l.Visible = state.skeleton and rigMain ~= nil
				l.BackgroundColor3 = skColor
			end
			state.ring = pv("Other/Footstep Indicators") == true
			ringStroke.Color = fromHex(pv("Other/Footstep Indicators/Color"))
			ring.Visible = state.ring
			if not rigMain then
				layout(math.floor(STAGE_W / 2 - 60), math.floor(STAGE_H / 2 - 130), 120, 260)
			end
		end

		local function placeLine(line, a, b)
			local d = b - a
			line.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
			line.Size = UDim2.fromOffset(d.Magnitude, 1)
			line.Rotation = math.deg(math.atan2(d.Y, d.X))
		end
		local function step3D()
			-- the hidden copy follows the visible one frame for frame
			if rigMain.track and rigHidden.track then
				local t = rigMain.track.TimePosition
				if math.abs(rigHidden.track.TimePosition - t) > 0.02 then
					rigHidden.track.TimePosition = t
				end
			end
			-- hidden layer: clipped to the wall's rectangle on screen
			if state.hidden then
				local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
				local s = wall.Size / 2
				for ix = -1, 1, 2 do
					for iy = -1, 1, 2 do
						for iz = -1, 1, 2 do
							local q = project(wall.CFrame:PointToWorldSpace(Vector3.new(s.X * ix, s.Y * iy, s.Z * iz)))
							if q then
								x0, y0, x1, y1 = math.min(x0, q.X), math.min(y0, q.Y), math.max(x1, q.X), math.max(y1, q.Y)
							end
						end
					end
				end
				x0, y0 = math.max(math.floor(x0), 0), math.max(math.floor(y0), 0)
				x1, y1 = math.min(math.ceil(x1), STAGE_W), math.min(math.ceil(y1), STAGE_H)
				hiddenClip.Visible = x1 > x0 and y1 > y0
				hiddenClip.Position, hiddenClip.Size = UDim2.fromOffset(x0, y0), UDim2.fromOffset(math.max(x1 - x0, 0), math.max(y1 - y0, 0))
				hiddenView.vp.Position = UDim2.fromOffset(-x0, -y0)
			else
				hiddenClip.Visible = false
			end
			-- box from the body (not the arms or rifle), padded like the live ESP
			local lo, hi
			for _, name in ipairs(BOX_PARTS) do
				local part = rigMain.body[name]
				if part then
					local cf, s = part.CFrame, part.Size / 2
					for ix = -1, 1, 2 do
						for iy = -1, 1, 2 do
							for iz = -1, 1, 2 do
								local p = cf:PointToWorldSpace(Vector3.new(s.X * ix, s.Y * iy, s.Z * iz))
								lo = lo and Vector3.new(math.min(lo.X, p.X), math.min(lo.Y, p.Y), math.min(lo.Z, p.Z)) or p
								hi = hi and Vector3.new(math.max(hi.X, p.X), math.max(hi.Y, p.Y), math.max(hi.Z, p.Z)) or p
							end
						end
					end
				end
			end
			if lo then
				local pad = Vector3.new(0.15, 0.12, 0.15)
				lo, hi = lo - pad, hi + pad
				local cx, cz = (lo.X + hi.X) / 2, (lo.Z + hi.Z) / 2
				local hx, hz = math.max((hi.X - lo.X) / 2 * 0.88, 0.95), math.max((hi.Z - lo.Z) / 2 * 0.88, 0.95)
				local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
				for _, x in ipairs({ cx - hx, cx + hx }) do
					for _, y in ipairs({ lo.Y, hi.Y + 0.1 }) do
						for _, z in ipairs({ cz - hz, cz + hz }) do
							local q = project(Vector3.new(x, y, z))
							if q then
								minX, minY = math.min(minX, q.X), math.min(minY, q.Y)
								maxX, maxY = math.max(maxX, q.X), math.max(maxY, q.Y)
							end
						end
					end
				end
				if minX < maxX then
					layout(math.floor(minX + 0.5), math.floor(minY + 0.5), math.floor(maxX - minX + 0.5), math.floor(maxY - minY + 0.5))
				end
			end
			if state.skeleton then
				for i, bone in ipairs(BONES) do
					local a, b = rigMain.body[bone[1]], rigMain.body[bone[2]]
					local pa, pb = a and project(a.Position), b and project(b.Position)
					boneLines[i].Visible = pa ~= nil and pb ~= nil
					if pa and pb then
						placeLine(boneLines[i], pa, pb)
					end
				end
			end
		end

		-- drag the stage to turn the model around; double-click resets the view
		if rigMain then
			local rotateHit = hitbox({ Name = "RotateHit", Size = UDim2.fromScale(1, 1), ZIndex = 7, Parent = stage })
			local dragging, lastX, lastClick = false, 0, 0
			connect(rotateHit.MouseButton1Down, function()
				if os.clock() - lastClick < 0.3 then
					viewYaw = DEFAULT_YAW
					applyYaw()
				end
				lastClick = os.clock()
				dragging = true
				lastX = UserInputService:GetMouseLocation().X
			end)
			connect(UserInputService.InputChanged, function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local x = UserInputService:GetMouseLocation().X
					viewYaw += (x - lastX) * math.rad(0.6)
					lastX = x
					applyYaw()
				end
			end)
			connect(UserInputService.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
		end

		local pvDirty = true
		table.insert(Store.any, function(path)
			if path:sub(1, 8) == "Players/" then
				pvDirty = true
			end
		end)
		connect(RunService.RenderStepped, function()
			if not (preview.Visible and holder.Visible) then
				return
			end
			if gameAdapter then
				local weapon=gameAdapter.nativeItem();local name=weapon and weapon.Name
				if name~=nativeWeaponName then
					nativeWeaponName=name;nativeWeaponIcon.Image=gameAdapter.weaponIcon(name) or "";pvWeaponText.Text=name or "";pvDirty=true
				end
			end
			if pvDirty then
				pvDirty = false
				refreshPreview()
			end
			if rigMain then
				step3D()
			end
			local t = os.clock()
			if state.glow then
				local pulse = 0.5 + 0.5 * math.sin(t * 3.2)
				for k, a in ipairs(auras) do
					local base = state.glowStyle == "Outline" and (k == 1 and 0.1 or k == 2 and 0.55 or 1) or (0.5 + k * 0.11)
					a.stroke.Transparency = state.glowStyle == "Pulse" and math.clamp(base + (1 - pulse) * 0.4, 0, 1) or base
				end
			end
			if state.ring then
				local k = (t % 1.5) / 1.5
				local w = 24 + k * 120
				ring.Size = UDim2.fromOffset(w, w * 0.2)
				ringStroke.Transparency = 0.2 + k * 0.8
			end
		end)

		return preview, function()
			pvDirty = true
		end
	end
	local preview, markPreviewDirty = buildPreview()

	---------------------------------------------------------------------------------------
	-- Navigation
	---------------------------------------------------------------------------------------
	selectPage = function(key, instant)
		if not pages[key] then
			return
		end
		if currentPage == key then
			return
		end
		closePopup()
		currentPage = key
		for k, nb in pairs(navButtons) do
			local active = k == key
			nb.label.TextColor3 = active and Theme.NavTextActive or Theme.NavText
			nb.icon.ImageColor3 = active and Theme.NavIconActive or Theme.NavIcon
		end
		local target = UDim2.fromOffset(9, navButtons[key].y)
		if instant then
			navHighlight.Position = target
		else
			tween(navHighlight, 0.2, { Position = target })
		end
		for k, page in pairs(pages) do
			page.Visible = k == key
		end
		updateHeaderWidgets()
		preview.Visible = key == "players"
		markPreviewDirty()
		if key == "scripts" then
			rebuildScripts()
		elseif key == "configs" then
			rebuildConfigs()
		end
		local page = pages[key]
		page.CanvasPosition = Vector2.zero
		if not instant then
			local inner = page:FindFirstChild("Inner")
			if inner then
				inner.Position = UDim2.fromOffset(0, 8)
				tween(inner, 0.22, { Position = UDim2.fromOffset(0, 0) })
			end
		end
	end
	for key, nb in pairs(navButtons) do
		connect(nb.button.MouseButton1Click, function()
			selectPage(key)
		end)
		connect(nb.button.MouseEnter, function()
			if currentPage ~= key then
				tween(nb.label, 0.12, { TextColor3 = Color3.new(1, 1, 1) })
			end
		end)
		connect(nb.button.MouseLeave, function()
			if currentPage ~= key then
				tween(nb.label, 0.12, { TextColor3 = Theme.NavText })
			end
		end)
	end

	---------------------------------------------------------------------------------------
	-- Show/hide, dragging, keybinds
	---------------------------------------------------------------------------------------
	-- The custom camera can re-lock the cursor every frame, so release it after
	-- camera/input updates while the menu is visible. Restore the captured state
	-- when closing or unloading.
	local mouseState
	local mouseBinding = "NeverloseMenuMouse"
	local function restoreMenuMouse()
		if mouseState then
			UserInputService.MouseBehavior = mouseState.behavior
			UserInputService.MouseIconEnabled = mouseState.icon
			mouseState = nil
		end
	end
	local function releaseMenuMouse()
		if not mouseState then
			mouseState = {
				behavior = UserInputService.MouseBehavior,
				icon = UserInputService.MouseIconEnabled,
			}
		end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end
	RunService:BindToRenderStep(mouseBinding, Enum.RenderPriority.Last.Value + 10, function()
		if menuOpen then releaseMenuMouse() else restoreMenuMouse() end
	end)
	table.insert(cleanups, function()
		RunService:UnbindFromRenderStep(mouseBinding)
		restoreMenuMouse()
	end)
	local menuTweens = {}
	local menuTransition = 0
	local function setMenuVisible(v)
		v = v == true
		if menuOpen == v then return end
		menuOpen = v
		mouseUnlock.Modal = v
		menuTransition += 1
		local transition = menuTransition
		for _,animation in ipairs(menuTweens) do animation:Cancel() end
		table.clear(menuTweens)
		closePopup()
		if v then
			holder.Visible = true
			releaseMenuMouse()
		else
			restoreMenuMouse()
			if searching then setSearching(false) end
		end
		local target = v and 1 or 0
		local duration = math.max(0.06, (v and 0.18 or 0.14) * math.abs(target - menuMotion.Value))
		table.insert(menuTweens, tween(menuMotion, duration, { Value = target }, Enum.EasingStyle.Cubic))
		table.insert(menuTweens, tween(window, duration, { GroupTransparency = 1 - target }, Enum.EasingStyle.Cubic))
		table.insert(menuTweens, tween(preview, duration, { GroupTransparency = 1 - target }, Enum.EasingStyle.Cubic))
		if not v then
			task.delay(duration, function()
				if transition == menuTransition and not menuOpen then holder.Visible = false; updateKeybindVisibility() end
			end)
		end
		updateKeybindVisibility()
	end
	table.insert(cleanups, function()
		menuTransition += 1
		for _,animation in ipairs(menuTweens) do animation:Cancel() end
		menuMotion:Destroy()
	end)

	local dragStart, startPos
	local function beginDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragStart = input.Position
			startPos = menuBasePosition
		end
	end
	connect(logoArea.InputBegan, beginDrag)
	connect(header.InputBegan, beginDrag)
	connect(UserInputService.InputChanged, function(input)
		if dragStart and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - dragStart
			menuBasePosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			applyMenuMotion()
			if d.Magnitude > 3 then
				closePopup()
			end
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragStart = nil
		end
	end)

	connect(UserInputService.InputBegan, function(input)
		if UserInputService:GetFocusedTextBox() or os.clock() < Store.captureUntil then
			return
		end
		local name = keyName(input)
		if not name then
			return
		end
		if name == getValue(SETTINGS .. "/Menu Key") then
			setMenuVisible(not menuOpen)
			return
		end
		for path in pairs(Store.binds) do
			if getValue(path .. "/Key") == name then
				local mode = getValue(path .. "/Mode")
				if mode == "Toggle" then
					setValue(path, not getValue(path))
				elseif mode == "Hold" then
					Store.held[path] = true
					setValue(path, true)
				end
			end
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		local name = keyName(input)
		if not name then
			return
		end
		for path in pairs(Store.held) do
			if getValue(path .. "/Key") == name then
				Store.held[path] = nil
				setValue(path, false)
			end
		end
	end)

	---------------------------------------------------------------------------------------
	-- Acrylic blur behind the sidebar
	--
	-- Roblox can't blur behind a GUI directly. Instead a nearly invisible Glass part is
	-- kept right in front of the camera, exactly covering the sidebar on screen. Glass
	-- writes to the depth buffer, so a DepthOfField effect that only blurs things closer
	-- than ~1.6 studs blurs every pixel the part covers, i.e. the game behind the sidebar.
	-- Needs graphics quality high enough for post effects; otherwise it simply stays sharp.
	---------------------------------------------------------------------------------------
	local BLUR_DEPTH = 0.5
	local BLUR_INSET = 3 -- keeps the square part inside the sidebar's rounded corners
	local blurRegion = frame({
		Name = "BlurRegion",
		Position = UDim2.fromOffset(BLUR_INSET, BLUR_INSET),
		Size = UDim2.fromOffset(SIDEBAR_W - BLUR_INSET, WIN_H - BLUR_INSET * 2),
		BackgroundTransparency = 1,
		Parent = window,
	})
	local blurPart, blurDof
	local function clearBlur()
		if blurPart then
			blurPart:Destroy()
			blurPart = nil
		end
		if blurDof then
			blurDof:Destroy()
			blurDof = nil
		end
	end
	local function buildBlur(cam)
		clearBlur()
		for _, name in ipairs({ "NeverloseBlur", "NeverloseBlurDoF" }) do
			local old = cam:FindFirstChild(name)
			if old then
				old:Destroy()
			end
		end
		blurDof = create("DepthOfFieldEffect", {
			Name = "NeverloseBlurDoF",
			FarIntensity = 0,
			FocusDistance = 51.6,
			InFocusRadius = 50,
			NearIntensity = 1,
			Parent = cam,
		})
		blurPart = create("Part", {
			Name = "NeverloseBlur",
			Material = Enum.Material.Glass,
			Color = Color3.new(0, 0, 0),
			Transparency = 0.98,
			Anchored = true,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CastShadow = false,
			Size = Vector3.new(1, 1, 0.001),
			Parent = cam,
		})
	end
	local function worldAt(cam, screenPos)
		local ray = cam:ScreenPointToRay(screenPos.X, screenPos.Y, 0)
		return ray.Origin + ray.Direction * (BLUR_DEPTH / ray.Direction:Dot(cam.CFrame.LookVector))
	end
	connect(RunService.RenderStepped, function()
		local cam = workspace.CurrentCamera
		if not cam then
			return
		end
		if not blurPart or blurPart.Parent ~= cam then
			buildBlur(cam)
		end
		local shown = holder.Visible and getValue(SETTINGS .. "/Background Blur") == true
		local opacity = shown and menuMotion.Value or 0
		blurDof.Enabled = opacity > 0.001
		blurDof.NearIntensity = opacity
		blurPart.Transparency = 1 - 0.02 * opacity
		if opacity <= 0.001 then
			return
		end
		local ap, as = blurRegion.AbsolutePosition, blurRegion.AbsoluteSize
		local tl = worldAt(cam, ap)
		local tr = worldAt(cam, ap + Vector2.new(as.X, 0))
		local bl = worldAt(cam, ap + Vector2.new(0, as.Y))
		local center = worldAt(cam, ap + as / 2)
		blurPart.Size = Vector3.new((tr - tl).Magnitude, (bl - tl).Magnitude, 0.001)
		blurPart.CFrame = CFrame.lookAt(center, center + cam.CFrame.LookVector, cam.CFrame.UpVector)
	end)
	table.insert(cleanups, clearBlur)

	---------------------------------------------------------------------------------------
	-- Start-up
	---------------------------------------------------------------------------------------
	if setthreadidentity then setthreadidentity(8) end
	gui.Parent = guiParent
	api.adapter = gameAdapter
	api.ui = { status = function() return { fontsReady = fontCache.ready, fontWarmups = fontCache.warmups, fontError = fontCache.lastError, open = menuOpen, progress = menuMotion.Value, scale = holderScale.Scale } end }
	api.esp = installLiveESP(gui, Store, connect, cleanups, gameAdapter)
	api.world = installWorldVisuals(getValue, connect, cleanups, gameAdapter)
	api.ragebot = installRagebot(Store, connect, cleanups, function() return menuOpen end, function(title, body) notify(title, body) end, gameAdapter)
	api.legitbot = installLegitbot(Store, connect, cleanups, function() return menuOpen end, gameAdapter)
	api.antiaim = installAntiAim(getValue, connect, cleanups, function() return menuOpen end, function(title, body) notify(title, body) end, gameAdapter)
	api.movement = installMovement(getValue, connect, cleanups, function() return menuOpen end, gameAdapter)
	api.autovote = installAutoVote(getValue, connect, cleanups, gameAdapter)
	if gameAdapter then api.models=installCustomModels(pages.models,gameAdapter,getValue,connect,cleanups,function()return menuOpen end,function(title,body)notify(title,body)end)end

	-- reload the last used config, if any
	if isfile(ROOT .. "/last_config.txt") then
		local last = readfile(ROOT .. "/last_config.txt")
		if last ~= "" and isfile(configFile(last)) then
			loadConfig(last, true)
		end
	end
	if reloadValues then
		Store.values = supportedConfig(reloadValues)
		for path,callbacks in pairs(Store.controls)do for _,apply in ipairs(callbacks)do apply(getValue(path))end;fire(path,getValue(path))end
	end
	-- Migrate the previous default in existing saved configurations.
	if getValue(SETTINGS .. "/Menu Key") == "Insert" then
		setValue(SETTINGS .. "/Menu Key", "Delete")
	end
	refreshPaths()
	selectPage(pages[env.NeverloseStartPage] and env.NeverloseStartPage or "ragebot", true)
	refreshKeybindList()
	setMenuVisible(true)

	---------------------------------------------------------------------------------------
	-- Public API: getgenv().NeverloseMenu
	---------------------------------------------------------------------------------------
	local contextOptions = {
		skins = gameAdapter and gameAdapter.weaponChoices or nil,
		players = {"Enemies", "Teammates", "Local"},
		ragebot = {"Global", "Pistols", "Heavy Pistols", "Auto Snipers", "Scout", "AWP", "Rifles", "SMG"},
	}
	api.snapshot = function()local values={};for k,v in pairs(Store.values)do values[k]=copyValue(v)end;return values end
	api.restoreSnapshot = function(values)
		assert(type(values) == "table", "snapshot must be a table")
		Store.values = supportedConfig(values)
		refreshPaths()
	end
	api.get = function(path, context)
		if not context then return getValue(path) end
		local page = Store.pageOf[path]
		if not contextOptions[page] or not table.find(contextOptions[page], context) then error("invalid setting context", 2) end
		local value = Store.values[path .. "@" .. context]
		if value == nil and page == "ragebot" then value = Store.values[path .. "@Global"] end
		if value == nil then value = Store.defaults[path] end
		return copyValue(value)
	end
	api.set = function(path, value, context)
		if Store.defaults[path] == nil then error("unknown setting: " .. tostring(path), 2) end
		if context then
			local page = Store.pageOf[path]
			if not contextOptions[page] or not table.find(contextOptions[page], context) then error("invalid setting context", 2) end
			if context ~= Store.contexts[page] then
				Store.values[path .. "@" .. context] = copyValue(value)
				fire(path, value)
				return
			end
		end
		setValue(path, value)
	end
	api.onChanged = onChanged
	api.onAnyChanged = function(fn)
		table.insert(Store.any, fn)
		return {
			Disconnect = function()
				local i = table.find(Store.any, fn)
				if i then
					table.remove(Store.any, i)
				end
			end,
		}
	end
	api.paths = function()
		local list = {}
		for path in pairs(Store.defaults) do
			table.insert(list, path)
		end
		table.sort(list)
		return list
	end
	api.notify = function(title, body)
		notify(tostring(title), body and tostring(body) or "")
	end
	api.select = function(key)
		selectPage(key)
	end
	api.toggle = function()
		setMenuVisible(not menuOpen)
	end
	api.show = function(v)
		setMenuVisible(v ~= false)
	end
	api.saveConfig = function(name)
		return saveConfig(name or currentConfig or "default")
	end
	api.loadConfig = loadConfig
	api.configs = function()
		local names = {}
		for _, c in ipairs(listConfigs()) do
			table.insert(names, c.name)
		end
		return names
	end
	api.unload = function()
		if gui:GetAttribute("Unloaded") then
			return
		end
		gui:SetAttribute("Unloaded", true)
		for _, c in ipairs(connections) do
			pcall(function()
				c:Disconnect()
			end)
		end
		for i = #cleanups, 1, -1 do
			pcall(cleanups[i])
		end
		closePopup()
		gui:Destroy()
		if env.NeverloseMenu == api then
			env.NeverloseMenu = nil
			env.NeverloseMenuCleanups = nil
		end
	end
	api.destroy = api.unload
	-- Native controllers can resume callers at game identity. Keep protected UI work local
	-- to these API calls and restore the caller's identity even if a control throws.
	for _,name in ipairs({'set','select','toggle','show','loadConfig','saveConfig','unload','destroy','notify','restoreSnapshot'})do
		local originalCall=api[name]
		api[name]=function(...)
			local prior=getthreadidentity and getthreadidentity()
			if setthreadidentity then setthreadidentity(8)end
			local result=table.pack(pcall(originalCall,...))
			if setthreadidentity and prior then setthreadidentity(prior)end
			if not result[1]then error(result[2],0)end
			return table.unpack(result,2,result.n)
		end
	end
	env.NeverloseMenu = api
	api._jobId = game.JobId
	api.isAlive = function() return gui.Parent ~= nil and not gui:GetAttribute("Unloaded") end
	api.autoexecute = installAutoExecute(api, connect, cleanups, env, ROOT, STARTUP_SOURCE)
	env.NeverloseTeleportValues = nil
	return api
end

ICON_DATA = {
	["discord_20"] = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAIPElEQVR4nO1Ya4xkVRH+6pxzb3fPo9ldsxsGjRgeLg4mahYFJWQmGjSYGIx6dxZ5CLLMiogbQ0yIId5t/qohkURkwFcEYaZJjNEgmBB2ogEUCf5aMwqRGGBcWNidfkx333tPff64PTM93TMwK/DDZL+kk053narvVNWpqnOAUziF/0OQlCiiBShbkD4J2f+dksQxzURM91a0rOiIY5qtrnmTXVEmJmDn5yXr/fXK6cYYYc6t4fhf62NnJAAwCWivzOIi7MLCYe46a8/2Qql4Vr3ZXPjNL7afWFNNifbCVKvi3wLBHHFM89wr6R7v0y+IyKeo/tzS0Mi2Vqtx8MGZ0R++0dp9+5fuLw6Vv9xuNf4jxjwjsI9Zg0d+eVfx71uxvTFBUuJDkBdeOFHOSqVrlfyKQD7sggLUe2RZC8YE6n3nKERmRcwu0p++olJIUuQlCE5A+XURY42xYl0JIkCWLntA5j39zHljI1UAqFSEALglgtEcbXWv+Kn9S78eHi1/vtNK4H2bIDwBIwIBIWIcgnAIIMA+1dLNsqRTX7FLAAqCEHHODSEoWCzXl+LZn2y7PYpoNwr3AMEVwanpE58O3OijWdpMANjuZ8DVIHxXy3pd7HpDZKODRYBexELEgEjHH7i7/FwcQyoVWZfLfaeJMj4OXnXL4rCo/RE1I0m3Mbncek5AHCB23UfEbUKuuxlx1EysKzr1/AEgPHJk0GHrCE7EsJWKaFob2l8ojZzts5YXkS2XhJOGGJsmDR+Go5+bOlCfrFbF5zVzY4Iyfwg+ihmScnOWJiTeQXKryPOTXmMwj+CGBCdiWojQvljbWyyMnu2zlr6j3luF2CRpMnClyX0HlvZUKqK9XlwlMNkttCr8htITsnmJJKkA/eDZ3VgaoM/XbEIRVOsCUs3VAICo9z/khbhSEb3qQONDnvIs6Vf/6yNGEcC5YYEYZGkDJDf1NKlqjDPWDYGaIctaKgIzqJo0JhTvk9eHt5ff99PvST3v3ZL3xMNdT2aeXwzCIUGXYZ8xWhuKsQVJs+bf0qTxJCDqXNGQOuBJUhmEo4aqy2lS/5P37X8E4agBhIP1WMT7jgbh8I7l15cuBoAoyjkZoLeP8kIqAemvaaS1BQLyqmp22ew9p31k9t7yJyz8RaR/3rmS9IaQVA3CEfG+/RhtcP7svaddUpbRD2rWutHaUAAzEG6BqDGWNHI5ALwynnMwAKVSEb3qa/VdBC/OsvYq8VWDAI0NDLV144MzI49Ec7QTE3T337Pt6UybV5DMVqJMQq0tiM/aL9tm7fLZu0svRBHtzBj8r2aGf5xl7TvCcMSA6tfboFFVAeUCAJivwAOAWXGlV/t+54aGVROi54SQUOsKJu00FrMztv02imire6Hz85JNxI+7uXt2Pu2zzrMuGDIAvYDqgqJ49b+7776x5vTdDKpV8dERSBTRGmNm0nRZIcagJ9YiIt53AMHu626u7eymgpgVV6qm51jnIOjvh1xpCMerFUnyfpnzn8SkAhQROS59TcmKvBTHNAsv5yTm5qDVKrRgXdP71IuYvpMioj7VwJVG222MA3keut2Lz8h8LvGB/rzIl0HUtynWnXnl9Ctj54ztPHoYMLuOgEeOAFFUFeIz56km3VQCSMKrXlSpiEbdAXXvIThAknZy4vxCYTRI04bP22KPLUCNdSZJeSaQ56FbGNuTu5ly+kYEARFq5sPiacOdRG+tVOQgeobTqRuWDobByHt7DaZJU50rXDq1//VLZivyx65oEsexWXjZ3UYMnvpeGEhh5ftqMxeDTQspxNikXdcgKH1z33S9rMjuJJg6BNeI2FvStKXoPVhUIdUaW/z9vuml2+jlUWOwa2HRxC4oXZwmDRWRTQYQgCLvBoDdi8+ImwR0HgDI91AxWGJWScJk6TKDQvnaLF2+FiBcMIw0qaNbVHtkRagZxbjhICjfkbJGY4sixqFLbssttGcckvSNRUkAPunUKAIHiKRJrRvWDfYkImTGNKkpYGyWtRWAFxHpbmjTXio9TnKH89AogGNi4EEopH/+I4wJJQiLznsiS+vMa19+JLoEB/rX2tY0ExEXhKPGGCDpLIPMBpcQJKEAXgOAhbE9a9c/gi8GAWy+aq3VkVTrSlBN/9JZrh30vvOUMYEUimUXBGUrJpDuGpLU7iBBQCTfVNkWimUnYrM0aTzcai/dROi/jQ1XotI1pF6MOOdghHxp1ZsABTEkehVDNl3+rnXBt0Uc0qSuIiAAI2IgYo8D8nOlzhlIgSKXCvlRgheQfoexoRgTAADUJ1BNFcAxY9yfKXiKyj8AmRUENwgwRfphdgcoEhIWysb7TlM1/U4ZI3eNjcFXKqIDeTC1v3aJMe526wqTgCBN6ppPG4ENC0PI0hSSNc+6797t/wKA67/FHe1WZ2eadbYbFw7lDLVGtTU1y0erMzuWAGDqhqXLSqXyw94DadIA6b2ImCAoC6nwPnlI0bl1dmbb8+vysScBJIrWLtJXHGh8VuBuMcZ90hiLTqemYThi0qQx65fKV9ZP/6e7cMe5af8lpx8TE4+73bsnpVl4rZS1wyecK+5W33FBOIIsbYPgY6R+/8GZkUeAtUvbBgRzxDFN5RAIEQLAvgOtSy3kagi/pKqNYsGf/7M7R48hhqAimj+LQNZfeKoYH49YqYCAcMXoFV9d+rgplJ6gZkcF5iGluf+BmfDJFbsA8GYbXkUU0YJrDz7XTLfOjq47Nr7i7S0pWYd8TXT9sY9dfRPf1euQ/ovSSSGKaNcreAuvVD0bjiLak3lEelPEMc3boTCK5t7pp7hTOIW3Ff8FzUhS6El49rUAAAAASUVORK5CYII=",
	["models_14"] = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABGklEQVR4nIXRMWtVQRAF4LN5L2DSBNRWU9uq2NsqdsFgSG9lESGQnxCsQjory/wBeWBlY+WPsBFiISSNGgnmfRbOfblcvMnCsjNn5uycmUmuOWgDfzKahD18xpMB/uB/pEm9z3GCHZzhTuGH5W8lydKAPE1ylkSS9SQ/kszrU7072tcLzHBvgD/s7E57K/tlkmdJbpaa8yTfkrxrrc0qd6m1Nu/kBa8xxy728RPbOPDv3MdkMVU0rOE39gp7jC89iR/xqXIv14ENHGMVy9jEd6xgikc16bud3I64jNu9fX0oeVu9+K0FYWSiT2tfR/hapDaW3KrxGzjF28L/YL+r2ucsSrfWLpKsJnmf5E3Br5L8KvtiVOZQxVXxv/qBJnaLgsQ4AAAAAElFTkSuQmCC",
	["antiaim_14"] = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABLklEQVR4nG2SPS+EQRSFn313164QoSM6GoktRLXNVhq9RKPT+A06/0Ch0mkQrWgQnVon4qMREqESUfjcR+EOk5ebTCZz7jkzc8+9FZWIClAAxv6R4VXgM3LfYAgLoMvfqOTknFeLZBItx80jwBwwANwAW8Aa8PwjVlFb6qG/0VV31XX1OLBzdTz4Beqs+hLJd/VAHQ5CWm31UT1VG0nYr3bUzRCvBLmp1tR6nDuRX1ShdPOkOqNW1CLDq7FfxY8owpw+YAdoAkclw3JHL4HR5Grq2zxwD5wE/lYSdoGxcJn8G/vqndoT53qpxnbUuJRqrEZN05HYU4dKtU+pD+qF2ptcJTNiIcQv6ra6mvX3Wp3I+1h2rqVuqLfqk3oWLRrMH0mzmiINc4oG8PrfrH4B9LyYFapPpUQAAAAASUVORK5CYII=",
	["antiaim_16"] = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABYElEQVR4nIWTTStEYRTHf/fOJCUplA3JgliIlZ3MWlkIG7YWsvWysvMR+A62lqyYlc+gKSURJRYUizE/izm3njvIqdN97vn/zznPc14ylUQyIAdaQIWyGPayQxKgcPxPSrxq8m3GeQ2oA3NADRgA7oCL0FYpiFrohHpmW279XerqZPBzFdR+dV99DVJT/VQP1Gl1WJ1TjwJ/UsfVTM1R59VGkqWpLiQ3S3U5OFdxgzwFV9TLIEyp1dBcrahdwTsOznzxhKwjS00diXOKVSLYrNpSD1Wq0XuAHWAI2OvofeccPIbPSNHTLMB1YBfoSeylmQl7X/Cf6SCeBrAQmboCK7Qa9tX4rxdzkMcbR6N91+rgH12YUd/VG7VbzdICoW5FhRvqktobCQbVTfUtCli0uZJGL4JsxyyofqgPyYw8qosmk5guU7ooY8BG1KMfuAfOgRPghfamfgE/ApCCf0gJ/wbNKNuZoTPGDAAAAABJRU5ErkJggg==",
	["check_10"] = "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAnklEQVR4nIWQMQoCMRBFX3aDsNgqW3gAL2Brv52H8wRewUvoDSxFsRTsLCx8Fk4khejAwM/kzWTyk8qPaIBnEf+gXIMtkCooBzQAJ2CGWmdSc+iF71irGbVRV2pXNczVh7opA1BH6lndRbFXb+o2zq2akpqAHtgDF2AKXIFl7CtgeRp1oh7VgzqOfcsdKXwsVnTx+3vtIfABCcAvGoAXIdGbBMzqNwMAAAAASUVORK5CYII=",
	["check_11"] = "iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAArElEQVR4nI3RIU6DQRDF8bdfP0WCROEq6lBcglvU9QS9AIIzITCI3gBHUChEBaKy7a+CXbItJfCSTd7M/Gd2M1uQPzQkKUl24z/AfR/8prGCd0meklz08HACbpPcJnmstV3Qn4Kx+hk2WGGC0qBnPHRN1/jACy5rbmjFpS/d4wpveK8+GJBvg0Vt+MQa05qftBvb5PbOOV5xcwoipfuUo52eiY/Wte/iH2CSHAAHwMMghZCRAQAAAABJRU5ErkJggg==",
	["chevron_10"] = "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAi0lEQVR4nI2QMQpCQQxE30ZvYKFgqbW38FoW3shCwd7eY6igF7D4z2YD8WPhwpDMZBLYaSr/vCh96/jJo1Q70pA8qnEHnMul1E/AHgA11JV6U48qHYeurdVoagADMAeuwAV4A1tgAzyAyO1Jrwv1rj7VZZ21Ek9ennX+KtqXMT/iaBGA6SjXGs9QBx+Vbl/MYA6D+AAAAABJRU5ErkJggg==",
	["chevron_12"] = "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAnElEQVR4nJWRPQ7CMBSDvyTlAnAbFtaeBlohsTHAAhsXhpoBVw2PqhJe3o+dZ8lJkvgH2TUBZUFXrCEFhwREywwM0WENtBZnP0yVuAU2AEhC0lYf3D03klbur+Z2kkBSMdGZuHlG0sW7znMZiex6sOAs6ei+rzVU1xrXXhNOgftJqQGewN5RPqodc7HGGL8iHS9GDEyf+IrknMMi3hNFuGJXVxh1AAAAAElFTkSuQmCC",
	["chevron_right_10"] = "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAh0lEQVR4nI2QsQ0CMRAEx356eERAGURURzlEJERfwldB9v8lIMGQnC2DHHCS5d3T3q29SaVTGXj/Nlp8AY4hGnrCcp+BGRiB19ciFTWpOfBdXdQxeFarsIiHwFf1oe6jn9o3tvUEdg1PPeubuqmHnnWOM6lrWNIM11+VzGbgBCwRT80y/Rv4B3ltjxP/56boAAAAAElFTkSuQmCC",
	["comments_17"] = "iVBORw0KGgoAAAANSUhEUgAAABEAAAARCAYAAAA7bUf6AAABhklEQVR4nI2UvWtVQRDFf/fDKEIqwRQSiJU8SJHCyk4EsRDSW1kGLKwsNFgJViksbGzEfyFgJX5gZWVlERC0NSGFJOJD9OX9LN5ZWcLNw4VzZ5mdObN7dvY2KkATTBkeHXB0whp9rMFFYJQkgJ/AR+AAaE8sorZqrz5zeIzV22qJ5TjKZCsJD9U1dTW4om5n7WpiuyGSc+qR+mSoSvBVfVeRdDVZC6xE1JfAAnA6mnTAmdj30YoIXNCSz35IVoHfwKQK+hV7KXFl3APWI3RbtvtK/R4N+uoYp9Q70WQjvl59G996LeyyepiFHfWz+k39Ed/z3ExBp75W99WzhWQpCR+SdKi+UJ+qNxLTBAshup7YtUJyM45piEZzbqpui6m6VByPQ7KVSkWPPvZClbysPqri/2kyUq9VgeXc9S531S856lj9o94yfQKwA7xJT5SHOM38E3A3fdQBi8A2sAdcLm/neOV5WFQfOGsHnbUGjbNfwbzRVK96Ense2ATGwP3/IRkinNTOv/GXXt0A39qzAAAAAElFTkSuQmCC",
	["comments_19"] = "iVBORw0KGgoAAAANSUhEUgAAABMAAAATCAYAAAByUDbMAAAB0klEQVR4nJWUPWtUQRSGn3s3JmDUNaLxAwQtxBRqOiFoJ1gE8Q9IfoOVTYqgP8BCURAELVPFKkIkEIU0SSTaq4WmSBO/UEwiZvexyJl13L0b9IXDzM5559z3PTOzhUqgjLFJJ3bKtdCTkRPxINCfcdaBtQpeJ9RSRT2nzliN5+r54CV+RxRqAZwGFoA6MAmsAAUgcAwYAzaBi8CrUNioUob6VG2qI12+OqxuqIs7qUPdr/5Sp2KxV+3Joi/WH4blo20Fa6lYCeyJg/iQHUgjC2P9feT2xtjMuGWy2ad+VF93a2zEnPpTrcfvIXVJvZSUJuJEWLitHo4PJJsD6s3I38ksjqjfotcXUs/K2LwQG76rb9XVULwV6zNqf/BTn06oX9VltUAtIrGsvolCqithbUodyxqe+L0xPgj+kWTzkNtH/0ltqLNhN+9Zqe7K7Kfiz9RNtZ6IV/2DW1mBWmapKq7Hnntq6yp8AV4AE8B83P70AprASeAusAR8Bo4Do8DZyN/PXwBtatrnV9R1/8YP9VHMLxuXllBRVry5NJ8GBoEzwDXgHbA7FG8Bp7op+5fYp467fY1UHxv/Gh2PvwuKLJLiA8AN4CXw5H+KtReuhcUWfgNvROTRlcqVSwAAAABJRU5ErkJggg==",
	["configs_14"] = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABWklEQVR4nF2TsWobURBFz0oIB8dNmhRRJxHswh9g8EdEBIOaFPmBgHrpF4w74zLgQm1cuBIuDalDXMRgOQTSKSJyIMYEc1zsfWTRg+HNPmbu3Jm5i4pa5e6p2/G31d/qXH2jdtQNta2C2krigbq0PkfqtXql3qqzgBWraKBcJGiiPiSxq34I2LH6SX1bKhY7URfxtxrvL9VT9Wdo36l91IF6HtRpekF9pm6uURyrj+oOqfJdHakvEjAM8ip+FRaqh4XqSv2qvkrSc/Wv+jF2n8pt9Yf6Td1tAftAB/gMtAGBiv+nfD8Ce8A/4LJwPwyNrdAahsldfNLGKG0tUHfS8HhtEJsZEBnYNODn6gC1H+R5Rn6aFRSAsppFVoZKC7gB3gNfgDPgHTAEusA18AuYAH+A15nDRlOnxWbWCrqyVs9RKC6tZVmprRLctpZex1rQc2uBNwXfs/FDPAFDREKl2fdJUgAAAABJRU5ErkJggg==",
	["configs_16"] = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABhUlEQVR4nG3TzUrVYRAG8OfoOShIBBniMgm6gdwZKm2ihYs20scVuBEFd23FrXgTbbwIS8pdF2CrcHEWcXaBRRC/Fu/866+dgRfm/Zp5nmdmgtxaD3r+Q4zxFUcYYIRh+Uk5M7iDY83O8BwX+FVBfmDhdsL0or2pzx9w7Z9t41n5e1jDS8x1AUYVbbWybWEZO9iou2VcumknGHRQ7mO3Lg6m6BLcLQQvcF5vV4JDfK+DL1gsSrN42kPRrXuYlE7zqc1V8VyqR0Oc9uCeFuch9utsvdPgG37iVX0eVFZ4W0uhCTZr/wmPZpI8SfI5ybskm0kkmc3/9jvJIMn7JK+TPE7yseO1XlH3C+bcFArDertUdK8wCeZLkEkJ1Bdso6DPFrXFEloJfxis1MG5VqI9rWTTSnlQb3e10v9t5RM37VJrng7FTu23tGZbrbtRF3lOa8+1QqB4bveCXmttTmv7AYbTYC5ogzOubBfaYJ3V52Nt8Gb0WnlQKo/KP9JGeKyN9LRRD/IH3pstH+9rG5wAAAAASUVORK5CYII=",
	["copy_13"] = "iVBORw0KGgoAAAANSUhEUgAAAA0AAAANCAYAAABy6+R8AAAA+UlEQVR4nHXSvy5EQRQG8N/dvSsShT8FjYRoEDyBVieReBn0GpWC8AZahWpLERIvolBQSIS47o5izzA2fMlkzsz5851v5lQpJZjBKaYMUWGADvo4CXsANWZxhS7u0fODDo7CPouYtsYmVjHpbzxiJ9i6makJR8Y6Vop2NjCHLVznpApjsS/jFs9IcdfgA5c4x0FdCE9YwwuWCubs28duFlqiwefIXbd4lPdspMLZicr/ocqaeiG4xVs4qpHAX4VqPGEe21iM9lIR08Y5LzVusIeLYH0odOSYJvZxqGKMYMLw1foFW26rxTSOcZiTvucKC4b/VSbBK+7gC7chPWF9PqKIAAAAAElFTkSuQmCC",
	["dots_12"] = "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAkklEQVR4nJ3RPW5CMRAE4HHygCBREEVUIMEtaLgyDZdC4gLQfRSxkfOKRC8rjbRj7894XJAp8Tapumsoo+ZS0deVJCkjSSXJWOOPszZ1lmTXXayTfNZckm2S+TcjOOOBE5a44oYVjrjjgjLUKe8VbeNQeVMxVLw2LHCoefCFTcf3+MD/H91s1fFmq/xi658x+aefiGNiZbGzTr8AAAAASUVORK5CYII=",
	["gear_13"] = "iVBORw0KGgoAAAANSUhEUgAAAA0AAAANCAYAAABy6+R8AAAA4ElEQVR4nKWSMWpCURBFj9FvZ21l8UmVLMEyYKMWAessKL2FbiFVmg9ZgDFFEMFScAu/SBvCSeF9ENKZDDxm7p07M29gUFG7ak/tB6882yq4n3xXBbWTRHmLFDzGL37lOyWYqk/qWm3VJnwTvE5+WiaN03GnHtSNWqeoVl/D76Ibo84DRj++MFBn8YUbRTdHrdR3dZ+Fh+pR/Yofht9HV5Uud+lyrU4S38dPwhsdf5508U49oOVsz0AFfAAPQAPUwAswAD6ja6+ALTADTsAbcAssI1gCN+FP0W3/dREX3d43Ul7p69KkvscAAAAASUVORK5CYII=",
	["gear_16"] = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAA+UlEQVR4nK2TMUpDQRRFz/droWAtaBEwYCG4hBQ2LiCbcBniEoIgmGW4gXTZgGChIKSRNLERraLHInfIELD6eXAZ5s69M/PezEMlaII286H6EQzDtZUOlUYFaIEf1tEDnoDPzA+BC2BWaVaearcD9STjnas4DwxXa1Cbcv1rdRHhV8Zpld50Y20RD43aA96AF2ACHAPfwA3wmuueAbfAPvAOXIY7Re1n13F1YkFJYZMfx9MvxGOIq1R6Tx25jlG4NhrjoRTxSJ2rs+pk1YegFJRo5vE0O3SNbaTQqYi7wBL4BQbA/cYzPv/zjIN4lp0/UuevvJVm6tTOf6Lobz+QLuqRAAAAAElFTkSuQmCC",
	["inventory_14"] = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABQUlEQVR4nGXSwUqVURTF8fVd76B6B6UmWQO52FAyqomooxpEjUoIoleIiB4he4AGkRU6MwhsHkoaPUHZJJIGNalG6q/B3TcPteHwnb32f28W+zsdUtFPsl/3E0keJBlL8jDJr/8Y9JA6Y7iDPcM4xDfcRb/hemmSm/hSDS9wChNYKe0rbo34YBGb2K+G6WbY6AzwvJhNLAbLNfEHLjdw/x97F/G92OWReAbrJb7HpabhArar9gpnR1YHeFLfGWwV9LpAeIfzLRtMYbeAZ5jEHD7iMxZwGk+L2cVUu4ArtTl4jJO11Uel7eFqu9XZmn4Dx7CEn47iN25X7Xqxs8E4Vgv6hPmC7uE+jjfWYQ3jrdVz2Kjih8oH2CntTWl/rXaGT61d/9vG6pbhP2yfZdc5euS9JF2Sg8qvlfayqSfJYZL8AbE8TI1ODzvpAAAAAElFTkSuQmCC",
	["inventory_16"] = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABkElEQVR4nG3TQYjNURQG8O+9N43NIJmVBTMLFrPCVlasKBlmIqGklGShWViIspyFNDvZTZaklFKUMovZSEayMY0idkjZ2IyfxTtvXJlbt//5f+f77j3n3HM6SLN6SVbLHk4yk6Sb5FaSX+twEgQ9dMru4BSW/V0fcAbdhtND0giDo3hboo84iak6AN5hsuF3BsYBvCjSd1zChoY4jIv4VpyF0iSYbUK93oi6GKpQuw1+reHPdpMsJlmqkkwmOZFkKMnv2urbSzKd5Fhxl5Ispjn5OD7VyW9wpPEdxuvyfa66ZJDCeOV0GiM4i69Ffo5nTW3OYWNxFzAejGGlSMt12yZcxmrhV7AZh/C+sBWMtSlMVXjwCvsxWnsfXpbvC6bbFEZxG3sKPI8fRX6Cx2X/xIXi7C7NaDDRPMsD7NBvrpkGv6r/nNtxv8EnBuFvw1zjuIut+kUdwRbcafxzpfmvlXdiviHexI3m/x52WaeV14ajyfFhI3yEvY1/bfg6/h3nbpJOM64HC3vajPKgM5MkfwAAsdz0RyLZeQAAAABJRU5ErkJggg==",
	["legitbot_14"] = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABC0lEQVR4nJ2SvS6EURCGn+/btRSiI/YCFCoi0am4CIlQugXRoRWNRG8LonMJEh3iEnQSeoVm2Ufh/TZHdrcxycnMO/PO38lUKmOkC2wDLeAGeBthqKiVWqsd9Vwd+Fcu1OlwKnWY2IruhXii3qvP6nF81+HUTWIdx3IIR8G36l3sw8RWmkY1UGfqVUCgF1wFE5/AWhNrF+tuhPwQvBj9XhRaBy4BysTX6CvgA+inSweYBQ7+/K7aztx72WMuuHwzie0Ht8uOneh54LPYfQAsxJ5qyGViM9pXdPMxpa/fkOtUBHjKB+wC3yH1Y+8k9jgsNuEAztQtdVM9nXQA/zq537sblS6wFPuFMUf+A7TDQonw5varAAAAAElFTkSuQmCC",
	["legitbot_16"] = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABXElEQVR4nIWTvUqcURCGn/32UwR/Ythib2CtAhYRUnsDtrmI1CliY5fSQsU7sLDKLSQEUgiKZLVKFyUQweBuIJ3fPhbOYWeXXTIwnDnzd2bmvNNSSdQCimIVeAu0gVPg7wwfUAu34nypHqkDxzRUj9XOlC85uFLX1IsI+qbeqnchq36PB6qSpCSo4/wYjntx/xJBqB/Cth/3dklQyqnUX+qP1NZX9Srdr9V7daFUXqUBrgJd4AboBS/GEHvABvAT6AAv8hBL+Ttq4/+pCV/UugZGkesy5D5wAFTJVuR3wFb4AIzyDJYj+6fU8zSfRBXrZQZ1mkGRF0NuA03oirwUIKqng0joGqXAx2RvgieQmBP8A34Dr8KhARZSsMAm8IcxrOcCaXdG/+9nAekZjs9ltYAV4DPwGjgHzuLlN8F9YBsYhn7ihbxMh+pD+vuBc5apVFBoep27obtjzjo/ATRy4yFml8zRAAAAAElFTkSuQmCC",
	["main_14"] = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABKElEQVR4nG2SsUoDURBFz2Y3Kay0jVZaKP6AoJV+gU3+QxSbdIkRLDQo5McEQUlhEa0sBEGCSrLHIvPIujgwvJ337tk7u29QM3VLRW1ETWR6XleP1DydNYBNYAwMgBLIgQxoAAId4B44jr0WAGpTHbiIfryxGW5t9TPOTiqdNKrt9EPQizpX92Nvpn6o5+qdepjAIsS9EF5GfRDQ3L+xUf0JCU5tj9THGvCmdlQSmLIV66gm3gv3djKqQslxV31QS/VHnUYXSZdXHRO0o76E03us6ftuK9osXXqCJiF6jfoq6mmsQyvXgbpdgSYBpbObGnydHFfU53+gwuWIDWtwtwDmwBPwFWM1BgpgFqOXA6cxjmcsYi1TCUEL+I55LFlGFlkCXWAVuPgFrnodq9clzG4AAAAASUVORK5CYII=",
	["main_16"] = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABWElEQVR4nHWTO0pEQRBFz5vxAyKMih+YQBB1D+5BUUEwFWNDl+EiZkBNRTQUTP2sQFATU0N/+HTmGEy19jy1oKi+9e693V3NK1SAUeCZXhSA/ESOF4ASeEj9GtAAboCDTFBka4Ap4Ai4AJrRrwMF6rB6aC/aKmotS9TT+H4X+DtRiwDtILUC16POqR31Qy3VLXVQXVJnk0HaqVUxKdRp9UXtRqreRm+RjFg12Q+8qr5l4k7Uk3SFv0z2g3SmPsW6q76G2bE6pRZ9AwmTgVifZTuW6obaVOdzftUgidfUR/U9hvcZhiMZr6heYTATf9gfCV+p4/48NX/tXGaiTfU88GvUC3Us+PVvp4q4VNejPxkiY4Cql2ojP8FK3DeJ16I/FLXxj8lMMrjPjp3EaSb1zOQyeC9R95LBjnqtLldmkrLm75Oobveeoj9qQLfajL+vA0wAu8Ad0PoCS0vZhV2g6IcAAAAASUVORK5CYII=",
	["pencil_13"] = "iVBORw0KGgoAAAANSUhEUgAAAA0AAAANCAYAAABy6+R8AAAAsUlEQVR4nJXSMUpDQRQF0Psn30JwKSlcgDuwVdMJVm7GNegKXIGlARttrd2CIMQm/1hkBiLEZHzwmJnicN+DGZCOmiVZ13spHWCs4DzJaZIp2NdH9byyqQ+c9YBLrHGLFe4OgQtMuMYLHpFDCQ0s8YyC0pPQQDBg+C8o2+ONe0b6BRqa1ceiB2wnzfGFmwqWf4GGjvGKb7zjqS28CyBjkpMkn0kekrwluU8iSUky7fpXP2Wcr5v/OfpjAAAAAElFTkSuQmCC",
	["play_11"] = "iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAAsklEQVR4nJXRMW4CMRAF0Gc2ilJRpc050qCtuAIH4AqcIFU6JC4QLkKBUiQlp0gVOiqEsmsKxsJaaPIla2z/P39m7JRzNkCDHjfEKBbM0KILYXNPXC5bfGKJ50hKldl1g0PEBXaYR4X+nrgJ8ogXrLHBa3CpFouyD9HCCVN8YzJ0LvgLp0dsY5Yv4VLQRXzCD97wUbvU4nHEFd6xj7ZSGTLlnEdxmOHX5fnKwF1lJv3nB88GmCqfNLYlsgAAAABJRU5ErkJggg==",
	["players_14"] = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAA7klEQVR4nG2RMU7DQBBF325MlxRIXCMU6XIIapBoaHKHnISGIjkKyhFQJFdUSNCkQKkioeRT8I3GY6/0Ze2bP+udv0USaRUgwwGryVBtWAGttTLreyV1mvj7oL/1asksekYbd5LawFuzXmO+KsABuEk6DFzh5CqpSFpIOkk6WyezYg+SKCnVLr1b4MlsC7zlZHNjBS4j1x/U6khhCWyAvbUxu/T8YT4krR3/MTzH0WwdvbFpbsOzpGkIbWome5BUkdR4c+8Ur0NTp5lrj943TXwZz/ACfKdgZq79z9iEiD+AT+AOuEqNP8AX8N795Bd8TToTtZCDSQAAAABJRU5ErkJggg==",
	["players_16"] = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABNUlEQVR4nH2TMUsDQRCFv72cppEUQgorxUIr7fUXBCyu9l+k9x/kj4hlCqvYpbAUFAIpFBuxtBBByeGzuFkz2dtkYFh483aYefs2SCITAUgLOYwic7kwYgXcWFaGtfmSfHbsHKodw4SDpJUGwc6epE9JM0kHljPDegl3ZaRgZx/YASbAq+XEsH7CJTgRI9gFXoAt4NKwa2ABHAI/cftNGlSSard/bVhLAz+Bf4Vf4NTUBxgDj6623HtDg1y0amVCCEY4Bi6AE8OfgFtgTmoo9yyF5SjjgRgjxwveB1GYKyPeSRpI2rccGCbj/N8JkuJIJfAOfABHazSYA7vAHlADwRupoPHA25rLAM80htrOiVjQmOUMeGD5qaK4sskWuE9VWiHYSFPgnMZxHddcNK/zBdwD37HpHxcRRi2U2BRwAAAAAElFTkSuQmCC",
	["plus_11"] = "iVBORw0KGgoAAAANSUhEUgAAAAsAAAALCAYAAACprHcmAAAApklEQVR4nIWRMQoCQQxF37KDOKLoWcRSBRtF9ETewTNZWHgeEat1/Rb7F7LTGAg/yQ9J5g+SKDxL2ksal1xMauNBnZ2cp74n0VltBxgBAmahLqDtm1s7wBOojLFOAjKwdfwFVubWYWsD3OON/+xcScrADph65RK4AFfg4clv4FbKhqSNJx1LLqqRPHnh189dS755oEaPjdV4AZ8BH9ZUxok/JJdn/AAHU9BE9GPBPAAAAABJRU5ErkJggg==",
	["ragebot_14"] = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABJ0lEQVR4nHXSQUtVURQF4O8+Xg99mJKSjUUFbeDABm+i4G/o5xQNEgL/gogYETQRf4LQpHEIFgnR2CCiqQ2Wk/30vtdtw+Hcvfc6+66zzmqSaEWDB7jBKXp4jgH+4g7cnzqUOrSIVQyxhF9TGJJI0tS+kOQw/8ZxkkdtbJOkqUlzOMczHGCtpl/hJS6whz/jPw5q0lFN36m8vUbVe1f5YNwYVONN5TNJNmvNVu1VYYZJ9HGGlbr8eim5gi9Ve4pvtQef8KNXwGEVJ97mPzFEb0x1tmjst/Jpqi8K8zDJhDgn1Rh1iLNdvQ9jTZokvaIwj4/YwmtsVP0S+/iKXfzuMsBikrcdBnif5HEb26bTtL6Xk3xOcpXkSRem7dW4N/lPfC/Fr3WY/BYIlGmqmlOKGAAAAABJRU5ErkJggg==",
	["ragebot_16"] = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABWUlEQVR4nIWTyy5EQRCGvzMYzIyNhAgWs5B4EJbGwnsQJK4L8V4uDyBkTCJYWImIjVi4hBHzWaiTaSculVS6q+uv6q6/ujKVgmRAH/AO7IU9m5x9C+j9IVigHXYdqBXOSkCHxEj3Av3AEnACTADDQBNYAQYjuBunopZinVSP/JIHu3Ifa1OtpzGoWRgD6nEAd9Sq2gitqFvha4WvpGao5ci4GIDdsH/SzcCshV3Oki60gHFgBOgBqsBM+A6AZ+ADuAUegemcg331Qn1Tn9X5yL6QcLAQZw31SW2rl+phKVpXS7rwnxjYKkBawhkwGlosYR94iRJugFdgKi8hJ3E5nrv9B4mrgdnKSUzbWFFPA7Ch9qtzoeUk+FwdStuYfqR6kuQu1o56G/szdcrCRyomqajrAX4Nxs/j2UMF7DcS83noJPZVdGjsN0xxGjt0x7kNXCe+Ml/jnF7AJ3413x91E2A4AAAAAElFTkSuQmCC",
	["save_14"] = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABHUlEQVR4nH2SvUpDQRCFv00uirFR/H0GH8EyvZ0QsFB7W59CtBKxt7OwsvcJrOxsBAk2FmIuGlSSfBaZa5b8eGBY9uyc2Z2zk1QCdWAeqDEJgQHwA/QBijhoAWfAAtCdIqwDi0AJHAPXqIXaUa/UE6fjRT1Qb9Q3tUBtqF9qU92eIXxQUXfVD7VRxPv7wCrwBDxHP7VsfYy2loKz6nEANIB7YCsTEEX7QC8i5eZUSMB35VyG8bwJ6w3xCnAOXABrwf9fKZ5zChzGfhnYmyU0bq/M2sxyNhj+Y4rVSphC1InbAPaBy+CPGPX8HlxKagG8AnfAbRTrZn0lho73gB2gCawTH9tS2zFBpfo5FmWctSOXNDbkc4yczVFxf0P+C6y61Qu5PKYJAAAAAElFTkSuQmCC",
	["save_15"] = "iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAABLUlEQVR4nJ3SvWoUcRQF8N8kkxizwYAPoH0qtbQI2Gth40vkGZI+YCXoQ/gENiGC2MaEWEcEO1EEccmHm2Phnc0w7ELIac7879xzv5skBlgYGgqXQ0OLBg/xBvfwa454BbfxFVs4kESSoyQnSV5lPj4leZnkW5LDJDrxjyTb9X2a5DzJWfG4eKf+7yb5nkRbJf3FGka4NSh3qXhUbY7KfypOOf3Bk16Ahd6gPpfoouY0Fffxfs7AOkzXM2stK8UtNrBc7+Wh4yzxBdaxh2Ps4y4m1xFP8AybOMVjPJ8l7g+scXU0X8q+Wnzi/0A7v/TFLcZqBfhYGZ/iHT70Eo47XVO3fVh9vcViRf5d/be4UxkneIGfeNAkafAIr3G/ojcVpCvx0tW+p7fdZb4R/gGfp6lzCq0b6AAAAABJRU5ErkJggg==",
	["scripts_14"] = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABBUlEQVR4nJ2SQUoDQRBFf89E9BKaTYgnyDqgSxUkbnKWXCMbRSYx4CJuFA/gWQS9gcSNYF4W/Wtsx50FTdX//au7qKoEqLDks9VvqyTh0xKl4aTgR5Jm5vCjVoKAZF8BQ6BnvAY+gIG5FNpIqi18AD6BfeM3oAFegUdzNZBUJN2SbWLcN74AThwvIjlKnfviyljA1Nyh8cT4Okpdmri04MD+Dnh3vGd/bu2qklS7T1/23/ankl4cdzVtqTedX4+Mp0XpZ+aaKDWas/LF2A3BDVKB78vmlON4dusb8ihEHs0GeKIzjkhO5CEPyENf+64HHBePtwvQ3R4BM2DEzzb90eTsfyz5Dt7Q348eDK7jAAAAAElFTkSuQmCC",
	["scripts_16"] = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABQElEQVR4nKWTvUpDQRSEv3sTIilTWecNQlq1t08brawTSC3iLypYWamgRtT4BD6B+iC2lhYKoo5F5oSTaOfCZe/M7Pnds4Uk/rPKGVyYK/0P0AA6QB2oJH68JMVXpH8kVb0PNF5N4zKfLVPk8HwNbAJfxsvAM7AGXAHfyWaSamnhEuhGck57EXgCXoBVYGhtbCup4nTOnOpuKqNtrme8b3xuXImDxxaOjGve++Zbrh1JB+ZOJIG9SdJhal408F7Sa3IY/I5tLuLKAD5Scz6BGrAEPFirpkbH2UkJp/a4l66qZa5vbs77dkSPEqK2oYUt455xOzV13dxNBIoBCiej1PVbSW+S6tY2rN0lm6LqO43aux6geWABeATe06yMgJU0J1OjmzNpOtpgpvu/xp4/hIrT7khqzDifegeSKPTP5/wDUEH0mcMtt1wAAAAASUVORK5CYII=",
	["search_16"] = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABT0lEQVR4nH2Tv04UURTGfzOz7IZQKAmExoawvAQFiaGyNna8gSGx8QF4BdaEggQaDd2GrFZWdjwDvoDgn964cX8WfkOusyMnuTn3zvnOd8/5zp1KpbAG+M2yNcACsBsYFPs6yVvAAbANfAM+AZ97SP+aitrEH6m/XLYTdaDWahUsKmXyy4Cv1Wfqjrqnvsv3i+DqLgHqpvozyU0JyHoTkv1OxfcEhwEc5DzKTSvxG+pcPUt80BK0Io6j8A1QAfNCdYHvwA9gt5WuVB7gLn4rBE0Rb4BV4HGBq7pTGKeFy57+UV8l/jxT+EeD9jAJaKI+yff1IvmLutadBGGsI8x5MftbdZH91/j3EfiepK/cp+qp+lF9q77ImD+EZKYO24vLxLaSPlKSNOuQ9FbQpJ3St094mDZUp+qj/93Wt0qSaUiOK136Qx+yOg9sBLwGrv4AkJJXGqINT+YAAAAASUVORK5CYII=",
	["share_13"] = "iVBORw0KGgoAAAANSUhEUgAAAA0AAAANCAYAAABy6+R8AAAA+0lEQVR4nI2Svy5EURDGf/fcjcZmRWhEsVmlRpT7BqL2Anqlt1CqFBrxDN5gEwo6T8AqkKCgWNZPM/fmOLkSk0xyMuf75s83U6n8wyqgBaY/AAAD4ACog1C3CLX0KnxFfVIv1X781WpnJaPaC7AJ9IFbYAjMgV5ZJTXZCj9T79QtlV5WIQHf8V4EjoB14Cvia8AE2EsFYQicA/fALjCL+GeQE5CallDH6rt6pe6rq1l7p+pU3VZp1Bqor+pJMcuyeqM+qBsRa4U4VJ8zWRdC8ql6rS51Sb4DXGTzzULeY2AMvMVy5wBVnNEI+AAes12VV9LGGlKXVVn2X6AfxTD3x5iPOBUAAAAASUVORK5CYII=",
	["trash_13"] = "iVBORw0KGgoAAAANSUhEUgAAAA0AAAANCAYAAABy6+R8AAABEElEQVR4nHXSzSqEYRQH8N+8MyFm4SOUK7Bi4wYk2WIrG1v3MBehXABiKzcgZW2j2LBV8v09EnMsnNFryqnTef7nf757KhFRoK0tjGMBXfjAHk5LfEtEdOpGRJxFxHbazc6YGmaxilv0YzErf6Quo457DGG9wF06VvCKBnbxlraBx+SfcFduexURAxHRnVZEDCbui4jriKi2xyvQjSrGMI8JLGEN59hBDT1o1vIizRxnEM94x2eHv5nj/55aBg/jy1/5xEjyUBSoJHhIsgt9Waw38WgeCyq1UtJtdjrKHVs4xgkmcdNOKne6wjQusY8pHOACM8n/dooEh5jz822qpZ2+svBW4qhERIlX97+8tB/f/mCWAq7nT5EAAAAASUVORK5CYII=",
	["world_14"] = "iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAABR0lEQVR4nG2SQUuUURSGnzujuBIKUhxdjVGbpMG9e8F1GAju+wHtBv9E235BRTQQZK79B+JCEBSEFoJtDCpnnHla9H7MzTzwce73nvOee857T1GJtYFxzivAKiBwClz+l6OituPX1Y/qd6c2UT+rvTq3Jm2rNxXhNoS+eh3sRUNGLepzdZTgqCrwOokL6kGwZ2ppWh1UpEnOX9Vu4qgP1Uv1S9PqcloZq8OQ3laEnvpGPVEv1J9qZwZ4AsxHtXG+R0ABHgOHVZwo/bRV/XwDZiN5J9hOSL+BSbDSPMdi2ttTt9RX6nzUXlQ/ZO7b+Gt1uZljX72Kwg02F99P4V/xg0acoq6l2pn6Sd0MaSk3DBMf5enKDNACjoGXwHugCzzIPBuVMENgFzgC2ndXrqe+U384tSv/ruF6nVu8f8k7WfICnEfxf3L+AOMS1cuI9EJJAAAAAElFTkSuQmCC",
	["world_16"] = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABYElEQVR4nHWTvUpDQRCFz00iihpBQcQ/xDalIYRg7QOID2BhI/gQIS8h9gbUQhS0tRXEzjcIEhDFQoLGxNx8NueGzU0ycNnd2Tnn7syZiQAFlpUUe5+XtCoJSU1JP2NiJCD5Ml4rQB1oAG2gB3zaV07FDgiyXmuM2ivwGJyrIWYcuAf8Ab/en/q+BDylSRRcYmA/9YJjIBc8/cH+nTCFyxRBDDSBI2AqqNOmfW3gKiHIOzgB9kx2EADLwDnQMvgbeAPmc5LWJC1JiixM12tR0q2kRUl3kpY1bBlJ65lA25ZJZnwuWO9Dgzvuib4xUdIHs8CXK7wLXAMnwJKLtgHcO704KHITyCc5Xti5HeQdSlxwbWIXGhd+oELRzmdg3+cFYNqvqPu+GxCUmNBI+E979m8BHYMThWqkGikhqQY5vgBnwA3DViPVypOG6SMANeyrpGIVMXmc5yStWK53yzwyzv9Gj7NjFS1XiAAAAABJRU5ErkJggg==",
}

local started,result=xpcall(main,debug.traceback)
if not started then
	local env=getgenv and getgenv() or {}
	for _,connection in ipairs(env.NeverloseMenuConnections or {})do pcall(function()connection:Disconnect()end)end
	for i=#(env.NeverloseMenuCleanups or {}),1,-1 do
		if setthreadidentity then setthreadidentity(8)end
		pcall(env.NeverloseMenuCleanups[i])
	end
	env.NeverloseMenu=nil
	env.NeverloseMenuConnections=nil
	env.NeverloseMenuCleanups=nil
	error(result,0)
end
return result
]=====]
local env=getgenv()
env.NeverloseMenuSource=source
local chunk,err=loadstring(source,"Neverlose for RIVALS")
assert(chunk,err)
return chunk()
