---
from: implementer
to: systems
status: open
topic: 獨立戰略層(野心獨立隊建國 intent)實作完成；機制通+稀有+守恆,但 established 1→多 未在 bed 窗內顯現(誠實標,交主 session 長跑/評估)
---

# Hand Back: 獨立戰略層（野心獨立隊建國 intent）

統一決策 arc 第三塊 / (a) 征服者湧現最後一哩。branch `feat/independent-strategic-layer`。

## 實作摘要（改檔）
- `scripts/simulation/faction_ai_system.gd`：
  - 新 `_evaluate_independent_strategy`（mirror commander-v2 `_select_intent` 輕量）：fid=-1 + 野心≥`AMBITION_FOUND_MIN`(0.55) + 累積夠(pop≥EXPAND_MIN_POP + 食盈餘≥`FOUND_FOOD_SURPLUS_DAYS`=7日) + founding 路徑可達 → 秤建國 vs 守成 → means-end 子行動 **結盟(義氣染,`_nearest_independent`→TASK_DIPLOMACY)/吞併(殘忍·好戰染,`_find_weakest_prey`→TASK_ATTACK)** argmax+hysteresis → 複用既有 create_faction（interaction:333 / npc_combat:524）。守成=不 dispatch。
  - 常數 `INDEP_STRATEGY_CADENCE`/`AMBITION_FOUND_MIN`/`FOUND_COMMITMENT_BONUS`/`FOUND_FOOD_SURPLUS_DAYS`（全 TEST VALUE）。
  - 接點 = `evaluate_all` solo 迴圈 `_evaluate_solo` **前**（戰略意圖先於個體日常）。
- `docs/invariants.md`：決策域加「獨立戰略層」不變量（野心普世驅力,戰略意圖非 faction-only;建國=means-end option 非 fiat;複用 create_faction;意圖集{建國,守成};稀有三閘;宣告 defer;接點不雙寫 _evaluate_solo）。
- `scripts/debug/headless_test.gd`：5 新測（strategic_found 結盟 / low_ambition no-found / isolated no-found / subjugate dispatch / found_to_faction 整環 fid -1→正）。
- `scripts/debug/indep_found_bed.gd`（新）：warring config bed，量 established/CONQUER/建國 dispatch funnel。
- `scripts/debug/warring_states_seed.gd`：加 `indep.found_ally/subjugate` probe。

## 接點選擇 + 理由（plan Task1 Step1 measure）
- 探了 3 候選：`_evaluate_solo`(SoloAI)/`_decide_unified`(unified tag)/faction_ai per-team 迴圈。
- **選 solo 迴圈 `_evaluate_solo` 前**（非 per-team 第二迴圈，非塞進 _evaluate_solo 內）。理由：
  - 戰略意圖層 = commander-v2 `_update_goals` 的對位（高於個體日常）；插 `_evaluate_solo` 前 = 建國 intent 先於 SoloAI 貿易/紮營/govern，dispatch 後 SoloAI 見非 idle 自動跳過（**不雙寫**）。
  - **初版犯錯（已修，記取）**：先塞 per-team 第二迴圈 + IDLE-gate + cadence-gate → bed 量證 **dispatch=0 漏觸發**。根因：累積夠(pop+7日食盈餘)的獨立隊=成功定居/治理隊，恆跑日常 task **永不 idle**；SoloAI 每 tick 搶走 idle，戰略層 cadence tick 永遠撞非 idle。修：移到 solo 迴圈前 + busy-gate 改「只讓位高優先(survival/threat/combat/vendetta/player @>PRIO_DISPATCH)，允許打斷日常(release+re-dispatch)」+ found-task 進行中 guard 防 churn + 去 cadence gate（與 SoloAI 同每-idle-tick 節奏，內部三閘自限稀有）。

## 整環驗證（誠實）
- **獨立能人→建國**：✅ bed funnel `path_ok=N → dispatch=N`（通過三閘者全 dispatch）；2 月 bed `建國 dispatch=6(ally=1 subj=5)`、5 月 `=4(ally=2 subj=2)`。`[IndepStrategy]` print 出現。
- **建國→create_faction(fid -1→正)**：✅ 確證於 deterministic 整環測 `_test_indep_found_to_faction`（結盟→`_try_diplomacy`→`create_faction`→founder.fid -1→0、members=2）。sim 中 faction 數有短暫增（月1 8→9）佐證。
- **成 faction 後爬 rung3**：⚠️ **未直接量到**。`rung_diagnose.gd` 重型(10月×72000 tick)**未跑完**（GODOT_TIMEOUT=2500s 牆，無 DONE/月標）→ 交主 session 重跑。
- **established 1→多**：❌ **未在 bed 窗(2~5月)顯現**。established 全程卡 1（= 既有 commander-v2 立國，非獨立建國貢獻）；warring 為高 attrition 環境，`teams` 42→28、`factions` 8→5（被吞/滅快過新建）。founded faction 要麼戰國熔爐中夭折、要麼未在窗內達 `is_established` gate(readiness≥0.7+統領≥0.4+野心≥0.6+members≥2)。
- **CONQUER 0→小正**：△ bed 中 CONQUER意圖偶 0 偶 1（established 未漲 → 征服候選未明顯增）。
- **不 over-found**：✅ 建國 dispatch 總 4~6 vs 獨立隊 ~38/月 = 稀有（非建國潮）。
- **守恆**：✅ game_sim_multi 4 配置 coin_eq delta=0、InvariantViolation=0；framework S1-S6 PASS=6/DORMANT=1（S3 scout 為**既有** dormant，非本次引入）。
- **既有 solo/survival 不回歸**：✅ headless 全綠（=== DONE ===）；守成隊(低野心/孤立)行為原樣（測證 task=idle 不建國）。

## 連動風險（待主 session 評估）
- **established 1→多 未達 = (a) 收尾未完全閉環**：機制(建國 drive)補上了，但「founded faction 活到 established → 征服候選增」這段在 warring 熔爐未顯現。可能需：①更長跑(warring full 172800 tick，背景)②founded faction 早期存活/establish gate 平衡(屬 commander-v2 領域，**本實作 scope 外**，未動)。**未硬調**（守「建國潮就停手；under-conversion 同理記錄不硬 tune」）。
- **吞併(subj) 比結盟(ally) 多**：spec 講「結盟 primary」(指 measure 候選多)，但 persona util(`subj=0.2+殘忍.4+好戰.3` vs `ally=0.3+義氣.5`)在 warring 好戰 leader 池下 **吞併常勝**。emergent 合理但與 spec 框架語氣有出入 → 量級若想偏結盟需調 util 權重(TEST VALUE)。
- **吞併路 統領 tag**：`_try_subjugate` 需 `winner.tags.has("統領")`，獨立 founder 無 → 我在 commit 吞併-建國時**自立 統領 tag**（driver=建國，自立為統領）。屬「複用 create_faction」邊界詮釋，**非新 founding 機制**，但是**新增 tag 行為**，請主 session 確認可接受（替代：吞併路放棄、只留結盟）。
- **founding-diplomacy churn**：去 cadence + 每-idle-tick → 結盟被拒(對方不接受)後隊回 idle → 下 tick 可能重派同 ally（`_try_diplomacy` 未設 `diplomacy_reject_cooldown`）。bed 未見爆量(dispatch 稀有)，但理論上驅動隊會反覆嘗試。可後續接既有 reject cooldown。
- **打斷日常 op 的經濟影響**：busy-gate 改允許建國打斷 SoloAI 日常(release+re-dispatch)。coin_eq/Invariant 全綠 → 無守恆破，但「成功治理隊偶被拉去建國」對經濟產出的量級影響未專測（稀有 → 預期小）。
- **`solo_intent` 共用**：hysteresis 用 `team.solo_intent`("建國"/"守成")，與 SoloAI 寫 task 名共用欄位 → SoloAI 跑後會覆蓋(hysteresis 偶失效)。非 load-bearing（保守）。

## 待主 session 確認
- (a) 收尾判定：機制通+稀有+守恆達標；established 1→多 需長跑/平衡 → 算「收尾」還是「機制就位待平衡」？
- 吞併自立 統領 tag 是否可接受（或收斂只結盟）。
- 結盟/吞併 util 權重是否要偏回「結盟 primary」。
- 宣告(solo declare) defer 的孤立野心隊洞（無鄰→守成累積）= backlog，需新機制（spec 已標 defer）。

## 量測指令（主 session 重跑）
```
GODOT_TIMEOUT=3500 ... scripts/debug/indep_found_bed.gd   # 建國 funnel + established/CONQUER（4月，可調 months 拉長）
GODOT_TIMEOUT=2500 ... scripts/debug/rung_diagnose.gd      # 本次未跑完，重跑驗 rung2→3
GODOT_TIMEOUT=3000 (背景) ... scripts/debug/warring_states_seed.gd  # full 戰國長跑驗 established 1→多
```
