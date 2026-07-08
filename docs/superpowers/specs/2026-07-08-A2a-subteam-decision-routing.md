# A2a Spec — 子隊決策路由進統一引擎（D7 手不聽腦）

- from: systems
- slice: A2a
- 工單: `tools/orchestrator/briefs/A2a.md`
- 依賴: A1a（引擎內閥 `>`→`>=` source-gate + 成員縫已清；A2a 在其上）
- 憲法連動: 沙盒憲法「行為=引擎輸出」；逆向 arc「控制層手不聽腦」；A2 = leader/subteam bypass（A2a 只做 subteam，leader=A2b）

## 問題（現況，已 grep 驗）

子隊（`parent_team_id != -1`）的 task 決策**手寫 argmax + randf 繞引擎**，是 A1a 後剩最大宗手不聽腦。兩個落點：

1. **`faction_ai_system.gd:1688 _evaluate_idle_subteam`**（idle 且離家子隊）：
   - `scores = {回歸:0.3, TASK_LOOT:(greed·0.5+martial·0.2)·_tag_weight, TASK_ATTACK:(martial·0.4+greed·0.2)·_tag_weight}` → 手 argmax → `TaskArbiter.try_set(..., PRIO_DISPATCH, "subteam_idle")` → `HandBrainProbe.note_bypass(...,"subteam")`（1716/1718）。
2. **`faction_ai_system.gd:1669 _check_deviation`**（在途非保護任務子隊，greed 驅動偏離）：
   - `deviation_chance = greed·(1-loyalty)·DEVIATION_RATE` randf → fire → 手選 `_nearest_independent` → `try_set(TASK_LOOT, ..., "deviation")` → `note_bypass(...,"subteam")`（1682）。

兩處皆同 `values`（greed/martial/loyalty）手算，**不過 `DecisionEngine.rank_scored`**。對照組：成員走 `_decide_unified`→`rank_scored`（1469，乾淨縫）。單點 bed `HandBrainProbe` 分 `subteam` category + `subteam_bypass` 機制計數＝驗收工具。

## 目標

子隊每 cadence 的 task 來自**引擎 util weigh**（吃子隊自己 leader 人格 + 感知 ctx），argmax 由 `DecisionEngine` 決定，非手寫門檻+randf。**只換「怎麼決定 task」**——生命週期（生成/紀律脫離/歸建 merge/安頓/施工/護衛/信使）全不動。

## 設計決定（HOW）

### D1. 子隊 option 子集（scaffolding narrowing，非全 menu）

子隊的既有 repertoire = {LOOT, ATTACK, 回歸-parent}。引擎已有對應 option：`掠奪`（loot_drive/greed + capability + belief-gated prey）、`攻擊`（attack_drive/martial + feud_pull + faction_stakes/intent target）。→ 子隊走**子集 rank**，鏡射既有 `rank_ambient`/`rank_survival` 收窄法（invariants 認可的 scaffolding narrowing）：

- `options.gd` 加 `const SUBTEAM_OPTION_SET: Array = ["掠奪", "攻擊"]`。
- `decision_engine.gd` 加 `static func rank_subteam(ctx) -> Array`（**逐字鏡射 `rank_ambient`**：`applicable(ctx) ∩ SUBTEAM_OPTION_SET` → util = Σ weight×eval → 降序 → opt 字串陣列）。

**為何子集不用全 `rank_scored`**：全 menu 會讓離家子隊在野外冒出 `建設`（無條件 applicable，`options.gd:55`）/`訓練`（有 anon 即 applicable）/`貿易` 等＝新行為 + 抖動風險，違「生命週期不動 + 忠實最小」護欄。子集把 greed→掠奪、martial→攻擊 的既有意圖搬進引擎秤（人格權重承載，去手算），行為忠實、bypass 歸零可量。**★此為要藍圖裁的一點**：子集（忠實/安全，本 spec 取此）vs 全 `rank_scored`（最大統一，但子隊野外會長出新行為）。

### D2. 新 `_decide_subteam(state, sub)`（引擎 dispatch，鏡射 `_decide_unified` 尾）

`faction_ai_system.gd` 新 func。流程（鏡射 `_decide_unified` 1505-1542 dispatch loop，去 conquest/prosperity scaffolding——子隊非自主征服者）：

```
var ctx := DecisionContext.gather(state, sub)
var ranked := DecisionEngine.rank_subteam(ctx)         # opt 字串陣列
for opt in ranked:
    var td := DecisionOptions.to_task(state, sub, opt)
    if td["task"] == TASK_IDLE or (td["target"]==(-1,-1)): continue   # 不可派→次佳
    sub.current_option = opt                            # ★承諾慣性（防抖，COMMITMENT_BONUS 讀）
    var set_ok := TaskArbiter.try_set(state, sub, td["task"], td["target"], PRIO_DISPATCH, "subteam")
    if td.has("combat_target"): state.set_combat_target(sub, int(td["combat_target"]))
    HandBrainProbe.capture(state, sub, "subteam", String(ranked[0]), opt, td["task"], set_ok)
    return true                                         # 已派
# 全不可派 → lifecycle fallback：回 parent（★不 capture）
sub.move_target = parent.tile_pos
return false
```

- **回歸 = lifecycle fallback，永不進 obey/violation 統計**（工單量測特判硬要求）：`rank_subteam` 只吐 掠奪/攻擊，回歸不是 engine option → winner 恆是真 task；無可派時走 `sub.move_target=parent.tile_pos` 不呼 `capture` → 回歸決策不入單點統計，避免「winner=回歸 → result_task 恆≠回歸 → 每次回歸算違規 → subteam 率被灌高誤導 QA」的坑。
- `set_combat_target` 對掠奪/攻擊（`to_task` 帶 `combat_target`）；子集無社交 option 故不需 `set_social_target`。
- **rank0 fallthrough 誠實記**：`ranked[0]` 若 `to_task` 撲空（prey 消失）→ 跳次佳 → `capture` winner≠rank0 → 記 `subset_fallthrough`（誠實，非隱瞞）。

### D3. 兩落點改接 `_decide_subteam`

- **`_evaluate_idle_subteam`（1688）**：保留前置 lifecycle guard 原封不動——parent null 早退、`parent.tile_pos==sub.tile_pos → merge_queue.append; return`（到家歸建）、leader null → `move_target=parent; return`。撕除 1699-1720 手 scores/argmax/try_set/note_bypass → 改呼 `_decide_subteam(state, sub)`（內含回 parent fallback）。
- **`_check_deviation`（1669）**：`deviation_chance` randf = **world-mechanic 紀律脫韁概率**（loyalty/greed → 指揮鏈是否鬆動，鏡射上方 `_check_discipline` 逃亡 randf，憲法允許的世界機制/概率，非 action-selection）。fire → 撕除手選 loot/`try_set`/`note_bypass` → 改 `TaskArbiter.release(sub)` + `_decide_subteam(state, sub)` + `return true`。未 fire → `return false`（照舊落 1632 move_target 檢查）。
  - 語意：貪婪低忠 leader 脫韁 → 引擎秤（掠奪 if 有 prey、否則漂回 parent），非手寫恆 loot。行為近似（greed→高 loot_drive→掠奪贏），但經腦。
  - **★deviation randf 存廢＝要藍圖裁的第二點**：保留（本 spec 取此，忠實 + 對稱 `_check_discipline`）vs 全刪讓引擎自然溶（更純，但需引擎每 cadence 重評在途子隊＝抖動風險，逾 A2a 範圍）。

### D4. 憲法閘 baseline 更新（必做，否則 gate FAIL）

`scripts/debug/constitution_baseline.txt` 契約 = current ⊆ baseline，**新 try_set 指紋=FAIL**。本改動：
- 移除：`_check_deviation`、`_evaluate_idle_subteam` 的 try_set → 兩指紋自 current 消失 → gate 印 `removed`（arc 進度，PASS）。baseline 可留舊行（removed 不 FAIL）。
- 新增：`faction_ai_system.gd::_decide_subteam`（引擎 dispatch path，正當性同已 baselined 的 `_decide_unified`）→ **必須加進 baseline**，附註 `# 序A2a subteam 溶入引擎（rank_subteam）`。否則 current ⊄ baseline → FAIL。

## 觸及檔（詳 `A2a.scope.json`）

| 檔 | 改點 |
|---|---|
| `scripts/simulation/faction_ai_system.gd` | 新 `_decide_subteam`；改 `_evaluate_idle_subteam`(1688) / `_check_deviation`(1669) |
| `scripts/simulation/decision/options.gd` | 加 `SUBTEAM_OPTION_SET` |
| `scripts/simulation/decision/decision_engine.gd` | 加 `rank_subteam(ctx)`（鏡射 `rank_ambient`） |
| `scripts/debug/constitution_baseline.txt` | +`_decide_subteam` 行；標 removed 兩舊 site |

**不碰**：`_tag_weight`（904/1893 仍用，非死碼）、`hand_brain_probe.gd`（`SUBTEAM_BYPASS_REASONS` 變不可達但無害留著）、子隊 lifecycle（detach/merge/settle/construct/escort/herald）、leader（A2b）、member/solo（A1a 已好）、A1a 拆的閥。

## 驗收法（QA/量測員跑；systems 不跑 godot）

1. **無 GDScript 錯誤**；`.\tools\godot.ps1 --headless --import` 綠。
2. **constitution_gate 綠**：`scripts/debug/constitution_gate.gd`（current ⊆ baseline；印 removed 兩 site + `_decide_subteam` 已收編）。
3. **sanity**：headless ≥1000 tick 無崩、關鍵 print。
4. **★單點 bed**（`hand_obeys_brain_bed.gd`，seed 1337, 1 月）：
   - `subteam_bypass` 計數 **→ ~0**（baseline >0；手寫 dispatch 消失）。
   - `subteam` category 背離率（`src_viol/src_dec`）大幅掉 or 決策改由 unified-style capture 記錄且 obey 高。
   - determinism 段 PASS（逐事件確定性）；非擾動段 MATCH（final teams/factions/pop 同 clean）。
5. **抖動檢**（TeamTrace 或 bed events）：子隊 task 走引擎後穩定、不每 cadence 亂換（`current_option` + COMMITMENT_BONUS 防震）。
6. **非退化**：member/solo/leader category 背離不暴增；`arbiter_latch` 維持 A1a 後低檔。
7. **效果發生**（subteam 背離真降）非只「改了 code」。

## 殘留 / 呈報藍圖（見 handback）

- 子集 vs 全 menu（D1）、deviation randf 存廢（D3）＝兩個要藍圖點頭的設計取捨。
- 子隊絕境（離家 starve）不接 survival option＝忠實現況（超範圍，backlog）。
