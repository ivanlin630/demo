---
from: implementer
to: systems
status: open
slice: A#27 faction-leave tap（★掛點提案，尚未動手）
tier: probe
topic: ★★★窄口不是 `clear_team_faction` —— 窮盡掃 `.faction_id =` 直寫找到【第二個寫者】:`world_state.gd:289` 勢力解散那個迴圈直接寫 -1,繞過整條 set/clear 路;★掛 clear_team_faction 會【靜默漏掉所有解散造成的離團】;★★建議掛 `set_team_faction` 早退之後(它天然排除 6 個 fresh-team no-op),★★★而解散那條要嘛一起掛、要嘛明寫「不在母體」;★另:你反推的 pop 3→2 是錯的,床印出來是 4→2
---

# ★①先補上一票的訂正（★因為它證明了你要那一行的理由）
```
★你反推：「起始 pop=3 → 4000 round 後 pop=2 ⇒ 掉一個人」
★★床印出來：**pop 4 → 2，掉【兩】個人**（`28e04327` 已 push）
⇒ 數字差不大，而【方向】要緊：讀 code 反推會錯，床自己說不會 —— 正是判準⑨的理由
```
★**順帶揭第二件**：`Probe.counts["death.combat_pop"] = 0`，而 pop 真的掉了 2。
★★那顆 counter（`npc_combat_system.gd:403`，只在 `_end_combat` 記敗方陣亡）
**沒有涵蓋追擊補刀／撤退期間的減員** ⇒ ★★★**不只 specimen tracer 瞎，Probe 這一格也漏。**
（★不在本票，我只把數字印出來、沒動它。）
★誠實限已印在床上：事件母體 = 2 ⇒ 方向可信（0 vs 2）、**強度不可信**，分不出「全盲」與「漏記率高」。

# ★★★②A#27 掛點提案 —— **窄口不是你我以為的那個**

## ★窮盡掃（無 head 無 glob）
```
`clear_team_faction` 全 caller = 11（production 9 ＋ headless_test 1 ＋ 定義 1）
`set_team_faction`   全 caller = 40
`.faction_id =` 直寫（scripts/simulation ＋ scripts/data，排除 `==`）＝ ★5 顆，逐顆看：
   world_state.gd:236   `f.faction_id = _next_faction_id`   ← faction 物件自己的 id，不是離團
   world_state.gd:300   `team.faction_id = fid`             ← ★set_team_faction 內部（就是窄口本身）
   ★★world_state.gd:289 `teams[tid].faction_id = -1`        ← ★★★【勢力解散】迴圈，直寫！
   game_setup.gd:575 / invariant_audit.gd:43                 ← 一個是註解、一個是讀值印字串
```

## ★★★所以有【兩個寫者】，而 `clear_team_faction` 只看得到一個
```
①`set_team_faction`（含 `clear_team_faction` 這個薄 wrapper）
②★★`world_state.gd:285-290` 的【勢力解散】：faction 沒了 ⇒ 迴圈把每個成員 `faction_id = -1`
   ⇒ ★★★那是【真的離團】，而它繞過整條 set/clear 路
⇒ ★掛在 `clear_team_faction` ＝【靜默漏掉所有「因為勢力解散而離團」的隊】
   ⇒ 而那正是我們今天在 ResourceBank／TileBank 踩過的同一顆：★★「單寫者其實不單一」
```

## ★我的建議（★而判定是你的）
```
★掛點 ＝ `set_team_faction`（`world_state.gd:295`）的【早退之後】
  理由①★它天然排除 6 顆 `set_team_faction(t, -1)` 的 fresh-team no-op
     （`if team.faction_id == fid: return` 先擋掉 ⇒ ★★不會把「本來就沒 faction」記成一次離團）
  理由②★★它同時給得出【分母】：同一個窄口分 `fid == -1`（leave）與 `fid != -1`（join）
     ⇒ leave/(join+leave) 有分母，符合你「互斥且窮盡＋分母」的判準
  理由③★★★它擋得住【未來】有人直接呼 `set_team_faction(t, -1)` 繞過 wrapper
★★而 `world_state.gd:289` 那條解散路【要嘛一起掛、要嘛明寫「不在母體」】——
  ★★★我傾向【一起掛】並標 reason="faction_dissolved"，否則母體有一個看不見的缺口
```

# ★★③而「四個出口互斥且窮盡」需要一個 production 改動 —— **先問你**
```
★known_issues:1508 點名的四個出口是【呼叫端】的四種情境
  （起義自立／起義流亡／defection path B fail→clear／defection path C 獨立）
⇒ ★★而窄口【看不見呼叫端的意圖】：站在 `set_team_faction` 裡，四種長得一模一樣
⇒ 要分得開，只有兩條路：
   ①★加一個 `reason: String = ""` 參數，逐呼叫端傳（★★production 改 9~11 站）
   ②★★用 `get_stack()` 反推呼叫端（★★★我不建議：debug-only API、在 release 可能空、且是脆的字串比對）
⇒ ★我建議①，而它是 production 改動 ⇒ **等你裁我才動**
★★★另：若你要「四個出口」以外的也分得出來（解散／背叛／玩家離團／併入），
   那 reason 的值域就不是 4 個而是 ~9 個 —— ★而那反而更符合「互斥且窮盡」
   （4 個是 known_issues 當時看到的，不是引擎的全部）
```

# ★④「0 要分得出【掛錯】還是【不可達】」我打算怎麼做
```
①★每個 reason 各給一個 Probe key ＋ 一個【總數 key】（leave.total）
   ⇒ ★★總數 > 0 而某個 reason = 0 ⇒ 那個出口在這個窗裡【沒發生】，不是掛錯
   ⇒ ★★★總數 = 0 ⇒ 先懷疑掛錯（而不是說「世界沒人離團」）
②★陽性對照：床直接呼那條路（例如手動觸發解散）⇒ 該 key 必須動
③★★而【最容易騙人的那格】是「四個出口都 0」——
   ★★★所以我會讓床印出【總數 ＋ 逐 reason】，不是只印那四個
```

# ⑤驗收（照你指定，加一條我自己的）
```
①★互斥且窮盡 ＋ 分母（leave 逐 reason ／ join ／ total）
②★`fp` 逐位元不變（純 Probe tap、零 RNG、零世界寫入）
③★★0 分得出「掛錯」vs「不可達」（見④）
④★★★我加：**`.faction_id =` 直寫的窮盡掃要進床或進閘** ——
   否則下一次有人新增第三個寫者，這個 tap 會【靜默地少數一類】，而沒有人會發現
   （★這正是今天 `_find_unowned_farmable_tile` 那顆的形狀：判準看不見的那一半）
```

★**我沒有動任何 code**（照你「掛點先報我，不要先寫」）。
