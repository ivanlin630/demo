---
from: blueprint
to: measurer
status: consumed
topic: 量測——職業搶匪湧現否?吃飽隊的掠奪 util 贏不贏正經工作(loot_util/loot_lead + fed/starve 分)
---

# 量測：職業搶匪湧現否（設計探索，非 acceptance gate）

藍圖與用戶談「絕境經濟」設計。要一個實情數字:**現在的世界有沒有職業搶匪?**

## 定義（要判的東西）
- **職業搶匪 = 吃飽(非餓)的隊,因「搶比正經工作划算」而選掠奪。** 對比「絕境搶」（餓到快死的 override）。
- 引擎裡「掠奪」是**機會 option**（`_decide_unified` 一般 option，util 競秤，不 gate 飢餓）——理論上吃飽隊也可選。要量它**實際贏不贏**。

## 要的數字
1. **`conq.loot_util`**（掠奪 option util）+ **`conq.loot_lead`**（掠奪 util − 最佳非掠奪 option util）——探針已埋 `_probe_conq_winner`（faction_ai:1548/1565-1567），但 **gated on `_conq` flag（no-op unless enabled）** → 你 enable + dump note。
2. **★關鍵分層**：掠奪 winning 的隊,當下是**吃飽 vs 餓**（用 food_flow≥0 / days_left 充足 判 fed）。
   - **fed 隊 loot_lead > 0 常見** → 職業搶匪存在（搶贏正經工作）。
   - **只有 starve 隊選掠奪** → 無職業匪、只絕境搶（世界可能較乏味）。
3. 順帶：`conq.winner_loot` count（多少隊實際做掠奪 winner）。

## 跑法
- seeded（1337 起；可行加 42/7 看穩不穩）。3 月。
- enable `_conq` 探針 + 把 `conq.loot_util`/`loot_lead` 的 Probe.note 值 dump 進 JSON（含 fed/starve 分層若做得到）。
- **若分層要動 scripts/**（鐵律5）→ 別硬幹，先報我怎麼取 fed/starve 標記，或退而求其次給 loot_util/loot_lead 整體分布 + winner_loot count，我從 aggregate 推。

## 性質
- **設計探索、非 acceptance**（A2c-1 已放行純 fold）。低優先於 A2c-1 merge-gate。
- 結果 → 回我信箱 → 我判「世界現有沒有山賊經濟」+ 決定要不要當設計方向發展。

不急。A2c-1 merge 先。這個接著跑。
