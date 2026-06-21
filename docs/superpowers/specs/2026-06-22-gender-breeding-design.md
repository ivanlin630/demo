# 性別資料 + 生育需兩性（④Trait 前置資料，獨立小改）

> 藍圖 `gender-prethink`（範圍 a：資料 + 生育，非 Trait 縫機器）。生育是自動人口過程（reaction），非 team 決策 → 不經統一框架 → 獨立小改、不卡框架。

## 範圍（最小 + 避坑）
- **做（獨立）**：性別資料 + 生育需兩性 → emergent「全男戰幫內部不繁衍」。
- **不做（耦合 combat=未決，留他域後）**：戰損扭斜性別比（戰爭傷疤）；性別戰鬥角色/繼承/社會角色（④後 content）。
- **資料模型決策**：anon 用 **team-level `anon_female_ratio`（float）**，**不動 anon_cohort key schema**（`tier|health` 不變）→ 避開 in-flight cohort 重構衝突 + ratio 是 metadata 不影響 pop count = **conservation 安全**。藍圖授權「team-level 男女 ratio」。

## 改動
### 1. PersonData.sex（named）
`person_data.gd` 加 `var sex: String = "male"`（"male"/"female"）。`person_generator.gd generate()` 50/50 roll 設 sex（seeded rng）。`generate_for_team`（晉升）沿用 generate() 的 sex。

### 2. TeamData.anon_female_ratio（anon 性別比）
`team_data.gd` 加 `var anon_female_ratio: float = 0.5`（anon 女性占比）。world-gen 初始 ≈0.5（均衡）。maturation/promotion **不改 ratio**（新生假設均衡；戰損扭斜留 combat）。

### 3. 生育需兩性（reaction_system `_evaluate_life_events`）
現：任一 named（食/安足）roll breed。新：**team 須兩性俱在**才 breed，成長 ∝ 平衡：
```
M_eff = named 男數 + round(anon_total × (1 - anon_female_ratio))
F_eff = named 女數 + round(anon_total × anon_female_ratio)
if min(M_eff, F_eff) <= 0: 不 breed（全單性 → 內部 0 繁衍）
balance = min(M,F) / maxf((M+F)/2, 1)   # 0..1，越平衡越高
chance = (BREED_BASE_CHANCE + 醫療×0.1) × balance   # 軟縮放(TEST VALUE)
```
P5_breed apply 不變（minor_population += 1）。maturation 不變（minor→anon PLEB；新 anon 不改 ratio）。

## emergent（價值）
- 全男戰幫（named 全男 + ratio 0）→ F_eff=0 → 內部 0 繁衍（只能招募/吸收）。
- 定居有兩性隊 → 自然成長。
- （戰損扭斜→人口傷疤 = 待 combat 他域接，ratio 已備欄位可被扭斜）。

## 守恆 / 不破既有
- `anon_female_ratio` = metadata，**不影響 pop count**（cohort 總數不變）→ InvariantAudit population 零影響。
- anon_cohort key schema 不動 → 既有 cohort 測/refactor 零衝突。
- 生育只改 gate（chance 縮放），不碰 resources/coin。

## 驗收
- named 有 sex（50/50 生成）；單測。
- 全單性隊（M 或 F=0）→ breed chance=0（不繁衍）；兩性平衡隊 → 正常 breed；單測。
- 2 年 world_sim：pop 仍均衡成長、無 conservation 破（InvariantAudit population 0）、headless 全綠、coin_eq 0。
- 全男隊（config 種一支）內部 pop 不長（靠招募）= emergent 證（world_sim trace 或單測）。

## 檔案
- `person_data.gd`：加 sex。
- `person_generator.gd`：generate() 設 sex（50/50）。
- `team_data.gd`：加 anon_female_ratio。
- `reaction_system.gd`：`_evaluate_life_events` 生育兩性 gate。
- `world_generator.gd`（若需）：初始 anon_female_ratio≈0.5（預設 0.5 已夠，除非要扭斜種子）。
- `headless_test.gd`：sex 生成 / 全單性不繁衍 / 兩性繁衍 測。
- 2 年 world_sim 驗收。

## TEST VALUE
- 生成 50/50；anon_female_ratio 預設 0.5；balance 軟縮放（min/avg）。嚴/軟可調。

## 非本塊
- 戰損扭斜性別比（戰爭傷疤）= combat 他域（未決）後接 ratio。
- 繼承/家族樹（父系母系）= 死亡繼承/Graph 血緣（另）。
- 性別戰鬥角色/社會角色/多元性別 = ④後 content / 不做。
