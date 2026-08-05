---
from: systems
to: measurer
status: open
topic: "[faction-cohesion arc ★開場 exit-attribution 量測(spec 鎖前 grounding、用戶 route=A 提前;measure-first 定 §2 刀口非靜態斷言)·床:rep 床 config/infonet_faction_rich_rep.json(它正是靠這些 exit 崩=完美 trace 對象)+若可加好領主 vs 爛領主對照更佳·量:床裡★逐件 clear_team_faction 事件 trace(三出口:defect event_faction_defect:24 / 起義 faction_ai:4571/4577 / contact-loss defection_eval:4640/4643)·每件分類『人格 genuine 該走 vs 死常數驅動假走』——★discriminator:①defect(義氣/信義<0.35 fire):該 member 有無『其他真該走理由』(領主 abusive/無 relief 史/無保護/有更好去處)=genuine,vs 義氣 0.34 但領主好(有 relief 救援史/保護)、純門檻 flip=死常數假走(義氣 0.34 vs 0.36 差一點就被踢=arbitrary)②起義(無條件清):該隊起義後『可否換領主留勢力』(推翻領主≠必然脫勢力)、被無條件 clear=可能假走·③各出口佔比(defect/起義/contact-loss 各幾件、佔崩壞多少)·輸出:per-exit trace 表(member/義氣/領主品質/去處/genuine-or-死常數判)+佔比→grounds §2 哪個出口主導、多少 genuine vs 死常數 forced·★純觀測 dump 真值、別下 accept、回 systems 定 §2 刀口 spec·落地 docs/measurements/·地基 KEEP"
---

# faction-cohesion ★開場 exit-attribution 量測（spec 鎖前 grounding）

用戶 route=A（cohesion arc 提前）。**spec 鎖前必先 measure-first grounding**（定 §2 刀口、非靜態斷言、[[feedback_measure_peroption_util_before_decision_claim]] dump 真值先）。

## 床
- **rep 床 `config/infonet_faction_rich_rep.json`**（它正是靠這些 exit 崩成 1 faction＝**完美 trace 對象**）。
- 若可，加**好領主 vs 爛領主對照**（驗分化：好領主勢力該較持久）更佳。

## 量：逐件 `clear_team_faction` 事件 trace（三出口）
1. **defect**（`event_faction_defect:24`、義氣/信義<0.35 fire）
2. **起義 uprising**（`faction_ai:4571/4577` 無條件清）
3. **contact-loss**（`defection_eval:4640/4643`、`_evaluate_owner_contact` 路）

### 每件分類「人格 genuine 該走 vs 死常數驅動假走」（★discriminator）
- **defect**：該 member 有無**其他真該走理由**？領主 abusive / 無 relief 救援史 / 無保護 / 有更好去處 → **genuine 該走**；vs 義氣 0.34 但**領主好**（有 relief 救援史/保護）、純門檻 flip（義氣 0.34 vs 0.36 差一點就被踢）→ **死常數假走（arbitrary）**。
- **起義**：該隊起義後**可否換領主留勢力**？（推翻領主 ≠ 必然脫勢力）被無條件 clear → 可能**假走**。
- **各出口佔比**：defect / 起義 / contact-loss 各幾件、佔崩壞多少。

## 輸出
- **per-exit trace 表**（member / 義氣 / 領主品質[relief 史/保護] / 去處 / genuine-or-死常數判）+ 佔比。
- → grounds §2：哪個出口**主導**、多少 **genuine** vs **死常數 forced**（定刀口先砍哪個）。

## 序
★純觀測 dump 真值、別下 accept。回 systems **定 §2 刀口 spec**（+ blueprint P1-P4 R① 平行）→ spec 鎖 → R² → build。落地 `docs/measurements/`。地基 KEEP。
