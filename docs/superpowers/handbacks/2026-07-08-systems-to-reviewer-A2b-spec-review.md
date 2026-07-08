---
from: systems
to: reviewer
status: consumed
topic: 審 A2b spec（leader 隊納統一引擎）——設計健全性 + 跨系統盲點 + 呈報藍圖三岔路是否漏
---

# 請審 A2b spec

**檔**：`docs/superpowers/specs/2026-07-08-A2b-leader-into-engine.md`
**上游**：`docs/superpowers/handbacks/2026-07-08-blueprint-to-systems-A2-leader-into-engine.md`（藍圖 WHAT）

## 一句話
faction leader 隊是 A2「手不聽腦」最後一塊——成員(序6)/子隊(A2a)已納引擎，唯 leader 走 `_assign_tasks:1366-1400` 手 cascade。A2b = 送 leader 進 `_decide_unified`、拆手 cascade、intent 選擇 cadence-gate。**關鍵：intent→引擎的 bias-term(`intent_fit`)+ctx 接線已存在**，A2b 只是讓 leader 隊真被 rank_scored。

## ★重點審查項（02② spec review + 順帶 02① code-claim factcheck）

1. **code-claim factcheck**（grep 驗）：spec 引的落點/機制是否真實——
   - `intent_fit` term 已存在且讀 `ctx.intent`（terms.gd:131/161）？
   - `ctx.intent = f.intent.type` 已接 leader（decision_context:224）？
   - `_assign_tasks:1366-1400` 手 cascade + `note_bypass "leader"`(1400) 屬實？
   - 成員/子隊已走引擎（`_decide_unified`/`_decide_subteam`）、leader 未走？

2. **D2 seam 岔路健全性**（最需對抗）：leader 讀 intent(intent_fit) + faction_stakes(徵收/外交，**排除攻擊**)。
   - 排除 leader faction_stakes-攻擊 = 「身分-conditional context」——**算不算違憲『身分=權重非路徑切換』**？（系統辯：非路徑分支，同 rank_scored；對齊既有 decision_context:66-68 member→stakes/leader→intent 設計註。你判。）
   - 徵收/外交 走 faction_duty(follower obey 機制) 給 leader（intent-holder）自己——語意有無擰？

3. **cadence-gate 正確性**（D3）：只 gate `_select_intent`、survival override/goal emission 每 tick——會不會 goal emission 讀到 stale `f.intent`（cadence 內）造成 f.goals 與 committed intent 不一致？（系統判：冪等重 emit 同 f.intent → 一致。查。）

4. **跨系統盲點**（讀廣一點）：leader 隊改走 `_decide_unified` 後——
   - conquest scaffolding（`_commit_conquest_attack` gated faction_id==-1）leader 天然不觸 → leader 征服有無 scout-verify 缺口？（現手 cascade 也無，非退化，但確認。）
   - prio `PRIO_FACTION→PRIO_DISPATCH` 對威脅/survival 壓制序有無破綻？
   - tribute-detachment(1371-1378 遠距 dispatch 子隊) 移除 → leader 離家徵收，有無 abandon-capital 連鎖？

5. **呈報藍圖三岔路（spec §呈報藍圖）是否漏項/誤判 player-visible 分類**：(1)D2 訊號源 (2)征服 target→prosperity (3)攻擊 prio (4)tribute-detachment。你覺得還有沒標到的體感改動？

## 產物
- verdict → `docs/process/verdicts/A2b.review.raw.txt`（或你慣例位）+ 回信 `to: systems`（issues→halt / 綠→我 handback 重點給 00）。
- 消費後改本信 status: consumed。
