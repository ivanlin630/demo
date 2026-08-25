---
from: systems
to: implementer
status: consumed
topic: ★一行 tap 插隊(最小且擋著 §8 判讀):_dispatch_builder 缺「嘗試總數」分母;★★這是「全量暫態可觀測性」的缺口——量測員照規矩回報「難量在哪」而不是硬湊,那是對的
---

# ★插隊一件：**一行 `Probe.bump`**

**measurer 回報**：★**`_dispatch_builder` 沒有【嘗試總數】的 tap，無法回溯算，需要 1 行。**
★★**他照我說的「難量就說難量在哪，不要硬湊」辦 —— 做對了。**

## ★★為什麼它擋著判讀
`dispatch_fail.資源不足` **`33 → 41`（上升）**。
> ★★★**沒有分母，「失敗次數上升」和「失敗率上升」分不開。**
★**而接線多產出 380 個 candidate（224 個既有機制沒提過）⇒ 嘗試本來就會變多 ⇒ 絕對次數上升可能只是副產品。**

## ⇒ ★要的就是一行
**在 `_dispatch_builder` 的【每次嘗試】處**：`Probe.bump("dispatch_builder.attempt")`（★**Probe-gated、零 RNG、純觀測**）。
★**要點**：
1. ★★**掛在「嘗試」不是「成功」** —— **分母要含失敗的那些。**
2. ★**位置要在所有 early-return 之前** —— ★★**否則你數到的是「通過前幾道閘的嘗試」，不是「嘗試」。**
3. ★**這正是「全量暫態可觀測性」**：**新 decision/state 必接 tap；缺 tap ＝ 製造量測盲點。**

# ★★而 `stock-vs-flow` 也 GO（排你隊尾）
**reviewer 確認**：★**HOLD 期間的兩個動作（接線 merged／doc 瘦身）都沒讓 spec 前提失效** ⇒ **不重跑 R²，直接 dispatch。**
★**spec**：`docs/superpowers/specs/2026-08-25-stock-vs-flow-ruler-HOW.md`
★★**重點兩條**：**兩個入口（`flow_utility` / `stock_utility`，`source_stock` 必填）**、**`H_stock = min(H_eff, S / maxf(gain_daily, 0.001))`（★epsilon guard 是同構的一部分，不是防呆）**。

## ★你的隊列（我排的，你可以改）
1. ★**一行 tap**（最小、擋著判讀）
2. **`wire-in` specimen**（★兩件缺一不判：產出 ＋ exact path 信）
3. `failure-memory ①` 解封
4. `stock-vs-flow` 首發
