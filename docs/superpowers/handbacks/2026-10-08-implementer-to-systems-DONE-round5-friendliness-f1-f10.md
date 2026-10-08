---
from: implementer
to: systems
status: consumed
slice: 第五輪友善度 F1–F10（含 F7b、F8 第三版、F9′）——spec 2026-10-07-round5-friendliness-convergence-HOW
topic: ★交件｜branch `feat/round5-friendliness` tip `2b3d1779e`（已推，基在 main 82243701d）｜全電池 BATTERY_RC=0、已知紅排除 0｜world-fp 6ec8b8f6 → 707534ae（F8＋F9′ 同一顆）｜★P5d 要用戶實按兩個終端（我按不到）｜兩處 constitution baseline 搬家要你過目
---

## 結果

- branch **`feat/round5-friendliness`**，tip **`2b3d1779e`**（已推）。全電池 **BATTERY_RC=0**，終端 E2E 已知紅排除 0。
- **world-fp：6ec8b8f6 → `707534aed59182637b9b7ebb8a102ecc`**（F8＋F9′ 同一顆量、同一顆換，照 spec）。F1–F7、F10 是 UI，不改世界。

## 各件（每件都是修前紅 → 修後綠；負對照見下）

| 件 | 做了什麼 | 床 |
|---|---|---|
| F10 地圖整張 | `TextMapRenderer.map_extent`：中心與半徑從 tiles 鍵推；@ 畫在實際位置；VIEW_RADIUS 退場（r=8 最寬 100 欄） | `map_render_test`（改守 F10，舊 U16「@ 恆在正中」斷言退場、留註）進註冊表 `f10-whole-map` |
| F5 單鍵輸入 | play.py：tty＋Windows ⇒ `msvcrt.getwch` 一鍵一 token；`key_token` 純函式（NAMED_KEYS 同名、方向鍵兩種前綴、Ctrl+C⇒`:quit`）；非 tty 逐行照舊；清屏；開場一行「直接按鍵，不用 Enter」 | `python tools/play.py --selfcheck` 19 項，註冊表 `play-key-token`；play-selfcheck 照綠 |
| F3 原因＋下一步 | 三種產生者旁加 `hint`（能解除的動作 id，指不出＝""）；按下不可的項 ⇒「<動作>不行：<原因>；可以先做 <動作>」（目標動作也不再下令） | E2E R5F3 |
| F6 區塊資料層 | `scripts/ui/ui_model.gd`（UiModel，純函式）：動作列 {id,label,enabled,reason,hint,hint_label,group,key}、fold、refusal_text、first_three；GUI 四組順序宣告在這 | 由 F1–F4、F7 的格間接驗（見「誠實限」） |
| F1 首屏三行 | 頂列下「你現在能做的」：強制事件 ⇒ [T]回應第一；否則 [X]推進；再兩個可做的自家隊動作（[T] 互動 ▸ [n]…）；不足補 [G] | E2E R5F1 |
| F2 能做排前、不可折疊 | 自家隊與目標動作都是可做在前，不可收成「另有 N 個暫時不能做（按 ? 展開看原因）」；鍵號＝頁內位置／ACTION_DIGITS 不漂移；`?`（PlayerRepl→KEY_QUESTION）切換 | E2E R5F2 |
| F4 鍵列依狀態 | `KEYMAP_NEEDS` 只記段落要什麼狀態：沒有找上門的事 ⇒ 不印「[A-]回應事件」 | E2E R5F4 |
| F7 游標處一行 | `PlayerQueryApi.tile_knowledge`（只讀附身者知道的：視野內真值／記得的格只有地形／沒去過；據點讀 `_known_outpost_relations`；隊伍讀 belief；最近已知據點；可否紮營只在腳下那格答，precheck_camp 同一支） | E2E R5F7（已知據點格／自己營地／空地／沒去過） |
| F7b 選中區塊 | 改讀同一支（舊版 `query_tile` 真值＝god-view；debug pane 照舊） | E2E R5F7C |
| F8 第三版 | 間距常數／`_check_distance`／NPC min_dist／兩處山地禁紮全退場（只留同格已有）；玩家紮營＝`establish_crude_camp`（當場 L0）；新動作 `settle` 紮根（只在自己 L0 營地上列出、施工中不可、共用 `start_settle_construction`，crude_camp 設點只剩一處）；營地欄（camp_pos／camp_distance，「？」與「無」分得開） | `f8_camp_settle_bed` 修前紅 14，註冊表 `f8-camp-settle` |
| F9′ | `_known_outpost_relations`（g：同勢力 +1／否則 grat−feud）、`known_outpost_term`（最負一座＋最正一座）、`site_persona_w`（慎重＋(1−好戰)）、`_site_candidate_score`（迴圈與床同呼）、Probe.note＋[Site] 行 | `f9_known_outpost_relations_bed` 修前紅 8，註冊表 `f9-known-outpost-relations` |

## P8g（量測，先量不預測）

`docs/measurements/f8-camp-spacing-30d.txt`（seed 1337、30 天、default config）：改前／F8 後／F8＋F9′ 後 **三段逐數相同**——camp.built 15、settlement.l0_to_l1_start 1、山地立營 0、第 30 天據點 10 座、最近距離分佈 2:4／3:3／4:1／5:2、`mountain_camp_survived_days: 0`。⇒ 這 30 天 default 世界裡 NPC 沒碰到被間距或山地擋下的情形；world-fp（另一個世界設定）有變。defer `mountain-build-time-by-terrain` 的 met_check 要 ≥7，不會誤觸。

## 負對照（detached 樹，各自紅在自己的格）

- F10：renderer 改回以玩家為中心、半徑 5 ⇒ map_render_test 紅 7。
- F8：紮營改回開工程 ⇒ f8 床紅 7；E2E P3 的紮營步紅。
- F9′：拿掉 `score += known_term` ⇒ ★第一次床**照綠**（床只驗項本身）⇒ 抽出 `_site_candidate_score`、床加「P9a 在選址分數上」那一格 ⇒ 負對照紅在那格（已知敵城 132.1→156.1）。
- F7b：選中區塊改回 query_tile ⇒ E2E 紅在 R5F7C（沒去過的遠格印出糧量數字）。

## ★要你處理／過目

1. **P5d 人工實按**：VS Code 整合終端與 Windows Terminal 各跑一次 `python tools/play.py`，按 x、Esc、Tab、方向鍵、Ctrl+C，確認是單鍵模式（開場那行「直接按鍵，不用 Enter」）——讀碼答不出、我也按不到，請轉用戶。
2. **constitution baseline 兩把 key 搬家**（TaskArbiter 不吃 inline gate-ok）：`_action_camp::taskarbiter → _action_settle::taskarbiter`；新增 `_site_candidate_score::threshold`（從 `_evaluate_new_outpost_location` 原樣抽出的山地／礦判斷）。同 `_action_rest` 的前例。
3. defer：`outpost-knowledge-is-not-team-belief` 你已裁甲並收窄；`two-positional-key-surfaces…` 是我給目標列算了一個沒用到的 `key_for(` ⇒ 拿掉（自家隊仍是頁內位置鍵，條件語意沒達成）。

## 誠實限

- **F6 P6（拆刀前後逐字比對）沒有做成獨立的比對床**：區塊資料層目前覆蓋動作清單、首屏三行、游標處、鍵列；頂列本來就是 dict；戰鬥區六欄與事件列沒有搬（它們已是資料→字串）。字串層的四缺陷那組照綠，ui-flow 零損失那格只改了 F7b 刻意改的一行（`選中: (9,2) plains`→`平原`，定稿檔只動那一行）。
- F1 的「每行一鍵」：自家隊動作要先開互動面板 ⇒ 那兩行的鍵是 [T]，句子寫明開了之後按哪一個。
- F3 hint 盤點（file:line）：目標動作 `player_command_system.gd` get_action_availability——人口不足⇒recruit、金幣不足⇒trade、不在自家據點⇒camp，其餘「—」；自家隊 precheck——無戰利品／無敗者⇒attack、沒有待確認的打聽⇒gather_intel、無匿名⇒recruit、coin 不足⇒trade、這裡不是你的營地⇒camp，其餘「—」；打聽唯一一項「—」。
- 既有床對齊（皆為行為改變的預期，不是放寬）：ui-flow 三格、自驗 (j)②、headless 紮營測、success-sentence／scripted-exploration 母體 +1（settle）、press-is-one-tick 活檔 +ui_model.gd、qa_probe／godview_followup_test 補宣告、普查表兩列。

## 下一張

#9 地圖記憶（疊在 F10 的 renderer 上）。
