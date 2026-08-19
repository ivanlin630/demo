---
from: systems
to: measurer
status: open
topic: "[★用戶 priority 改判:效能=目前最大問題→perf 線索包五路(★純量測禁優化、與 §4 平行)·序①②先(歸因最值錢)→③④⑤·baseline=現 main(settlement arc 全落地+churn-fix+labor-v2)·①phase 細 profile on 現 main:FaiPhase markers 補新相位(L0 階梯檢查/farm 生產線/labor rebalance/construction tick)→+34% 單價花在哪、短窗跑法(3-7 天、上次成功經驗)·②★★slice 歸因 bisect(最值錢、精確歸因非猜):同床同 seed 跑三個歷史 commit→per-team ms 逐點:pre-L0 main(S2a 前)/post-S2b/現 main→哪個 slice 加多少單價;★建議 commit 錨(你可自選更準的):S1 merged 94e2f826(pre-L0)、S2b merged 3d30b3ed(post-S2b)、現 main;★同床同 seed 同窗才可比、per-team 正規化要標團數·③scaling 曲線:per-team 成本 vs 團數多點擬合(既有點 242→793ms/152→670ms 再補 2-3 點)→分解 O(N) vs O(N²) 成分=預測大世界/12mo 撞不撞牆·④重申 CPU 份額 quantify(known_issues(a) 的 cheap-win candidate):in-flight JOIN 每 cadence 重申(re-rank+re-set 同 target+print)的成本佔比·⑤alloc 普查:per-tick per-site 新實例創建計數(刀A=_hex_dist static 已證真根家族、找殘餘 alloc 熱點)·★output=hotspot 地圖:每項標【byte-identical-safe 與否】(=憲章兩道分類:安全道 cache/memo/static/減 alloc vs 行為影響道 降頻/deferred)+量級排序→blueprint 帶用戶裁開哪些刀(含要不要進 LOD/行為道)·★★純量測禁優化(這輪不改 production 邏輯;temp instrumentation 用完 revert)·★觀測禁耗 global RNG+禁污染 Probe(invariants §83、markers 須 _begin/_end_observe 或等價)·★wrapper timeout-kill race 已修 d18ff8fc=長跑 stdout 不再失憶·★另排隊(perf 之後、非現在):QA 判 labor-v2 accepted cost 分解=REVISE 需 specimen(死亡前 10-15 天瞬時 daily_rate 軌跡[非 EMA]+3-5 起 chronic/near-zero 的決策資源軌跡)→我等你 perf ①②回報後再正式派·出 .measure.json 落地 path·地基KEEP"
---

# ★perf 線索包五路（用戶 priority 改判：效能=目前最大問題）

**★純量測禁優化**、與 §4 平行。**序：①② 先（歸因最值錢）→ ③④⑤**。baseline=**現 main**（settlement arc 全落地 + churn-fix + labor-v2）。

1. **①phase 細 profile on 現 main**：FaiPhase markers **補新相位**（L0 階梯檢查 / farm 生產線 / labor rebalance / construction tick）→ **+34% 單價花在哪**。短窗跑法（3-7 天、上次成功經驗）。
2. **②★★slice 歸因 bisect（最值錢、精確歸因非猜「三 slice 疊加」）**：**同床同 seed** 跑三個歷史 commit → per-team ms 逐點：**pre-L0 main / post-S2b / 現 main**。★建議錨（你可自選更準的）：S1 merged `94e2f826`（pre-L0）、S2b merged `3d30b3ed`（post-S2b）、現 main。**★同床同 seed 同窗才可比、per-team 正規化要標團數**。
3. **③scaling 曲線**：per-team 成本 vs 團數多點擬合（既有點 242→793ms / 152→670ms 再補 2-3 點）→ **分解 O(N) vs O(N²)** = 預測大世界/12mo 撞不撞牆。
4. **④重申 CPU 份額 quantify**（known_issues(a) cheap-win candidate）：**in-flight JOIN 每 cadence 重申**（re-rank + re-set 同 target + print）的成本佔比。
5. **⑤alloc 普查**：per-tick per-site 新實例創建計數（刀A `_hex_dist` static=已證真根家族、找**殘餘 alloc 熱點**）。

**★output=hotspot 地圖**：每項標 **byte-identical-safe 與否**（憲章兩道：安全道 cache/memo/static/減 alloc vs 行為影響道 降頻/deferred）+ **量級排序** → blueprint 帶用戶裁開哪些刀（含要不要進 LOD/行為道）。

**★★純量測禁優化**（不改 production 邏輯、temp instrumentation 用完 revert）。**★觀測禁耗 global RNG + 禁污染 Probe**（invariants §83、markers 須 `_begin/_end_observe` 或等價）。★wrapper race 已修 `d18ff8fc`=長跑 stdout 不再失憶。

**★另排隊（perf 之後、非現在）**：QA 判 labor-v2 accepted cost 分解=**REVISE 需 specimen**（死亡前 10-15 天**瞬時 `daily_rate`** 軌跡[非 EMA] + 3-5 起 chronic / near-zero 的**決策+資源**軌跡）→ 我等你 perf ①②回報後再正式派。

出 `.measure.json` 落地 path。地基 KEEP。
