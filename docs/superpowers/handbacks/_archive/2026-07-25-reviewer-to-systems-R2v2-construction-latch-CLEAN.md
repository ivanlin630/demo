---
from: reviewer
to: systems
status: consumed
topic: "[R②v2 CLEAN] construction commitment latch——force_reeval 設計確認關洞，且我自己排查過沒有第二個同款漏洞，dispatch implementer"
---

# R②v2 判決：construction commitment latch（force_reeval 訂正）— CLEAN

## (1) force 參數繞法——確認真解威脅悶死
`if force_reeval: return true` 放在 `_should_reeval` 最前面（latch/cadence 之前），結構上跟既有 crisis-edge/directive_fresh 是同款「各自獨立的緊急重評理由各給一個 bypass」模式，非臨時補丁。`:423` 改 `_decide_unified(state,team,true)` 後，威脅段能穿透 latch+cadence 兩關直達重評——邏輯上洞確實補上。

## (2) 憲法論證訂正——四路例外對應對
威脅→force_reeval bypass（非原先誤引的 stuck/crisis）/深餓→crisis edge/命令→directive/卡住→stuck，四路各自獨立 gate，latch 只擋純例行 cadence 的經濟 argmax——訂正後論證跟 code 實際結構一致，不再有落差。

## (3) ★我自己排查「還有沒有第二個同款漏洞」——沒有
你問得對，這值得認真查非空口確認。**grep 全檔 `decision_eval_next_tick\s*=` 逐條核對**：
- `:422`（威脅段）：`=current_tick`（無 offset，立即生效）——就是本輪抓到並修的那個。
- `:1525`/`:1926`（`_decide_unified`/`_evaluate_solo` 內部）：`_should_reeval` 已回 true **之後**才排下次 cadence（下游排程，非上游繞過），不是同款漏洞。
- `:3486-3487`：讀過上下文（`:3475-3493`）——這段在 `team.current_task in SURVIVAL_TASKS` 分支內，**直接 `TaskArbiter.release(team)` + 呼 `_trigger_survival`**，完全不經 `_should_reeval`/`_decide_unified` 這條路；且到這分支時 `current_task` 已是 survival-class task（非 TASK_BUILD），跟新 latch 不會有交集。offset 是 `+DECISION_CADENCE`(非0)，本來就是排未來 checkpoint 非立即繞過。

**結論：全檔只有 1 個「reset timer 讓 cadence 分支誤判過」的模式，就是這次抓到並修的那個，沒有兄弟漏洞。**

## TDD 要求——確認落實
§69-74 明文要求威脅繞 latch 測（`threat_react≥threshold+PREEMPT_MARGIN`）跟深餓測（crisis edge）分開兩條，不用深餓頂替威脅——吻合我原要求。

## 判決
**CLEAN → dispatch implementer。** 驗收硬標準沿用（execution-verified，`outpost_built>0` 才收，非只 R②綠燈）。
