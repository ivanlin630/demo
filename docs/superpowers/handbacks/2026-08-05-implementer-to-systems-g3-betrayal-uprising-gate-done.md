---
from: implementer
to: systems
status: consumed
topic: "[g3.betrayal bond counter + uprising faction_id gate DONE·續 feat/faction-cohesion commits 03f03ce4+00a40775]①g3:betrayal driver 加 bond counter driver−=_faction_stay_benefit(第四出口解單邊秤、共享同一 helper 一套非兩套、跨class呼既有慣例)→忠/被救不叛、無情+利大+無恩義照叛(genuine opportunism 保留)②cheap-win:_evaluate_uprising 開頭補 if faction_id==-1 return(independent 隊空觸發修、對照 defect gate)。驗:g3_test 4/4(分化命門+opportunism+共享helper+零godview)+headless 0-new+constitution 74+determinism 28C07CF1 byte-identical(≠cohesion-alone=行為真改)。★注:diplomatic_ai counter 被 linter/concurrent revert 一次、已 re-apply+commit lock。請 R²→measurer re-measure(★③下游解鎖 rep 床不秒崩+4出口佔比 map)→QA。"
branch: feat/faction-cohesion
commit: 00a40775
---

# g3.betrayal bond counter + uprising faction_id gate — DONE（續 faction-cohesion arc）

兩件皆續 `feat/faction-cohesion` 同 branch（cohesion 90631616 之上）。

## ① g3.betrayal bond counter（commit `03f03ce4`、spec g3-extension-HOW R² CLEAN）
grounding：g3.betrayal 單邊秤（driver=機會+不忠、零 bond counter）＝P4 同病異出口、cohesion ③下游 rep 床 collapse 真驅動。
- **fix**：`diplomatic_ai_system.gd betrayal_assessment` driver 計算後 `driver -= FactionAISystem.new()._faction_stay_benefit(state, self_team)`（bond counter-term）。
- **★共享同一 `_faction_stay_benefit`**（faction_ai defect/uprising/defection-eval + diplomatic_ai betrayal 四出口共用＝一套非兩套；跨 class 呼 `FactionAISystem.new()` 既有慣例、不需改 static＝避 reviewer 前輪抓的兩精度病）。
- 結果：忠的/被救的（stay_benefit 高）→driver<0.65 **不叛**；無情+利大+無恩義（stay≈0）→**仍過門檻照叛**（genuine opportunism 保留）。0.65 semi-cliff 連續化 defer（避 scope creep）。
- 守：零 god-view（counter 讀 self benefactor memory + known_reputations belief）；§1 雙向（counter=已驗 genuine helper 減項非忠誠常數 boost、`_execute_betrayal clear_team_faction` 不碰=opportunist 照叛、無配額）；determinism 純算術減項零新 randf。

## ② uprising faction_id gate（commit `00a40775`、cheap-win blueprint GO c）
- `_evaluate_uprising`（`faction_ai:4536`）開頭缺 `if team.faction_id == -1: return`（對照 defect `event_faction_defect:6-8` 有此閘）→已 independent 隊（faction_id=-1）反覆**空觸發**整段起義流程（print + 鄰格恐懼 cascade + 取消施工副作用；即使 `clear_team_faction` 本身 no-op）。measurer occupancy-map 血證：rep 床 Team5 對已 independent 自己 4 次空 uprising。
- **fix**：開頭加 `if team.faction_id == -1: return`（gate-ok guard、非決策閘）。

## ★注（透明）：diplomatic_ai revert incident
g3 counter 首次 apply 後被 linter/concurrent 過程 revert（系統 "modified by user/linter" note）→g3_test regression 抓到（saved 也叛）→**已 re-apply + commit lock**（git 保全）。re-apply 後 g3_test 4/4 復綠。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `g3_betrayal_bond_test` | **4/4**（①★分化命門 同 personality+盟弱 被救→不叛/沒被救→叛 / ②genuine opportunism stay≈0 仍過 0.65 / ③共享 helper / ④零 god-view 竄改他隊不變） |
| `faction_cohesion_test` | 6/6（guard 不影響、re-confirm） |
| headless | **0-new**（uprising guard 不動 faction-member uprising、只擋 independent 空觸發） |
| constitution_gate | **PASS sites=74 removed=0** |
| determinism | 3-run（GODOT_TIMEOUT=1200、seed1337 1mo）MD5 `28C07CF10F26EB3378F578D22907AE2E` **byte-identical**（≠cohesion-alone 7CB7D680＝g3 counter + uprising guard 行為真改） |

## 路
1. **你 R²**（審 g3 counter §1 雙向/共享 helper 一套/零 god-view + uprising guard cheap-win）。
2. → measurer re-measure：**★③下游解鎖真驗**（rep 床 `config/infonet_faction_rich_rep.json` 不再秒崩、factions>1、established>0）+ 4 出口佔比 map（判 cohesion+g3 是否真解 faction-fragility、有無第 5 出口）+ 分化（好領主/被救勢力持久、該叛照叛）。
3. → QA 新 verdict。

★仍待辦（另 dispatch）：**ledger defensive/rescue 真 consumer fix**（QA REFUTE 手不聽腦、feat/missing-contact-ledger 分支）——接著做。**HOLD-warm 待 R²。**
