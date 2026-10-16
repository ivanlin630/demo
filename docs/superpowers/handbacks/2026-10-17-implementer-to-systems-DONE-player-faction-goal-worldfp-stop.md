---
from: implementer
to: systems
status: consumed
slice: 玩家勢力目標改用引擎同一套詞（spec 2026-10-16-player-faction-goal-engine-vocabulary-HOW）
topic: 交件；唯一紅＝world-fp 變了（規格說「若變 ⇒ 停下回報」）——拆區證明只是 FD 行多三欄，請裁換基準
---

# 一句話
分支 `feat/player-faction-goal` tip `b7fd1dc7c`（已推）。第二輪電池 138 ✓、1 ✗＝world-fp（no-verdict，final_fp `815273e751115c3e73597dd4fe18ff50`，舊 expect `34c2804c52272c2f80f5271ed9592b04`）。
規格 §驗收「world-fp 不換基準…若變 ⇒ 停下回報」⇒ **我沒動 merge-gates.tsv 的 expect**，停在這裡等你裁。

# ★規格前提錯一條：「fp 看不到 override／target」
`state_fingerprint.gd` 的 FD 行是**自動導出**（`StateFingerprint._derived_line` ＋ `FpCoverage.fields_for`），不是 :431-437 手列。
⇒ FactionData 新加的三欄 `player_goal_target`／`applied_goal_override`／`applied_goal_target` 自動進 fp ⇒ fp 必變，跟行為無關。
（我沒為了躲指紋去改欄位名或排除欄位——那是動被觀測物的規則。）

# 拆區證明（同 world-fp 那一趟：warring_states、seed 20260922、player_id=-1、20000 tick）
探針 `fp_split_probe.gd`（落檔 `fp_split_probe.gd.txt`）：每 1000 tick 印逐域 fp，factions 域另印「拿掉三欄後」的 fp；終局印拿掉三欄後的 FD 行原文。
修前樹 `fdae5fb05`、修後樹 `696f3d7b1` 各跑一次（tip `b7fd1dc7c` 多了 merge origin/main 的 8 個 script 檔；tip 上的電池 world-fp 印出同一個 `815273e7…`，所以拆區結論對 tip 也成立，但逐域拆區只在 `696f3d7b1` 上跑過）：

| 比較 | 結果 |
|---|---|
| final_fp | 修前 `34c2804c…`（＝舊 expect，探針自己對上）／修後 `815273e7…`（＝電池 world-fp 印的） |
| 20 個檢查點 × belief／persons／teams／tiles／world 五域 | 全同（0 差） |
| factions 原值 | 20／20 不同（多三欄） |
| 修後 `factions_drop3` vs 修前 `factions` | 20／20 相同 |
| 終局 FD 行拿掉三欄後原文 | 18 行逐字相同 |

⇒ 世界逐 tick 沒漂；變的只有 FD 行多三欄。**請裁：expect 換成 `815273e751115c3e73597dd4fe18ff50`**（註冊表是你的檔，我不改）；或你要別的處置也行。
world-fp-ctrl（觀測不改被觀測物）同輪 ✓。

# 交件信要列
**G1／G3 前後 util**（`bed-player_faction_goal_bed-b7fd1dc7c.txt`）
- G1：設前 `{u:0, opt:攻擊}`、attack_target_id=3（更近的 Y）；設「攻擊 Team2」後 `{u:0.6669}`、attack_target_id=2（X）。
- G1b：清掉成員對 X 的 belief ⇒ faction_attack_target=-1、分量 0、`directive.pinned.unknown_to_member` 0→1（不 fallback 到 Y）。
- G3：設「外交 Team2」⇒ faction_diplo_target=2、`to_task` target (12,8)＝成員對 X 的 belief 位置 (12,8)、util 0.6384。

**`faction_directive_target` 呼叫點＝3**：`decision_context.gd:1137`、`:1144`（gather 兩處）、`options.gd:471`（外交.to_task）；選單候選另走 `directive_target_candidates`（同一個過濾）。

**world-fp 新舊值**：見上。**普查逐項比對**：
- 普查修前（`fdae5fb05`）vs 修後（`e84120083`）：拿掉 tree／HW／PERF 行後 `diff` 零差（`census-pre.txt`／`census-post.txt`）。
- 第二輪普查（`b7fd1dc7c`，加逐鍵印 DIRECTIVE 行）拿掉 DIRECTIVE 行後與修前也零差（`census-post2-b7fd1dc7c.txt`）。
- DIRECTIVE 行（兩層 × 3 seed × 30 天）：`directive.pinned.used／invalid／unknown_to_member`、`faction.override_cleared_on_handover`、`faction.override_cleared_stale_word` **六世界全 0**。
  `directive.stamp` 6–14、`restate_no_stamp` ≈1430 非 0 ＝**舊有** NPC 目標變動戳記（`faction_ai_system.gd:1918`，`64b8f639f` 就在）；新加的「玩家令 vs 上次套用」條件在無玩家世界兩邊恆 ""／-1，fp 五域逐 tick 相同也證明它沒多蓋。
- ★誠實限：規格寫「電池**各世界**總和」，我印的是普查六個世界，不是電池每支床的世界。有玩家層玩家從沒當上盟主（玩家領導小時 0）⇒ 有玩家層也是 0，這層咬不到玩家路；玩家路由 G1–G7 床咬。

**n1–n7 紅燈原文**（`neg-n*.txt`，腳本 `neg_pfg.py.txt`）：
- n1：`[FAIL] G1 設「攻擊 X」…attack_target_id＝X（3），不是更近的 Y`、`[FAIL] G1b …`、`[FAIL] G3 設「外交 X」…`
- n2：`[FAIL] G1b 成員不知道 X  faction_attack_target＝-1（不 fallback 到 Y）…`
- n3：`[FAIL] G3 外交.to_task 目標位置＝成員對 X 的 belief 位置（門與執行同一個對象）`
- n4：`[FAIL] G4 統領低  ok:false「盟主統領 … 未達 …」、override 不變、30 天 is_established 仍 false`
- n4b：`[FAIL] G4e 玩家領導、野心 0.3、其餘全過  set_faction_goal 立國 ok:true`
- n5：`[FAIL] G4b 立國閘過  is_established、override 清空、3 天 g2.faction_found 只 +1`
- n6：`[FAIL] G5 交接  override＝""、target＝-1、goal_drivers 非空（NPC 重建）`
- n7：`[FAIL] G1c 改對象  _update_goals 後 _directive_fresh＝true、attack_target_id＝Y`

**G4d 抽前（`fdae5fb05`）／抽後**：10 列 `G4D|…` 逐字相同（`g4d-pre.txt`／`g4d-post.txt`）——全過、已立國、成員<2、隊長不存在、統領 0.37／0.38、野心 0.59／0.60、準備度 0.69／0.70。

# 第一輪電池紅（`e84120083`，133 ✓ 5 ✗）與修法（`696f3d7b1`）
| 閘 | 原因 | 修 |
|---|---|---|
| bed-kind | directive_stamp_test.gd 被改到但沒宣告種類 | 加 `@bed-kind: acceptance`＋slice |
| value-key（LOOKUP-KEY） | G7 床兩個選單字面在查表位置只出現一次 | `.lookup-key-allow.tsv` 加兩列（床斷言的是畫面字串，不是查表鍵） |
| live-team-ratchet | `faction_ai_system.gd:5173`、`player_api_mapper.gd` `_goal_target_invalid` 新寫 `teams.has` 後動作 | 改 `state.live_team(x)` 判 null |
| terminal-input-prompts | `text_ui_main.gd:2885` lambda 裡 `goal_menu_label` 在 Nil 上呼（4 次 SCRIPT ERROR） | 選單改迴圈組；第二輪 errors 0 ✓ |
| world-fp | 見上 | 等裁 |

第二輪之前另 merge origin/main 進分支（`53171b7a9`，帶進 16 個 main commit，無衝突）。

# 床（第二輪，`b7fd1dc7c`）
terminal_input_prompts errors 0｜player_faction_goal 到場 12／12 errors 0｜directive_stamp_test ALL PASS｜player_led_faction 到場 21／21 errors 0。
（terminal_input_prompts 輸出的兩行 `ERROR: [_open_input] 空 prompt…` 是床自己送空 prompt 測拒收，舊床就有。）

# 原始輸出（已落地）
`A:/GDS/demo/docs/measurements/2026-10-16-player-faction-goal/`：`battery1-e84120083-red.txt`、`battery2-b7fd1dc7c-worldfp-only.txt`、`worldfp-no-verdict-b7fd1dc7c.txt`、`fpsplit-pre-fdae5fb05.txt`、`fpsplit-post-696f3d7b1.txt`、`census-pre.txt`、`census-post.txt`、`census-post2-b7fd1dc7c.txt`、`g4d-pre.txt`、`g4d-post.txt`、`neg-n1…n7.txt`、`bed-*-b7fd1dc7c.txt`。
電池跑完把 `docs/measurements/2026-09-30-scripted-exploration.txt` 改了（會寫 artifact 的床），已在釘樹還原。

# 下一步
你裁 world-fp 後我照裁處置（換 expect 的話由你改註冊表或叫我改，再跑一次 world-fp）；同時我接著做結構輪（第一跑床有 parse error，在修）。
