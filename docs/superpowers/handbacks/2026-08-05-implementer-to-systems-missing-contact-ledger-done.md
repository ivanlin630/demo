---
from: implementer
to: systems
status: consumed
topic: "[失聯帳本 DONE·feat/missing-contact-ledger commit a3c11288]共享 _contact_elapsed_days(母↔子一套、重構 _evaluate_owner_contact 走它=防第4散落點)+TeamData.dispatch_ledger(herald/scout/convoy 記帳+letter-deliver/subteam-merge 清帳)+_step_contact_ledger(overdue_ratio 連續→失聯 belief→★競爭 react_util 4 類 argmax 非 if/elif=hard-track命門)。驗:mcl_test 12/12(★競爭 react 4 類皆勝其人格軸+零 god-view live 竄改 elapsed 不變)+headless 0-new+constitution 74+determinism 9290F462 byte-identical(warring 1mo inert、真反應需 targeted 床)。請 R²(硬追蹤:react_util competing candidate set 非退化)→measurer(失聯→反應人格分化)→QA。"
branch: feat/missing-contact-ledger
commit: a3c11288
---

# 失聯帳本 — DONE（路 systems R²）

照 spec `2026-08-05-missing-contact-ledger-HOW`（R² CLEAN、blueprint LOCKED）build 完。通例統一非特例、reuse 既有 last_tick 原語母↔子一套。

## 三塊
- **①共享失聯原語 `_contact_elapsed_days(state, observer, is_team, subject_ref, dispatched_tick)`**：team subject→`best_estimate.last_tick`（既有 belief provenance、-1=未接觸）；非-team(letter)→`dispatched_tick`（自我 dispatch-log）。**★重構 `_evaluate_owner_contact`（子→母）改呼此**＝雙方向**一套失聯感知**（R① 整併義務、防第 4 散落點）。`CONTACT_TIMEOUT_DAYS` 硬門檻本批不動（照妖鏡 faction-balance 批、blueprint 定）。
- **②`TeamData.dispatch_ledger` + 記帳**：herald（letter、is_team=false、subject_ref=spawn_tick）/ scout（sid）/ convoy（sub_id）spawn 後 append；`expected_return_tick = dispatched + _round_trip_ticks(dist×BASE_MOVE_TICKS×2 + 1日 service)`＝**機械估 DERIVED 真移速、零人格**。清帳 hook：letter **deliver→resolve**（timeout/intercept **不清**＝沉默即資訊→母逾時反應）、subteam(scout/convoy) merge-back→inline resolve。
- **③`_step_contact_ledger`（cadence per-team、掛 `info_side_dispatch_all`）**：掃未 resolved、`overdue_ratio = elapsed/expected`（連續值）>1→失聯 belief（`entry.lost`、★零 god-view 只知逾時、不知對方真死活）→**★競爭 react_util**。

## ★★hard-track命門：react_util = competing candidate set（非 if/elif）
`_pick_contact_reaction(overdue_ratio, lv)`：4 反應**各算 util = overdue_ratio × 人格加權**，**argmax 選最高**：
```
redispatch = overdue_ratio × (0.3 + 統領×0.7)   # 重資產→再派查明
defensive  = overdue_ratio × (0.3 + 慎重×0.7)   # 多疑→防禦準備
rescue     = overdue_ratio × (0.3 + 義氣×0.7)   # 重情→救援意圖 flag
writeoff   = overdue_ratio × (0.3 + 野心×0.7)   # 冷酷→註銷當沒了
```
- **★禁 if/elif 人格特質揀死一條**（=偽 util 死門檻退化）——4 類進**同一候選集 argmax**、同求援/偵察 mini-util 候選集模式。TDD case ④ 硬驗：4 種人格各令其對應反應**勝出**（統領→redispatch / 慎重→defensive / 義氣→rescue / 野心→writeoff）＝每類皆可被 argmax 選中、非死揀。
- 反應接既有 side-action 動詞：redispatch→`_try_herald_side`/`_try_scout_side`（不新建）；rescue→flag（救援隊新動詞**不在本批**、待 blueprint sign-off side-action 新型）；defensive→belief flag；writeoff→resolved 結案。

## 守
- **零 god-view**：帳本=自我 dispatch-log + elapsed（own memory）；team-subject 走 belief `best_estimate.last_tick`；**禁查對方 live 死活/位置**；失聯 belief 只含「我多久沒消息」。`constitution_gate` PASS 74。
- **通例統一非特例**：一帳本 + 一共享原語（母↔子收斂）；反應 reuse 既有 side-action。
- **人格非死常數**：反應=mini-util 人格加權、逾時 ratio 連續進 util、禁硬門檻必派。
- **機械估 DERIVED**：round_trip=真移速×2+service、零人格（人格只在反應端）。determinism 零新 randf。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `missing_contact_ledger_test` | **12/12**（①記帳 expected 機械估 / ②共享原語 team=belief/letter=dispatched/未接觸=-1 / ③逾時偵測 / ★④競爭 react argmax 4 類皆勝其人格軸 / ★⑤零 god-view live-pop 竄改 elapsed 不變 / ⑥清帳不再反應） |
| headless | **0-new**（Team23/弱目標/3 baseline pre-existing） |
| constitution_gate | **PASS sites=74 removed=0** |
| determinism | 3-run（GODOT_TIMEOUT=1200、seed1337 1mo）MD5 `9290F462BD4A01B542A4519A091FCA79` **byte-identical**（=baseline＝warring 1mo 窗 **inert**：該窗無派出單位逾時觸反應、零新 randf；**真反應效果需長/targeted 床 measurer 驗**、同 free-relief bed-specific pattern） |

## 路
1. **你 R²**（★硬追蹤：react_util 4 類確為 competing candidate set argmax、非 if/elif 退化——TDD case ④ 已證；+ 共享原語母↔子一套 / 零 god-view / 機械估 DERIVED / 人格非死常數）。
2. → measurer：失聯事件→反應 fire 且**人格分化**（務實派查多/冷酷註銷多、per-option util dump）+ 領主對久無音訊村查訪（子→母 既有 + 母→子 新兩方向一套）+ 零 god-view 洩漏。**需長/targeted 床**（warring 1mo inert）。
3. → QA 故事稽核（派出→失聯→人格反應鏈）。

★照妖鏡候選記 faction-balance 批（非本批、spec §追蹤）：`CONTACT_TIMEOUT_DAYS`/`OWNER_CHANGE_BUFFER_DAYS` + 10+ 子單位側 timeout 死常數。

★失聯帳本是 2 補完批之二（另：L3 循環貿易 feat/L3-circuit-trade commit 06c8b452、同批已 handback）。**HOLD-warm 待 R²。**
