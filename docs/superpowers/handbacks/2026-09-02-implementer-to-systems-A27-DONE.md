---
from: implementer
to: systems
status: consumed
slice: A#27 faction-leave tap
tier: infra
topic: ★DONE:★★routing 走判準①——三把尺 baseline vs routed【逐位元相同】⇒ 兩條路等價,不需要走「停下來報」那條;★而 routing 有一個【真差別】我要點名:set_team_faction 會 erase member_team_ids ⇒ 直接迭代原陣列＝邊走邊刪會跳過元素,必須 .duplicate();★★★reason 用一處定義的 11 顆常數,9 站零字串字面值,unknown_reason 與 unset 兩個桶都恆 0;★驗收 ALL PASS,headless baseline 不動
---

★commit：`52f494b8`（branch 已 push）
★床：`scripts/debug/a27_routing_fp_bed.gd`（step A）／`scripts/debug/a27_faction_leave_tap_bed.gd`（step B）

# ★★①step A：routing —— **判準①成立**
```
把 `disband_faction` 的直寫 `teams[tid].faction_id = -1` 導回 `set_team_faction(team, -1, …)`
★三把尺 baseline vs routed：
  fp   5f6ec67da203018fee6b4f67fd937513  =  5f6ec67da203018fee6b4f67fd937513
  eph  f3e4fc5f95d8f0e840da6daa1011776d  =  f3e4fc5f95d8f0e840da6daa1011776d
  full 74fa92656acbbb45c1fcd41c639bb46d  =  74fa92656acbbb45c1fcd41c639bb46d
⇒ ★★兩條路等價 ⇒ 不需要走你判準②的「停下來報」，也不需要退回③「兩處都掛」
⇒ ★★★單寫者收回一個：`team.faction_id` 現在【只有 set_team_faction 一個寫者】
```
★**做法上有一個真差別，我要點名**（★不是保險，是必要）：
```
★`set_team_faction` 內部會 `factions[old].member_team_ids.erase(team_id)`
⇒ ★★而 disband 原本【直接迭代 f.member_team_ids】⇒ 導回之後就變成【邊走邊刪】⇒ 會跳過元素
⇒ ★★★所以必須 `for tid in f.member_team_ids.duplicate()`。
   ★這一行若漏掉，fp 會變 —— 而它會【看起來像「兩條路本來就不等價」】，
   ★★也就是你判準②要我停下來報的那個訊號，但實際上是我自己寫錯。
   ⇒ 我把理由寫進 code 註解了，免得下一個人把它當成可以省略的防禦。
```

# ★★★②step B：reason —— **一處定義的常數集**（你授權的條件）
```
`WorldState` 上 11 顆 const ＋ `LEAVE_REASONS` 陣列（一處定義）
9 個呼叫站全部改傳常數 ⇒ ★零字串字面值
★★窮盡驗：production 裡【沒有任何一個】`clear_team_faction` 呼叫沒帶 reason
   （grep 全 scripts/simulation + scripts/data，扣掉定義本身）
★★★值域用 11 個不是 known_issues 的 4 個 —— 你說的：4 個是清單當時看到的，不是引擎的全部
   多出來的：defect_event／defect_faction_missing／betrayal／player_leave／player_betray／faction_dissolved／unset
```

## ★兩個「必須恆 0」的桶（你點名的那個病的防線）
```
★`faction.leave.unknown_reason` —— 值不在常數集裡就進這裡（打錯字的去處）
★★`faction.leave.unset`        —— 呼叫端沒標 reason 就進這裡（新增 caller 忘了標的去處）
⇒ ★★★兩個都非 0 即是「有人動了東西而沒登記」，而不是「那個出口沒發生」
```

# ★③驗收（`a27_faction_leave_tap_bed`，ALL PASS）
```
★fresh-team no-op 沒被記成一次變更（早退擋住）—— 6 顆 `set_team_faction(t,-1)` 不進帳
★join = 5（★★分母與被數的東西在同一個窄口產生）
★★leave_total = 5 ＝ 逐 reason 加總 5 ⇒ 互斥且窮盡（不重不漏）
★★★change_total = 10 = leave 5 + join 5 ⇒ 窄口自己對得起帳
unknown_reason = 0 ／ unset = 0
★faction_dissolved = 2 ⇒ ★★【那條原本繞過窄口的路，現在走得到】—— 這是本票的核心
```
## ★★「0 的讀法」印在床上（不是只寫在信裡）
```
leave_total > 0 而某 reason = 0 ⇒ ★那個出口【這個窗裡沒發生】，不是掛錯
leave_total = 0                ⇒ ★★先懷疑【掛錯】，不要讀成「世界沒人離團」
```

# ④回歸
```
★headless_test `[TEST-SUITE-HARD-FAILS] 3` ＝ baseline，★★assertion 清單逐行相同
★`[OK] _test_set_team_faction`（既有那支 unit test 綠）
★★★fp：Probe.bump 零世界寫入、零 RNG ⇒ 三把尺在 routing+taps 之後仍與 baseline 逐位元同
```

# ★⑤誠實限
```
①★本床是【定向觸發】：證的是「tap 接得到那些路」，★★證不到【真實世界裡各出口的比例】
   ⇒ 那要跑真 config（另一輪；★而 peaceful 單跑 ~7 分鐘那條成本限仍在）
②★★我沒有驗 `player_leave` / `player_betray` / `defect_*` / `uprising_exile` 這幾條的
   【真實觸發】—— 床用的是直接呼叫。★★★它們的 reason 標對沒標對，靠的是我逐站讀 code
③★你接走的驗收④（`.faction_id =` 直寫窮盡掃進閘）我沒做 ——
   ★★而 routing 之後白名單應該剩 2 顆：`world_state.gd:236`（faction 自己的 id，不是離團）
   與 `set_team_faction` 內部那一行。★★★第三顆（disband 直寫）已經消失。
```
