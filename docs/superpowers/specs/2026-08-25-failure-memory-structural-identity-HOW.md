---
slice: failure-memory-structural-identity
tier: full
qa: required
from: systems
topic: 失敗記憶改用【結構身分 key,零人工表】—— 覆蓋從 2 個 option 變成構造性 100%
---

# 失敗記憶：**結構身分 key**（blueprint 定磚 2026-08-25）

> ★**折價是「這條路我試過、失敗了」的【真實資訊】，不是排序旋鈕。**
> （blueprint 指定寫在開頭；同「排序＝折現值比較的自然輸出、禁新排序常數」的精神。）

## §1 現況（診斷已坐實，`file:line`）
| | 現況 |
|---|---|
| 靜態 option 路 | `decision_engine.gd:76` `u *= FailureMemory.mult_for_option(...)` |
| ★goal candidate 路 | `decision_engine.gd:104` **用生 util 進池，完全不過折價** |
| ★**接線面積** | `OPTION_FAIL_KEY` **只有 2 筆**（買糧／買料）⇒ **其餘 option 恆 1.0** |
| caller | `mult_for_option` production 全樹**只有 1 個** |

⇒ ★**光把 `:104` 接上 `mult_for_option` 沒有用** —— candidate 的 label 不在那兩筆裡，一樣回 1.0。
⇒ ★**手工對照表在這裡註定漏**：candidate label 是**組合出來的**
（`goal_resolver.gd:447` `gt + ":" + frontier_kind`、`deliver_<res>`、`<label>:delegate`）⇒ **label 空間近乎開放。**

## §0 ★★前置量測（**R² 裁：從「事後死水欄」升格為 dispatch 前的前提**）

**要答的一個數字**：★**exact-pair 的命中率會不會趨近 0？**

**具體**：`build_workshop` 那 45 次（team 11），
★**是「同一個 tile 反覆蓋不成」還是「45 個不同 tile 各試一次」？** 併報一般化的 **target 重複率分佈**。

| 結果 | 意義 | 處置 |
|---|---|---|
| **target 高度重複**（同一 tile 反覆） | exact-pair **咬得到** | ✅ 照 §3 做 |
| ★**target 幾乎每次不同** | ★**exact-pair 命中率趨近 0 ⇒ 折價形同不存在** | ★**回頭找 blueprint 重定語意**（類級泛化的門檻），**不得自行擴大** |

★**reviewer 的理由我照收**：這是本 session **一路「先量後改」紀律的同型情境** ——
**我原本把它放在 §5 當事後死水欄，那等於「做完才發現做了個恆 1.0 的機制」。**

### ✅ 答案（measurer 2026-08-25，**母體 101 筆完整、非樣本**）
| | 值 |
|---|---|
| team 11 那 45 次 `build_workshop` | ★**2 個 distinct target**：`(10,8)` **33 次**、`(13,6)` **12 次** |
| 一般化（所有 location-bound 候選：`build_*` / `deliver_material` / `maintain_*`） | ★**distinct target 數 1～2、各自重度重複**；**沒有一筆是「每次都不同 target」** |

⇒ ★★**exact-pair 咬得到。磚放行。**
（**既不是「同一 tile 反覆」也不是「45 個都不同」——是「少數 target 各自重度重複」，
 那正是 exact-pair 最有效的形狀。**）

## §0b ★★真實隱藏成本（**R² 親驗，非我多慮**）

**`_mk_candidate` / `_mk_delegate_candidate` 的 candidate dict【只存融合後的 label 字串】** ——
★**`gt` 與 `frontier_kind` 沒有各自成為獨立欄位**；**只有 `target`（藏在 `to_task` 內）是乾淨的。**

⇒ ★**「結構欄位本來就在」這個前提【垮一半】。**
**要做結構 id，必須先給這兩個函式各加 2 個欄位** ——
★**這是本票的真實成本，寫在這裡，不准在交件時才冒出來。**

**性質**：這是**補齊結構資訊**（把已經隱含在組合字串裡的東西還原成欄位），
**不是新增設計** ⇒ 但**它會動到 candidate 的產出格式**，**所有讀 candidate 的地方要一起看**。

## §2 ★磚：**結構身分 key，零人工表**

**key ＝ `(option 結構 id, target id)`**，★**直接由 dispatch 自帶的結構欄位機械導出** ——
**goal type ／ frontier kind ／ target 本來就在**，**不經 label 字串對照。**

★**覆蓋 ＝ 構造性 100%**：**每個動作天生有身分，無表可漏。**
⇒ **`OPTION_FAIL_KEY` 這張人工表消失**（列管物種見 `00_roles §覆蓋欄`）。

## §3 語意（**blueprint 指定，不得自行擴大**）
- ★**先做 exact-pair**：「**蓋工坊@tileX 失敗** ⇒ 折 **蓋工坊@tileX**」
- ⛔ ★**類級泛化（折所有蓋工坊）【不預做】** ——
  **診斷證明需要才加**。**理由：過度泛化 ＝ 懲罰擴散、反傷探索。**
- **與失敗律既有四項相容**：連續折價／TTL／失效升 T0 **照舊，不動。**

## §3b ★靜態 option 的 key 退化語意（**measurer 順帶點出，必須寫死**）

**measurer 指出**：★**靜態 options（備戰／貿易／survival…）本來就不帶 target** ⇒ **不在 exact-pair 適用範圍。**

⇒ **寫死語意**：**`target` 為空時，key ＝ `(option 結構 id, ∅)`**
—— 行為**等同現行的「按 option 折價」**，**不是特例、不是第二套**。
★**這一條必須明寫**，否則 implementer 會在「靜態 option 沒有 target 怎麼辦」上**自行決定**，
**那就是兩套語意的起點。**

## §4 folding（★**單一失敗記憶，不得有兩套**）
- **candidate 路（`:104`）接上同一把尺**
- ★**靜態 option 路收斂到同一個 key 空間** ⇒ **一套記憶、一個查詢入口**
- ⛔ **不准出現「candidate 用新的、option 用舊的」** —— 那就是又一份 drift 的真相

## §5 驗收
1. ★**覆蓋率**：接線面積從 **2 個 option** ⇒ **報實際涵蓋的 (結構 id, target) 對數**
   （★依 `00_roles §覆蓋欄`：**記 done 必同記覆蓋率**）
2. ★**行為**：`build_workshop` 對同一目標**連續失敗後 util 要真的下降**
   —— **測規律不測結果**（同 join 法條測的形狀）：
   *同一 (動作, 目標) 連續失敗 N 次 ⇒ 第 N+1 次的 util 嚴格小於第 1 次*
3. **反面**：**不同 target 的同類動作【不受影響】**（證明沒有偷做類級泛化）
4. `det fp` **預期會變 ＝ intended-change**；headless 分流照實列
5. ★**死水兩欄**：新 key 的**呼叫頻率**與**輸入變異性**（**別做出第二個恆 1.0 的機制**）
   —— ★**但主要防線已前移到 §0**（R² 裁）：**命中率要在動工前就知道，不是做完才發現。**

## §6 閘
`headless` ／ `det×3`（intended-change） ／ `constitution_gate` ／ `seam-gate`（HARD，`tier: full`）
／ tap 全 Probe-gated、**禁耗 global RNG**
