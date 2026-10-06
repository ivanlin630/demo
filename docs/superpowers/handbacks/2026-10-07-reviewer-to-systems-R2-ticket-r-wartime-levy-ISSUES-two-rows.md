---
from: reviewer
to: systems
status: consumed
slice: 票 R 戰時徵用（修法）
topic: R② ＝ **ISSUES，兩列**（`79eaf801b`）｜五個先查逐一答完：委派機制【沒有】（TASK_HERALD是信使不是授權）、率函式【沒有】（tribute_rate只是player指令可設的死欄位，零NPC動態導出）、生存儲備【有但帶瑕疵】（`_resident_food_runway`被自己的code標過god-view，改用`team.food_runway`較乾淨）、怨恨入口【有】（`NpcAiSystem.form_feud`，FEUD_MIN=0.30恰好對上你要的門檦）、宣告欄位【有但窄】（`f.strategy=="戰爭基金"`只在material<200時才會是這個值，材料充足的戰爭不會被這個字串抓到）｜(a)核過：徵收只有一條decision-layer路徑（7處`_emit_goal`都餵同一個option），applicable()擋法完整
---

# 0 審了哪棵樹

`origin/main` ＝ `15bbc5a9f`（ticket T 第一輪）；spec sha `79eaf801b` 是它的祖先。

# 1 五個先查

## 委派機制（Q2）—— 沒有

```
team_data.gd:6 TASK_HERALD（"信使"）——faction_ai_system.gd:1757/2364/4077 的用法都是傳令／外交提案
  （envoy_proposal），不是「授權某隊代替盟主收稅」的機制
git grep -niE "delegate.*tribute|tribute.*delegate|委派.*徵" scripts/ ⇒ 零命中
⇒ 沒有既有的明示委派機制，spec 自己的 fallback（本票只認盟主，委派另開）是對的，不用再查
```

## 可重用的率函式（Q3 前半）—— 沒有

```
faction_data.gd:8 var tribute_rate: float = 0.10 ——只是一個欄位
唯一賦值點：player_command_system.gd:968 f_tr.tribute_rate = rate（★玩家指令手動設的，不是NPC動態導出）
⇒ 全站零一處從「盟主人格＋戰況」算出 tribute_rate 的函式 ⇒ Q3 要的那支函式要新寫，
  沒有東西可以重用；可重用的只有「tribute_rate」這個欄位名本身（存放處），不是算法
```

## 生存儲備既有定義（Q3 底線①）—— 有，但你找到的那支帶瑕疵，建議換

```
goal_resolver.gd:462 _resident_food_runway(state, resident) —— 算式沒問題（有效糧/日耗）
★但 goal_resolver.gd:418 同檔自己的註解：「★de-scan（資訊網arc）：移除god-view live-read
  （_resident_food_runway直讀resident live pop/food）」——這支函式被本專案自己標記過
  god-view 嫌疑，而且只在【某一個呼叫點】被 de-scan 掉，它本身在 faction_ai_system.gd:5751
  仍被直接呼叫（讀別隊的live pop/food）
⇒ 更乾淨的候選：team.food_runway（food_flow.gd:14-27 每日 cadence 算好、快取在欄位上，
  純算術零RNG，decision_context.gd:213/791 也讀同一個快取）
⇒ ★讀「對方欄位上已經快取好的值」跟「自己重新呼一次會直讀對方live pop/food的函式」不是同一個風險等級：
  戰時徵用是機械資源轉移（像_deduct_cost直讀倉庫），不是威脅感知決策，用哪一個都不算違反感知鐵律，
  但既然有一個沒被標記過god-view嫌疑的現成快取欄位，沒理由選另一支帶著歷史標籤的
```

## 宣告欄位（Q1）—— 有，但範圍比字面窄，兩類應急不要混

```
faction_data.gd:13 var strategy: String = "idle" ——一般情況下被設成 intent["type"]（:1989，隨意圖變動）
faction_ai_system.gd:1999 f.strategy = "戰爭基金" ——★只在 war_chest_need 成立時才會是這個字串
  （ambition>0.6 或 martial>0.6）且（leader_team.material < WAR_CHEST_MIN=200）
⇒ 若勢力已經在打仗、但 material 剛好 ≥200（不缺），strategy 會是別的 intent 類型，
  不會是「戰爭基金」——用這個字串當「有宣告」的判準，會漏掉「真的在打仗但不缺材料」的情況
faction_ai_system.gd:1948 f.strategy = "緊急徵收" ——★這支不要混進來：觸發條件是 food_per_cap
  過低（糧食危機），跟戰爭完全無關，是另一種應急
⇒ 全站沒有更廣義的 at_war／war_declared 欄位（grep at_war|is_at_war|war_state 零命中）
⇒ 處置：f.strategy=="戰爭基金" 可以用，但要在 spec 寫明它的範圍（窄、綁material<200），
  不要寫成「這就是戰爭宣告」——它寧可漏抓（少徵一些），不要跟「緊急徵收」混（那會讓
  糧食危機也能發戰時徵用，牛頭不對馬嘴）
```

## 怨恨寫入入口（Q4）—— 有，而且門檦數字剛好對得上

```
npc_ai_system.gd:13 const FEUD_MIN := 0.30
npc_ai_system.gd:36 static func form_feud(victim, perp_id, severity, tick) -> bool
  ——註解逐字「A feud：唯一形成點」，FEUD_MIN gate
⇒ 你要的「≥0.30那層」就是這支函式的 gate 本身，不用另外判斷門檦——
  呼叫 form_feud(繳稅方leader, 收稅方faction_id或leader_id, severity, tick)，
  severity 給到能過 0.30 即可，不要自己另寫一道if比較0.30
```

# 2 (a) TASK_TRIBUTE 的派工點——核完：只有一條路，決策層擋法完整

```
faction_ai_system.gd 有 7 處 _emit_goal(state, f, "徵收", ...)（:1949/2000/2012/2020/2024/2064/2137）
  ——這些都是【勢力層的目標宣告】，餵進成員自己的決策（「徵收」option 的 goal-frontier 候選），
  不是直接指派某個特定非盟主隊
:3827 Probe.bump("tribute.dispatch.member")（if team.faction_id != -1 and opt=="徵收"）
  ——證實任何成員（非僅盟主）今天都能透過同一個 option 選中「徵收」，這正是紅基線 11/11 的來源
⇒ 全站沒有找到第二條「指派TASK_TRIBUTE」的路徑（沒有其他 try_set/transition 寫 "徵收"）
⇒ 你判「在決策層擋applicable()」是對的、完整的：堵住option本身，7處_emit_goal不管宣告什麼，
  成員端applicable()一律先判是不是盟主，全部路徑都會被同一個閘擋到
```

# 3 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "Q3 底線①的生存儲備定義 ＝ _resident_food_runway",
     "file_line": "goal_resolver.gd:418,462；faction_ai_system.gd:5751；food_flow.gd:14-27",
     "truth": "_resident_food_runway 被同檔自己的註解標記過god-view嫌疑(已在一處de-scan但另一處仍在用)；更乾淨的等價候選是team.food_runway(每日cadence快取,零RNG,無此標籤)"},
    {"claim": "Q1 宣告 ＝ f.strategy == 戰爭基金",
     "file_line": "faction_ai_system.gd:1948(緊急徵收,食物危機)/:1999(戰爭基金,綁material<200)",
     "truth": "戰爭基金只在material<200時才會是這個字串,材料充足的戰爭會被漏掉;緊急徵收是另一種(食物)應急不該混進同一個判準;spec要寫明這是窄範圍,不是廣義的at-war旗標"}
  ],
  "note": "委派(沒有,fallback對)/率函式(沒有,要新寫)/怨恨入口(有,form_feud+FEUD_MIN剛好對上)三項確認完。(a)確認只有一條決策層路徑,擋法完整。改完這兩列敲sha，我只看這兩處。" }
```
