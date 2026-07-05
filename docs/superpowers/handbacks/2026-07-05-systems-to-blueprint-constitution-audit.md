---
from: systems
to: blueprint
status: open
topic: 憲法稽核清單——引擎存在正確但只wire 2 tag(MERCHANT/PRODUCE)+全隊survival;違憲=8個歷史舊平行subsystem/判斷器繞引擎(threat/solo/rung_task查表/vendetta/prosperity/faction dispatch/ReactionSystem/灰項dispatch);零例外驗PASS(絕境引擎內支配/遠方疏非笨反更乾淨);核心=擴uses_unified全隊+併option入REGISTRY;=多slice收斂arc待你裁序
---

# 沙盒憲法稽核清單（統一矩陣收斂主軸）

碼證稽核完。**好消息：引擎架構已足，違憲=歷史舊平行路徑未拆，非引擎缺能力。**

## 引擎現況
- `DecisionEngine.rank_scored` = 真 utility-weigh argmax（`ctx.gather`→每 option `util=Σ(人格weight×drive eval)`+承諾bonus→降序）。REGISTRY 19 option（貿易/生產/覓食/survival/掠奪/佔村/投靠/攻擊/徵收/外交…）。**這正是憲法要的多-option weigh+人格調製。**
- **但只 wire 到 `uses_unified`（TAG_MERCHANT/TAG_PRODUCE）的 macro 決策 + 全隊 survival slice**。其餘 tag（軍隊/統領/獨立武力…）的非生存決策全走**引擎外舊系統**。= 半 wired。

## ★零例外驗 PASS（你的兩硬點）
- **絕境=survival**：unified 走 `_decide_unified` 引擎排序（survival_pressure term 飢餓陡升支配 util）、非 unified 走 `rank_survival` 引擎子集。**引擎內 utility 支配，非 override 硬塞**。飢餓路乾淨。
- **遠方=far LOD**：far 隊跑完整引擎+subsystem，**無跳決策無簡化**（且 evaluate_all 忽略 subset=全隊每 cadence 跑,LOD 不降決策品質）。反諷：far **更**乾淨（跳過 near-only 的 ReactionSystem）。**疏非笨。**

## 違憲清單（8 項，溶入引擎優先序）
| 序 | 違憲項 | file:line | 為何違憲 | 溶法 |
|---|---|---|---|---|
| 1 | **threat subsystem** `_evaluate_threat`/`_dispatch_threat_response` | faction_ai:358/403 | 手算 scores{FLEE/PREPARE/求和/DEFEND} argmax→try_set。**引擎已有 survival(FLEE)+threat_pressure term=純重複** | 4 option 進 REGISTRY 秤。低險高收斂,**先溶** |
| 2 | **_evaluate_solo** | faction_ai:1749 | 非 unified solo 隊自建 scores dict 手算 argmax=**平行第二決策引擎** | 語意同構,翻成 options(多數已在 REGISTRY) |
| 3 | **ambition_ladder.rung_task** | ambition_ladder:105 | `(archetype,rung)→固定 task` 查表=教科書判斷器 | 溶進 ambient_drive term(rung/archetype 當 weight 非塞 task) |
| 4 | **vendetta dispatch** | faction_ai:771 | 強血仇→直塞 TASK_ATTACK,`feud_pull` term 存在但攻擊 option 未掛 | 掛 feud_pull term 到攻擊 option |
| 5 | **prosperity_attack** | faction_ai:244 | gate cascade(archetype/readiness 硬閘)prescribe 攻擊,無 option 競爭 | 攻擊/佔村/scout 成 option 由 intent_fit+belief 風險 weigh。中險 |
| 6 | **faction dispatch** `_assign_tasks`/`_assign_member_tasks` | faction_ai:1392/1465 | goal→固定 task if/elif 判斷器(=V2-cmd 徵收 shadow 攻擊那條) | member 走 _decide_unified(faction_duty term 已存),擴 uses_unified 全 tag。高收斂動主幹 |
| 7 | **ReactionSystem** | reaction_system:112 | 9 反應手算人格 winner-take-all=完整平行行為引擎+ReactionBridge 劫持 TASK_FLEE | 最大最難:拆行為選擇(違憲溶入)vs 情緒/離隊/生育後果(合憲保留)。最後 |
| 8 | 灰項 dispatch | select_strategic_intent(890)/diplomatic(121)/strategic trade_net(231) | intent 作 ctx.intent 輸入=合憲;但**直接 dispatch** 片段繞引擎 | intent 只設 ctx、dispatch 交引擎 option |

## 核心觀察 + 定性
- **憲法接線只差兩件**：①`uses_unified` 從 2 tag 擴成全隊 ②上述平行 subsystem 的 option 併入 REGISTRY。引擎機制（term/weight/applicable/to_task/survival/遠方）**已完整合憲**。
- **這 = 統一決策框架 arc 的收斂終點**（[[project_unified_decision_framework]] 一直在往這走,憲法把它講死）。**= 多 slice arc**,非一 slice。
- **連 V2-cmd**（序6 的 faction dispatch=征服 shadow 攻擊那條 elif）——溶入引擎後 shadow 自然消(option 競秤非 if/elif 遮蔽)。V2-cmd 修 = 序6 副產品。

## 待你裁
1. **修序**：8 項溶入序我按「重疊×難度」排（threat/solo 先=低險高收斂）。你裁 WHAT 優先(哪些戲最需要=先溶)。
2. **arc vs time-wave 序**：憲法溶入=大 arc,與 time-wave(3機械修/A2/60/空間)**平行還是先後**？我建議:①3 機械修先(unblock 60,獨立小)②憲法溶入 arc 逐 slice 穿插(threat→solo→…)③A2/60 節奏切換其間找窗。你裁大序。
3. **強制閘**:憲法閘(掃引擎外 action-selection)何時立=溶完主要違憲後(否則現碼全 fail)。建議 arc 尾立閘擋未來,現先掛 known_issues 追。
