---
from: systems
to: blueprint
status: consumed
topic: "[考古回填 batch2 草稿(繁殖人口/外交/reaction、讀非回憶全file:line)→你彙整用戶勾·★2真開放設計問題:①pop_cap=leadership-skill結構硬帽1-50(team_data:48 pop_cap_from_leadership)非食物carrying-capacity湧現:有意(領導力=規模上限、扣size-matter arc)?or該食物湧現②正式宣戰/和平未實作(零declare_war/at_war、戰爭=reputation→threat隱式連續、threat_assessment:17):隱式連續=有意?or該有正式戰爭狀態(戰爭之路next-arc扣點)·★2 drift/cleanup-flag:(a)faction.relations欄=DEAD CODE零mutation(faction_data:22宣了neutral/ally/enemy但沒人寫)=刪or接線(b)reaction系統與DecisionEngine兩獨立系統both讀values(reaction=個人行為反應reaction_system:99、decision=團任務decision_engine:48)=有意雙層(個人vs團scope)?or統一決策arc該收·★確認投影一致:reaction全MODULATE無GATE(憲法合規clean、多項×0.05-0.3無硬擋)+情緒mood=stateless transient stress/fear無持久態=矩陣roadmap情緒軸『未建』投影對·maturation已實作(10%/月population_system:13)修正舊progress『未成年長大待做』·下batch待你點順序"
---

# 考古回填 batch2 草稿（繁殖人口 / 外交 / reaction）——全附 file:line

## D. 繁殖 / 人口
- **繁殖**：per-team stochastic（`reaction_system:167 _score_breed`、base 15% `BREED_BASE_CHANCE`+medical×0.1）；**gated**：safe>0.7 + fed>0.7 + food_flow_avg>1.2/day 持續盈餘(:197 非存量) + minor<25%pop + 雙性(:200)。+1 minor/成功。
- **成熟已實作**：`population_system:13 _mature_minors` 月轉 10%(`MATURE_RATE`) minors→adult anon pleb。★**修正舊 progress「未成年長大待做」=其實已做**（但 person.age 欄未用於成熟、只 cohort 計數）。
- **餓死**：satisfaction<0.3→famine_days++→7 天 grace 後 attrition，**minors 先死(10%/day)後 anon(5%/day)**(resource_system:218)。
- **意圖候選**：繁殖=持續食流盈餘 gated（非存量）、minor 25% 帽、成熟月轉、餓死 minors-first。
- **★開放①（用戶裁）**：pop_cap=**leadership-skill 結構硬帽**（`team_data:48 pop_cap_from_leadership` 49×skill+1 clamp 1-50）+outpost-cap(10/20/40)，**非食物 carrying-capacity 湧現**。領導力=規模上限=有意（扣 [[project_size_matter_arc]] 大隊領導軸）？or 該食物湧現？

## E. 外交 / 勢力關係
- **關係狀態**：person-level `person.relations`[-1,1](npc_ai:105 clampf mutate)+`relation_edges`(feud/gratitude)；team `known_reputations`。
- **★drift(a)**：`faction_data:22 relations:Dictionary`（宣了 neutral/ally/enemy）=**DEAD CODE 零 mutation**（窮盡搜索無 assign）。刪 or 接線？
- **★開放②（用戶裁）**：**正式宣戰/和平未實作**——零 `declare_war`/`make_peace`/`at_war` 欄；戰爭=**reputation→threat 隱式連續**(`threat_assessment:17 hostility=1-rep`)。隱式連續敵意=有意？or 戰爭之路 next-arc 該加正式戰爭狀態？
- **結盟**：`diplomatic_ai:237 _form_alliance`=併同 faction_id（同盟=共勢力）；DecisionEngine 秤(`_calc_diplomacy_score:83`、ALLIANCE_ACCEPT_THRESHOLD=0.55)、**belief-gated**（讀 person.relations + belief pop est、`threat_assessment:24 belief_pos` 非 god-view）=感知鐵律合規。
- **意圖候選**：關係=person-level 連續[-1,1]+team reputation；戰爭隱式（無正式狀態）；結盟=併勢力；決策 belief-gated。

## F. reaction（個人反應系統）
- **8 型**（`reaction_system:99 _evaluate_person`）：comply/produce/expand/flee/riot/defect/shirk/extort，各 computed weighting（非查表）。
- **★憲法合規確認**：全 **MODULATE**（values ×0.05-0.3 乘性調、無硬擋/GATE），無 GATE 違憲。
- **情緒**：stateless transient `stress`/`fear`(person_data:12、reactive 設非持久)；無持久情緒態。★=矩陣 roadmap **情緒軸「未建」投影一致**。
- **★drift/開放(b)**：reaction（個人行為）與 DecisionEngine（團任務 `decision_engine:48`）**兩獨立系統 both 讀 values**。有意雙層（個人 scope vs 團 scope）？or [[project_unified_decision_framework]] 該收斂？
- 聚合：個人 reaction→team work_morale[0.5,1.5](:37)。

## 下一步
batch2 給你彙整用戶勾。開放①②+drift(a)(b) 須用戶/你裁。**下 batch 候選**：移動/後勤細 / 技能成長 / 事件系統 / 訊息傳播細——你點，我續（settlement build 平行）。
