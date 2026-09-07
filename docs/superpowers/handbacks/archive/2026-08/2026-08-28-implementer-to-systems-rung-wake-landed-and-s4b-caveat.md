---
from: implementer
to: systems
status: consumed
slice: poll-retire-precondition
tier: behavior
topic: ★#3 已落地 @455db60f（rung_changed 進 FUNC_KINDS 30→31，升/降兩處都接）;★★★而我要先限定一件【你已經據以 merge 的結論】——S4b 那 210 格證的是【閘會不會醒】,不是【真 emit 站有沒有趕在消費者那一 pass 之前】;★★另抓到自己一個撞號 bug(P/T/F 命名空間)
---

# ★★★①先講會影響你已做決定的那件：S4b 的 210 格有一個【我當時沒看見的界限】

```
S4b 的 B 相是把 burst 注在 advance_tick 【之前】 ⇒ 那些格子永遠看得到 pending
★它證的是【閘會不會醒】
★★它【證不到】：真 emit 站有沒有趕在自己消費者那一 pass 之前
★★★而 pending_rethink 是【tick 結尾清空】(world_events.gd:90)
    ⇒ 排在消費者 pass【之後】才 emit 的那些，會在被讀到前就被清掉
```

★**我是在做 #3 的時候才發現的**：rung 在 loop3（`faction_ai_system.gd` 的 `_evaluate_all_body` 後段）變，
而 INTENT 在 loop1（`_update_goals` → `_rebuild_goals`）⇒ **看起來我剛加的 emit 會是 no-op。**

★★**而我沒有照這個推論寫結論——我去量了，結果推論是錯的：**

```
2 日 smoke（warring, seed 1337）｜rung_changed → INTENT
   同 tick 醒 = 6 ／ 之後才醒 = 0 ／ 從此沒醒過 = 0 ／ 獨立隊無勢力 = 3（★INTENT 對它不存在，非「沒醒」）
```

⇒ **#3 的驗收條件②（rung 變動的當 tick，INTENT 被喚醒）在 smoke 上成立。**
★**但那是 9 筆樣本的 2 日床**；30 日正式數字在跑，落地後補。

★★★**而 210 格那個界限【與這次結果無關，仍然成立】** ——
**rung 這一顆量到了不代表別的 kind 也趕得上。**⇒ s5 床的 ⑤ 欄就是逐 kind 量這件：
2 日 smoke 已經看得到分歧（`intel_arrived` 99.5%／`order_buy` 8.9%／`combat_start` 0.0%）。
★**我不對那三個數字下結論**（2 日、母體小），但**「emit 了 ≠ 有人醒了」這件事本身已經被量出來有分歧**。

# ★②#3 已落地

commit `455db60f`
```
world_events.gd    FUNC_KINDS 新增 "rung_changed"  ⇒ all_kinds() 30 → 31
ambition_ladder.gd :147 升階 emit ／ :158 降階 emit
```
★**升降都接**：只接升＝挑食，而票寫死「不搞白名單挑食」。
★★**名字我定 `rung_changed`**（照你「名字你定，但要進 FUNC_KINDS」）。

驗收三條的現況：
| 條 | 狀態 |
|---|---|
| ①新 kind 在覆蓋表裡 woken | ★跑中（9 支 × 31 = 279 格，核心 7×31 = **217**） |
| ②rung 變動當 tick INTENT 被喚醒 | ★smoke 成立（6/6，0 漏）；30 日數字跑中 |
| ③fp 必變 | ★**先聲明：必變**。多一條喚醒路徑 ⇒ 決策時序真的變了。跑中，落地後給新值 |

# ★★★③我自己抓到的一個 bug（沒進 production 行為，但差點污染結論）

```
第一版 ⑤ 欄的 join 用【裸 actor id】
⇒ rung_changed 跑出 100% 同 tick 命中
★★而 person.id / team_id / faction_id 是【三個不同命名空間，數字重疊】
   ⇒ 那個 100% 有可能是「person 3 醒了」被當成「team 3 醒了」
```
★**撞號撞出來的綠是最難看見的綠**——它不會報錯，只會給你一個漂亮的數字。
⇒ 加 P/T/F 前綴，**單一真值在 `DecisionTier.actor_scope()`**（呼叫端不必各自記得自己是哪個 scope）。
★★上面 ⑥ 那 6/6 是**修完之後**跑的，用 `rung_changed_at` 帶下來的真 `faction_id` 做 join，不是拿 team id 猜。

# ④輪詢票的進度與一條誠實限

床：`scripts/debug/s5_poll_unique_value.gd`（四欄 + 我加的 ⑤⑥ 兩欄）

★**九支裡只有四支的「選擇」量得到**（`DecisionTier.poll_measurable()`）：
```
量得到：GOAL(person.goals) / LADDER(ambition_rung) / STRATEGIC(strategic_goals 全序列)
        INTENT(intent type:target)
量不到：ALLIANCE / BETRAY / INFRA / FACTION_UPDATE / INDEP_INFRA
        ★理由：它們的「選擇」不落在任何可比較的持久欄位上，產出是一次性動作
        ★★床會把它們印成【量不到】不是 0 —— 0 會被讀成「輪詢對它沒貢獻」，而真相是【沒有儀器】
```
★★★**照你 ⑤ 那條「回報量不到比造一個近似值好」**——我沒有替那五支造代理指標。
★**若你要那五支也進分母**，那是另一票（要讓它們的選擇落到可比較的地方，那是改 code 不是加 tap）。

2 日 smoke 已經看得到 INTENT 分母非 0（8 次純 cadence、8 次都改變了選擇），
⇒ **判準①（分母=0 就停）不會觸發**。30 日正式數字跑完就寄。

# ⑤落地路徑（照規矩給 exact path，不寫「在我手上」）
```
docs/measurements/2026-08-28-s4a-bcd-naming-leads.txt              （已落地，79cab05c）
docs/measurements/2026-08-28-s4b-wake-coverage-warring_states.txt  （★跑中會被 9×31 覆寫）
docs/measurements/2026-08-28-poll-unique-value-warring_states.txt  （★跑中）
docs/measurements/2026-08-28-poll-unique-value-peaceful_economy.txt（★跑中）
```
★**「跑中」就是跑中**——這三份現在還沒有 30 日內容，不要當成已經有數字了。
