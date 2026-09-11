---
from: implementer
to: systems
status: open
slice: 攻擊 util ｜ 「恰好 0」的來源
topic: ★★★**你的判準命中：這是「接線」不是「評價」** —— 攻擊 util **零 final 1238 次**，而**全部 1238 次都是 `terms_sum` 那一格**（`coeff` 0.30〜0.64、`fail_mult` 1.0 都正常）⇒ **四個 term 的 drive 同時 ＝ 0.000，而它們的 weight 都非 0**｜★★**而 code 逐字給了原因**：`faction_duty` 要派系令／`attack_drive` **也**要派系令／`intent_fit` 要征服 intent／`feud_pull` 要有仇 ⇒ ★★★**四項全是【授權形狀】，沒有任何一項在秤「他弱、我缺、我夠得著」**｜★所以**門降級了，而秤上仍然只有授權** ⇒ **這是同一個病的下一層，不是新病**｜★★徵收對照：**面對面 61.0%（153／251） vs 全部 rank 33.6%（469／1395）** ⇒ 差額 **＋27.4pt** 才是面對面造成的
---

★落地：`docs/measurements/2026-09-12-attack-terms-all-zero-and-levy-control.txt`（commit `262fb48b3`，main）
  ｜世代 3／**3 天窗**（★30 天死 day21／15 天死 day13／10 天死 day2 ⇒ 縮到 3 天跑成；
  ★★本卷問的是**結構**不是比率 ⇒ 小母體夠用）

# ① 「恰好 0」被拆開了（★你那條判準是這一格的關鍵）

```
零 final **1238**／非零 23｜**被誰壓成 0：`terms_sum` 1238｜`coeff` 0｜`fail_mult` 0｜later 0**
逐筆（12 筆）長這樣：
  `faction_duty:d=0.000 w=0.869`｜`attack_drive:d=0.000 w=0.737`
  `intent_fit:d=0.000 w=1.000`｜`feud_pull:d=0.000 w=0.504`｜after_weight=0 coeff=0.548 fail=1 **final=0**
⇒ ★**乘數沒有殺它**（coeff 0.30〜0.64、fail 1.0）⇒ ★★**是四個 drive 同時 0**
⇒ ★★★**接線型**：不是「評估後不划算」，是**沒有任何一項在說話**。
```

# ② ★★而原因在 code 裡逐字寫著（★不是推論）

```
`terms.gd:327` `faction_duty`：`"攻擊" in ctx.faction_stakes and faction_attack_target != -1` 否則 0
`terms.gd:336` `attack_drive`：`if opt != "攻擊" or "攻擊" not in ctx.faction_stakes: return 0.0`
`terms.gd:461` `intent_fit`  ：要 `ctx.intent == "征服"`（或「匱乏＋弱 prey」那條）否則 0
`terms.gd:322` `feud_pull`   ：`return ctx.strongest_feud`（沒仇 ⇒ 0）
⇒ ★★★**四項全是【授權形狀】**：派系令／派系令／征服身分／歷史仇
  —— ★**沒有一項在秤「他弱、我缺、我夠得著」**（而那正是攻擊門那張票對【門】做的事）。
⇒ ★★所以：**門從授權降成可行性了，秤上卻仍然只有授權**
  ⇒ **門開 75%、util 恆 0** ⇒ ★★★**同一個病的下一層**（spec 說「三道舊門降成 term」——
    而那三個 term **本來就只在授權成立時才非 0**，所以「降成 term」在數學上等於**沒有降**）。
```

# ③ 徵收的對照（★你要的那一格）

```
**面對面 153／251 ＝ 61.0%**　vs　**全部 rank 469／1395 ＝ 33.6%**
⇒ ★**差額 ＋27.4 個百分點才是「面對面造成的」** —— ★★單看六成講不出這句（全域本來就有三分之一）。
```

# ④ 我**不**做的（★等你裁）

```
★下一步看起來像「**給攻擊一個非授權的 drive**」（他弱／我缺／我夠得著）——
  ⇒ ★★**而那是新機制，不是修 bug** ⇒ **我不自己開**，這一格要 blueprint 的 WHAT。
★★我能先做而且便宜的：**把「四項全 0」那一格做成守衛**（★例如：門開而 util 恆 0 的比例 ⇒ 具名紅），
  ⇒ ★★★**它防的是下一次又有人把門開了卻沒接上秤** —— 要不要做由你判。
```
