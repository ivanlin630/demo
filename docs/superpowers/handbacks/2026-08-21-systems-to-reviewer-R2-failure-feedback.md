---
from: systems
to: reviewer
slice: failure-feedback
status: open
topic: "[R② 審設計·執行失敗反饋機制 Phase 0(用戶立法:執行失敗=事件必反饋決策層、禁靜默丟棄、同一原因禁無記憶反覆撞)·spec=docs/superpowers/specs/2026-08-21-failure-feedback-mechanism-HOW.md·★我自己最不放心的一點已寫在 §2,請優先打:【折價在世界結構性壞掉時,會讓 agent 安靜地放棄→症狀消失、病還在】,我開的兩道防線是 floor + failure.recorded/suppressed 雙 tap,請判夠不夠·★另請打四裁定:①連續折價非硬 cooldown ②recent_failures 掛隊層非 leader p.memory ③失效升 T0、劣勢只折價 ④反射弧三段同語彙·★這支是 A1 五族的形狀來源:若示範族(order.abandoned)照抄成立,A1 從五個修法縮成五處接線,所以形狀錯的代價會乘以五"
---

# R②：執行失敗反饋機制（Phase 0）

**spec**：`docs/superpowers/specs/2026-08-21-failure-feedback-mechanism-HOW.md`

## ★請優先打這一點（我自己最不放心的）
spec §2 已自陳：**折價在世界結構性壞掉時，會讓 agent 安靜地放棄** —— 隊伍不再嘗試那個選項，
**症狀（反覆撞）消失了，但病（世界壞掉）還在**，而且從此**量不到**。
我開的兩道防線：**① 折價有 floor**（不得歸零）**② `failure.recorded.*` / `failure.suppressed.*` 雙 tap**（放棄本身要可觀測）。
**請判：夠不夠？** 這正是「治抖動＝治症」那條血證的同型風險。

## 四個裁定請一併打
1. **連續折價**（非硬 cooldown）——理由：硬 cooldown 是補丁閘、會 pre-empt 引擎。
2. **`recent_failures` 掛隊層**（非 leader 的 `p.memory`）——理由：換頭不該失憶。
3. **失效升 T0 喚醒；單純劣勢只折價**——兩者不可混。
4. **反射弧三段同語彙**（偵測／記錄／重想用同一組名詞）。

## ★形狀錯的代價會乘以五
這支是 **A1 五族的形狀來源**：若示範族（`order.abandoned`）照抄成立，
**A1 會從「五個修法」縮成「五處接線」**。所以請把它當**通用機制**審，不是當單點修。
