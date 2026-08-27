---
from: systems
to: implementer
status: open
slice: S3-tiered-cadence
tier: behavior
topic: ★★★DISPATCH(R² CLEAN)——七支節律遷入 T3(3 天),意圖留 1 天當【內建對照組】;★★這是 intended-change 不是同值換來源:週期全部變長、fp 必變、事件率必降;★★★主判準是【觸發間隔】不是【事件率】(改節律讓世界分岔,而分岔後聚合不可比是我們 S2 才立的規矩)
---

# spec（唯一真相）
`docs/superpowers/specs/2026-08-27-S3-tiered-cadence-HOW.md`
**R² CLEAN**（reviewer 獨立核對過 WHAT §3 逐字、並獨立 grep 複驗了負斷言）。

# ★①做什麼（七支，★不是八支）
```
個人目標  GOAL_CHECK_INTERVAL      reaction_system.gd:3       10h → T3(3 天)
野心階梯  LADDER_EVAL_CADENCE      ambition_ladder.gd:13      10h → T3(3 天)
勢力戰略  STRATEGIC_INTERVAL       strategic_ai_system.gd:3   10h → T3(3 天)
結盟傾向  ALLIANCE_CHECK_INTERVAL  strategic_ai_system.gd:4   30h → T3(3 天)
背叛傾向  BETRAY_CHECK_INTERVAL    diplomatic_ai_system.gd:4  50h → T3(3 天)
基建方向  INFRA_INTERVAL           faction_ai_system.gd:4596  50h → T3(3 天)
派系更新  FACTION_UPDATE_INTERVAL  faction_ai_system.gd:4     20h → T3(3 天)
────────────────────────────────────────────────────────────
★意圖    INTENT_CADENCE           faction_ai_system.gd:116   ★★1 天 → 【不動】
```
★★**意圖【不搬】是 blueprint 的裁定**（它與「危機 T0 接管」在用戶原文寫在同一格＝成對設計，拆開＝反應性空窗）。
★★★**而它同時是本 slice 的【內建對照組】**：**七支變、它不變 —— 若它的事件率也動了，那是搬家漏到別人身上。**
★**唯一可能翻的變數就是這一顆**（我把 reviewer 的反論轉給 blueprint 了）——**若他改判，就是多搬這一顆，不會動到別的。**

## ★★層級要成為【結構】，不是七個各自寫 3 天
★**七支不得各自寫 `3 * TICKS_PER_DAY`** —— **那只是把 8 個沒理由的數字換成 7 個一樣的數字。**
⇒ **要有一個具名的層級來源**（形狀你定，我不代選；★★但「T3 是什麼」必須只有一個地方寫）。
★**每一支搬家在 code 註解寫一句「為什麼是這一層」** —— ★★**寫不出來的照實標 `TIER_UNJUSTIFIED`，那一欄非空不是失敗。**

## ★★★逐 site 標記（reviewer 要求，不是只寫 spec）
母體 45 顆（枚舉指令在 spec 檔頭，★**你要自己重跑一次確認還是 45**）。**(b)(c) 桶每顆就地加一行**：
```gdscript
# TIER: unmigrated(b) — S3 只搬七支,本顆待 S5+
# TIER: n/a — 語意時長非節律（某事多久算過期,不是多久評一次）
```
★**理由**：**下一個人看到的是 code 不是 spec。**

# ★★★★②怎麼驗（★主判準不是事件率）
```
★①觸發間隔（主）：per-team,逐支連續兩次 fire 的 tick 差
   ⇒ 中位數必須 = 3 天(3 × TICKS_PER_DAY),容差 [×0.98, ×1.02]
   ★★理由:間隔是【機制自身的性質】,不受世界分岔汙染——而七支全變慢會讓世界大幅分岔
★②分母同印:該支本窗 fire 次數 / 有幾隊曾 fire 過
   ★3 天 cadence 在 30 天窗內應 ≈10 次 ⇒ 0 是訊號,要當場分「沒掛上」vs「掛了沒到期」
★③意圖(對照組):事件率必須 ±5% 內
★④死水兩欄:T3 本窗被評估幾次 / T3 掛了幾支 —— 任一為 0 要當場說出是哪一種
★⑤fp:在 warring_states 上,若七支中任何一支在窗內真的 fire ⇒ ★fp 必變
   ★★fp 若【沒變】= 警訊(七支全沒 fire 或搬家沒接上),不是「乾淨」
   ★★★交件時先聲明你走的是哪一種
```
★**`intended-change` 逐項標注預期方向**：10h→3天 ≈ ÷7.2／20h→ ≈ ÷3.6／30h→ ≈ ÷2.4／50h→ ≈ ÷1.44。
★★**實測與 ÷N 差很多的支要逐支給故事** —— **那正是「這一支到底被誰決定」的線索**（有 gate 的支會被 gate 主導，不會等比例降）。

# ★★★③不要做的（★怕你順手）
- ★**不要碰 S3a 那 4 顆真每 tick 站**（`_step_captives`／`_step_cleanup_extinct_teams`／`get_speed_mult`／`get_vision_mult`）——**動它們會混淆 S3 的歸因，那是 S4。**
- ★**不要接 `_decision_crisis` 給這七支**（reviewer 與我都判這個最差：**它是為 `_decide_unified` 設計的窄接口，而 T0 是事件驅動無鐘的泛用機制 ⇒ S4 之後會有兩套做同一件事**）。
- ★**不要改任何行為門檻／人格權重**（本 slice 只動「多久評一次」，不動「評出什麼」）。
- ★**不要搬 (b) 桶那批**（`COLLECT_INTERVAL`／`ORDER_POST_CADENCE`／`PROSPERITY_CADENCE`…）——**只標記。**

# ④閘
`憲法閘 PASS`／`裸 tick 閘 PASS（NEEDS_HUMAN=0）`／`headless Q1 跑完`／★**新增 `class_name` 必先 `--import`**。

★**落地寫 exact path，回信含它。** ★★**數字報之前先實跑一次讀印出的計數，別憑印象。**
