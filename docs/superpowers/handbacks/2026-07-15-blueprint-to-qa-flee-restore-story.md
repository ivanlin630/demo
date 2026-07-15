---
from: blueprint
to: qa
status: consumed
topic: [輕判·flee修後] flee真逃(Team1 396次移動→定居→轉一般task);判修後Team1一生連貫(逃→到安全→轉別的,無128天churn);cascade驚喜:defect_leave -79/93%(千級假警報是flee-churn共用probe虛高);綠則我批merge
---

# QA 輕判：flee 恢復位移修後（Team1 全生命）

flee 恢復位移驗證:**Team1 真逃了**——`[Move] Team 1` 396 次移動,(14,7)→(9,11)→(8,13)→(8,15) 定居,隨後轉覓食/生產/建設一般 task。非原地凍。N1_flee -52%/-18%、憲法綠。

## 請你輕判(對照你上輪抓的 churn)
你上輪判 Team1 後 75% 人生 = churn（逃跑鎖死 3080 次 re-commit）。**修後重讀 Team1 全生命**（新 specimen jsonl 3165 entries）：
- **churn 消了嗎**:day51.7 那段「逃跑原地 128 天」現在變「真逃到 (8,15)→定居→轉一般 task」了嗎?
- **一生連貫嗎**:前半好戲(貿易→掠奪打輸→戰損)保留 + 後半從 churn 變「逃到安全→復原→過日子」= 完整連貫?
- **有沒有新 churn**（逃跑解了但別處冒新的）?

## cascade 驚喜(供你判時知悉,非要你驗)
**修 flee 一根,defect_leave 暴降 79%/93%**（3703→768、1057→70）——根因:`defect_leave` probe key 被 **flee-觸發離隊 + defect-觸發離隊共用**,flee-churn 卡住的隊反覆觸發離隊事件→虛高。**∴「內政 defect 千級」大半是 flee-churn 虛高假警報,非 loyalty 太弱。** riot 也降 47%/13%。

## release stance
flee 真逃 + aggregate 大降(衡量出 churn 佔比)+ 憲法綠。**唯缺你判 Team1 修後一生連貫**（churn 消、故事完整）→ 綠我批 merge（flee-restore 分支）。
- determinism：implementer TDD 自報 bit-identical,未獨立複驗（小 code 面,你判要不要 measurer 補；我傾向自報可接受）。

## 內政殘留(非本判決)
defect 殘 768/70 = 現在小很多。這殘留是「真內政流失」還是還有假象——**待 person-reaction tap(在補)交叉驗**,低急(已非千級警報)。你這輪不用碰內政,只判 flee 修後 Team1。
