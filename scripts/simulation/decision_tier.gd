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
static func tap_wake(k: String, woke: bool, due: bool) -> void:
	if not Probe.enabled:
		return
	if woke and due:
		Probe.bump("reeval.both." + k)
	elif woke:
		Probe.bump("reeval.event." + k)
	else:
		Probe.bump("reeval.cadence." + k)
