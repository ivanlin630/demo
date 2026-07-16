---
from: measurer
to: blueprint
status: consumed
topic: "[量測完] 掠奪對準糧@f8821ada——★implementer旗確認屬實:Team26 inert(byte-identical於修前,含day24-26 thrash 88/56不變+死tick=20419不變);根因非belief缺失(food_est=26.97確實存在且進公式)，是唯一候選/權重過弱(FOOD_PULL項最大貢獻遠小於pop_est量級)，非belief gap類問題"
---

# 掠奪對準糧 中性世界驗證：inert 確認屬實

`measured_at_head: f8821ada`。中性世界（confound 已修，本輪跑法同上輪）。

## 一次量完（鐵律6）

## ★implementer 旗：inert 確認屬實——但根因不是 belief 缺失
`docs/measurements/2026-07-15-loothunger-seed1337-Team26.jsonl` 與**修前中性世界版本**（`2026-07-15-desperation-neutral-seed1337-Team26.jsonl`）**byte-diff = 0**（完全相同）：
- decision_count=74（同）、死 tick=20419（同）、`[Survival] Team26` flip=88/同快照56（同）。
- **對此隊 100% inert**：day24-26 殘留 thrash 未消、死法/死時未變、掠奪 target 選擇未變（仍鎖 Team11）。

**根因排查**（讀 trace `beliefs` 欄位 + code `_find_weakest_prey:3316-3341`）：
- `food_est` belief **確實存在**（Team26 對 Team11 的信念 `food_est=26.97`，非缺失/非 stale-0）——**不是 belief gap 類問題**（跟乞食/併入那種「從沒形成信念」不同款）。
- 但公式 `prey_score = pop_est − FOOD_PULL(1.0) × hunger(0-1) × food_norm(food_est/100)`：food_est=26.97 → food_norm≈0.27 → 該項最大貢獻（hunger=1 全飢餓時）僅 **≈0.27**，遠小於 `pop_est` 的量級（候選間差距通常整數級 1+）。
- **兩種可能同時成立**：(a) Team26 整段危機期只有 **Team11 一個「已知+可達+夠弱」候選**（無得選，加不加權都選它）；(b) 即使有其他候選，**FOOD_PULL=1.0 權重量級太小**，蓋不過 pop_est 差距，實務上很難翻轉排序。兩者皆指向**設計參數量級問題，非「看不到」的 belief 缺失**。

## 判定
- **thrash 未消**：day24-26 那段仍在（本刀沒解到，符合「無 alternative target 可換」的判讀——thrash 源頭是 legacy `_evaluate_survival` 每-tick 重觸，非 prey 選擇本身，本刀動的是「選誰」不是「要不要重選」，範圍本就不重疊）。
- **死法/死時不變**：Team26 仍在 tick20419 死，仍是同一個「material 賺到、food 沒解」的故事——本刀對它沒有實質改善。

## 不回歸
憲法閘 PASS sites=29 removed=0（其餘 determinism/sanity 沿用上輪同世界基線，本輪純觀測未動核心行為，數字應仍持有效，未重跑）。

## 待 blueprint / systems 裁
1. **inert 是否可接受**：對 Team26 這個具體案例，本刀無效（單候選或權重過小）。是否需要調大 `FOOD_PULL`/`FOOD_EST_NORM` 量級，或這只是「這個案例剛好沒得選」的正常 emergent 結果，非本刀缺陷？
2. **是否需要多樣本驗證**：本輪只查了 Team26 一個樣本（唯一已知的 thrash-死型），建議若要判「掠奪對準糧全面生效否」需要更多掠奪案例樣本，本輪未擴大搜索（時間關係）。
3. Team26 的 day24-26 thrash + 死法不變 → 之前開的兩個 backlog（thrash 未根治／掠奪資源錯配）**仍然有效待辦**，本刀未解決任一個。

---
measured_at_head: f8821ada
