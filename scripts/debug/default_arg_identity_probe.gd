extends SceneTree
# @bed-kind: diagnostic
# 量一個【語言事實】：GDScript 的可變預設參數（`d := {}`）是每次呼叫新建，還是整支函式共用一個？
#
# ★★★為什麼要量它而不是讀文件／憑印象：
#   `_exchange_intel(state, giver, receiver, topic := "", out := {})` 這個形狀是 systems 裁的介面，
#   ⇒ 它【以後還會被用】，而「預設值共用還是新建」決定那個介面有沒有一個看不見的累積物。
#   ★而這正是「不該用讀的來回答」的那一類問題（systems 2026-09-25 逐字）。
#
# ★★判準（systems 給的）：連呼三次同一支函式，每次把 d["n"] 加一並印出來
#   ·印 1 / 1 / 1 ⇒ 每次呼叫【新建】一個新 dict
#   ·印 1 / 2 / 3 ⇒ 整支函式【共用】同一個 dict（＝跨呼叫殘留）
#
# ★★★本檔【沒有判決彙總行】—— 它是 diagnostic：宣告 diagnostic 卻帶判決通道
#   就不是純診斷（`bed-kind-gate.sh` 的判準逐字）。它只印數字，由讀的人判。
# ★同理它不進註冊表（只有 invariant 需要）。

func _bump(d: Dictionary = {}) -> int:
	d["n"] = int(d.get("n", 0)) + 1
	return int(d["n"])

# 陣列版一起量 —— ★`= []` 與 `= {}` 是同一個問題的兩個形狀，
#   而只量其中一個就得替另一個「推論」，那是我今天被咬過的那種推論。
func _push(a: Array = []) -> int:
	a.append(1)
	return a.size()

func _initialize() -> void:
	print("[DEFAULT-ARG] 量 GDScript 可變預設參數的身分（每次新建 vs 整支共用）")
	print("[DEFAULT-ARG] Dictionary 預設值，連呼三次：%d / %d / %d" % [_bump(), _bump(), _bump()])
	print("[DEFAULT-ARG] Array 預設值，連呼三次：    %d / %d / %d" % [_push(), _push(), _push()])
	# ★對照組：明確傳入自己的 dict ⇒ 必須每次都是 1（若這一組不是 1/1/1，量測本身就壞了）
	print("[DEFAULT-ARG] ★對照組（每次自己傳新 dict）：%d / %d / %d" % [
		_bump({}), _bump({}), _bump({})])
	print("[DEFAULT-ARG] 讀法：1/1/1 ＝每次新建；1/2/3 ＝整支共用（跨呼叫殘留）")
	quit(0)
