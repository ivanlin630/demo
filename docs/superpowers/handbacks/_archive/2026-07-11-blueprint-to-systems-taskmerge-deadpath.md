---
from: blueprint
to: systems
status: consumed
topic: [S-A merge-blocker] TASK_MERGE 0/8333 結構never-fire——診斷通則查_try_merge可達性洞;整隊合併=有機政體核心不可缺
---

# 呈報 systems：整併 TASK_MERGE 死碼 = S-A merge-blocker

18-seed 大窗（`final18-result`，已 consumed）：gate#1 餵養真解 PASS（19例真救人）、gate#3 PASS。**但爆結構事實**。

## 結構發現（18 seed 證實非噪音）
- `TASK_MERGE`（整併＝吸收整隊）路 **0/8333 dispatch，一次都沒 accept**。
- 19 成交**全走 solo-join（個人投靠），無一整隊合併**。
- dispatch→accept=0.228%：8333 次派只換 19 solo-join，**整併整支＝能 dispatch 不能 accept 的死碼**。

## 診斷通則（行為從不 fire → 查可達性洞，非 tune）
「整併從不觸發」= 典型結構閘/可達性洞（同型病本 session 第 N 次：殲滅 int-truncate、pursuit truncate…能跑不能成）。**第一件事查**：為何 `_try_merge` 接觸路 8333 次沒一次成立？
- **非** `_find_absorber` 餵養閘問題（那是 accept 後的事，且 solo-join 走得通證餵養閘 OK）。
- **是更前面**：兩隊「何時真正接觸到能 call `_try_merge`」這條路徑。查是否有 proximity gate（d<=1 才觸？隊移動追不上?）、硬條件、或 dispatch 目標與 try_merge 觸發點錯位（派去了但到不了/到了不觸）。
- 找到 = de-patch（讓整併真可達），非加補償或調參湊。

## 為何這是 merge-blocker（不 ship 現狀）
1. **有機政體核心＝整隊合併**：S-A 重定目標「食壓驅併=有機政體/勢力聚合」，個人投靠 ≠ 隊聚合。整隊合併結構性 0 → 重定目標只交付一半（solo-join），核心（隊變少變大、政體聚合）**完全沒發生**。
2. **churn 成本換死路**：8333 dispatch（consolidation 慢 2倍主因）換 0 整隊合併=帶算力成本的死碼。ship=為死路付 perf。
3. ∴ **S-A merge 前必須**：要嘛修好 `_try_merge` 可達性（交付真整隊合併），要嘛若查明整隊合併在此世界態本不該常發生，則**明確 gate 掉整併 dispatch**（省 churn）+ S-A 誠實縮為「solo-join 食壓化」。二選一由 characterize 結果定。

## 待 systems
- characterize `_try_merge` 接觸路可達性洞（file:line，為何 8333 次 0 成立）。
- 回報是「可修的可達性 bug」還是「結構上整隊合併本罕/該罕」——**這決定 WHAT**：若前者→修；若後者→回 blueprint 我裁 S-A 是否縮為 solo-join-only + gate 掉整併 churn。
- gate#1/#3 solo-join 那半有效，不動；只查整併死路。

merge hold 到整併可達性有結論。characterize 回 blueprint。
