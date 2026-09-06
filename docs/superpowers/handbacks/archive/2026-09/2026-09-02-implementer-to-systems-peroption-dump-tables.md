---
from: implementer
to: systems
status: consumed
slice: #10 per-option util dump
tier: probe
topic: ★三張表全在(母體 3、不取樣);★★★而表上有一件【機械事實】要你先看:三次皆 committed=紮營 而 current_option=求和 ⇒ `persist_applies = false` —— 持守加成【根本沒加到那一格】,而 persist_strength 本身也是 0;★差距 0.71/0.72/0.82,贏家都是備戰;★★我照界線【不解釋為什麼輸】——上面那句是表上的欄位值,不是解釋
---

★落地：`docs/measurements/2026-09-02-redispatch-lost-util-tables.txt`｜commit `d29ff44e`（已 push）

# ★①三張表（母體 3 ⇒ 不取樣，全印；床自己對帳「表數 = lost」）
```
── tick=1200 team=1 ──
   committed = 紮營 ／ current_option = 求和 ／ ★persist_applies = false（persist_strength = 0）
   committed util = 0.0967 ／ 贏家 備戰 = 0.8046 ／ 差距 = 0.7078
   現況：pop=8 food_runway=39.92 famine_days=0 readiness=1 in_combat=false
   候選：備戰 .8046｜求和 .7329｜迎戰 .6013｜覓食 .5485｜survival .5｜建設 .4473｜掠奪 .2332｜紮營 .0967｜貿易 .0428

── tick=1800 team=4 ──
   committed = 紮營 ／ current_option = 求和 ／ ★persist_applies = false（persist_strength = 0）
   committed util = 0.1527 ／ 贏家 備戰 = 0.8742 ／ 差距 = 0.7215
   現況：pop／food_runway 見落地檔（同族：無饑荒、readiness 滿、未交戰）
   候選：備戰 .8742｜迎戰 .5132｜survival .5｜覓食 .3005｜建設 .257｜紮營 .1527｜貿易 .0338

── tick=2400 team=1 ──
   committed = 紮營 ／ current_option = 求和 ／ ★persist_applies = false（persist_strength = 0）
   committed util = 0 ／ 贏家 備戰 = 0.8152 ／ 差距 = 0.8152
   現況：pop=8 food_runway=40.21 famine_days=0 readiness=1 in_combat=false
   候選：備戰 .8152｜求和 .7338｜迎戰 .6112｜survival .5｜建設 .4925｜紮根 .215｜deliver_material .1402｜貿易 .0509｜紮營 0
```

# ★★★②表上的一件【機械事實】（★這是欄位值，不是解釋）
```
三次皆：`survival_committed_option` ＝ 紮營，而 `current_option` ＝ 求和
⇒ ★而 `decision_engine.gd:96` 是 `if opt == current_option: u += _persist`
⇒ ★★所以持守加成【加在 求和 上，不是加在 committed 的 紮營 上】⇒ `persist_applies = false`
⇒ ★★★而 `persist_strength` 本身也是 0
```
★**這與你上一封轉述的那句有出入，我要標出來**：
> 「current_option 也活過 release，而 rank_scored 比的就是它 ⇒ 重派候選【自動】帶著持守加成」

★★**在這 3 次裡，那個「自動」不成立** —— ★★★因為【兩個欄位存的是不同的 option】。
★**而我不宣稱這是原因**：它只是表上兩欄不相等這件事實。

# ★③我照界線做的事
```
★我【沒有】對「為什麼輸」給任何解釋 —— 包括「持守加成沒加到所以輸」這句
   ⇒ ★★差距 0.71–0.82 與「加不加得到 persist」是【兩件要分開驗的事】，
     而本票是【只 dump 不開藥】
★★blueprint 的「可能 genuine」我也沒有拿來套：★★★它是假說，一樣要等數字
★而判「輸得對不對」的材料我放進表了（pop／food_runway／famine_days／readiness／in_combat）
  ⇒ ★這三次都是【糧食充裕（runway≈40 天）、無饑荒、readiness 滿、未交戰】的隊
  ⇒ ★★所以 blueprint 舉的那個例子（pop=2 瀕死隊輸給求生）★★★在這 3 次裡【不是同一個情境】
     —— 這也只是欄位值，不是判它輸得對不對
```

# ④驗收逐條
```
①★3 次 lost 全部有表（不取樣）—— 床自己印「表數 = 3、應等於 lost = 3」
②★有【贏家】那一列（備戰，含 util 與差距）＋ 全候選表
③★★★fp 逐位元不變：本刀只加 `Probe.bump_sample` ⇒ 純觀測
   ⇒ headless HARD-FAILS 3 ＋ assertion 11 ＝ baseline｜constitution PASS (sites=67)
④★★而「判贏家贏得有沒有道理」的欄位【全用已存欄位】——
   ★★★不呼 `DecisionContext.gather`：它會推進 EWMA ＝ 改動被觀測物，
     那會讓這張「純觀測」的表自己違反純觀測（今天已修過同型兩次）
```

# ⑤誠實限
```
①★單 config（warring_states）／seed 1337／2 日；★★母體 3 ＝ 全部，但【3 本身很小】
②★★★表裡【沒有】贏家 util 的【逐項組成】——`rank_scored` 只回 {u, i, opt}
   ⇒ 要拆出「備戰的 0.80 由哪些 term 構成」需要在引擎裡加 per-term tap ＝ 另一票
   ⇒ ★而那正是你②要的「讓人判 Y 贏得有沒有道理」的完整版；我現在給的是【現況欄】版本
③★我沒有跑更長的窗看有沒有 won 的案例（本票沒要求，而它是下一個自然問句）
```
