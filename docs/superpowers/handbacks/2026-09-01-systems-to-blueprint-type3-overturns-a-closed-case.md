---
from: systems
to: blueprint
status: open
slice: S7-type3
topic: ★★★型③第一輪就推翻了一條【已經銷案】的病(病4),而推翻的依據是 registry;當初銷案的依據是【code 註解自述】——註解說謊;★★世界面的含意:同一座工坊,隊在遠區時每日真產量只有近區的 1/10(★推導,待量測坐實);★★★而補回機制【存在、被別人用了、它沒用】—— 同張 registry 上四個系統都是 teams_cadence
---

# ★①型③第一輪：四個真命中，而最重的一個推翻了銷案
```
執行端 sim_runner.gd:164   {"name":"manufacture", "lod": LOD_BOTH, "shape":"teams"}
   ★LOD_BOTH ⇒ far 隊在 far pass 也跑（每 FAR_ZONE_INTERVAL 600 tick ⇒ 2.4 次/日）
   ★★shape "teams"（不是 "teams_cadence"）⇒ 呼叫時不傳 cadence ⇒ 間隔變長【不補回】
估算端 manufacturing_system.gd:78-81 註解自述「產線在 NEAR pass ⇒ 24 次/日」
⇒ ★估算對 far 隊高估 10×；★★世界面：同一座工坊在遠區每日真產量約近區的 1/10
```
★★★**而這不是估算誤差 —— 是【世界本身的行為隨 LOD 改變】**，那正是 LOD 率等價原則要禁的。

## ★★對照組坐實它是【漏做】不是【設計】
```
同一張 registry：collect / consumption / fatigue / reactions ★四個都是 teams_cadence
而 reactions 更在 sim_runner.gd:515-517 明寫「far pass 用 trials 補回被跳過的窗次」
⇒ ★★★補回機制【存在、被別人用了、manufacture 沒用】
★對照組②：outpost_tick 是 LOD_NEAR，且它多帶一顆 _outpost_tick_runs_in_near_pass() 假設告警
   ⇒ ★★manufacturing 沒有那顆 ⇒ 它的假設壞了也不會叫
```

# ★★★②要你知道的是這個方向：**銷案比未修更危險**
```
病4 在 2026-09-01 的重盤裡被標成【healed 銷案】
★理由是 manufacturing_system.gd:78-81 的【註解自述】「產線只在 NEAR pass ⇒ 沒有兩條路」
⇒ ★★而註解說謊，registry 才是真的
⇒ ★★★銷案之後它從清單上消失 —— 【沒有人會再看它】
```
★**我已把 §4 的「病4 healed」改成【銷案撤回】並寫明撤回理由。**
★★**而通則是**：**「已修/不適用」這一欄，跟「待修」那一欄一樣需要證據** ——
★★★**而我們當時接受的證據是【被查對象自己的註解】。**

# ★③另外三個命中（★摘要，細節在 `docs/measurements/` 型③落地檔）
```
★食物 burn：執行端算 population + minor_population + 馬匹草料；
   估算端 55 處裡只有 4 處含 minor、★★馬匹草料【沒有任何估算端算】
   ⇒ 隊以為自己撐得比實際久（★誠實標：51 是【上界】不是 51 個 bug，逐條分類未做）
★移動速度：執行端 base×地形×分段疲勞×超載×車輛+clamp；
   估算端三個獨立來源，共用的只有一顆常數，★其中一個就是病3 手寫 2.0（物理真值 6.0）
★「查不到執行端」欄 = 0 列 ⇒ ★★implementer 自己標成【判準的限制】不是好消息
   （母體只收「名字像估算」的函式 ⇒ 名字不像的沒進母體）—— ★★★他標得對
```

# ★④我要做的（★不先派修，先坐實）
```
①★manufacturing 那個 1/10 是【推導】不是量測 ⇒ 派 measurer 用一支床坐實
   （同一座工坊、同一組人，near vs far 各跑 N 日比產量）
   ★★理由：我今天已經被「推理 ≠ 量測」打過一次，而這條的世界影響很大
②★坐實後才開修票（shape "teams" → "teams_cadence"）
   ⇒ ★★而那是【intended-change 級】的世界變動（遠區產量 ×10）⇒ 到時要你裁
③排序：measurer 現在在跑 S6 after 腿 ⇒ 這支排它之後
```
