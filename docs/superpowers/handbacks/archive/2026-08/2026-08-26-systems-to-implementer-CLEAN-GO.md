---
from: systems
to: implementer
status: consumed
slice: local-value-state-required
topic: ★reviewer CLEAN → 動工;★★驗收① 我又改了一次(四訂)但這次是【放寬掃描範圍】不是改 scope,九個 default 與 A/B/C 一字未動;★★★附我剛踩的第四次同型錯,免得你照抄我的 grep
---

# ★CLEAN → **動工**

**reviewer 重驗 closure**：全 `scripts/` grep（**不用我畫的任何容器當母體**）命中剛好 9 個 ＋
`decision_engine.gd:58`（已排除）＋ `depatch_track2_verify_bed.gd:29`（區域變數宣告，不算）。
★**沒有第 10 個漏網 default。**

## 你要做的（**scope 一字未動**）
1. **A** `slice_a_observe.gd:45`（同一行兩個呼叫）→ `reserve(t, res, {}, state)`
2. **B** `interaction_system.gd:667-669 _calc_reserve` → **整支刪**
3. ★**C** `headless_test.gd:11657/11658/11660/11665` → `pts._sellable_qty(t, "material", {}, state)`
4. **九個 default 一起刪** ＋ `_stock()` 的 `if state != null` fallback
5. 驗收①②③④

★**動工後若又冒出第 10 個 default 或第四個呼叫端 ⇒ 直接回報，那是我的帳。**

---

# ★★驗收① 我改了（**四訂**）—— 但這次改的是**掃描範圍**，不是 scope

**reviewer 提醒**：我原本寫死兩個檔名
（`trade_valuation.gd` ＋ `interaction_system.gd`）⇒ **九個刪完後它【剛好也會＝0】**，
★**但那是因為第三個檔（`player_trade_system.gd`）的 default 被刪掉了，不是因為 grep 涵蓋了它。**
⇒ ★★**一個判準可以【因為錯的理由】而綠** —— 下一個長在別處的 default，它抓不到。

## ★新的驗收①（請用這條，不要用我上一版的）
```
grep -rn 'state: WorldState = null' scripts/ | grep -vE ':[0-9]+:[[:space:]]*(var |#)'
⇒ ★剩 1 行，且必須是 decision_engine.gd:58 rank_scored_ctx
```
（排除：區域變數宣告 `var last_state: WorldState = null` ／註解行。）

---

# ★★★而我剛剛在寫這條 grep 的時候，**又踩了同一個病第四次** —— 貼給你免得你照抄

**我第一版寫的是**：
```
grep -rn 'state: WorldState = null' scripts/ | grep -c 'func '     # ← 錯
```
★**它報 9，實際是 10。** 漏掉的是 ★**`player_trade_system.gd:19`** ——
**因為那個簽名【跨兩行】，`func` 在上一行**：
```gdscript
func _sellable_qty(team: TeamData, res: String, leader_values: Dictionary = {},
		state: WorldState = null) -> float:          ← 命中在這行，這行沒有 func
```
⇒ ★★**過濾條件本身又把母體畫窄了。同一張票第四次，形狀完全相同。**

★**所以新判準改成【排除法】**（扣掉 `var ` 與 `#`），**不是【包含法】** ——
★★**排除法的失效方向是「太吵」（會多報幾條要人看），包含法的失效方向是「太鬆」（安靜地少報）。**
**吵會被查，鬆會過關。** —— 這句是你上一票教我的，我這次用上了。
