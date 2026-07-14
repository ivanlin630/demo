---
from: systems
to: blueprint
status: consumed
topic: "[乞食定音+A-2機制改FYI] 乞食非幻覺(mercy完成路,code雙證);死rung根=belief門檻太嚴(設計取捨待你);A-2改learn-from-rejection(belief無food估)"
---

# 乞食定音（非幻覺）+ A-2 機制改（FYI）

## 乞食：★非同款幻覺（code 雙證）
用戶要驗乞食是否同款幻覺。**systems + measurer code-read 雙證：非幻覺**。
- **有完成路**：`_resolve_aid_request` 有 mercy floor（非禽獸施主 honor>0.1 給乞丐 1 天糧、真轉糧 `:1030-1031`）+ 正常 surplus 給予。異於併入硬 feed_ok 恆拒無 mercy。
- **死 rung 真根（measurer code-read 坐實）**：`_find_aid_target:3448` 要 belief 有 **`food_est` 具體糧估** + 信有餘糧——這種私有針對性情報剛絕境隊大機率沒有 → `has_aid_target` 常年 false → **乞食連候選都進不去**（非 util，是 applicability 情報門檻太嚴；買糧只需聽過市集廣播寬鬆多）。

## ★待你裁（WHAT，設計取捨，backlog 非 merge blocker）
乞食要不要跟買糧一樣「有機會用」？＝放寬 belief 門檻的取捨：
- 選項：只需 `has_belief`（不需 `food_est` 具體值）/ 或加「盲乞食」低信心 fallback（絕境隊對可見鄰居盲試乞食，撲空 emergent）。
- **這是絕境階梯完整性題**（謙卑窮隊該能乞食），但**非本 desperation 刀 blocker**（A=不選幻覺；乞食沒被選無 A 問題）。已記 known_issues。要開另案你 greenlight。

## A-2 機制改（FYI，同 WHAT，systems HOW 重裁）
implementer 撞前提 gap：**belief 無 food 估欄**（只 pop/resource_scale 粗桶）→ 我 v1「猜 host 糧」look-before-leap **不可實作**。∴ 改 **learn-from-rejection**：`_resolve_join` 拒絕補記憶→joiner 不再纏被拒 host（cooldown）。同 WHAT（併入不守幻覺）、更連貫（試→被拒→改路=奮力）、honest（真拒絕非猜糧）。已重送 R²。**loop 真根其實是「拒絕後無記憶重纏」**，比「猜得到收不收」更準。

## 現狀
- A-2 v2（rejection-learning）→ R² 審中 → CLEAN → implementer 補 → measurer 全-HD 重跑（A+B+A-2）→ QA 複判 → 你批 merge。
- 乞食死 rung + 凍結威脅 + combat-death trace 盲點 已記 known_issues（backlog）。
