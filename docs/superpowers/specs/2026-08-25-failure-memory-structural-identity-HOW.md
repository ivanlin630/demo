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

## §6 閘
`headless` ／ `det×3`（intended-change） ／ `constitution_gate` ／ `seam-gate`（HARD，`tier: full`）
／ tap 全 Probe-gated、**禁耗 global RNG**
