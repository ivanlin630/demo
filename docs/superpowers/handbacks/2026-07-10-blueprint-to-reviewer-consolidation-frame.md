---
from: blueprint
to: reviewer
status: consumed
topic: [對抗①/框外] consolidation 統一決策願景 refute——併/降服=統一腦 option-set 框 + code 前提，systems spec 前
---

# reviewer 框外①：consolidation 統一決策框 refute（refute-by-default）

大框 call（三對齊全中：①強結論「併+降服都是統一腦 option-set」+redirect 兩 slice 大工 ②「food term→併 util 升→隊變大→殲滅可見」跳因果鏈 ③blueprint/user 共推、確信+難逆 build）。工作流 `02_reviewer.md:18` 對抗① 在 00→01 前——systems 出技術 spec 前先 refute 框。**用不同模型/代 + 明確 refute（非 confirm）**。

審的 artifact：`docs/superpowers/specs/2026-07-10-consolidation-unified-decision-design.md`（committed）。

## refute 靶 A：「food term→併 util 升→隊變大→殲滅可見」因果鏈成立？
框主張：讓 `consolidate_drive`/`join_drive` 過生存 term，餓隊併 util 自然升→隊變大→殲滅/pursuit 可見。
- 攻擊：這條鏈**每一跳都成立嗎**？(1) 餓隊真會 argmax 選併，還是「覓食/掠奪/返家補給」等既有 survival option 先贏（`SURVIVAL_OPTION_SET` 已有 8 個 option 競爭，併只是其一）？(2) 就算選併，`_find_absorber` 找得到餵得飽的吸附者嗎（餓的世界大家都餓，吸附者也沒餘糧）？(3) 併成了隊真變夠大到讓殲滅窄縫（雙勇均等）常觸嗎？**任一跳斷 = 解不了小隊根，白做**。哪跳最可能斷？

## refute 靶 B：附庸「復用 subteam 骨架」真乾淨？
框主張：附庸=subteam parent-child 骨架 + 怨氣/外源/叛離層，非新概念。
- 攻擊：subteam 骨架假設「自己人分出去」（同源同 faction、忠誠隱含、`_decide_subteam` 歸建 duty 驅）。外來降服隊塞進這骨架，**哪些既有 subteam 假設會被違反**？（跨 faction 的 parent_team_id？怨氣隊走 duty-driven 歸建邏輯會錯嗎？subteam_ids 雙向同步對外來隊成立嗎？）「推廣非重造」是真的，還是硬塞會污染既有 subteam 語意？（S-B 範圍，但框現在就賭這條路）

## refute 靶 C：over-unification 風險？
我的強框：併+降服**全**進統一腦 option-set，無 bespoke。
- 攻擊：有沒有**不該**進統一效用秤的部分？例：合併的「雙方同意」握手（發起方 util 選 + 接受方 util 選）——兩隊異步決策，rank_scored 是單隊 per-cadence argmax，**雙邊握手的原子性/時序**塞得進單隊 rank 嗎，還是需要框外的 handshake 協議（那就不是純統一腦了）？「無 bespoke」是不是過度自信？

## 前提 factcheck（file:line，grep 驗，鐵律1）
design doc 引的 code 斷言逐一 grep 驗真：
- `terms.gd:229` `consolidate_drive` return flat 1.0 / `:90` `join_drive` `has_strong_neighbor` gate
- `_find_absorber`（`faction_ai_system.gd:1562`）同 faction + 統領 pop-cap + 距離、food-blind
- `decision_context.gd:266` consolidate_target 僅非子隊算 / `options.gd:47` SURVIVAL_OPTION_SET 含投靠
- subteam parent-child：`parent_team_id`/`subteam_ids`/`set_subteam_parent`/`merge_teams`/`try_merge_back` 存在且語意如述
- 獨立隊確實跑 rank_scored 含整併/投靠（非只子隊）

## 產物
verdict JSON（clean|issues + premise_contradiction + issues[claim/file_line/truth] + note）to:blueprint。issues → 我 halt 重估框、調 design doc，再放 systems spec。clean → 我推 systems 出 S-A 技術 spec。
