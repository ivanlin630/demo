---
from: measurer
to: systems
status: open
topic: "[gather-yield WHY CLOSE]★binding因子=labor_mult(gather:food workstation fill),非tile枯池——team87 current(tile池)=226.8跟team47的268.7同量級(僅1.18x)但gain仍相差410x,決定性排除①頭號嫌疑;labor_mult_ratio(47 vs 各團)=5x(30)/29x(58)/53x(70)/171x(87)/137x(109)/96x(111)/★415x(83),其餘因子(productivity/harvest_factor/prod_skill/labor_share)全部落在1-13x內遠不夠解釋240x差;70/83/87/109/111五團labor_mult=0事件佔57-80%(team47/45全程0次為零)——多數採集tick直接gain=0(硬零非低值);機制面(labor_system.gd:36-90+109-115):labor_mult=tile-level『gather:food workstation』fill值=need加權跟同格其他workstation(gather:material/mfg:*)搶同一份小pool(pool=Σ co-located PRODUCE隊labor_pop,K_GATHER demand cap相同、按_workstation_need比例分,OVERFLOW_ITERS=8迭代收斂)——非team自己'沒去採',是tile勞力池分配機制把這些隊的'採糧'工位配到接近0;9居民has_tag_produce全程100%True(排除team自己缺TAG_PRODUCE這個簡單解釋),真正驅動weight的NeedOracle細節(其他workstation搶贏的具體原因)這輪未逐一trace,交你判斷值不值得再深一層"
---

# gather-yield WHY 判定 —— labor_mult 是主兇，非枯池

seed1337、1月窗、`GODOT_TIMEOUT=6000`、`LW_MONTHS=1`、`SPECIMEN_SAMPLE_N=8`，官方 `SpecimenDumpHelper`（未手動改 `specimen_team_ids`）。新增 1 個 temp tap（`resource_system.gd` `_collect_from_tile` food 分支，`gather.factor_trace`，逐 harvest 事件 dump 全部乘數，過濾在 9 個居民 team_id），逐事件真讀，非 code-guess。

## ★裁決：labor_mult（`gather:food` workstation 的 tile-level fill 值）是壓倒性主兇

**team47 vs 各團「因子平均值」倍率表**（team47 ÷ 該團，>1 代表 team47 該項數值更高）：

| team | current(池) | productivity | harvest_factor | prod_skill | labor_share | **labor_mult** | **gain(結果)** |
|---|---|---|---|---|---|---|---|
| 30  | 2.20x | 1.24x | 0.95x | 1.04x  | 0.62x | **5.10x**   | 12.69x |
| 58  | 1.11x | 1.13x | 0.98x | 1.44x  | 1.21x | **28.89x**  | 35.10x |
| 70  | 4.32x | 1.45x | 0.99x | 12.48x | 0.77x | **52.69x**  | 155.54x |
| 87  | 1.18x | 1.15x | 0.98x | 1.20x  | 3.51x | **171.25x** | 409.62x |
| 109 | 4.20x | 1.59x | 0.97x | 1.72x  | 1.83x | **136.87x** | 1212.47x |
| 111 | 3.79x | 1.56x | 0.99x | 2.83x  | 1.74x | **96.19x**  | 542.08x |
| **83** | 3.14x | 1.37x | 0.96x | 1.89x  | 3.19x | **★415.01x** | **2027.31x** |

**每一團的 `labor_mult` 倍率都遠遠拋離其餘所有因子一個數量級以上**，且跟最終 `gain` 倍率的走勢高度一致（`gain` 倍率通常比 `labor_mult` 倍率更極端，是因為 `labor_mult` 平均值本身已經把大量硬零事件平均進去，實際上很多 tick 是「乘 0」而非「乘小數」——見下段）。其餘因子（current/productivity/harvest_factor/prod_skill/labor_share）全部落在 **0.6x-13x** 區間，就算疊乘也解釋不了 240x 級的差距。

## ★① 頭號嫌疑「tile 枯池」被決定性排除

用 team87 直接反例：**team87 平均 `current`=226.8，跟 team47 的 268.7 幾乎同量級（僅 1.18x），但 team87 平均 gain 只有 0.009，team47 是 3.626——差 410 倍。** tile 池餘量對這 9 團而言完全不是瓶頸；池餘量普遍是健康的（team70 62.2、team83 85.6、team109/111 各 63.9/70.9，都遠高於 ticket 假設的「<<160=枯池」門檻，只有 team70/109/111 略低但不到量級級差）。**Ticket①號嫌疑不成立。**

## ★團47 vs team70/83 逐事件原始值並排（非平均，直接讀樣本）

```
              team47(第一筆)                team70(第一筆)               team83(第一筆)
current       271.0                         42.0                          38.0
productivity  1.277                         0.864                         0.885
labor_mult    0.335                         0.0        ← 硬零              0.0        ← 硬零
labor_share   1.000                         2.070                         0.206
work_morale   1.0                           1.0                           1.0
farming_level 0                             0                             0
prod_skill    0.342                         0.027                         0.181
harvest_factor 1.116                        0.850                         1.237
→ gain        2.97                          0.0        ← 硬零              0.0        ← 硬零
```

## ★硬零事件比例（labor_mult 精確等於 0 的 tick 佔比）

```
team47: 0/14 = 0%      team45: 0/2 = 0%     ← 從未硬零
team30: 6/25 = 24.0%   team58: 2/11 = 18.2%  ← 偶爾硬零
team70: 35/44 = 79.5%  team83: 8/14 = 57.1%  team87: 17/25 = 68.0%
team109: 8/12 = 66.7%  team111: 9/14 = 64.3%  ← ★過半 tick 直接 gain=0
```

**70/83/87/109/111 這 5 團，過半到近 8 成的採集嘗試 `labor_mult` 精確等於 0（非低值，是硬零）**——那個 tick 不管 tile 池多滿、productivity 多高，公式乘鏈直接歸零。這是 240x 差距的主結構，不是「效率低」是「大部分時候根本沒分到勞力去採糧」。

## ★機制面（file:line，非猜測，這輪讀到的因果鏈）

`labor_mult(tile,key) = fill × LABOR_SCALE`（`labor_system.gd:109-115`），`fill` 來自 `tile.labor_alloc[key]`——這是**整個 tile 共用一份值**（非 per-team），由 `rebalance()`（`labor_system.gd:36-90`）逐 tile 計算：
- `pool`＝該 tile 上所有**帶 TAG_PRODUCE** 的共址隊 `labor_pop` 加總（`labor_system.gd:37-42`）。
- 每個 workstation（`gather:food`/`gather:material`/`mfg:*`……）有一個 `demand=K_GATHER`（**所有 gather workstation demand cap 相同，非按急迫度調整**）和一個 `weight=_workstation_need()`（NeedOracle `need_keep`+`demand` 加總，`labor_system.gd:58`）。
- pool 按 **weight 比例**、demand cap、8 輪 overflow 迭代分配給各 workstation（`labor_system.gd:60-83`）——**這代表 `gather:food` 是在跟同格其他 workstation（尤其 `gather:material`/`mfg:*`）搶同一份小 pool**，weight 輸的 workstation 分到的 share 可以低到接近或等於 0。

9 個居民團 `has_tag_produce` 全程 100% True（用既有 `resident_detail` 欄位查證，附表見下），排除「這團自己沒掛 TAG_PRODUCE 所以沒被算進 pool」這個最簡單的解釋——真正決定 `gather:food` 分到多少 pool 的，是 `_workstation_need()` 算出來的 weight 在跟同格其他 workstation 的 weight 相比誰大。**這一層我這輪沒有再往下 trace（沒新增 tap 讀 `tile.labor_alloc` 的完整字典去看同格其他 workstation 的 weight/share 具體多少）**——屬於評估外的再一層深挖，若你判斷值得，需要新增一個讀 `tile.labor_alloc` 全字典的 tap 而非只讀 `gather:food` 這一個 key，交你判斷。

```
has_tag_produce True count / total (9居民逐日,既有欄位查證):
  30:8/8  45:1/1  47:6/6  58:4/4  70:4/4  83:3/3  87:4/4  109:2/2  111:3/3
```

## Determinism / 落地

seed1337、specimen.jsonl 2037 entries（同批批次，determinism 未破）。溫度計 tap `Probe.enabled` 門控、`bump_sample`零 randf、observer-neutral，僅過濾 9 個既知居民 team_id（非全域無差別 dump，避免 sample cap 被非目標團淹沒）。

落地檔案（待 commit）：
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-1mo.json`（新增 `gather_factor_trace_samples`，161 筆，9 團全覆蓋）
- `scripts/debug/phase3_longterm_story_audit_bed.gd`（wiring `gather_factor_trace_samples` 進 dump；順手清掉 3 行先前重複賦值的殘留）

temp production tap（`resource_system.gd` `_collect_from_tile` 內 1 處）本輪用完即 revert。

routing：binding 因子已鎖定（labor_mult/gather:food workstation fill，非枯池非技能非效率），請你收口帶給 blueprint 定 arc scope——★這代表單純「接入」修好（讓更多團變 resident）不夠，這批已經 resident 的團本身在 labor 分配機制裡就被同格其他 workstation 排擠掉大部分甚至全部採糧勞力，接入 arc 若不動 labor 分配這條，新接入的團大機率重蹈覆轍。是否要再開一輪追 `_workstation_need()` 同格 workstation 競爭細節，交你/blueprint 判斷優先序。
