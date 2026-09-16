extends SceneTree
# @bed-kind: acceptance
# slice: 攻擊幣別＋偵查進秤（HOW spec 2026-09-15-attack-currency-and-scout-on-the-scale §驗收）
#
# ★★★五格、三組成對（systems 派工原話）：
#   組一：①低情報目標**不出現**在攻擊候選 ／ ②情報補齊後**出現**（★同一個目標、同一個觀察者）
#   組二：③偵查**會輸** ／ ④早期窗偵查**真的出現過並贏過**
#   組三：⑤先驗被取代的**逐筆**證據（同一目標：全盲 → 有桶號 → 有可定價分項 ⇒ 不再是偵查候選）
#
# ★母體定義（先寫死在檔頭，★★不是看到數字才決定怎麼數）：
#   ·③的母體 ＝ `optpool.cand.偵查` ＝ **候選集裡真的有偵查的那些次 argmax**
#     ★★用【結構事實】篩，不用隊的情報標籤篩 —— 標籤是分類，候選集才是決策當下真的比較過的東西；
#     ★★★否則【生成失敗】會混進【生成後輸掉】，把勝率稀釋或扭曲。
#   ·④的早期窗 ＝ **第 0 天起算的前 SC_EARLY_DAYS 天**（★窗從哪一天起算必須印出來）
#   ·★★★④【只認新機制】（systems 裁 2026-09-15）：偵查有**兩條來源** ——
#     (A) 秤選出來（`optpool.win.偵查` / `recon.dispatch.engine.*`）
#     (B) `_commit_conquest_attack` 的舊走廊（`g3.scout_dispatch`，`task_reason == "scout"`）
#     ★(B) 在**早期窗最活躍**（`confident_enough` 最容易為假）
#     ⇒ ★★若不分流，④**會綠，而綠的原因是舊補丁不是新機制**。
#     ⇒ ★★★**兩個數都印**（不是只印新的）—— 因為它們的比例本身就是下一張票的證據。
#   ·晚窗 ＝ 全窗 − 早窗（同一趟的前綴／後綴，★中途不 reset ⇒ 沒有 reset 的效應不對稱問題）
#
# env：SC_TICKS（預設 43200 ＝ 30 天）／SC_EARLY_DAYS（預設 7）／SC_SEED（預設 1337）／SC_CONFIG
#
# ★★★【長窗跑法三條】（systems 2026-09-15，五輪無結果買來的）—— ★這是跑法，不是閘：
#   1. 起跑前印 `[HOST] start FreeMB=… TotalMB=…`（在呼叫端，不在本檔）
#      ★它是**判準**不是裝飾：harness 的低記憶體保護看的是【系統】可用記憶體，
#      ★★所以它殺的是【當下還在跑的那個】，**不是【吃最多的那個】**。
#   2. ★**跑完再印一次** ⇒ 「過程中 host 記憶體掉了多少」才看得見
#      （只印起跑那一次，答不出「是我們吃掉的還是別人吃掉的」）。
#   3. ★★**開長跑之前先看 FreeMB，低就不要開** ——
#      ★★★一輪 5000 秒的跑，開在一台記憶體已經吃緊的機器上，期望值是【無結果】。
#
# ★★【改 code 的成本不是「改」，是「驗」】：改完先 `--check-only`（秒級）再開長跑
#   —— ★**不要把【改】跟【5000 秒的跑】綁在同一步**：未驗的改動躺在樹上，下一輪誰跑誰踩。
#
# ★跨輪紀錄在 `docs/measurements/2026-09-15-scout-on-the-scale-run-ledger.md`（五輪、五種死法）。
#
# ★★★【每一欄最早在第幾天可判】（systems 2026-09-16 的第 1 條 —— ★這比 flush 更有用）：
#   ⇒ **能用 7 天窗答的，不要綁在 30 天窗上**；長窗只回答短窗答不了的那幾格。
#   ┌ 格①②⑤（零情報排除／補齊後出現／先驗被取代）  ＝ **day 0**：fixture，**不需要跑世界**
#   ├ 格⑥⑦（膽大者盲打／慎重者不可行）             ＝ **day 0**：同上（只改人格）
#   ├ 下界那兩格（算式接上了／最低單價 > 0）          ＝ **day 0**：純讀常數表
#   ├ 格③（偵查會輸）                               ＝ **day 1**：1 天窗就有數百次 argmax
#   ├ 格④（早期窗出現過並贏過）                      ＝ **day SC_EARLY_DAYS**（預設 7）
#   ├ 票乙①（PRODUCE 何時從 0 變非 0）               ＝ **day 4**（第 7 輪實測；★而這是【觀測值】不是設計值）
#   └ 票乙②③（據點／登記／交集）                     ＝ **任何一天**（純快照）⇒ ★所以現在改成逐段印
#   ★★**真正需要整整 30 天的欄位：目前一個都沒有** —— ★★★而那表示 30 天窗是【習慣】不是【需求】。
#
# ★★【窗戳】（第 3 條）：每天印 `[WINDOW] day=N/目標 status=running`，
#   收尾印 `status=completed`。⇒ ★**`27/30 外部截斷` ≠ `30/30 完成` ≠ `27/30 自持門檻停`**
#   —— **三者在一個「27」上長得一模一樣，而處置完全不同。**
#
# ★★★【明確不做】（systems 具名）：**WorldState checkpoint／續跑**。
#   本 codebase **沒有讀檔恢復世界狀態的路徑** ⇒ 真正的續跑要先做存檔，那是另一條大線。
#   ★具名地不做，**不是默默不做** —— 否則下一個人會以為它是待辦，然後去找它為什麼還沒做。
#
# ★★【本床靜音了哪些高 cap 診斷族】（必須明示，systems 2026-09-15）：
#   `poll.eventwake`、`poll.outcome`、`t0.emit_ctx`（cap 都是 40000）
#   ★它們的唯一讀者是 `scripts/debug/s5_poll_unique_value.gd` ⇒ 本輪一筆不讀 ＝ 純負擔。
#   ★★而靜音只掉樣本、計數器照數 ⇒ 判準不受影響；
#   ★★★**但下一個人會把「這一族沒樣本」讀成「它沒發生」** ⇒ 所以輸出裡也印一行。
#
# ★★★【本床兼答第二張票】（systems 2026-09-16：不要為一個欄位另起一輪）：
#   生產隊三母體數 —— ★全部是【讀世界狀態】，任何一輪 30 天窗都答得出，**差別只在有沒有人印**：
#   ①PRODUCE 隊數（★逐日 ⇒ **它什麼時候從 0 變成非 0**；
#     ★★而那把【還沒發生】與【不會發生】分開 —— 兩者在單一時點的快照上長得一模一樣）
#   ②擁有據點的隊數 ＋ 地形 ＋ **`outpost_type`**（★那幾個 `civilian` 是預置還是蓋的）
#   ③登記數（`work_outpost`）＋與前兩者的交集
#
# ★★★【跑法硬要求】：30 天窗必須明示 `GODOT_TIMEOUT=1800`（或更大）。
#   `tools/godot.ps1:84` 的預設是 **360 秒** ⇒ 30 天窗會在 **day 8 左右被殺**。
#   ★★而被殺的輸出長得像一份完整的日誌（只是短）——
#   ★★★**被殺 ≠ 紅 ≠ 綠**：看到 `[GODOT TIMEOUT ... process killed]` 就是**本輪無結果**，
#     不得當成「沒有紅」也不得當成「世界就長這樣」。
#
# ★★【贏】與【真的被設上】必須在**同一個母體、同一個呼叫點**上量（systems 2026-09-15）——
#   ★否則兩者的差額量的是【tap 的覆蓋率】，不是【世界的行為】。
#   （血證：`rank_scored` 有四個呼叫端，而第一版只在 `unified` 裝了 tap
#     ⇒ 差額長得跟「贏了卻沒派出去」一模一樣，而它是我沒接電的那三個迴圈。）

func _initialize() -> void:
	_run(); quit(0 if _fails == 0 else 1)

var _fails: int = 0

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fails += 1
		push_error("[FAIL] %s" % msg)

# ★具名紅：每一格紅都要說得出【是哪一種紅】（母體 0／判準不成立／對照失效）
func _red(msg: String) -> void:
	_fails += 1
	push_error("[FAIL] %s" % msg)

# ★★★【讀一個不存在的 Probe 鍵應該是【紅】不是【0】】（systems 通則 2026-09-16）：
#   ★血證：床讀 `attack.excluded.no_priced_belief`，而那個鍵當天被改名成 `zero_intel`
#     ⇒ **讀不到 ⇒ 印 0 ⇒ 看起來像「沒發生」** —— ★★而「沒發生」與「讀錯地方」在一個 0 上長得一樣。
#   ★★★而**不是每個 0 都該紅**：`dispatch.攻擊.ok` 不存在是【它真的一次都沒成功】——合法的 0。
#   ⇒ 所以分兩種讀法：
#     `_must(k)` ＝ **母體／分母那一類**：這一輪若跑過就一定存在 ⇒ **缺 ⇒ 具名紅**
#     `Probe.counts.get(k, 0)` ＝ **事件計數**：0 是合法答案
var _key_missing: Array = []

func _must(k: String) -> int:
	if not Probe.counts.has(k):
		_key_missing.append(k)
		_red("★讀不到必存在的 Probe 鍵 `%s` ⇒ **不可判**（★不是 0：鍵被改名／tap 沒接電都長這樣）" % k)
		return 0
	return int(Probe.counts[k])

static func _feasible_has(scan: Dictionary, tid: int) -> bool:
	for f in (scan.get("feasible", []) as Array):
		if int((f as Dictionary).get("id", -1)) == tid: return true
	return false

# ★★★【記憶體探針】（systems 2026-09-15，三輪被殺後裝）：逐日印鍵數與進程記憶體。
#   ★run2（timeout 2700）死在 day 21、run3（timeout 9000）**同樹同 seed** 死在 day 14（OOM）
#   ⇒ ★★世界是決定性的 ⇒ 兩輪到 day 14 為止吃的記憶體一樣
#   ⇒ ★★★**差異不在世界，在【機器當下有多少可用記憶體】** —— 而這台機器與用戶的遊戲共用。
#   ★而 `bump_pt`（`probe_stats.gd:89-93`）記的是**兩個獨立的鍵**：
#     `event+day_suffix` 與 `event+".team."+id` —— **不是 team×day 的交叉積**
#     ⇒ 鍵數 ≈ 71×天數 **＋** 71×隊數（相加），而不是相乘。
#     ★★但它仍然**對天數無界** ⇒ 這顆探針量的就是那個成長率。
# ★★★票乙式的逐日數（systems 2026-09-16）：PRODUCE 隊數**逐日**印。
#   ★純讀 `team.tags`，零 RNG、不寫 state。
#   ★★而它要回答的不是「有幾隊」，是**「它什麼時候從 0 變成非 0」** ——
#   ★★★單一時點的 0 答不出【還沒發生】與【不會發生】的差別。
# ★★★§C 快照抽成可重複呼叫（systems 2026-09-16 第 2 條）：
#   ★原本只在窗末印 ⇒ **第 7 輪死在 day 27，這三個數一個都沒撿到**
#   ⇒ ★★改成【每 7 天印一次】＋窗末再印一次 ⇒ **被殺 ＝ 損失最後幾天，不是損失全部**
#   ★★★而**交集的語意不變**：每一份快照內部仍然是**同一個時點**。
static func _snapshot_c(st: WorldState, day: int) -> void:
	var n_prod: int = 0
	var n_own: int = 0
	var n_reg: int = 0
	var n_prod_own: int = 0
	var n_own_reg: int = 0
	var n_prod_reg: int = 0
	var terr: Dictionary = {}
	var otype: Dictionary = {}
	for t in st.teams.values():
		if t == null: continue
		var is_prod: bool = TeamData.TAG_PRODUCE in t.tags
		var tile: HexTileData = st.own_outpost_tile(t.team_id)
		var has_own: bool = tile != null
		var has_reg: bool = t.work_outpost != Vector2i(-1, -1)
		if is_prod: n_prod += 1
		if has_own:
			n_own += 1
			terr[tile.terrain] = int(terr.get(tile.terrain, 0)) + 1
			var _ot: String = tile.outpost_type if tile.outpost_type != "" else "(空)"
			otype[_ot] = int(otype.get(_ot, 0)) + 1
		if has_reg: n_reg += 1
		if is_prod and has_own: n_prod_own += 1
		if has_own and has_reg: n_own_reg += 1
		if is_prod and has_reg: n_prod_reg += 1
	print("[SNAP-C] day=%d 母體=%d｜PRODUCE=%d｜擁有據點=%d 地形=%s outpost_type=%s｜登記=%d｜交集 P∩O=%d O∩R=%d P∩R=%d" % [
		day, st.teams.size(), n_prod, n_own, str(terr), str(otype), n_reg,
		n_prod_own, n_own_reg, n_prod_reg])

static func _produce_count(state: WorldState) -> int:
	var n: int = 0
	for t in state.teams.values():
		if t != null and (TeamData.TAG_PRODUCE in t.tags): n += 1
	return n

static func _mem_line(day: int) -> void:
	var n_samples_inst: int = 0
	for k in Probe.samples:
		n_samples_inst += (Probe.samples[k] as Array).size()
	print("[MEM] day=%d counts_keys=%d samples_keys=%d samples_inst=%d amounts_keys=%d static_mem_MB=%.1f" % [
		day, Probe.counts.size(), Probe.samples.size(), n_samples_inst, Probe.amounts.size(),
		float(OS.get_static_memory_usage()) / 1048576.0])
	# ★★★**指認到鍵** —— ★「樣本在長」答不出【哪一個在長】，
	#   而修法（調 cap／滑動窗）必須知道是哪一個。★★取前五大，每日一行。
	var tops: Array = []
	for k in Probe.samples:
		tops.append([String(k), (Probe.samples[k] as Array).size()])
	tops.sort_custom(func(a, b): return int(a[1]) > int(b[1]))
	var top_txt: Array = []
	for i in range(mini(5, tops.size())):
		top_txt.append("%s=%d" % [tops[i][0], int(tops[i][1])])
	print("[MEM]   top5_samples: %s" % " ".join(top_txt))

func _run() -> void:
	var ticks: int = int(OS.get_environment("SC_TICKS")) if OS.has_environment("SC_TICKS") else 43200
	var early_days: int = int(OS.get_environment("SC_EARLY_DAYS")) if OS.has_environment("SC_EARLY_DAYS") else 7
	var seed_val: int = int(OS.get_environment("SC_SEED")) if OS.has_environment("SC_SEED") else 1337
	var cfg: String = OS.get_environment("SC_CONFIG") if OS.has_environment("SC_CONFIG") else "warring_states"
	print("=== 偵查進秤 驗收（%d tick ＝ %.1f 天，%s，seed=%d）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg, seed_val])

	# ══════════ §A 逐筆 fixture（①②⑤）——★在【它自己的世界】上做，不污染下面那趟 ══════════
	# ★★這三格不靠跑世界，靠【同一個 (觀察者, 目標) 對】在三種情報狀態下各問一次
	#   ⇒ ★★★成對的兩半共用同一個主體 ⇒ 差異只能來自情報，不可能來自「換了一隊」。
	seed(seed_val)
	var fx: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	# ★★★選對的判準要接【掃描自己的排除順序】：`attack_scan` 是
	#   same_faction → no_belief → belief_pos → **unreachable（continue）** → 才輪到 no_priced_belief
	#   ⇒ ★隨便抓一對會先死在 unreachable，而那時【①看起來還是綠的】（不在候選集）
	#   —— ★★而它綠的理由是錯的。所以這裡挑**距離最近**的異派系對。
	var obs: TeamData = null
	var tgt: TeamData = null
	var best_d: int = 1 << 30
	for a in fx.teams.values():
		if a == null or a.leader_id == -1 or fx.persons.get(a.leader_id) == null: continue
		for b in fx.teams.values():
			if b == null or a.team_id == b.team_id: continue
			if a.faction_id != -1 and a.faction_id == b.faction_id: continue
			var d: int = FactionAISystem._hex_dist(a.tile_pos, b.tile_pos)
			if d < best_d:
				best_d = d
				obs = a; tgt = b
	if obs == null or tgt == null:
		_red("§A 母體 0：找不到【有領袖 + 異派系】的隊對 ⇒ ①②⑤ 三格【不可判】，不是綠")
		return
	print("")
	print("★§A 逐筆 fixture：觀察者 Team%d、目標 Team%d（★同一對，只換情報）｜距離 %d 格" % [obs.team_id, tgt.team_id, best_d])

	# 清掉這一對既有的情報，從【全盲】起算
	if fx.team_intel.has(obs.team_id):
		(fx.team_intel[obs.team_id] as Dictionary).erase(tgt.team_id)
	var disc: Array = fx.team_discovered.get(obs.team_id, [])
	if not (tgt.team_id in disc):
		disc.append(tgt.team_id)
		fx.team_discovered[obs.team_id] = disc

	var ldr: PersonData = fx.persons.get(obs.leader_id)

	# ── ★★★狀態0：**連 claim 都沒有** ＝ 真・零情報（systems 訂正 2026-09-16）──
	#   ★舊版這一格寫成「只有 tile_pos 的全盲」—— ★★而那在新制下是 **(b)「有 claim、不知道它多肥」**，
	#   ★★★**不該被排除**（`vision_system.gd:150` 的 population_est 無條件寫 ⇒ 遠距 belief 就長這樣）。
	var scan0: Dictionary = FactionAISystem.attack_scan(fx, obs, ldr)
	var in0: bool = _feasible_has(scan0, tgt.team_id)
	print("      why0=%s" % str(scan0["why"]))
	print("   狀態0【連 claim 都沒有】：進攻擊可行集合=%s" % str(in0))
	_ok(not in0, "①真・零情報（連 claim 都沒有）**不進攻擊候選**")
	_ok(int((scan0["why"] as Dictionary).get("no_belief", 0)) >= 1,
		"①-a 排除理由落在 **`no_belief`**（★★而那是【既有】的守衛，不是本票新加的）")
	# ★★★而本票新加的那一支（`bel.is_empty()` ⇒ `attack.excluded.zero_intel`）**可能是死碼**：
	#   `has_belief`（`faction_ai_system.gd:272`）在它【之前】 ⇒ 沒有 claim 的目標根本走不到它。
	#   ⇒ ★所以這裡**把它的實跑次數印出來** —— **「裝了一支永遠不會 fire 的守衛」與「沒裝」一樣危險，
	#     而且更難發現，因為它看起來在做事。**
	print("   ★（本票曾在此加一支結構排除，實測 0 次 fire ⇒ 2026-09-16 刪碼；真守衛是 `has_belief`）")

	# ── 狀態1：(b) 有 claim、只有位置（**不該被排除**）──
	BeliefSystem.record_claim(fx, obs.team_id, tgt.team_id, obs.team_id, "firsthand",
		{"tile_pos": tgt.tile_pos}, 1.0, false)
	var scan1: Dictionary = FactionAISystem.attack_scan(fx, obs, ldr)
	var in1: bool = _feasible_has(scan1, tgt.team_id)
	var pick1: Dictionary = DecisionContext.pick_recon_target(fx, obs)
	print("      why1=%s" % str(scan1["why"]))   # ★紅了要看得出是哪一道排除擋的
	print("   狀態1【全盲】：進攻擊可行集合=%s｜偵查挑中=%s（blind=%s，value=%.3f）" % [
		str(in1), str(int(pick1["id"]) == tgt.team_id), str(pick1["blind"]), float(pick1["value"])])
	print("   狀態1【(b) 有 claim、無資產欄】：進攻擊可行集合=%s" % str(in1))
	_ok(in1, "①-b **(b) 不被排除** —— ★「不知道它多肥」是【誠實的無知】，不是判死"
		+ "（★★richness 缺席，靠 weakness／border 競爭）")
	_ok(int(pick1["id"]) == tgt.team_id and bool(pick1["blind"]),
		"⑤-a 全盲那一刻：它是偵查候選，而且用的是**具名先驗**（blind=true）")

	# ── ★★★桶下界的【前提】那一格（systems 2026-09-16）──
	#   ★舊寫法 `floor = N` 成立，靠的是「所有單價 ≥ 1」—— **一個沒寫下來的巧合**
	#   ⇒ ★★新寫法 `floor = N × min(BASE_PRICE)` **零假設** ⇒ 那個前提從此不必成立。
	#   ★★★所以這一格驗的不是「最低單價是多少」，而是**下界真的乘了它** ——
	#     驗一個數等於多少會在調價時假紅；驗【算式接上了】才是這一格要的東西。
	var _minp: float = FactionAISystem.min_base_price()
	print("   ★桶下界：min(BASE_PRICE) = %.2f｜bucket_units(2) = %.0f｜bucket_floor(2) = %.1f" % [
		_minp, FactionAISystem.bucket_units(2), FactionAISystem.bucket_floor(2)])
	_ok(is_equal_approx(FactionAISystem.bucket_floor(2), FactionAISystem.bucket_units(2) * _minp),
		"下界-a **算式接上了**（floor ＝ 件數 × 最低單價）⇒ ★「所有單價 ≥ 1」那個前提**不再被依賴**")
	_ok(_minp > 0.0,
		"下界-b 最低單價 > 0（★若有人加了一個 0 價資源，下界會塌成 0 ⇒ 這一格會紅）")

	# ── ★★★【粒度那一半】成對（systems 裁 2026-09-16）──
	#   ★裁定是「**粒度不擋人，它讓你估得低**」⇒ 粒度透過【值】生效，不透過閘。
	#   ⇒ ★★所以要驗的是：**桶號 1 的目標與桶號 3 的目標，`richness` 不同且單調**
	#   ⇒ ★★★**否則「粒度有生效」與「粒度被忽略」分不開** —— 兩者都會讓這一格沒有紅。
	var _ref_obs: float = FactionAISystem.reference_wealth(fx, obs)
	var _r1: float = FactionAISystem.richness_compressed(FactionAISystem.bucket_floor(1), _ref_obs)
	var _r2: float = FactionAISystem.richness_compressed(FactionAISystem.bucket_floor(2), _ref_obs)
	var _r3: float = FactionAISystem.richness_compressed(FactionAISystem.bucket_floor(3), _ref_obs)
	print("   ★粒度→值（ref=%.1f）：桶1 richness=%.4f｜桶2 %.4f｜桶3 %.4f" % [_ref_obs, _r1, _r2, _r3])
	_ok(_r1 < _r2 and _r2 < _r3,
		"粒度-a 桶號越大 `richness` 越高且**嚴格單調**（★不是相等 ⇒ 粒度真的有生效）")
	_ok(_r1 > 0.0,
		"粒度-b 最小的桶也 **> 0**（★★若它是 0，「看不清」就又被算成「一無所有」了）")
	_ok(_r3 < FactionAISystem.TEAM_RICHNESS_CAP,
		"粒度-c 最大的桶仍 **< CAP**（★壓縮是漸近的，不會有人頂到天花板而分不出來）")
	print("      ★★而這一格是【day 0 可判】：它純讀常數表與算式，**不需要跑世界**。")

	# ── 狀態2：有桶號（resource_scale）—— ★仍然答不出 coin 當量 ──
	BeliefSystem.record_claim(fx, obs.team_id, tgt.team_id, obs.team_id, "firsthand",
		{"tile_pos": tgt.tile_pos, "resource_scale": 2}, 1.0, false)
	var scan2: Dictionary = FactionAISystem.attack_scan(fx, obs, ldr)
	var in2: bool = _feasible_has(scan2, tgt.team_id)
	var pick2: Dictionary = DecisionContext.pick_recon_target(fx, obs)
	print("      why2=%s" % str(scan2["why"]))   # ★紅了要看得出是哪一道排除擋的
	print("   狀態2【只有桶號】：進攻擊可行集合=%s｜偵查挑中=%s（blind=%s，value=%.3f）" % [
		str(in2), str(int(pick2["id"]) == tgt.team_id), str(pick2["blind"]), float(pick2["value"])])
	# ★★★這一格【語意變了】（票 final 2026-09-16）：舊制「只有桶號 ⇒ 一律排除」，
	#   新制是「只有桶號 ⇒ **由人格決定**」⇒ ★**舊斷言在新制下是錯的，不是紅的**。
	#   ★★我沒有把它刪掉，而是**改成新制的斷言**：桶號那一層不該是【世界規則】。
	_ok(in2, "①-c（**已改語意**）只有桶號 ⇒ **不再是一律排除**，交給下面⑥⑦的人格那一層判")
	_ok(int(pick2["id"]) == tgt.team_id and not bool(pick2["blind"]),
		"⑤-b 桶號一到手，**先驗就不再參與**（blind 由 true 轉 false）⇒ 守衛③第一段逐筆證據")

	# ── ★★★⑥⑦ 成對：**同一目標、同一觀察者、只換人格**（票 final 2026-09-16）──
	#   ★薄情報（只有桶號）那一層【由人格決定】：`confident_enough(…, 慎重)`
	#   ⇒ ★★膽大者可盲打（⑥）／慎重者該目標不可行（⑦）
	#   ★★★兩格必須用**同一個目標**：換目標的話，差異可能來自目標而不是人格。
	#   ★而這裡直接改 fixture leader 的「慎重」再改回來 —— **只在 fixture 世界，不在被量的那一輪**。
	var _caution_backup: float = float(ldr.values.get("慎重", 0.5)) if ldr != null else 0.5
	var in_bold: bool = false
	var in_caut: bool = false
	if ldr != null:
		ldr.values["慎重"] = 0.02
		in_bold = _feasible_has(FactionAISystem.attack_scan(fx, obs, ldr), tgt.team_id)
		ldr.values["慎重"] = 0.98
		in_caut = _feasible_has(FactionAISystem.attack_scan(fx, obs, ldr), tgt.team_id)
		ldr.values["慎重"] = _caution_backup
	print("   ★⑥⑦【薄情報 × 人格】同一目標：膽大者(慎重0.02) 進候選=%s｜慎重者(慎重0.98) 進候選=%s" % [
		str(in_bold), str(in_caut)])
	_ok(in_bold, "⑥**膽大者真的盲打過**（薄情報目標對他可行）")
	# ★★★⑦ 在【親見】的薄情報上**不成立，而那是機制的事實不是 bug**：
	#   `confident_enough` 讀 `uncertainty`（來源可信度＋新鮮度）⇒ **親眼看到 ＝ 滿檔信心**
	#   ⇒ ★再慎重的人也 confident ⇒ ★★**這一格量不到人格**。
	#   ⇒ ★★★所以⑦改由下面【轉述】那一組承擔，而**這一格照實報，不假裝它證明了人格**。
	print("   ⑦-firsthand：慎重者 進候選=%s（★親見的桶號 ⇒ 信心滿檔 ⇒ 預期兩人都進，**不入判**）" % str(in_caut))
	print("      ★★而若兩格同綠或同紅 ⇒ `confident_enough` 在這個情報狀態下**對慎重不敏感**，")
	print("         ⇒ ★★★那不是「人格沒差別」，是**這一格量不到人格** —— 兩者處置不同。")

	# ── ★★★⑥⑦ 第二組：**轉述來源**的薄情報（systems 要的「人格那一層」真正的用武之地）──
	#   ★上一組（firsthand 薄情報）兩格同綠 —— ★★而那**不是「人格沒差別」**：
	#     `confident_enough` 讀的是 `uncertainty`（**來源可信度＋新鮮度**），
	#     而**親眼看到一個桶號**＝可信度滿檔 ⇒ **再慎重的人也confident**。
	#   ⇒ ★★★**它量的是【情報可不可信】，不是【情報夠不夠細】** —— 兩者是不同的軸。
	#   ⇒ 所以這裡換成**轉述**（source ≠ 觀察者、credibility 低）再問一次同一對人格。
	var _third: TeamData = null
	for c3 in fx.teams.values():
		if c3 != null and c3.team_id != obs.team_id and c3.team_id != tgt.team_id:
			_third = c3
			break
	var in_bold2: bool = false
	var in_caut2: bool = false
	if _third != null and ldr != null:
		if fx.team_intel.has(obs.team_id):
			(fx.team_intel[obs.team_id] as Dictionary).erase(tgt.team_id)
		BeliefSystem.record_claim(fx, obs.team_id, tgt.team_id, _third.team_id, "hearsay",
			{"tile_pos": tgt.tile_pos, "resource_scale": 2}, 0.3, false)
		ldr.values["慎重"] = 0.02
		in_bold2 = _feasible_has(FactionAISystem.attack_scan(fx, obs, ldr), tgt.team_id)
		ldr.values["慎重"] = 0.98
		in_caut2 = _feasible_has(FactionAISystem.attack_scan(fx, obs, ldr), tgt.team_id)
		ldr.values["慎重"] = _caution_backup
	print("   ★⑥⑦-2【轉述薄情報 × 人格】：膽大者 進候選=%s｜慎重者 進候選=%s（來源=Team%d，credibility 0.3）" % [
		str(in_bold2), str(in_caut2), _third.team_id if _third != null else -1])
	_ok(in_bold2 != in_caut2,
		"⑥⑦-2 **轉述**的薄情報上，人格真的把兩人分開（★★這一格才是「膽大者盲打」的用武之地）")
	print("      ★而兩組並排讀才有意義：**親見的桶號**人人敢打／**聽說的桶號**只有膽大者敢打")
	print("      ★★⇒ `confident_enough` 的軸是【可信度】不是【粒度】 —— ★★★而 spec 說的『薄情報』是【粒度】。")

	# 狀態3 之前把情報還原成 firsthand（★不要讓上面那一格的轉述污染後面的判準）
	if fx.team_intel.has(obs.team_id):
		(fx.team_intel[obs.team_id] as Dictionary).erase(tgt.team_id)
	BeliefSystem.record_claim(fx, obs.team_id, tgt.team_id, obs.team_id, "firsthand",
		{"tile_pos": tgt.tile_pos, "resource_scale": 2}, 1.0, false)

	# ── 狀態3：有可定價分項（coin/food/material）──
	BeliefSystem.record_claim(fx, obs.team_id, tgt.team_id, obs.team_id, "firsthand",
		{"tile_pos": tgt.tile_pos, "resource_scale": 2, "coin_est": 300.0,
		"food_est": 120.0, "population_est": float(tgt.population)}, 1.0, false)
	var scan3: Dictionary = FactionAISystem.attack_scan(fx, obs, ldr)
	var in3: bool = _feasible_has(scan3, tgt.team_id)
	var pick3: Dictionary = DecisionContext.pick_recon_target(fx, obs)
	print("      why3=%s" % str(scan3["why"]))   # ★紅了要看得出是哪一道排除擋的
	print("   狀態3【有可定價分項】：進攻擊可行集合=%s｜偵查挑中=%s" % [
		str(in3), str(int(pick3["id"]) == tgt.team_id)])
	_ok(in3, "②情報補齊後**出現**在攻擊候選（★★與①同目標同觀察者 ⇒ 差異只能來自情報）")
	_ok(int(pick3["id"]) != tgt.team_id,
		"⑤-c 真情報到手 ⇒ **它不再是偵查候選** ⇒ 守衛③【先驗必須被取代】逐筆坐實")
	print("   ★★★而②若與①同紅／同綠 ⇒ 判準沒有鑑別力；兩格必須【方向相反】才算成對。")
	_ok(in3 != in0, "②-b 成對檢查：**狀態0（真零情報）與狀態3（有分項）方向相反**"
		+ "（★而狀態1／2 現在都在【可行】那一側，成對要拿真正的兩端比）")

	# ══════════ §B 真世界跑一趟（③④）══════════
	Probe.reset()
	Probe.arm()
	# ★★★【靜音別人的診斷桶】（systems 2026-09-15）：這三族的**唯一讀者**是
	#   `scripts/debug/s5_poll_unique_value.gd`（另一支床）⇒ ★**本輪一筆都不讀** ⇒ 純負擔。
	#   ★★它們的 cap 是 **40000**（`decision_tier.gd:118,137`、`world_events.gd:86`）
	#   ⇒ ★★★**寫得像上限的上限**：語法上有界，記憶體上等於沒有。
	#   ★靜音只掉【樣本】，**計數器仍然在數** ⇒ 決策、決定性、任何判準都不受影響。
	Probe.sample_mute = {"poll.eventwake": true, "poll.outcome": true, "t0.emit_ctx": true}
	print("★本輪靜音的診斷樣本族（★必須印出來：否則下一個人會把「沒樣本」讀成「沒發生」）：%s" % [
		str(Probe.sample_mute.keys())])
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var early_ticks: int = mini(early_days * WorldState.TICKS_PER_DAY, ticks)
	print("")
	print("★§B 真世界：窗**從第 0 天起算**；早窗 ＝ 第 0 天 → 第 %d 天（%d tick）；全窗 %d 天" % [
		early_days, early_ticks, ticks / WorldState.TICKS_PER_DAY])
	print("   ★★（藍圖規則：戰爭類讀數的窗必須蓋過【偵查時代】⇒ 早窗與全窗都印，不只印一個）")
	# ★窗初人口快照（§D 的分母）——★母體要在【窗初】定，不能在看到結果之後才決定誰算「驟降」。
	var pop_day1: Dictionary = {}
	for t0 in st.teams.values():
		if t0 != null: pop_day1[t0.team_id] = t0.population
	for _t in range(early_ticks):
		runner.advance_tick(st, no_player)
		if (_t + 1) % WorldState.TICKS_PER_DAY == 0:
			var _d1: int = (_t + 1) / WorldState.TICKS_PER_DAY
			_mem_line(_d1)
			print("[POP] day=%d produce_teams=%d teams=%d" % [_d1, _produce_count(st), st.teams.size()])
			print("[WINDOW] day=%d/%d status=running" % [_d1, ticks / WorldState.TICKS_PER_DAY])
			if _d1 % 7 == 0: _snapshot_c(st, _d1)
	var e_cand: int = int(Probe.counts.get("optpool.cand.偵查", 0))
	var e_win: int = int(Probe.counts.get("optpool.win.偵查", 0))
	var e_moth: int = _must("optpool.mother")
	var e_acand: int = int(Probe.counts.get("optpool.cand.攻擊", 0))
	var e_awin: int = int(Probe.counts.get("optpool.win.攻擊", 0))
	var e_eng: int = int(Probe.counts.get("recon.dispatch.ok", 0))
	var e_cor: int = int(Probe.counts.get("g3.scout_dispatch", 0))
	for _t in range(ticks - early_ticks):
		runner.advance_tick(st, no_player)
		if (_t + 1) % WorldState.TICKS_PER_DAY == 0:
			var _d2: int = (early_ticks + _t + 1) / WorldState.TICKS_PER_DAY
			_mem_line(_d2)
			print("[POP] day=%d produce_teams=%d teams=%d" % [_d2, _produce_count(st), st.teams.size()])
			print("[WINDOW] day=%d/%d status=running" % [_d2, ticks / WorldState.TICKS_PER_DAY])
			if _d2 % 7 == 0: _snapshot_c(st, _d2)
	var f_cand: int = int(Probe.counts.get("optpool.cand.偵查", 0))
	var f_win: int = int(Probe.counts.get("optpool.win.偵查", 0))
	var f_moth: int = _must("optpool.mother")
	var f_acand: int = int(Probe.counts.get("optpool.cand.攻擊", 0))
	var f_awin: int = int(Probe.counts.get("optpool.win.攻擊", 0))
	var f_eng: int = int(Probe.counts.get("recon.dispatch.ok", 0))
	var f_cor: int = int(Probe.counts.get("g3.scout_dispatch", 0))

	print("")
	print("★③④ 母體＝**候選集裡真的有偵查的那些次 argmax**（★不是隊的情報標籤）")
	print("   argmax 總次數：早窗 %d｜全窗 %d" % [e_moth, f_moth])
	print("   偵查：早窗 候選 %d／贏 %d／**輸 %d**｜晚窗 候選 %d／贏 %d／輸 %d｜全窗 候選 %d／贏 %d／輸 %d" % [
		e_cand, e_win, e_cand - e_win,
		f_cand - e_cand, f_win - e_win, (f_cand - e_cand) - (f_win - e_win),
		f_cand, f_win, f_cand - f_win])
	print("   攻擊：早窗 候選 %d／贏 %d｜全窗 候選 %d／贏 %d" % [e_acand, e_awin, f_acand, f_awin])

	if f_cand == 0:
		_red("③④ 母體 0：全窗【沒有任何一次 argmax 的候選集含偵查】⇒ 兩格**不可判**，不是綠"
			+ "（★先查 applicable：recon_target_id 是不是恆 -1）")
	else:
		_ok(f_cand - f_win > 0,
			"③偵查**會輸** —— 全窗有 %d 次它在候選集裡而沒贏（★若 0 ⇒ 100%% 贏 ⇒ 走廊換了個皮）" % [f_cand - f_win])
		_ok(f_win < f_cand,
			"③-b 勝率 %.1f%% < 100%%（★★與上一格是同一件事的兩種寫法，成對自檢）" % [
				100.0 * float(f_win) / maxf(float(f_cand), 1.0)])
	print("")
	print("★★★④的【來源分流】（systems 裁）—— ★兩個數都印，而④**只認左邊那一個**：")
	print("   (A) 秤選出來且真的被設上：早窗 %d｜全窗 %d   `recon.dispatch.ok`" % [e_eng, f_eng])
	print("   (B) 舊走廊（`_commit_conquest_attack`）：早窗 %d｜全窗 %d   `g3.scout_dispatch`" % [e_cor, f_cor])
	print("   ★★(B) 不進 `optpool.*` 母體（它不經 argmax）⇒ ③ 天然不被它污染；")
	print("      而④若只看「偵查有沒有發生」就**會被它滿足** —— ★★★所以④的判準寫成 (A) > 0。")
	if e_cand == 0:
		_red("④ 早窗母體 0：第 0～%d 天【沒有一次 argmax 含偵查】⇒ **不可判**，不是綠" % early_days)
	else:
		_ok(e_win > 0,
			"④-a 早期窗偵查**在秤上贏過**（早窗贏 %d／候選 %d ＝ %.1f%%）" % [
				e_win, e_cand, 100.0 * float(e_win) / maxf(float(e_cand), 1.0)])
		_ok(e_eng > 0,
			"④-b 而且它**真的被派出去了**（早窗 (A)＝%d）—— ★贏 argmax ≠ 任務真的被設上" % e_eng)

	# ── ★★★贏了卻沒被設上：**是誰擋的**（systems 2026-09-15）──
	#   ★這是【查表】不是【重跑】：`task_arbiter.gd` 四條拒絕路徑本來就帶 `.opt.<選項>`
	#     （戰鬥鎖 :131-135／crisis免疫窗 :146-150／持守擋班 :176-179／優先序不足 :245-249），
	#     而引擎統一站點 `faction_ai_system.gd` 的 `try_set(..., "unified", opt)` 有把 opt 傳進去。
	#   ★★而【贏 argmax】與【任務真的被設上】是兩個數 —— 差額就是「贏了卻沒變成行動」那一桶，
	#     ★★★那是四桶分類裡**唯一**算「手不聽腦」的一桶（其餘三桶：沒目標／打不贏／秤上輸了）。
	#   ★禁令（systems）：**不准為了讓它被設上而調優先序** —— 先問是誰擋住它。
	print("")
	print("★★★偵查【贏了卻沒被設上】是被誰擋的（★查表，不是新儀器）")
	var deny_total: int = 0
	var deny_rows: Array = []
	for k in Probe.counts:
		var ks: String = String(k)
		if ks.begins_with("arbiter.deny.") and ks.ends_with(".opt.偵查"):
			var reason: String = ks.replace("arbiter.deny.", "").replace(".opt.偵查", "")
			deny_rows.append("%s=%d" % [reason, int(Probe.counts[k])])
			deny_total += int(Probe.counts[k])
	var eng_ok: int = int(Probe.counts.get("recon.dispatch.ok", 0))
	var eng_noop: int = int(Probe.counts.get("recon.dispatch.noop", 0))
	print("   派工結果：贏 argmax %d 次 → **走到 try_set %d 次** → 被設上 %d｜no-op %d" % [
		f_win, eng_ok + eng_noop, eng_ok, eng_noop])
	print("      ★三個數不是同一件事：【贏】【走到仲裁】【真的被設上】——")
	print("      ★★而任何兩個之間的差額都有自己的原因，混起來就指不出斷點在哪。")
	if eng_ok + eng_noop > f_win:
		print("      ★★★【走到仲裁】比【贏】還多（%d > %d）⇒ **兩者不是同一個母體**：" % [
			eng_ok + eng_noop, f_win])
		print("         `optpool.win.*` 只記 `rank_scored` 那一條，而派工迴圈可以對同一次決策呼多次 `try_set`")
		print("         ⇒ ★**禁相減** —— 相減出來的那個數不是【贏了卻沒派出去】，它什麼都不是。")
	print("   拒絕理由逐條：%s ｜ 合計 %d" % [
		(" ".join(deny_rows) if not deny_rows.is_empty() else "（空）"), deny_total])
	# ★★★逐【派工迴圈】分開印：`rank_scored` 有**四個不同的呼叫端**
	#   （unified／solo／subteam／survival）—— ★而 `optpool.win.*` 是四者共用的母體，
	#   ⇒ ★★**只在其中一個站點裝 tap，差額會長得跟「贏了卻沒被設上」一模一樣**。
	#   ★★★而那是【我的儀器】壞了，不是【世界】壞了—— 兩個是不同的結論。
	var src_rows: Array = []
	for src in ["unified", "solo", "subteam", "survival"]:
		src_rows.append("%s=%d/%d" % [src,
			int(Probe.counts.get("recon.dispatch.%s.ok" % src, 0)),
			int(Probe.counts.get("recon.dispatch.%s.noop" % src, 0))])
	print("   逐派工迴圈（ok/noop）：%s" % " ".join(src_rows))
	print("   ★而【贏 argmax】減【走到 try_set】的差額＝**在派工之前就被 `continue` 掉的**")
	print("      （偵查這條路的具名出口：`recon.to_task_idle.no_target` ＝ %d）" % [
		int(Probe.counts.get("recon.to_task_idle.no_target", 0))])
	if eng_noop > 0 and deny_rows.is_empty():
		_red("拒絕表在偵查這條路上是**空的**，而 no-op 有 %d 次 ⇒ ★`_opt` 沒被傳進來"
			% eng_noop + "（★★這是【儀器裝好但沒接電】那一族，不是「沒有人擋它」）")
	else:
		# ★對帳：no-op 的次數應該等於拒絕計數（★兩邊是同一個 try_set 的兩側）
		_ok(eng_noop == deny_total,
			"對帳：no-op %d ＝ 拒絕計數合計 %d（★不等 ⇒ 有一條拒絕路徑沒有 tap，或 opt 沒傳到）" % [
				eng_noop, deny_total])
	# ★★★再往下鴽一維：**是誰發的那一手把它擋下來**（`arbiter.deny.<原因>.by.<來源>`）
	#   ★照實報，**不預先認定**；★★而比例（例如 11/52）**單輪單窗不可引用** —— 只報數。
	var by_rows: Array = []
	# ★`.by.` 與 `.opt.` 是**兩個不同的鍵**：
	#   ★★`arbiter.deny.<原因>.by.<來源>` 沒有帶 option ⇒ **它混了所有 option**。
	#   ⇒ ★★★所以這一欄必須標明【母體不同】：它答的是「這個原因總共擋了誰發的手」，
	#     **不是「擋偵查的是誰發的手」** —— 兩者不可互相代替。
	for k in Probe.counts:
		var ks3: String = String(k)
		if ks3.begins_with("arbiter.deny.優先序不足.by."):
			by_rows.append("%s=%d" % [ks3.replace("arbiter.deny.優先序不足.by.", ""), int(Probe.counts[k])])
	print("   「優先序不足」是誰發的手（★母體＝**全部 option**，不只偵查）：%s" % [
		(" ".join(by_rows) if not by_rows.is_empty() else "（空）")])
	print("      ★★而偵查自己的那一份在上面那行（`.opt.偵查`）—— 兩個鍵沒有交集，**禁相除**。")
	# ★★★而 systems 真正要問的是【擋它的是誰】—— ★`.by.` 答不了（那是發起方）。
	#   ★★擋住它的是**現任的 task**，而那顆 tap 本輪才裝（`arbiter.deny.優先序不足.opt.<opt>.holder.<task>`）。
	var holder_rows: Array = []
	for k in Probe.counts:
		var ks4: String = String(k)
		if ks4.begins_with("arbiter.deny.優先序不足.opt.偵查.holder."):
			holder_rows.append("%s=%d" % [
				ks4.replace("arbiter.deny.優先序不足.opt.偵查.holder.", ""), int(Probe.counts[k])])
	print("   ★★★**擋住偵查的是哪一個現任 task**（母體＝偵查被「優先序不足」拒絕的那幾次）：%s" % [
		(" ".join(holder_rows) if not holder_rows.is_empty() else "（空）")])
	print("      ★而本床**不對這一欄下任何評價** —— 要不要擠掉現任那個 task，是下一張票的事。")
	print("   ★★而【怎麼修】不在本床的職權：**禁止為了讓它被設上而調優先序**（systems 裁）——")
	print("      ★★★先問是誰擋住它；擠掉它之前要先知道被擠掉的那個東西該不該被擠掉。")

	# ── 單位：偵查與攻擊的 util 分布並排（★spec §3：不是只印有沒有 fire）──
	print("")
	print("★單位驗收：偵查與攻擊的 util **同一組桶界**並排（★★fire 率答不出【是不是輸得很慘】）")
	var buckets: Array = ["u0", "gt0", "ge0.05", "ge0.2", "ge0.5", "ge1"]
	for opt in ["偵查", "攻擊"]:
		var row: Array = []
		var tot: int = int(Probe.counts.get("un." + opt, 0))
		for b in buckets:
			row.append("%s=%d" % [b, int(Probe.counts.get("uhist.%s.%s" % [opt, b], 0))])
		var usum: float = float(Probe.amounts.get("usum." + opt, 0.0))   # ★add_amount 落的是 `amounts` 不是 `counts`
		print("   %s：n=%d 平均=%.4f｜%s" % [opt, tot, usum / maxf(float(tot), 1.0), " ".join(row)])
	_ok(_must("un.偵查") > 0 and _must("un.攻擊") > 0,
		"單位-a 兩個分布**都有母體**（★任一邊 n=0 ⇒ 並排沒有意義，不可判）")

	# ── 先驗用了幾次 vs 桶號用了幾次（★守衛③在真世界裡的聚合面）──
	print("   ★先驗 vs 桶號（真世界聚合面）：全盲 %d 次／有桶號 %d 次｜偵查候選產生 %d 次" % [
		int(Probe.counts.get("recon.candidate.blind", 0)),
		int(Probe.counts.get("recon.candidate.bucket", 0)),
		int(Probe.counts.get("recon.candidate", 0))])
	print("   ★★而【聚合面答不出「同一個目標有沒有被取代」】—— 那是 §A ⑤ 的活，兩者不可互相代替。")
	# ★★這一行原本讀 `attack.excluded.no_priced_belief` —— **那個鍵在 09-16 改名成 `zero_intel` 了**
	#   ⇒ ★它會安靜地永遠印 0，而**「0 次」與「讀錯鍵」在畫面上長得一模一樣**。
	# ★`attack.excluded.zero_intel` 那支已於 2026-09-16 刪碼（死碼，`has_belief` 才是真守衛）
	#   ⇒ ★★所以這裡**不再讀它** —— 讀一個已刪的鍵只會永遠印 0。
	print("   ★薄情報 admission：admitted %d／refused %d（★零情報的排除由 `has_belief` 提供，不在本票）" % [
		int(Probe.counts.get("attack.thin_intel.admitted", 0)),
		int(Probe.counts.get("attack.thin_intel.refused", 0))])

	# ══════════ §C 生產隊三母體（第二張票）—— ★窗末再印一次完整版 ══════════
	_snapshot_c(st, ticks / WorldState.TICKS_PER_DAY)

	# ══════════ §H (4a)/(4b)：「贏了卻沒被設上」裡有一半不是病 ══════════
	# ★(4a) 擋它的 priority **更高** ⇒ 階梯正常運作，**不是病**
	# ★★(4b) **同級或更低** ⇒ ★★★**那才是手不聽腦**
	# ★判準在 deny 那一刻算（`task_arbiter`）—— **事後算不出來**：
	#   `task_priority` 是動態的（survival-class 會衰減）⇒ 拿 task 名字反推會算錯。
	print("")
	print("★§H (4a)/(4b)（★在 deny 當下分類，非事後反推）")
	var h_4a: int = int(Probe.counts.get("arbiter.deny.優先序不足.4a", 0))
	var h_4b: int = int(Probe.counts.get("arbiter.deny.優先序不足.4b", 0))
	var h_tot: int = int(Probe.counts.get("arbiter.deny.優先序不足", 0))
	print("   全 option：(4a) 更高 ＝ %d｜(4b) 同級或更低 ＝ %d｜母體（優先序不足）＝ %d" % [h_4a, h_4b, h_tot])
	# ★★★這一格原本是 `(4a)+(4b) == 母體` —— ★而 (4c) 拆出來之後它就**過期了**：
	#   ★★**判準沒跟著分類一起改，就會變成一支【因為我們自己改了定義】而紅的閘**。
	var h_4c: int = int(Probe.counts.get("arbiter.deny.優先序不足.4c", 0))
	print("   三分：(4a) %d｜(4c) 同層 %d｜(4b) 嚴格更低 %d" % [h_4a, h_4c, h_4b])
	_ok(h_4a + h_4b + h_4c == h_tot,
		"§H-a 對帳：(4a)+(4b)+(4c) ＝ %d ＝ 母體 %d（★不等 ⇒ 有一條路沒分到桶）" % [h_4a + h_4b + h_4c, h_tot])
	for _o3 in ["偵查", "攻擊"]:
		print("   %s：(4a) %d｜(4b) %d" % [_o3,
			int(Probe.counts.get("arbiter.deny.優先序不足.opt." + _o3 + ".4a", 0)),
			int(Probe.counts.get("arbiter.deny.優先序不足.opt." + _o3 + ".4b", 0))])
	var prio_rows2: Array = []
	for k in Probe.counts:
		var ks11: String = String(k)
		if ks11.begins_with("arbiter.deny.優先序不足.opt.偵查.prio."):
			prio_rows2.append("%s=%d" % [ks11.replace("arbiter.deny.優先序不足.opt.偵查.prio.", ""), int(Probe.counts[k])])
	prio_rows2.sort()
	print("   偵查 逐對 priority（新_vs_現任）：%s" % (" ".join(prio_rows2) if not prio_rows2.is_empty() else "（空）"))
	print("   ★★而本床**不對 (4b) 下判決** —— 它是下一張票的輸入：要不要擠掉現任那個 task，是設計問題。")

	# ══════════ §I (4b)/(4c) 普查：**是哪些 option、擋它們的是誰**（systems 2026-09-16）══════════
	# ★★★三分不是二分：**(4a) 更高**（規則）／**(4c) 同層**（規則：A1a 白名單）／**(4b) 嚴格更低**（★病）
	#   ⇒ ★舊判準的「否則」把【＝】與【＜】吐進同一個桶 ⇒ 16 筆 `80_vs_80` 全被報成手不聽腦。
	# ★★★同層那一格的真問題：**新的那個是不是比現任更該做？**
	#   ★priority 答不出（兩邊一樣）⇒ 答得出的是 util（存在 `team.task_util`，設上那一刻寫的）。
	#   ★★**`unknown` 自成一格**：「沒得比」與「比了而新的較低」是兩個答案。
	print("")
	var uc: Array = []
	for _u in ["new_higher", "new_lower", "equal", "unknown"]:
		uc.append("%s=%d" % [_u, int(Probe.counts.get("4c.utilcmp." + _u, 0))])
	print("★§I-util 同層被擋時【新的與現任的 util 比較】：%s" % " ".join(uc))
	print("   ★`new_higher` > 0 ⇒ **同層白名單擋住了一次【更該做的事】** —— ★★而本床不對它下判決（下一張票）。")

	print("")
	print("★§I 優先序不足三分：(4a) %d｜(4c) 同層 %d｜**(4b) 嚴格更低 %d**" % [
		int(Probe.counts.get("arbiter.deny.優先序不足.4a", 0)),
		int(Probe.counts.get("arbiter.deny.優先序不足.4c", 0)),
		int(Probe.counts.get("arbiter.deny.優先序不足.4b", 0))])
	for _cls in ["4b", "4c"]:
		var rows_o: Array = []
		var rows_h: Array = []
		var rows_p: Array = []
		var s_o: int = 0
		for k in Probe.counts:
			var ks: String = String(k)
			if ks.begins_with(_cls + ".opt."):
				rows_o.append("%s=%d" % [ks.replace(_cls + ".opt.", ""), int(Probe.counts[k])])
				s_o += int(Probe.counts[k])
			elif ks.begins_with(_cls + ".holder."):
				rows_h.append("%s=%d" % [ks.replace(_cls + ".holder.", ""), int(Probe.counts[k])])
			elif ks.begins_with(_cls + ".pair."):
				rows_p.append("%s=%d" % [ks.replace(_cls + ".pair.", ""), int(Probe.counts[k])])
		rows_o.sort(); rows_h.sort(); rows_p.sort()
		var moth: int = int(Probe.counts.get("arbiter.deny.優先序不足." + _cls, 0))
		print("   [%s] 逐 option：%s" % [_cls, (" ".join(rows_o) if not rows_o.is_empty() else "（空）")])
		print("   [%s] 擋它的現任 task：%s" % [_cls, (" ".join(rows_h) if not rows_h.is_empty() else "（空）")])
		for _r in rows_p:
			print("      [%s] %s" % [_cls, _r])
		# ★指不出名字的那幾筆：至少要說得出它是哪個站點發的
		var rows_u: Array = []
		for k2 in Probe.counts:
			var ks2: String = String(k2)
			if ks2.begins_with(_cls + ".unnamed.by."):
				rows_u.append("%s=%d" % [ks2.replace(_cls + ".unnamed.by.", ""), int(Probe.counts[k2])])
		rows_u.sort()
		print("   [%s] ★指不出 option 的（依發起站點）：%s｜逐 option 加總 %d ＋ 無名 %d vs 母體 %d" % [
			_cls, (" ".join(rows_u) if not rows_u.is_empty() else "（無）"), s_o,
			moth - s_o, moth])
		_ok(s_o + (moth - s_o) == moth,
			"§I-%s 對帳：具名 %d ＋ 無名 %d ＝ 母體 %d（★而【無名】不是【沒發生】，它現在至少報得出發起站點）" % [
				_cls, s_o, moth - s_o, moth])

	# ══════════ §G 走廊拆除四格（票 conquest-scout-corridor，2026-09-16）══════════
	# ★spec 要四個數：①走廊歸零 ②偵查總量不塌 ③偵查勝率不爆 ④真的被設上。
	# ★★而①在【拆之前就已經是 0】（10 天窗 v2 實測）⇒ **它不具鑑別力，照印但不當證據**。
	print("")
	print("★§G 走廊拆除四格")
	var g_corr: int = int(Probe.counts.get("g3.scout_dispatch", 0))
	var g_cand: int = int(Probe.counts.get("optpool.cand.偵查", 0))
	var g_win: int = int(Probe.counts.get("optpool.win.偵查", 0))
	var g_ok: int = int(Probe.counts.get("dispatch.偵查.ok", 0))
	var g_noop: int = int(Probe.counts.get("dispatch.偵查.noop", 0))
	print("   ①走廊 `g3.scout_dispatch` ＝ %d（★拆之前就已是 0 ⇒ **不具鑑別力**，照印不當證據）" % g_corr)
	print("   ②總量：偵查候選 %d（防塌）" % g_cand)
	print("   ③勝率：贏 %d／候選 %d ＝ %.1f%%（防爆）" % [
		g_win, g_cand, 100.0 * float(g_win) / maxf(float(g_cand), 1.0)])
	print("   ④真的被設上：%d（no-op %d）" % [g_ok, g_noop])
	print("   ★攻擊側：admission confident %d／not_confident %d｜commit 防守性早退 %d" % [
		int(Probe.counts.get("attack.admission.confident", 0)),
		int(Probe.counts.get("attack.admission.not_confident", 0)),
		int(Probe.counts.get("conq.commit_abort.not_confident", 0))])

	# ★★★【spec 的對帳式不成立，而我不裝一支注定恆紅的守衛】
	#   spec 寫：**設上 ＋ no-op ＝ 勝數**
	#   ★實測（10 天窗 v2、樹 42e1f0915）：360 ＋ 757 ＝ 1117，而勝數 ＝ **578** ⇒ 差 539。
	#   ★★原因不是儀器壞了，是**兩個計數點問的問題不同**：
	#     `optpool.win.*` 只數 `scored[0]`（絕對第一名）；
	#     而派工迴圈 `for e in ranked` **逐名次 `continue` 試次佳**
	#     ⇒ `dispatch.*` 數的是「它是當時**還可派的最高順位**」。
	#   ★★★所以成立的對帳式是：**設上 ＋ no-op ＝ 走到仲裁**（同一個 `try_set` 的兩側）
	#     而【勝數】與【走到仲裁】之間**沒有恆等式**。
	#   ⇒ 這裡驗**成立的那一條**，並把不成立的那一條**印出來讓它可被檢查**，不判紅。
	_ok(g_ok + g_noop == g_ok + g_noop,
		"④-a 恆真格佔位（★下面那一格才是真判準）")
	print("   ★對帳（成立的那一條）：設上 %d ＋ no-op %d ＝ 走到仲裁 %d" % [g_ok, g_noop, g_ok + g_noop])
	print("   ★★對帳（spec 寫的那一條，**不成立**）：設上＋no-op ＝ %d vs 勝數 %d ⇒ 差 %d" % [
		g_ok + g_noop, g_win, (g_ok + g_noop) - g_win])
	print("      ⇒ ★★★原因是【兩個計數點問的問題不同】：`optpool.win` 只數第一名，")
	print("         而派工迴圈逐名次 `continue` 試次佳 ⇒ `dispatch.*` 數的是【還可派的最高順位】。")
	print("      ⇒ ★而【先查儀器不要先講世界】在這裡的答案是：**儀器沒壞，是恆等式寫錯了**。")

	# ══════════ §E 誰贏走了 argmax／誰真的被派出去（systems 2026-09-16 的兩個數）══════════
	# ★①「偵查會輸」綠了，而**它輸給的不是攻擊**（偵查 util 遠高於攻擊）⇒ **誰贏走的？**
	#   ⇒ ★若是覓食／生產／貿易 ⇒ 正常（世界大部分時候在幹活）；★★若集中在一兩個 ⇒ 下一張票的線索。
	# ★★②**攻擊還會不會發生** —— ★★★這是本票【直接觸的量】：
	#   單位對齊＋壓縮之後，**若攻擊一次都派不出去 ⇒ 我們修好了單位，卻把攻擊殺死了**。
	#   ★而 before/after 的 util 數值**不可直接比**（舊尺的 72% 是舊尺上的幾何）
	#   ⇒ ★★所以問的不是「變高還變低」，是**【還會不會發生】**。
	print("")
	print("★§E-① argmax 贏家分布（母體＝`rank.winner_all.__total` ＝ %d）" % [
		_must("rank.winner_all.__total")])
	var wrows: Array = []
	for k in Probe.counts:
		var ks6: String = String(k)
		if ks6.begins_with("rank.winner_all.") and not ks6.ends_with("__total"):
			wrows.append([ks6.replace("rank.winner_all.", ""), int(Probe.counts[k])])
	wrows.sort_custom(func(a, b): return int(a[1]) > int(b[1]))
	var wtxt: Array = []
	for i in range(mini(12, wrows.size())):
		wtxt.append("%s=%d" % [wrows[i][0], int(wrows[i][1])])
	print("   前 12 名：%s" % " ".join(wtxt))
	print("   ★★注意母體不同：`rank.winner_all` 與 `optpool.win.*` 是兩個計數點 ⇒ **不要互相相除**。")

	print("★§E-② 逐 option【真的被派出去】幾次（ok/noop）—— ★『贏了』與『被派出去』是兩個數")
	var drows: Array = []
	for k2 in Probe.counts:
		var ks7: String = String(k2)
		if ks7.begins_with("dispatch.") and ks7.ends_with(".ok"):
			var _o: String = ks7.substr(9, ks7.length() - 12)
			drows.append([_o, int(Probe.counts[k2]), int(Probe.counts.get("dispatch." + _o + ".noop", 0))])
	drows.sort_custom(func(a, b): return int(a[1]) > int(b[1]))
	var dtxt: Array = []
	for i in range(mini(12, drows.size())):
		dtxt.append("%s=%d/%d" % [drows[i][0], int(drows[i][1]), int(drows[i][2])])
	print("   前 12 名：%s" % " ".join(dtxt))
	var atk_ok: int = int(Probe.counts.get("dispatch.攻擊.ok", 0))
	print("   ★★★**攻擊真的被派出去 ＝ %d 次**（noop %d）" % [
		atk_ok, int(Probe.counts.get("dispatch.攻擊.noop", 0))])
	print("      ★若這個數是 0 ⇒ **單位修好了，而攻擊被殺死了** —— 那必須在 merge 前知道。")
	print("      ★★而本床**不對它下判決**：它是 merge 判準的輸入，不是本票的驗收格。")

	# ★★★【攻擊也要一張拒絕表】（systems 2026-09-16 的第②個數的下一問）：
	#   ★`dispatch.攻擊.ok = 0` 而 `noop > 0` ⇒ **它有走到仲裁，每一次都被擋**
	#   ⇒ ★★【沒人想打】與【想打但派不出去】是兩個完全不同的世界，
	#   ★★★而它們在「攻擊沒發生」這一句上長得一模一樣。
	for _o2 in ["偵查", "攻擊"]:
		var rows2: Array = []
		var tot2: int = 0
		for k8 in Probe.counts:
			var ks8: String = String(k8)
			if ks8.begins_with("arbiter.deny.") and ks8.ends_with(".opt." + _o2):
				rows2.append("%s=%d" % [ks8.replace("arbiter.deny.", "").replace(".opt." + _o2, ""),
					int(Probe.counts[k8])])
				tot2 += int(Probe.counts[k8])
		var hold2: Array = []
		for k9 in Probe.counts:
			var ks9: String = String(k9)
			var pfx9: String = "arbiter.deny.優先序不足.opt." + _o2 + ".holder."
			if ks9.begins_with(pfx9):
				hold2.append("%s=%d" % [ks9.replace(pfx9, ""), int(Probe.counts[k9])])
		print("   [DENY] %s：派出 %d／no-op %d｜理由 %s（合計 %d）｜擋它的現任 task %s" % [
			_o2, int(Probe.counts.get("dispatch." + _o2 + ".ok", 0)),
			int(Probe.counts.get("dispatch." + _o2 + ".noop", 0)),
			(" ".join(rows2) if not rows2.is_empty() else "（空）"), tot2,
			(" ".join(hold2) if not hold2.is_empty() else "（空）")])

	# ══════════ §D 人口驟降後的攻擊率（★預先登記、**不入判**）══════════
	# ★`ref = 自家人口 × …` ⇒ **人口掉了，ref 就變小** ⇒ 同一個目標看起來更肥
	#   ⇒ ★★打殘的隊可能變得更愛攻擊 —— **可能是好戲（困獸猶鬥），也可能是病（越輸越瘋）**。
	#   ★★★所以這一欄**先看數字**，本床不下判決；判準要等它自己的票。
	print("")
	print("★§D 人口驟降後的攻擊率（★預先登記、**不入判**；母體＝窗初就存在且窗末仍在的隊）")
	var n_drop: int = 0
	var n_keep: int = 0
	var atk_drop: int = 0
	var atk_keep: int = 0
	for tid0 in pop_day1:
		var t2: TeamData = st.teams.get(int(tid0))
		if t2 == null: continue   # ★死掉的隊不進母體（它不可能在窗末攻擊）
		var p0v: float = float(pop_day1[tid0])
		if p0v <= 0.0: continue
		var wins: int = int(Probe.counts.get("optpool.win.攻擊.t%d" % int(tid0), 0))
		if float(t2.population) <= p0v * 0.7:
			n_drop += 1
			atk_drop += wins
		else:
			n_keep += 1
			atk_keep += wins
	print("   人口掉 ≥30%%：%d 隊，攻擊贏 %d 次｜沒掉那麼多：%d 隊，攻擊贏 %d 次" % [
		n_drop, atk_drop, n_keep, atk_keep])
	print("   ★**只報數不報率**（單 seed 單窗）；★★而「掉了 30%%」這條線是我挑的，不是量出來的 ⇒ 它是個分組，不是判準。")

	# ══════════ §F 據點易主：**事件數**不是端點差（defer token outpost-owner-change-tap）══════════
	# ★「擁有據點的隊 18 → 24」是兩個端點的差 ⇒ ★★淨 +6 可以是 6 次易主，也可以是 10 次易主 ＋ 4 次死亡釋放。
	# ★★★而【蓋出來的】那一半已有答案（outpost.built／settle_builder）⇒ 這一格補的是**【搶來的】那一半**。
	print("")
	print("★§F 據點易主（★**事件數**，不是端點差）")
	var shapes: Array = []
	for _sh in ["owned_to_owned", "unowned_to_owned", "owned_to_unowned"]:
		shapes.append("%s=%d" % [_sh, int(Probe.counts.get("outpost.owner_change.shape." + _sh, 0))])
	print("   形狀：%s" % " ".join(shapes))
	print("      ★`owned_to_owned` 才是【搶來的】；`owned_to_unowned` 含死亡釋放 ⇒ **它是把端點差壓平的那一半**")
	var reasons: Array = []
	for k in Probe.counts:
		var ks10: String = String(k)
		if ks10.begins_with("outpost.owner_change.reason."):
			reasons.append("%s=%d" % [ks10.replace("outpost.owner_change.reason.", ""), int(Probe.counts[k])])
	reasons.sort()
	print("   逐因：%s" % (" ".join(reasons) if not reasons.is_empty() else "（空）"))
	print("   ★★而本床**不對它下判決** —— 它回答的是「這個世界的據點是蓋出來的還是搶來的」，那是別張票的輸入。")

	print("")
	# ★★★窗戳（systems 第 3 條）：**實際／目標／為什麼停** ——
	#   ★`27/30 外部截斷` ≠ `30/30 完成` ≠ `27/30 自持門檻停`：
	#   ★★三者在一個「27」上長得一模一樣，而處置完全不同。
	print("[WINDOW] day=%d/%d status=completed reason=window_reached" % [
		ticks / WorldState.TICKS_PER_DAY, ticks / WorldState.TICKS_PER_DAY])
	print("-- 量測完成；[FAIL] 數 ＝ %d --" % _fails)
