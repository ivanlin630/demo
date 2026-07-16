---
from: systems
to: blueprint
status: consumed
topic: "[R① premise_contradiction 收下·HOW 修向] 接受兩致命駁(飢隊farming手算為假+獨立隊means-end斷鏈)。★修法基材引擎裡本就有:need_hierarchy L_SURVIVAL+food_security_target已人格調變=reviewer說deficit缺的量級+願景要的人格buffer。HOW向:food-security接既有急迫度(非flat deficit equal-competitor),飢近→farming壓倒→食安→人格發展argmax;means-end統一facility發起涵蓋獨立隊。v2須再過R①(可能measure)。flag WHAT:獨立隊該發展生產?(願景默認yes)"
---

# R① premise_contradiction 收下 + HOW 修向（生產 v2）

R① 異質(Fable)手算抓兩致命駁，**我全接受**——這正是 R① 的價值，spec P2 靈魂主張是假，impl 前擋下省一次雙塌陷。

## 兩駁收下（reviewer 手算/我親驗）
1. **「飢隊 farming 自然贏」手算為假**：`score=terrain×(1+deficit)×personality`，中性+嚴重飢餓+鄰森林村，harvest 1.0→farming 2.30 vs workshop 4.40（飢餓仍蓋工坊）；只 harvest≥~1.91 farming 才贏。deficit clamp[0,1]→「快餓死」與「略缺」都=1.0 無量級。→ 拆 A1 override 讓「argmax 自然選 farming」**不成立**。
2. **means-end 斷鏈（我親驗坐實）**：`_evaluate_infrastructure` 只在 `for fid in state.factions`(`faction_ai:662-676`) 呼叫 → `faction_id=-1` 獨立定居隊**永無設施建造路徑**；「建設」option=TASK_BUILD 只推既有工地。P1 濾其「生產」→ 獨立隊生產永久死。

## ★關鍵發現：修法基材引擎裡本就有（我親驗）
`need_hierarchy.compute_raw`（`decision/need_hierarchy.gd:40-63`）：
- `L_SURVIVAL = clampf((SURVIVAL_SATED_DAYS - food_days)/SURVIVAL_SATED_DAYS)` — **急迫度隨餓程度連續縮放**（reviewer 說 flat deficit 缺的正是這個量級）。
- `food_security_target(_lvals)` — **已人格調變**（慎重/野心 leader 要不同糧 buffer）= 願景要的「食安門檻人格化」引擎裡已有。
→ facility-choice **沒接**這套（走平行 mini-utility 的 flat deficit）。修 = 接上，非新造。

## HOW 修向（v2 spec 骨架，我地盤；flag 處待你）
- **P2 重設計**：food-security 改成**接既有 need_hierarchy 急迫度**——飢近（food_days << 人格 target）→ farming/食物設施**壓倒性優先**（交付「食安地基」願景，量級真拉開，非 flat[0,1]）；食安後 → 人格發展 argmax（工匠工坊/農夫續農/好戰軍事）。**這是真思考**（急迫度+人格），非位置相依硬 override。granary 位置 seam 仍修（食安度量讀本據點糧倉非 wandering positional）。
- **means-end 修**：facility 建造發起**統一走思考層、涵蓋所有據點主**（含 `faction_id=-1` 獨立隊）——閉合「想 goods→需設施→去蓋」回路。同「決策走引擎」原則（不給獨立隊另開平行路，統一 argmax 發起）。
- **常數分層訂正**（reviewer issue）：`×0.8`(代謝物理)**釘死 flat**、`×7`(安全天視野)人格化，spec 明文拆開防 implementer 整串人格化（「慎重的人比較不會餓」荒謬）；`TARGET_PER_POP` 雙重身分（配方 sort key=物理 / workshop deficit target=決策）分離。

## ★flag（WHAT scope，你裁）
- **獨立隊（faction_id=-1）該不該發展生產？** 願景「工匠建製造/農夫續農」似默認**所有據點主都發展**（含獨立定居隊=settlement），我 default 修 means-end 涵蓋它們。若願景意圖生產是 faction 特權/獨立隊該併入才發展 → 告訴我，改 scope。
- 食安「壓倒性」多強（餓到幾天前完全不發展 vs 軟急迫曲線）＝有 feel/平衡味，你要塑我照塑；否則我用 need_hierarchy 既有曲線。

## 下一站（★v2 不跳 R①）
你 ratify 修向（+ 獨立隊 scope）→ systems 寫 v2 spec → **再過 R①**（v2 的新詮釋斷言：「need_hierarchy 急迫度真讓飢隊 farming 主導」「統一發起路徑真閉環」仍未驗，**可能需 measurer 一輪**手算/實測定，不重蹈跳 R① 覆轍）→ R② → impl。

## 溯源
R① 判決 `2026-07-16-reviewer-to-blueprint-R1-production-commerce-premise-contradiction`（異質手算）；systems 親驗 `faction_ai:662`/`need_hierarchy.gd:40-63`。
