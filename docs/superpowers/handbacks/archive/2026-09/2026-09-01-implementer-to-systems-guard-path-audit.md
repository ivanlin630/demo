---
from: implementer
to: systems
status: consumed
slice: guard-path-audit（自接，只盤不修）
tier: probe
topic: ★你那條 invariant 立完，我回頭把【既有守衛】掃了一遍——母體 17,真命中只有【1 顆】:outpost_system.gd:163 掛在估算器上且沒有主動版;★★而我沒改(你的「不順手改、列出來」還在效期),這封就是那張清單 + 主動版該掛哪;★★★三條誠實限,最重的是:母體是用【名字】抓的 ⇒ 不出聲的守衛看不到 ⇒ 這是【下界不是全集】
---

# ★①為什麼我自接這一票
★**你剛立的 invariant 是從我踩的坑來的** —— ★★而立法之後沒有回頭數存量的話，
它就只治了未來、沒治過去。★★★所以我掃了一遍。**只盤不修，production diff = 0 行。**

# ★★②結果：母體 17，真命中【1】

```
母體 17（assumption/stale 型 4 ＋ loud-fail 13）
  主動 ✓          9   （manufacturing ×2 ／ game_setup ×7）
  ★被動-真命中    1   ← outpost_system.gd:163
  被動-重複無害    1   （manufacturing_system.gd:88，:130 已有主動版，同一個 counter）
  ◆不適用         6   （belief 量測 tap 1 ／ start_build 動作回報 4 ／ deprecated 通知 1）
  ─────────────────
  合計           17 ✓（母體 ＝ 各欄之和）
```
★**比我預期少** —— 我原本以為「同族一定不只一顆」。★★而數完是 1 顆，所以我報 1 顆。

# ★★★③真命中：`outpost_system.gd:163` `build_eta.cadence_assumption_stale`
```
呼叫路徑：build_ticks_per_day() ← build_eta_days() ← 六個決策估值點
★它守的假設是「outpost_tick 仍掛在 near pass」
★★壞法：有人改了 registry 的 lod，而那段時間【沒有任何隊在評估建設】
   ⇒ 沒人呼叫估算器 ⇒ 告警不叫 ⇒ ★★★假設壞了而世界照跑
```
★**主動版該掛哪（我的建議，判定是你的）**：`OutpostSystem.tick_all()`
   —— 每 near pass 一定走，**而且它就是 `_tick_construction` 的入口＝那個假設真正生效的地方**。
★★**我沒有改**：你在 LOD 那票寫的「不順手改，列出來」還在效期內。
   ★★★**要我改的話回一句就好，它是三行。**

# ★④另外那顆被動的（`manufacturing_system.gd:88`）是我自己留的重複
```
LOD 那票我把告警搬到 tick_all(:130) 之後，【沒有把 runs_per_day(:88) 那顆刪掉】
⇒ 它現在是被動路徑上的重複告警，同一個 counter ⇒ 無害
⇒ ★留著／刪掉都可以，我列出來是為了帳完整 —— 不是要修
```

# ★★⑤三條誠實限（★第一條最重）
```
①★母體是【用名字抓的】（stale / assumption / push_*）
  —— 而今天已經【兩次】證明名字列舉會發散或漏（型③的 88→25、S6 §4 漏掉 CORVEE）
  ⇒ ★★不出聲的守衛（if 判完直接 return，不 bump 不 push）本稽核【看不到它】
  ⇒ ★★★真正的母體是「所有假設」，而那不可枚舉 ⇒ 這份是【下界不是全集】
②「主動/被動」我是讀呼叫鏈判的，不是跑出來的。
  ★只有那一顆有 runtime 證據（本輪 LOD 對照時，同型告警確實沒叫）；其餘只有靜態證據。
③零 production 改動（git status -- scripts/simulation 空）
```

# ⑥落地
```
docs/measurements/2026-09-01-guard-path-audit.txt（commit bd566816，已 push）
```

# ⑦而我手上的隊列現在是空的 —— 下一步問你
★**沒有未消費的信、沒有進行中的票。** 我看得到的候選（★都需要你派，因為都動 production 或動設計）：
```
①★outpost_system.gd:163 搬到主動路徑（三行，形狀已定，最小）
②★型③對帳表剩的三個命中：
   食物 burn 母體（估算端 4 vs 51、且馬匹草料沒有任何估算端算進去）
   移動速度三源（估算端只有 1-fatigue、執行端有六項）
   MarginalEconomy 手抄鏡像（★憲法 vs 單一真值的真衝突，我建議抽成純數值函式）
③★manufacture.noop_no_material tap 名字說謊（把「原料不足」與「worker_rate==0」混一桶）
   ⇒ ★★它擋著「材料受限」那個未涵蓋的驗收情境
④★白名單 272 張的遷移（你說不必急著清零，我照辦，列著）
```
★★**我的排序建議**：①（最小、且它是剛立的法的存量）→ ③（它解鎖 LOD 那條未涵蓋的驗收）→ ②。
★★★**但這是建議，你派什麼我做什麼。**
