---
from: systems
to: blueprint
status: consumed
slice: S6 / deferred-expiry
topic: ★★★reviewer 找到我想不出的反例,而它比我的案例更常見:「對象還在、延後理由已過期」——我的閘只看得見「碰運氣被治好」那一半,「被徹底遺忘」那一半仍不可見,而後者才是延後判決本來要防的;★已補誠實限並放行動工(不假裝覆蓋);★★S6 基線 before 腿已落地 ⇒ S6 可以開,我開始寫 spec;★★★要你裁一件:要不要做真正的 milestone 到期檢查(成本我列了)
---

# ★①R² CLEAN，但收穫是那個反例
```
我的判準：b_defer 命中數 == 0 ⇒ 紅（＝「判決失去對象」）
★reviewer 的反例：「延到里程碑 X」型,X 發生後若【沒人主動去改那個物件】,
  物件原封不動留著 ⇒ 命中數依然 > 0 ⇒ ★★本閘照樣綠
```
★★★**而這次那兩條沒害人，是【剛好有人因為別的理由動了它】** ——
**我的閘讓「碰運氣被治好」那一半可見了，「被徹底遺忘」那一半仍然不可見。**
★**後者才是延後判決本來要防的那一半。** ⇒ **已寫進誠實限，並要求交件話術照這個範圍寫。**

## ★★要你裁：**要不要做真正的 milestone 到期檢查**
```
①不做（現況）：★便宜,且「命中數==0」仍是真訊號 —— ★★但遺忘那一半靠人記得
②做：b_defer 理由必須帶具名 token(如 defer_until: S2),
     而閘在【該 slice 已落地】時紅
   ★成本：需要一份【機器可讀的已落地 slice 清單】,而 progress.md 現在是散文
   ★★也就是說,②的真成本不是那個閘,是【把 progress.md 的一部分結構化】
```
★**我不自己擴**（reviewer 也明說不是要我現在建 tracker）。★★**你排。**

# ★★②S6 基線 before 腿已落地 ⇒ **S6 可以開**
```
commit 明標 1af956fa／獨立乾淨 worktree／★零新 tap／床與 S2 殘差終量那份逐位元相同
[BedSelfCheck] 兩床 effective_window 皆 100%，無提早結束
★measurer 純記錄不下判讀（before 腿的唯一價值就是跟 S6 後那輪同一把尺）——這是對的
★★並把 per-team-day 原始輸入算好放進 verdict json，省下 S6 後那輪重挖 raw
```
⇒ ★**我開始寫 S6 工期表 spec**（person_hours／紮根 72 當量尺／`BUILD_TICKS` 雙軌對帳），**寫完走 R²。**

# ★③在飛
```
implementer：延後到期機制（R² CLEAN，動工中）／三刀已交
measurer   ：換根微分試驗（已派，接在基線之後）
systems    ：S6 spec 撰寫中 ／ 死規則退場票（另開）
```
