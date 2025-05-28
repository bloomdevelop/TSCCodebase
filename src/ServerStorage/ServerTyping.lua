--!strict

export type Map<K, V> = {[K]: V}

export type Array<V> = {V}

export type PlayerGroup = {
	Name: string,
	Id: number,
	EmblemUrl: string,
	EmblemId: number,
	Rank: number,
	Role: string,
	IsPrimary: boolean,
	IsInClan: false
}

export type CharacterType = Model & {
	Humanoid: Humanoid,
	HumanoidRootPart: Part & { ["RootJoint"]: Motor6D },
	Torso: Part & { ["Neck"]: Motor6D, ["Left Hip"]: Motor6D, ["Right Hip"]: Motor6D, ["Left Shoulder"]: Motor6D, ["Left Shoulder"]: Motor6D }
}

export type ConnectionType = { Disconnect: () -> nil }

export type SignalType = { Connect: ((any) -> any) -> ConnectionType, DisconnectAll: () -> nil, Fire: (...any) -> nil, Wait: () -> nil }

export type AudioDataType = {
	Looped: boolean,
	ID: string,
	SoundId: string,
}

export type TypedRBXScriptSignal<Variant... = ()> = {
    --[[
    Connects the given function to the event and returns RBXScriptConnection that represents it.
    [Learn more](https://developer.roblox.com/en-us/api-reference/datatype/RBXScriptSignal)
    ]]
	Connect: (self: RBXScriptSignal, func: (Variant...) -> ()) -> RBXScriptConnection,
    --[[
    Yields the current thread until the signal fires
    and returns the arguements provided by the
    signal.
    [Learn more](https://developer.roblox.com/en-us/api-reference/datatype/RBXScriptSignal)
    ]]
	Wait: (_: RBXScriptSignal) -> Variant...,
	Once: (self: RBXScriptSignal, func: (Variant...) -> ()) -> RBXScriptConnection,
	ConnectParallel: (self: RBXScriptSignal, func: (Variant...) -> ()) -> RBXScriptConnection
}

export type NACSConnection = {
	Disconnect: (self: any) -> ()
}

export type NACSSignal<Variant... = ()> = {
	Connect: (self: any, func: (Variant...) -> ()) -> NACSConnection,
	Wait: (_: any) -> Variant...,
	DisconnectAll: (_: any) -> ()
}

export type NACS = {
	Cache: Map<any, any>,
	Logs: Map<any, any>, -- TODO: fix this for a logger type
	Events: Map<string, NACSSignal<...any>>,
	[string]: any
}

export type Modules = {
	Create: (className: string, defaultParent: Instance) -> (properties: Map<any, any>) -> Instance
}

export type FrameworkType = (...any) -> (...any) & {
	Logger: {
		print: (...any) -> (),
		warn: (...any) -> (),
		error: (...any) -> ()
	},
	Functions: {},
	Modules: (...any) -> (...any) & Map<string, any> & Modules,
	Services: (...any) -> (...any) & {
		Debris: Debris,
		Players: Players,
		ReplicatedStorage: ReplicatedStorage,
		ContextActionService: ContextActionService,
		UserInputService: UserInputService,
		Lighting: Lighting,
		RunService: RunService,
		SoundService: SoundService,
		TextService: TextService,
		Teams: Teams,
		GroupService: GroupService,
		Workspace: Workspace,
		ServerStorage: ServerStorage,
		ContentProvider: ContentProvider,
		Chat: Chat,
		ServerScriptService: ServerScriptService,
		ReplicatedFirst: ReplicatedFirst,
		TweenService: TweenService,
		[string]: any
	},
	Network: NetworkType,
	[string]: any
}

export type NetworkType = {
	Pings: Map<Player, number>,
	Remotes: {
		Function: BindableFunction,
		Fetch: RemoteFunction,
		Send: RemoteEvent,
		Call: BindableEvent
	},
	GetKey: (Player) -> number,
	GetPing: (Player) -> number,
	Watch: (string, callback: (Player, any) -> any) -> (),
	Add: (string, callback: (Player, any) -> any) -> (),
	Remove: (string) -> (),
	Modify: (string, callback: (Player, any) -> any) -> (),
	Send: (Player | string | { Player | string }, string, ...any) -> (),
	Fetch: (Player | string | { Player | string }, string, ...any) -> (),
	[string]: any
}

export type FrameworkAndNetworkType = FrameworkType & {
	Network: NetworkType
}

export type FrameworkAndNACSType = FrameworkType & {
	NACS: NACS
}

return nil