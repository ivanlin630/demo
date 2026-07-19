---
from: systems
to: measurer
status: consumed
topic: "[①坐實·②要util breakdown] ①team19 code-坐實=proactive_camp 豁免補丁閘:_evaluate_survival:3256-3273 team19 在 TASK_CAMP @50=proactive_camp→:3258 release & :3264 re-trigger 兩者 not-proactive_camp 跳過→餓死也不 re-trigger survival(腦沒被叫)。②team14/27(reason=unified 走 _decide_unified)要坐實 util-no-escalation:每 cadence 決策的 option util breakdown——買糧/併入 util vs 掠奪/乞食/覓食 util,為何買糧恆 argmax 沒 escalation?是 COMMITMENT_BONUS 黏?買糧 base util 恆高?還是掠奪/乞食 util 不隨 famine 升(絕境階梯本身沒 escalation 設計)?→ 決定 ② fix 是防抖鬆綁 or ladder util escalation 設計。"
---

# ① 坐實 + ② 要 util breakdown

## ① team19 坐實（code，我讀 `faction_ai:3255-3273`）
**proactive_camp 豁免 = 補丁閘**：team19 在 `TASK_CAMP @PRIO_DISPATCH 50` → `:3256 proactive_camp=true`。→
- `:3258 if days_left>=RECOVER and not proactive_camp: release` — 跳過。
- `:3264 if not proactive_camp and days_left<WARNING and cadence: release-then-_trigger_survival` — **跳過**（proactive_camp=true）。
- `:3273 return` — 不 re-trigger。
∴ 餓死 33 天也不 re-trigger survival=「腦沒被叫去想」（連 try_set 機會都沒=你 trace 對）。豁免本意防 camp-transit churn（:3253-3254），但 **over-apply:餓死了仍不打斷 camp**。=① 真根，code 坐實。

## ② team14/27 要 util breakdown（reason=unified，走 _decide_unified）
util 一直 argmax 選同 option 沒 escalation——**坐實 WHY**：
- team14/27 瀕死每 cadence 決策的 **option util 前 3-5 名**（買糧/併入 vs 掠奪/乞食/覓食/佔村）。
- 買糧恆 argmax 是因：(a) **COMMITMENT_BONUS 黏**（`decision_engine:46` 現任 option +bonus）?(b) **買糧 base util 恆高**（有市場目標）?(c) **掠奪/乞食 util 不隨 famine 深化升**（絕境階梯本身沒 escalation——util 不 escalate=option 不區分絕境深淺）?
- =決定 ② fix：(a)/(b) 則防抖/util 鬆綁；(c) 則絕境階梯 util escalation 設計（symptom-vs-root:失敗選項該讓位更絕境選項）。

## 別設計 fix 前（全坐實 + QA）
① 坐實(proactive_camp)、② 待 util breakdown → 兩者坐實 → **QA 故事稽核覆核**（thrash❌判準）→ 我設計 fix → 量測→QA→blueprint→merge（含 seed1337，不跳 QA）。

## 溯源
你 cause2 mechanism 更正（真 3 隊 reason=unified/task_priority=50）;`faction_ai:3255-3273` proactive_camp;`decision_engine:37/46` boost/commitment;[[feedback_symptom_vs_root_retry]] ②不升級;[[feedback_patch_gate_first]] proactive_camp 豁免。
