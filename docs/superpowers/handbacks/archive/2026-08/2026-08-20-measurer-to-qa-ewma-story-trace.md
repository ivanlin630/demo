---
from: measurer
to: qa
status: consumed
topic: "ewma-story-trace"
---

# EWMA解耦後行為面trace：請讀motive→action→outcome故事（大考blocker#4）

`.measure.json`落地：`docs/process/verdicts/ewma-story-trace.measure.json`

## trace落地path（逐隊motive→action→outcome，非只aggregate）

- **warring_states**：`docs/measurements/2026-08-20-ewma-story-trace-warring_states.specimen.jsonl`（6515 entries，15隊代表性取樣，1個月窗seed=1337）
- **peaceful_economy**：`docs/measurements/2026-08-20-ewma-story-trace-peaceful_economy.specimen.jsonl`（1464 entries，同取樣法/seed/窗）

每筆entry含：`想什麼`(candidates全util陣列+beliefs)+`做什麼`(winner_opt/task/target)+`狀態`(pop/food_private/food_granary/effective_food/leader_traits等)。

## 背景（systems要你判斷的問題）

EWMA(食物流訊號)原本每次`gather`呼叫就推進、非冪等，推進次數取決於哪個選項贏＝既存缺陷；現改成只在真決策入口推進、預設不推進→**推進頻率真的降了**，世界動力學可能變了。**重點問題**：
1. **求生/成長切換有沒有變遲鈍**（need_urgency餵consistency_coeff直接乘進option util，推進慢＝urgency反應慢的假說）
2. **饑荒/威脅出現後多久才切到求生**

## 我的粗分析（起點，非結論——請你判斷是否合理）

逐隊解析：`first_low_food_tick`(effective_food首次<日耗×3) vs `first_survival_tick`(task首次落入返家/乞食/覓食/併入/紮營)的gap。結果分布很寬（0.4天~10+天），含多個負gap案例（先進求生再踩到我定的缺糧門檻，可能是威脅驅動非飢餓驅動）。**★誠實揭露：我沒有EWMA-merge前的同gap分布對照，所以無法斷定這個分布本身算不算『變遲鈍』**——只能給你post-EWMA現狀的數字，請你讀trace自己判斷這個延遲(尤其peaceful_economy裡Team8/9/11的7-10天延遲)在故事上合不合理。

## cleanup

純觀測，未碰production code。temp bed+worktree已清理。

## 交你判斷

讀這兩份trace，重點看：①求生切換的觸發時機是否合理（尤其那幾個7-10天延遲案例）②威脅出現到求生反應的因果鏈講不講得通③是否有『decision卡住/util算出來但沒真正切換』的手不聽腦訊號。地基KEEP。
