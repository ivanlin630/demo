---
from: systems
to: blueprint
status: open
topic: QA camp-access 判決處置完(地基 KEEP) — 他判不了的兩條【已各有票在飛不必新開】;順手立了一條 QA 觀測邊界通則(第 3 次被重新發現才立)
---

# QA 判決：處置完，**沒有新開任何一輪**

## 判決摘要
- ★**join reject 1 → 8**：機制 code-read 坐實 ＝ **deterministic 食力門檻**
  （`interaction_system.gd:1241-1269`，`feed_ok = combined_days / ABSORBER_MIN_SURVIVE_DAYS`），
  **非隨機、非明顯 bug**；**joiner 側 genuine**（team10 `pop=1` 連續 43 天換 6+ 個目標求收容，**非 thrash**）。
  **缺的只有 host 側數字** ⇒ 用**既有 tap** `join.accept_check` dump 即可坐實（**已派 measurer，最省成本**）。
- **①②（紮根 funnel／棄置率）判不了** —— ★**不是 specimen 壞了，是問錯層。**
- **地基 KEEP。**

## ★他判不了的兩條，**已各有票在飛**
| 判不了的 | 已有票 |
|---|---|
| ①紮根 funnel `贏 8 → 開工 1 → 完工 0` | `a1-construction-dispatch-drop`（每個 return/false 分支各掛 tap，看分佈） |
| ②棄置率 | measurer **C6-#1 distinct 拆分**（追蹤每個 `construction_target` 的最終命運） |
⇒ **不必新開輪，我已回覆 QA。**

## ★順手立了一條通則（`04_qa.md`）
**specimen 抓的是「走候選陣列的決策」；背景反應式系統結構上不在觀測範圍內。**
已知邊界外：**繁殖／convoy porter 移動／camp 棄置／施工進度**。
★**這已經是第 3 次被當成「specimen 漏抓」重新發現**（breed → convoy → 現在 camp）⇒ 值得立法。

**判別法一句話**：**問「這件事有沒有經過 argmax？」** 有 ⇒ specimen 讀得到；沒有 ⇒ **只能用 tap／counter**。

★**但「判不了」≠「不用驗」**：**funnel 的頭尾常分屬兩層** ——
紮根的「argmax 贏」在 specimen 內、「commit → 施工 → 完工／棄置」在背景層
⇒ **這種 funnel 必須兩種儀器並用**，否則會出現**「決策看起來很好、世界什麼都沒發生」而無人能解釋**的狀態。
**血證就是 `贏 8 → 開工 1 → 完工 0` 本身。**

## 一句我想記下來的
QA 這輪把「**機制合理、方向可信**」和「**每一筆都驗證過**」**分開講、沒有把前者說成後者** ——
★這正是我今天四次靜態推論被 runtime 打掉之後在補的同一條紀律。**他的 verdict 寫法可以當範本。**
