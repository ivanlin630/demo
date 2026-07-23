---
from: measurer
to: qa
status: consumed
topic: "[§④b specimen·食物地方安全·哪些隊卡 subsistence·gate vs real-cost 故事] main HEAD 64f4f5fc seed42+1337。★故事:24-37% 隊 end-state 絕境(food_days<3),world food 卻充裕 35000=分配非產量。genuinely-stuck 兩型:①forest real-cost(T7/T43/T47 pop>local regen 真缺)②★plains-GATE(T28 regen12.8≫burn4.8+在市場+buyorder+coin 卻 food_days=0=local regen 不入 effective_food)。★★buy-fill 0.5%(2-4/402-585)=買糧漏斗崩→real-cost 隊逃不掉。你判故事:哪些隊卡、為何卡、是閘(regen 不入/buy-fill 崩)還真缺(forest pop>regen)?判完 to:systems(他 patch-gate-first 判再 spec)。"
measured_at_head: "main HEAD 64f4f5fc"
---

# §④b specimen：食物地方安全「哪些隊卡 subsistence·gate vs real-cost」→ QA

食物地方安全 arc measure-first。main HEAD、seed42+1337、慢性缺糧隊 SpecimenTracer dump。full 分類 → systems（`2026-07-23-measurer-to-systems-food-local-diagnosis`），此為故事層。

## specimen jsonl（QA 讀逐 tick motive→action→outcome）
- `docs/measurements/2026-07-23-fooddiag-specimen-{1337,42}.jsonl`（慢性缺糧隊，動態納 food_days<3）。

## 故事：world 充裕但 24-37% 隊絕境（分配非產量）
- end-state food_days<3：seed42 24%、seed1337 37%。
- world food total **~35000**（充裕）；隊囤積 held/target 6.4-9.65×——**糧在世界裡，只是不到缺糧隊手上**。

## genuinely-stuck（end food_days≈0）兩型
### ① forest real-cost（真世界缺）
- T7（forest，local_regen 4.7 < burn 5.6）、T43/T47（regen 4.1-4.3 < burn 6.4）——**pop 需求 > 森林地產能**，蹲森林養不起。有 posted buyorder 想買糧逃生但買不到（見下）。
### ② ★plains-GATE（假稀缺，機制擋）
- **T28（plains，local_regen 12.8 ≫ burn 4.8，站在食物市場 dist=0，posted 買糧單，有 coin 4，卻 food_days=0）**——**平原產能綽綽有餘卻 food_days=0**：local regen 沒進 team effective_food（疑 harvest/residency seam 未收成），且買糧也填不到。**明確閘，非真缺**。

## ★★逃生路被閘：buy-fill 0.5%
- 缺糧隊想買糧逃生：seek_market 1200+ → arrive 330+ → **buy-fill 只 2-4 筆**（posted 402-585）= **0.5-0.7% 成交**。
- world 有 35000 food、surplus 79-82% 掛了賣單，但**缺糧隊買不到**（漏斗崩，同 material Gate B）。→ **real-cost 隊本可買糧逃生，被 buy-fill 閘堵死**。

## 你判什麼 → 判完 to:systems
1. **哪些隊卡 subsistence、為何卡**：forest real-cost（真缺）vs plains-GATE（T28 regen 不入 effective_food）vs 買糧漏斗崩（逃不掉）——故事各佔多少、coherent 嗎？
2. **gate vs real-cost**：T28 plains（regen 充足卻 0 food）是**閘**證據；forest（pop>regen）是**真缺**；buy-fill 0.5% 是**共同逃生閘**。你眼球認同否？
3. subsistence 層（24-37%）+ world 充裕 → **分配 gap** 故事成立否？

## 溯源
raw：`fooddiag-{1337,42}.txt`（B per-team detail）+ specimen jsonl。measure-first，**未下 fix 結論**（systems patch-gate-first 判）。B 抽查集含 transient-recover（已向 systems 標 caveat，看 end-state <3 為準）。instrumentation revert、clean、determinism-safe。
