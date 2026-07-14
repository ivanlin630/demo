---
from: reviewer
to: systems
status: consumed
topic: "[R²判決·issues] tracer-completeness spec——根因/三態邏輯/heartbeat設計皆CLEAN,但Fix3 static baseline數字錯(capture_options現2非1,tripwire自己起跑就不準);另一項player-join早退路徑advisory"
---

# R² 判決：tracer-completeness spec

verdict: **issues**
premise_contradiction: false

## 根因驗證（file:line 全查證）

`faction_ai_system.gd` 逐一核對：`capture_decision` 確認唯 4 call-site（`:1480`attack/`:1523`unified/`:1876`solo/`:3217`survival），與根因分析信一致。`_trigger_survival`（`:3195-3219`）逐行核對：`:3205` finder 撲空 `continue`（true）、`:3213` `try_set` 呼叫、`:3216 if _surv_ok:` gate、`:3217` capture_decision 在成功分支內——commit-gated 診斷精確坐實。`evaluate_all:609` 存在，Fix 2 sweep 插入點對。

## Fix 1/2 設計驗證

- **attempt-tap result 語意**：`committed`/`finder_miss`/`try_set_noop` 三態對應 `:3205`/`:3213`(fail)/`:3216`(success) 三個分支，涵蓋完整，設計合理。
- **heartbeat sweep 位置**：`evaluate_all` 末尾，所有決策路徑（unified/solo/survival/attack）皆已跑完才 sweep，位置對；`_last_entry_tick` 由 `capture_decision` 更新、sweep 查本 tick 有無 entry 才補——不重複膨脹的邏輯站得住。churn 期間密 entry 自然壓制 heartbeat，語意一致（你信中自己提的這點我認同）。
- **byte-identical 驗收**：與稍早 confound-fix 那輪（`observe_velocity` suppress 包裹）CLEAN 判決一致，非新增假設。

## issue：Fix 3 static tripwire 的 baseline 數字錯

spec `:42`「現 4 capture_decision + 2 capture_intent + **1 capture_options**」——`grep SpecimenTracer.capture_options scripts/` 確認**現有 2 處**（`decision_engine.gd:18` rank_scored、`:124` rank_survival，皆已帶 `ctx` 參數，是稍早交易/威脅 tap 那輪 CLEAN 後落地的）。spec 寫「1」是錯的。

**為何不只是小抄寫錯**：Fix 3 的 static tripwire 本質是「凍結一個精確 call-site 計數當 baseline，未來新增決策點沒伴隨 capture → 計數比失衡示警」——這個機制的正確性建立在 baseline 數字本身要準。若 implementer 照抄 spec 的錯誤數字（1）當 baseline，這個「弱訊號防線」從第一天就跟實際 code（2）對不上，未來真出現計數失衡時反而分不清是「新洞」還是「baseline 本來就記錯」。**要求**：spec 訂正為「4 capture_decision + 2 capture_intent + 2 capture_options」。

## advisory（非阻擋，供記錄）

`_trigger_survival:3208-3212`「投靠對象是玩家隊」分支：`_maybe_request_join_player` 回 true 時整個函式提前 `return`（`:3212`），完全繞過 `:3205`/`:3213-3217` 三個 tap 點——這是 Fix 1 三態（committed/finder_miss/try_set_noop）沒涵蓋到的**第四種 attempt 結果**（「請求送出待玩家答覆」）。範圍窄（僅 `opt=="併入"` 且 target 恰為玩家隊、`state.player_id != -1` 時才會走到），headless AI churn specimen 床（無 active player）大概率不會命中，不要求本刀處理，但值得留一筆記錄（未來若做玩家互動向的 story-QA 才會浮現）。

## 框外審評估
同意——根因已 code 定音，增量設計非新概念大框，標準審足夠。

## 結論
根因/Fix 1/Fix 2 設計 CLEAN。**唯一 issue＝Fix 3 static baseline 數字錯**（1→2 capture_options，一行訂正）。**issues → halt，退回訂正數字後可 CLEAN**（非重新設計）。
