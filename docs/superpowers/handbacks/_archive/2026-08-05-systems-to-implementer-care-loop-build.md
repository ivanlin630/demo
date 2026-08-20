---
from: systems
to: implementer
status: consumed
topic: "[dispatch build 領主主動照護 loop(R² CLEAN+2必查項已決斷入 spec、新 slice feat/lord-care-loop off 更新後 main[含 ledger+cohesion merge])·spec docs/superpowers/specs/2026-08-05-lord-care-loop-HOW.md·wiring arc 三塊全接既有件·四塊:①ledger holding 條目(第4 kind、領主對自家村持久監看)②理不理=領主人格秤(_pick_contact_reaction 家族 care/ignore competing util 責任仁慈 vs 野心疏忽、禁 if/elif 零死常數)③scout reuse+(a)firsthand 觀察 write④觀察 belief→distribute mini-util reuse·★★必查項①決斷(reviewer)=改 _step_contact_ledger holding kind 特殊處理 refresh-and-keep:現迴圈(:4697-4719)逾時→resolved=true+不進 kept=永久丟(一次性 unit 對)、★holding 例外=逾時 fire care 反應後不 set resolved、refresh dispatched_tick=current+放回 kept(持久監看續留)、非 lazy 補建·★★必查項②決斷(最高風險 god-view 覆轍防線)=firsthand 觀察 write 必須 INLINE 在 _tick_info_scout 既有 if scout.tile_pos==target.tile_pos co-location 分支『裡面』、禁抽外部/獨立可呼叫函式(若抽 helper 只能此分支內呼)——讀資料(村 food/pop)跟 distribute-descan 修掉的 _resident_food_runway god-view 幾乎一樣、差別只 co-location gate、分支外讀=違憲換包裝復刻剛修好的違規·守:零 god-view(holding 逾時自我記憶/firsthand co-location 物理在場/distress belief 帶時戳非全知)/零死常數(人格秤非逾時 X 必派)/真成本(scout 佔人力+走路延遲)/程度界線(非保姆國家:無天眼/無自動補滿/結果分化)/determinism byte-identical/constitution 74·TDD:holding 逾時偵測/理不理人格分化/★(a)firsthand 傲村不 post 也讀出缺口/觀察→賑濟端到端/零 god-view 硬驗/determinism·完成 handback to:systems R²(★merge-gate 逐行核對 firsthand 呼叫點鎖 co-location 分支內)+measurer 量 cohesion①natural 真考(moderate ex-ante 床責任 lord 村留人/疏忽村叛離)→QA→merge·地基 KEEP"
---

# dispatch build 領主主動照護 loop（R² CLEAN + 2 必查項已決斷）

新 slice `feat/lord-care-loop` off 更新後 main（含 ledger+cohesion merge）。spec：`2026-08-05-lord-care-loop-HOW.md`。wiring arc 三塊全接既有件。

## 四塊
- ①**ledger holding 條目**（第 4 kind、領主對自家村持久監看）。
- ②**理不理=領主人格秤**（`_pick_contact_reaction` 家族 care/ignore competing util：責任/仁慈 vs 野心/疏忽、**禁 if/elif、零死常數**）。
- ③**scout reuse +（a）firsthand 觀察 write**。
- ④**觀察 belief→distribute mini-util**（reuse）。

## ★★必查項①決斷（reviewer）＝改 `_step_contact_ledger` holding kind refresh-and-keep
現迴圈（`:4697-4719`）逾時→`resolved=true`+不進 kept=永久丟（一次性 unit **正確**）。**★holding 例外**：逾時 fire care 反應後**不 set resolved**、**refresh** `dispatched_tick=current`+**放回 kept**（持久監看續留）。**非 lazy 補建**（每 tick 重造雜訊）。

## ★★必查項②決斷（最高風險＝god-view 覆轍防線）
firsthand 觀察 write **必須 INLINE 在 `_tick_info_scout` 既有 `if scout.tile_pos==target.tile_pos`（co-location）分支『裡面』**、**禁抽外部/獨立可呼叫函式**（若抽 helper、只能此分支內呼）。理由：讀資料（村 food/pop）跟 distribute-descan 修掉的 `_resident_food_runway` god-view **幾乎一樣、差別只 co-location gate**——分支外讀=違憲換包裝復刻剛修好的違規。

## 守 + TDD
- 零 god-view（holding 逾時自我記憶 / firsthand co-location 物理在場 / distress belief 帶時戳非全知）/ 零死常數（人格秤非逾時 X 必派）/ 真成本（scout 佔人力+走路延遲）/ 程度界線（非保姆國家：無天眼/無自動補滿/結果分化）/ determinism byte-identical / constitution 74。
- **TDD**：①holding 逾時偵測②理不理人格分化（care/ignore competing argmax）③★(a) firsthand **傲村不 post 也讀出缺口**④觀察→賑濟端到端⑤★零 god-view 硬驗（firsthand 讀鎖 co-location）⑥determinism。
- 完成 → handback `to:systems`（R²、**★merge-gate 逐行核對 firsthand 呼叫點鎖 co-location 分支內**）+ measurer 量 **cohesion ①natural 真考**（moderate ex-ante 床：責任 lord 村留人/疏忽村叛離）→ QA → merge。地基 KEEP。
