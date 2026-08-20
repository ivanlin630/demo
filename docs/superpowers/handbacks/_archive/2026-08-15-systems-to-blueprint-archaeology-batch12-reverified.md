---
from: systems
to: blueprint
status: consumed
topic: "[考古batch1/2全9題重驗完(整檔重讀+負斷言窮盡證據、照品質閘整改)·結果:9題→用戶只需裁3真WHAT、其餘6銷/降/指arc·★銷案3(code已答假問題):④貿易god-view fallback=dead code(_find_trade_target 3261/_find_trade_partner 241窮盡零caller、非live違憲cleanup候選)⑤BASE_PRICE=估值湧現已答(local_value:136=BASE×(1+短缺)per-team主觀/饑荒5×/人格折扣、BASE只錨定常數、檔頭自述唯一估值源=我部分讀犯病)⑧relations=dead code(faction.relations零mutation窮盡驗、僅person.relations npc_ai:106)cleanup非問題·★指既有arc 1:①戰鬥off-ramp够不够=3 off-ramp真存在(mortal_flee eff≤3 courage-scaled/readiness rout/retreat)但desperation-economy arc已measure小隊100%殲滅在track、非新裁決·★降級2:③零累積繼承=successor自帶attributes+team-state保留、只無dynasty技能傳承=feature-speculation非gap低優先·⑨reaction雙系統=person值→morale vs team值→task不同scope疑本就有意分(unified是團層/reaction人格層)·★KEEP真WHAT 3(窮盡驗、真需用戶裁):②勢力零繼承(leader_team死→disband無reassign窮盡world_state:310/122)斬首即崩intended?③外交正式戰爭未實作(窮盡無declare_war/at_war/make_peace、宣戰僅log flavor)隱式intended or戰爭之路加正式態?⑥pop_cap領導結構帽(team_data:48 clampi公式、食物只gate breed-rate)領導帽or食物湧現?·整改後每batch自過此關·用戶裁決名額省6·地基KEEP"
---

# 考古 batch1/2 全 9 題重驗（整檔重讀 + 負斷言窮盡、照品質閘整改）

翻車認：⑤ 我 C 段前一句寫「湧現估值 local_value:136」下一句還問「該湧現？」=部分讀犯了要治的病、燒用戶名額。整改後全 9 題整檔重讀重裁。**結果：用戶只需裁 3 真 WHAT、其餘 6 銷/降/指 arc。**

## ★銷案 3（code 已答、假問題、不勞用戶）
| # | 原題 | 現況（整檔讀完 + 窮盡證據） | 裁決 |
|---|---|---|---|
| ④ 貿易 god-view fallback | 「該刪 or 確認 dead」 | `_find_trade_target`(faction_ai:3261)/`_find_trade_partner`(strategic_ai:241) **窮盡搜零 caller**（僅註解:3164 提及、strategic_ai 系統 live 但此 fn 無呼叫點）→ **dead code、非 live 違憲** | 已答=cleanup 候選、非開放 |
| ⑤ 貿易 BASE_PRICE | 「錨定 or 該湧現」 | **估值湧現**：`local_value:136 = BASE_PRICE×(1+短缺率)`、per-team 主觀(pop/stock)、survival 饑荒 5× 不對稱、ask_price 人格折扣；BASE_PRICE=錨定常數(成品≥原料×1.2)。檔頭自述「估值唯一真值源、唯一 local_value」 | 已答=湧現、**我部分讀** |
| ⑧ 外交 relations | 「dead code？」 | `faction.relations` **窮盡搜零 mutation**（`.relations[`寫入僅 `npc_ai:106 p.relations`=person、無 faction 寫）→ 死碼確認 | 已答=cleanup、非開放 |

## ★指既有 arc 1（非新裁決）
| # | 原題 | 現況 | 裁決 |
|---|---|---|---|
| ① 戰鬥 off-ramp 够不够 | | 3 off-ramp 真存在（`_mortal_flee_check` eff≤3 courage-scaled:152 / readiness-abandon rout / optional retreat）+ 殲滅 path(:179 註勢均消耗≈1) | 指 [[project_desperation_economy]]（已 measure 小隊 100% 殲滅、off-ramp 不够、arc 在 track）、非新裁決 |

## ★降級 2（低優先 / 疑本就有意）
| # | 原題 | 現況 | 裁決 |
|---|---|---|---|
| ③ 零累積繼承 | | successor=named best「統領」or fresh anon、**各自帶** attributes；`set_leader` 只設 leader_id+role、不轉死領袖個人技能；team-state(reputation)保留 | 非「啥都不繼承」=誤述；真=無 dynasty 技能傳承=**feature-speculation 非 gap**、低優先 |
| ⑨ reaction 雙系統 | 「該收斂？」 | reaction(個人行為 reaction_system:99、person 值→morale)與 DecisionEngine(團任務 decision_engine:48、leader 值→task)不同 scope | 疑**本就有意分層**（unified-decision=團層、reaction=人格層、粒度不同）；mild、非急 |

## ★KEEP 真 WHAT 3（窮盡驗、真需用戶裁）
| # | 現況（整檔 + 窮盡證據） | 真開放（原始意圖未知、code 不能答） |
|---|---|---|
| ② 勢力零繼承 | leader_team 死 → `disband_faction`(world_state:310)、`leader_team_id=` **窮盡僅 :122 create 無 reassign** | **斬首即崩 intended？** or 該有勢力繼承/遷都？ |
| ③ 外交正式戰爭 | **窮盡無** declare_war/at_war/war_status/make_peace（「宣戰」僅 log/UI flavor npc_combat:112）；戰爭=reputation→threat 隱式連續(threat_assessment:17) | **隱式連續 intended？** or 戰爭之路 arc 該加正式戰爭態？ |
| ⑥ 繁殖 pop_cap | `pop_cap_from_leadership=clampi(round(49×min(skill/0.8,1))+1,1,50)`(team_data:48)=領導技能結構帽；食物只 gate breed-rate(reaction:197)非 carrying-capacity | **領導帽 intended？** or 該食物 carrying-capacity 湧現？（扣 [[project_size_matter_arc]]）|

## 整改
- 之後每 batch 出稿**自過此關**（整檔重讀 + 負斷言窮盡 + code-有答自銷）。格式=現況欄按負斷言標準（原始意圖(git 史)欄本輪薄、聚焦現況重驗、深 git 考古待後續 batch）。
- **用戶裁決名額省 6**（9→3）。地基 KEEP。
