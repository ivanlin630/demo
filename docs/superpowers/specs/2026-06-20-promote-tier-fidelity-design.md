# 升 named 忠於 tier（#0b）— HOW design

> 來源：藍圖 ruling `2026-06-20-blueprint-to-systems-dramatic-distribution`（item 4「升 named 忠於 tier」）。
> feel/WHAT 藍圖給；分佈形狀 / tier→skill 映射 / 抽 tier 權重 = 系統 HOW + TEST VALUE。
> 承 #0 戲劇尾巴（`world-gen-dramatic-tail`，已 merged）。本項補其結構缺口。

## 病（root，ruling item 3）

`PersonGenerator.generate_for_team`（升 anon→named）：
1. 呼 `generate()` **不看來源 tier** → 新 named 拿 `randf_range(0.0,0.3)` 低技能。
2. `kill_random(team, 1, "promote")` 預設**按 count 比例**抽（平民最多 → 幾乎都抽平民）。

合起來：菁英 anon 升 named = 隨機低技能，**老兵/菁英本事蒸發**；#0 generate 的技能尾巴被晉升路徑稀釋。named 高技能本該是「被提拔的老兵」，現在不是。

## HOW 決定

### 1. 晉升偏好抽高 tier（提拔精銳）
`kill_random` 已支援 `tier_weight` 參數（非空 = 各 tier 抽中權重 ∝ count × tier_weight）。
晉升傳偏高 tier 權重，且**用回傳值得知實際抽中的來源 tier**：

```gdscript
const PROMOTE_TIER_WEIGHT := {"平民": 0.2, "新兵": 0.6, "老兵": 1.5, "菁英": 3.0}  # TEST VALUE
```

- 高 tier 在 = 優先升精銳（亂世爬到隊長者本是本事突出）。
- 但 count 仍入權重 → 全平民隊（早期）仍只能升平民 = 低技能民兵頭（正確）。
- 非硬選最高 tier：保留隨機性（偶爾升個新兵）。

### 2. 來源 tier → 戰鬥簇技能帶
新 named 的戰鬥簇（戰鬥/戰術/統領）技能由來源 tier 設下限：

```gdscript
const PROMOTE_TIER_SKILLS := {              # TEST VALUE
	"平民": {},                                              # 不加成 = generate 低值（民兵頭）
	"新兵": {"戰鬥": [0.30, 0.50]},
	"老兵": {"戰鬥": [0.50, 0.70], "戰術": [0.30, 0.50], "統領": [0.30, 0.50]},
	"菁英": {"戰鬥": [0.70, 0.90], "戰術": [0.50, 0.70], "統領": [0.50, 0.70]},
}
```

- 用 `maxf(現值, roll)` 套用：**不蓋既有 archetype 尾巴**（#0 outlier roll 給的高技能不被降）。
- 戰鬥簇對齊 TIER_STATS combat 階梯（0.1/0.3/0.5/0.7）+ named 略高（被提拔者≥同 tier 平均）。
- 只動戰鬥簇 3 鍵；非戰鬥技能（醫療/商業/計謀…）不由戰鬥 tier 決定 → 留 generate 預設（避免「菁英兵升上來突然會醫術」）。

### 3. 一致性（ruling item 5）
- 初始 leader 走 `game_setup` 的 `generate(role="leader")`（outlier 0.45 + skill +0.1）—— 已有戲，**不動**。
- 升階 named 走 `generate_for_team` → 本項補。兩路徑都有技能尾巴來源。

## 邊界 / 守恆
- **只改生成技能值**，不碰 state 流 / 守恆 / treasury share（既有邏輯原樣）。
- `generate_for_team` 簽名不變；callers（faction_ai / event_system / population_system / player_command）零改。
- `kill_random` 已有 `tier_weight` 參數，**不改 AnonTierSystem**（零新概念，複用）。
- 確定性：來源 tier 抽用 global `randf()`（既有 kill_random 行為，pre-existing 非決定）；技能 roll 用本地 seeded rng（`_team_seed` 衍生）保可重現。測試用全平民/全菁英隊 → 來源 tier 唯一 → 斷言穩定。

## 驗收
- 全菁英 anon 隊升 named → 戰鬥 ≥0.7、戰術/統領 ≥0.5。
- 全平民 anon 隊升 named → 戰鬥簇低（generate 預設 ≤~0.4）。
- 既有 `_test_promote_anon_takes_share`（_seed_pop 全平民）不破 → 平民升 = 低技能 + coin share 不變。
- headless 全綠、coin_eq=0、InvariantAudit 0（純生成值，不破守恆）。
- （重量）world_sim 技能分佈：菁英升的 named 顯著高於平民升的；大盤仍多數平庸。
