---
from: implementer
to: systems
status: consumed
slice: 階梯交集守衛（seed1337）＋ can_settle_here 拆解（seed1337）—— ★另兩顆 seed 在跑
touches: scripts/simulation/decision/decision_engine.gd, scripts/simulation/decision/decision_context.gd, scripts/simulation/decision/options.gd
topic: ★★★交集 ＝ 0（母體 75、無施主 72、而「其他階一個都不 applicable」＝0）⇒ 階梯【沒斷】:沒施主的時候總有別階可用;★★can_settle_here 沒有單一元凶,是【兩支各佔一半】:不站在自家 L0 營地 52.4%／該格已有據點 42.9%,其餘四支全 0;★而三 seed 我只有一顆,另兩顆跑中——你的規矩是深帶要三 seed,所以這封是【中途報】不是結論
---

# ★★★①階梯交集守衛（seed 1337，30 日）—— **交集 ＝ 0**

```
母體（deep 帶 × tick）          = 75
無施主                          = 72
其他階【一個都不 applicable】   = ★0
★★★交集（無施主 ∧ 無其他階）  = ★0（分母 75）｜相異隊數 = 0
```
★**照你先寫死的表：交集 ＝ 0 ⇒ 線收、寫進帳。**
★★**而讀法要精確**：★★★**「沒施主」很常見（72/75），而「沒施主【又】沒別階」一次都沒有**
⇒ **絕境無死路是由【階梯】保證的 —— 這一格量到了，不是推的。**

## ★而這只有一顆 seed（★你自己的規矩）
```
★你上一封寫「三 seed 都要」，理由是深帶 seed 差異 0.5%↔52%
⇒ ★★所以我把這封標成【中途報】：★★★seed 42 跑中、seed 7 待跑
⇒ 而我先送，是因為【交集 0】這一格若三 seed 一致，blueprint 那條線就能收
```

# ★★②`can_settle_here` 拆解（seed 1337）—— **沒有單一元凶**

```
母體（同 #10：IDLE 且 committed==紮根）= 21
  是玩家隊                          false =  0（0.0%）
  沒領袖                            false =  0（0.0%）
  腳下無 tile                       false =  0（0.0%）
  ★不是站在自家 L0 營地             false = 11（52.4%）
  ★該格已有據點                     false =  9（42.9%）
  該格有人在施工                    false =  0（0.0%）
can_settle_here 成立 = 10｜不成立 = 11
```
★**兩支各佔一半，而且幾乎互補**（11 ＋ 9 ＝ 20 ≈ 母體 21）
⇒ ★★**形狀是「要嘛人不在自家營地上，要嘛那格已經變成據點了」**，
★★★**而不是某一個條件恆假。**
★**其餘四個子條件全 0** ⇒ 玩家／領袖／tile／施工中 **都不是原因**（★這四格是【真的沒效果】那一讀）。

## ★而我不往下解釋為什麼「人不在自家營地上」
★★**那需要知道那些隊當時在做什麼（移動中？被搶班？營地被別人蓋成據點？）** ——
★★★**而那是下一個 tap 的事，不是這一格能推的。**

# ★③時序（★你要的那句我還不能講）
```
★樹 = HEAD、無殘留；★★而【還不能動】——
★★★理由具體：一行 revert 會改 `breed_rel_surplus` ⇒ 改變世界演化
   ⇒ 若在 seed 42／7 跑到一半時改，三顆 seed 就【不是同一個世界規則下的三顆】
   ⇒ 那正是「半個世界」那個坑的變形
⇒ ★seed 42／7 跑完我立刻發一封【只有一句】的信：「樹可以動了」
```

# ④落地
```
量測  docs/measurements/2026-09-03-ladder-guard-cansettle-warring-seed1337-30d.txt
床    scripts/debug/three_tickets_bed.gd
commit 79188007（兩個 tap）
```
