---
from: systems
to: implementer
status: consumed
slice: 備戰 root-check（★先於 #10／#5 退化／#12 三票）
topic: ★藍圖裁:備戰查【先於】三票——若它的 util 被高估,一次解釋三個看起來無關的病;★★而他加了一個我沒想到的對照:三份量測【全來自 warring】(那裡備戰本來就該重要)⇒ 必帶【peaceful 對照腿】:peaceful 也橫掃＝強(b)證據,只 warring 贏＝偏(a);★★★而我先查已把範圍縮小:power 那半【已經是 belief-based 且 fallback 中性】⇒ 若有高估,比較可能在 approach／hostility 或門檻
---

# ★①為什麼先查它（藍圖裁）
```
①#10 承諾再派：★贏家【都是備戰】（0.8046／0.8742；承諾那格 0.0967／0.1527）
②#5 flee 退化：★★→ 備戰，30 日【2108 次】
③#12 乞食輸家：★★★28 次【輸給備戰】
⇒ 三份【獨立】量測、三個不同的病、【同一個贏家】
⇒ ★若 util 被高估 ⇒ 一次解釋三個病；★★而我們正要為那三個病各開一張票
```

# ★★②對照設計（★藍圖加的，本票的核心）
```
★三份量測【全來自 warring 世界】—— 而在那裡備戰【本來就該重要】
⇒ ★★必帶【peaceful 對照腿】：
   ★備戰在 peaceful 也橫掃 ⇒ ★★★強 (b) 證據（util 被高估／applicable 太鬆）
   ★只在 warring 贏      ⇒ ★★偏 (a)（它真的該贏，那三票照原樣開）
⇒ ★★兩種結果都有用 ⇒ 這一查【不會白做】
```

# ★★★③第一問照 util＝真值（藍圖指定）＋ 我先查縮小的範圍
```
第一問：`threat_react` 的組成【是不是 belief-based 真值】
   —— ★高估的常見形態＝【讀了不該讀的】或【忘了衰減】
★★而我先查過，範圍可以縮小：
   `threat_assessment.gd score()`：`raw = approach*1.0 + hostility*1.0 + (power_ratio-1.0)*0.5`
   ★`_power_ratio` ⇒ 讀 `BeliefSystem.best_estimate.population_est`，
     無 belief 時 fallback「視對方等強」⇒ power_ratio=1.0 ⇒ ★★貢獻【中性，不膨脹】
   ★位置：`dist_factor` 走 belief，positionless／過期 ⇒ 0（已有衰減處理）
⇒ ★★★所以【power 與位置那兩半看起來乾淨】——★若有高估，先看 `approach`／`hostility` 與門檻
   （★而這是【縮小範圍】不是【排除】：請你自己驗一遍，我只讀了 score() 的骨架）
```

# ④要的四格
```
①★備戰 util 的【逐項組成】（approach／hostility／power 各貢獻多少）
②★★applicable 命中率：`threat_react >= threat_threshold` 在 warring／peaceful 各多少隊過
③★★★贏率：備戰在候選裡出現幾次／贏幾次 —— warring 與 peaceful 【分開報】
④`fp` 逐位元不變（純觀測）；★母體與命中同印（「備戰贏 0 次」與「沒有隊在候選」長得一樣）
```
