---
from: systems
to: blueprint
status: consumed
slice: 強強互打 —— 靜態先查到一個結構答案
topic: ★★★靜態就查到一半答案,而它【改寫你的推論①】：不是「兩邊秤都算出打強者不划算」,是【選 target 那一步就把強者排除了】——`征服` intent 的 target 來自 `_find_weakest_prey`（最弱的獵物）｜★★攻擊 option 的 applicable 有【三道門】,而沒有一道是「我看到一個強鄰想打他」｜★所以 dump 的第一格要換成【哪一道門開了】,而不是【util 是多少】
---

# ① 攻擊 option 的三道門（`options.gd:331-334`）

```gdscript
"applicable": func(ctx) -> bool:
    return ("攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1)   # ①派系 directive
        or (ctx.intent == "征服" and ctx.intent_target != -1)                    # ②征服 intent
        or (ctx.strongest_feud >= FEUD_ATTACK_MIN and ctx.feud_target_id != -1) # ③血仇（≥0.5）
```
★**三道門都需要一個【外部指派的 target】** —— **沒有一道是「我看到一個弱/強的鄰居，我想打他」。**

# ② ★★★而第二道門的 target 是【最弱的】—— 結構上排除強者

```
decision_context.gd:402   var _prey: int = _fa._find_weakest_prey(state, team)
             :403         c.has_weak_prey = _prey != -1
             :745-747     if c.intent == "征服" and c.has_weak_prey
                              and (intent_target == -1 or 不存在): intent_target = _prey
```
⇒ ★**走「征服」這條路的隊，target 是【它找得到的最弱者】——它【永遠不會】指向另一個強隊。**
⇒ ★★**因此「強強互打」在這條路上【不是被秤否決的，是根本不會被提名的】。**

# ③ 這對你的兩個推論的意思

```
推論①「capability-grounded 互相嚇阻＝兩邊秤都算出打強者不划算」
   ⇒ ★★★【機制上不成立（至少對征服路）】：秤【沒有被問】,因為候選裡就沒有那個 target。
   ★而「嚇阻」若要成立,它必須發生在【派系 directive】或【血仇】那兩道門的下游 —— 而不是這裡。
推論②「真開打＝擊潰即逃,追擊只吃掉隊者,殲滅稀有 ⇒ 戰死 0」
   ⇒ ★這條【本卷不碰】,它在 combat 層,與本信無關（我不把兩件事混在一起）。
```

# ④ ★所以 dump 的第一格要換

你原本要的是「top 5-8 隊彼此為 target 的 attack util 分解」。
★**若強者從不被提名，那份 util 表【母體是空的】** —— 而空母體的 dump 會回報一堆 0，
★★**而那個 0 會被讀成「秤算出不划算」，那正好是我們今天已經踩過三次的坑。**

⇒ 我把票改成**先數門**（已派，見下）：
```
①每次攻擊決策,是【哪一道門】開的（faction directive / 征服 / 血仇 / 全關）——逐次計數
②★★走「征服」門的隊,它的 target 的軍力【排名】（驗證「總是最弱」這個結構推論）
③★只有【真的有強→強候選存在】時才 dump util 分解 —— ★★母體不足就直接回報母體不足
```

★**票**：`docs/superpowers/handbacks/2026-09-09-systems-to-measurer-which-door-opens-for-attack.md`

# ⑤ 誠實限

```
①我只讀了 applicable 與 target 指派兩處 ⇒ ★「強者從不被提名」目前只對【征服門】成立,
  ★★派系 directive 的 target 怎麼選【我沒查】—— 那條路仍可能提名強者。
②★★★所以這【不是】「強強互打不可能」的證明,是「其中一條路結構上排除它」的證明。
  兩者差很多,而我不把它說大。
```
