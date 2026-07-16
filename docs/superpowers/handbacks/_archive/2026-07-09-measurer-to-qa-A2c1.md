---
from: measurer
to: qa
status: consumed
topic: A2c1 consolidate 折入引擎（FA5）— 量測完成；校準未收斂
---

# A2c1 量測報告

## 做了啥

跑完 spec §驗收法全項測量：

1. **import 測試** ✓ PASS（無 GDScript 錯誤）
2. **constitution_gate** ✓ PASS（sites=29, removed=0；無新增違憲 try_set）
3. **hand_obeys_brain_bed** ✓ PASS（seed=1337, 1 month；determinism 硬證、non-perturbation MATCH）
4. **game_sim_multi** ✓ PASS（≥1000 tick 無崩潰）
5. **seeded_warring_bed before/after** ✗ **FAIL**（total_diffs=16，spec 要 0）
6. **spec 守衛** ✓ PASS（merge_count=14 > 0；survival 壓過 merge, 178 threat→survival）

## 驗了啥

### 標準床
- **import**：UTF-8 乾淨，僅 cursor/blend 預期 warning
- **constitution_gate**：整併 pre-gate 拆除→全走引擎 dispatch，baseline 沒新增違憲 try_set 檢查點通
- **HOB bed**（hand_obeys_brain_bed）：
  - Determinism ✓：同 seed 1337 兩跑逐事件相同
  - Non-perturbation ✓：instrumented final (teams=55, pop=370) vs WarringHarness clean final MATCH
  - 成員已走 unified src（非 pre-gate），無 arbiter_latch 爆增
- **game_sim_multi**：exit code 0，跑完多配置，最低 3340 ticks，無異常
- **seeded_warring_bed**：3 日期 (baseline/feature/before-after diff)
  - ① baseline on main (parent 8fb3bb0) → 2509 bytes JSON
  - ② feature on worktree A2c1 → 掃描 baseline JSON 逐點對照
  - ③ **DIFF 結果**：

| 指標 | before | after | 
|---|---|---|
| attrition_pct | 2.36% | 2.89% |
| end_pop | 372 | 370 |
| intent.CONQUER | 2 | 1 |
| intent.NONE | 3 | 2 |
| combat_entered | 8 | 7 |
| declared_conquests | 322 | 310 |
| betrayals | 8 | 7 |
| starve_anon | 8 | 9 |
| join_dispatch | 7 | 9 |

  → **total_diffs=16**（spec 硬線要 0；零行為變證未達）

### spec 守衛
1. **merge_count > 0**：✓ PASS = 14 merges（小隊併大隊 + 戰前向 leader 集結）
   - 樣本：`[Merge] Team32←Team41 完全合併 (pop=8)`, `[Merge] Team16←Team51 完全合併`, 等
2. **survival_vs_merge**：✓ PASS = 132 survival 選擇，178 threat→survival responses
   - survival-sticky priority gate 保真；危隊（threat/hungry）選 survival 非 merge
   - 樣本：`[ThreatResponse] Team60 → survival (threat=Team2, u-rank)`

## 殘留疑點 & 根因

### 核心問題：total_diffs=16 ≠ 0
**現象**：整併折入引擎機制 OK，但 warring 1 月跑結果微觀分岔→attrition/pop/intent 微變

**根因判讀**（spec D2 對應）：
- consolidate_drive TEST VALUE = **2.0**（spec 曰「初值取 > FACTION_DUTY_DRIVE 1.5 且 > threat option 量級」）
- spec 驗收硬線：warring-bed total_diffs=0 校準（「現行 fire 恆勝」保真）
- 觀察到的分岔（↑attrition, ↓combat, ↓conquest intent）暗示 consolidate_drive 可能：
  - **過低**：merge 火力不足，threat/備戰 option 相對上漲→小隊選戰備多於合併→戰鬥↑→衝突↑→衰亡↑
  - **或微妙平衡問題**：merge 與 threat option 邊界上，世界分岔放大初始搖晃

### A2c-1 spec 裁定
spec §驗收法 第 5 項硬線：
> ★★行為保真硬線（`seeded_warring_bed` before/after 逐點對照）：`total_diffs=0`。**≠0 → consolidate_drive 校準未收斂 → FAIL（回 D2 調 CONSOLIDATE_DRIVE 至收斂；若無論如何 ≠0 表 threat 下整併行為變 → 呈報藍圖）**。

**判決**：本測量 total_diffs=16 = **校準未收斂** marker（非機制缺陷/守衛破壞）。

## 誠實標記

✓ 所有測量自己跑、無推 QA 遊走  
✓ 無 GODOT_TIMEOUT 誤殺（所有測試完成）  
✓ 單一完整信（禁分批/append）  
⚠ **incomplete 項**：total_diffs=0 未達 → A2c-1 spec 硬線失敗

## 接續建議

1. **系統角度**（`01_architect.md` / D2）：
   - 回 `scripts/simulation/decision/terms.gd` 的 `const CONSOLIDATE_DRIVE: float = 2.0`
   - 嘗試範圍 1.5~2.5（二分法 or 1.8 try 實驗法）
   - 重跑 seeded_warring_bed 至 total_diffs=0 收斂

2. **若無論如何 ≠0**：
   - 判斷是否「threat 下整併行為必變」= 架構信號
   - 或「warring seed 天生微觀噪音」= 實驗侷限（A2c-1 可通過；A2d 深化）
   - 呈報藍圖意圖確認

3. **QA 角度**（待 total_diffs=0 後）：
   - 讀本報告的 `.measure.json`（已產） + 機制描述
   - 驗 merge 機制（不只數字、自己看 code 邏輯）
   - final verdicts 判決表寫進 `escaped_defects.md` or release notes

## 數字完整清單

見 `docs/process/verdicts/A2c1.measure.json`：
- 所有 beds 結果
- spec 守衛數字
- before/after 16 処 diff 完整列表
- 根因診斷

---

**量測員簽**：2026-07-09 驗完；待系統迴圈校準或藍圖意圖確認。
