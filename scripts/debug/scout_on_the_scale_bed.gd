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

	# ── 狀態1：全盲（只有位置，沒有任何分項、沒有桶號）──
	BeliefSystem.record_claim(fx, obs.team_id, tgt.team_id, obs.team_id, "firsthand",
		{"tile_pos": tgt.tile_pos}, 1.0, false)
	var scan1: Dictionary = FactionAISystem.attack_scan(fx, obs, ldr)
	var in1: bool = _feasible_has(scan1, tgt.team_id)
	var pick1: Dictionary = DecisionContext.pick_recon_target(fx, obs)
	print("      why1=%s" % str(scan1["why"]))   # ★紅了要看得出是哪一道排除擋的
	print("   狀態1【全盲】：進攻擊可行集合=%s｜偵查挑中=%s（blind=%s，value=%.3f）" % [
		str(in1), str(int(pick1["id"]) == tgt.team_id), str(pick1["blind"]), float(pick1["value"])])
	_ok(not in1, "①低情報目標**不出現**在攻擊候選（★而它是【結構排除】不是【算成 0】）")
	_ok(int((scan1["why"] as Dictionary).get("no_priced_belief", 0)) >= 1,
		"①-b 排除理由逐筆記到了 `no_priced_belief`（★查無 ≠ 沒發生）")
	_ok(int(pick1["id"]) == tgt.team_id and bool(pick1["blind"]),
		"⑤-a 全盲那一刻：它是偵查候選，而且用的是**具名先驗**（blind=true）")

	# ── 狀態2：有桶號（resource_scale）—— ★仍然答不出 coin 當量 ──
	BeliefSystem.record_claim(fx, obs.team_id, tgt.team_id, obs.team_id, "firsthand",
		{"tile_pos": tgt.tile_pos, "resource_scale": 2}, 1.0, false)
	var scan2: Dictionary = FactionAISystem.attack_scan(fx, obs, ldr)
	var in2: bool = _feasible_has(scan2, tgt.team_id)
	var pick2: Dictionary = DecisionContext.pick_recon_target(fx, obs)
	print("      why2=%s" % str(scan2["why"]))   # ★紅了要看得出是哪一道排除擋的
	print("   狀態2【只有桶號】：進攻擊可行集合=%s｜偵查挑中=%s（blind=%s，value=%.3f）" % [
		str(in2), str(int(pick2["id"]) == tgt.team_id), str(pick2["blind"]), float(pick2["value"])])
	_ok(not in2, "①-c 只有桶號**仍然**不進攻擊候選（★桶號是分類，不是價）")
	_ok(int(pick2["id"]) == tgt.team_id and not bool(pick2["blind"]),
		"⑤-b 桶號一到手，**先驗就不再參與**（blind 由 true 轉 false）⇒ 守衛③第一段逐筆證據")

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
	_ok(in3 != in1, "②-b 成對檢查：①與②**方向相反**（★否則兩格量的是同一件事）")

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
	for _t in range(early_ticks):
		runner.advance_tick(st, no_player)
		if (_t + 1) % WorldState.TICKS_PER_DAY == 0: _mem_line((_t + 1) / WorldState.TICKS_PER_DAY)
	var e_cand: int = int(Probe.counts.get("optpool.cand.偵查", 0))
	var e_win: int = int(Probe.counts.get("optpool.win.偵查", 0))
	var e_moth: int = int(Probe.counts.get("optpool.mother", 0))
	var e_acand: int = int(Probe.counts.get("optpool.cand.攻擊", 0))
	var e_awin: int = int(Probe.counts.get("optpool.win.攻擊", 0))
	var e_eng: int = int(Probe.counts.get("recon.dispatch.ok", 0))
	var e_cor: int = int(Probe.counts.get("g3.scout_dispatch", 0))
	for _t in range(ticks - early_ticks):
		runner.advance_tick(st, no_player)
		if (_t + 1) % WorldState.TICKS_PER_DAY == 0: _mem_line((early_ticks + _t + 1) / WorldState.TICKS_PER_DAY)
	var f_cand: int = int(Probe.counts.get("optpool.cand.偵查", 0))
	var f_win: int = int(Probe.counts.get("optpool.win.偵查", 0))
	var f_moth: int = int(Probe.counts.get("optpool.mother", 0))
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
	_ok(int(Probe.counts.get("un.偵查", 0)) > 0 and int(Probe.counts.get("un.攻擊", 0)) > 0,
		"單位-a 兩個分布**都有母體**（★任一邊 n=0 ⇒ 並排沒有意義，不可判）")

	# ── 先驗用了幾次 vs 桶號用了幾次（★守衛③在真世界裡的聚合面）──
	print("   ★先驗 vs 桶號（真世界聚合面）：全盲 %d 次／有桶號 %d 次｜偵查候選產生 %d 次" % [
		int(Probe.counts.get("recon.candidate.blind", 0)),
		int(Probe.counts.get("recon.candidate.bucket", 0)),
		int(Probe.counts.get("recon.candidate", 0))])
	print("   ★★而【聚合面答不出「同一個目標有沒有被取代」】—— 那是 §A ⑤ 的活，兩者不可互相代替。")
	print("   ★攻擊側結構排除：`no_priced_belief` %d 次（★這是①在真世界裡的量）" % [
		int(Probe.counts.get("attack.excluded.no_priced_belief", 0))])

	print("")
	print("-- 量測完成；[FAIL] 數 ＝ %d --" % _fails)
