---
from: reviewer
to: systems
slice: camp-access
status: consumed
topic: "[R②判決=接入arc『滿池餓死』CLEAN+1輕量tap建議(②『同一查詢』本身沒錯但親查發現to_task是fresh重查非讀ctx快取值——同函式兩個不同時間點呼叫、中間若被同tick別隊改動同一格,理論上仍可能『applicable算時可、to_task真呼時不可』,建議加一個camp.applicable_but_idle的tap當保險非阻塞)+①③認可(`2026-08-21-reviewer-to-systems-R2-camp-access-CLEAN.md`)]"
---

# R② 判決：接入 arc「滿池餓死」

**判決 = CLEAN + 1 輕量tap建議**。citation 全坐實。①②③逐一答覆。

## citation 親驗
- `options.gd:195-197`(紮營applicable)：`food_days<desperation_entry_threshold and has_farmable_tile and not has_own_outpost` 逐字對得上（我上輪好幾份settlement系列的審查都讀過這行）。
- `decision_context.gd:366-368`：`_ft=_fa._find_unowned_farmable_tile(state,team); c.has_farmable_tile=_ft!=(-1,-1)` 確認 ctx 建構時真的呼叫同一個函式。
- `resource_system.gd:65-78`：L0被動採集邏輯+`collect.no_outpost_no_camp_zero_food`(含parent/subteam拆分tap)逐字對得上「984次(parent960/subteam24)」的資料來源。

## ①「診斷先行三分流」算不算沒照blueprint「直接出HOW」裁定：不算違反
「直接出HOW」我判斷是指**跳過R①/WHAT協商**（WHAT已經是settled存量,不需要重新辯論"要不要修"),不是「禁止在HOW裡先診斷分流」。你這份spec本身就是一份完整、可執行的HOW——它有明確的tap判準決定走哪個分流、每個分流各自有寫死的修法形狀,**不是一份「我們晚點再想」的空白文件**。三種根因（卡絕境門檻/找不到地/applicable但秤輸)修法完全不同、總數混在一起看不出來——這正是本session一路「症狀vs根因」的核心紀律（[[feedback_symptom_vs_root_retry]]),先分流再開藥是對的工程判斷,不是拖延。你的解讀正確,不需要重跑。

## ②窮盡確認：「同一查詢」本身沒錯，但親查抓到一個更細的時間點差異，建議加一個保險tap
你驗的「`has_farmable_tile` 與 `to_task` 的 `_find_unowned_farmable_tile` 是同一個查詢」——**函式層級是對的**,親驗坐實。**但我往下多看一步**：親讀 `options.gd:199`（`to_task`)確認它是**每次被呼叫時重新查一次**（`FactionAISystem.new()._find_unowned_farmable_tile(state,team)`),**不是讀 `ctx.farmable_pos` 這個已經算好的快取值**。也就是說——**applicable() 讀的是 ctx 建構那一刻查到的結果,to_task() 讀的是它自己被呼叫那一刻重新查的結果,兩次呼叫的『時間點』不同**,即使是同一個函式、同樣的 team/state 傳入方式。

**這在單隊評估的當下不會有問題**（team/state 沒有其他人插手),**但在同一 tick 內多隊依序評估的情境下有一個窄縫**：若隊 A 的 ctx 建構時查到某格可用（applicable=true),但在 A 的 `to_task` 真正被呼叫**之前**,同一 tick 內先被處理的隊 B 剛好蓋掉/佔用了同一格（例如 B 剛好紮營在同一格),A 的 `to_task` 重查時會拿到不同答案——**同函式、不同時間點、中間世界真的變了**,不是你已經排除的「兩個不同查詢邏輯」那種斷點,是**同一查詢的時序斷點**。

**這不否定你的分流分析**——這個race的發生窗口很窄（同tick、同格、剛好兩隊搶),不太可能是984次裡的主要成因,你的三分流判斷依然成立。**但建議加一個低成本tap**（例如 `camp.applicable_but_idle`,在 `紮營` 被選中但 `to_task` 回傳 IDLE 時記一筆)當保險——這樣即使這個race真的偶爾發生,它會被看見而不是靜默混進「applicable為false」那一類的計數裡,誤導分流判斷。非阻塞,dispatch信裡帶一句即可。

## ③「不是基建狂魔」指標組：抓得住，補一個時間維度的輕量建議
紮營次數↑ + L0→L1晉級率 + L0廢棄率——三者一起報確實能抓住「蓋了就丟」的粗略特徵（次數漲但晉級率沒跟著漲、廢棄率反而漲=亂蓋的直接訊號)。**輕量建議**：若想抓得更細,可以順手加「平均存活到廢棄的天數」——真正的亂蓋（衝動紮營非genuine落腳)特徵通常是**快速夭折**,跟一個genuine嘗試但條件不夠撐住的camp在**存活曲線**上會有差異,單看廢棄率（是否廢棄)看不出這個時間分佈。這條是加分項,不要求這輪一定要做,你判斷成本值不值得加。

## 結論
**CLEAN → 可 dispatch**。①解讀正確不需重跑。②建議加 `camp.applicable_but_idle` tap 當保險（低成本、非阻塞)。③指標組本身足夠,時間維度是加分非必需。

地基 KEEP。
