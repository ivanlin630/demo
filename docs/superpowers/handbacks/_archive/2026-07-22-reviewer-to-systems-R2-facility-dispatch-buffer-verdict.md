---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·facility dispatch buffer·issues(premise sharpen+姊妹站)] 方向可(作者 98a0a8f7 已認 dispatch-afford choke point 非神聖 buffer)。但★①「2780 anomaly」framing 不準:×1.5 是 3 站一致 dispatch convention;2637(_dispatch_upgrader)是 2780 姊妹站(同 commit 改、同 vault+private ×1.5)→改只 2780=新不一致(一致化目標自拆台),須連 2637。2551(新據點 strict-private)另案。②1.1 小 buffer 有 fund-transfer 語意支撐(dispatch 資助移動 subteam≠in-place internal),defensible+measure owner-depletion。③次要④無RNG⑤measure 分開 agree。"
---

# R² verdict：facility dispatch afford buffer（×1.5→1.1）

**VERDICT: issues（premise 精準化 + 姊妹站一致）** — 方向可（減 dispatch afford 門檻，作者已認 restrictive），但 spec 的「2780 anomaly」premise 不準 + 改只 2780 造新不一致。`premise_contradiction: false`（但「anomaly」詮釋需修）。factcheck 對 HEAD `0f0a5eca`。

## Root 精準化（spec premise 修正）
- **`_fund_subteam_cost`**（2780 dispatch 後呼）：`ResourceBank.add(owner, -transfer)` = **dispatch 把 cost 轉給 subteam（owner 失資源給移動實體）**。in-place（建自家 tile）資源留 owner 經濟。∴ dispatch vs in-place **有真語意差**（外部資助移動隊 vs 內部建造），非純 anomaly。
- **×1.5 是 3 站一致 dispatch convention**（非 2780-specific anomaly）：`2551`（`_dispatch_builder` 新據點/建國，strict-private）、`2637`（`_dispatch_upgrader` 升級，vault+private）、`2780`（`_dispatch_facility_builder` 擴建，vault+private）。**blame 98a0a8f7 揭：2637+2780 同 commit 一起改（「_dispatch_upgrader/_dispatch_facility_builder 的 1.5x 預檢改吃公庫」）= 姊妹站**；2551 作者刻意「維持私產 gate 嚴格本地」=另案。
- **「承重 buffer」疑 → 減弱**：blame 揭作者**已認 dispatch-afford 是 choke point**（「2 年 75 次 material 不足失敗」），提過降 tax/caravan-load 修——∴ ×1.5 restrictiveness **是已知的、非神聖 load-bearing**。減 defensible。

## 審點逐一
1. **★①一致化理由 → 修正：×1.5 非 2780 anomaly，是 3 站 convention；改只 2780 造新不一致**。spec 目標「與 in-place 一致」，但**改只 2780→2637 姊妹站仍 ×1.5**（升級 dispatch 卡 1.5、擴建 dispatch 降 1.1）=**dispatch-internal 新不一致**（一致化目標自我拆台）。**要求：連 2637（_dispatch_upgrader 姊妹站）一起改** const（兩者同 vault+private facility-dispatch convention）。`2551`（_dispatch_builder 新據點 strict-private，虛擬目標格無公庫）= 作者刻意另案，**分開判**（改不改 = 另 decision，本 slice 可不動）。
2. **②1.1 vs 1.0 → 1.1 defensible**。fund-transfer 語意支撐小 buffer：dispatch **資助移動 subteam**（途中可能死=資源不回，異於 in-place internal）→ owner 別 deplete 到恰 0 保守合理。1.1（10% buffer）>1.0，非 0.5× 大 buffer。**但 0.5×→0.1× 大降 → measure owner-depletion/thrash**（funding 後 owner 枯竭風險）。1.1 值 = measurer/QA 長跑 tune（同意）。
3. **③trade-primary 次要 → agree**。只降 dispatch 門檻；mil 隊仍需**有** material（買才夠=material 貿易流另軌主線）。此項讓「有料隊別被多卡」。別誤當主 fix。
4. **④無 RNG → CLEAN**。const 改。
5. **⑤measure 與 material 貿易流分開 → agree**（別 conflate：此驗「有料隊建得成」，那驗「無料隊買得到」）。

## ★別重蹈「未驗前提調常數」（systems 自警）
- premise「×1.5=anomaly 應 match in-place」= **詮釋斷言**（[[feedback_fileline_vs_interpretation]]）。**原始事實**：×1.5 是 3 站一致 dispatch convention + fund-transfer 有真語意差 + 作者已認 restrictive。→ 修正 premise 為「dispatch-afford 過嚴（作者已認 choke），降 buffer；但保 dispatch>in-place 的小差（fund 移動隊）」，非「anomaly 應消滅一致 in-place」。
- 這樣改 **有 code-fact 支撐**（3 站/fund-transfer/作者 blame 認 choke）+ **1.1 值本身仍 tuning**（measurer/QA 驗），符 systems「前提=code-fact 較穩、值待長跑驗」的自評。

## 回覆
issues（premise 精準 + 姊妹站）→ 方向認可，兩調整：
1. **連 2637（_dispatch_upgrader 姊妹站）一起改 const**（否則 dispatch-internal 新不一致；一致化目標自拆台）。2551（新據點 strict-private）另案分開判。
2. **premise 措辭改**：非「anomaly 消滅→match in-place exact」，是「dispatch-afford 過嚴（作者已認 choke）降 buffer，保 dispatch>in-place 小差（fund 移動隊語意）」。1.1 small buffer defensible。
+ measure owner-depletion（funding 後枯竭 thrash）+ 與 material 貿易流分開。
改好回 R² → dispatch。
