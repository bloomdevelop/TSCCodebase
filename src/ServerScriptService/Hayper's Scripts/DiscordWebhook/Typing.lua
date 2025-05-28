--!strict
-- Ported from https://github.com/discordjs/discord-api-types
--------------------------------------------------------------------

type Array<T> = {[number]: T}

--------------------------------------------------------------------

type Snowflake = string
type Permissions = string

--------------------------------------------------------------------

export type RESTPostAPIWebhookWithTokenJSONBody = {
	content: string?,
	username: string?,
	avatar_url: string?,
	tts: boolean?,
	embeds: Array<APIEmbed>?,
	allowed_mentions: APIAllowedMentions?,
	components: Array<APIActionRowComponent<APIMessageActionRowComponent>>?,
	attachments: Array<APIAttachment>,
	flags: MessageFlags?,
	thread_name: string?
}

--------------------------------------------------------------------

export type APIGuildMember = {
	user: APIUser?,
	nick: (string | nil)?,
	avatar: (string | nil)?,
	roles: Array<Snowflake>,
	joined_at: string,
	premium_since: (string | nil)?,
	deaf: boolean,
	mute: boolean,
	pending: boolean?,
	communication_disabled_until: (string | nil)?
}

--------------------------------------------------------------------

export type InteractionType = number

export type PartialAPIMessageInteractionGuildMember = APIGuildMember | ('roles' | 'premium_since' | 'pending' | 'nick' | 'mute' | 'joined_at' | 'deaf' | 'communication_disabled_until' | 'avatar')

export type APIMessageInteraction = {
	id: Snowflake,
	type: InteractionType,
	name: string,
	user: APIUser,
	member: PartialAPIMessageInteractionGuildMember?
}

--------------------------------------------------------------------

export type APITeam = {
	icon: string | nil,
	id: Snowflake,
	members: Array<APITeamMember>,
	name: string,
	owner_user_id: Snowflake
}

export type APITeamMember = {
	membership_state: TeamMemberMembershipState,
	permissions: {'*'},
	team_id: Snowflake,
	user: APIUser
}

export type TeamMemberMembershipState = number

--------------------------------------------------------------------

export type OAuth2Scopes = 	'bot' | 'connections' |'dm_channels.read' |'email' |'identify' |'guilds' |'guilds.join' |'guilds.members.read' |'gdm.join' |'messages.read' |'rpc' |'rpc.notifications.read' |'webhook.incoming' |'voice' |'applications.builds.upload' |'applications.builds.read' |'applications.store.update' |'applications.entitlements' |'relationships.read' |'activities.read' |'activities.write' |'applications.commands' |'applications.commands.update' |'applications.commands.permissions.update'

--------------------------------------------------------------------

export type APIApplication = {
	id: Snowflake,
	name: string,
	icon: string | nil,
	description: string,
	rpc_origins: Array<string>?,
	bot_public: boolean,
	bot_require_code_grant: boolean,
	terms_of_service_url: string?,
	privacy_policy_url: string?,
	owner: APIUser?,
	summary: string,
	verify_key: string,
	team: APITeam | nil,
	guild_id: Snowflake?,
	primary_sku_id: Snowflake?,
	slug: string?,
	cover_image: string?,
	flags: ApplicationFlags,
	tags: Array<string>?,
	install_params: APIApplicationInstallParams?,
	custom_install_url: string?
}

export type APIApplicationInstallParams = {
	scopes: Array<OAuth2Scopes>;
	permissions: Permissions;
}

export type ApplicationFlags = number

--------------------------------------------------------------------

export type APISticker = {
	id: Snowflake,
	pack_id: Snowflake?,
	name: string,
	description: string | nil,
	tags: string,
	asset: ''?,
	type: StickerType,
	format_type: StickerFormatType,
	available: boolean?,
	guild_id: Snowflake?,
	user: APIUser?,
	sort_value: number?
}

export type StickerType = number

export type StickerFormatType = number

export type APIStickerItem = APISticker | ('id' | 'name' | 'format_type')

--------------------------------------------------------------------

export type APIPartialEmoji = {
	id: Snowflake | nil,
	name: string | nil,
	animated: boolean?
}

export type APIEmoji = {
	roles: Array<Snowflake>?,
	user: APIUser?,
	required_colons: boolean?,
	managed: boolean?,
	available: boolean?
} & APIPartialEmoji

--------------------------------------------------------------------

export type UserFlags = number

export type UserPremiumType = number

export type APIMessage = {
	id: Snowflake,
	channel_id: Snowflake,
	author: APIUser,
	content: string,
	timestamp: string,
	edited_timestamp: string | nil,
	tts: boolean,
	mention_everyone: boolean,
	mentions: Array<APIUser>,
	mention_roles: Array<Snowflake>,
	mention_channels: Array<APIChannelMention>?,
	attachments: Array<APIAttachment>,
	embeds: Array<APIEmbed>,
	reactions: Array<APIReaction>?,
	nonce: (string | number)?,
	pinned: boolean,
	webhook_id: Snowflake?,
	type: MessageType,
	activity: APIMessageActivity?,
	application: APIApplication, -- Partial
	application_id: Snowflake?,
	message_reference: APIMessageReference?,
	flags: MessageFlags?,
	referenced_message: APIMessage?,
	interaction: APIMessageInteraction?,
	thread: APIChannel?,
	components: Array<APIActionRowComponent<APIMessageActionRowComponent>>?,
	sticker_items: Array<APIStickerItem>?,
	stickers: Array<APISticker>?
}

--------------------------------------------------------------------

export type APIPartialChannel = {
	id: Snowflake,
	type: ChannelType,
	name: string?
}

export type APIChannelBase<T> = {
	type: T,
	flags: ChannelFlags?;
} & APIPartialChannel

export type TextChannelType = ChannelType

export type GuildChannelType = ChannelType

export type APITextBasedChannel<T> = {
	last_message_id: (Snowflake | nil)?
} & APIChannelBase<T>

export type APIGuildChannel<T> = {
	guild_id: Snowflake?,
	permission_overwrites: Array<APIOverwrite>?,
	position: number?,
	parent_id: (Snowflake | nil)?,
	nsfw: boolean?
} & APIChannelBase<T>

export type GuildTextChannelType = ChannelType

export type APIGuildTextChannel<T> = {
	default_auto_archive_duration: ThreadAutoArchiveDuration?,
	topic: (string | nil)?,
	last_pin_timestamp: (string | nil)?
} & APITextBasedChannel<T> & APIGuildChannel<T>

export type APITextChannel = {
	rate_limit_per_user: number?
} & APIGuildTextChannel<ChannelType>

export type APINewsChannel = APIGuildTextChannel<ChannelType>
export type APIGuildCategoryChannel = APIGuildChannel<ChannelType>

export type APIVoiceChannel = {
	bitrate: number?,
	user_limit: number?,
	rtc_region: (string | nil)?,
	video_quality_mode: VideoQualityMode?
} & APIGuildChannel<ChannelType>

type APIDMChannelBase<T> = {
	recipients: Array<APIUser>?
} & APITextBasedChannel<T>

export type APIDMChannel = APIDMChannelBase<ChannelType>

export type APIGroupDMChannel = {
	application_id: Snowflake?,
	icon: (string | nil)?,
	name: (string | nil)?,
	owner_id: Snowflake?,
	last_message_id: (Snowflake | nil)?
} & APIDMChannelBase<ChannelType>

export type APIThreadChannel = {
	member: APIThreadMember?,
	thread_metadata: APIThreadMetadata?,
	message_count: number?,
	member_count: number?,
	rate_limit_per_user: number?,
	owner_id: Snowflake?,
	last_message_id: (Snowflake | nil)?
} & APIGuildChannel<ChannelType>

export type APIGuildForumChannel = APIGuildTextChannel<ChannelType>

export type APIChannel = APIGroupDMChannel | APIDMChannel | APITextChannel | APINewsChannel | APIVoiceChannel | APIGuildCategoryChannel | APIThreadChannel | APINewsChannel | APIGuildForumChannel

export type ChannelType = number

export type VideoQualityMode = number

export type APIUser = {
	id: Snowflake,
	username: string,
	discriminator: string,
	avatar: string | nil,
	system: boolean?,
	mfa_enabled: boolean?,
	banner: (string | nil)?,
	accent_color: (number | nil)?;
	locale: string?;
	verified: boolean?;
	email: (string | nil)?;
	flags: UserFlags?;
	premium_type: UserPremiumType?;
	public_flags: UserFlags?;
}

export type MessageType = number

export type APIMessageActivity = {
	type: MessageActivityType,
	party_id: string?
}

export type APIMessageReference = {
	message_id: Snowflake?,
	channel_id: Snowflake,
	guild_id: Snowflake?
}

export type MessageActivityType = number

export type MessageFlags = number

export type APIReaction = {
	count: number,
	me: boolean,
	emoji: APIPartialEmoji
}

export type APIOverwrite = {
	id: Snowflake,
	type: OverwriteType,
	allow: Permissions,
	deny: Permissions
}

export type OverwriteType = number

export type APIThreadMetadata = {
	archived: boolean,
	auto_archive_duration: ThreadAutoArchiveDuration,
	archive_timestamp: string,
	locked: boolean?,
	invitable: boolean?,
	create_timestamp: string?
}

export type ThreadAutoArchiveDuration = number

export type APIThreadMember = {
	id: Snowflake?,
	user_id: Snowflake?,
	join_timestamp: string,
	flags: ThreadMemberFlags
}

export type ThreadMemberFlags = number
export type APIEmbed = {
	title: string?;
	type: EmbedType?,
	description: string?,
	url: string?,
	timestamp: string?,
	color: number?,
	footer: APIEmbedFooter?,
	image: APIEmbedImage?,
	thumbnail: APIEmbedThumbnail?,
	video: APIEmbedVideo?,
	provider: APIEmbedProvider?,
	author: APIEmbedAuthor?,
	fields: Array<APIEmbedField>?
}

export type APIEmbedThumbnail = {
	url: string,
	proxy_url: string?,
	height: string?,
	width: string?
}

export type APIEmbedVideo = {
	url: string,
	height: number?,
	width: number?
}

export type APIEmbedImage = {
	url: string,
	proxy_url: string?,
	height: number?,
	width: number?
}

export type APIEmbedProvider = {
	name: string?,
	url: string?
}

export type APIEmbedAuthor = {
	name: string,
	url: string?,
	icon_url: string?,
	proxy_icon_url: string?
}

export type APIEmbedFooter = {
	text: string,
	icon_url: string?,
	proxy_icon_url: string?
}

export type APIEmbedField = {
	name: string,
	value: string,
	inline: boolean?
}

export type EmbedType = "rich" | "image" | "video" | "gifv" | "article" | "link"

export type APIAttachment = {
	id: Snowflake,
	filename: string,
	description: string?,
	content_type: string?,
	size: number,
	url: string,
	proxy_url: string,
	height: (number | nil)?,
	width: (number | nil)?,
	ephemeral: boolean?
}

export type APIChannelMention = {
	id: Snowflake,
	guild_id: Snowflake,
	type: ChannelType,
	name: string
}

export type ApiChannelMention = {
	id: Snowflake,
	guild_id: Snowflake,
	type: ChannelType,
	name: string
}

export type AllowedMentionsTypes = "everyone" | "roles" | "users"

export type APIAllowedMentions = {
	parse: Array<AllowedMentionsTypes>?,
	roles: Array<Snowflake>?,
	users: Array<Snowflake>?,
	replied_user: boolean?
}

export type APIBaseComponent<T> = {
	type: T
}

export type ComponentType = number

export type APIActionRowComponent<T> = {
	components: Array<T>
} & APIBaseComponent<ComponentType>

export type  APIButtonComponentBase<Style> = {
	label: string?,
	style: Style,
	emoji: APIMessageComponentEmoji?,
	disabled: boolean?
} & APIBaseComponent<ComponentType>

export type APIMessageComponentEmoji = {
	id: Snowflake?,
	name: string?,
	animated: boolean?
}

export type APIButtonComponentWithCustomId = {
	custom_id: string
} & APIButtonComponentBase<ButtonStyle>

export type APIButtonComponentWithURL = {
	url: string
} & APIButtonComponentBase<ButtonStyle>

export type APIButtonComponent = APIButtonComponentWithCustomId | APIButtonComponentWithURL

export type ButtonStyle = number

export type TextInputStyle = number

export type APISelectMenuComponent = {
	custom_id: string,
	options: Array<APISelectMenuOption>,
	placeholder: string?,
	min_values: number?,
	max_values: number?,
	disabled: boolean?
} & APIBaseComponent<ComponentType>

export type APISelectMenuOption = {
	label: string,
	value: string,
	description: string?,
	emoji: APIMessageComponentEmoji?,
	default: boolean?
}

export type APITextInputComponent = {
	style: TextInputStyle,
	custom_id: string,
	label: string,
	placeholder: string?,
	value: string?,
	min_length: number?,
	max_length: number?,
	required: boolean?
} & APIBaseComponent<ComponentType>

export type ChannelFlags = number

export type APIMessageComponent = APIMessageActionRowComponent | APIActionRowComponent<APIMessageActionRowComponent>
export type APIModalComponent = APIModalActionRowComponent | APIActionRowComponent<APIModalActionRowComponent>

export type APIActionRowComponentTypes = APIMessageActionRowComponent | APIModalActionRowComponent

export type APIMessageActionRowComponent = APIButtonComponent | APISelectMenuComponent

export type APIModalActionRowComponent = APITextInputComponent

return nil