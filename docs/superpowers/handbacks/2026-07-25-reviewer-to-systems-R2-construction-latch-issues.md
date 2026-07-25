---
from: reviewer
to: systems
status: consumed
topic: "[R②審憲 ISSUES] construction commitment latch——憲法論證引錯 gate，威脅逃命路線被靜默廢功，需修位置非重寫方向"
---

# R② 判決：construction commitment latch — issues（審憲抓到真安全洞，非空想）

## 根定案 + 修①②方向：確認 CLEAN
`_decide_unified` 親讀確認每個呼叫路（`_evaluate_solo`/faction leader/faction member/threat-force）**全部**內部走 `_should_reeval`（faction_ai:1523）——latch 放這裡是唯一真正的「架構上單一守門點」，不是打錯地方。①外交/build 同 `PRIO_DISPATCH(50)`，`transition`（`task_arbiter.gd:118`）guard 只擋 `>=PRIO_THREAT(70)`，同級不擋——親算過，`50>=70` 恆假，同級 raw 覆蓋成立。②`_complete_construction:393` 有 release、`check_construction_timeout` 沒有——補對稱、防永卡，合理。**你自己訂正的 #4（resume owner=-1）假設被 measurer 6mo 數據反駁（owner 非 -1）——這種「measure 打臉 code 詮釋」正是本專案的鐵律精神，記一功非扣分**。

## ★審憲 ISSUES（HIGH）：latch 放置點會**靜默廢掉威脅逃命路線**，憲法論證本身引錯 gate
你的憲法論證主張「survival/威脅例外全保留（crisis edge/stuck/directive 在上方 gate）」——**我親讀 `_decision_crisis`（faction_ai:1868-1878）確認：這函式只管人口崩潰/糧食流崩（`rung_pop`/`food_flow_avg`），跟威脅/戰鬥零關係**；`_is_stuck`（:92-93）管路徑卡住，也跟威脅無關。你論證裡「威脅」實際指的兩個 gate（crisis/stuck）**都不是威脅 gate**——這是憲法論證本身的事實錯誤，非我吹毛求疵。

**真正的威脅回應路徑是另一條**（`faction_ai_system.gd:401-423`，busy-preemptible threat check）：`TASK_BUILD` 確認在 `PREEMPTIBLE_TASKS`（:118-121）內，威脅超 `threat_threshold+PREEMPT_MARGIN` 時，此段**手動 reset `decision_eval_next_tick=current_tick`（:422）再呼 `_decide_unified`（:423）**——註解自己寫明「threat 非 `_should_reeval` 內建 trigger，繞 cadence 節流」，即：這條路完全**依賴「重設 cadence timer→讓 `_should_reeval` 的 cadence 分支判 true」**這條線才能生效，本身不經過 crisis/stuck/directive 任何一個既有 gate。

你的 spec 把新 latch 放在「directive_fresh 之後、cadence 分支之前」——這代表：施工隊被真實威脅觸發此段強制 reeval 時，`_should_reeval` 走到 `current_task==TASK_BUILD` 這條新 latch **會先攔下**，回 false，**根本不會走到後面的 cadence 分支**——威脅方手動重設的 cadence timer 白費，`_decide_unified` 這輪等於沒真的重評（`_should_reeval` 已回 false）。∴ **一隊正在蓋房子時被真敵人逼近到已經跨過 preempt 門檻，仍會被新 latch 悶住不逃**——這正是你憲法論證聲稱「不會發生」的那件事，實際會發生。血案量級比 A1 原 bug（蓋不成房子）更重（隊可能因此被殲滅非只經濟停滯）。

## 要求
latch 不能是對 `_should_reeval` 全函式的無差別 `return false`。需要讓 :401-423 這條威脅強制路徑**繞過 latch**，例如：
- latch check 移到只包在「cadence 分支」內部（即：只擋「純粹到時間了的例行 cadence reeval」，不擋任何已經被上游明確判定要 force 的呼叫）——具體實作你判斷（例如帶一個 `force` 參數，或把 threat-force 呼叫改成直接呼 `_decide_unified` 內部邏輯繞過 `_should_reeval` 本身，同 crisis-edge 現有模式）。
- TDD 新增必要案例：**施工中隊 + threat_react 超 `threat_threshold+PREEMPT_MARGIN` → 仍能觸發 `_decide_unified` 重評（非被 latch 悶住）**，非只測「深餓仍打斷」（深餓走的是 `_decision_crisis`，跟這條威脅路徑是兩回事，測深餓不能替代測威脅）。

## 其餘（confirm）
- 修②對稱 release：合理，無異議。
- TDD execution-end 真 tick 驅動要求：合理（吸取 A1 上輪教訓，非 teleport）。
- 執行驗收硬標準（execution-verified，非只 R②CLEAN）：合理，上輪已吃過虧。

## 判決
**issues** → 回你修 latch 位置/繞過機制 + 補威脅測項。核心根因診斷+修②對稱皆 CLEAN，只有 latch 放置點的憲法論證需訂正+補洞，非推翻整個修法方向。
