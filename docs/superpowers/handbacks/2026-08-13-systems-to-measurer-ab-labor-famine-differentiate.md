---
from: systems
to: measurer
status: open
topic: "[a/b 分辨:gather:food labor 硬零真根=(a)NeedOracle famine-blind bug vs (b)guns-vs-butter 動員(blueprint GO、線索終齊裁 arc)·problem:5團(70/83/87/109/111)57-80% 採集 tick labor_mult 硬零=share 0、code-logic 兩互斥根待 measure 分·★決定性測=dump 全 tile.labor_alloc 字典(非只 gather:food 一 key)在硬零 tick:①別工位(gather:material/mfg:*)有 share>0 但 gather:food=0→(a)NeedOracle food need_keep+demand=0=餓著不報食物需求 famine-blind bug②全工位 share 皆 0(pool=0)→(b)共址 PRODUCE 隊 labor_pop 全動員 guns-vs-butter·★輔證 tap:per-team(1)pool 值=Σ共址 TAG_PRODUCE labor_pop 是否 0(2)labor_pop vs total pop=mobilized 比例(labor_pop=0 而 pop>0=動員=b)(3)NeedOracle.need_keep(food)+demand(food) 值 vs famine_days=食物 need 餓時該升卻=0?(=a 直證、food need 不隨飢餓升=need-oracle famine-blind)·★可能 mixed(某團 a 某團 b)逐團報別 aggregate 掩蓋·對照 team47(從不硬零)同 dump 看正常態 labor_alloc 長怎樣·★不 code-guess、真讀 runtime 值(need_keep/demand 是 runtime NeedOracle state 算、必 measure 非公式推)·官方 SpecimenDumpHelper 勿手設 team_ids、先讀既有 gather_factor_trace 再決定補啥 tap·evidence-only 禁 fix 禁預設·output→systems 收口(a/b 定案或 mixed 佔比)→blueprint 攤全桌帶用戶裁 arc·地基 KEEP"
---

# a/b 分辨 — gather:food labor 硬零真根（blueprint GO、線索終齊）

`labor_mult` 硬零 ⟺ gather:food share=0，code-logic 兩互斥根。**這票 measure 分 (a) vs (b)**。不 code-guess、真讀 runtime 值 [[feedback_measure_peroption_util_before_decision_claim]]。evidence-only、禁 fix、禁預設。

## ★決定性測：dump 全 `tile.labor_alloc` 字典（非只 gather:food 一 key）
在硬零 tick（5 團 70/83/87/109/111 的 labor_mult=0 事件）dump 該 tile 的**完整 labor_alloc**（每 workstation 的 `demand`/`share`/`fill`）：
- **別工位（`gather:material`/`mfg:*`）有 `share`>0 但 `gather:food`=0 → (a)** = NeedOracle food `need_keep+demand`=0 = **餓著卻不報食物需求 = famine-blind need-oracle bug**。
- **全工位 `share` 皆 0（pool=0）→ (b)** = 共址 PRODUCE 隊 `labor_pop` 全動員 = **guns-vs-butter**（打仗把人抽走沒人種田）。

## ★輔證 tap（per-team、坐實哪根）
1. **pool 值** = Σ 共址 TAG_PRODUCE 隊 `labor_pop`（`labor_system:38-42`）→ 是否 = 0（=b 直證）。
2. **labor_pop vs total pop** = mobilized 比例（`labor_pop=0` 而 `pop>0` = 全動員 = b）。
3. **`NeedOracle.need_keep(state,t,"food",lv) + NeedOracle.demand(state,t,"food",lv)`** 值 vs `famine_days` → 食物 need 餓時該升卻 = 0?（= a 直證：food need **不隨飢餓升** = need-oracle famine-blind）。

## ★分辨邏輯 + 誠實
- **可能 mixed**（某團 a、某團 b）→ **逐團報、別 aggregate 掩蓋**（哪幾團 a、哪幾團 b、比例）。
- **對照 team47**（從不硬零）同 dump → 看正常態 labor_alloc 長怎樣（food workstation 拿多少 share、food need 多少）。
- 若 (a)：再看 food need 為何 0（need_keep/demand 公式讀啥 state、飢餓為何沒進 need）——但這層若太深可留再下票，先定 a/b 大類。

## 紀律
官方 `SpecimenDumpHelper` 勿手設 `specimen_team_ids`（observer-neutrality [[feedback_observer_no_global_rng]]）。**先讀既有 `gather_factor_trace_samples`**（161 筆）看夠不夠、不足才補「全 labor_alloc 字典 + NeedOracle food need」新 tap。
output → systems 收口（a/b 定案或 mixed 佔比）→ blueprint 攤全桌帶用戶裁 arc。地基 KEEP。
