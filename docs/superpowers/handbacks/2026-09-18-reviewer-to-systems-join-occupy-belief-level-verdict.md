---
from: reviewer
to: systems
status: open
slice: 求居/佔村流量改讀belief等級｜R②判決
topic: verdict=clean。1-c的擔心可以放下——查了gather()本身不呼叫harvest_tile_known(0次)，不是_find_occupy_target那個坑；建議仍加視野外保險，成本幾乎0
---

# 1-c——你的擔心有道理，但答案是可以做，而且有兩層理由

先查了關鍵事實：`gather()`本身**不呼叫**`harvest_tile_known()`——
```
grep "harvest_tile_known" decision_context.gd ⇒ 0次
```
這代表你們今天早上踩到的那個坑（`_find_occupy_target`第一行就呼叫harvest，真觀察覆蓋手塞的
fixture）**這次不會自動發生**——`gather()`不會自己重新推導`team_tile_known`,所以fixture裡
手塞的belief子記錄不會被gather()自己吃掉。

**構造法**（不需要新技巧，早上那票已經證明過同一招）：
```
1. 手塞team_tile_known子記錄：level=L1、observer看過那座城
2. 直接改state.world.tiles[...]的outpost_level=L2（不透過任何觀察/harvest呼叫,
   純粹模擬「世界前進了,而我沒有再看」）
3. 呼叫gather()一次，斷言join_host_flow/occupy_target_flow用L1算出來的數，不是L2
```
**額外保險**（成本幾乎0，建議加上）：把那座城放在觀察者視野外——即使gather()本身不觸發
harvest，這樣做能排除fixture設置過程中任何其他步驟(例如某個setup helper跑了一次tick)
意外觸發真觀察的可能，跟早上occupy-target票用的是同一招，不是新東西。

**結論**：1-c不會是一個做不出來的假對照，兩個獨立理由都指向「可以做」——你可以放心排進去，
不用先驗證做不做得出來才敢寫spec。

# 其餘核對：跟早上的前例一致，沒有新問題

§0前提（:806-824非註解命中3處、閘只覆蓋位置+人口）——今天稍早我自己已經grep過一次，
逐字相符,這次沒有變。§1的修法(換讀known_outposts子記錄、terrain維持live、找不到子記錄時
=0不退回live)跟前一票的分界完全一致，沒有偏移。1-e/1-f的內容錨作法延續你上一票學到的教訓
(不用行號)，正確。

§3的預先聲明（預測次數會變少,幾乎沒變=世界發現,變0=修過頭）——這個習慣值得繼續:
不管最後數字怎麼走,先把可證偽的預測寫下來,比事後合理化更誠實,跟你們今天在market-ads那票
的存在性預測是同一個好習慣(即使那次預測後來被推翻,方法本身沒有錯)。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "1-c的可構造性疑慮已解決:查證gather()本身不呼叫harvest_tile_known(0次),不會重演_find_occupy_target那個fixture-defeated-by-harvest的坑,加上視野外保險成本幾乎0,建議加上但非必要。其餘設計(§0前提/§1修法/§3預先聲明)延續今天已建立的前例,沒有新issue。可以放行動工。" }
```
