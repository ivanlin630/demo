# A2b Spec — faction leader 隊戰術執行納統一引擎（拆 `_assign_tasks` 手 cascade，intent cadence-gate）

- from: systems
- slice: A2b
- 工單/裁示: `docs/superpowers/handbacks/2026-07-08-blueprint-to-systems-A2-leader-into-engine.md`（藍圖 WHAT；HOW/seam/invariant 系統定）
- 依賴: A1a（引擎內閥 source-gate）、A2a（子隊納引擎，本 spec 鏡射其「拆補丁不加補丁」philosophy + 戰略-gate/lifecycle 分離 pattern）、序6（成員 cascade 已溶入 `_decide_unified`）
- 憲法連動:「行為=引擎輸出」；「身分=權重非路徑切換」（leader vs member = context/term 差異，非決策路徑分支）
- reverse-findings 定位: slice#6 FA1（Leader 隊從不進 rank_scored，手寫 cascade）、D6（同）、FA3（優先權倒置，#1 已 done）

---

## 問題（現況，grep 重驗 2026-07-08）

faction **成員** 早走統一引擎（`_assign_member_tasks:1404 → _decide_unified:1470 → rank_scored`，序6 done），**子隊** A2a 收編。**唯 leader 隊仍手寫 cascade 繞引擎**——A2 最後一塊「手不聽腦」。

落點 `_assign_tasks`（`faction_ai_system.gd:1340-1402`）：讀 `f.goals` 手派 leader 隊 task——
```
1366  "徵收" in f.goals → TASK_TRIBUTE（或遠距 dispatch TRIBUTE 子隊）
1382  "立國" in f.goals → _declare_established
1384  "外交" in f.goals → TASK_DIPLOMACY
1389  "攻擊" in f.goals → TASK_ATTACK（PRIO_FACTION, target=_nearest_independent）
1394  "掠奪" in f.goals → TASK_LOOT（_update_goals 已不 emit 掠奪 goal → 近死枝）
1400  HandBrainProbe.note_bypass(leader_team, "leader")   # 自標繞引擎
```
`f.goals` 由 `_update_goals(state, f):940` 每 tick（`_evaluate_all_body:630`）產：`_select_intent → select_strategic_intent`（意圖 argmax）→ `match itype:` emit goals。

## ★關鍵發現（handback 未點出）：intent→引擎的 bias-term 管道**已鋪好**

- **`intent_fit` term 已存在**（`terms.gd:131` + `_intent_fit:161`）：讀 `ctx.intent`/`ctx.intent_target`，把「意圖→子需求」reshape 戰術 option util（致富→貿易/囤貨、征服→攻擊-prosperity×readiness×cap、匱乏→掠奪/佔村）。
- **`ctx.intent = f.intent.type` 已接**（`decision_context.gd:224`）：faction leader 隊被 gather 時，其 intent 已注入 ctx。
- ∴ **藍圖 #4「intent 當 self-directive 餵引擎 bias term」= 早在**。真缺口單一：**leader 隊根本沒被送進 `rank_scored`**（走 `_assign_tasks` 手 cascade），故 `intent_fit` 對 leader 空轉。

### ★可行性回報（藍圖 #4 保留否決權之澄清，非阻擋）

藍圖 #4 說「比照 A2a 母團命令複用 **faction_duty** directive pattern」——**語意需微校**：
- `faction_duty` = **follower 服從外部權威**（子隊聽母團 / 成員聽 faction 令），weight 受 `_duty_factor(loyalty,野心)` 調（叛離逃閥）。
- leader 的 intent = **自身戰略姿態**（非服從誰），已由**另一個既有 term `intent_fit`** 正確承載（weight=1.0，人格染色 baked in eval）。
- 故 A2b 不套 faction_duty，走既有 `intent_fit`。**藍圖 #4 的精神（intent 進引擎當 bias 秤）完全成立且已鋪好管道**；A2b = 把 leader 隊送進引擎讓管道通電。此為澄清，不觸發「呈報別硬套」的阻擋。

---

## ★裁定方向（藍圖 WHAT → 系統 HOW 落地）

| 藍圖裁示 | A2b 落地 |
|---|---|
| #1 征服稀有性湧現自秤（FA3 硬門檻已刪，done） | 沿用。leader 走引擎後 征服-攻擊 由 `faction_duty+intent_fit`(readiness×cap×conq_person) 加成競秤（非手 forced），target 保 `_nearest_independent`（FA10 撤出範圍）；稀有性 gate 在 intent-selection |
| #2 目標錨軟黏承諾（非硬鎖時間窗） | 保留。intent hysteresis（`_argmax_intent` COMMANDER_COMMITMENT_BONUS）+ 引擎 option COMMITMENT_BONUS 雙層防抖 |
| #3 重評走 cadence（1 天，非每 tick） | **D3**：intent 選擇 cadence-gate（`INTENT_CADENCE=TICK_PER_DAY`，鏡射 THREAT/SUBTEAM_CADENCE）；cadence 內沿用 `f.intent` |
| #4 intent=self-directive bias term；退役 `_update_goals` 平行 bypass；戰術走統一秤 | **D1/D2**：leader 隊送進 `_decide_unified`（同成員）；拆 `_assign_tasks` 戰術 cascade + note_bypass。intent 走既有 `intent_fit`（非 faction_duty，見上） |

**核心 = 鏡射 A2a：把 leader 隊「送進引擎」，拆手 cascade，戰略/lifecycle 分離。**

---

## 設計決定（HOW，全框架 row/term/gate）

### D1. leader 隊戰術執行 → `_decide_unified`（拆 `_assign_tasks` 戰術 cascade）

`_assign_tasks`（1340-1402）改寫：**保留 lifecycle/faction-level 前置（pre-engine，pre-empt 語意，鏡射 A2a 戰略-gate + `_try_consolidate_merge`），拆除戰術 cascade，改呼 `_decide_unified(leader_team)`。**

```
func _assign_tasks(state, f):
    leader_team = state.teams.get(f.leader_team_id)
    if leader_team == null or leader_team.combat_target != -1: return
    # 生存 sticky（不變）：leader 在 survival task → 不蓋，仍跑 member 指派
    if leader_team.current_task in SURVIVAL_TASKS:
        _assign_member_tasks(state, f); return
    # ── pre-engine lifecycle/faction-level（保留；pre-empt，非戰術 util）──
    <player_commanded_task 迴圈（1352-1364，不變）>          # 玩家令（loyalty-gate）
    if "立國" in f.goals: _declare_established(state, f, leader_team)   # 立國=lifecycle gate（結構act，非引擎 option；同 A2a STRATEGIC_SELFINIT 精神）
    # ── ★戰術執行走引擎（取代 徵收/外交/攻擊/掠奪 手 cascade + note_bypass）──
    _decide_unified(state, leader_team)      # 全框架 rank：faction_duty(徵收/外交)+intent_fit(攻擊/貿易/囤貨)+threat+survival…
    _assign_member_tasks(state, f)
```

- **刪除**：1366-1399 的 徵收/外交/攻擊/掠奪 手 cascade（`try_set` 部分）+ `HandBrainProbe.note_bypass(leader_team, "leader")`（1400）。→ leader bypass 計數 **→ 0**（A2b 成功度量，鏡射 A2a subteam_bypass→0）。
- **保留為 lifecycle gate**：
  - `立國`（`_declare_established`）：結構性宣告（faction 立國），非戰術 option，**不入引擎**——同 A2a「lifecycle 走 pre-set，戰略足跡=leader/faction 決定」。
  - `player_commanded_task`（1352-1364）：玩家令走 PRIO_PLAYER，非引擎 util。
- **`_decide_unified` 對 leader 隊開箱即用**：conquest scaffolding（`_commit_conquest_attack`）gated `faction_id==-1`（solo），leader `faction_id!=-1` 不觸 → 走一般 攻擊 dispatch（to_task→TASK_ATTACK）。徵收/外交/貿易/囤貨/生產/駐守/survival/threat repertoire 全 generic to_task 派工。
- **prio 語意變更（明示）**：手 cascade 攻擊/掠奪 用 `PRIO_FACTION`，A2b 統一走 `_decide_unified` 的 `PRIO_DISPATCH`（50）。**合藍圖 #1「征服競秤非高 prio 強派」** + A1 arbiter 語意（威脅 70/survival 80 仍壓過，秩序保）。

### D2. leader ctx 訊號源：純訊號分析（**零 code 改**）——leader 均一讀 stakes+intent、攻擊 target 保 `_nearest_independent` 不變

**★revised v3（02 rev2 verdict Issue 2 定案）**：v1「leader 排除 stakes-攻擊」= 違憲身分收窄（撤）；v2「to_task intent-conditional 拿 prosperity_prey」= **假修 FA10**（02 抓：leader `intent_target` = `fi.intent.target_id` = `_select_intent:902 _nearest_independent`，序5 prosperity 覆蓋 gated `intent_target==-1 or ==_prey` → leader 不觸 → intent_target 停在 `_nearest_independent` → reorder 拿到的還是 god-view）。**撤 to_task reorder + prosperity 宣稱**。

**可行性事實（仍成立，否決 02 rev1 建議 (b)）**：`徵收`/`外交` 全 driver（`faction_duty`+`levy_drive`/`diplo_drive`）皆 stakes-gated（`terms.gd:112/118/122`），`intent_fit` 不涵蓋 → **leader 必須讀 stakes**。

**★真解（v3）= A2b 縮回純路由重構，FA10 out-of-scope**：

- **FA10 god-view target = reverse-findings 主題2「感知半霧」，非 A2b「手不聽腦」（主題1）**。blueprint A2b handback 只要退役 intent bypass，未要求修 target god-view → 修 FA10 = scope creep（另感知 slice）。
- **★行為保真關鍵**：現行手 cascade 攻擊 target 本就 = `_nearest_independent`（`faction_ai:1390`）。leader 走引擎後 `to_task 攻擊` 拿 `faction_attack_target`（stakes 有攻擊 → decision_context:206 亦 = `_nearest_independent`）**優先序勝**（>intent_target）→ **target 完全不變**。∴ **`options.gd to_task` 零改、`decision_context` 零改**——D2 純訊號分析，非 code 改點。
- leader 均一讀全 stakes（decision_context:200 本已如此）+ intent（224 pre-existing）→ **Issue 1 解**：無新增身分-conditional，全隊同 term set，差異只 `ctx.intent` 有無值（pre-existing）。
- **`攻擊` 雙訊號（faction_duty+intent_fit）= util 加成、target 不影響**（to_task faction_attack_target 勝，intent_target 被忽略）：僅 `intent==征服` 同時觸（非 spurious），加成使 攻擊 util 高——但**現行手 cascade 是 forced（PRIO_FACTION try_set），引擎是 competes**：即使加成，survival(80)/threat(70) 仍可 preempt leader 攻擊(50) → **比 forced 更 手聽腦**（威脅時不硬攻）。稀有性 gate 在上游 intent-selection（#1）。

- 效果對照（**target/behavior 保真，唯 prio+competes 變**）：
  - 致富 leader：`f.goals={徵收,外交}` → stakes 徵收/外交(faction_duty+levy/diplo_drive) + intent=致富(intent_fit 貿易/囤貨)。徵收/外交 target 同現行（richest member / _nearest_independent）**不變**。
  - 征服 leader：`f.goals={攻擊(+補力徵收/外交)}` → 攻擊 target = `_nearest_independent`（**同現行 1390，不變**）；util 加成但 competes（威脅可 preempt）。
  - 防衛/擴張 leader：`f.goals={徵收}` → 徵收 走 stakes（不變）。intent_fit 對防衛/擴張無 boost → leader 落 駐守/生產/survival 競秤。

### D3. intent 選擇 cadence-gate（藍圖 #3；1 天）

- `FactionData` 加欄 `intent_eval_next_tick: int = 0`（faction-level，intent 是 per-faction；鏡射 TeamData `threat_eval_next_tick`/`subteam_eval_next_tick`）。
- `faction_ai_system.gd` 加 `const INTENT_CADENCE: int = TimeScale.TICK_PER_DAY * 1`（1 日，TEST VALUE，鏡射 `THREAT_CADENCE`/`SUBTEAM_CADENCE`）。
- `_update_goals` 改：**只 `_select_intent` cadence-gate**，其餘（survival override / 立國 gate / goal emission from committed intent）每 tick（reactive + 便宜）：
```
func _update_goals(state, f):
    f.goals.clear(); f.goal_drivers.clear()
    if player_goal_override: ...; return
    <survival override 缺糧→徵收（962-965，每 tick reactive，不 gate）>
    <立國 gate（968-974，每 tick，便宜）>
    # ── intent 選擇：cadence-gate（#3）──
    if state.world.current_tick >= f.intent_eval_next_tick:
        f.intent = _select_intent(state, f)
        f.intent_eval_next_tick = state.world.current_tick + INTENT_CADENCE
    # else 沿用上次 f.intent（cadence 內黏住，#3「cadence 內沿用」）
    var intent = f.intent
    <war_chest emit + match itype goal emission（每 tick，從 committed intent 冪等重 emit）>
```
- **why 只 gate 選擇非整個 `_update_goals`**：goal emission 冪等（clear→re-emit 同結果），成本低；survival override 須 reactive（缺糧不能等 1 天）。cadence 精準落在「戰略意圖重秤」= 藍圖 #3 語意。
- **雙層防抖**：intent hysteresis（`_argmax_intent` COMMITMENT_BONUS，committed=f.intent.type）+ cadence（1 天不重選）+ 引擎 option COMMITMENT_BONUS（戰術不抖）。
- **leader 戰術（`_decide_unified`）不另 cadence-gate**：與成員同 per-tick 節奏（成員未 gate，序6 接受其成本；leader +1 rank/faction/tick 微增）。若 profiling 顯著 → 後續補 leader-tactical cadence（flag 於驗收 #perf）。**藍圖 #3 的 cadence 指戰略重評（intent），已由此 D3 滿足。**

### D4. 憲法閘 baseline（必做）

`scripts/debug/constitution_baseline.txt`：
- `_assign_tasks`（line 16）**保留**（仍 player_cmd try_set + 立國 gate + 調度 _decide_unified/_assign_member_tasks 的合法 dispatch 協調點），註記由「序6b defer」改為 `# A2b: leader 戰術→_decide_unified；本體只留 player_cmd/立國 lifecycle-gate（tactical cascade 已拆）`。
- 淨：leader tactical bypass 溶解（`note_bypass "leader"` 移除，非新增 try_set 落點——leader 戰術 try_set 現全經 `_decide_unified`，baseline 既有）。**無新增引擎外 task 指派 → gate 綠（current ⊆ baseline）。**

---

## 觸及檔

| 檔 | 改點 | D |
|---|---|---|
| `scripts/simulation/faction_ai_system.gd` | `_assign_tasks`(1340-1402) 拆 1366-1399 戰術 cascade→`_decide_unified(state, leader_team)`，保 player_cmd(1352-1364)/立國 gate(1382-1383) lifecycle，刪 `note_bypass`(1400)；`_update_goals`(940) intent 選擇 cadence-gate（`_select_intent` 呼叫包 `if current_tick >= f.intent_eval_next_tick`）；+`INTENT_CADENCE` const(≈line 100 THREAT_CADENCE 旁) | D1/D3 |
| `scripts/data/faction_data.gd` | +`intent_eval_next_tick: int = 0`（faction-level cadence 欄；`intent:Dictionary` 旁 line 15 附近） | D3 |
| `scripts/debug/constitution_baseline.txt` | `_assign_tasks`(line 16) 註記更新（leader tactical→engine；本體 lifecycle-gate only） | D4 |

**★D2 零 code 改（v3 定案）**：leader 現況本已讀全 stakes(200-217)+intent(224)；攻擊 target 走 `faction_attack_target`=`_nearest_independent`=同現行手 cascade(1390) → **decision_context / options.gd / terms.gd 全零改**。A2b code 面 = D1（route）+ D3（cadence）+ D4（baseline 註）三檔，**FA10 out-of-scope**。

**不碰**：`_decide_unified`（leader 復用不改）、`intent_fit`/`faction_duty`/`attack_drive`/`levy_drive`/`diplo_drive` term（零 patch）、`decision_context`（零改）、`options.gd to_task`（零改，target 保 _nearest_independent）、成員 faction_stakes、`select_strategic_intent`/`_intent_scores`/`_argmax_intent`（只改呼叫 cadence）、子隊路（A2a）、solo（`_evaluate_solo`）、A1a 拆的閥、**FA10 god-view target（另感知 slice）**。

---

## ★呈報藍圖（player-visible，spec 鎖前 sign-off；經 02 → 00）

藍圖 A2c 約束：「任一權威折入後**若改變玩家看得到的行為或平衡意圖**，鎖 spec 前呈報 sign-off」。

**★v3 縮回純路由：D2 身分岔路（v1）+ prosperity target（v2）皆撤。剩三項 player-visible（target/behavior 保真）**，02 要求 QA 遊走證據（Issue 3）已納驗收 #10-12：

1. **征服攻擊 prio `PRIO_FACTION`→`PRIO_DISPATCH` + forced→competes**：leader 開戰不再手 forced 強派，改競秤；威脅/生存可 preempt。**QA 驗**：threat(70)/survival(80) 對 leader 攻擊(50) preemption 序成立、無攻擊 latch（驗收 #11）。→ **若平衡意圖依賴 faction 攻擊高 prio 強派，呈報**；系統判合 #1，預設改善（手聽腦）。

2. **攻擊雙訊號（faction_duty+intent_fit）於征服 leader = util 加成**（target 不變，見 D2）：接受為 intended（稀有性 gate 在 intent-selection 上游）。**QA 驗**：加成後征服**仍稀有**（多數 tick 經濟意圖勝，#1 湧現保）（驗收 #6/#12）。→ **請確認加成可接受**。

3. **（次要）tribute-detachment 移除**：現況遠距富 member → dispatch TRIBUTE 子隊（`1371-1378`）；A2b leader 走引擎 徵收 = **leader 隊自行前往徵收**（不再派遣分隊）。engine 徵收 與 駐守/survival 競秤（離家有威脅/飢餓則不選=自然節制）。**QA 驗**：leader 離家徵收無持續 capital 暴露（threat 自然節制真生效，驗收 #12）。→ 「派遣分隊收貢」如需保留 = follow-up scaffolding（同 A2a settle/construct）；A2b 預設移除（un-patch）。呈報確認可接受。

**★FA10 god-view target 撤出 A2b**：leader 攻擊 target 保 `_nearest_independent`（同現行手 cascade 1390），非本 slice 修。歸 reverse-findings 主題2 感知 slice。

---

## 驗收法（QA/量測員跑；systems 不跑 godot）

1. **無 GDScript 錯誤**；`.\tools\godot.ps1 --headless --import` 綠。
2. **constitution_gate 綠**：current ⊆ baseline（`_assign_tasks` 註記更新，無新增 try_set 落點）。
3. **sanity**：`game_sim_multi` headless ≥1000 tick 無崩；faction leader 派工 print（TRIBUTE/DIPLOMACY/ATTACK）仍出現。
4. **★手聽腦 bed**（`hand_obeys_brain_bed.gd`）對照 A2b 前 baseline：
   - `leader_bypass` 計數 **→ ~0**（手 cascade 消失）。
   - `leader`/`unified` src（leader 隊現走 unified）obey 率高、背離率低。
   - determinism 段 PASS。
5. **抖動檢**：leader intent cadence-gate 後不每 tick 亂換意圖（TeamTrace intent 序列穩定，1 天內同 intent）；戰術 option COMMITMENT_BONUS 防抖。
6. **★行為保真**（非退化）：
   - 致富 faction 仍徵收富 member + 結盟（徵收/外交 task 出現，target 同現行）。
   - 征服 faction 攻擊 target = `_nearest_independent`（**同現行不變**）；征服仍稀有（多數 tick 經濟勝，#1 湧現保）。
   - 防衛/擴張 faction 仍備戰籌餉（徵收 fund_war）。
7. **效能**：leader +1 `_decide_unified`/faction/tick + intent cadence-gate 攤平 → per-tick tick-time 不顯著退化（headless N-tick wall-time before/after 同 seed，建議 ≤5%）。
8. **非退化**：member/solo/子隊 category 背離不暴增；`arbiter_latch` 維持低檔；seeded final 漂移 QA 判合理非退化。
9. **效果發生**（leader 背離真降 + bypass→0 + 戰術走引擎競秤）非只「改了 code」。
10. **★（02 Issue 3）target 保真**：seeded before/after，斷言 leader 攻擊/徵收/外交 target **同 A2b 前**（攻擊=_nearest_independent、徵收=richest member、外交=_nearest_independent）——純路由不改 target（FA10 撤出範圍，非本 slice）。
11. **★（02 Issue 3）prio 降 + forced→competes regression 檢**：seeded 遊走，斷言 leader 攻擊(PRIO_DISPATCH 50) **不** preempt 同隊 threat(70)/survival(80)；leader 無「攻擊裝上被高階丟」的 latch 徵候（A1 arbiter 語意保）；leader 該攻擊時仍攻擊（competes 但雙訊號加成使 util 通常勝）。
12. **★（02 Issue 3）edge-case：leader 離家徵收 capital 暴露 + 征服稀有**：seeded 遊走，leader 選 徵收/攻擊 離家期間，家 outpost 無持續無守暴露（threat 自然節制真觸：有威脅時 survival/駐守 壓過離家 option）；征服雙訊號後**征服仍稀有**（經濟意圖 tick 佔比 vs A2b 前不顯著降）。
13. **★★守衛 A（00 放行條件，硬閘）：征服稀有但非零**——降 prio/競秤後別讓 leader 征服實質消失。長跑 seeded（≥數千 tick）**至少見數次 leader 發起征服攻擊**（`[FactionAI]…主動攻擊` 或引擎 攻擊 dispatch count > 0 且合理）。**=0 = FAIL**。
14. **★★守衛 B（00 放行條件，硬閘）：貢賦不塌成純近距**——tribute-detachment 移除後，leader 無威脅時仍前往收貢；QA 抽驗**遠距 member（dist > 舊 DISPATCH_DIST_THRESHOLD）仍有貢賦流入**（TRIBUTE 成交 / treasury 增 > 0，非只近距 member）。遠距貢賦恆 0 = FAIL。

---

## ★Future-work（立案，非 A2b 職責）

- **tribute-detachment scaffolding**（若藍圖要保「派遣分隊收貢」）：另 slice 補 lifecycle dispatch（鏡射 A2a settle/construct）。
- **A2c 5 平行權威折入**（外交 diplomatic_ai 背叛/結盟/徵貢 FA8、strategic_ai 包圍 FA6/god-view FA7）：依 A2b 落地後定調（藍圖 handback 序 A2c 排 A2b 後）。seam 系統定，player-visible 呈報。
- **intent_fit 擴充涵蓋徵收/外交**（D2 替代 (a)）：若日後要 leader 全 intent-driven（棄 faction_stakes 於 leader），另議。
