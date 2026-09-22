# 互動迴圈幀時間量測儀器（HOW spec）

**開票**：blueprint 裁 2026-09-23（裁 (甲)：玩家的問題是**畫面凍住**）
**狀態**：★★**HALT 2026-09-23**：本票的用途是驗收分片票，而分片票的門檻可能摸不到（見那份 spec）。★本票【本身】仍有獨立價值：互動迴圈的幀時間今天沒有任何床在量。★★而 R² 指出 §3 的校準【必要不充分】：直接包 `advance_tick` 的假接線一樣會對得上 ⇒ 它擋得住「世界變了」，擋不住「裝好但沒接電」。
**它是什麼**：一支床，量**互動迴圈的幀時間**；★**它不是修法**，它是分片票的驗收儀器。

---

## §0 為什麼非開不可（不是「順便做個床」）

```
分片票的驗收原本掛在 B3（freeze_sample_bed）⇒ R² 判 premise_contradiction：
  freeze_sample_bed.gd:96-99 量的是 advance_tick 那一個呼叫，
  而分片票明文【advance_tick 契約不動】⇒ ★驗收恆真。
★★更深：frame_time_who_freezes_bed.gd:10/:18/:51 明寫現有量法把【tick】當【frame】的代理，
  理由是「ObserverBridge 的 12ms 預算不可切割」—— 而分片票要做的就是把它切開
  ⇒ ★★★修法本身摧毀了舊儀器的成立理由。
⇒ 所以先有儀器，才談修法。
```

## §1 量什麼（★量的是 `tick_step` 的牆鐘時間，不是 `advance_tick`）

```
scripts/ui/observer_bridge.gd:26-36
  func tick_step(max_ticks, budget_ms = 12.0) -> int:
      t0 = now
      while done < max_ticks:
          _runner.advance_tick(...)          ← ★一整顆 tick，不可中斷
          done += 1
          if elapsed >= budget_ms: break     ← ★★預算在【tick 跑完之後】才檢查
⇒ 今天：一顆 2 秒的 tick ＝ 一個 2 秒的幀（預算擋不住它）
⇒ ★★★所以本床量的是【一次 tick_step 呼叫的牆鐘時間】＝玩家那一幀真正卡多久
```

## §2 判準（自足、同一行帶操作元）

```
[IFRAME] gen=<G> seed=<S> days=<D>/<N> frames=<F> over2s=<K> p99_ms=<P> p50_ms=<M> verdict=...
★frames ＝ tick_step 被呼叫的次數（母體）—— 沒有它，「沒有卡頓」與「沒跑到」長得一樣
★★over2s ＝ 單次 tick_step > 2s 的次數
```

## §3 ★★★內建的健全性檢查（這一格是本票最重要的東西）

```
今天 tick_step 【不可切割】 ⇒ 它的最壞幀 ≈ advance_tick 的最壞幀
⇒ ★本床在【世代 7、分片【之前】】量出來的數字，必須與 B3 那一輪【對得上】：
   B3: seed1337 p99=1161ms over2s_days=7/12｜seed42 p99=1052ms over2s_days=5/12
   （同機 HW-2、同兩顆種子、同 12 天窗）
⇒ ★★對不上 ⇒ **是這支新床錯了**，不是世界變了 —— 因為兩者今天量的是同一件事。
⇒ ★★★而分片【之後】兩者【必須分岔】—— 那個分岔就是修法的效果本身。
```

★這一格讓新儀器**在被使用之前先被校準**，而校準的對照是**已經在卷面上的真實數字**。

## §4 副作用對照：世界吞吐（blueprint 令）

```
本床同時印：[IFRAME] … ticks_total=<T> wall_s=<W> tps=<T/W>
★★分片票的驗收要加一格：**吞吐不得掉 > 5%**（相對於分片前、同機同種子的 tps）
★★★理由（blueprint 的話，我原文收）：**不准把變慢藏在畫面順裡。**
★血統標註：5% 是 **WHAT 選的政策門檻**，★不是量出來的 —— 誰之後要改它，改的是政策不是事實。
```

## §5 不變量

```
・★本床【不得】改變被觀測物：tick_step 是 production 路徑 ⇒ 計時只能包在呼叫外面，
  不得在 ObserverBridge 內插 Probe／計時（觀測不得改變被觀測物）。
・時間量跨機不可比 ⇒ 卷面必帶 wrapper 的 [HW] cpu= 行與開跑前 FreeMB。
・母體 0 ⇒ 【不可判】不是綠（同 B3 的規矩）。
```

## §6 誠實限

```
★本床跑在 headless 下，而 tick_step 是 UI 那一側的入口 ⇒ 它量的是【那條路徑的耗時】，
  **不是真 GUI 的 present-to-present**。★★真 GUI 還有 render／輸入處理，本床看不到它們。
⇒ 所以它答的是「世界那一側讓畫面等了多久」，不是「玩家眼睛看到的總延遲」。
★★★這一條必須寫在卷面上，否則下一個人會拿它當「玩家實測」。
```
