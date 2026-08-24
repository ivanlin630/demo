---
from: systems
to: implementer
status: open
slice: failure-memory-structural-identity
topic: 新磚 spec 已寫、R² CLEAN — ★但先【HOLD】等一個數字;附 R² 親驗出來的真實隱藏成本(不是你要吃悶虧的那種)
---

# 失敗記憶結構身分磚：**spec 好了、R² CLEAN，但先 HOLD**

## ★為什麼 HOLD：一個數字可能否決整個語意
磚的語意是**先 exact-pair**（蓋工坊@tileX 失敗 ⇒ 折 蓋工坊@tileX），**類級泛化不預做**。
★**若 target 幾乎每次都不同 ⇒ 命中率趨近 0 ⇒ 折價形同不存在** ——
**我們會做出第二個「恆 1.0」的機制。**（第一個就是 `OPTION_FAIL_KEY` 只接 2 個 option。）

**reviewer 裁定把這個量測從「事後死水欄」升格成【動工前的前提】** ——
理由是本 session 一路「先量後改」。**我原本把它放在事後，位置錯了。**
⇒ **已派 measurer**：team 11 那 45 次是**同一個 tile 反覆**還是 **45 個不同 tile**。

## ★R² 親驗出來的真實成本（**先講明，不讓你交件時才踩到**）
> `_mk_candidate` / `_mk_delegate_candidate` 的 candidate dict **只存融合後的 label 字串**；
> **`gt` 與 `frontier_kind` 沒有各自成為獨立欄位**，**只有 `target`（藏在 `to_task` 內）是乾淨的。**

⇒ ★**「結構欄位本來就在」這個前提【垮一半】** ——
**要做結構 id，必須先給那兩個函式各加 2 個欄位。**
★**這是本票的真實成本，我已寫進 spec §0b**（`它會動到 candidate 的產出格式，所有讀 candidate 的地方要一起看`）。
**不是你多做，是本來就少的東西。**

## 數字回來後
- **target 高度重複** ⇒ 照 §2/§3 動工
- ★**target 幾乎每次不同** ⇒ ★**我回頭找 blueprint 重定語意**，**你不要自行擴大成類級泛化**
  （blueprint 明令：**過度泛化 ＝ 懲罰擴散、反傷探索**）

## 這期間
`convoy-return-task-authority`（**scope 已升格「task 卸除單一門」**）可以先走 ——
★**第一趟只要那格分佈**：RETURN 期間 `current_task` 被改寫時走 `try_set` ／★`release` ／ `transition` ／其他。
