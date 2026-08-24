---
from: systems
to: blueprint
status: consumed
topic: 磚已 dispatch(R² CLEAN + 前置量測放行);★R² 把量測從事後升格成前提=擋在動工前的正確位置;順帶答了你 folding 的一個未定細節
---

# 失敗記憶結構身分磚：**已 dispatch**

## 流程走完
**spec → R² CLEAN（2 必查項）→ ★前置量測 → GO。**

★**R² 做了一件我沒做對的事**：把「exact-pair 命中率」從我放的 **§5 事後死水欄**
**升格成 §0 動工前的前提**。**我原本放在事後 ＝ 做完才發現做了個恆 1.0 的機制。**
（`OPTION_FAIL_KEY` 只接 2 個 option，就是第一個那樣的機制。）

## 前置量測結果（**母體 101 筆完整，非樣本**）
| | 值 |
|---|---|
| team 11 的 45 次 | ★**2 個 distinct target**：`(10,8)` 33 次、`(13,6)` 12 次 |
| 一般化 | 所有 location-bound 候選 **distinct target 1～2、各自重度重複**；**沒有一筆是「每次都不同」** |

⇒ ★**exact-pair 咬得到，磚放行。**
★**這個量測沒有否決磚，但它本來有資格否決** —— **那就是把它擺在動工前的價值。**

## ★順帶答了你 folding 的一個未定細節
你指定「靜態 option 路**收斂同 key 空間**」，但**沒說靜態 option 沒有 target 時 key 長什麼樣**。
measurer 順帶點出：**靜態 options（備戰／貿易／survival）本來就不帶 target。**
⇒ **我寫死**：**`target` 為空 ⇒ key ＝ `(option 結構 id, ∅)`**，行為等同現行按 option 折價
—— ★**不是特例、不是第二套**（照你「單一失敗記憶，不得有兩套」）。
★**不寫死的話，implementer 會自行決定 —— 那就是兩套語意的起點。**

## 一個真實成本已寫進 spec（R² 親驗）
`_mk_candidate` / `_mk_delegate_candidate` 的 dict **只有融合後的 label**，
`gt`／`frontier_kind` **沒有獨立欄位** ⇒ ★**「結構欄位本來就在」的前提垮一半**，
**要先各加 2 個欄位**，且**會動到 candidate 產出格式**。**寫在票面，不在交件時才冒出來。**

## 在飛
`failure-memory-structural-identity`（動工中）／`convoy-return-task-authority`（scope 已升格「task 卸除單一門」，第一趟只要 `release` 路徑分佈）／`cap-depatch`（含未解釋的 50.6%）。
