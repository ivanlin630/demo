---
from: blueprint
to: reviewer
status: consumed
topic: [R②設計審] 統領技能de-patch繁榮閘——加日常領導成長路徑,不綁P4_expand繁榮條件；用戶已點頭
---

# 統領技能日常成長 —— 設計送審（R②）

## 背景（真根，systems已file:line坐實）
established B2門(統領技能≥~0.35)100%結構性硬牆——統領技能唯一成長路徑是`P4_expand`(繁榮擴張reaction)，觸發需`food>100+stress<0.3+已有統領tag`。絕境隊(本世界預設態)food<<100+高壓→P4_expand永不贏reaction argmax→統領凍結在初始mean~0.25，永遠過不了門檻。見`2026-07-12-systems-to-blueprint-b2-command-root.md`。

## 用戶裁定（已點頭）
**開日常領導成長路徑**——統領技能不該只能靠繁榮擴張練，帶隊本身(leading a team/faction)就該累積領導經驗，不必先過繁榮閘。

## 設計意圖（WHAT，細節交systems判斷HOW）
- **新增**：任何隊伍leader（faction leader或獨立隊leader，不限food/stress狀態）在**帶隊本身**這件事上，隨時間/cadence微幅累積統領技能——「當領袖」這個狀態本身就是練習，不必先繁榮才能練。
- **不取代**P4_expand既有成長路徑——那條保留（繁榮隊仍可循此路徑額外/更快成長）。日常路徑是**新增的底層保底成長**，非取代。
- **成長速率**：日常路徑速率應明顯低於P4_expand（P4_expand代表主動擴張決策練習，日常路徑代表被動經驗累積），避免'帶隊掛機也能全滿'的失衡——具體常數由systems定，比照BASE_GROWTH量級（P4_expand≈+0.001~0.003/次）抓一個更小或同量級但低頻的增量，讓絕境隊「終將爬過門檻」但不是「立刻就過」，仍需撐過一段時間存活/帶隊才行——這保留「掙扎求生仍需要撐過一段時間」的遊戲張力，只是拔除「structurally永遠不可能」。

## 審查重點（factcheck/skeptical）
1. 「帶隊」判定用什麼欄位？（faction.leader_team_id / 獨立隊leader本身即隊伍leader？）需查現有TeamData/FactionData是否已有可用的「是否leader」旗標，避免新推導。
2. 觸發點放哪個cadence？（每tick太密/INFRA_INTERVAL(50h)較合理/或跟P4_expand同reaction cadence但去掉food/stress條件）——systems評估現有tick結構決定。
3. 是否有其他系統依賴「統領只能靠P4_expand漲」這個假設（例如某平衡數值假設統領增速上限）？grep cap_add統領調用點確認不會意外破壞現有繁榮隊的統領成長曲線。
4. determinism：新增日常成長路徑是否會讓既有run（無此系統時）行為改變——這是行為改動非L3純觀測，預期會改變數值結果，非regression bug，需向QA/measurer說明這是預期行為變化。

CLEAN後推systems出正式spec。
