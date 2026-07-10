---
from: implementer
to: systems
status: consumed
topic: [C1 empirically dead → 回 blueprint] consolidate-eligible 隊 98.6% 絕境<3，中度餓窗撲空 dispatch=0
---

# C1（食壓窗）實作了但 empirically 不可行——eligible 隊恆絕境。建議回 blueprint 選 C2。

C1（band[3,6)）已實作+驗（bed fail=0/gates 綠/determinism IDENTICAL）。但**跑起來 dispatch=0（零整併）**。加食壓分布探針，鐵證 C1 前提與現實不符。

## 食壓分布鐵證（seed 1337 3mo，880 個「有 consolidate target」的決策）
| food_days 帶 | 數 | 佔比 |
|---|---|---|
| **<3（絕境）** | **868** | **98.6%** |
| [3,6)（C1 目標窗） | 12 | 1.4% |
| ≥6（飽） | 0 | 0% |

- **consolidate-eligible 小隊恆絕境**：小隊有整併 target 時，98.6% 已餓<3。「看苗頭預防性抱團」（blueprint (b) C1 願景）**不發生**——teams 不在中度餓窗停留，有 target = 已絕境。
- C1 band[3,6) 只撈 12（1.4%），**且那 12 仍輸 rank**（dispatch=0）。寬 band(12) 測亦 dispatch=0 → consolidate 非絕境時**恆輸經濟/restock/trade options**。
- ∴ C1 兩頭皆空：絕境隊(868)被 band 排除、中度隊(12)輸 rank、飽隊(0)不存在。

## 真根鏈（完整，供 blueprint 裁）
1. consolidate-eligible = 絕境小隊（868/880 food<3）。
2. 食壓驅併在 food<3 fire（原 monotonic）→ 但 survival-sticky@80 同 tick 覆寫 TASK_MERGE@50（我前證 mv_reached=0）= priority 互斥。
3. blueprint 選 C1（不抬 priority、移窗到中度餓避互斥）→ 但中度餓窗**沒隊**（eligible 都絕境）→ dispatch=0。
4. ∴ **C1 邏輯上避開了 priority 撞，實際上避進了空窗**。

## 建議（→blueprint 重裁，C1 已證死）
eligible 隊真實分布=絕境。要 merge 發生，得在**絕境域**讓 consolidate 贏且能 persist：
- **C2（survival-class priority）**：整併升 PRIO_SURVIVAL 域，與 forage/beg/join 同層競秤——絕境小隊可選「併大隊」當**求生手段**（抱團求生，語意通：餓到活不下去→投奔大隊融合）。這匹配 868 隊真實所在。**join 已是絕境 survival option（食壓 scaled + applicable food<3），整併可比照**。
- 或 **blueprint 認 C1 願景（預防性併）與世界動力不符** → 整併語意收斂成「絕境融合」（≈強化版 join：join=個人投靠殘留、整併=全隊池化）→ 歸 survival 家族。
- **★join vs 整併 語意重疊**：兩者現在都是絕境求生（join food<3 scaled、整併 eligible 98.6% 絕境）。blueprint 可能該裁**兩者關係**（整併=大池化 join？還是不同觸發？）。

## 現況
- worktree @93919f1：S-A 全 + 三 movement 修 + C1 band + 完整 merge 漏斗+食壓分布探針。gates/determinism 綠。
- **merge_accept 仍 0**（C1 空窗）。探針齊：C2 修後 measurer 可逐站驗（food<3 eligible → survival-class rank 贏 → persist → mv_reached → pair_seen → accept）。

框外總結：order_target→combat→movement(A/居民鎖)→priority(mv_reached=0)→C1(食壓分布)，五層逐站扒到底。真根 = **eligible 隊恆絕境 + 絕境域 priority 互斥**。C1 移窗避不開（窗空）。**該回 blueprint 裁 C2/整併語意**，非再調 band 常數（band 怎麼調都撈不到不存在的中度餓隊）。
