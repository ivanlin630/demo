# Hand Back: wave2 序5 — prosperity-attack cascade 溶入引擎

## 實作摘要

**溶=融合非刪**：`_evaluate_prosperity_attack` gate cascade（archetype/attack_score/readiness/find_prey/scout-defer 硬閘 prescribe TASK_ATTACK）決策溶進引擎 攻擊 option；scout-verify 保為 dispatch-time scaffolding。de-risk 兩階（Phase1 加到 parity → Phase2 拆）。

改動檔（每檔一行）：
- `scripts/simulation/decision/decision_context.gd`：gather 加 `readiness`(=calc_readiness)/`readiness_thr_eff`(=calc_readiness_threshold × hunger_relief)/`prosperity_prey_id`(=find_prosperity_prey)；征服 `intent_target` 改用富 prey（取代 weak_prey fallback）。
- `scripts/simulation/decision/terms.gd`：`_intent_fit` 征服路 × `readiness_factor=clampf(readiness/readiness_thr_eff,0,1)`（readiness 閘=權重非硬閘）+ 信義 penalty（對齊舊 cascade attack_score 野心+好戰−信義）。
- `scripts/simulation/faction_ai_system.gd`：
  - 加 `_commit_conquest_attack(state,team,prey_id)`：dispatch-time scout-verify scaffolding（ports cascade 312-349 tail；不確定+慎重→TASK_SCOUT、confident/莽者→TASK_ATTACK）。
  - 加 `_tick_conquest_scout`：scout 生命週期（逾時釋放 / prey 消失 / 收斂轉攻），取代舊 cascade 的 scout timeout/自家 scout 重評段，loop3 每 tick 呼。
  - 刪 `_evaluate_prosperity_attack` 決策（fai:259-349）+ loop3 invoke + 序2 solo yield 閘 + `_decide_unified` unified reroute。
  - `_decide_unified`/`_evaluate_solo`：征服 intent 攻擊 winner → `_commit_conquest_attack`（scout-gated），非 raw dispatch。純血仇攻擊(非征服)照走 raw dispatch（confidence 脫軌不 scout-gate）。
- `scripts/debug/prosperity_dissolution_check.gd`（新）：融合驗 6 錨（①repertoire ②readiness閘 ③斥候 ④照衝 ⑤hunger_relief ⑥富prey）全 PASS。
- `scripts/debug/constitution_baseline.txt`：`_evaluate_prosperity_attack` 指紋刪（arc 溶解）、`_commit_conquest_attack` 指紋加（scout scaffolding，# 序5 標）。sites 32→32（−cascade +scaffolding）。
- `scripts/debug/framework_validation.gd`：S3 scenario 加 `atk.armed_anon_ratio=1.0`（見連動風險）。
- `scripts/debug/headless_test.gd`：cascade 單元測遷移/退役（見連動風險）。

### 與 spec 差異
- **富 prey target 實作走 ctx.intent_target**（gather 令 `intent_target=prosperity_prey_id`）而非改 to_task 簽名——to_task 既有 `intent_target` 優先序自動吃到富 prey，faction_attack > 富prey(征服) > feud 優先序保。
- **信義 penalty 落 intent_fit**（非 attack weight）：`conq_person = clampf(0.5 + max(野心,好戰)*0.5 − 信義*0.4, 0, 1.5)`。

## 征服率 before / after（★gen 重校依據）

conquest_measure bed（游擊征服名vs實）：

| probe | before (cascade) | after (dissolve) |
|---|---|---|
| conq.declared (征服 intent 宣告) | — | **2146**（鏈起點活躍） |
| conq.intent (reach solo winner) | n/a | 26 |
| conq.winner_loot | n/a | **21** |
| conq.winner_prosperity (攻擊 winner) | n/a | **0** |
| g3.scout_dispatch | — | 0 |
| conq.prosperity_reached | **2** | **0** |
| 掠奪達capture率 by_attack | 0 | 1 |
| conq.combat_entered / retreat_captured | — | 15 / 3 |

**關鍵發現（gen 重校核心輸入）**：征服 intent 隊 rank **掠奪(21/26) 壓過 攻擊(0/26)** → `_commit_conquest_attack` 從不被觸發（scout/prosperity_reached=0）。**根因=readiness_factor 正確壓抑**：攻擊 util = 1.5×conq_person×cap×**readiness_factor**；掠奪 util = loot_drive×weight(~0.6cap) 不吃 readiness。readiness_factor<0.5（readiness<0.5×thr_eff）→ 掠奪勝。即「**沒本錢的征服隊改掠奪(小承諾) 而非出征**」＝合設計（capability/readiness grounding）。ready+armed 隊 攻擊會贏（harness ①/framework S3 證）。

**非凍死**：世界有 churn（60→54 隊、8 factions、combat_entered=15、retreat_captured=3、by_attack capture=1）→ parity 哨（不歸零/不龜縮）過。conquest 仍經 loot→combat→capture 發生，只是「征服→攻擊 clean chain probe」在此 bed 2 月窗口未主導。

**藍圖裁量點**：(a) 是否 readiness_factor 太重壓死 攻擊(vs 掠奪)？(b) 是否接受「unready 征服隊掠奪、ready 才出征」＝正確？(c) 序6 接回成員打草穀後征服率是否回升？→ **gen 重校 follow-up 觸發**（據此 shift）。baseline 的 2 次 prosperity_reached 主要來自 loop3 cascade 跑成員（已刪，序6 接回）。

## seeded 漂移
- before: 52/9/1/381 → after: **52/8/1/380**（factions 9→8、pop 381→380；漂移允許，QA wave 判；征服鏈不歸零=parity 哨過）。

## 連動風險（主 session 決定是否補修）

1. **★成員打草穀 raid 移除（框架債縫#3 未結清部分）**：舊 loop3 cascade 對 faction 成員(非 leader)也跑 prosperity attack（打草穀 day-op raid）。序5 刪 loop3 cascade 後，成員征服 intent 只宣告、**無獨立 dispatch 路**（成員不呼 `_evaluate_solo`）→ 成員打草穀 raid 暫時消失。**spec/plan 定序6 loop3 全溶接回**（框架債縫#3 序6 續）。獨立 FORCE 隊征服鏈完整（主交付）。`_is_prosperity_candidate` 候選判定保留。

2. **framework S3 scenario 加武裝**（測試設定修正，非行為改）：dissolve 後征服攻擊走主 rank，`攻擊` util = intent_fit 征服 × **capability cap**（self_armed_ratio/VIABLE_ARMED_RATIO）。舊 cascade 無 capability 閘 → S3 scenario 未武裝（armed_anon_ratio=0）→ dissolve 後 cap=0 → 攻擊 util=0 不 rank 得贏 → scout 不 dispatch。加 `armed_anon_ratio=1.0`（真實 FORCE 隊本應有兵）。同理 `solo_dissolution_check` 6a-1 + `headless_test` intent_fit 征服 unit test 補 readiness 欄。**行為正確化**：無兵隊本就不該征服（capability grounding）。

3. **readiness weight vs 舊 gate 行為差**：舊 cascade `readiness < threshold_eff → return`（硬閘）；新 `intent_fit 征服 × clampf(readiness/thr_eff)`（權重，低 readiness→util 趨0 但非硬 0）。邊界隊（readiness ≈ threshold）行為較平滑；readiness 略低但其他驅力強的隊可能仍攻（合憲法「狀態=權重非硬閘」）。gen 重校時留意。

4. **calc_attack_score / ATTACK_SCORE_THRESHOLD / PROSPERITY_CADENCE(_MILITARY) orphaned**：cascade 刪後這些 const/helper 無 production caller（calc_attack_score 仍有 `_test_prosperity_treasury_bonus` 單元測引用）。保留避churn；arc 尾可清。

5. **cascade 單元測遷移/退役**（headless_test.gd）：
   - 遷移（行為保留 → 改呼 `_commit_conquest_attack`）：`_test_faction_attack_gate`(G3d-1 scout)、`_test_scout_verification`(G3d-2)、`_test_evaluate_prosperity_trigger`。
   - 遷移（helper 保留）：`_test_prosperity_same_faction_skip` → 改驗 `find_prosperity_prey`==-1。
   - 退役（硬閘溶成權重，覆蓋移至 engine harness）：`_test_prosperity_low_ambition_skip`、`_test_prosperity_low_readiness_skip`、`_test_prosperity_gated_by_ladder`、`_test_r1a_rung_gate_removed`、`_test_prosperity_cadence`（cadence 機制溶解）。
   - 削（成員 raid dispatch 待序6）：`_test_raid_continuity_member` B1/B2 刪，A(_is_prosperity_candidate)保留。

6. **`longwindow_bed.gd` `_diag_gate`（LW_DIAG=1 gated 診斷）**：手複算舊 cascade 入口鏈（score/readiness gate），stale 但不 break（off by default）。arc 尾更新或刪。

7. **`docs/invariants.md` G3d-2 段 + `known_issues.md` 引用 `_evaluate_prosperity_attack`**：doc 提及已刪函數，主 session（系統 owner）決定是否更新措辭指向 `_commit_conquest_attack`/engine 路。

8. **pre-existing 失敗（非本 arc 引入）**：`headless_test._run_sim_test` 的「弱目標未加入攻擊 goal」sub-check 在 base 9f59d1b 即 FAIL（已 stash-驗證）。與序5 無關。

## 待主 session 確認

- **★gen 重校 follow-up 觸發**（藍圖裁定）：據征服率 before/after shift（見 measure 段）。藍圖 seq5-greenlight 重框：雪球/暴衝≠fail，唯龜縮凍死=fail；parity 哨只驗征服鏈不歸零。
- **B 照妖鏡（決策模型驗收）**：新閾殘全域者標 B-債——`VIABLE_ARMED_RATIO`(cap)、`readiness_thr_eff`（已含慎重 via calc_readiness_threshold ✓ 部分人格化）、`INTENT_FIT_DRIVE`、信義 penalty k=0.4。arc 尾/另軌「常數人格化」收。
- **序6 loop3 全溶**：接回成員打草穀 raid（連動風險#1），框架債縫#3 完全結清。
