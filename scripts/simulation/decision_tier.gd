class_name DecisionTier

# ★★★決策頻率層級（LOCKED §3 T0–T4）—— ★「T3 是什麼」只有【這一個地方】寫。
#
# ★為什麼要有這個檔（systems 派 S3 明令）：
#   七支各自寫 `3 * WorldState.TICKS_PER_DAY`，只是把 8 個沒理由的數字換成 7 個一樣的數字。
#   ★★層級要成為【結構】：改「T3 該多長」是改這裡一行，不是去七個地方找。
#
# ★★判準（用戶原文 §3「頻率＝決策層級」）：
#   想多勤【由「你在想多大的事」決定】，不是每個系統自己發明一顆 cadence。
#   ⇒ 掛哪一層問的是【這個決策的尺度】，不是【它有多重要】。
#
# ★★★T0 沒有常數，而那是【刻意的】：
#   T0 ＝ 突發事件驅動、【無鐘】。給它一個週期常數就等於把它變成 T1。
#   ⇒ 想掛 T0 的東西應該接事件，不是接這裡。
#
# ★★★★層級鐘是死常數而【合憲】：它是取樣格／基礎設施，同 TICKS_PER_DAY 類。
#   憲法禁的是「死常數替 NPC 做決策」——層級鐘決定的是【多久想一次】，不是【想出什麼】。

# T0 突發：事件驅動、無鐘 —— ★沒有常數（見檔頭）

# T1 操作：物理心跳（採集／消耗／製造／移動／反應窗）——不做選擇只執行
const T1_OPERATIONAL: int = WorldState.TICKS_PER_HOUR

# T2 戰術：task 重評／威脅／整併／子隊／徵收／俘虜／求援偵察／溢出
const T2_TACTICAL: int = WorldState.TICKS_PER_DAY

# T3 戰略：繁榮／goal 生成／居留／獨立戰略 ＋ S3 搬入的七支
#   ★★★【試跑值】——LOCKED §3 標 provisional，新基線考憑質地（故事反應性＋效能）定案。
const T3_STRATEGIC: int = WorldState.TICKS_PER_DAY * 3

# T4 世代：成年／野生再生／規劃視野／季節
const T4_GENERATIONAL: int = WorldState.TICKS_PER_MONTH

# ★★★★★可逆閥（blueprint 裁定補遺 2026-08-27）：
#   S4 若延誤超過一個工作節拍 ⇒ 七支 cadence【回滾現值】。
#   ★而「回滾」要回的是【七支各自的舊值】（10/10/10/30/50/50/20 小時）——
#     單一個 T3_STRATEGIC 常數【回不了異質值】。
#   ⇒ ★★七支各給一個具名別名放在【這個檔】，回滾 = 把某幾行從 T3_STRATEGIC 換回註解裡的舊值，
#     ★★★而那仍然是【改一個檔】，不是七次手術。
#   ★舊值就寫在同一行的註解裡 —— 回滾的人不必去翻 git 歷史。
const C_GOAL_CHECK: int      = T3_STRATEGIC   # 舊值 10 * TICKS_PER_HOUR
const C_LADDER_EVAL: int     = T3_STRATEGIC   # 舊值 10 * TICKS_PER_HOUR
const C_STRATEGIC: int       = T3_STRATEGIC   # 舊值 10 * TICKS_PER_HOUR
const C_ALLIANCE_CHECK: int  = T3_STRATEGIC   # 舊值 30 * TICKS_PER_HOUR
const C_BETRAY_CHECK: int    = T3_STRATEGIC   # 舊值 50 * TICKS_PER_HOUR
const C_INFRA: int           = T3_STRATEGIC   # 舊值 50 * TICKS_PER_HOUR
const C_FACTION_UPDATE: int  = T3_STRATEGIC   # 舊值 20 * TICKS_PER_HOUR
# ★S4b：意圖併遷 T3。blueprint 當初扣住它的理由是【危機 T0 接管不存在】，
#   而 S4b ①做完之後它存在了 ⇒ 前提消失（reviewer 獨立確認過）。
const C_INTENT: int          = T3_STRATEGIC   # 舊值 TimeScale.TICK_PER_DAY * 1

# ★★★S4b 死水三欄（互斥、相加 = 該支的 fire 次數）：
#   reeval.event.<K>   ＝【事件把它提早叫醒】——★T0 接管【真的有作用】的唯一證據
#   reeval.both.<K>    ＝ 事件來了，但這 tick 本來就到期 ⇒ ★保守記在 both，不記給事件
#   reeval.cadence.<K> ＝ 純週期到期
# ★為什麼要 both 這一欄：只印 event/cadence 兩欄的話，「事件來了但反正也要跑」會被
#   算進 event ⇒ ★★T0 的功勞被灌水。分出來才知道【少了事件會不會真的漏掉】。
# ★★★actor id 要帶【命名空間前綴】—— 這是實測抓到的，不是潔癖：
#   person.id / team_id / faction_id 是三個【不同的命名空間，但數字重疊】。
#   ★第一版我用裸 int 做 join，rung_changed 跑出 100% 同 tick 命中 ——
#     ★★而那有可能是【person 3 醒了】被當成【team 3 醒了】。撞號撞出來的綠是最難看見的綠。
#   ⇒ 前綴由【支別】決定（單一真值在這裡），呼叫端不必各自記得自己是哪個 scope。
# ★九支的名冊（單一真值）—— emit 端要逐支問「這一發對你來說是趕上了還是輸了」。
const SUPPORT_KEYS: Array = ["GOAL", "LADDER", "STRATEGIC", "ALLIANCE", "BETRAY",
	"INFRA", "FACTION_UPDATE", "INDEP_INFRA", "INTENT"]

# ★這一發 emit 的主體隊，對這一支來說【存不存在消費者】。
#   ★★這是 systems ② 的另一半：「比例低」要能分成
#      【順序輸了】(消費者存在但已經評估過了) vs 【本來就沒有消費者】。
#   ★★★沒有這一分，兩者的修法會被混成同一個 —— 而它們完全不同。
static func has_consumer(state: WorldState, team, k: String) -> bool:
	if team == null:
		return false
	if k == "INDEP_INFRA":
		return int(team.faction_id) == -1        # 只跑獨立隊
	if k == "LADDER":
		return int(team.leader_id) != -1         # 無領袖不評野心階
	if k == "GOAL":
		return true                              # 隊裡有人就有 person 走 reaction
	return int(team.faction_id) != -1            # 其餘皆勢力層：獨立隊沒有這一支

# ★GOAL 也用【隊】粒度：它的閘其實是逐 person，但 emit 的 subjects 是隊 id
#   ⇒ ★★要 join 得起來，兩邊必須在同一個命名空間。
#   ★★★代價寫明：GOAL 的 ④延遲欄因此是【隊粒度】不是【人粒度】。
static func actor_scope(k: String) -> String:
	if k in ["GOAL", "LADDER", "INDEP_INFRA"]:
		return "T"
	return "F"

static func tap_wake(k: String, actor: int, tick: int, woke: bool, due: bool) -> void:
	if not Probe.enabled:
		return
	if woke and due:
		Probe.bump("reeval.both." + k)
	elif woke:
		Probe.bump("reeval.event." + k)
		# ★★★④延遲欄要用的：每一次【事件喚醒】的 (支, actor, tick)。
		#   ★這裡只記【發生過的事實】，不預測未來 —— 「下一次事件喚醒在多久之後」
		#     是床事後把這份跟 poll.same 對接算出來的，★★production 不准偷看未來。
		Probe.bump_sample("poll.eventwake", {"k": k, "a": actor_scope(k) + str(actor), "t": tick}, 40000)
	else:
		Probe.bump("reeval.cadence." + k)

# ★★★輪詢獨特貢獻率的分子（blueprint 判準，systems 轉述時寫死了邊界）：
#   「改變」＝ 該次重評之後，該 actor 的【選擇】與重評前不同
#     ⇒ ★不是「跑了」，也不是「分數變了」，是【選出來的東西變了】。
#   ★★而「維持原選擇」【獨立成第三類】（poll.same），★★★不併進分子。
#     理由（票裡寫死的）：維持承諾也可能是貢獻，但那要單獨判，不能混進「改變了決策」。
#
# ★只在【純 cadence 觸發】時呼叫（due 且 not woke）—— 事件喚醒的那些不進這個分母，
#   因為要量的是【輪詢】的獨特貢獻，不是「重評」的貢獻。
static func tap_poll_outcome(k: String, actor: int, tick: int, before: String, after: String) -> void:
	if not Probe.enabled:
		return
	if before == after:
		Probe.bump("poll.same." + k)
		Probe.bump_sample("poll.same", {"k": k, "a": actor_scope(k) + str(actor), "t": tick}, 40000)
	else:
		Probe.bump("poll.changed." + k)
		# ★成因分類（③欄）要靠 before/after 逐筆人判 —— ★★所以這裡【存原文】不存摘要，
		#   摘要會把「是什麼變了」這個唯一有用的資訊丟掉。
		Probe.bump_sample("poll.changed", {"k": k, "a": actor_scope(k) + str(actor), "t": tick, "b": before, "f": after}, 20000)

# ★★這一支的存在本身就是一條【誠實界限】：
#   有些支的「選擇」不落在任何可比較的持久欄位上（產出是一次性動作）。
#   ⇒ ★那些支【不呼叫 tap_poll_outcome】，而床要把它們印成「量不到」，
#     ★★不是印成 0 —— 0 會被讀成「輪詢對它沒貢獻」，而真相是【沒有儀器】。
static func poll_measurable(k: String) -> bool:
	return k in ["GOAL", "LADDER", "STRATEGIC", "INTENT"]
