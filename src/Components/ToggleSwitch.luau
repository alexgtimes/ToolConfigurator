local Fusion = require(script.Parent.Parent.Packages.fusion)
local Colours = require(script.Parent.Parent.Theme)

type ToggleSwitchProps = {
	isToggled: Fusion.UsedAs<boolean>,
	onToggle: () -> (),

	Position: UDim2?,
	Size: UDim2?,
	AnchorPoint: Vector2?
}

local tweenConfig = TweenInfo.new(0.25)

return function(scope: Fusion.Scope, props: ToggleSwitchProps)
	local toggleBackground = scope:Computed(function(use, scope) if use(props.isToggled) then return Colours.accent else return Colours.background end end)
	local toggleBgAnimated = scope:Tween(toggleBackground, tweenConfig)

	local togglePosition = scope:Computed(function(use, scope) if use(props.isToggled) then return UDim2.new(1, 0, 0.5, 0) else return UDim2.new(0, 0, 0.5, 0) end end)
	local togglePosAnimated = scope:Tween(togglePosition, tweenConfig)

	return scope:New("TextButton")({
		BackgroundColor3 = toggleBgAnimated;

		Size = props.Size;
		Position = props.Position;
		AnchorPoint = props.AnchorPoint;

		[Fusion.Children] = {
			scope:New("TextButton")({
				BackgroundColor3 = Colours.primary;
				Size = UDim2.new(1, 8, 1, 8);

				AnchorPoint = Vector2.new(0.5, 0.5);
				Position = togglePosAnimated;

				AutoButtonColor = true;

				SizeConstraint = Enum.SizeConstraint.RelativeYY;

				[Fusion.Children] = {
					scope:New("UICorner")({
						CornerRadius = UDim.new(1, 0);
					});
				};

				[Fusion.OnEvent("Activated")] = function()
					props.onToggle()
				end,
			});

			scope:New("UICorner")({
				CornerRadius = UDim.new(1, 0);
			});
		};

		[Fusion.OnEvent("Activated")] = function()
			props.onToggle()
		end,
	})
end