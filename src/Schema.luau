export type Schema = {
	Type: string,
	Name: string,
	Class: string,
	Attributes: {any}
}

local data: {Schema} = {
	{
		Type = "Scannable Item";
		Name = "JSM | Item Data";
		Class = "BindableFunction";
		Attributes = {
			AgeRestricted = false;
			Cost = 4.99;
			LoyaltyCost = 0;
			EASActive = true;
			ItemImage = "";
		};
	};

	{
		Type = "Operator Barcode";
		Name = "JSM | Operator Barcode";
		Class = "BindableFunction";
		Attributes = {
			AccountID = 1;
		};
	};

	{
		Type = "Debit Card";
		Name = "JSM | Debit Card";
		Class = "BindableFunction";
		Attributes = {};
	};

	{
		Type = "Loyalty Card";
		Name = "JSM | Loyalty Card";
		Class = "BindableFunction";
		Attributes = {};
	};

	{
		Type = "EAS Test Tag";
		Name = "JSM | EAS Test Tag";
		Class = "BindableFunction";
		Attributes = {
			EASActive = true;
		};
	};
}

return data
