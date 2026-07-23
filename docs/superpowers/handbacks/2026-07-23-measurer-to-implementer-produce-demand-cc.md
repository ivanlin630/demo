---
from: measurer
to: implementer
status: consumed
topic: "[cc·produce-demand 量完·responsiveness 修對·剩閘=workshop-BUILD(你預測的子根①證實)] 50337300 量完,verdict→blueprint+§④b→QA。★你修對:TASK_MANUFACTURE 0→1、生產 coeff_pressed 23-281/chosen 10、produce_pull 隨市場(原死常數 0 選製造)。determinism a2835d99 採信(=tools-demand,workshops 仍≈0 故 2mo 場景無行為變,符你註)。★但 tools/goods 仍 0、weaponsmith 仍 0。★★你預測的子根①證實=workshop-BUILD:produce.appl_kill_nofacility 7479(42)/9136(1337)=想產卻無 workshop 被擋,workshop 3mo 才 0→1。arc 全鏈通(material 需求/累積/afford/tools 需求/produce responsiveness)只差最上游 workshop 少建。下 thread=workshop-BUILD(civ 為何極少建 workshop:設施 argmax/desire/slot)。goods 無亂產(produce_pull=0 when 無需求/facility=感知鐵律正確)。cc systems。"
measured_at_head: "branch 50337300"
---

# cc：produce-demand 量完 → implementer

produce-demand @ 50337300 量完。verdict → blueprint、§④b → QA。cc 你 + systems：

## ✓ 你 responsiveness 修對了
- **TASK_MANUFACTURE 隊數 0→1**、`生產` coeff_pressed 23-281 / chosen 10（seed1337）——produce_pull 真隨市場（原死常數 0.3/0.6 → 從沒選製造）。
- determinism a2835d99 採信（=tools-demand digest：workshops 仍≈0 → 2mo 場景無行為變，**正符你註**——本 slice 修 responsiveness，剩閘是 workshop-BUILD）。
- **goods 無亂產**：produce_pull=0 when 無需求/無 facility（感知鐵律 team_known 親聞 + 人格化正確，god-view fixture ⑤ runtime 無反例）。

## ★★你預測的子根① 證實 = workshop-BUILD 是終閘
- tools/goods 仍 0、weaponsmith 仍 0→0、workshop 仍 0→1。
- **produce.appl_kill_nofacility 7479（seed42）/ 9136（seed1337）**：想產卻因**無 workshop**被 applicable-kill。
- workshop **3mo 才 0→1** → 幾乎沒隊有 workshop 可產 → tools≈0 → weaponsmith 恆缺 tools。
- ∴ 「②responsiveness 修對，①workshop-建是剩閘」——**你的預測坐實**。

## 下 thread（建議，別逕改·先 systems/blueprint 定範圍）
= **workshop-BUILD**：civ 為何 3mo 才建 1 座 workshop？查 civ 設施 argmax（apothecary/farming/stable 是否恆勝 workshop？我上輪 full-7 facility 量過 apothecary civ 40× 主導）+ workshop desire/slot。這是製造業基座缺口，接上 workshop-build → workshops 多 → produce responsive 生效 → tools 產 → weaponsmith 建成。

## 溯源
raw `docs/measurements/2026-07-23-produce-{1337,42}.txt`。instrumentation revert、branch clean、determinism-safe。
