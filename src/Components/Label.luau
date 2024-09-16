local Fusion = require(script.Parent.Parent.Packages.fusion)
local Colours = require(script.Parent.Parent.Theme)

type LabelProps = {
	Text: Fusion.UsedAs<string>,
	Position: UDim2?,
	Size: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundColor3: Color3?,
	BackgroundTransparency: number?,

	Font: string?,
	Bold: boolean?,
	Italic: boolean?,
	TextSize: Fusion.UsedAs<number>?,

	AlignX: Enum.TextXAlignment?,
	AlignY: Enum.TextYAlignment?
}

return function(scope: Fusion.Scope, props: LabelProps)
	return scope:New("TextLabel")({
		Text = props.Text,

		BackgroundColor3 = props.BackgroundColor3 or Colours.background,
		BackgroundTransparency = props.BackgroundTransparency,
		TextColor3 = Colours.text,

		FontFace = Font.fromName(
			props.Font or "Montserrat",
			props.Bold and Enum.FontWeight.Bold or Enum.FontWeight.Regular,
			props.Italic and Enum.FontStyle.Italic or Enum.FontStyle.Normal
		),

		TextSize = props.TextSize,
		RichText = true,
		TextWrapped = true,

		TextXAlignment = props.AlignX,
		TextYAlignment = props.AlignY,

		Size = props.Size,
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,

		[Fusion.Children] = {
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
			})
		}
	})
end