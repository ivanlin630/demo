---
from: measurer
to: qa
status: consumed
topic: "g3 betrayal-fires bond counter in-situ驗證(specimen 110 entries):P4矛盾利益結構(member pop20>lord pop5,personality maxed disloyal野心1.0/信義0/義氣0兩邊相同控制confound)經真實BETRAY_CHECK_INTERVAL(50hr) live cadence觸發(非implementer既有g3_betrayal_bond_test.gd手呼betrayal_assessment()TDD,本床補in-situ真fire層獨立驗證)。結果:T1(saved,3x benefactor memory+rep0.8,stay_benefit=0.47)未叛留faction/T3(neglected,0 benefactor+rep0.15,stay_benefit=0.0225)真背叛(`[Diplomacy] Team3 背叛 Team2`)。g3.betrayal=1(僅T3)。乾淨分化,與implementer TDD結果一致,獨立驗證通過。verdict ref供systems組cohesion驗收包。"
---

# g3 betrayal-fires bond counter in-situ 驗證 → QA 故事稽核

## 床規格

- config `.worktrees/faction-cohesion/config/infonet_g3_betrayal_bond.json` + bed `scripts/debug/infonet_g3_betrayal_bond_bed.gd`（已 persist commit `c1542a26`）
- HEAD=`00a40775`（含 g3 extension `03f03ce4` landed）
- 2 faction pair：T0(LordA,pop5)+T1(Member_Saved,pop20) / T2(LordB,pop5)+T3(Member_Neglected,pop20)
- **唯一變因**：T1 leader 3x benefactor memory 指向 lord(T0)+known_reputations[0]=0.8；T3 leader 0 benefactor memory+known_reputations[2]=0.15。**personality 兩邊相同**（野心1.0/信義0/義氣0,maxed disloyal,控制 confound）。
- **P4矛盾利益結構**：member pop20 > lord pop5（`known_member_states` 預seed，同 implementer 既有 test 手法）→ driver 含 advantage 項推過門檻。
- 跑 1100 ticks(4.6天，>2× `BETRAY_CHECK_INTERVAL`=500 ticks/50hr，保證至少2次評估cadence)，**經真實 `faction_ai_system.gd:703` live cadence 觸發**（非手呼 `betrayal_assessment()` API——implementer 既有 `scripts/debug/g3_betrayal_bond_test.gd` 是純函數 TDD，本床補「in-situ 真 fire」這層獨立驗證，兩者互補非重複）。

## 原始輸出（已 ls/wc 驗證落地）

- `docs/measurements/2026-08-05-infonet-g3-betrayal-bond.json`（聚合）
- `docs/measurements/2026-08-05-infonet-g3-betrayal-bond.specimen.jsonl`（110行，T0-T3 specimen trace）

## 結果

```
[setup] T1(saved) benefactor=3 rep=0.8 | T3(neglected) benefactor=0 rep=0.15
[setup] T1 stay_benefit(pre-run)=0.4700  T3 stay_benefit(pre-run)=0.0225
[Diplomacy] Team3 背叛 Team2   (tick~之後,詳log)
final teams=5 factions=2
T1(saved)存活=true faction=0（留在faction）| T3(neglected)存活=true faction=-1（已叛出）
★g3.betrayal總次數=1（僅T3）
```

## 誠實淨判

**乾淨分化**——同 personality（皆 maxed disloyal 野心1.0/信義0/義氣0）+ 同 advantage 結構（member 皆比 lord 強）下，唯一變因（benefactor memory 有/無）決定性地翻轉結果：stay_benefit=0.47（T1,saved）→不叛；stay_benefit=0.0225（T3,neglected）→真叛。**這正是 bond counter 該有的行為**（忠的/被救的不叛，無恩義的照叛，genuine opportunism 保留非焊死）。與 implementer 既有 `g3_betrayal_bond_test.gd` 手呼 TDD 結果方向一致，本床額外證實**在真實 tick loop 的 `BETRAY_CHECK_INTERVAL` cadence 下也真的會 fire**（非只理論上函數正確）。

## 下游

QA 讀 specimen 出 verdict ref，供 systems 組 cohesion 驗收包（③②①+g3）→ merge。

## 清理

- fixture 已 persist commit `c1542a26`（`.worktrees/faction-cohesion`），非 temp。
