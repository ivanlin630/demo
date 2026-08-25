---
from: measurer
to: systems
status: consumed
topic: "popcap-hypothesis-verdict"
---

# population天花板假說：REFUTED（(b)繁殖瓶頸而非(a)領導帽飽和）

`.measure.json`落地：`docs/process/verdicts/popcap-hypothesis.measure.json`

## 快照坐實：假說不成立

peaceful_economy seed1337 day20，11個PRODUCE隊快照：**leadership(統領)全部=0.600**（不是你猜的0.08-0.10）→ `effective_pop_cap`算出**76-99**，population卻卡在**3-6**——**AT_CAP比例=0.0%**，population遠遠低於cap，完全不是天花板飽和。

**判定=(b)：population<<cap，瓶頸在繁殖/成人化速率，不在領導帽**。

## warring_states：誠實測不到，不影響判定

嘗試day20/25/30(timeout)/35，**到day35都還沒有任何隊擁有TAG_PRODUCE**（尚未settle成生產隊）——跟§4b輪(較早commit)day25就有produce_n=2不同，可能是EWMA解耦改變世界動力學後settle時程delay，未進一步追查（超出cheap-snapshot範圍）。**如實標記N/A，不影響已經很清楚的peaceful_economy判定**（單一場景乾淨反駁假說已足夠，不需要靠warring_states平衡）。

## 建議下一步方向（非本輪範圍）

真根該往`population_system.gd`的`MATURE_RATE`(=0.1，每月10% minor→成人)或minor_population補充機制去查——是否有新minor持續產生，還是minor池本身也卡住。這是具體查證方向，交你/blueprint判斷要不要開下一輪。

## 附帶觀察

peaceful_economy這個config裡所有leader統領技能完全一致=0.600（非隨機），可能是標準化測試fixture特性非隨機代表樣本——若要看『典型』統領分布，需要有隨機leader生成的場景，但這次warring_states沒能取得PRODUCE隊數據來對照。

## cleanup

純觀測，未碰production code，temp bed已刪，無需revert。

## 交你裁

假說REFUTED，交你判斷這是否已足以回答blueprint的具名科目優先序裁定，還是需要我接著查MATURE_RATE/minor補充機制。地基KEEP，接著回EWMA trace（queue #2）。
