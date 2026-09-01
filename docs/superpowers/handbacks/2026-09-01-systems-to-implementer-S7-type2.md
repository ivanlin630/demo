---
from: systems
to: implementer
status: open
slice: S7-reconcile-type2
tier: probe
topic: ★型②(表 vs code)——★★★而我先自己踩到第一顆,教科書級:docs/tick_parameters.md 整份還寫著 TICKS_PER_DAY=240／TICKS_PER_HOUR=10／TICKS_PER_TURN=24,全是【換根前】的值,連行號都錯(world_state.gd:4 現在是 :12);★★母體我【反過來綁】:從 code 常數出發,文件是被查的一方——因為 code 是引擎決定的,而文件不是
---

# ★①已 grep `known_issues`：**無直接相關條目**
```
:159 提到「意圖帳 material row 待補註」⇒ ★相關族但不是型② 本體
⇒ ★★本票不與它重疊
```

# ★★②第一顆我已經踩到，直接給你當起點
```
docs/tick_parameters.md:3-5,13-15
  「基準：ticks_per_day = 240」／「TICKS_PER_HOUR = 10」／「TICKS_PER_TURN = 24 tick = 1 天」
★而現況：TICKS_PER_HOUR = 60、TICKS_PER_DAY = 1440
★★連 file:line 都錯：寫 `data/world_state.gd:4`，而根常數現在在 :12
⇒ ★★★整份文件停在 S2 換根【之前】
```

# ★★★③母體【反過來綁】—— 這是本票的設計重點
```
✗ 直覺做法：列出 docs 裡所有數值表 ⇒ ★而「文件裡的表」是【文件決定的】,不是引擎決定的
   ⇒ ★★那條路我今天已經走窄過【四次】
✓ ★★★反過來：從【code 常數】出發（引擎側可枚舉），問
   「這顆常數有沒有被任何 doc 提到？doc 說的值跟它一樣嗎？」
⇒ 母體 ＝ code 常數 ∩ doc 提及  —— ★可機械求交集,且 code 是【現況】
```
★**而這樣自然回答「文件過時」** —— ★★**因為比較的基準是 code，不是另一份文件。**

# ★★④修法方向我先裁一件（★免得你去更新那些數字）
```
★tick_parameters.md 那些數字【不要更新成 1440】
⇒ ★★因為三個月後又會爛 —— 這是今天反覆的形狀：改接線,不是改數值
⇒ ★★★正解：把 domain doc 的常數表改成【指 code 為準】（用途／高層模型留下，死數字拿掉）
   —— 而那本來就是 doc-strategy 已裁的 glance-aid 形狀
★本票【只盤不修】：列出「哪些是死數字該指 code」「哪些是真的要更新」,判定我來
```

# ★⑤紀律
```
★母體先寫死再數（★★交集的兩側各自的判準都要寫進落地檔）
★★窮盡不 head 不 glob；★★★而「doc 提及」的匹配法要標明（是搜常數名？還是搜數值？兩者漏的東西不同）
★只盤不修，production 0 行
```
