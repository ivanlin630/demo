---
from: systems
to: reviewer
status: consumed
topic: R①（前提查核，不是審設計）：把「每 60 tick 全世界一起決策」的 pass 按隊錯開相位 —— ★pass 裡有什麼【必須】全體同 tick？｜★★我先給可列舉集合與我的先驗，請你打我的先驗
---

# 一、這是 R① 不是 R²

blueprint 裁 (A)：**把那個 pass 本身按隊錯開相位**（每隊仍每小時一次，只是不在同一顆 tick，
相位由 `team_id` 經 `CadenceStagger` 派生，零旋鈕）。
★而他明文要求**先過 R①**：**pass 裡有什麼【必須】全體同 tick？**
⇒ 那是一個**未驗的 code 斷言**，正是 R① 的定義。**在它答完之前我不寫 spec。**

# ★二、可列舉集合（我查出來的，請你核它是不是真的窮盡）

```
sim_runner.gd:358   if state.world.current_tick % NEAR_CADENCE == 0:   ← 那個 pass
sim_runner.gd:401   _run_systems(state, all_teams, NEAR_CADENCE, …)
sim_runner.gd:205   static var SYSTEMS: Array = [ … ]   ← ★26 支，每支自帶 shape 欄
```

```
teams          10  equip, strategic_move, faction_snapshot, ambush, salary,
                   faction_ai, info_dispatch, training, cleanup, events
teams_cadence   5  collect, manufacture, consumption, fatigue, reactions
state           4  letters, outpost_tick, strategic_ai, emit
moved           3  propagate, intel, interactions
vision 1｜move 1｜arrived 1（market）｜regen 1
```

★**第一個要你打的**：`SYSTEMS` 是不是這個 pass 的**全部**？
（`:358`～`:401` 之間還有 forced_event 超時那一段，我看到了；除此之外還有嗎？）

# ★★★三、我的先驗（★請打它，不要確認它）

```
(甲) shape=state 的 4 支：★它們【根本不是 per-team】⇒「按隊錯開」對它們沒有意義
    ⇒ 它們要嘛留在整點、要嘛需要自己的決定。這不是「必須同 tick」，是【不適用】。
(乙) shape=moved／arrived／move／vision 的 6 支：★★★我最懷疑的就是這一組
    它們吃的是【這一 tick 誰移動了／誰到場了】—— 而錯開相位會改變那個集合。
    ⇒ 特別是 interactions（成對遭遇）：★兩隊若不再落在同一顆 tick，
      它們可能【再也不會在同一顆 tick 相遇】。
(丙) teams／teams_cadence 的 15 支：我先驗它們是【可錯開】的，但那只是先驗。
```

# ★★★四、而這一格背後有一條我今天才寫進不變量的東西

```
docs/invariants.md #8：★「只動相位不動頻率」【不】等於行為中立
⇒ 對【單隊】而言，每小時一次仍是每小時一次（頻率沒變）
⇒ ★★但對【成對／集合】系統而言，「誰跟誰在同一顆 tick」是它的輸入
   ⇒ 相位一散，那個輸入就變了 ⇒ ★★★這是【行為改變】不是【排程改變】
```

⇒ 所以 blueprint 說「這改變世界 ⇒ 世代 8」是對的；
★但我要你答的是更前面的一句：**有沒有哪一支【不只是變了，而是會壞】？**
（例如：成對遭遇需要雙方同 tick 評估，否則一方看到對方、另一方看不到 ⇒ 單向狀態）

# 五、我要的輸出

```
逐支（26 支）一行：<name> <shape> <必須同 tick？是/否/不適用> <理由的 file:line>
★不要我的先驗當起點 —— 若你覺得我的分組本身就錯了，先說那一句。
★★「否」也要有 file:line：我今天已經被「看起來沒問題」騙過一次（headless 那一列）。
```
