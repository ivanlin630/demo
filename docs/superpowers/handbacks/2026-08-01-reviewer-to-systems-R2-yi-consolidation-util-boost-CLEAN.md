---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+1追蹤項] 乙整併util boost HOW——親讀terms.gd:59/129-134/224-230確認§0b餓死公式坐實精準(三≤1因子連乘+野心先被×0.3閹割再塞band)，A absorb的de-patch(鬆綁既有死常數非疊補丁)方向對；B join新增protection urgency因公式未定無法驗連續性，implementer落地時我會針對這條專門複驗②約束(禁硬gate)"
---

# R②判決：乙 整併 util boost HOW — CLEAN + 1 追蹤項

## §0b 餓死公式——親讀terms.gd坐實，非信斷言
逐行核對`terms.gd`：
- `:59` `ABSORB_DRIVE_BASE=1.0`，comment原文「T3正規化：吸納量級→[0,1](1.2→1.0)」——確認這是**先前某輪迭代**主動把base從1.2砍到1.0做正規化，這輪要放寬的正是那次正規化留下的死常數，非亂改。
- `:224-230`完整`absorb_drive`公式：`ABSORB_DRIVE_BASE×resource_slack×(0.5+0.5·yield_pos)×(0.5+0.5·amb_gap)`——跟spec引用逐字對上。
- `:228` `amb_gap=clampf(ambition_gap×0.3,0,1)`——親算：野心`ambition_gap`(語意上是「跟目標的野心差距」，非raw野心值)先被×0.3打對折以上，再塞進`0.5+0.5×`這個只能貢獻[0.5,1.0]範圍的band——即使`amb_gap`打滿1.0，這一項也只到1.0；三個這樣的≤1因子連乘，典型值確實會落在spec講的~0.2量級，跟「吸納ownutil均0.104」的觀測數字量級吻合，不是巧合。
- `:129-134` `join_drive`確認只有quality/rep term(`0.5+best_protector_rep×REP_MAGNET_W×0.5`)，urgency(hunger/threat)走另一層coeff——spec講的「join_drive本身沒有urgency、urgency在別處乘」跟code結構一致。

## A absorb de-patch——方向對，是鬆綁死常數非疊補丁
`amb_gap→ambition_amp=0.5+AMB_GAIN×ambition_gap`拿掉了×0.3的預先閹割、`BASE→BASE_V2`保守抬——這是**放寬既有過度正規化的常數**，不是在原公式外面加一層新判斷或新特判分支，符合這session一貫的de-patch要求（[[feedback-patch-gate-first]]死常數人格化家族的正確解法）。

## ★B join新增protection urgency——方向合理，但公式未定，追蹤到implementation
spec明講「弱near強、非只絕境」但沒給出exact公式（保守起步值+§5合量tune非現在定）——這是這個codebase一貫的做法（大量TEST VALUE常數先定形狀後調數值），可以接受。但這代表我**這輪沒辦法驗證約束②（連續weigh非硬gate）對這個新urgency項是否成立**——「弱」「near」「強」如果implementer寫成`if weak and near_strong: urgency+=X`會是硬gate、寫成連續乘積才是WEIGH。

**要求**：implementer落地後，我會針對這條**專門**複驗join_drive新urgency項的實際公式，確認是連續乘除而非階梯判斷——這是這輪HOW審查唯一沒能grep到真code驗證的部分，其餘三個約束(①③④)已經能從spec文字+既有code結構確認方向對。

## dev-verify（§3）——涵蓋到位
5項硬斷(吸納真fire/併入理性fire/人格分化連續/保守未塌/determinism)裡的第3項(「掃ambition→連續非階梯」)本身就是驗證②約束的機制，implementer必須跑這個掃描才能過dev-verify，等於B的公式問題最終還是會被這輪自己的驗收流程攔到，不會漏測。

## 判決
**CLEAN → dispatch隔離branch。** de-patch方向紮實、根因坐實非猜測，①③④約束從spec文字可信，②約束對B的新urgency項待implementation才能真正grep驗證(非blocking，dev-verify流程本身會攔)。
