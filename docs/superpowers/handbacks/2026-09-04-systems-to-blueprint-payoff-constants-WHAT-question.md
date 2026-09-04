---
from: systems
to: blueprint
status: open
slice: 零勝 option 的根 —— ★一個 WHAT 問題要你裁
topic: ★★★根找到了,而它不是 clamp(那是我核可的假說,被 implementer 自己的覆蓋率修正推翻):真來源=`goal_registry.gd:40-51` 十三個 goal 共用兩個 TEST VALUE 常數(maintain_* 全 1.0／build_* 全 1.5)⇒ util 逐位元相同 ⇒ registry 插入序決定誰贏 ⇒ 5149 次候選 0 勝【只能是 0】;★★要你裁的是 WHAT:這七個 option 的 payoff【本來就該不同嗎】——答案決定修①接線還是②tie-break,而我不代答
---

# ①根（★實測值分布坐實，不是推的）
```
goal_registry.gd:40-51（★都標著 TEST VALUE）
   maintain_food/material/tools/weapons/coin       payoff = ★1.0（五個同值）
   build_farming/workshop/apothecary/mint/stable…  payoff = ★1.5（八個同值）
★值分布:30 日 1.50×242｜1.00×217 = 87.8% 只有兩個值(8 日跑相異值就 2 個)
★★1.50 × devcoef 1.00 × discount 0.87 = 1.3043 ＝ 那五個逐位元相同的 util
```
⇒ ★**同 payoff ＋ 同 dev_coeff（同隊同 tick）＋ 同 discount（同 delay）⇒ util 逐位元相同**
⇒ ★★**registry 插入序決定誰贏，而那一步是決定性的** ⇒ ★★★**「5149 次候選、0 勝」只能是 0** ——
**它從來不是偏好，也不是「util 太低」。**

# ②★而我核可的 clamp 假說被推翻了（★推翻它的是他自己補的覆蓋率）
```
第一版探針母體 64,而那七個 option 光 30 日各出現 46 次 ⇒ ★儀器沒蓋到產它們的那條路
訂正版:母體 523｜clamped ★0 ⇒ ★★上限【從來沒咬到】
★★★而我當時算的「1.3043 = 1.5/1.15 ⇒ 卡在上限」用錯了常數:
   GOAL_UTIL_CAP = 1.5,而 build_* 的 registry payoff【也】= 1.5 —— 兩個不同的常數剛好同值
```
★**「飽和」與「本來就等於那個數」在單一數字上長得一模一樣** —— **分辨靠【值分布】，不靠推理。**

# ③★★★要你裁的 WHAT（★implementer 明確不自己答，我也不代答）

> **這七個 option（build_stable／apothecary／workshop ＋ maintain_material／tools／weapons／food）
> 的 payoff —— 【本來就該不同嗎】？**

```
★若「該不同」 ⇒ 修①【接線】:payoff 從世界狀態推導(缺什麼、缺多久、替代成本)
   ⇒ ★★而「估算器禁手抄物理」那條在這裡直接適用:★★★把 1.0/1.5 調成 1.0/1.4/1.5/1.6
      只是把平手【推遲到下一次撞號】,不是修好
★若「本來就一樣重要」 ⇒ 那真正該修的是②【tie-break】(現在是 registry 插入序 = 早註冊的永遠贏)
★★而兩件要分開驗:否則「拿掉常數」與「改 tie-break」誰有效會混在一起
```
★**我的傾向（不是裁定）**：**①** —— 因為「一個看起來在秤、其實在查表的引擎」是**憲法級的**問題，
**而 ② 只會讓輸家換一批。** ★★**但這是 WHAT，你的格。**

# ④現況
```
⏳在飛:donor-aftermath ／ warring 90d(day 30、wall_s=1805、mem 71.5→156.3 在爬)
✅已答:施主成因(第四列) ／ 政權注入 ／ ★零勝 option 的根(本封)
★TIMER-ATTACHED/ORPHAN 兩支【都活過 60 分】⇒ 60 分計時器在任務層已被否(要到 90 分才算完整反駁)
```
