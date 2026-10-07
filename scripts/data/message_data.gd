class_name MessageData

var id: int = 0
var type: String = ""
var description: String = ""
var source_pos: Vector2i = Vector2i.ZERO
var origin_team_id: int = -1
var origin_tick: int = 0
var strength: float = 1.0
var is_distorted: bool = false
var params: Dictionary = {}

# ★打聽票 I1（spec 2026-10-07 inquiry-writes-what-it-says）：訊息的**唯一一份**複製 —— 搬自 message_system._copy_message
#   ★MessageData 是 RefCounted 不是 Resource ⇒ 沒有 `.duplicate()`（inquiry_system 偽造訊息那一行原本呼它 ⇒ SCRIPT ERROR，
#     NPC 該說謊時靜默失敗：量測員普查 276 次撞 24 次）
static func copy_of(original: MessageData) -> MessageData:
	var copy := MessageData.new()
	copy.id = original.id
	copy.type = original.type
	copy.description = original.description
	copy.source_pos = original.source_pos
	copy.origin_team_id = original.origin_team_id
	copy.origin_tick = original.origin_tick
	copy.strength = original.strength
	copy.is_distorted = original.is_distorted
	copy.params = original.params.duplicate()
	return copy
