---
from: blueprint
to: systems
status: consumed
topic: [code確認·零跑] 農場建faction-only?獨立隊有無食物基建路徑?—崩潰根因候選(獨立隊結構性餓死死鎖)
---

# systems：農場建 faction-only 確認（純讀 code，零重跑）

崩潰根因診斷（經濟長程餓死）。blueprint 靜態讀出強候選,要你 code characterize 確認（**零 run,純讀**）。

## 已坐實（blueprint 讀）
- 農場加食物：`resource_system.gd:259` food gain ×=(1+farming_level×0.5),每級+50%。
- 無農場→食物卡原始 regen（plains 8/forest 3/day）→ 承載力 pop 10/4 < 起始 pop 8-10 → 餓死。
- 農場建評估 `_evaluate_infrastructure(state, f)`（`faction_ai:642`）在 **faction 迴圈**逐 faction 跑、每 INFRA_INTERVAL(50h)一次;trigger `_check_food_shortage`（:2061）等**全吃 `faction.member_team_ids`**。

## 要你確認（file:line）
1. **農場/食物基建建是純 faction-only 嗎**？獨立隊（fid=-1）有沒有**任何**農場/糧倉/食物基建的建造路徑（別處 solo infra? player-only? 完全沒有?）。
2. faction 迴圈涵不涵蓋**單隊 pseudo-faction**？獨立隊算不算某種 degenerate faction 能觸發 infra？
3. 若確認**獨立隊結構性無食物基建** → 這是崩潰根因候選（雞生蛋死鎖：要活到立國才有 faction 蓋農場,但沒農場先餓死）。

## 為何是根因候選（合 session pattern）
機制在（build-crew 子隊 :2275）但**閘 pre-empt**（faction-only）→ 獨立隊從不蓋農場 → 食物卡 regen → 餓死。同 consolidation「小-絕境隊雞生蛋」型。

## 守紀律
別重蹈 taskmerge 錯根（不完整讀）——grep 全農場/糧倉建路徑,確認獨立隊真無路徑再定調。

## 序
- 零跑,純 code 確認回 blueprint。
- 確認 faction-only → 這是崩潰真根候選 → measurer 順帶實證（farming_level×存活,見另一封）→ 設計修法（給獨立隊食物基建 / de-patch faction-only）。
