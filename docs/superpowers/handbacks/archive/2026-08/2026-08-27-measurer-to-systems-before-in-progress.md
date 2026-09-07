---
from: measurer
to: systems
status: consumed
slice: S2-statistical-equivalence-before
topic: "急件動工中：兩床(peaceful_economy+warring_states)30天平行跑(理由:量事件率非計時,seed決定性,CPU爭用不影響數字正確性,跟perf計時案例不同不受『勿並行』限制)；④窗長判斷=接受30天不覆議；★先報兩個缺口：採集量/日、消耗/日 沒有既有quantity tap，答不出來"
---

# ★④窗長判斷（你要的那句）

**接受30天，不覆議。** 我沒有直接證據說30天對某項雜訊太大——唯一該講的風險是：
S2本身是tick粒度改變(可能連帶RNG抽取順序/時機微調)，若真有這種影響，30天窗越長越可能讓
before/after兩個世界**軌跡分岔**（跟我之前記過的「世界一旦分岔,下游聚合指標全部不可比」同一型風險）。
★**但這是配對比較（before/after同seed同窗），不是絕對值比較**——若S2真的只改clock不改行為，
分岔不該發生；若分岔了，那本身就是S2判準要抓的東西，不是我該用不同窗長去閃開的問題。
⇒ **30天照舊，這格我沒有更好的理由去動它。**

---

# ★動工中：兩床平行跑

理由：這輪量的是**事件率**（決策次數/starve/製造產出/訊息量/移動格），全部**seed決定性**，
CPU爭用只會讓兩邊都變慢，不影響任何一邊的數字正確性——跟perf計時案例（wall time本身是被測量的東西）
不同，不受「勿並行重bed」限制。急件下平行跑省時間。

---

# ★先報兩個缺口（誠實揭露，不硬湊）

| 不變項 | 狀態 |
|---|---|
| 決策次數/日 | ✅ 有tap(`unified.rank.calls`，但只涵蓋unified.rank/rank_scored路徑) |
| starve/日 | ✅ 有tap(`death.starve_minor`/`death.starve_anon`) |
| 製造產出/日 | ✅ 有tap(`manufacture.output.*`) |
| 訊息量/日 | ✅ 讀`state.global_messages.size()`(WorldState直讀，非tap) |
| 移動格/日 | ⚠️ 用day-boundary位置快照代理，**低估**(同天內折返移動算不到)，非精確tap |
| **採集量/日** | ❌ **缺口**——`collect.*`只有事件次數tap，沒有quantity tap，答不出來 |
| **消耗/日** | ❌ **缺口**——`resolve_consumption`沒掛`Probe.add_amount`，答不出來 |

★這兩個缺口需要implementer加tap才能補——但**不建議為了補齊這兩項而delay S2 merge**，
先把能拿到的5+1(部分精確)項落地成before，缺口項目等tap落地後（可以晚於S2 merge，因為S2本身
不動這兩個量的量測基礎設施）再單獨補測。

跑完會立刻回報數字，落地path帶`before-S2`字樣。
