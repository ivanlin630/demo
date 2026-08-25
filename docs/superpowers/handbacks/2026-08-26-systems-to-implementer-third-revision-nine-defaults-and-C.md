---
from: systems
to: implementer
status: open
slice: local-value-state-required
topic: ★三訂(最後一次,我保證不再動 scope):default 從 8 → 9(⑨ player_trade_system._sellable_qty 拉回範圍內);★★新增 C:headless_test.gd 4 處——它在 baseline-7 主測試檔,一 merge 下次例行 headless 就炸;★★★我的驗收④有洞,已重寫
---

# ★三訂：**9 個 default，不是 8 個**

**⑨`player_trade_system.gd:19 _sellable_qty`** —— 我上一封標「範圍外」，★**錯了**。
它**自己也有 `state: WorldState = null`**，而且**直接轉送**：
```gdscript
func _sellable_qty(team, res, leader_values := {}, state: WorldState = null) -> float:
	return maxf(... - TradeValuation.reserve(team, res, leader_values, state), 0.0)
```
⇒ ★★**同一條可達鏈，只是入口多疊一層、跨了檔案。留著它 ＝ 這票的保證作廢。**

**完整 9 個**：`trade_valuation.gd :85 :102 :109 :115 :121 :127 :136`
＋ `interaction_system.gd:662` ＋ ★`player_trade_system.gd:19`。
★**唯一真的範圍外**：`decision_engine.gd:58 rank_scored_ctx`（reviewer 複驗過與 `_stock` 無關）。

---

# ★★動工前要接住的變成【三個】

| # | 位置 | 處置 |
|---|---|---|
| A | `scripts/debug/slice_a_observe.gd:45`（★**同一行兩個呼叫**） | `reserve(t, res, {}, state)` |
| B | `interaction_system.gd:667-669 _calc_reserve` | ★**整支刪**（零 caller ＝ 純負債） |
| ★**C** | ★★**`scripts/debug/headless_test.gd:11657 / 11658 / 11660 / 11665`**（4 處，同一支 `_test_trade_reserve_no_drain`） | `pts._sellable_qty(t, "material", {}, state)` —— `state` 就在 `:11652` 手上 |

★★★**C 比 A 嚴重**：**它在 `headless_test.gd`（baseline-7 主測試檔）裡**
⇒ **不是「以後有人跑才炸」，是【這票一 merge、下一次例行 headless 就炸】。**

★**順帶讀一下 `:11652` 那行的註解**——那是這個測試**自己寫的自認證詞**：
> 「reserve 的 state default 讓漏傳編得過」

★★**寫那行的人早就知道自己在吃 default 的便宜，還是照吃。**
⇒ **那才是 default 的真正代價：它讓「明知不對」也能過關。**

---

# ★★★我的驗收④有洞，已重寫 —— **這條你動工時要用到**

**原本**：「編譯即驗收：少傳 `state` 就編不過。」
★**洞**：`pts._sellable_qty(t, "material")` **不是少傳引數** ——
`_sellable_qty` 用自己的 default 補齊，再以**完整 4 引數**呼叫 `reserve(team,res,{},null)`
⇒ ★★**引數個數對、值是 `null` ⇒ 編得過，執行期才崩。**

⇒ **新的④**：
> ★**驗收是「可達閉包上的 default 數 ＝ 0」；「編譯過」是它的【結果】，不是檢查本身。**

★**實務上對你的意思**：★★**改完不要只看「編得過」就送** —— **要真的跑一次 `headless_test.gd` 與
`slice_a_observe.gd`**（後者平常沒人跑，這次必須跑，它就是 A 的現場）。

---

# ★我把邊界畫錯三次，一次講完免得你再被我改來改去
| 次 | 我說的 | 實際 |
|---|---|---|
| ① | 「`local_value` 呼叫點就是全部」 | `_stock` 還有第二條鏈 |
| ② | 「這條 grep 是結構型判準」 | 它只掃 `TradeValuation.` 前綴，**看不見包裝層** |
| ③ | 「那兩個檔就是全部」 | **跨檔閉包**還有 `_sellable_qty` |

★**病根同一個**：**我用【看得見的容器】當母體（函式名／前綴／檔案），而真正的母體是【可達性】。**
★★**所以三訂之後我不再自己畫範圍了** —— **驗收①改成數【定義側的 default】，那個不吃我畫母體的能力。**
⇒ ★**你動工時若又發現第 10 個 default 或第四個呼叫端，直接回報，那是我的帳不是你的。**

# 狀態
**送 reviewer 複核中**（他只看 A/B/C 改了沒 ＋ 九個 default 是不是真的一起刪 ＋ ④ 新講法對不對）。
★**CLEAN 我立刻通知你**；在那之前**不要動工**（scope 已經被我改過三次，再改一次就是浪費你的工）。
