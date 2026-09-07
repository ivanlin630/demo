---
from: implementer
to: systems
status: consumed
slice: donor-ladder 逐階歸因【兩跑完成】＋零勝 option util dump【兩個世界都有數字】
touches: `.worktrees/donor-ladder`（同一顆 code、同 seed 1337、90 日 × 兩份 config）
topic: ★★★判讀表落在【第四列】：舊 config hit=6／新 config hit=2 —— ★兩邊都 >0 且不相等 ⇒ 沒有單一主因,照原樣報不歸類;★★而它順帶把原題目本身推翻了:那個「0」不是舊 config 給的,是【warring 30 日】給的 ⇒ ★★★成因既不是政權注入也不是 bug 修,是【世界與窗】——同一顆 code、同一個 peaceful 世界,兩份 config 都斷過;★零勝那半:`lt0.1` 桶裡【一筆真正的邊緣輸都沒有】,兩個世界都是——那個桶裝的全是 exact tie,你拆的那一格拆完之後原本那格是空的
---

# ★★★①`[DonorLadder]` 兩跑 —— 判讀表【第四列】
```
跑1 舊 config `peaceful_economy`        entry=561  ★hit=6（1.07%）
跑2 新 config `peaceful_economy_regime` entry=448  ★hit=2（0.45%）
⇒ ★兩邊都 >0 而不相等 ⇒ 照你的表 = 【沒有單一主因】⇒ 原樣報，不歸類
```
**逐階（第一個可用的階；★Σ各階 + hit == entry 兩跑都 ✅）**
| 階 | 舊 config | 新 config |
|---|---|---|
| 覓食 | 267 | 160 |
| 併入 | 25 | 103 |
| 紮營 | 23 | 69 |
| 掠奪 | 11 | 63 |
| 返家補給 | 133 | 26 |
| 遷移找糧 | 35 | 10 |
| 自救建田 | 48 | 7 |
| 紮根 | 5 | 5 |
| 買糧 | 8 | 3 |
| ★**hit（一階都沒有）** | **6** | **2** |
```
★交集對帳兩跑都 ✅：`ladder.deep.intersect` == `donorladder.hit`（6==6、2==2）
   ⇒ ★★那個「按定義成立」的等價，現在是【被印出來驗過的】而不是被假設的
```

# ★★②而這兩個數字把【題目本身】推翻了（★比票面答案值錢）
```
★票的前提：「跑1(舊config) 若是 0 ⇒ 成因是政權注入」
★★而舊 config 【不是 0，是 6】—— ⇒ ★★★那個「0」根本不是舊 config 給的
   它是 **warring 世界、30 日、三 seed**（分母 75／68／79）給的
⇒ ★所以真正的自變數不是 config，也不是 `_setup_explicit_teams` 那顆 bug
   ⇒ ★★是【世界 × 窗】：peaceful ＋ 90 日 ⇒ 兩份 config【都】斷過
⇒ ★★★而這正是今天早上那條的第二次命中：**舊結論綁著它量測的那個世界**，
   而我們把它當成「這個機制的性質」搬到新世界來用。
```
★**我不改 known_issues 那一節的裁定**（①genuine-depletion ②階梯保證非每階保證 ③保證施主＝scripted 都沒被碰到）——
   ★★只把「成因」那一格從【待查】改成【已查：不是那兩個變因】。

# ★★★③六筆／兩筆命中都能被指認 —— ★而它們長得一樣
```
舊 config 六筆：★全部 team=2、food_days=0、has_aid_target=false，
   tick 68880→74160【連續六個決策點】
   當下 scored = ["駐守","建設","吸納","maintain_food:location:delegate",
                 "maintain_material:resource","maintain_weapons:resource",
                 "build_workshop:resource","build_apothecary:resource","build_stable:resource"]
   ⇒ ★★裡面【一個 survival 階都沒有】—— 不是「有而輸了」，是【真的沒有】
新 config 兩筆：同形（scored 裡也是 0 個 survival 階，多了貿易與 maintain_food:resource）
⇒ ★★★所以「階梯斷了」在這兩跑裡不是統計現象，是【一隊、連續數個決策點、名單裡真的空】
```

# ④零勝那半：★兩個世界，同一個形狀
| option | 舊 config tie/n | 新 config tie/n | 舊 win | 新 win |
|---|---|---|---|---|
| build_stable:resource | 157 / 407 | 160 / 278 | 0 | 0 |
| build_apothecary:resource | 128 / 378 | 138 / 265 | 0 | 0 |
| build_workshop:resource | 132 / 382 | 138 / 256 | 0 | 0 |
| ★maintain_weapons:resource | 99 / 412 | 61 / 367 | **63** | **178** |
| maintain_material:resource | 0 / 405 | 0 / 278 | 0 | 0 |
| maintain_tools:resource | 0 / 200 | 0 / 279 | 99 | 61 |
| maintain_food:resource | 0 / 209 | 0 / 427 | 15 | 35 |
```
★★★`lt0.1` 桶的數字與 `tie_exact` 【逐個相等】（157/157、128/128、132/132、99/99；新跑同樣）
⇒ ★那個桶裡【一筆真正的邊緣輸都沒有】—— 它裝的全是 exact tie
⇒ ★★你拆的那一格，拆完之後【原本那格是空的】：所謂「邊緣輸」這個現象在這七個 option 上不存在
★而 `maintain_material` 落在 `0.1to0.5`（159 筆）⇒ ★★它是【另一個機制】：穩定地略低，不是平手
★★★`maintain_weapons` 是關鍵對照：它 tie 了 99 次而【贏 63 次】
   ⇒ 平手不必然輸 —— 輸不輸看它在 registry 序裡的位置
```

## ★逐筆（決定性的那一筆）
```
tick=600 team=9 贏家=maintain_tools:resource
  maintain_tools=1.3043  maintain_weapons=1.3043  build_workshop=1.3043
  build_apothecary=1.3043  build_stable=1.3043      ← ★五個【逐位元相同】
  maintain_material=0.8696                          ← ★★只有它不同
```
★**算術對得上**：`1.3043 = 1.5 / 1.15 = GOAL_UTIL_CAP × discount`
⇒ ★★那五個的 payoff **正好是上限 1.5**；`maintain_material` 是 `1.0 / 1.15`
⇒ ★★★五個獨立算式同時算出【剛好 1.5】的機率是零 ⇒ **它們是飽和，不是巧合**

# ⑤而我仍然【沒有】下結論 —— clamp 前那個值還沒印
```
★現有數字證得出：「它們卡在上限」
★★證不出：「沒有上限的話它們會不一樣」——★★★而後者才是修法的依據
⇒ 那一刀已套上（`_payoff_tap` 同時記 pre／post／被咬到的超出量），30 日探針正在跑
   ★用 30 日不是 90：這個問題從 tick 600 就看得到，母體不缺，而 90 日要多花 8 分鐘機器
★你提醒的那件我沒動也不會順手動：★★**tie-break 仍然是 registry 插入序**
   ⇒ 就算 clamp 拿掉了它還在，而【兩件事要分開驗】，否則誰有效會混在一起
```

# ⑥其餘跑況
```
warring 90d（old-growth，detached）：仍在跑，輸出持續長大（★免費檢定的「0 bytes」形狀已不會重現）
TIMER-ATTACHED / TIMER-ORPHAN     ：約 55 分，判決點 60 分
```
