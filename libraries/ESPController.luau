----<< Setup Global Variables >>----
getgenv().CKTY_HUB["ESPController"] = {}

----<< Folders >>----
local espFolder = Instance.new("Folder")
local nametagsFolder = Instance.new("Folder")
local chamsFolder = Instance.new("Folder")

nametagsFolder.Parent = espFolder
chamsFolder.Parent = espFolder

espFolder.Name = "esp-controller"
espFolder.Parent = gethui and gethui() or game:GetService("CoreGui")

----<< Variables >>----
local defaultOptions = {
	visible = true,
	nametag = {
		visible = true,
		alwaysOnTop = true,
		maxDistance = math.huge,
		text = "text",
		textSize = 14,
		color = { Color3.new(1, 1, 1), 0 },
		outlineColor = { Color3.new(0, 0, 0), 0.5 },
		font = Enum.Font.Ubuntu,
		offset = Vector3.new(0, 0, 0),
	},
	cham = {
		visible = true,
		alwaysOnTop = true,
		color = { Color3.new(1, 0, 0), 0.5 },
		outlineColor = { Color3.new(1, 1, 1), 0 },
	},
	onDestroy = function(obj)
		print("Default")
	end,
}

----<< Functions >>----
local function mergeDefaults(options, _defaultOptions)
	for i, v in pairs(_defaultOptions) do
		if type(v) == "table" then
			if options[i] == nil then
				options[i] = _defaultOptions[i]
			else
				mergeDefaults(options[i], _defaultOptions[i])
			end

			continue
		end

		if options[i] == nil then
			options[i] = v
		end
	end
end

local function updateRecursive(options, changes)
	for i, v in pairs(changes) do
		if type(v) == "table" then
			updateRecursive(options[i], v)
			continue
		end

		options[i] = v
	end
end

----<< Main Module >>----
local ESPController = {
	objects = {},
	loopConnection = true,
}

function ESPController.new(owner: Instance, options: table)
	if ESPController.has(owner) then
		return ESPController.get(owner)
	end

	assert(owner, "Missing argument #1 (Instance expected)")
	if not options then
		options = {}
	end
	mergeDefaults(options, defaultOptions)

	local self = {}
	self.objects = {
		nametag = nil,
		cham = nil,
	}
	self.options = options

	function self:_construct()
		self:_createNametag(options.nametag)

		-- To somewhat prevent reaching highlight instance cap
		if options.cham.visible then
			self:_createCham(options.cham)
		end

		ESPController.objects[owner] = self
	end

	function self:Update(newOptions)
        mergeDefaults(newOptions, defaultOptions)

		do
			local billboard = self.objects.nametag
			local opt = newOptions.nametag

			billboard.Enabled = opt.visible
			billboard.AlwaysOnTop = opt.alwaysOnTop
			billboard.MaxDistance = opt.maxDistance
			billboard.StudsOffset = opt.offset

			local textLabel = billboard.TextLabel
			textLabel.Text = opt.text
			textLabel.TextSize = opt.textSize
			textLabel.Font = opt.font
			textLabel.TextColor3 = opt.color[1]
			textLabel.TextTransparency = opt.color[2]
			textLabel.TextStrokeColor3 = opt.outlineColor[1]
			textLabel.TextStrokeTransparency = opt.outlineColor[2]
		end

		if self.options.cham.visible and newOptions.cham.visible then
			local highlight = self.objects.cham
			local opt = newOptions.cham

			highlight.DepthMode = opt.alwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop
				or Enum.HighlightDepthMode.Occluded
			highlight.FillColor = opt.color[1]
			highlight.FillTransparency = opt.color[2]
			highlight.OutlineColor = opt.outlineColor[1]
			highlight.OutlineTransparency = opt.outlineColor[2]
		end

		if not self.options.cham.visible and newOptions.cham.visible then
			self:_createCham(newOptions.cham)
		end
		if self.options.cham.visible and not newOptions.cham.visible then
			if self.objects.cham then
				self.objects.cham:Destroy()
				self.objects.cham = nil
			end
		end

		updateRecursive(self.options, newOptions)
	end

	function self:Destroy()
		if self.observer then
			self.observer:Disconnect()
			self.observer = nil
		end

		if self.objects.nametag then
			self.objects.nametag:Destroy()
			self.objects.nametag = nil
		end
		if self.objects.cham then
			self.objects.cham:Destroy()
			self.objects.cham = nil
		end

		ESPController.objects[owner] = nil

		if self.options.onDestroy then
			self.options.onDestroy(self)
		end
	end

	function self:_observeOwner()
		self.observer = owner.Destroying:Connect(function()
			self:Destroy()
		end)
	end

	function self:_createNametag(opt)
		if self.objects.nametag then
			self.objects.nametag:Destroy()
		end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "Nametag"
		billboard.ClipsDescendants = false
		billboard.ResetOnSpawn = false
		billboard.Enabled = opt.visible
		billboard.Size = UDim2.new(1, 0, 1, 0)
		billboard.AlwaysOnTop = opt.alwaysOnTop
		billboard.MaxDistance = opt.maxDistance
		billboard.StudsOffset = opt.offset

		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.Text = opt.text
		textLabel.TextSize = opt.textSize
		textLabel.Font = opt.font
		textLabel.TextColor3 = opt.color[1]
		textLabel.TextTransparency = opt.color[2]
		textLabel.TextStrokeColor3 = opt.outlineColor[1]
		textLabel.TextStrokeTransparency = opt.outlineColor[2]

		textLabel.Parent = billboard
		billboard.Adornee = owner:FindFirstChild("Head") or owner
		billboard.Parent = nametagsFolder

		self.objects.nametag = billboard
	end

	function self:_createCham(opt)
		if self.objects.cham then
			self.objects.cham:Destroy()
		end

		local highlight = Instance.new("Highlight")
		highlight.Name = "Cham"
		highlight.DepthMode = opt.alwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop
			or Enum.HighlightDepthMode.Occluded
		highlight.FillColor = opt.color[1]
		highlight.FillTransparency = opt.color[2]
		highlight.OutlineColor = opt.outlineColor[1]
		highlight.OutlineTransparency = opt.outlineColor[2]

		highlight.Adornee = owner
		highlight.Parent = chamsFolder

		self.objects.cham = highlight
	end

	self:_construct()
	self:_observeOwner()

	return self
end

function ESPController.Destroy()
	ESPController.loopConnection = false
end

function ESPController.has(owner: Instance)
	return ESPController.objects[owner] ~= nil
end

function ESPController.get(owner): table?
	return ESPController.objects[owner]
end

----<< Loop >>----
coroutine.wrap(function()
	while ESPController.loopConnection do
		for owner: Instance, obj in pairs(ESPController.objects) do
			if obj.options.nametag.visible then
				local template = obj.options.nametag.text
				local needDistance = template:find("{distance}") ~= nil
				local needHealth = template:find("{health}") ~= nil

				local isBodyPart = false
				local humanoid = owner:FindFirstChildWhichIsA("Humanoid")

				if owner.Parent ~= nil and not humanoid then
					local parentHumanoid = owner.Parent:FindFirstChildWhichIsA("Humanoid")
					if parentHumanoid then
						isBodyPart = true
						humanoid = parentHumanoid
					end
				end

				local distance, health

				if needDistance then
					if humanoid then
						if isBodyPart then
							distance = (workspace.CurrentCamera.CFrame.Position - owner.CFrame.Position).Magnitude
						else
							pcall(function()
								distance = (
									workspace.CurrentCamera.CFrame.Position
									- owner.HumanoidRootPart.CFrame.Position
								).Magnitude
							end)
						end
					elseif owner:IsA("Model") then
						distance = (workspace.CurrentCamera.CFrame.Position - owner.WorldPivot.Position).Magnitude
					else
						distance = (workspace.CurrentCamera.CFrame.Position - owner.CFrame.Position).Magnitude
					end

					distance = math.round(distance or -1)
				end

				if needHealth and humanoid then
					health = math.round(humanoid.Health)
				end

				-- replace only what’s needed
				local text = template
				if needDistance then
					text = text:gsub("{distance}", tostring(distance))
				end
				if needHealth then
					text = text:gsub("{health}", tostring(health or -1))
				end

				obj.objects.nametag.TextLabel.Text = text
			end
		end

		task.wait(0.5)
	end
end)()
