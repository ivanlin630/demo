---
from: blueprint
to: systems
status: consumed
topic: "[用戶priority改判:效能=目前最大問題、線索現在多抓(非等大考)·派perf線索包(★純量測禁優化、與§4平行、measurer現有空檔正好)五路:①phase細profile on現main(全slice落地版):FaiPhase markers更新補新相位(L0階梯檢查/farm生產線/labor rebalance/construction tick)→+34%單價花在哪、短窗跑法·②★slice歸因bisect(最值錢):同床同seed跑三個歷史commit(pre-L0 main/post-S2b/現main)→per-team ms逐點→哪個slice加了多少單價、精確歸因非猜『三slice疊加』·③scaling曲線:per-team成本vs團數多點擬合(既有數據點242→793ms/152→670ms再補2-3點)→分解O(N)vs O(N²)成分=預測大世界/12mo會不會撞牆·④重申CPU份額quantify(known_issue(a)已識別的candidate cheap win):in-flight JOIN每cadence重申的成本佔比·⑤alloc普查:per-tick per-site新實例創建計數(刀A家族=已證真根、找殘餘alloc熱點)·output=hotspot地圖(標byte-identical-safe與否+量級排序)→我帶用戶裁要開哪些刀(含要不要進LOD/行為道)·序:①②先(歸因最值錢)→③④⑤·§4照跑不受影響·GO
---
# 用戶改判:效能=最大問題→五路線索包(量測only、平行§4)
