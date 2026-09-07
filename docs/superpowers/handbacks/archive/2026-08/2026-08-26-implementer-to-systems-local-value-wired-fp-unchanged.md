---
from: implementer
to: systems
status: consumed
slice: local-value-blind-callsites
tier: full
topic: ★15 呼叫點全接 @6735b2c2(逐點走函式邊界,非檔名非行號鄰近);★★★但【fp 沒變】而我不當它是安全——執行證據 100% 覆蓋+339/2562 真的看到不同庫存,行為卻兩床逐位元相同;三件事分開報,請你判
---

# `local-value` blind callsites — **接完，但驗收有一格我交不出綠**

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\local-value-blind`／`feat/local-value-blind-callsites` |
| **commit** | `6735b2c2` |
| **headless（閘）** | ★**PASS，7 vs baseline 7** |

## ★呼叫點清單（**逐點走函式邊界**，不是檔名也不是行號鄰近）
| 類 | 檔:函式 | 數 |
|---|---|---|
| 純 NPC | `interaction_system.gd::_attempt_barter`（×5）、`::_attempt_trade_direction`（inventory bid ×1） | 6 |
| 純 NPC | `faction_ai_system.gd::_find_trade_target` | 1 |
| 純 player | `player_trade_system.gd::（開市/評估/接受 三處函式）` | 5 |
| 純 player | `player_api_mapper.gd::map_trade_session` | 4 |
★**你 spec 寫的是 `5/1/9`；我實際追到 `7 NPC / 9 player`** ——
**差在 `:952`（`_attempt_trade_direction` 的 inventory bid）我歸「純 NPC」而你歸「共用」。**
★**理由**：`_attempt_trade_direction` 的 caller 鏈我追過，**player 走的是 `player_trade_system` 那條，不經這裡**；
★★**但這是我追的，若你手上有 player 走到它的呼叫鏈，以你的為準，退我改。**

## ★★★`fp` 那格：**沒變，而我不打算把「沒變」講成「安全」**
你 spec 寫「純 NPC ＋ 共用 ⇒ `fp` **要求變**」。**實測沒變**：
| 窗口 | main | branch |
|---|---|---|
| `warring_states` 1000 tick | `5c1fa2fce6c6aa01135d961371693d39` | ★**相同** |
| `warring_states` 2400 tick | `b4086e50f277855383b9231eb9e5d0d7` | ★**相同** |

★**而「沒變」有三種可能，我把三種分開量了**：
| 讀法 | 判準 | 實測 |
|---|---|---|
| (a) **接線沒生效** | 有沒有呼叫傳 state | ★**排除**：`calls_with_state / calls` ＝ **2562/2562**（peaceful 30d）、**3194/3194**（warring 5d）＝ **100%，blind 呼叫 0** |
| (b) **生效但世界沒有可改變的東西** | 傳 state 後看到的庫存有沒有真的不同 | ★**部分**：peaceful 30d **339/2562 ＝ 13.2%**（material 233／food 106）；warring 5d **21/3194 ＝ 0.7%**（全 food） |
| (c) **估值真的不同、但沒有翻轉任何結果** | 同床兩側行為對照 | ★★**這個成立**：`join_accept_measure_bed`（peaceful/1337/30d）**main 與 branch 輸出【逐位元相同】** |

⇒ ★★★**結論（我下的是這句，不是「安全」）**：
**新路徑【每一次都被走到】、而且在 13.2% 的呼叫上【真的改變了隊自己看到的庫存】，
但在這兩張床的窗口內【從未跨過任何會翻轉交易的門檻】。**

★**這正是你立的那條的反面用法**：**`fp` 不變只證等價、不證執行 ⇒ 要另有非零 counter。**
**counter 我有（339 / 21），所以「執行」這一半是綠的；「行為改變」那一半我交不出來，如實掛著。**

## ★要不要往下追，我的建議（**你裁**）
★**不建議現在造情境去逼它翻轉** —— 同 stock 那票的理由。
★**若你要一個決定性的答案**，最小的一步是**在 `_attempt_trade_direction` 的成交判斷處
加一顆「blind 值會不會改變成交與否」的對照 tap**（★純觀測、同時算兩個值、只記差異，不動控制流）
⇒ **它會直接回答「13.2% 的估值差裡有幾次落在成交邊界上」。**
★★**我沒有自己加**，因為那是**第二顆為了追同一個問題而加的 tap**，該不該加是你的判斷。

## ★落地
- 執行證據床：`scripts/debug/local_value_state_evidence_bed.gd`（同 branch）
- 數字檔：`docs/measurements/2026-08-26-local-value-state-evidence-30d.txt`／`…-warring-5d.txt`
- 兩側行為對照原始輸出：`…\scratchpad\ja_main.txt`／`ja_branch.txt`（**逐位元相同**，12332 bytes 各一）

## 隊列
1 tap ✅merged　2 specimen ✅（QA PASS）　3 failure-memory ① ✅　4 stale test ✅merged
5 stock-vs-flow ✅（A+B，等 reviewer 措辭 CLEAN）　6 **224 identity tap ✅** `462ede84`（在 `feat/wire-in-specimen-trace`）
7 **render 三態 ✅** `fecba76e`（已寄 QA 格式變更通知，QA 回：判決未引用過 `intent_hist`，不受影響）
8 **`local-value` ✅ 本封** ⇒ ★**我這邊清空了，下一件等你派。**
