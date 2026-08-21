---
from: systems
to: implementer
slice: eta-single-model
tier: full
qa: required
status: open
topic: "[派工·ETA 與真實移動成本合成單一模型(R² CLEAN)·★這是你那張診斷票的【修法票】,接在後面·spec=docs/superpowers/specs/2026-08-21-eta-single-model-HOW.md·核心:eta_ticks 改用與 _move_cost 相同的速度模型與 clamp;⛔明令禁止把 RETURN_ABANDON_ETA_MULT 調大來補(那是用常數 paper over 模型分歧,症狀消失但兩套模型仍不同步,下一個吃 ETA 的消費端照樣被坑)·★R² 親查+我窮盡確認:全站【五套】算『走一格多久』的公式(真實 _move_cost/eta_ticks/pursuit-eta/失聯帳本/founding_timeout);R² 判 3-5 不共享超載那個病根 ⇒【不塞進這刀】,已記 known_issues·★gate 4 雙向判準別漏:stranded 應顯著減少【但不預設歸零】——母隊滅團/真不可達仍該 stranded;若歸零反而要查 T3 是不是變成永不觸發·★gate 6 要留 convoy.eta_vs_actual 比值 tap:讓『兩套模型是否同步』變成可持續觀測的量,不是修完就忘·qa: required(這條會下長跑因果結論)"
---

# 派工：ETA 與真實移動成本合成單一模型（**R² CLEAN**）

**這是你那張診斷票的【修法票】**，接在後面。
**spec**：`docs/superpowers/specs/2026-08-21-eta-single-model-HOW.md`

## 核心
**`eta_ticks` 改用與 `_move_cost` 相同的速度模型與 clamp。**

⛔ **明令禁止**：把 `RETURN_ABANDON_ETA_MULT` **調大來補**。
那是**用常數 paper over 一個模型分歧** —— **症狀會消失，但兩套模型仍然不同步**，
**下一個吃 ETA 的消費端照樣被坑**。

## ★爆炸半徑（R² 親查 ＋ 我窮盡確認，你不用重查）
**全站有【五套】算「走一格多久」的公式**：
`_move_cost`（**真實、唯一權威**）／`eta_ticks`（**本刀修**）／`path_system:236` pursuit-eta／
`faction_ai:5612` 失聯帳本／`subteam_system:12` founding_timeout。

**R² 判 3–5 不共享 convoy 那個「超載驅動 3× 誤差」的病根 ⇒ 不塞進這刀。**
**已記 `known_issues`**（連同「日後方向：逐步讓它們由真實模型導出，不是各自校準」）。

## ★兩個 gate 別漏
- **gate 4 是雙向判準**：`stranded` **應顯著減少**，**但不預設歸零** ——
  **母隊滅團／真不可達仍該 stranded**。**若歸零，反而要查 T3 是不是變成永不觸發。**
- **gate 6**：留 **`convoy.eta_vs_actual`（預估／實走比值）tap** ——
  **讓「兩套模型是否同步」變成可持續觀測的量，不是修完就忘。**

## 附註
- `qa: required`（本刀會下長跑因果結論 ⇒ merge 閘會驗 QA verdict 存在）。
- **`porter164 貨沒交割` 那條不併進來** —— 你本輪**沒有重現**（`deliver=2/settled=2/零 bail`），**另一條因果**。
