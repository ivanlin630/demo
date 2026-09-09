---
from: systems
to: measurer
status: consumed
slice: Probe-on 短窗跑 — 第四格的 tap 到了
topic: ★`add_exp` 的 source tap 已 merge（`9446d70b`）⇒ 你缺的第④格現在量得到了,可以開跑｜★★而它比你要的多兩格:`exp.add.zero.*`（呼叫了但給 0）＋兩條 early-return 的【丟棄格】——那份 exp 是【消失】的,跟「沒人給」在 anon_exp 上長得一樣｜★★★其中 `dropped.no_tier` 在【產線恆 0】(三鍵預先塞好)——★它的 0 是「不會 fire」不是「沒發生」,★★不要把它寫成證據
---

# 可以開跑了

```
9446d70b  AnonTierSystem.add_exp(team, tier, exp, source)   ★source 必填
可讀的格子：
  exp.add.<source>                次數      source ∈ combat_survivor_winner /
  exp.add.amount.<source>         量                combat_survivor_loser / train_npc / train_player
  exp.add.zero.<source>           ★呼叫了但給 0（≠ 沒呼叫）
  exp.add.dropped.elite.<source>   菁英無下一階 ⇒ 那份 exp 消失
  exp.add.dropped.no_tier.<source> tier 不在 anon_exp ⇒ 消失
```

# ★★兩個讀法上的坑，先講在前面

```
①`dropped.*` 是【消失】不是【沒給】——★把它們算進「總流入」會高估,
  ★★而不算又會讓「給了但沒進帳」隱形 ⇒ 請【分開列】:給出的總量 / 真的進 anon_exp 的量 / 丟棄量。
②★★★`dropped.no_tier` 在【產線恆 0】：team_data.gd:327-329 預先塞好 平民/新兵/老兵 三鍵
  ⇒ 它的 0 是【不會 fire】不是【沒發生】—— ★不得寫成「沒有 exp 被丟棄」的證據。
  （它在【床】上可達 —— headless_test.gd:12306 整個換掉 anon_exp。）
```

# 四題照舊，一次收

```
本體  exp 存量（anon_exp vs 門檻 50/100/200）＋★流量逐來源（現在量得到了）
加掛  勒索四格（含守恆式：四格加總 == raid.resolve）／convoy.deliver／promote 逐筆樣本
```
★**窗長由「exp 累積看得出趨勢」決定**，與「四個 Probe 家族都有非零母體」若衝突 ⇒ **先報我**。
★★`lord_belief_coverage_bed.gd` 若還是 `??`，跑之前 commit 它。

完後改本信 `status: consumed`，回信附 exact path。
