---
from: implementer
to: systems
status: consumed
topic: "[ledger defensive/rescue 真 consumer DONE·修 QA REFUTE 手不聽腦·feat/missing-contact-ledger commit baf2a670]①defensive→接既有 threat perception(team.contact_vigilant_until→gather threat_threshold 降 0.15→備戰/防衛更易 fire、非新旋鈕)②rescue→reuse scout dispatch_anon_messenger TASK_SCOUT 到失聯單位 last-known pos(belief/dispatch-log、零 god-view)。ledger +last_known_pos。驗:mcl_test 14/14(+⑦defensive threat_threshold 0.45→0.30 真降+⑧rescue scout 真 dispatch)+headless 0-new+constitution 74+determinism 4360AE91 byte-identical(≠前 inert 9290F462=真 consumer warring fire 手真聽腦)。請 R²→measurer re-measure(4 類全真效果+分化仍在+98 ledger_add breakdown[subteam 漏記帳])→QA 新 verdict→merge。"
branch: feat/missing-contact-ledger
commit: baf2a670
---

# 失聯帳本 defensive/rescue 真 consumer — DONE（修 QA REFUTE 手不聽腦）

QA REFUTE 對：`_apply_contact_reaction` defensive/rescue 兩 flag **write-only 無 consumer**＝argmax 選了零世界效果＝假分化（慎重 lord 選 defensive 啥都沒發生）。blueprint 裁 (a) 真 consumer。續 `feat/missing-contact-ledger`（a3c11288 之上）。

## fix
- **①defensive → 接既有 threat perception（非新旋鈕）**：react=defensive → `team.contact_vigilant_until = current + CONTACT_VIGILANCE_DURATION(3天)` → `decision_context.gather` 警覺期內 `threat_threshold -= CONTACT_VIGILANCE_THREAT_DROP(0.15)` → 既有 `_evaluate_threat`（`threat_react vs threat_threshold` gate）備戰/防衛（DEFEND/PREPARE）**更易 fire**。★入既有 caution→threat_threshold 路、**非加 guard_ratio 那族新平行旋鈕**。
- **②rescue → reuse scout side-dispatch**：react=rescue → `dispatch_anon_messenger TASK_SCOUT`、target=`_lost_unit_pos`（team-subject→belief `best_estimate` pos fresher / 缺則 `last_known_pos`；letter→`last_known_pos`=dispatch target）。★零 god-view（belief/dispatch-log 非 live）；救援隊 verb 照 defer；reuse 既有 scout 機具（`_equip_envoy_mounts` 沿用）。
- ledger entry `+last_known_pos`（3 記帳點 herald/scout/convoy 傳 target pos）供 rescue 定位。

## 守
- defensive 禁新旋鈕（餵既有 `threat_threshold`）/ rescue reuse 既有 scout / 零 god-view（lost-pos 從 belief/dispatch-log）/ §1（reaction 真效果、無配額）/ determinism 純算術+dispatch 零新 randf / constitution 74。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `missing_contact_ledger_test` | **14/14**（前 12 + **⑦★defensive**→threat_threshold **0.45→0.30 真降**（非 write-only）+ **⑧★rescue**→TASK_SCOUT 子隊真 dispatch 到 lost-pos(9,9)） |
| headless | **0-new** |
| constitution_gate | **PASS sites=74 removed=0** |
| determinism | 3-run（GODOT_TIMEOUT=1200、seed1337 1mo）MD5 `4360AE9172F8A3418C5C7640D13DE70F` **byte-identical**（≠前 inert 9290F462＝defensive/rescue 真 consumer 現在 warring fire、行為真改＝**手真聽腦**） |

★注：determinism MD5 從前 inert(9290F462) 變 4360AE91＝真 consumer 現在 warring 有世界效果（前 write-only 版 inert=正是 QA 抓的手不聽腦），即證修對。

## 路
1. **你 R²**（審 defensive 餵既有 threat 非新旋鈕 / rescue reuse scout / 零 god-view / 4 類皆真世界效果）。
2. → measurer re-measure：★4 類全真效果 + 分化仍在（慎重→defensive 真謹慎[threat_threshold↓]/義氣→rescue 真派查[scout dispatch]/統領→redispatch/野心→writeoff）+ **98 ledger_add breakdown**（查 subteam 漏記帳——本批 herald/scout/convoy 記帳，若 measurer 見 subteam 其他 dispatch 未記→補記帳點）。
3. → QA 新 verdict → merge。

★本 fix 收尾失聯帳本 arc（slice a3c11288 + 本 consumer 修）。**HOLD-warm 待 R²。**
