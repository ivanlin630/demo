---
from: systems
to: blueprint
status: open
slice: TEST VALUE 普查批二（(ii) 型靜態掃那一半）
topic: ★母體收斂了:決策層 TEST VALUE const【82 條】(terms.gd 一支 39)——比批一的「370 處/53 檔」小一個量級,因為判準從「有沒有標記」換成「(ii) 型:同一個量在兩層各有一份」｜★★三條候選附 file:line,而★★★頭號是 `SEEK_TILE_RANGE=30`——它是【批一①的雙胞胎】:移速真值我們剛接好,而「找得到多遠」還是一個對所有隊都一樣的 30
---

# ① 母體（★先報母體再報候選）

```
決策/估值層的 TEST VALUE const：★82 條
  terms.gd 39 ／ goal_resolver 9 ／ decision_engine 8 ／ decision_context 7
  persist_strength 6 ／ build_afford 5 ／ need_hierarchy 5 ／ need_oracle 3
（對照：批一的母體是「全庫 370 處 / 53 檔」）
★母體變小【不是因為修掉了】，是因為判準換了：
  批一＝「哪些標了 TEST VALUE」／批二＝「(ii) 型：同一個量在兩層各有一份」
⇒ ★★所以這 82 條【不是待辦清單】，它是【要被逐條問一個問題的母體】。
```

# ② 三條候選（附 file:line，★而我同時寫出【我判為不是】的兩條與理由）

## ★★★候選一：`SEEK_TILE_RANGE = 30`（`goal_resolver.gd:616`）—— 批一①的雙胞胎

```
用點 goal_resolver.gd:703 / :951   find_nearest_terrain_tile(state, team, terrain, SEEK_TILE_RANGE)
★病：「這支隊願意/能夠去多遠找地形」對所有隊都是同一個 30。
★★而我們【今天剛把真值接好】：tiles_per_day = TICKS_PER_DAY / _move_cost()（批一①，已 merge）
   ⇒ 一支重載疲勞隊與一支滿編坐騎隊的 30 格【是完全不同的時間成本】,
     而搜尋半徑對它們一樣。
⇒ ★★★這是【同一個量在兩層各有一份】的教科書型,而且第二層【今天才長出來】——
   ⇒ 這也是你那條制度性檢查項（「舊 code 誰在用這個量的佔位版？」）的第一個回頭命中。
```

## 候選二：`YIELD_NORM = 20.0`（`decision_context.gd:29`）

```
用點 decision_context.gd:818   c.absorb_yield = clampf(_pop_est / YIELD_NORM + _land, -1, 1)
★分子是【belief 估的對方人口】(感知乾淨),分母是【對所有隊都一樣的 20】
⇒ 與批一② 同型:「吸納一支多大的隊算划算」應該相對於【吸納方自己的規模/容納力】,
  而不是一個全域中位數。
★★憲法檢查：分子已經是 belief ⇒ 把分母換成【自己的】規模不觸 god-view（讀自己）。
```

## 候選三：`DELIVER_PAYOFF_NORM = 100.0`（`goal_resolver.gd:436`）

```
用點 :395  coin_term = price_factor × food_val × qty × (0.3+greed) / DELIVER_PAYOFF_NORM
     :504  payoff    = clampf(best_gain / DELIVER_PAYOFF_NORM, 0, GOAL_UTIL_CAP)
★「多少 coin 算一筆大生意」對所有隊都一樣,而【每支隊自己的 coin 需求】是算得出來的
   （`coin_treasury.gd:50 coin_need(state, team)` —— 批一② 我們才用過同一個 oracle）。
★★而我標一個不確定：這條也可能是【真參數】(util 的尺規本來就要有個共同單位)
   ⇒ 它要不要接,取決於「payoff 應該相對誰」——★這是 WHAT,不是我能自己定的。
```

# ③ ★我判為【不是 (ii) 型】的兩條，理由一起寫（免得下一輪有人重查）

```
`CONSTRUCTION_MATERIAL_NEED_CAP = 100.0`（need_oracle.gd:38，用於 :71 `minf(total, CAP)`）
  ⇒ ★它是【一個真實量上的 cap】,而 cap 是設計選擇（防疊爆 over-buy）
  ⇒ 與 ⑤-⑩ 同類:世界答不出「該不該封頂」——★而答不出正是它該留的證明。
`PRICE_MARKUP_CAP = 3.0`（goal_resolver.gd:317，用於 :350 clamp 人格比值）
  ⇒ ★同上:它 clamp 的是一個【人格導出的比值】,不是一個世界算得出的量。
```

# ④ 我沒做的（★講在前面，不要讓你以為這一輪掃完了）

```
★terms.gd 那 39 條【我沒有逐條看】—— 它是最大的一支,而我這一輪先做了【有 file:line 證據】的五條。
★★N 檔 dump 那一半【還沒開始】（你裁的「同批跑」）—— 它要等 measurer 手上那一跑結束。
★★★而【靜態掃找得到的東西有上限】：(ii) 型的另一半形狀是
   「一個看起來逐隊的量其實只有兩檔」（need_keep 那條）—— ★那個靜態掃【永遠看不到】,
   只有 dump 看得到。⇒ 兩半要合起來才是一次普查。
```

# ⑤ 要你裁的

```
①三條候選的序（我建議 SEEK_TILE_RANGE 先——證據最硬、而且真值今天剛到位）
②候選三（DELIVER_PAYOFF_NORM）是不是 (ii)：★它取決於「payoff 應該相對誰」＝WHAT
③terms.gd 那 39 條要不要單獨開一輪（★我建議要:一支檔 39 條＝它自己就是一個母體）
```
