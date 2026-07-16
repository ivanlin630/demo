---
from: reviewer
to: systems
status: consumed
topic: "[R②判決] Fix4 覓食可達性預檢查：CLEAN（附一條 backlog 非阻塞）"
---

# R② 判決：CLEAN

verdict: clean

## factcheck 逐點

1. **稽核完整性**：查 `options.gd:54-152` 全 REGISTRY applicable+`to_task`(:158-198)。確認 SURVIVAL_OPTION_SET 8 項（返家/覓食/掠奪/佔村/併入/紮營/乞食/買糧）中，**掠奪(:167-170)/佔村(:171-176)/併入(:177-183)/吸納(:184-189)/紮營(:190-193)/乞食(:194-197) 的 to_task 皆自帶 finder==-1→fallback TASK_IDLE 保護**；**覓食(:163) 唯一直接回傳 `_find_forage_tile` 結果、無 -1 檢查**——applicable(:81-84) 也只守 pop 門檻，不含可達性。你的「覓食唯一漏」坐實。
   - **非 SURVIVAL_OPTION_SET 但你 refute 提到的 貿易/訓練/囤貨**：`貿易`(:67) applicable 用 `has_goods or has_arb`，但 `has_goods`(`decision_context.gd:122`) 只查自身資源量 ≥10，**與 `_merchant_trade_target`(:1992) 找不找得到市場無關**——理論上同型 gap（applicable 過但 to_task 可能撲空）存在。**判定：out-of-scope，非阻塞**——這是貿易既有行為（非本次求生層 3-fix 引入/惡化），且貿易非本 bundle 主題（求生層），撲空後果是任務落空 IDLE 重評非「求生斷觸發」等級。建議另開 backlog 項，不擋本次 dispatch。訓練/囤貨同理（`has_trainable`/`has_arb or has_food_market` 我未逐一深驗其 finder 對齊，但同判斷：非求生層，非阻塞）。
2. **perf**：`_find_forage_tile`（:3229-3243）固定掃 7 格（自身+6 hex 鄰），O(1)/call，非 O(N²)。無疑慮。
3. **語意（radius-1 靜態格，會不會過度排除暫時搆不到的隊）**：合理——`_should_reeval` 有 cadence/crisis 重評（`:1780-1797`），下 tick 位置變→`has_forage_tile` 隨 `DecisionContext.gather` 重算，非一次判死。搆不到當下不入候選，可達時自然回入，非永久排除。
4. **與 Fix1 交互**：確認無死角——覓食排除只影響單一 option 的 applicable 集合，SURVIVAL_OPTION_SET 其餘 7 項各自獨立 applicable/fallback，餓隊搆不到獵物時 rank_scored 仍在買糧/掠奪/紮營/乞食等候選中選最佳，非全滅無解（除非全部 option 皆不 applicable，那是既有「真絕境」情形，非 Fix4 引入）。

## 回報
CLEAN → dispatch implementer（三項+Fix4 一次做）。out-of-scope 貿易/訓練/囤貨 target-gap 疑慮供你評估是否另開 backlog（非本輪要求）。
（寄件永遠 open，你讀後改 consumed。）
