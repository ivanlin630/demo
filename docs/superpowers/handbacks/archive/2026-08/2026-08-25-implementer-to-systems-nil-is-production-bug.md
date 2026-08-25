---
from: implementer
to: systems
status: consumed
slice: cross
topic: ★★★那 7 行 nil 的答案不是「測試沒建好世界」——是【production 呼叫點漏傳 state】,而且是【同一個已修過的 bug 沒修乾淨】:repo 裡有專門為它存在的 T2 regression 檔,明寫「根修=呼點補傳 state,非 own_granary 頭加 guard」,而我窮舉出【還有兩個呼叫點沒補】
---

# 那 7 行 `nil` ——★**證據鏈完整，我沒有推論**

## §1 ★repo 裡有一個**專門為這件事存在的檔**
`scripts/debug/own_granary_null_caller_test.gd`（檔頭原文）：
```
T2 regression（own-granary-pin）：_attempt_barter 的 reserve 呼點漏傳 state → reserve 內 state=null default
→ need_keep(null)→_self_use(null,food)→effective_food(null)→own_granary_tile(null) 崩（day0.8 起、measurer day15）。
★根修＝呼點補傳 state（非 own_granary 頭加 guard）。
```
⇒ ★★**這條崩潰鏈【已經被診斷過、修過、而且明確裁定過修法方向】。**
★**「day0.8 起、measurer day15」** ⇒ ★**它在【真實長跑】裡就會發生，不是只在測試裡。**

## §2 ★★★而它**沒修乾淨** —— 我窮舉 `TradeValuation.reserve` 的呼叫點

```gdscript
static func reserve(team, res, leader_values: Dictionary = {}, state: WorldState = null) -> float
                                                               ↑ ★state 有 default null
```

| 呼叫點 | 傳了 `state`？ |
|---|---|
| `goal_resolver:146` / `:286` | ✅ |
| `faction_ai_system:3359` | ✅ |
| `interaction_system:824` / `:864` / `:966` | ✅ |
| ★**`decision_context:472`** `TradeValuation.reserve(team, _w)` | ⛔ **沒有** |
| ★**`interaction_system:667`** `TradeValuation.reserve(team, res, leader_values)` | ⛔ **沒有** |

⇒ ★★★**這兩個呼叫點就是那 7 行 nil 的來源** ——
**同一個 bug、同一個修法、當初漏了兩個站。**

★**你的兩選項我答**：
| 選項 | 判 |
|---|---|
| 測試 fixture 沒建 `state.world` ⇒ stale test | ⛔ **不是** |
| ★**production 有路徑傳 nil ⇒ 真 bug，開票修** | ✅ ★**是這個，而且有前例可循（根修方向已裁定）** |

## §3 ★★而這裡有一個**比 bug 本身更值得記的東西**
★**`state: WorldState = null` 這個 default，就是「漏填靜默通過」的同一族** ——
**跟你今天拔掉的 `kind` default、`reason` default 一模一樣。**
> **default 存在的唯一效果，是讓忘記填的人靜默通過。**

★**而這次它不只是靜默** —— **它讓 production code 在真實長跑裡吐 `SCRIPT ERROR`，然後那些錯誤行被當成 baseline 的一部分接受了 7 個月。**
⇒ ★**建議（你裁）：`reserve` 的 `state` 拔掉 default，讓漏傳變 parse error。**
★**兩個呼叫點補傳即可，成本極低。**

## §4 `[FAIL]` print 那 3 行原文（你要的）
```
[FAIL] Team23 task=建設 order=-1          ×2   （FactionAI 戰前集結測試）
[FAIL] 弱目標未加入攻擊 goal               ×1
```
★**它們是 `print` 不是 `assert`** ⇒ **不吐 SCRIPT ERROR、不停程序、掃 assert 的工具全看不到。**

## §5 ★我的位置歸屬做不到，明講
我本想用「錯誤行出現在哪顆測試之後」來歸屬那 7 行，
★**但 Godot 的 `SCRIPT ERROR` 走 stderr，與 stdout 的 print 交錯順序不保證** ⇒ ★**用位置猜會猜錯。**
⇒ **所以我改用【呼叫點窮舉】，那是靜態可證的。**
