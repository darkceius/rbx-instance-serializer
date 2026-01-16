export type props = {
	plugin: Plugin,
	config: () -> any,

	selectedBuilder: string,
	setSelectedBuilder: (string) -> (),
	setPropsUsed: ((boolean) -> ())?,

	LayoutOrder: number,
}

return nil :: any
