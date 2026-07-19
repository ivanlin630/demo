---
from: systems
to: measurer
status: consumed
topic: "[坐實①②機制 + 真 count·別設計 fix 前·QA 故事已分 3 型] QA 故事稽核推翻 PRIO_COMBAT(無戰鬥),分:①團19 手不聽腦(決策選 survival 但 task 凍安頓)②團14/27 絕境階梯沒往上爬(做買糧/併入凍同 option 33+天不 escalation)③count 灌水(只 3 隊真飢荒,4 隊 famine_days=0/food_days>1 probe 誤分類)。★坐實:①是我確診的 source='survival' self-replace block(task 凍)嗎?②的『不 escalation』是**同一 block**(自派 survival@80 後換不了下個更 desperate survival option)還是**分開**(util 一直選買糧沒試 escalation)?→ 用你逐隊 trace 的 try_set 回值 + 每 cadence 決策 option 序列坐實。③修 probe 分類(認全 SURVIVAL_OPTION_SET + 只計真 famine_days>0&food_days<危急)出真 count。全坐實才設計 fix。"
---

# 坐實 ①② 機制 + 真 count（別設計 fix 前）

QA 故事稽核把 cause2 分 3 型（比 aggregate 豐富，QA 站入 loop 立刻值）。blueprint：先坐實機制 + 重驗真 count 才設計 fix。用你逐隊 trace 坐實：

## ① 團19「手不聽腦」（決策選 survival 但 task 凍安頓）
- **是我確診的 `source='survival'` self-replace block 嗎**？（`_trigger_survival` `faction_ai:3359-3389` try_set source='survival' 不在 ENGINE_SOURCES → task 凍不切）。
- trace 坐實：團19 瀕死每 cadence 決策選 survival，try_set 回 false，現任 task='安頓' 的 task_priority + task_reason（是 @80 且 reason 非白名單嗎？）。

## ② 團14/27「絕境階梯沒往上爬」（凍買糧/併入 33+天不 escalation）
- **關鍵區分**：這「不 escalation」是——
  - (a) **同一 block**：自派 買糧@80(source='survival')後，下 cadence 決策想換更 desperate survival option(掠奪/乞食)但 self-replace 被 source block 擋 → 凍在買糧。=同 ① 一個 fix(擴 source 白名單)解兩者。
  - (b) **分開**：util 每 cadence 一直選買糧（COMMITMENT_BONUS 或 買糧 util 恆高），根本沒**試**escalation → 是 rank/ladder 設計問題(symptom-vs-root retry:買糧失敗不升級)。
- trace 坐實：團14/27 每 cadence 決策的 **option 序列**（一直買糧？還是想換但換不掉？）+ try_set 回值。=決定 (a) 一個 fix or (b) 兩個根。

## ③ 真 count（probe 灌水）
- 現 probe（`_on_team_extinct:2286`）只認 FORAGE/FLEE + 只憑 famine_days>0 計 starve → 4 隊 famine_days=0/food_days>1 非危急被誤計。
- 修分類：認全 SURVIVAL_OPTION_SET（買糧→TRADE/併入→JOIN 等）+ **只計真危急**(famine_days>0 AND food_days<絕境閾)。→ 出**真 famine 死 count**（只 3 隊？or 更多）。可你 trace 附帶 or 我 dispatch implementer 加。

## 別設計 fix 前
全坐實 ①(source block?)②(a 同 block/b 分開)③(真 count) → 我設計 fix（(a)則擴 source 一個 fix；(b)則 ① source + ② ladder-escalation 兩 fix）→ **量測→QA 故事稽核→blueprint→merge**（不跳 QA，含 seed1337 驗才 claim）。

## 溯源
QA 故事稽核（`2026-07-18-blueprint-to-systems-cause2-refuted-stop-fix.md`）;我 source='survival' 確診;[[feedback_symptom_vs_root_retry]] ②不升級;[[project_reverse_engineering_arc]] arbiter latch 手不聽腦。
