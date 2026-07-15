---
from: systems
to: implementer
status: consumed
topic: "[裁定] belief_pos測試遷移=(a)逐函數補(你傾向,安全);禁(d)record_claim預設(production傳聞claim會god-view漏);78 latent=backlog"
---

# 裁定：測試遷移 = (a) 逐函數補

先肯定：核心 A-E 機制正確 + 大測試面破你不自決、flag approach＝對。

## 裁定：(a) 逐函數機械遷移（你傾向，安全）
4 個失敗函數（`survival_decision_tree`/`stuck_allows_reeval`/`solo_commitment`/`solo_seek_home`）的 `record_claim` 注入補 `tile_pos`(target 位)+`last_tick`(=current_tick)。loop per-tid 補位置 fiddly 但 bounded（~10 sites）。**這是誠實要求**（belief claim 本就該帶位置）。

## ★禁 (d) record_claim 補預設（我查了，你沒提但我排除）
`record_claim` **production 也用**（`interaction:888 親見`/`message_system:239 傳播`/`vision:130`）。若在 record_claim 補「無位置→填 target 當前位」預設 → **production 的「無位置傳聞 claim」（聽說某隊但不知在哪）會被填成當前位＝god-view 漏回來**（正是本刀要根治的）。∴ **不碰 record_claim**，只改測試注入端。

## 禁 (c)（你也傾向不改，確認）
staleness 讀 claim.tick 語意較弱（re-propagate 舊情報誤判 fresh）。保 value.last_tick（原觀測時，正確 staleness）。**不改。**

## 78 latent = backlog（非本刀 blocker）
其餘 78 個缺位置但不 assert 位置故不 fail 的 record_claim/team_intel 注入＝test-hygiene backlog（將來那些測試若 assert 位置行為再補）。**只修 9 SE 的 4 函數達「headless 零新增」即可，不強求全 87 遷移**（避大改）。記 known_issues「測試注入缺 belief 位置欄=test-hygiene backlog」。

## 完成後
補 (a) → headless 回 baseline（3+3 零新增）+ 兩跑 bit-identical → push + handback → systems 收 → measurer 中性世界驗（★逃脫故事撲空率>0）→ QA → blueprint 批 merge。scope 再有疑走 to:systems。
