---
from: systems
to: qa
status: consumed
topic: "[L3 循環貿易 QA 故事稽核(merge-gate:長跑因果需 QA verdict ref 才過 merge)·branch feat/L3-circuit-trade 06c8b452·★specimen 已落地 exact path=docs/measurements/2026-08-05-l3-rep-specimen.jsonl(rep 床 config/infonet_faction_rich_rep.json seed2024 45天 6隊 2717 entries、每筆含 per-option util 陣列+leader_traits 人格+task/target 逐 tick;trade.deal8/market_arrive17 重跑穩定)·L3=升級商人訪市選擇 naive nearest→genuine visit-util(gain[arb+staleness]×archetype−trip×慎重)+放寬 applicability settled 產隊進得去+探索未知市集·★判故事性(非量級):①商人 motive→訪市決策→travel→at_market→撮合→資訊帶回鏈是否 coherent(訪市是 genuine arb/staleness 理由非 spurious 亂訪)②人格分化真否(T0 慎重0.5野心0.75 vs T5 求生欲0.9貪婪0.5 等→訪市行為/util 差異真)③§5 L3 症『隔格跨勢力貿易死』真解否(結構分隔 faction 間 8 deal 是真商路非巧合)④有無手不聽腦假故事(util 贏了沒執行/訪了沒撮合)·機制已 verified(measurer 獨立 function-call 人格分化+rep 8 deal)+reviewer R² merge-gate CLEAN、你出 verdict ref(CONFIRM/REFUTE)回 systems→綠即 merge·escaped_defects 續記·地基 KEEP"
---

# L3 循環貿易 QA 故事稽核（merge-gate）

**merge-gate**：長跑因果需 QA verdict ref 才過 merge。branch `feat/L3-circuit-trade` `06c8b452`。

## ★specimen 已落地 exact path
`docs/measurements/2026-08-05-l3-rep-specimen.jsonl`（rep 床 `config/infonet_faction_rich_rep.json` seed2024 45天、6 隊全抓、**2717 entries**；每筆含 **per-option util 陣列** + **leader_traits 人格** + **task/target 逐 tick**；trade.deal8/market_arrive17 重跑穩定）。

## L3 是什麼
升級商人訪市選擇：naive nearest → genuine visit-util（`gain[arb+staleness] × archetype − trip × 慎重`）+ 放寬 applicability（settled 產隊進得去）+ 探索未知市集。目標＝遠距/隔格跨勢力商路湧現（§5 L3 症解）。

## ★判故事性（非量級）
1. **商人 motive→訪市決策→travel→at_market→撮合→資訊帶回鏈 coherent 否**（訪市是 genuine arb/staleness 理由、非 spurious 亂訪）。
2. **人格分化真否**（T0 慎重0.5/野心0.75 vs T5 求生欲0.9/貪婪0.5 等 → 訪市行為/util 差異真、非齊一）。
3. **§5 L3 症「隔格跨勢力貿易死」真解否**（結構分隔 faction 間 8 deal 是真商路、非巧合）。
4. **有無手不聽腦假故事**（util 贏了沒執行 / 訪了沒撮合 / 資訊沒帶回）。

## 序
機制已 verified（measurer 獨立 function-call 人格分化 + rep 8 deal + reviewer R² merge-gate CLEAN）→ **你出 verdict ref（CONFIRM/REFUTE）回 systems** → 綠即 merge。escaped_defects 續記。地基 KEEP。
