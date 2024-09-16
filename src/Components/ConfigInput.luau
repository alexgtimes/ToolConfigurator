local Fusion = require(script.Parent.Parent.Packages.fusion)
local Colours = require(script.Parent.Parent.Theme)

type ConfigInputProps = {
	Text: Fusion.UsedAs<string>,
	OnUpdate: (newValue: string) -> (),

	IsError: boolean?,

	Position: UDim2?,
	Size: UDim2?,
	AnchorPoint: Vector2?
}

return function(scope: Fusion.Scope, props: ConfigInputProps)
	local inputValue = scope:Value(props.Text)

	return scope:New("TextBox")({
		BackgroundColor3 = Colours.background;

		Size = props.Size;
		Position = props.Position;
		AnchorPoint = props.AnchorPoint;

		TextColor3 = scope:Computed(function(use, scope)
			if use(props.IsError) then
				return Color3.fromRGB(140, 35, 35)
			else
				return Colours.text
			end
		end);

		Text = props.Text;
		[Fusion.Out("Text")] = inputValue;

		[Fusion.Children] = {
			scope:New("UICorner")({
				CornerRadius = UDim.new(0, 8);
			});

			scope:Computed(function(use, scope)
				if use(props.IsError) then
					return scope:New("UIStroke")({
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
						Color = Color3.fromRGB(140, 35, 35);
						Thickness = 2;
					})
				end
			end)
		};

		[Fusion.OnEvent("FocusLost")] = function()
			props.OnUpdate(Fusion.peek(inputValue))
		end,
	})
end