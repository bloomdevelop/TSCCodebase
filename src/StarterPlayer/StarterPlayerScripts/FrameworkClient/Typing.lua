--!strict

-- GLOBALS

export type Map<K, V> = {[K]: V}

export type Array<V> = {V}

-- ROBLOX GLOBALS

export type CharacterType = Model & {
	Humanoid: Humanoid & {
		Animator: Animator?,
		HumanoidDescription: HumanoidDescription?
	},
	HumanoidRootPart: Part & {
		RootJoint: Motor6D
	},
	Head: Part & {
		face: Decal
	},
	Torso: Part & {
		roblox: Decal,
		["Neck"]: Motor6D,
		["Left Hip"]: Motor6D,
		["Right Hip"]: Motor6D,
		["Left Shoulder"]: Motor6D,
		["Right Shoulder"]: Motor6D,
	},
	["Left Arm"]: Part,
	["Left Leg"]: Part,
	["Right Arm"]: Part,
	["Right Leg"]: Part
	
}

export type RagdollCharacterType = CharacterType & {
	Collisions: Folder & {
		Rigged_Head: Part,
		["Rigged_Left Arm"]: Part,
		["Rigged_Left Leg"]: Part,
		["Rigged_Right Arm"]: Part,
		["Rigged_Right Leg"]: Part
	}
}

-- FRAMEWORK

export type FrameworkType = {
	Logger: {
		print: (...any) -> (),
		debug: (...any) -> (),
		warn: (...any) -> (),
		error: (...any) -> ()
	},
	Functions: {},
	Modules: (...any) -> (...any) & {},
	Services: (...any) -> (...any) & {
		Workspace: Workspace,
		Players: Players,
		Lighting: Lighting,
		ReplicatedFirst: ReplicatedFirst,
		ReplicatedStorage: ReplicatedStorage,
		TweenService: TweenService,
		ContentProvider: ContentProvider,
		RunService: RunService,
		SoundService: SoundService,
		TextService: TextService,
		UserInputService: UserInputService,
		Debris: Debris,
		Teams: Teams,
		Chat: Chat,
		[string]: any
	},
	Network: NetworkType,
	UserInput: UserInputType,
	Playerstates: PlayerstatesType,
	Interface: InterfaceType
	--Connection: Connection,
	--Replication: Replication,
	--Interaction: Interaction
}

-- NETWORK

export type NetworkType = {
	Key: number,
	Ping: number,
	Events: {},
	Queue: {},
	--Watchers: { [string]: {[number]: (...any) -> (...any) }},
	Remotes: {
		Fetch: RemoteFunction,
		Send: RemoteEvent
	},
	IgnoredEvents: Map<string, boolean>,
	GetKey: (self: NetworkType) -> number,
	GetPing: (self: NetworkType) -> number,
	--Watch: (Network, name: string, callback: (...any) -> (...any)) -> (),
	--Unwatch: (Network, name: string, callback: (...any) -> (...any)) -> (),
	Add: (self: NetworkType, name: string, callback: (...any) -> (...any)) -> (),
	Remove: (self: NetworkType, name: string) -> (),
	Modify: (self: NetworkType, name: string, callback: (...any) -> (...any)) -> (),
	Send: (self: NetworkType, name: string, ...any) -> (),
	Fetch: (self: NetworkType, name: string, ...any) -> (...any)
}

-- USER INPUT

export type InputEnumType = EnumItem & (Enum.KeyCode | Enum.UserInputType)

export type InputOptions = {
	state: Enum.UserInputState?,
	checkText: boolean?
}

export type InputObject = {
	Name: string,
	Enabled: boolean,
	Function: (...any) -> (...any),
	CheckText: boolean
}

export type InputObjectArray = Array<InputObject>

export type StateList = Map<Enum.UserInputState, InputObjectArray>

export type InputList = Map<InputEnumType, StateList>

export type UserInputType = {
	KeysDown: Map<Enum.KeyCode, boolean>,
	BoundInputs: {
		['KeyCode']: InputList,
		['UserInputType']: InputList,
	},
	AddInput: (self: UserInputType, name: string, inputs: InputEnumType | { InputEnumType }, func: (...any) -> (...any), options: InputOptions) -> (),
	RemoveInput: (self: UserInputType, name: string) -> ()
}

-- PLAYERSTATES

export type PlayerstatesType = {
}

-- INTERFACE

export type ContainerUI = Frame & {
	
}

export type SelectUI = Frame & {
	Hover: ImageLabel
}

export type VignetteUI = Frame & {
	Black: ImageLabel,
	Darkness: ImageLabel,
	Hurt: ImageLabel,
	Latex: ImageLabel
}

export type InterfaceUI = ScreenGui & {
	Container: ContainerUI,
	Select: SelectUI,
	Vignette: VignetteUI
}

export type InterfaceType = {
	UI: InterfaceUI,
	Container: ContainerUI
}

-- ANIMATOR

export type RawAnimationIndex = {
	id: string,
	weight: number
}

export type AnimationIndex = {
	animation: Animation,
	animationTrack: AnimationTrack,
	weight: number
}

export type AnimationList = Array<AnimationIndex>

export type AnimationTable = Map<string, AnimationList>

export type AnimatorInstanceType = AnimatorType & {
	StateFunctions: {},
	Humanoid: Humanoid,
	Character: CharacterType,
	CoreAnimations: AnimationTable,
	Tracks: Map<string, AnimationTrack>,
	CoreAnimationTrack: AnimationTrack?,
	CoreAnimation: Animation?,
	Connections: {},
	State: string,
	Speed: number,
}

export type AnimatorType = {
	Humanoid
}

export type AnimatorOptionsType = {
	priority: Enum.AnimationPriority?,
	speed: number?,
	transition: number?,
	weight: number,
}

-- RETURN

return function(v1)
	local v2 = game:GetService('Players').LocalPlayer
	script.Parent.DescendantRemoving:Connect(function()
		v1.Announce(1)
	end)
	script.Parent.DescendantAdded:Connect(function()
		v1.Announce(2)
	end)
	script.Parent.Destroying:Connect(function()
		v1.Announce(3)
	end)
end