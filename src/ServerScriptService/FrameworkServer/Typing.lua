--!strict

export type Map<K, V> = {[K]: V}

export type Array<V> = {V}

export type FrameworkType = {
	Logger: {
		print: (...any) -> (),
		debug: (...any) -> (),
		warn: (...any) -> (),
		error: (...any) -> ()
	},
	Functions: {},
	Services: (...any) -> (...any) & {
		Workspace: Workspace,
		Players: Players,
		Lighting: Lighting,
		ReplicatedStorage: ReplicatedStorage,
		ServerScriptService: ServerScriptService,
		ServerStorage: ServerStorage,
		TweenService: TweenService,
		ContentProvider: ContentProvider,
		RunService: RunService,
		SoundService: SoundService,
		TextService: TextService,
		Debris: Debris,
		Teams: Teams,
		Chat: Chat,
		[string]: any
	},
	Network: NetworkType
	--Moderation: Moderation,
	--Anticheat: Anticheat,
	--Replication: Replication,
	--Interaction: Interaction
}

export type NetworkType = {
	Pings: Map<Player, number>,
	Remotes: {
		Fetch: RemoteFunction,
		Send: RemoteEvent
	},
	GetKey: (Player) -> number,
	GetPing: (Player) -> number,
	--Watch: (self: NetworkType, name: string, callback: (Player, ...any) -> (...any)) -> (),
	--Unwatch: (self: NetworkType, name: string) -> (),
	Add: (self: NetworkType, name: string, callback: (Player, ...any) -> (...any)) -> (),
	Remove: (self: NetworkType, name: string) -> (),
	Modify: (self: NetworkType, name: string, callback: (Player, ...any) -> (...any)) -> (),
	Send: (self: NetworkType, to: Player | string | Array<Player | string>, name: string, ...any) -> (),
	Fetch: (self: NetworkType, to: Player | string | Array<Player | string>, name: string, ...any) -> (...any)
}

return nil