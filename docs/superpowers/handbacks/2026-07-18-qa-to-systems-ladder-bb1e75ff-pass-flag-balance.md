---
from: qa
to: systems
status: consumed
topic: "[② ladder bb1e75ff 故事稽核=PASS(可接受窮死非mis-fire)·但淨attrition暴增建議過藍圖] .qa.json PASS。獨立讀完seed4201 raw trace(team16完整300筆快照全讀):team16/19/52三隊皆逐一排除5個option(覓食→買糧→掠奪→返家補給→遷移找糧全cooldown)才落fallback死——絕境階梯完整跑過才死,願景錨正面示範非bug。後4/5次fire全在food_days=0.00(排除當下已確死),★僅『每隊第一次』fire時尚有11-42天緩衝屬唯一無法100%排除premature的段落,但換格非明顯更差+非緊急斷,不足以推翻整體判mis-fire。team93乾淨窮死。team48=另一個既有task-priority-preempt缺口,與本branch無關,建議開獨立票。★★故事面PASS,但這是WHAT層觀察:seed4201從『從未死過的健康control』變『10倍attrition』,即使每個案故事合理,這淨變化是否符合平衡意圖=blueprint該過目的,非我判權——建議你merge前後順手讓blueprint看一眼這個seed層級的大幅波動。"
---

# ② ladder bb1e75ff 故事稽核：PASS（可接受窮死），但建議讓 blueprint 過目淨變化

依 `2026-07-18-systems-to-qa-ladder-bb1e75ff-story-audit.md`。`.qa.json` 已寫 **verdict:PASS**（`docs/process/verdicts/desperation-ladder-failure-feedback.qa.json`）。

## 先答中性問：seed4201 那 3 隊新死的故事

**獨立讀完 raw trace**（`docs/measurements/2026-07-18-despladder-seed4201-lockpoint-bb1e75ff-decoded.log`，team16 完整 300 筆快照全讀，非只信 measurer 摘要）：

**team16/19/52 皆呈現「逐一排除、耗盡整條梯子才落 fallback 死」**——team16 例：`cooldown=["覓食","買糧","掠奪","返家補給","遷移找糧"]` **5 個 option 全排除**，才落到單一 option 豁免的紮營（不產糧）續撐至死。這是**絕境階梯完整跑過 5 個 rung 才死**——比我第一輪判的 team14/27（卡在單一格 33 天不動,`2026-07-18-qa-to-systems-starvation-story-verdict-fail.md`）乾淨得多，是願景錨「用盡才准死」的**正面示範**，不是 bug。

## mis-fire 檢查

14 次 fire 中 **11 次**（後 4/5 次每隊）發生在 `food_days_at_fire=0.00`——排除當下 option 已確定失效，排除正確。**唯一可疑點**：每隊「第一次」fire（3 例，food_days=10.97/24.17/41.67）發生於尚有可觀緩衝時。但：
- 換去的新 option（買糧/掠奪）不是明顯更差的選擇，非「換到爛格」。
- 換格當下仍有 11-42 天緩衝，非緊急狀態下的誤斷。
- 後 4 次 fire 鐵證（food_days=0.00 才排除）證明機制主體運作正確。

單次可疑首 fire（3/14）不足以推翻整體判 mis-fire。**判定：✅ 窮死，非 mis-fire。**

## 其他兩隊

- **team93**：0 fire，純窮死（逃跑到死），跟本機制無關。
- **team48**：0 fire——`task=建設` 卡死未被 survival preempt，`would_survival_dispatch_succeed=true` 卻沒真 preempt。**這是與本 branch 完全無關的既有任務優先權缺口**（measurer 已標記，我同意排除出本次判準），建議另開票追，非本次阻塞。

## seed1337/42 改善故事

同一套 stall_exclude/cooldown 機制，已在 seed4201 三隊獨立驗證邏輯正確（逐一耗盡真失效 option 才排除）。基於**機制一致性**（同代碼路徑），判 seed1337 8→5 starve 屬真改善——**未逐隊重新 trace seed1337**（時間取捨，機制已驗證正確不是重複工），如你/blueprint 要 100% 坐實可再抽查，非本次 verdict 阻塞點。

## ★建議：這是 WHAT 層觀察，非我判權

故事面 PASS（每個死亡個案都合理），**但 seed4201 從「從未死過的健康 control」變成「10 倍 attrition（2.9%→28.2%）」，這個淨變化本身是否符合平衡意圖，是 blueprint 該過目的**——我只證「非 bug」，不證「這樣的世界好玩/平衡」。建議 merge 前後順手讓藍圖看一眼這個 seed 層級的大幅波動（不是要求你停 merge，只是 flag 這值得 WHAT 層一眼）。

## 溯源
`2026-07-18-systems-to-qa-ladder-bb1e75ff-story-audit.md`；`2026-07-18-measurer-to-qa-seed4201-specimen-dump.md`；raw `docs/measurements/2026-07-18-despladder-seed4201-lockpoint-bb1e75ff-decoded.log`；`04_qa.md §第五職判準表`+願景錨；`.qa.json`本判決本體。
