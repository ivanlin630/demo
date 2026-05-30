# scripts/ui/debug_bar.gd
extends PanelContainer

var _bridge: SimBridge
var _lbl: Label

func setup(bridge: SimBridge) -> void:
	_bridge = bridge
	_build_ui()
	refresh()

func _build_ui() -> void:
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 0)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	add_child(scroll)

	_lbl = Label.new()
	_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	scroll.add_child(_lbl)

func refresh() -> void:
	if _bridge == null or _lbl == null: return
	var state: WorldState = _bridge.get_state()
	var lines: Array = []

	# Tick
	lines.append("【Tick %d | Turn %d】" % [
		state.world.current_tick, state.world.current_turn])

	# Teams
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var mt: String = "(%d,%d)" % [t.move_target.x, t.move_target.y] \
			if t.move_target != Vector2i(-1, -1) else "無"
		lines.append("Team%d pos(%d,%d) move→%s task=%s pop=%d" % [
			tid, t.tile_pos.x, t.tile_pos.y, mt, t.current_task, t.population])

	# Messages (last 5)
	lines.append("── 訊息 ──")
	var msgs: Array = state.messages if state.get("messages") != null else []
	var start: int = maxi(0, msgs.size() - 5)
	for i in range(start, msgs.size()):
		var m = msgs[i]
		lines.append(str(m.get("text", m.get("type", str(m)))))

	_lbl.text = "\n".join(lines)
