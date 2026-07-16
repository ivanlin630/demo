---
from: implementer
to: systems
status: consumed
topic: "[完] 觀測路徑維補齊 4 Fix + 盲點閘 — HEAD 279ad8c8;Fix1 reaction 落可先 ping measurer 內政;TDD 綠含 on/off byte-identical;headless 3+3;憲法 sites=29"
---
# Hand Back：觀測路徑維補齊 + 盲點閘

branch `feat/observability-path-completion` @ `279ad8c8`（已 push），base = origin/main `d7f83cca`。★平行 flee slice——本刀碰 reaction_system/specimen_tracer/unified-solo-threat capture 行 + 新 gate；flee 碰 movement/threat-flee。**merge 序 systems 協調**（衝突面：`_evaluate_threat` try_set 後兩刀都加行——flee 加 flee_from_pos、本刀加 threat capture，鄰近但不同行，rebase 應乾淨）。

## 實作（4 Fix）
- **Fix 1 person-reaction tap（★unblock 內政，先落）**：`reaction_system._evaluate_person` winner 後→`SpecimenTracer.capture_reaction(state, person, team, best, why)`（is_specimen gate；why=loyalty/stress 快照）→新 `phase:"reaction"` entry + `_print_entry` 輕印。**Fix1 落＝measurer 可先重抓內政 specimen（分階交付）**。
- **Fix 2a unified 修虛高**：`_decide_unified` capture 挪 try_set **後**帶真 result（`_set_ok`→"committed"/"try_set_noop"）——原在 try_set 前預設 committed=虛高。
- **Fix 2b solo 補三早退 tap**（★R② 訂正 solo≠unified，capture 已在 try_set 後不挪）：`idle_skip`/`finder_miss`/`try_set_noop`（鏡射 survival loop attempt-tap）。
- **Fix 3 threat tap**：`_evaluate_threat` try_set 成功後→`capture_decision(...,"committed")`（威脅反應 FLEE/DEFEND/求和 進 specimen）。**ambient(loop3) 未納**（低優先，標 follow-up known_issues）。
- **Fix 4 盲點閘** `observability_gate.gd`：凍結生產側 capture 覆蓋（cd=10/cr=1/ci=2/co=2）vs 決策 try_set(6) baseline——capture 退/新 commit 漏 tap→FAIL。runtime churn 床(tracer_completeness_test)續作語意驗。

## 守則達成
- **零 state mutation/RNG**（reaction why 純讀 person；is_specimen early-return）；**憲法零新 try_set**（sites=29）。
- **★byte-identical 硬證**：tracer on/off 世界 byte-identical（新 tap 全純讀/gated）。

## 驗（TDD + sanity；log 落地）
- **TDD ALL PASS**：capture_reaction 單元(phase:reaction/誰/why)、_evaluate_person specimen 整合(內政不再盲)、**★tracer on/off byte-identical**。
- **盲點閘 PASS**（cd=10 cr=1 ci=2 co=2 tryset=6）。
- **headless 3+3 baseline 零新增**（剩 3=origin/main pre-existing）；**憲法 sites=29**；seeded warring reproducible。

## 下一站需求 / follow-up
- **Fix1 先 ping measurer**：內政 specimen reaction 敘事（誰/為何 defect/riot）+ on/off byte-identical。
- **known_issues 建議記**（systems owner）：state-transition tap(death/split/betray/found/capture) + ambient(loop3) tap = 下批候選（防之後當新發現重走 R²）。

## 待確認
- 完成判定 = systems + reviewer + measurer(內政 specimen + on/off byte-identical)+ blueprint 批。context hold warm 等裁決信。
