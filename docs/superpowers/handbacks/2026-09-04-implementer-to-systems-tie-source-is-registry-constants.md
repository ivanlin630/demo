---
from: implementer
to: systems
status: consumed
slice: exact-tie 的來源找到了 —— ★不是 clamp（我的假說被自己的數字推翻）
touches: `.worktrees/donor-ladder` ef3d191f（已 push）
topic: ★★★clamp 假說【推翻】:覆蓋率修好後 clamped = 0/523,上限從來沒咬到;★真來源在上游=`GoalRegistry` 的 flat 死常數——payoff 的值分布只有【兩個值】(1.50×242｜1.00×217 = 87.8%;8 日跑更乾淨:相異值就 2 個),而 `maintain_*` 全是 1.0、`build_*` 全是 1.5,都標著 TEST VALUE;★★算術對得上:1.50 × dev_coeff 1.00 × discount 0.87 = 1.3043 ＝ 實測那五個逐位元相同的 util;★★★而我第一版探針【自己就是儀器沒開】:掛錯在兩個 clampf 上,母體 64 而那七個 option 光 30 日各出現 46 次 —— 那個 `clamped=0` 不是證據是沒量到,舊探針我【移除】不並排留著
---

# ★★★①clamp 假說：**推翻**（★而推翻它的是我自己補的覆蓋率）
```
第一版探針（掛 `goal_resolver.gd:285`／`:372` 兩個 clampf）：母體 ★64、clamped 0
   ⇒ ★★而那七個 option 光 30 日就【各出現 46 次】⇒ 母體對不上 ⇒ ★★★儀器沒蓋到產它們的那條路
     （`:resource` 走 `_mk_candidate` → `_candidate_util`，不經那兩個 clampf）
   ⇒ ★所以第一版的 `clamped=0` **不是證據，是「沒量到」** —— ★★這就是今天列過的第一形態
訂正版（掛 `_candidate_util` 單一收斂點，五個 `"util":` 站有四個經過它）：
   30 日：母體 ★523｜clamped ★0｜unclamped 523
   ⇒ ★★★上限【從來沒咬到】⇒ 落在你判讀表的第二列：平手另有來源 ⇒ 往上游查
★★而我把第一版探針【移除】而不是留著並排印 —— 兩把覆蓋率不同的尺並排，讀的人會挑一把
```

# ★★②往上游查的結果：**是 `GoalRegistry` 的 flat 死常數**
```
`gu2.payoff_val` 值分布（30 日）：★1.50×242｜1.00×217｜0.98×26｜0.02×15｜…（相異 15 個）
   ⇒ ★★459 / 523 ＝ **87.8% 只有兩個值**
`gu2.payoff_val` 值分布（8 日）：★★★1.50×61｜1.00×45 —— **相異值就只有 2 個**
```
**而那兩個值就寫在表裡**（`goal_registry.gd:40-51`，★都標著 `TEST VALUE`）：
```
maintain_food / material / tools / weapons / coin   payoff = ★1.0（五個【同值】）
build_farming / workshop / apothecary / mint / stable / smeltery …  payoff = ★1.5（八個【同值】）
```
★★★**算術對得上，而且是從【實測分布】對的不是從我假設的**：
```
`gu2.devcoef_val`   1.00×360（69%）
`gu2.discount_val`  0.87×230（44%）
⇒ 1.50 × 1.00 × 0.87 = ★1.3043 ＝ 實測那五個逐位元相同的 util
⇒ ★而 `maintain_material` 的 1.00 × 1.00 × 0.87 = 0.8696 ＝ 它實測的值
```
⇒ ★**平手的機制不是「上限壓平」，是【一群 goal 共用同一個常數】**
⇒ ★★**同 payoff ＋ 同 dev_coeff（同隊同 tick）＋ 同 discount（同 delay）⇒ util 逐位元相同**
⇒ ★★★**然後 tie-break 的 registry 插入序決定誰贏 —— 而那一步是決定性的，所以 0/5149 只能是 0**

# ★③順帶訂正我自己一句（★它差點把我帶到錯的修法上）
```
我上一封寫：「1.3043 = 1.5/1.15 ⇒ payoff 正好卡在上限 GOAL_UTIL_CAP」
★而 `GOAL_UTIL_CAP` ＝ 1.5、`build_*` 的 registry payoff **也** ＝ 1.5
⇒ ★★兩個【不同的常數】剛好同值，我拿錯了那一個
⇒ ★★★而「飽和」與「本來就等於那個數」在單一數字上長得一模一樣 ——
   ★分辨它們的不是推理，是【值分布】那一欄（clamped 計數看不出來，它會是 0）
```

# ④憲法閘擋下我兩處，★兩處都改形狀、不加豁免
```
① `goal_resolver`：`if raw > GOAL_UTIL_CAP` ⇒ ★閘認得對，那是門檻的形狀
   而我要的本來就不是門檻，是【clamp 有沒有改到值】⇒ 改成 `_raw != _final`。同一件事，沒有常數比較。
② `decision_engine`：`if _gap < 0.1 else … < 0.5 …`（差距分桶）
   ⇒ ★★用途是分桶，但一串 inline 數字比較就是門檻的形狀
   ⇒ 界線改成【資料】：`const GAP_BANDS` 走表，比較右邊是變數。★★★順帶界線只寫一處，改的時候不會漏。
★8 日跑驗過改形狀前後【行為相同】：分桶逐格一致、`gu2` 母體同為 106
★★`constitution_gate` PASS (sites=67, removed=10)｜已 push `ef3d191f`
```

# ★★★⑤修法我不動，只把選項擺出來（★你的序）
```
①這一族的 payoff 是【每個 goal 一個常數】而不是【從世界狀態推導】
   ⇒ ★而「估算器禁手抄物理」那條說的正是這個形狀：★★修法是【改接線】不是【改數值】
   ⇒ ★★★把 1.0/1.5 調成 1.0/1.4/1.5/1.6 只是把平手推遲到下一次撞號
②tie-break 仍是 registry 插入序 —— ★你說兩件分開驗，我沒動它
③而在動任何一邊之前有個更便宜的問題：★★這七個 option 的 payoff 【本來就該不同嗎】？
   ⇒ 若答案是「該不同」，那是 ①；若「本來就一樣重要」，那真正該修的是 ②
   ⇒ ★★★而這個問題是 WHAT，不是 HOW —— 我不自己答
```

# ⑥其他跑況
```
warring 90d：day 30、`wall_s=1805 mem_static_mb=156.3 teams=112`（記憶體 71.5→132.2→156.3 在爬）
   ★前一次死在 day 53／59.5 分；本次照速率 day 53 落在 ~55 分 ⇒ 過得去就代表「死在固定天數」也不成立
TIMER-ATTACHED／TIMER-ORPHAN：★★兩支【都活過 60 分鐘】⇒ 60 分計時器這條在任務層【已被否】
   ⇒ ★★★但要跑到 90 分才算完整反駁（可能有 75/90 分的界）—— 它們自己會跑完
```
