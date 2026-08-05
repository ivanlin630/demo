---
from: implementer
to: systems
status: consumed
topic: "[勢力凝聚力 DONE·feat/faction-cohesion commit 90631616]P4 主刀:新 _faction_stay_benefit(relief_memory 自身 benefactor + heard_reputation belief、人格 mod、零 god-view)+★benefactor write@distribute settle(P4 地基)+defect 死 cliff→連續 defect_util=distress×deficit−stay_benefit(保 unrest>=20 gate)+整併三決策點(a_score=honor+stay_benefit)+uprising 後果秤(守城後 stay vs secede)。驗:cohesion_test 6/6(★分化命門 被救→留/沒被救→走+零god-view+該散的散+uprising 後果)+headless 0-new+constitution 74+determinism 7CB7D680 byte-identical(≠baseline=行為真改)。★立國查根:根='立國'goal 從未 emit(orphan consume:1820/erase:4501)=正統 arc 記檔非本批。uprising gate→連續 polish 小 follow-up defer(consequence 主刀已做)。請 R²(§1 防crank 雙向/零god-view/人格非死常數)→measurer(好vs爛領主壽命分化+該散照散、無配額)→QA。"
branch: feat/faction-cohesion
commit: 90631616
---

# 勢力凝聚力 — DONE（路 systems R²）

照 spec `2026-08-05-faction-cohesion-HOW`（R² CLEAN、blueprint LOCKED、grounding=exit GENUINE）build 完。主刀＝給真餓 member 留下的理由（P4 真好處接留走秤）、非拆 genuine 出口。

## PRIMARY
- **①`_faction_stay_benefit(state, team)`**：`W_RELIEF(0.7)×relief_memory + W_REP(0.3)×heard_reputation`，人格 mod（義氣/信義高→更重恩義 [0.5,1.5]）。`relief_memory`=自身 benefactor memory 指向領主（被救次數飽和 [0,1]，`COHESION_RELIEF_SAT=3`）；`heard_reputation`=`known_reputations[領主]`（belief）。**★零 god-view**（讀 self memory + 自身 belief、禁全知 relief 統計）。
- **②★benefactor write@distribute settle**（`interaction_system:877`、P4 地基）：relief 真送達 resident（`override_ask>=0` 免費直注 settle 成功）→ resident leader 寫 `benefactor` memory（benefactor=領主=convoy 母隊 `visitor.parent_team_id`）。**沒它 stay_benefit 讀不到 relief 史**。
- **defect refine**（`event_faction_defect.check`）：honor/trust 死 cliff → **連續 `defect_util = distress_pressure(unrest 連續) × loyalty_deficit(honor/trust 連續) − _faction_stay_benefit`，fire if >0**。★保 `unrest_turns>=20` precondition 不動（genuine distress gate、measurer 證）；`execute clear_team_faction` 不動（genuine exit 保留）。
- **③整併**（三決策點統一）：`_trigger_defection_evaluation` `a_score = honor + has_benefactor_memory(flat0.3)` → `honor + _faction_stay_benefit`（rich relief-memory+reputation 取代粗糙常數；觸發仍 ledger domain 不碰）。

## SECONDARY
- **uprising 後果秤（主刀）**：`_evaluate_uprising` Path A 守城後**別無條件 `clear_team_faction`**→秤 `stay_u(honor×0.5 + stay_benefit)` vs `secede_u(ambition×0.6 + (1−honor)×0.4)`：高義氣/被救→**留勢力換新**（不脫 faction、`cohesion.uprising_stay_faction`）、野心/低 stay→自立脫離。Path B 流亡保留脫。
- **⚠ uprising 3 前置門→連續 polish**：**本批未做**（consequence-weigh 是 uprising 主刀、已做；gate→continuous 會動 firing behavior=風險，留**小 follow-up**）。flag 待你裁要不要本批補或另批。

## ★立國 goal 查根（P3）
- **根：`"立國"` goal token 從未被 emit**——無 `_emit_goal(..., "立國", ...)` caller（`_emit_goal` 全 caller 傳 攻擊/徵收/外交）；`:1820` consume + `:4501` erase **orphaned**。∴ founding 路 `if "立國" in f.goals` 恆 false → `_declare_established` never fires。
- **scope=大**（何時 declare established＝legitimacy WHAT、屬 立國/正統 arc）→ **記檔、非本 arc 順修**（順修 assign 需先定 legitimacy 準則=WHAT）。建議歸 立國/正統 arc。

## contact-loss（④）
**DEFER → 失聯帳本 ledger arc domain**（blueprint 定、本 arc 不碰）。

## 守
- **零 god-view**：stay_benefit 讀自身 benefactor memory + 自身 known_reputations belief；禁全知 relief 統計。`constitution_gate` PASS 74。
- **§1 防crank 雙向**：distress 真 / stay_benefit 真、引擎秤；**只加 stay-side、無 boost 逼留、無刪真走**（defect/uprising exit 保留）、**無配額**。
- 人格非死常數（honor/trust/loyalty/ambition 連續 weigh）；determinism 純算術+memory 讀、benefactor write 零 RNG。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `faction_cohesion_test` | **6/6**（★①分化命門：同餓+同低honor 被救→不defect / 沒被救→defect / ②好領主 stay 0.97>爛 0.06 / ③relief→benefactor write / ★④零 god-view 竄改他隊/領主 live 不變 stay_benefit / ⑥該散的散 暴君仍 defect / ⑤uprising 後果秤 stay 1.71>secede 0.34） |
| headless | **0-new** |
| constitution_gate | **PASS sites=74 removed=0** |
| determinism | 3-run（GODOT_TIMEOUT=1200、seed1337 1mo）MD5 `7CB7D680934A8F5830AA699A0F0D5787` **byte-identical**（≠baseline 9290F462＝cohesion 行為真改：defect 連續 util / benefactor write / uprising 後果 fire） |

## 路
1. **你 R²**（審 §1 防crank 雙向[只加 stay-side 無 boost 逼留無刪真走無配額] / 零 god-view / 人格非死常數 / 整併三決策點一致精度 / uprising 後果秤 + gate-polish defer 裁）。
2. → measurer：**好領主 vs 爛領主壽命分化**（同機制人格產不同、暴君失人心案例仍在=該散照散）+ 下游解鎖（rep 床不再秒崩→relief 長窗 + L3 cross-faction 可行使）+ **零配額**（禁「X% 存活」）。
3. → QA 故事稽核（留/走案例逐個合人格）。

★faction-cohesion 是同批第三 slice（前二：L3 循環貿易 06c8b452、失聯帳本 a3c11288，皆已 handback）。**HOLD-warm 待 R²。**
