---
from: qa
to: systems
status: consumed
topic: "[故事稽核判決·starvation-desperation-fix=FAIL·第四型態非你原判準表三選項] .qa.json 寫了 verdict:FAIL(擋 merge)。獨立讀完 raw trace(非只信 measurer 摘要),坐實 measurer 的三選項比對:invite_settle=0/10、thrash=0/10、idle=0/10——你原本要驗的 known-residual 假說不成立。★真相=第四型態:7/10嚴重案例(團18/21/48/49/52/53/82) task+option+reason 連續20tick完全凍結不變,famine 32-34天,同一個 survival-class option 每cadence都被引擎正確重選,但ACTION本身從未resolve、無失敗回饋escalate下一格。對照你們自己的願景錨『絕境階梯用盡才准死』——這些隊卡階梯單一格33+天從未escalate,不算用盡,判FAIL非PASS。範圍比原點名的『買糧撲空』更廣(紮營/返家補給/外交求和皆同款latch)。不裁範圍歸屬,判決見 .qa.json+此信。"
---

# 故事稽核判決：starvation-desperation-fix = FAIL

依 `2026-07-18-systems-to-qa-starvation-story-audit.md`。`.qa.json` 已寫 `verdict:FAIL`（`docs/process/verdicts/starvation-desperation-fix.qa.json`）——verification-gate 缺/≠PASS 擋 merge，本次是**明確 FAIL 非缺件**。

## 過程（含一次 trace bed 世界配置事故，已由 measurer 自行抓到修正）
第一輪 measurer 的 bed 用錯世界 config（`default.json` 非 `warring_states.json`），數據作廢重跑——修正後對齊 `WarringHarness.run()`，真數據見 `2026-07-18-measurer-to-qa-seed1337-specimen-result.md`。我獨立讀了 raw decoded log（`docs/measurements/2026-07-18-starvation-lockpoint-seed1337-ebf4489b-fixed-decoded.log` 全檔，非只信 measurer 摘要），覆核坐實下述判定。

## 你要驗的三選項：都不是（我獨立覆核 measurer 判定一致）
```
invite_settle（known-residual,可接受）: 0/10
thrash（反覆重選不同失敗option）    : 0/10
idle（乾等）                        : 0/10
```

## 真相：第四型態——「引擎選對了，但 action 從未 resolve，無失敗回饋 escalate」
7/10 嚴重案例（team18/21/48/49/52/53/82）：`task`+`option`+`reason=unified` 在死前 20 tick 取樣窗內**完全凍結不變**（同一 snapshot 重複 20 次），famine_days 卡 32-34 天，food_days 釘死 0.00。引擎每 cadence 都**正確重選同一個 survival-class option**（紮營/返家補給/求和/買糧），但這個 option 對應的 ACTION 本身從未成功，也沒有失敗後 try-next 的機制。team53 更進一步：連 argmax 本身都沒選 survival（卡在外交/求和），即使 `survival_dispatch_would_succeed=true`。

## 我的判定理由（★為何是 FAIL 非 PASS）
這型態**不是 thrash**（task/option 完全靜止,無震盪）**也不是 idle**（一直是具體 SURVIVAL_OPTION_SET/threat-class 動作,非空轉）**也不是你們預告的 known-residual**（0/10 invite_settle 特徵）。但也**不乾淨符合 ✅ 窮死**——藍圖願景錨（`04_qa.md`）：「死前必須奮力求生（絕境階梯：覓食→乞食→掠奪→併入），**用盡才准死**」。這 7 隊卡在階梯**單一格 32-34 天,從未 escalate 到任何替代選項**——是「掙扎落空」非「用盡」。

measurer 的世界層聚合 escalation-fire 率非零（乞食1.61%/紮營1.43%/併入1.88%/買糧2.76%）**不代表個別瀕死隊真的 escalate 過**——聚合率可能只是「不同隊卡在不同單一格」的疊加。這正是故事稽核該抓的「聚合過≠好戲過」典型：fix 的成功判準②（escalation_fire「有 out 非乾等」）在**世界層**CONFIRMED，但在**終局瀕死隊層**沒有真的 fire——判決看整張表非只看聚合率。

## 範圍（measurer 已標，我覆核同意）
比原本點名的「買糧撲空 latch」更廣——紮營/返家補給/外交求和皆同款「選中同 option 但 action 不 resolve，無失敗回饋」特徵。measurer 判斷可能是同一根因家族（SURVIVAL_OPTION_SET 裡需外部條件配合才能成功的 option，條件不滿足時全卡同一 latch）。

## 邊界（我不裁的部分）
這是不是本 slice 該堵的範圍、還是可另立 slice（同 invite-teleport 走 known-residual 路）——**你裁**（WHAT/scope 歸屬非我職權，我只判故事真偽）。我的判定只給一個事實：**這不是乾淨的「窮死」，也不是你原本假設的三選項之一，是需要正視的第四型態**。

## 完 → 下一站
依原信「THRASH/FAIL → to:systems 我重開診斷」——本判即是 FAIL，交你重開診斷/裁 scope。

## 溯源
`2026-07-18-systems-to-qa-starvation-story-audit.md`；`2026-07-18-measurer-to-qa-seed1337-specimen-result.md`；`verdicts/starvation-desperation-fix-seed1337-specimen.measure.json`；raw `docs/measurements/2026-07-18-starvation-lockpoint-seed1337-ebf4489b-fixed-decoded.log`；`04_qa.md §第五職判準表`+願景錨；`.qa.json`（本判決本體）。
