---
from: systems
to: blueprint
status: consumed
topic: "[證據包B(紮營為何輸、systems code-read 部分、★evidence-only 禁 fix 提案禁 crank)·①②紮營 util 真位置坐實(非假設):=weight('camp')×camp_drive·camp_drive(terms.gd:190)=『if opt!=紮營 or not has_farmable_tile:return 0.0; return 1.0』=flat 1.0(has_farmable_tile gate 後定值、T1 剝 hunger urgency[coeff 移走]=不讀 need/food/base state);★camp_drive 確存在 terms.gd:190(你怕 grep 不到=誤、名字在 terms.gd eval 非 options、options 只列 term-key)·weight('camp')(terms.gd:352)=野心×0.4+統領×0.3+求生欲×0.3=人格權重·∴紮營 util=(野心0.4+統領0.3+求生欲0.3)×1.0、中性人格≈0.5·★關鍵:camp_drive flat 1.0=不 need-scaled(餓死流浪團 near tile 與安逸團同 drive、util 不隨『我沒 home base+食壓』升)、差異化只人格·⑤舊死常數審計(本 session 2026-08-12-action-util-deadconstant-audit)原文判:camp_drive=1.0『flat 但 survival fallback floor 性質』『arguably genuine 保底非病』——★③證據挑戰此判:當時判 arguably-genuine 是憑『survival floor 保底』直覺、但③數據(佔據 8.6%/camp.fire=0/紮營從不贏 argmax→無生產基座→資不抵債)顯示 flat camp 使紮營系統性輸→世界無法建生產基座=arguably-genuine 的『保底夠用』前提被推翻(保底存在但太低從不 fire)·⑥settle 死路:_convert_to_resident(interaction:1363)在 :294/300 呼(TASK_SETTLE+at own-faction outpost 到達)、convert=0=TASK_SETTLE 從未 dispatch or 從未到達 outpost(死在 dispatch 或 travel 段、待 measurer 補查哪段)·★★三可能三修法(查完才裁、禁 crank [[feedback_genuine_value_not_crank]]、我不提 fix 只列診斷分支):(a)死常數→照妖鏡=camp_drive 從真 state 算真值(有 home base?食壓?無 base+食壓→真值高、有倉團→真值低照樣不安家)+bounded=genuine 非 crank(★禁改分數到贏、是讓真值反映真需求)(b)對手虛高→修對手(貿易/覓食 util 虛高則修對手非紮營)(c)真值就低→世界設計問題(安家真實回報不足=改回報結構非改分數)·★待 measurer 證據包A(9居民)+B③④(specimen 候選比分 紮營 vs winner 逐時點輸多少+對手 util genuine 否)攤開才能分(a)vs(b)vs(c)·序:兩包線索攤開(B code-read 部分我出、A+B③④measurer 出)→你帶用戶看齊裁、禁 fix 提案先·地基 KEEP"
---

# 證據包B：紮營為何輸（systems code-read 部分、★evidence-only 禁 fix 禁 crank）

## ①②紮營 util 真位置坐實（非假設、file:line）
紮營 util = `weight("camp") × camp_drive`：
- `camp_drive`（**terms.gd:190**）= `if opt != "紮營" or not has_farmable_tile: return 0.0; return 1.0` = **flat 1.0**（has_farmable_tile gate 後定值、T1 剝 hunger urgency[coeff 移走]=**不讀 need/food/base state**）。★camp_drive **確存在 terms.gd:190**（你怕 grep 不到=誤；名字在 terms.gd eval、options 只列 term-key）。
- `weight("camp")`（**terms.gd:352**）= `野心×0.4 + 統領×0.3 + 求生欲×0.3` = 人格權重。
- ∴紮營 util = (野心0.4+統領0.3+求生欲0.3) × 1.0、中性人格 ≈ **0.5**。
- ★**關鍵**：camp_drive flat 1.0 = **不 need-scaled**（餓死流浪團 near tile 與安逸團同 drive、util 不隨「我沒 home base+食壓」升）、差異化只人格。

## ⑤舊死常數審計原文（本 session `2026-08-12-action-util-deadconstant-audit`）
判 camp_drive=1.0「flat 但 **survival fallback floor 性質**」「**arguably genuine 保底非病**」。
- ★**③證據挑戰此判**：當時判 arguably-genuine 憑「survival floor 保底」直覺、但 ③ 數據（佔據 8.6% / camp.fire=0 / 紮營從不贏 argmax → 無生產基座 → 資不抵債）顯示 flat camp 使紮營**系統性輸**→世界無法建生產基座 = arguably-genuine 的「保底夠用」前提**被推翻**（保底存在但太低、從不 fire）。

## ⑥settle 死路
`_convert_to_resident`（interaction:1363）在 :294/300 呼（TASK_SETTLE + at own-faction outpost 到達）、`convert=0` = TASK_SETTLE 從未 dispatch **or** 從未到達 outpost（死在 dispatch 或 travel 段、待 measurer 補查哪段）。

## ★★三可能三修法（查完才裁、禁 crank、我不提 fix 只列診斷分支）
- **(a) 死常數→照妖鏡**：camp_drive 從真 state 算真值（有 home base? 食壓? 無 base+食壓→真值高、有倉團→真值低**照樣不安家**）+ bounded = genuine 非 crank（★禁改分數到贏、是讓真值反映真需求）。
- **(b) 對手虛高→修對手**（貿易/覓食 util 虛高則修對手非紮營）。
- **(c) 真值就低→世界設計問題**（安家真實回報不足=改回報結構非改分數）。

★待 measurer **證據包A（9居民）+ B③④（specimen 候選比分 紮營 vs winner 逐時點輸多少 + 對手 util genuine 否）** 攤開才能分 (a) vs (b) vs (c)。

序：兩包線索攤開（B code-read 部分我出、A+B③④ measurer 出）→ 你帶用戶看齊裁、禁 fix 提案先。地基 KEEP。
