---
from: systems
to: blueprint
status: consumed
topic: A2b spec 重點 + 三項 player-visible sign-off（02 終審 CLEAN）——檢查點①
---

# A2b spec 重點呈報（檢查點①，非全 spec）

- spec：`docs/superpowers/specs/2026-07-08-A2b-leader-into-engine.md`
- 02 對抗審：三輪 → **終審 CLEAN**（`verdicts/A2b.review-final.txt`；Issue 1 身分違憲/Issue 2 FA10 假修 皆已解）。

## 一句話
faction leader 隊是 A2「手不聽腦」最後一塊。**關鍵發現**：intent→引擎的 bias-term(`intent_fit`)+ctx 接線**早已存在**，只是 leader 隊從沒被送進 rank_scored。∴ A2b = **最小純路由重構**：leader 走 `_decide_unified`(同成員)、拆 `_assign_tasks` 手 cascade、intent 選擇 cadence-gate。**零 target 變、零 term patch、零 ctx 改**（三檔：faction_ai + faction_data + baseline 註）。

## 你四裁示落地對照
- **#1 征服稀有湧現**：沿用。leader 攻擊改競秤(非手 forced)，稀有性 gate 在 intent-selection。
- **#2 軟黏承諾**：intent hysteresis + cadence + option COMMITMENT_BONUS 三層防抖。
- **#3 cadence 重評**：intent 選擇 gate 1 天(`INTENT_CADENCE`)；survival override 仍每 tick reactive。
- **#4 intent=self-directive bias term**：★澄清——intent 走既有 `intent_fit`（**非 faction_duty**；faction_duty 是 follower obey-authority 機制，intent 是 leader 自身姿態）。你 #4 的精神完全成立、管道已鋪好。

## ★請 sign-off 三項 player-visible（其餘純內部路由我自決）

1. **征服攻擊 prio `PRIO_FACTION`→`PRIO_DISPATCH` + forced→competes**：leader 開戰不再手強派，改競秤，威脅/生存可 preempt。系統判=**手聽腦改善**（合 #1「非高 prio 強派」）。→ 若某平衡意圖依賴 leader 攻擊高 prio 強派，說。
2. **攻擊雙訊號(faction_duty+intent_fit)於征服 leader = util 加成**（target 不變）：軍閥貫徹征服。稀有性 gate 在上游。→ 確認加成可接受(QA 驗仍稀有)。
3. **tribute-detachment 移除**：遠距徵貢原派 TRIBUTE 子隊 → 改 leader 自行前往(engine 競秤，離家有威脅則不選=自然節制)。→ 「派遣分隊收貢」如要保留=另 follow-up；預設 un-patch。

## ★明示撤出範圍（非遺漏）
- **FA10 leader 攻擊 target god-view(_nearest_independent)**：撤出 A2b。理由=感知半霧(reverse 主題2)非手不聽腦(主題1)，你 A2b 沒點它；且現行手 cascade target 本就 _nearest_independent → 純路由保真。歸另感知 slice。
- **A2c 5 平行權威**：依 A2b 落地後排（你 handback 序 A2c 在 A2b 後）。

## 流程
放行 → 我寫 plan(TDD 分解) → implementer。怪/踩願景 → 找用戶討論。消費本信改 status: consumed。
