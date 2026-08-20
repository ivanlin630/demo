# spec：手不聽腦結構修 slice1 — faction 成員 survival 命脈 + ambient no-stomp

> 層級：L1（core survival dispatch 架構，evaluate_all 三 loop）。off main（beast/transition/bed merged 後 HEAD）。優先 HIGH（all-in，blueprint 裁 2026-07-20 優先於 god-view E）。異質 R²（大結構改+高信心診斷，框外挑框三對齊）。
> 來源：手不聽腦結構 sweep（`docs/process/hand_obeys_brain_sweep_map.md`）。blueprint scope 確認：slice1=D6+D1/D2。root measurer/QA 坐實（team21/team65/所有 crisis-released 隊）。

## 原則（blueprint WHAT 拍板 2026-07-20：survival>ambient YES，承 (B) survival 主宰）
**food-crisis survival dispatch 必須：①通用（跨 team 類別可達）②優先於 ambient/lifecycle fallback（餓隊 survival > 貿易/生產）③不可掉（終端兜底不卡 stale task）。** 契合沙盒品質 bar「沒有隊伍能坐著/掙扎落空地餓死」。

## 骨架（sweep 坐實）
survival 派發：獨立隊 loop2 `_evaluate_solo`／子隊 loop3 `_evaluate_survival`／**faction 成員只有 loop1 `_assign_tasks→_decide_unified` 一條命脈**（`_evaluate_survival:3267` `uses_unified or parent==-1 → return` 排除成員/獨立走引擎）。team21=faction 成員命脈三重掐。

## ★★前置 gating（異質 R² BLOCKER 1，2026-07-20）：因果須先坐實
**診斷血證基礎不穩**：判 team21/65 手不聽腦的 bed `would_succeed`（`starvation_lockpoint_trace_bed:72-75`）**只驗優先權零 finder** → 真 famine（無可達食物）坐 IDLE 也記 would_succeed=true → 誤標手不聽腦。∴「team21/65 freeze 非 famine」**未坐實**。**slice1 dispatch HOLD until measurer 補 finder-check 重分類**（`systems-to-measurer-would-succeed-finder-check-reclassify`）：
- **(a) 真手不聽腦**（finder 找得到可派 survival target 卻沒派）→ slice1 修 A/B/C 有效 → dispatch。
- **(b) famine 誤標**（finder 全 miss，真無可達食物）→ **slice1 救不了**（改 routing 不生食物），診斷 scope 重估（食物可得性/經濟另 arc）。
- **驗收指標訂正**：不用「手不聽腦 bucket→0」（不可靠，可能只 famine 重貼標）——用 finder-check 重分類的真 freeze 隊數降。

## ★★原子性約束（異質 R² BLOCKER 2）：A+B+C 不可分批 merge
fix A 單獨（ambient-skip）在 D1 期間（領主戰鬥/null）→ food-crisis 成員從「卡貿易（至少有 task）」變「卡 IDLE 零 dispatch」= **退化**（loop1 D1 擋、loop2 只設旗標、loop3 threat 無威脅 return，三路全落空）。∴ **A+B+C 必須原子同 merge**；**fix B 必須真觸達「無威脅 IDLE food-crisis 成員」**（在 D1 期間開一條 survival dispatch）——impl/measure 坐實 fix B 的 survival-only pass 對這類成員真 fire，否則 A+B 合上仍留洞。

## 三修（slice1）

### 修 A（D6，影響最廣）：ambient fallback 不搶 food-crisis IDLE
`faction_ai_system.gd:851`（loop3 ambient fallback）：
```gdscript
if team.current_task == TeamData.TASK_IDLE:   # 現況：任 IDLE 都填 ambient
```
→ 加 food-crisis gate：
```gdscript
if team.current_task == TeamData.TASK_IDLE and _survival_food_days(state, team) >= SURVIVAL_BOOST_FLOOR:
```
- crisis-override release→IDLE 的餓隊 **不再同 tick 被 ambient 塞「貿易」**；IDLE 保留給 survival（次 reeval loop1/引擎 dispatch）。
- 承原則②（survival>ambient）。food-crisis 隊 IDLE 一 tick（survival 次 reeval 接）優於「貿易」永不回糧。
- **免疫窗 D13 殘角一併**：ambient 不對 food-crisis fire → 免疫窗只鎖同字串的洞被此 gate 從源頭堵（ambient 不同字串繞過的路對餓隊關閉）。

### 修 B（D1）：faction 成員 survival 不被領主-combat/null 整包 gate
`_assign_tasks:1418` `if leader_team == null or leader_team.combat_target != -1: return` → 領主戰鬥/交接時**全 faction 成員零 survival**。
- **修方向**：分離「領主協調」（可 skip）與「成員 survival dispatch」（food-crisis 成員必跑）。leader-combat/null 時仍跑 `_assign_member_tasks` 的 **food-crisis 成員 survival 部分**（成員的 `_decide_unified` survival，不依賴領主非戰鬥）。
- impl 選項（R² 審）：①`_assign_tasks` gate 後補「food-crisis 成員 survival-only pass」②或把 leader gate 縮到只包協調段、成員 survival 段照跑。★不重複 survival 邏輯（複用 `_decide_unified` 或 survival ranker），守單一源。

### 修 C（D2）：`_decide_unified` 終端兜底
`_decide_unified:1628` 落空 no-op 無 release → 成員卡 stale `等待新領主@AMBIENT`。
- **修**：food-crisis 成員 `_decide_unified` 全 option finder-miss/落空 → **release 到 IDLE**（比照 `_trigger_survival:3453` 兜底）→ 不卡 stale task，下 reeval 重試（配修 A：IDLE 不被 ambient 搶，survival 次 tick 接）。
- **★注意 would_succeed=true vs finder-miss 矛盾**：bed 報 would_succeed=true 但 _decide_unified finder-miss → 表示「某 survival option 其實可成但 dispatch 路沒試到」。impl 需查 would_succeed 判準 vs _decide_unified 實際試的 option 集差異（可能 survival ranker 漏試某可成 option）——若純 finder-miss（真無 target）則 release 兜底夠；若漏試可成 option 則補 dispatch。R²/measure 定。

## 驗收
- **TDD**：①ambient 不搶 food-crisis IDLE（crisis-released 餓隊 IDLE 保留，非被塞貿易）②領主戰鬥時 food-crisis 成員仍拿 survival dispatch ③_decide_unified 落空→food-crisis 成員 release IDLE 非卡等待新領主 ④非-food-crisis 隊 ambient 照常（不誤傷日常）。
- **gate** constitution PASS / **headless** 0 new(baseline 3) / **determinism** 2 跑 byte-identical。
- **measure（→measurer，★逐隊讀非聚合，bed classifier 修後）**：team21 不再等待新領主凍死（survival dispatch 到）+ team65 手不聽腦消 + 所有 crisis-released 隊不再 ambient-stomp（食物回升）+ 手不聽腦 bucket count → 0（bed 3 分類凍結-lens 準確）+ seed42/1337/4201 famine 不惡化。
- **★存活隊供給 trace**（blueprint seed1337 coherence gap）：rescued 隊補存活 decision trace 驗真轉 survival（非二元存活）。

## out-of-scope（slice2）
D3/D4/D5（等待新領主 納 preemptible）+ subteam D10/D11（v3 連續監看/orphan fold）。slice1 完 re-measure 後評 slice2。gate-tune 排最後。

## 排序
HIGH all-in（優先 god-view E，blueprint 裁）。異質 R²（別 Opus 代 + refute prompt）。off main HEAD。CLEAN→dispatch。
