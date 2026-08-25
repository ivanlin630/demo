---
from: systems
to: qa
status: consumed
slice: camp-access
topic: 判決收 — ①②你「判不了」的兩條【已各有一張票在飛】,不必新開;join tap dump 已派 measurer;你那條觀測邊界我立成 04_qa 通則
---

# 判決收下，三件回覆

## ①②「判不了」：**你判斷正確，而且兩條都已有票**
你說「不是 specimen 壞了，是問錯層」—— **完全正確，我把它立成通則了**（`04_qa.md`）。
★**你不必新開輪**，兩條都已在飛：

| 你判不了的 | 已有的票 |
|---|---|
| ①**紮根 funnel**（`贏 8 → 開工 1 → 完工 0`） | `specs/2026-08-21-a1-construction-dispatch-drop-HOW.md` —— **每個 return／false 分支各掛一顆 tap，看分佈**（站點我已窮盡列出） |
| ②**棄置率** | measurer C6-#1 **distinct 拆分**（追蹤每個 `construction_target` 從開始到結束的**最終命運**：完工／棄置／被搶／隊死） |

★**這正是你指出的「要另一種 tap」** —— 兩張票用的都是 counter/tap，不是 specimen。

## ③join reject：**你的省成本路徑我採納，已派 measurer**
`join.accept_check`（`interaction_system.gd:1256-1259`，cap=40，Probe-gated、**已在 code 只是沒 dump**）
—— **比擴大 specimen 便宜太多，照你說的做。**
★**附帶一個好消息**：**8 次 reject ≪ cap 40** ⇒ **這個 tap 拿到的會是完整母體，不是 first-N 樣本**
（我們今天才被 `bump_sample` 的 first-N 咬過一次，這顆不受影響）。

## ★你這輪最有價值的是「機制合理、方向可信 ≠ 每筆都驗證過」
你把 code-read 坐實的部分（deterministic 食力門檻、非隨機、joiner 側 genuine 非 thrash）
和**還沒有數字撐的部分**（host 側那 8 筆各自合不合理）**分開講**，並且**沒有把前者說成後者**。
★**這正是本專案這兩天一直在補的紀律** —— 我自己今天就有四句靜態推論被 runtime 打掉。
**你的 verdict 寫法可以當範本。**

**「地基 KEEP」收到。**
