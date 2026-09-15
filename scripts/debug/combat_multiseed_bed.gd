extends SceneTree
# @bed-kind: diagnostic
# 戰鬥面多 seed（HOW spec 2026-09-12-combat-multiseed-attribution）：★只印三個數，**不下判決**
#   ⇒ 判決（真趨勢／蝴蝶／趨勢成立幅度不可引用）在**交件**上做，因為它要**兩臂 × 三 seed 一起看**。
#
# ★★★前置的事實（我查過再寫）：本票要的三個指標，**tap 全部是 production 既有**：
#   ·開打 `conq.combat_entered`（`npc_combat_system.gd` start_combat 內）
#   ·滅團 `extinct.starve/combat/other`（`faction_ai_system.gd`）
#   ·勒索 `raid.extort`（`interaction_system.gd:505`）
#   ⇒ ★**它們在世代 2 的樹上就已經存在** ⇒ **spec §② 的 cherry-pick 前置，對這三格【不需要】**
#   ⇒ ★★而「第四種 0」的風險仍在別的欄位上（相遇／面對面／徵收）—— **那些欄位本票不收**。
# env：CM_TICKS（預設 43200 ＝ 30 天）／CM_SEED（必給）／CM_CONFIG（預設 warring_states）

func _initialize() -> void:
	_run(); quit(0)

func _run() -> void:
	var ticks: int = int(OS.get_environment("CM_TICKS")) if OS.has_environment("CM_TICKS") else 43200
	var seed_val: int = int(OS.get_environment("CM_SEED")) if OS.has_environment("CM_SEED") else 1337
	var cfg: String = OS.get_environment("CM_CONFIG") if OS.has_environment("CM_CONFIG") else "warring_states"
	print("=== 戰鬥面多 seed（%d tick ＝ %.1f 天｜seed=%d｜%s）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), seed_val, cfg])
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for _t in range(ticks):
		runner.advance_tick(st, no_player)
	var ext_s: int = int(Probe.counts.get("extinct.starve", 0))
	var ext_c: int = int(Probe.counts.get("extinct.combat", 0))
	var ext_o: int = int(Probe.counts.get("extinct.other", 0))
	print("")
	print("★三個指標（★母體＝這一趟整窗；★★每一格只屬於【這一臂 × 這一個 seed】）")
	print("   開打 conq.combat_entered = %d" % int(Probe.counts.get("conq.combat_entered", 0)))
	print("   結束 combat.ended_n      = %d" % int(Probe.counts.get("combat.ended_n", 0)))
	print("   滅團 合計                = %d（餓 %d／戰 %d／其他 %d）" % [ext_s + ext_c + ext_o, ext_s, ext_c, ext_o])
	print("   勒索 raid.extort         = %d" % int(Probe.counts.get("raid.extort", 0)))
	print("★★這張床【不下判決】：真趨勢／蝴蝶／幅度不可引用，要兩臂 × 三 seed 一起看才判得出")
	print("★fp = %s" % StateFingerprint.compute(st))
	# ★★★本床【真的不下判決】⇒ 就不該有判決通道（bed-kind 閘點名，2026-09-15）：
	#   ★舊寫法是一個寫死的失敗數字欄位（這裡不寫出它的字面，否則閘會咬到這句註解）—— **一個永遠不會紅的字段**，
	#     ★★而它在畫面上與【真的全過】長得一模一樣 ⇒ 正是今天一直在拆的那種通道。
	#   ★★★判決（真趨勢／蝴蝶／幅度不可引用）在**交件**上做 —— 它要兩臂 × 三 seed 一起看。
	#   ★而【跑完了】仍然要有一個記號，否則【被殺】與【跑完】分不出來：
	#     ⇒ 用一個**不帶判決語義**的完成行。
	print("-- 量測完成（本床不下判決） --")
