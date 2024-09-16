local Fusion = require(script.Parent.Parent.Packages.fusion)
local Colours = require(script.Parent.Parent.Theme)
local Schema = require(script.Parent.Parent.Schema)

local Components = {
	Label = require(script.Parent.Label),
	Button = require(script.Parent.Button),
	Toggle = require(script.Parent.ToggleSwitch),
	ConfigInput = require(script.Parent.ConfigInput)
}

type ConfigProps = {
	Tool: Fusion.UsedAs<Tool>,
	ConfigSchema: Schema.Schema
}

local tweenConfig = TweenInfo.new(0.25)

return function(scope: Fusion.Scope, props: ConfigProps)
	local isWhitehillTool = scope:Value(false)
	local isExpanded = scope:Value(false)
	local absoluteContentSize = scope:Value(Vector2.new(0, 0))

	local arrowRotation = scope:Value(0)
	local animatedRotation = scope:Tween(arrowRotation, tweenConfig)

	local configFrameSize = scope:Value(UDim2.new(1, 0, 0, 40))
	local animatedConfigSize = scope:Tween(configFrameSize, tweenConfig)

	if Fusion.peek(props.Tool) and Fusion.peek(props.Tool):FindFirstChild(props.ConfigSchema.Name) then
		isWhitehillTool:set(true)
	end

	local statusText = scope:Value("")
	local statusSize = scope:Value(16)
	local statusSizeTween = scope:Tween(statusSize, tweenConfig)

	local function updateStatus(newStatus)
		statusText:set(newStatus)
		if Fusion.peek(statusText) ~= "" and Fusion.peek(statusSize) ~= 19 then
			statusSize:set(19)
			task.wait(.25)
			statusSize:set(16)
		end
	end

	local expandedObserver = scope:Observer(isExpanded)
	expandedObserver:onChange(function()
		updateStatus("")
		if Fusion.peek(isExpanded) then
			arrowRotation:set(180)
			configFrameSize:set(UDim2.new(1, 0, 0, Fusion.peek(absoluteContentSize).Y + 58))
		else
			arrowRotation:set(0)
			configFrameSize:set(UDim2.new(1, 0, 0, 40))
		end
	end)

	local whitehillToolObserver = scope:Observer(isWhitehillTool)
	whitehillToolObserver:onChange(function()
		if not Fusion.peek(isWhitehillTool) then
			isExpanded:set(false)
		end
	end)

	local contentSizeObserver = scope:Observer(absoluteContentSize)
	contentSizeObserver:onChange(function()
		if Fusion.peek(isExpanded) then
			configFrameSize:set(UDim2.new(1, 0, 0, Fusion.peek(absoluteContentSize).Y + 58))
		end
	end)

	local attribCount = 0
	for a, b in pairs(props.ConfigSchema.Attributes) do
		attribCount += 1
	end

	return scope:New("Frame")({
		Size = animatedConfigSize;
		BackgroundColor3 = Colours.secondary,

		[Fusion.Children] = {
			scope:New("TextButton")({
				Size = UDim2.new(1, 0, 0, 40);
				BackgroundColor3 = Colours.secondary,

				AutoButtonColor = (isWhitehillTool and attribCount > 0),

				[Fusion.Children] = {
					Components.Label(scope, {
						AlignX = Enum.TextXAlignment.Left,

						Text = props.ConfigSchema.Type,
						TextSize = 18,

						BackgroundTransparency = 1,
						Size = UDim2.new(0.5, 0, 1, 0),
					}),

					scope:Computed(function(use, _)
						if not use(props.Tool) then return end

						return Components.Button(scope, {
							BackgroundColor3 = Colours.primary,

							Size = UDim2.new(0.25, 0, 0, 30),
							Position = scope:Computed(function(use, _) if use(isWhitehillTool) and attribCount > 0 then return UDim2.new(1, -35, 0.5, 0) else return UDim2.new(1, 0, 0.5, 0) end end),
							AnchorPoint = Vector2.new(1, 0.5),

							Text = use(isWhitehillTool) and "Delete" or "Create",
							OnClick = function()
								if use(isWhitehillTool) then
									use(props.Tool):FindFirstChild(props.ConfigSchema.Name):Destroy()
									isWhitehillTool:set(false)
								else
									local newConfig = Instance.new(props.ConfigSchema.Class)
									newConfig.Name = props.ConfigSchema.Name

									for attribName, attribValue in pairs(props.ConfigSchema.Attributes) do
										newConfig:SetAttribute(attribName, attribValue)
										task.wait()
										newConfig:SetAttribute(attribName, attribValue)
									end

									newConfig.Parent = use(props.Tool)
									isWhitehillTool:set(true)
								end
							end,
						})
					end),

					scope:Computed(function(use, _)
						if not (use(isWhitehillTool) and attribCount > 0) then return end

						return scope:New("ImageLabel")({
							Image = "rbxassetid://122655587621294",

							BackgroundTransparency = 1,

							Size = UDim2.new(0, 30, 0, 30),
							Position = UDim2.new(1, 0, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5),

							Rotation = animatedRotation,
						})
					end),

					scope:New("UICorner")({
						CornerRadius = UDim.new(0, 8)
					}),

					scope:New("UIPadding")({
						PaddingTop = UDim.new(0, 5),
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5),
					}),
				},

				[Fusion.OnEvent("Activated")] = function()
					if not (Fusion.peek(isWhitehillTool) and attribCount > 0) then return end
					isExpanded:set(not Fusion.peek(isExpanded))
				end,
			}),

			scope:Computed(function(use, _)
				if not (use(isWhitehillTool) and attribCount > 0) then return end

				local attributeFormElements = {}
				for attributeName, attributeValue in pairs(props.ConfigSchema.Attributes) do
					local component = scope:New("Frame")({
						Size = UDim2.new(1, 0, 0, 30);
						BackgroundTransparency = 1;

						[Fusion.Children] = {
							Components.Label(scope, {
								BackgroundColor3 = Colours.secondary;
								Text = attributeName;
								Size = UDim2.new(0.5, -10, 1, 0);
							});

							scope:Computed(function(use, scope)
								local configItem = use(props.Tool):FindFirstChild(props.ConfigSchema.Name)

								local val = attributeValue
								if configItem then
									val = configItem:GetAttribute(attributeName)
								end

								local itemState = scope:Value(val)
								local itemStateChange = scope:Observer(itemState)
								itemStateChange:onChange(function()
									configItem:SetAttribute(attributeName, Fusion.peek(itemState))
									updateStatus(attributeName .. " updated!")
								end)

								if typeof(attributeValue) == "boolean" then
									return Components.Toggle(scope:innerScope(), {
										isToggled = itemState;
										onToggle = function()
											itemState:set(not Fusion.peek(itemState))
										end,

										Position = UDim2.new(1, -10, 0.5, 0);
										Size = UDim2.new(0, 30, 0.5, 0);
										AnchorPoint = Vector2.new(1, 0.5);
									});
								else
									local isError = scope:Value(false)

									return Components.ConfigInput(scope, {
										Position = UDim2.new(0.5, 10, 0, 0);
										Size = UDim2.new(0.5, -10, 1, 0);

										Text = itemState;
										IsError = isError;

										OnUpdate = function(newValue)
											isError:set(false)

											if typeof(attributeValue) == "number" and tonumber(newValue) then
												itemState:set(newValue)
											elseif attributeName == "ItemImage" then
												if newValue:match("((rbxassetid:\/\/)%d+)") or newValue == "" then
													itemState:set(newValue)
												else
													isError:set(true)
													updateStatus(attributeName .. " must be an image in the rbxassetid:// format.")
												end
											elseif typeof(attributeValue) == "string" then
												itemState:set(newValue)
											else
												isError:set(true)
												updateStatus(attributeName .. " was set to an invalid type.")
											end
										end;
									});
								end
							end);
						}
					})

					table.insert(attributeFormElements, component)
				end

				return scope:New("Frame")({
					Position = UDim2.new(0, 0, 0, 40);
					Size = UDim2.new(1, 0, 1, -40);

					BackgroundTransparency = 1;
					ClipsDescendants = true;

					[Fusion.Children] = {
						scope:New("UIListLayout")({
							Padding = UDim.new(0, 8),
							[Fusion.Out("AbsoluteContentSize")] = absoluteContentSize,
						});

						attributeFormElements;

						scope:Computed(function(use, scope)
							if use(statusText) == "" then return end

							return Components.Label(scope, {
								BackgroundTransparency = 1;
								Size = UDim2.new(1, 0, 0, 30);
								Text = statusText;
								TextSize = statusSizeTween;
							});
						end);

						scope:New("UIPadding")({
							PaddingTop = UDim.new(0, 8),
							PaddingLeft = UDim.new(0, 8),
							PaddingRight = UDim.new(0, 8),
							PaddingBottom = UDim.new(0, 8),
						});
					}
				})
			end),

			scope:New("UICorner")({
				CornerRadius = UDim.new(0, 8)
			}),
		}
	})
end