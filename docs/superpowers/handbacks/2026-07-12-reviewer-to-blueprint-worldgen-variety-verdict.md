---
from: reviewer
to: blueprint
status: consumed
topic: [對抗①verdict/框外] world-gen variety = issues，三疑兩成立，打回補三條約束
---

# 對抗① + 框外挑框 verdict — world-gen variety design

## verdict: issues（非 premise_contradiction，設計缺口，halt）

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {
      "claim": "資源/戰略加權散布真產「有機、變化」世界（靶A）",
      "file_line": "specs/2026-07-12-worldgen-variety-design.md §1",
      "truth": "部分成立：spec 把有機性歸功於「評分+seeded挑選」，因果掛錯——真正防收斂的是底層 resource map 本身 per-seed 甩（world_generator.gd:62 已確認seeded），非 scatter 演算法。若評分函數deterministic+tile資源方差不夠大/top-N截斷太窄，會復發 A 描述的規則化（換湯不換藥，規則從key-order換成分數排序）。spec 未設「分數非唯一驅動/需注入位置熵」約束。"
    },
    {
      "claim": "cap 據點數留空地真讓 build-outpost 可驗（靶B）",
      "file_line": "specs/2026-07-12-worldgen-variety-design.md §2；build-outpost 機制本身已由 reviewer file:line 確認存在（faction_ai_system.gd:3060 establish_crude_camp + outpost_system.gd:295-324 正規建構）",
      "truth": "機制存在為真（非假前提），但「留空地」只是必要非充分條件——空地保證有地方蓋，不保證隊伍會去蓋。spec 未驗證此決策路徑在新開局下真的會 fire（依本專案『補丁閘優先查/從不fire先查』教訓，很可能罕見）。§驗收把「build-outpost可驗」當已證，實為待證假設。"
    },
    {
      "claim": "結構地板（≥1勢力/≥幾隊/據點≤上限/不重疊/間距守）真保證「能跑」（靶C）",
      "file_line": "specs/2026-07-12-worldgen-variety-design.md §結構地板",
      "truth": "成立，地板只管局部幾何，無全域結構保證。可溜過：據點群聚地圖一角（逐對間距合法但整體偏側，= 靶A收斂病的空間版）、某勢力分0可達據點（無「每勢力≥1據點且連通」條款）、獨立隊全生資源死角。缺領土連通性/每勢力最低據點/散布覆蓋度下限。"
    }
  ],
  "note": "異質審（別模型代跑，refute-by-default）三疑其一部分成立、其二成立，非全盤推翻，設計方向（放野/去平衡護欄/資源導向布局）本身不錯，但地板/驗收假設不夠硬，打回補三條約束後可過。" }
```

## 打回，需 blueprint 補三條約束後再送 systems
1. **位置熵護欄**：明訂評分不能是唯一驅動因子，需注入位置隨機性（如 top-N 隨機挑非純 argmax，或評分本身含強 per-seed 位置噪聲項），防高分 tile 收斂成新的規則熱點。
2. **地板從局部升全域**：加「每勢力≥1 可達據點 + 領土連通」+ 散布覆蓋度下限（如象限/包圍盒分布檢查），擋群聚一角/勢力0據點/獨立隊死角三種退化開局。
3. **build-outpost 待驗獨立列項**：留空地本身不算驗收通過，須另立「build-outpost 決策路徑在新開局下 dispatch>0」為獨立測項，別把「留空地」當「訊號可觀測」的自動推論。

## file:line 補充（reviewer 主查，供 systems 後續參照）
- `world_generator.gd:62 _random_terrain(rng)` — 確認已 seeded。
- `pick_start_positions:180-194`（`world_generator.gd`）— 確認純 tile-key 迭代順序貪婪 + min_sep 檢查，**全函式無 rng 呼叫**，坐實「規則且每 seed 同」真兇斷言。
- `game_setup.gd:71-86 _plan_outposts` — 確認 `total_count` 讀 config 固定值（default 10），呼叫上述無 rng 的 `pick_start_positions`。
- `game_setup.gd:136 main_pos = outposts[0]` — 確認主隊錨定第一據點。
- `game_setup.gd:148,187,234... _random_near/_random_empty_tile` — 確認皆吃 seeded rng。
- `world_generator.gd:51 radius: int = config.get("radius", 4)` — 確認地圖半徑 config 固定值。
- **build-outpost 機制存在性（靶B前提）**：`faction_ai_system.gd:3060 establish_crude_camp`（求生豁免即時建 crude camp，`outpost_level` 0→1）+ `outpost_system.gd:295-324`（正規建構完工路徑，`crude_camp`/`upgrade_level` 等 case）確認**機制真實存在**，非虛構行為，靶B「假前提」疑慮在「機制存在性」層面不成立；但「留空地是否真讓它被觀測到」層面疑慮成立（見上 issues）。

halt，待 blueprint 補三條約束修 spec 後回 reviewer 重審。
