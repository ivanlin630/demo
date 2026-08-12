---
from: systems
to: measurer
status: open
topic: "[③長期故事驗證 first-pass story-audit(整系統 believability、blueprint 啟、本 session 大量系統 merged 退一步跑長局看敘事合理否)·★measure-first 中性觀察(禁預設、7×over-claim 教訓):跑長局 seeded → 產中性長局敘事+top incoherences ranked、禁預設哪壞·★vehicle:longwindow_bed.gd(LW_MONTHS env、6-12月長窗、月曲線+漏斗、GODOT_TIMEOUT=600 背景跑=你 HOB perf 協議)or WarringHarness.run(1337, N月×TICKS_PER_MONTH)→curve[月快照 teams/factions/established/pop/intent]+probe 子集·建議 LW_MONTHS=12-24(多月~年、seed1337 主+可加 42/8181 交叉看非 seed-artifact)·★觀察 4 維(blueprint WHAT):①勢力興衰 coherent 否(立國/擴張/衰亡/兼併有因果非亂跳、faction timeline 讀 curve established/factions/founding probe)②近期系統長跑互動 believable 否(缺officer→練兵→提拔[promote.fired]→军民動員[mobilize.fraction]→戰爭→勝負→復甦[migrant/invest/relocate] 這些鏈串起來像故事否、逐月 tap 這些 Probe 看有無真串接)③degenerate/absurd(某系統長跑失控/死循環/荒謬:全世界某極端[全動員?全一 intent?]/資源爆炸or歸零/行為刷屏[churn 計數爆]/monotonic collapse[established 恆0?pop 單調掉?])④活世界自己說故事達標否(無玩家也有戲)·★逐月 tap 建議(既有 curve + 近期系統 Probe 子集):promote.fired/train_chosen/mobilize.fraction/guard.ratio/migrant.*/invest.*/relocate.*/defect/uprising/g2.faction_found/collapse+資源總量+intent histogram 隨月變化·★degenerate 硬檢:pop 爆/歸零、某 intent>90%、established 恆定、某 Probe 單月爆量(刷屏)·output=①中性長局敘事(逐月 what happened 故事線)②★top incoherences/absurdities RANKED(硬證 specimen+故事線、最大的幾個非窮舉)③4 維各 verdict·★first-pass surface 非 fix(broad、先抓最大幾個)·★禁預設(established=0 等訊號讓數據說、別假設是 bug=可能 genuine 或可能真根、中性 trace)·specimen 送 QA 佐證·output→systems consolidate top incoherence 清單→blueprint 推用戶排 fix 優先序→逐個 fix arc·地基 KEEP·GODOT_TIMEOUT 拉大背景跑"
---

# ③長期故事驗證 — first-pass story-audit（整系統 believability）

blueprint 啟。本 session 大量系統 merged（資訊網/凝聚力/復甦/框架/派遣/named-scarcity/晉升/军民混编）→ 退一步跑長局看整體敘事合理否。★**measure-first 中性觀察**（禁預設、7×over-claim 教訓）：跑長局 → 產中性長局敘事 + top incoherences ranked、**禁預設哪壞**。

## ★vehicle
- `longwindow_bed.gd`（`LW_MONTHS` env、6-12月長窗、月曲線+漏斗、GODOT_TIMEOUT=600 背景跑=你 HOB perf 協議）**or** `WarringHarness.run(1337, N月×TICKS_PER_MONTH)` → curve[月快照 teams/factions/established/pop/intent] + probe 子集。
- 建議 **LW_MONTHS=12-24**（多月~年）、seed1337 主 + 可加 42/8181 交叉看非 seed-artifact。

## ★觀察 4 維（blueprint WHAT）
1. **勢力興衰 coherent 否**（立國/擴張/衰亡/兼併有因果非亂跳、faction timeline 讀 curve established/factions/founding probe）。
2. **近期系統長跑互動 believable 否**（缺officer→練兵→提拔[promote.fired]→军民動員[mobilize.fraction]→戰爭→勝負→復甦[migrant/invest/relocate] 這些鏈串起來像故事否、逐月 tap 看有無真串接）。
3. **degenerate/absurd**（某系統長跑失控/死循環/荒謬：全世界某極端[全動員？全一 intent？] / 資源爆炸or歸零 / 行為刷屏[churn 計數爆] / monotonic collapse[established 恆0？pop 單調掉？]）。
4. **活世界自己說故事達標否**（無玩家也有戲）。

## ★逐月 tap 建議（既有 curve + 近期系統 Probe 子集）
promote.fired / train_chosen / mobilize.fraction / guard.ratio / migrant.* / invest.* / relocate.* / defect / uprising / g2.faction_found / collapse + 資源總量 + intent histogram 隨月變化。
- **degenerate 硬檢**：pop 爆/歸零、某 intent>90%、established 恆定、某 Probe 單月爆量（刷屏）。

## ★output
1. **中性長局敘事**（逐月 what happened 故事線）。
2. ★**top incoherences/absurdities RANKED**（硬證 specimen + 故事線、最大的幾個非窮舉）。
3. 4 維各 verdict。

★**first-pass surface 非 fix**（broad、先抓最大幾個）。★**禁預設**（established=0 等訊號讓數據說、別假設是 bug=可能 genuine 或可能真根、中性 trace）。specimen 送 QA 佐證。

output → systems consolidate top incoherence 清單 → blueprint 推用戶排 fix 優先序 → 逐個 fix arc。地基 KEEP。GODOT_TIMEOUT 拉大背景跑。
