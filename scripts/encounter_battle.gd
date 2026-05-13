class_name EncounterBattle
extends RefCounted
## Minimal semi-real-time hex encounter simulation.

var active: bool = false
var finished: bool = false
var winner: String = ""   # "player" | "enemy"

var player_hp: int = 100
var enemy_hp: int = 80
var player_pos: Vector2i = Vector2i.ZERO
var enemy_pos: Vector2i = Vector2i(4, 0)
var seconds_per_step: float = 0.35

var _acc: float = 0.0
var _log: Array = []
var _rng: RandomNumberGenerator

func _init(seed_value: int = 1) -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = seed_value

func start(p_hp: int, e_hp: int) -> void:
	active = true
	finished = false
	winner = ""
	player_hp = p_hp
	enemy_hp = e_hp
	player_pos = Vector2i.ZERO
	enemy_pos = Vector2i(4, 0)
	_acc = 0.0
	_log = ["遭遇戰開始。"]

func update(delta: float) -> void:
	if not active or finished:
		return
	_acc += delta
	while _acc >= seconds_per_step and not finished:
		_acc -= seconds_per_step
		_step_once()

func get_status_text() -> String:
	if not active:
		return ""
	var recent: Array = _log.slice(max(0, _log.size() - 4))
	return (
		"[遭遇戰]\n"
		+ "你 HP: %d  敵 HP: %d\n" % [player_hp, enemy_hp]
		+ "你位置: %s  敵位置: %s\n" % [str(player_pos), str(enemy_pos)]
		+ "---\n"
		+ "\n".join(recent)
	)

func _step_once() -> void:
	if _hex_distance(player_pos, enemy_pos) <= 1:
		var p_dmg := _rng.randi_range(8, 14)
		var e_dmg := _rng.randi_range(6, 12)
		enemy_hp = max(0, enemy_hp - p_dmg)
		player_hp = max(0, player_hp - e_dmg)
		_log.append("你造成 %d 傷害，敵方造成 %d 傷害。" % [p_dmg, e_dmg])
	else:
		player_pos = _step_toward(player_pos, enemy_pos)
		enemy_pos = _step_toward(enemy_pos, player_pos)
		_log.append("雙方在六角格上接近中。")

	if enemy_hp <= 0:
		finished = true
		active = false
		winner = "player"
		_log.append("你贏得遭遇戰。")
	elif player_hp <= 0:
		finished = true
		active = false
		winner = "enemy"
		_log.append("你在遭遇戰中倒下。")

func _step_toward(from_pos: Vector2i, to_pos: Vector2i) -> Vector2i:
	var best := from_pos
	var best_dist := _hex_distance(from_pos, to_pos)
	for nb in _neighbors(from_pos):
		var d := _hex_distance(nb, to_pos)
		if d < best_dist:
			best_dist = d
			best = nb
	return best

func _neighbors(pos: Vector2i) -> Array:
	var result: Array = []
	var even_offsets := [
		Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(0, -1), Vector2i(-1, -1),
		Vector2i(0, 1), Vector2i(-1, 1),
	]
	var odd_offsets := [
		Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(1, -1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(0, 1),
	]
	var offsets := even_offsets if (pos.y % 2 == 0) else odd_offsets
	for d in offsets:
		result.append(pos + d)
	return result

func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	var ac := _odd_r_to_cube(a)
	var bc := _odd_r_to_cube(b)
	return int(max(abs(ac.x - bc.x), abs(ac.y - bc.y), abs(ac.z - bc.z)))

func _odd_r_to_cube(p: Vector2i) -> Vector3i:
	var x: int = p.x - int((p.y - (p.y & 1)) / 2)
	var z: int = p.y
	var y: int = -x - z
	return Vector3i(x, y, z)
