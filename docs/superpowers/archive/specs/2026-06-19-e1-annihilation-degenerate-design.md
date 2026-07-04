# E-1 結構免疫退化修 + 武裝下限 — Design

> 母 spec：`specs/2026-06-19-combat-unification-umbrella-design`。藍圖裁定（`handbacks/2026-06-19-blueprint-to-systems-e1-annihilation-ruling`）= E-1 只做**退化版**：敗方結果觸整隊 pop（殺結構免疫）+ tier 加權存活 + 武裝下限堵 cheese。**不**含完整人均戰力/意志公式/人海反殺（移出 E-1）。
> 與 `specs/2026-06-19-leader-succession-single-source`（繼承統一）並列為 E-1 兩塊；三塊（含武裝下限）合起 = 世界收斂 land。

## 問題（病灶 1：結構免疫，known_issues E-1）

- **encounter**：spawn 只上場 `named + mini(pop×armed_anon_ratio, ANON_UNIT_CAP)`（encounter:247-248）；結算 `kill_random` 只數**上場** dead_anon（encounter:1186-1194）→ 未上場 anon mass 永不進 kill 池 → 大隊 pop 殺不掉。
- **npc_combat**：`_apply_casualties` 只 wound anon（`wound_random`），`_end_combat` 只 loot/subjugate，**敗方 pop 不損耗**（除 `_apply_pursuit` 條件 5%）→ 同樣不收斂。
- **0 武裝 cheese**：`armed_anon_ratio=0`（equipment_system:67，無武器）→ encounter spawn 0 anon → 只 1 named 接戰 + 反覆被刷殺不死。

## 設計

### A. 敗方損耗落整隊 pop（兩路徑對稱，殺結構免疫）

敗負判定後，對**敗方整隊 anon pop（含未上場/reserve）**施 tier 加權陣亡，magnitude 綁實際戰鬥烈度（非武斷常數）：

- **encounter（`resolve_encounter_end`，改 encounter:1186-1194 段）**：
  - 先算上場 anon 陣亡率 `field_rate = dead_anon_onfield / max(onfield_anon, 1)`。
  - 對敗方**未上場** anon 施同等比例（或折扣係數 `RESERVE_CASUALTY_MULT`，TEST VALUE，預設 1.0 = 同命運；可 <1 表後排折損較輕）陣亡。
  - 勝方維持只上場結算（勝方不連坐 reserve）。
- **npc_combat（`_end_combat`，npc_combat:205-278 內補）**：
  - 敗方 pop 損耗 = `loser_anon × LOSER_CASUALTY_RATE`（TEST VALUE；複用先例 `force_occupy` 20% 量級 encounter:1424）。
  - 對稱性：NPC-vs-NPC 與 encounter 同走「敗方 pop 連坐」，無玩家專屬豁免（game-design §對稱性）。

### B. tier 加權存活（平民承重、訓練兵多生還）

藍圖要「平民承受最重 / 訓練兵多半生還」。現 `AnonTierSystem.kill_random`（anon_tier_system:83）weighted = **依各 tier count 比例**抽，**非存活品質偏向**。

- 加 survival-bias：死亡權重 ∝ `count_tier × survival_weight(tier)`，低 tier 權重高（平民死多）、高 tier 權重低（菁英生還）。
- 實作：`kill_random` 加可選 `tier_bias: Dictionary`（tier→權重乘數，預設均一 = 現行為，不破既有 caller），或新 `kill_random_weighted`。`survival_weight` 表（平民1.0/新兵0.6/老兵0.3/菁英0.15，TEST VALUE）放 config 或 AnonTierSystem const。
- A 的兩處 pop 損耗都走此加權。

### C. 武裝下限（堵 0 武裝免疫 cheese）

- `armed_anon_ratio` 在**消費端**設下限 `ARMED_RATIO_FLOOR`（TEST VALUE，如 0.1；config），**不覆寫** equipment_system 推導值（保留實際武裝資訊）。
- 落點：
  - encounter `init_encounter:247-248` spawn anon 數用 `max(armed_anon_ratio, FLOOR)`。
  - npc_combat `_strength_raw:381` anon 戰力項同步用 floored ratio（無武裝 anon 仍以低戰力參戰，符 game-design「平民會抄傢伙/反抗」）。
- 效果：0 武器隊仍 field 少量低戰力 anon → 可被接戰、被 A 連坐損耗 → 無免疫。

## 連動 / 風險

- **與繼承統一交互**：A 使敗方 anon 漸減 → 終至 anon=0 → `on_leader_death`（繼承 spec）無 named 無 anon → 回 false → 滅團。兩 spec 合起即 game-design「打到死＝絕境稀有結果」。確認順序：損耗 → 繼承檢查同一結算流程內或次 tick 安全網皆可。
- **kill_random 既有 caller 不破**：tier_bias 預設均一 = 現行為；既有 encounter:1194 改傳 bias 後行為變（這正是目的），其餘 caller（饑荒/疫病等）不傳 bias 維持原樣。**列出並確認** kill_random 全 caller，只 combat 端傳 bias。
- **武裝下限副作用**：FLOOR 使原本 0 武裝隊戰力上升 → 可能改變既有 encounter 平衡測試。FLOOR 取小（0.1）+ 標 TEST VALUE，回歸測試若漂移則調。
- **守恆**：pop 損耗走 `kill_random`（cohort 唯一來源，invariants anon 規則）；連坐的 reserve 也須經 cohort API，不裸改 population getter。treasury/裝備 loot 既有邏輯不變。
- **勝方不連坐**：只敗方 reserve 受損；確認勝負判定（attacker_win/defender_win/draw）對 draw 不施（draw 無敗方，沿用 BUG-10 跳過）。

## 測試標準

- headless：
  - `_test_e1_encounter_reserve_casualty`：敗方大隊（pop≫ANON_UNIT_CAP）打輸 → **未上場 anon 也減**（reserve pop 下降），非只上場。
  - `_test_e1_tier_survival_bias`：混 tier 敗方損耗 → 平民死亡比例 > 菁英（survival_weight 生效）。
  - `_test_e1_npc_combat_loser_pop_loss`：npc_combat `_end_combat` 敗方 anon pop 確實減（對稱）。
  - `_test_e1_armed_floor`：`armed_anon_ratio=0` 隊 encounter spawn anon > 0（floor 生效），可接戰。
  - `_test_e1_converges`：弱隊反覆被打 → anon→0 → 繼承無人 → 滅團（整鏈：A+B+繼承統一）。
- 回歸：`=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick 無崩潰；既有 encounter/anon-cohort 測試不破（kill_random 無 bias caller 行為不變）。

## invariants.md 新增

> **敗方損耗對稱**：encounter 與 npc_combat 敗方結算皆對敗方整隊 anon pop（含未上場）施 tier 加權陣亡（`kill_random` + survival-bias），無玩家專屬豁免。pop 變動只經 cohort API。

## 範圍

本 spec = 結構免疫退化修（A 整隊 pop + B tier 存活加權）+ C 武裝下限。**不含**：完整人均戰力公式、參戰意志/desperation 戰場套用、人海品質重扣、屠俘散命運（戰俘 spec）、等量耗時、遭遇戰 UI——全歸母 spec 後續子 spec。繼承統一另 spec。
