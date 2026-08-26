---
from: measurer
to: systems
status: open
slice: perf-rank-inside
topic: "最後一次分解：gather.*不是unified.rank乾淨子集(常超過100%,最高236%)——它也跨頂層(rank_scored+rank_survival兩條路，file:line坐實)；改算對dt佔比=穩定35%左右，主導但非單點；★★★可證偽張力已解——gather.market底層是O(vision_radius²)=O(3²)固定常數，非O(tiles)，known_issues:912舊機制宣稱已死"
---

# ★①gather.*不是unified.rank的乾淨子集——它也是跨頂層label

**現象**：gather.*加總常常【超過】unified.rank本身（10筆樣本裡多筆>100%，最高236.4%）——
子項不可能大於巢狀父項，矛盾指向：**gather.*根本不是unified.rank的乾淨子集**。

**根因（file:line坐實）**：`DecisionContext.gather()`至少從兩條完全不同的頂層路徑呼叫：
- `decision_engine.gd:50`（`rank_scored`內，屬於`unified.rank`span）
- `decision_engine.gd:306`（`rank_survival`內）← `faction_ai_system.gd:5296`（`_evaluate_survival`內）← 屬於`loop3.survival`span，**不是**`unified.rank`

⇒ `gather.*`跟`unified.rank`同型，是跨頂層橫切label，兩者不能用「佔比%」簡單相除，
改用「各自對`dt_us`算佔比」。

---

# ★②gather.*佔整tick的比例：穩定35%左右，主導但非單點熱點

27筆真實spike tick：**median=35.4%，mean=32.8%，範圍3.8%~52.9%**
（低值集中在ambition/order burst那幾個tick，被稀釋）。

⇒ gather.*是**持續性的大宗貢獻者**（約1/3的tick成本），不是單一離群尖峰。

---

# ★★★★③可證偽張力已解——gather.market/home_food現在【不是】O(tiles)

`known_issues:912`舊宣稱：`gather.market/home_food ★O(tiles)掃`（只引位置不引數值）。
實測矛盾：radius12/18/24（tiles 469→1801，3.84×）spike中位數不單調、tile最多階反而最低。

**查證（讀production code，file:line）**：
```gdscript
// faction_ai_system.gd:3440-3458 _nearest_market_outpost_with
for tile_id in known:   // ★迭代的是 state.team_market_known.get(team_id,{})，每隊自己的「已知市集快取」
                          //   不是 state.world.tiles 全圖

// faction_ai_system.gd:3463-3475 _harvest_market_known
var vr: int = VisionSystem.VISION_RADIUS   // ★★★核心證據
for dx in range(-vr, vr + 1):
    for dy in range(-vr, vr + 1):          // 迭代範圍 = 固定 vision 半徑窗，跟 map.radius 無關
```
`VisionSystem.VISION_RADIUS = 3`（`vision_system.gd:3`，**TEST VALUE固定常數**）——
完全與 `map.radius`(12/18/24) 無關，是 **O(vision_radius²) = O(3²) 有界掃描**。

⇒ ★★★**依你的三選一判讀表，落在【第二格】**：**gather主導(~35%)，但它【不是】O(tiles)**——
`known_issues:912` 那句機制宣稱已經是舊的/已被修過（現在的實作是 bounded vision-radius 掃描，
不是全圖掃）。

---

# 落地
`docs/process/verdicts/perf-rank-inside-gather.measure.json`
raw：沿用既有 `perf-coverage-tick9-19-29-full-dump.txt` + `perf-callus-300t.txt.checkpoint.perf_scale.txt`（未新跑，複用既有dump）
