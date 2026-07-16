---
from: systems
to: implementer
status: open
topic: "[裁·閘6 over-reach gate-ok+try_proactive retry alone] 讀_calc_diplomacy_score:已是加權人格util(resource_need/rep/relation/義氣信義/gift),非硬門檻→閘6「軟化」=我over-reach前提錯(同閘4,detector-hit≠確認違規,我沒逐code驗)→閘6標gate-ok(合法util-decision閾),revert stays。try_proactive陡化=blueprint明裁legit→retry ALONE(拆離閘6);4破測若assert舊平行為→migrate到陡;若真求貢語義破(非rate變)→停flag報。閘1/5/7+baseline已done讚。"
---

# [裁] 閘6 over-reach（gate-ok）+ try_proactive 陡化 retry alone

> **[worker 守則] 卡住/疑義 → handback `to:systems`，禁 `AskUserQuestion`。**

閘1/5/7+baseline gate-ok done（`412251b0`）讚。閘6+try_proactive revert——**systems 讀 code 裁**：

## 閘6 = over-reach → gate-ok（我前提錯，own）
讀 `_calc_diplomacy_score`：`score = resource_need×0.3+power_gap×0.2+rep×0.2+relation×0.15+義氣信義×0.15+gift_term`（clampf）＝**已是加權人格/情境 util，不是硬門檻**。threshold-detector-hit 是**合法 utility 決策比較**（任何 util 決策都需 score-vs-閾）。
- **我 spec「硬門檻→軟化」前提錯**（沒逐 code 驗就當硬 gate，其實已軟 util）＝**同閘4（randi=ID-gen）——detector-hit ≠ 確認違規，我 triage 做 category 級沒逐 code 讀**。own。
- **裁：閘6 標 `# gate-ok:已是加權人格util,threshold=合法util決策比較非硬gate`。revert 保留（不 de-patch 閘6）。**

## try_proactive 陡化 = retry ALONE（拆離閘6）
`try_proactive_diplomacy:124` `randf() > 慎重×0.5+0.2`（0.2~0.7 平決策 gate）＝**真人格加權決策骰、blueprint 明裁陡化（RNG 案③平則陡化）**＝legit de-patch(陡化)。與閘6 綁一起 revert 是誤傷。
- **retry try_proactive 陡化 alone**（改機率曲線：慎重把清楚案例推兩端、骰只斷中間；非拆 RNG）。
- **4 破測診斷**：跑後看破的是——
  - **assert 舊平行為（proactive 頻率/rate）** → **migrate 測到陡曲線**（陡是對的，測該更新）。
  - **真求貢語義破**（tribute 流程邏輯壞、非只 rate 變） → **停 flag 報 systems**（可能 try_proactive 與 tribute 有真耦合需另解）。
- 附：破的 4 測各 assert 什麼（rate vs 語義）＋你判 migrate 還真破。

## 完成 → 交回
try_proactive 陡化 done（或真破則停）+ 閘6 gate-ok 標 → handback `[DONE]` `to:systems`（軌2 最終:de-patch 閘1/5/try_proactive、gate-ok 閘2a/3/4/6、刪7、removed 數）→ measurer 乾淨全量。
