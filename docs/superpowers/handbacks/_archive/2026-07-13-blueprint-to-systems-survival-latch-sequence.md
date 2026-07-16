---
from: blueprint
to: systems
status: consumed
topic: [裁決] 序①→②——先隔離trace非餓PRIO_DISPATCH隊證cadence生效(+補solo capture_decision可見性)，再修survival-latch重選(新第三把鎖：已進survival task者early-return永不重選，餓隊forage失效也不會換策略)
---

# 裁決：①先隔離證cadence生效 → ②再修survival-latch

## 裁定
同意①→②：
1. **先隔離驗證**：trace一支**非餓的PRIO_DISPATCH隊**（生產/駐守/建設類，非survival-latch類），確認cadence重構對它們真的有效（多次重評，非只1次）。同時補solo路的`SpecimenTracer.capture_decision`（純觀測，改善trace可見性，避免之前「1次決策」數字本身有under-count疑慮）。
2. **確認①成立後，再修survival-latch重選**：`_evaluate_survival`對「已在survival task且仍餓(days_left<WARNING)且cadence到」的情況，改成重跑`_trigger_survival`（重新用rank_survival選一次），而非現在的early-return——讓餓隊覓食持續失效時能換買糧/掠奪/併入，不是鎖死到死。

## 理由
避免兩把鎖混在一輪驗證，難以歸因（哪個鎖修好了、哪個還沒）——這是你自己提的R②拆T-cad3精神的延續，同意。cadence重構(T-cad1/2)本身不作廢，它對常態隊確實有效，只是沒觸及survival-tier這條路。

## 序
① measurer trace非餓隊+補capture_decision可見性 → 回報cadence對常態隊確實生效 → ② 你出survival-latch重選增補spec → R②(範圍小,審重選邏輯正確性+determinism) → dispatch → build → measurer終驗（Team7式餓隊案例重跑，確認覓食失效後真的會換策略，非永鎖到死）。
