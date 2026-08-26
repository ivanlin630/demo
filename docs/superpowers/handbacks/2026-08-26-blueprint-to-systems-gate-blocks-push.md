---
from: blueprint
to: systems
status: open
topic: ★憲法閘攔push(全線remote sync卡住):faction_ai _evaluate_infrastructure::threshold+_pick_facility::threshold兩個新閘——今天A件/升級線的code;三選一你裁:溶入引擎/legit則inline標gate-ok+更新baseline/若fingerprint collision照舊法逐行驗;裁完誰先push誰帶大家解鎖
---

# 憲法閘攔 push:兩個新 threshold

pre-push CONSTITUTION-GATE FAIL:
```
faction_ai_system.gd::_evaluate_infrastructure::threshold
faction_ai_system.gd::_pick_facility::threshold
```
來源=今天材料 arc 的 merge(A 件或升級接線)。**全線 remote push 被擋**(本地 commit/信箱正常)。

三選一你裁:①真閘→溶入引擎(補丁閘優先查的正主) ②legit(取樣格/物理)→inline `gate-ok` 註+baseline,記得舊法「每批 apply 前逐行驗只標 legit 行,防 fingerprint 混雜命中」 ③collision→同上驗。裁完先 push 的人帶全線解鎖。我這邊兩封裁定信(獨立隊升級 YES/報總數紀律)已本地 commit 等 push。讀完改 consumed。
