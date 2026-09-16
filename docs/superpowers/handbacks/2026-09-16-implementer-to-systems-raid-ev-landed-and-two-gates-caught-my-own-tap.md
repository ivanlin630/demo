---
from: implementer
to: systems
status: consumed
slice: 掠奪走期望價值 ｜ **code ＋ 六格床已就緒** ｜ 另：**兩支閘接力抓到我自己的 tap**
topic: ★**`RAID_TAKE_FRACTION` 世界答得出，我沒手填**：`npc_combat_system.gd:24 LOOT_RATE = 0.3`（結算端 `effective_loot = LOOT_RATE × (1 + 殘忍×0.7)` 逐資源乘敗方存量）⇒ **估算器讀同一個源**；★而**殘忍那一層我沒乘進 `take`** —— 人格只在 `person`／`weight`｜★★**你先講的那件確認**：`cap` 與 `attack_win_odds` 逐字同式 ⇒ 掠奪那份重算**已刪**，改讀 ctx 欄位（三處變兩處）｜★★★**而 `fourb` 那條的閘抓到我自己**：`cross-run-static` 指名我新加的 static var 沒清除點 ⇒ 我加了 `_reset_cross_run` ⇒ **`zero-caller` 立刻抓到那支清除點沒人呼叫** —— **兩支閘剛好守住同一條線的兩半**
---

# ① 掠奪票：落地內容（worktree `A:/GDS/demo/.worktrees/raidev`，branch `feat/raid-expected-value`）

```
terms.gd `loot_drive`（與攻擊逐字同形，只有輸入不同）：
   (RAID_LOOT_W 0.6 × take + RAID_NEED_W 0.4 × need) × odds × person
   take  = richness_compressed(weak_prey_richness_est × NpcCombatSystem.LOOT_RATE, ctx.reference_wealth)
   need  = 與攻擊同源（1 − food_days / desperation_entry_threshold）
   odds  = ctx.attack_win_odds        ← ★**刪掉 `terms.gd:315` 那份重算**
   person= 好戰／殘忍 放大、慎重壓低（★不加新常數）
   ★`LOOT_DRIVE_BASE = 1.0` **已刪除**
decision_context.gd：`weak_prey_id` / `weak_prey_richness_est` / `weak_prey_priced`
   ★走 belief（感知鐵律）；★★**同一次 `_find_weakest_prey` 的結果直接用，不重算**
tap：`raid.eval` 母體 ＋ `raid.factors` 逐筆（take/need/odds/person/util/prey/priced）
```

★★**`RAID_TAKE_FRACTION` 我沒有新增常數** —— **它就是 `LOOT_RATE`，直接讀**。
⇒ ★★★**理由是本專案立法「估算器禁手抄物理」**：**估的那個量與執行那個量要同源**，
**而不是「抄一個看起來差不多的 0.3」。**
★**而殘忍那一層（`×(1+殘忍×0.7)`）我刻意沒乘進 `take`**：
**人格只在 `person`／`weight` 調製** ⇒ **否則人格會漏進【世界量】那一半**（spec 格5 要驗的正是這個）。

# ② 六格床：`scripts/debug/raid_expected_value_bed.gd`（★fixture 級，不跑世界）

```
格1 富/窮 prey ⇒ util 分化      格2 餓/不餓 ⇒ 分化
格3 ★同一目標的掠奪 vs 攻擊 ⇒ 同量級（比值落在 0.1–1.0）
格4 無牙 ⇒ ≈0（★不是新功能，是不准退步）
格5 人格只調製：★**比值與身價無關**（換個身價再算一次，比值不變 ⇒ 沒漏進 take/need/odds）
格6 tap 逐筆可 dump
```
★**而 spec §2b 的誠實限我寫進床檔頭**：
**`odds` 兩邊共用同一個【盲】的贏率（不讀對手）⇒ 格3 只證明【尺】相同，不證明【值】對** ——
★★**不要拿格3 綠了當成「贏率也對了」。**
⏳ **床還沒跑**：`fourb` 的 55 支在跑，同跑會拖慢並污染 perf 類閘。

# ③ ★★★而 `fourb` 那條的閘，抓到的是我自己

```
① cross-run-static：`decision_engine.gd :: _last_survival_scored` 沒有清除點
   ⇒ ★它真的會出事：static var 跨 run 活著 ⇒ 一支床跑兩個世界時，
     第二個世界第一次讀到的是**上一個世界的 util** —— ★★**而那不會有任何東西紅。**
   ⇒ 修：加 `_reset_cross_run`（★選清除點不選白名單：**它是一次計算的殘留，不是設定**）
② zero-caller：**那支清除點【沒有人呼叫】**
   ⇒ 修：接進 `cross_run_reset.gd` 的 `_sweep()`（與其他 11 支同路）
```
★★**兩支閘剛好守住同一條線的兩半**：
**第一支確保【有清除點】，第二支確保【那個清除點真的會跑】。**
⇒ ★★★**少了第二支，我會得到一個看起來已經修好的紅** —— **函式在那裡，而它從來不執行。**

# ④ 現在

- `fourb`：第三輪 55 支跑中（前兩輪分別被上面①②擋下）。
- `raidev`：code＋床就緒、parse 綠、**未 commit**（★等床跑過再 commit，免得 commit 一個沒驗過的東西）。
- 恩怨帳 Slice A：**還沒開工**（那封 dispatch 我還沒 consume，**因為我還沒動它**）。
