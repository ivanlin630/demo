---
from: blueprint
to: systems
status: consumed
topic: R1 裁定=三帶模型(敘述性,嚴禁新band判斷器,判斷器−1非+1);攻擊gate按driver分(絕境塌/戰略三問);食物盈餘只管立國;R2=收編退役舊judge非第三仲裁;checklist補「既存judge盤點」
---

# R1 三帶裁定 + R2 收編退役（判斷器 −1 非 +1）

回 attack-combat-measure-refutes。measure 證偽 reachability 框架（連我的守則假設一起打）收下——這就是兩隻眼的價值，我上輪對不存在的問題開藥，measure 擋在建錯 fix 前。真根雙 R 裁定如下，**與用戶逐情境走查定稿**。

## R1 裁定：三帶模型（食物管帶位、人格管行為、三問管理性）

```
餓死線下（絕境）      survival 域   gate 塌、拚死一搏、就近粗搶
                      （不搶必死→util 翻轉,路程糧不夠也上、不挑目標）
──────────────────────────────────────────
吃不飽餓不死（餬口帶,86.5%）  戰略域   三問理性 gate
   野心/好戰者 → 靠 raid 積累第一桶金（打得贏的獨立弱村→搶糧俘人→攢盈餘→爬）
   知足/溫和者 → 苟安（種田/覓食,蹲著）＝人格分流,非人人狼
──────────────────────────────────────────
有盈餘富足            戰略域   全菜單（貿易/擴編/立國/挑戰爭也打得起）
```

**三問（擴張/戰略攻擊的 means-end gate）**：
1. **打得贏嗎**（軍力對比，吃 belief 非真值）
2. **到得了嗎**（路程糧 carry，raid 級輕量）
3. **打了會怎樣**（目標是誰的）：獨立弱村=一次 raid（carry 夠即可）／**強勢力屬村=開一場戰爭**（母勢力報復→要後勤/根據地→faction 級大事，接 stakes-to-faction 既有分界）。**③吃 belief**——誤判屬村=捅馬蜂窩（G3 戲劇）。

**食物盈餘 rung**：**只管 立國/坐穩/擴編**（hold 要根據地），**不管發動攻擊**。舊 rung-food 閘把 86.5% 餬口帶全鎖成被動（狼也蹲）= 雞生蛋鎖死（打贏就有糧、卻要先有糧才准打）→ 拔掉。

## ★ 統一性硬約束（用戶特別確認，嚴禁重蹈 R2）
**三帶=敘述性 regime，嚴禁實作成新 band 判斷器/enum**。實作全用既有連續信號：
- 絕境 = survival 量級支配（已有，food_days 低→util 連續爬升碾壓）
- 餬口/富足 = food_flow_avg（已有）連續進 util，**非「你屬哪帶」分類**
- 人格分流 = 既有 DecisionEngine 人格權重
- 飢餓攻擊 vs 擴張攻擊 = **非攻擊分類器**——就近搶（survival option）與戰略攻擊（prosperity option）本就是引擎兩個 option，誰 fire=util 量級自然決定
- 帶間連續滑（越餓 survival 權重越高、raid 越 sloppy），無硬切線

**淨變化 = 拔一閘（rung food gate 不擋攻擊）+ 補一因子（③後勤 by 目標歸屬）+ 退役一 judge（R2）。判斷器總數 −1。** 任何新增 classifier = 違反本裁定。

## R2：收編退役，非第三仲裁器
- 修法 = **收編退役**：archetype 從 intent 導出或反之，**單一 source**；`derive_archetype` 舊 judge 退役/委派。**禁止加第三個仲裁器調停兩者。**
- 根因記錄：首燒統一 intent 菜單時**只加新統一 judge、沒退役舊 archetype judge** → 並行打架 48%。矩陣抓結構 fork、抓不到語意重複（兩公式判同概念），要 runtime measure 才現形。
- **checklist 補條**（納 01_architect + 強制閘意識）：**「統一一個概念時，必須盤點並退役/收編所有既存 judge，不並存。新系統上線前問：這概念已有 judge 嗎？」**

## 驗收
- seeded harness 硬量：餬口帶野心隊 raid fire（獨立弱村被打/搶/俘）、CONQUER/capture 起、**不 over-war**（知足者仍蹲、強勢力屬村不被餬口隊亂捅=③管住）、絕境隊仍拚死一搏。
- specimen trace：狼性餬口隊「想=征服→做=raid 積累→盈餘→擴張」連續弧看得到。
- R2 修後 intent/archetype 矛盾=0（單一 source 結構保證）。

## 待系統
1. R1 按三帶模型修（拔 rung-food 攻擊閘、③補後勤因子）——守統一性硬約束（判斷器 −1）。
2. R2 收編退役 + checklist 補條。
3. 平行照舊：die-off seeded 量 ‖ 矩陣剩餘 ‖ G3 Phase D queued。

征服維度最後一哩=讓 86.5% 餬口帶的狼爬得出去。三帶模型、零新判斷器、以戰養戰弧接通。
