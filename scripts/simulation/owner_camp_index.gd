class_name OwnerCampIndex

# ★★★own-camp-in-decision-model：owner → 自家 L0 營地 tile 的索引。
#
# ★為什麼是【姊妹索引】而不是塞進 `OwnerOutpostIndex._oo_map`（reviewer 2026-09-03 訂正）：
#   outpost 與 camp 是【不同欄位】（`outpost_owner`/`outpost_level` vs `camp_team_id`/`camp_level`）
#   ⇒ ★★同一張 map 表達不了兩種所有權。★★★複製的是【那套機制】，不是共用那張表。
#
# ★★語意（與 OwnerOutpostIndex 同慣例，故意抄）：
#   「`world.tiles` 迭代序中，第一個 `camp_level > 0` 且 `camp_team_id == X` 的 tile」
#   ⇒ 一隊多營時回哪一個【取決於插入序】——★整表重建天然重現同一個選擇（禁增量 patch）。
#
# ★★★失效 chokepoint（三處，與 `camp_team_id` 的寫入/清除點一一對應）：
#   ①寫：`faction_ai_system.gd::establish_crude_camp`（設 camp_team_id）
#   ②清：`harvest_system.gd`（camp_ticks_left 耗盡 → camp_level=0、camp_team_id=-1）
#   ③清：`outpost_system.gd`（L0 升 L1 → 清 camp_team_id）
#   ★漏掉任何一處 ⇒ 索引會指向【已經不存在的營地】，而那正是 shadow 對帳要抓的病。
static var epoch: int = 1

# ★影子對照（gate①）：debug bed 開啟後，每次查詢都同時跑舊全圖掃並比對。
#   ★★production 預設 false ＝ 單一 static bool 判斷，零行為零 RNG。
#   ★★★這一整套是從 OwnerOutpostIndex 抄來的 —— 抄它的理由是「索引與真值漂掉」正是它被造出來抓的病。
static var shadow: bool = false
static var shadow_checks: int = 0
static var shadow_fails: int = 0

static func invalidate() -> void:
	epoch += 1

static func shadow_reset() -> void:
	shadow_checks = 0
	shadow_fails = 0

# 影子對照：expect（舊全圖掃結果）vs got（索引結果）不等即印 team/tile 並記 FAIL。
static func shadow_check(tag: String, team_id: int, expect: Vector2i, got: Vector2i) -> void:
	shadow_checks += 1
	if expect != got:
		shadow_fails += 1
		print("[OwnerCampIndex][SHADOW-FAIL] %s team=%d expect=%s got=%s" % [tag, team_id, str(expect), str(got)])

# ★跨 run 清除（CrossRunReset 單一呼叫點）。
#   ★★`epoch` 【推版號而非歸零】——理由同 OwnerOutpostIndex：歸零會讓一個 `_oc_epoch == 1`
#     而中間被 invalidate 過的舊 state 誤判「我的表還新」⇒ ★★★靜默拿到 stale 索引。
static func _reset_cross_run() -> Dictionary:
	var cleared: Dictionary = {}
	if shadow_checks != 0 or shadow_fails != 0:
		cleared["OwnerCampIndex.shadow_counters"] = "%d/%d" % [shadow_checks, shadow_fails]
	shadow_reset()
	invalidate()
	return {"checked": 3, "cleared": cleared}
