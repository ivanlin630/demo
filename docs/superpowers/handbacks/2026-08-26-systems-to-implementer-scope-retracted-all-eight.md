---
from: systems
to: implementer
status: open
slice: local-value-state-required
topic: ★★撤回我上一封的 scope 裁定——reviewer 打回,而且他打中的比他自己說的更大:單位不是【函式】是【_stock(null,…) 到不到得了】,ask_price 也到得了 ⇒ 八個 default 一起刪;★★★動工前先接住兩個呼叫端(slice_a_observe:45 兩處 + 刪死碼 _calc_reserve);★仍等 reviewer 複核才動
---

# ★撤回：我上一封裁「①＋⑧ 做、②–⑦ 另開票」—— **那個切法是錯的**

★**你當時問我 scope，我給了一個看起來謹慎的答案，而它是錯的** ——
**謹慎的是【理由】（零 users 要各自驗），錯的是【切法】。**

## ★★reviewer 揭的：`_stock()` 有第二條入口，我的前提檢查完全沒掃到
```
reserve(team,res,leader_values,state=null)     ← 自己也有 default
  → _reserve_factor(…, state)
  → _urgency(team, state=null)                  ← 自己也有 default
  → _food_urgency(team, state=null)             ← 自己也有 default
  → _stock(state, team, "food")                 ← ★同一個 fallback
```
★**我自己再核出第三件**：**`ask_price`（⑦）也到得了**（`:127-132` 同時打 `_urgency(seller, state)` ＋ `local_value(seller, res, state)`）。

⇒ ★★★**②–⑦ 不是「另一票」，它們是【同一個 fallback 的其他入口】。**
**只刪 `local_value` 那個 default ⇒ `_stock(null,…)` 照樣到得了 ⇒ 病沒被關掉。**
★**我關了一扇門，然後宣布房間封死了。**

# ⇒ scope 二訂：**八個 default 一起刪**（spec 已改）
`trade_valuation.gd`：`local_value:136`／`reserve:85`／`_reserve_factor:102`／`_reserve_factor_food_only:109`／`_food_urgency:115`／`_urgency:121`／`ask_price:127`
`interaction_system.gd`：`local_value:662`（包裝層）
★**範圍外並記名，不要順手吃**：`decision_engine.gd:58 rank_scored_ctx`、`player_trade_system.gd:19`。

---

# ★★動工前先接住這兩個（缺一，刪 fallback 就會崩）
| | 位置 | 處置 |
|---|---|---|
| **A** | ★`scripts/debug/slice_a_observe.gd:45` —— **同一行【兩個】呼叫**，`leader_values` 與 `state` **兩個 default 都省**，而 `state` 就在同函式 scope（`:35`） | 補成 `reserve(t, res, {}, state)` |
| **B** | `interaction_system.gd:667-669 _calc_reserve`（wrapper，簽名自己就沒 `state`） | ★**刪掉整支** —— 零 caller ＝ 純負債。★★**不要「補參數讓它活」，沒有人要它活** |

★`weapon_melee_low` 不在 `SURVIVAL_GOODS(["food","medicine"])` ⇒ 走 generic 分支 ⇒ 一路打到 `_stock(null,…)`
⇒ 刪 fallback 後跑 `slice_a_observe.gd` 會在 `resource_system.gd:438 own_granary_tile(null,…)` **當場崩**。

★★**而 `_calc_reserve` 那支的註解值得你讀一次**（`interaction_system.gd:660-661`）：
> 「這一支【不崩】但更隱密 —— `_stock` 的 null guard 讓它退回『只算私產、不含糧倉』，靜默給出錯的估值。**★崩會被看見，這個不會。**」

---

# ★★★驗收① 改錨在【定義側】—— 因為我上一版的「結構型」判準自己把母體畫窄了
**新的**：
```
grep -c 'state: WorldState = null' scripts/simulation/trade_valuation.gd scripts/simulation/interaction_system.gd   ＝ 0
```
★**default 不存在 ⇒ blind 呼叫【不可代表】⇒ 根本不必列舉呼叫點。**

★★**我上一版那條錯在哪，值得你也知道**：
`grep -o 'TradeValuation\.local_value([^)]*)' | grep -v ', state)'`
——★**它把母體定義成「有 `TradeValuation.` 前綴的呼叫」**，於是**看不見**
`headless_test.gd:11631: InteractionSystem.new().local_value(t, res, state)`（**正是包裝層那條**）
⇒ **我報 debug 側 9、reviewer 報 10，他對。**
★★★**我以為我把判準從【計數】換成了【結構】，其實只是把「數錯」換成了「掃錯」—— 母體還是我畫的。**

---

# ★這票為什麼更該做（我查到的）
`scripts/debug/own_granary_null_caller_test.gd` 檔頭寫著：
> 「**根修＝呼點補傳 state（非 own_granary 頭加 guard）**」

⇒ ★★**同一個病已經修過一輪，而 default 讓它長回來了。**
★★★**修實例會長回來；刪掉 default 才不會。** —— **這句就是本票的全部意義。**

# 狀態
★**仍等 reviewer 複核**（我已把二訂送他，他只看兩處呼叫端 ＋ 八個 default 是不是真的一起刪）。**CLEAN 我立刻通知你。**
