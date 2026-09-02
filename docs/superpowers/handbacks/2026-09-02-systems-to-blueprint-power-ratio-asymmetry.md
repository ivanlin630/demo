---
from: systems
to: blueprint
status: open
slice: 備戰 root-check 的真根
topic: ★★★備戰 root-check 釘到底了,而答案不是「util 高估」也不是「applicable 太鬆」——是【輸入被系統性膨脹】:`_power_ratio` 對方用手抄常數 0.3、自己用真值(實測 combat 平均 0.1)⇒ ratio 恆 ≈3;★self combat < 0.3 的比例＝【100.0%】(母體 51.5 萬／1.07 萬,兩 config 皆然);★★而答案就在同一支函式裡:人口那一維的 fallback 是【自己】,技能那一維是【常數】——同函式兩維不一致
---

# ★①釘死的過程（★三步，每步都是量測）
```
①我縮小範圍：「power 那半已 belief-based 且 fallback 中性」⇒ ★★方向【反了】
②implementer 實測：power 平均 3.6410(warring)／0.9882(peaceful)，approach −0.03／hostility 0.51
   ⇒ ★★★power【主導】raw
③peaceful 那腿釘死：pop_est 5.99 vs self_pop 6.00（人口幾乎相等）、★ratio 平均 2.997 ≈ 0.3/0.1
   ⇒ ★★power 項【整個】來自常數落差 —— 不是 belief、不是情報
```
★**而你加的 peaceful 對照腿是這條線的關鍵**：★★**在 warring 看不出來**（人口差異會混進去），
★★★**是 peaceful 的「人口幾乎相等」讓那個 3 倍【無處可躲】。**

# ★★②真根（code）
```
threat_assessment.gd::_power_ratio
   other_power = pop_est * 0.3          ←★手抄常數（註解：「無 combat skill in intel → 0.3 baseline」）
   self_power  = _team_power(self_team) ←★★真值
★★★而同一支函式裡：pop_est 的 fallback ＝ `self_team.population`
   （註解原文「鏡射 diplomatic _get_pop_est fallback=self_pop 模式」）
⇒ ★人口維【用自己當先驗】、技能維【用手抄常數】—— ★★同函式內兩維不一致
```

# ★★★③所以先前「偏 (a)」的結論要往下修一層
```
★peaceful 沒橫掃（過門檻 20.0% vs 82.5%）⇒ 我們判「備戰真的該贏」＝ (a)
★★而現在知道：它贏是因為【每一隊都把每一隊看成約 3 倍強】
⇒ ★★★這不是 (a)「它該贏」，也不是 (b)「util 被高估」—— 是【輸入被系統性膨脹】
   ⇒ util 沒錯、applicable 沒錯，★而餵給它們的 threat_react 是膨脹的
```

# ④修法方向（★我不裁，但要指出既有立法直接管到它）
> memory `feedback_no_handcopied_physics`（**用戶立法**）：估值必 **(a) 物理同源推導** 或 **(b) 讀自身狀態**；
> **血統② 手抄物理常數全禁**；**修法形狀＝改接線非改數值**（「把 2 改 5，三個月後又爛」）。

★**所以不是把 0.3 改成 0.1** —— ★★**是讓技能維跟人口維走同一個 fallback（以自己為先驗）**
⇒ ratio ≈ 1（中性），★★★**而那正是那行註解自己宣稱的意思（「視對方等強」）——它只等在人口那一維。**
★**已立條目**（狀態：已知未修 ｜ 回訪：到期 token）。★★**而我明寫「不該夾在別的刀裡」：它會改變【所有】威脅評估。**

# ⑤而那三票（#10／#5 退化／#12）怎麼辦
★**建議：等這條裁完再開** —— ★★**因為三票的「輸給備戰」可能【整批】隨這條改變。**
★★★**而若你要先開，那也要知道：我們是在一個【威脅被系統性放大 3 倍】的世界裡量它們。**
