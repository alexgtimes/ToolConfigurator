local Selection = game:GetService('Selection')

local Fusion = require(script.Packages.fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

--// Configuration
local toolSchema = require(script.Schema)
local Colours = require(script.Theme)

local Components = {
	Label = require(script.Components.Label);
	ConfigItem = require(script.Components.ConfigItem);
}

--// Bootstrap the plugin
local pluginToolbar = plugin:CreateToolbar("Whitehill Group")
local pluginButton = pluginToolbar:CreateButton("Configure Tools", "Configure any tool to work with Whitehill/JSM products", "rbxassetid://13242789995")

local widgetConfig = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 350, 400, 350, 400)
local widget = plugin:CreateDockWidgetPluginGui("WhitehillToolConfigurator", widgetConfig)

--// Configure the plugin objects
pluginButton.ClickableWhenViewportHidden = true

widget.Title = "Whitehill Tool Configurator"

--// Create UI
local scope = Fusion.scoped(Fusion)
local selectedTool = scope:Value(nil)
local selectionError = scope:Value(nil)

scope:New("Frame")({
	Name = "Container",
	Parent = widget,

	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Colours.background,

	[Children] = {
		scope:Computed(function(use, _)
			if use(selectionError) ~= nil then
				return Components.Label(scope, {
					Text = use(selectionError),
					TextSize = 24,
					Size = UDim2.new(1, 0, 1, 0)
				})
			end
		end),

		scope:Computed(function(use, _)
			if use(selectedTool) ~= nil then
				local absoluteContentSize = scope:Value(Vector2.new(0, 0))
				local configurators = {}

				return scope:New("Frame")({
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Colours.background,

					[Fusion.Children] = {
						scope:New("UIPadding")({
							PaddingTop = UDim.new(0, 5),
							PaddingLeft = UDim.new(0, 5),
							PaddingRight = UDim.new(0, 5),
							PaddingBottom = UDim.new(0, 5),
						});

						Components.Label(scope, {
							Text = "Editing " .. tostring(use(selectedTool).Name),
							Bold = true,

							TextSize = 22,
							Position = UDim2.new(0, 0, 0, 0),
							Size = UDim2.new(1, 0, 0, 30),
						});

						scope:New("ScrollingFrame")({
							Size = UDim2.new(1, 0, 1, -40);
							Position = UDim2.new(0, 0, 0, 40);

							BackgroundTransparency = 1;
							ScrollBarThickness = 4;

							CanvasSize = scope:Computed(function(use, _)
								return UDim2.new(0, 0, 0, use(absoluteContentSize).Y)
							end);

							[Fusion.Children] = {
								scope:New("UIListLayout")({
									Padding = UDim.new(0, 5),
									[Fusion.Out("AbsoluteContentSize")] = absoluteContentSize,
								});

								scope:ForValues(toolSchema, function(use, scope, schemaItem)
									return Components.ConfigItem(scope:innerScope(), {
										Tool = use(selectedTool),
										ConfigSchema = schemaItem,
									})
								end);
							}
						})
					}
				})
			end
		end)
	}
})

--// Handle tool selections
local function handleToolSelection()
	local selected = Selection:Get()

	selectedTool:set(nil)
	selectionError:set(nil)

	if #selected == 0 or #selected > 1 then
		selectionError:set("No tool selected.\n\nSelect a tool to get started.")
	elseif selected[1].ClassName ~= "Tool" then
		selectionError:set("No tool selected.\n\nSelect a tool to get started.")
	else
		selectedTool:set(selected[1])
	end
end

--// Handle events
pluginButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	pluginButton:SetActive(widget.Enabled)
end)

widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	pluginButton:SetActive(widget.Enabled)
end)

Selection.SelectionChanged:Connect(handleToolSelection)
handleToolSelection()