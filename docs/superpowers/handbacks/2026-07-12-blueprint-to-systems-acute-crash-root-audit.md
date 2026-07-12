---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] 月1-3急性餓死崩真根——開局起86-96%隊伍負食物流,查初始pop/food buffer/regen速率/初始分布,這是四層de-patch共享上游根
---

# 月1-3急性餓死崩 —— 真根查（四層共享上游根，先找原因再定策略）

## 背景
measurer經濟長程診斷（`2026-07-12-measurer-to-blueprint-food-econ-diagnosis-result.md`）確認：**開局起86-96%隊伍就是負食物流**（非漸洩，起始態就失衡），頭3個月吃掉~45%總人口。這不是「隨時間累積才崩」，是**開局當下**供給/需求就對不上。

此崩潰是established調查鏈四層de-patch（farming死鎖→A門人口82.7%卡→B2統領繁榮閘→leader週轉吃成長）的**共享上游根**——systems判讀：四層都是「累積型」門，全被早崩重置吃掉，逐層下游修=打地鼠。用戶裁定：**先找急性崩本身的真根，再定策略**（是否轉攻上游）。

## 待查（零跑，file:line，patch-gate-first：先查是不是死常數/初始化不當，非猜tuning）
1. **開局初始pop vs 初始承載力**：`game_setup.gd` 開局隊伍pop生成邏輯 vs 各地形食物承載力（FOOD_PER_PERSON_PER_DAY=0.8、regen plains8/forest3/mountain0.5——這幾個數字之前已知，查開局pop是否從一開始就超過起始地形承載力）。
2. **開局food buffer（opening_granary_food）**：`game_setup:258-308` 之前提過有開局注入，查注入量級 vs 頭幾天消耗速度，是否buffer本來就薄到撐不了幾天。
3. **世界生成初始分布**：隊伍初始落點是否系統性分配到食物承載力不足的地形（例如過多隊伍落在mountain/低regen地形）？查world_generator相關邏輯。
4. **regen速率本身**：plains8/forest3/mountain0.5這幾個常數是否原本就設計為「需要farming才夠活」，也就是說**急性崩是設計意圖**（開局本該靠farming/貿易撐，非raw regen）——若是，那真根其實還是繞回farming死鎖（無farming就該死，但de-patch後應該不再馬上死）；若不是設計意圖而是死常數/初始化bug，才是獨立真根。
5. **月1-3這個時間窗本身**——有沒有特定tick/day常數在此窗口做了什麼（例如某種初始寬限期結束、或某個evaluate cadence從此開始跑）。

## 為何現在查
用戶：先找原因，再決定要不要轉攻上游（vs繼續逐層下游修）。這是策略分岔前置。

## 序
零跑出真根file:line → to:blueprint → 我判讀是否為獨立真根 vs 只是farming死鎖的另一面 → 待用戶裁策略方向。
