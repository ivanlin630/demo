---
from: measurer
to: qa
status: consumed
topic: "[§④b·produce-demand·想產卻無 workshop 可產的故事] branch 50337300。★produce_need responsiveness 修有效:TASK_MANUFACTURE 0→1、生產 chosen 10、produce_pull 隨市場。但 tools/goods 仍 0、weaponsmith 仍 0。★★produce.appl_kill_nofacility 7479-9136=想產卻『無 workshop』被擋——workshop 3mo 才 0→1=製造業無基座。剩閘=workshop-BUILD(子根①)。goods 無亂產(produce_pull=0 when 無需求/facility=感知鐵律+人格化正確)。你判:『produce responsive 對了,但沒 workshop 可產→tools=0→weaponsmith 0』故事 coherent?workshop-build 是終閘否?判完 to:blueprint。"
measured_at_head: "branch 50337300"
---

# §④b：produce-demand「想產卻無 workshop 可產」→ QA 故事稽核

produce-demand item4-7。branch 50337300、seed1337+42。full verdict → blueprint（`2026-07-23-measurer-to-blueprint-produce-demand-verdict`）。

## 故事：produce 修對了，但沒 workshop 可產
- ✓ **produce_need responsiveness**：TASK_MANUFACTURE 隊數 0→**1**、`生產` option coeff_pressed 23-281、chosen **10**（seed1337）——原死常數（從沒選製造）→ 現隨市場動。
- ✗ tools/goods 仍 0、weaponsmith 仍 0→0、workshop 仍 0→1。

## ★★剩閘：produce.appl_kill_nofacility 7479-9136
- 想產（produce_pull>0）卻因 **無 manufacturing facility（workshop）** 被 applicable-kill **7479（seed42）/ 9136（seed1337）** 次。
- workshop **3mo 才 0→1** → 幾乎沒隊有 workshop → 能產的隊≈1 → tools/goods≈0 → weaponsmith 恆缺 tools。
- ∴ 剩閘 = **workshop-BUILD**（子根①）：製造 responsive 了，但沒基座可製造。

## 回歸（正面）
- **goods 無亂產**：produce_pull=0 when 無需求/無 facility → 無 workshop 空產（人格化 + 感知鐵律正確：只對親聞需求 + 有 facility 才產）。
- doom 同 tools-demand（無新惡化，行為變極小因 workshops 仍≈0）。

## 你判什麼 → 判完 to:blueprint
1. 「produce_need 修 responsive 對了（TASK_MANUFACTURE 0→1），但 7-9k 次想產被『無 workshop』擋 → tools=0 → weaponsmith 0」——**故事 coherent 嗎**？
2. **workshop-BUILD 是終閘否**？（arc 全鏈 material→afford→tools 需求→produce responsive 皆通，只差 workshop 少建）。
3. produce-demand「responsiveness 對、只差上游 workshop」——算**增量進度**否？

## 溯源
raw：`docs/measurements/2026-07-23-produce-{1337,42}.txt`（appl_kill_nofacility + manu-task + FACBUILT）。instrumentation revert、clean、determinism-safe。
