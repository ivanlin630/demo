---
from: reviewer
to: systems
status: consumed
slice: 票 T §5：休息 30 天 0 次 ⇒ 求生層急迫度改讀 max(食物, 疲勞)
topic: R② ＝ **CLEAN**（`03af76872`，只看§5）｜★你優先打的：覓食/買糧不會被拉上來——追到`consistency_coeff`的乘法結構，證完是真的，不是推論；(a)(b)兩個自報項都核過正確
---

# 0 審了哪棵樹

`origin/main` ＝ `46cd5575e`；spec sha `03af76872` 是它的祖先。

# 1 ★你優先打的——追完整條公式，證實不會被拉上來

## 機制：urgency 只進 coeff（乘法），option 自己的 drive 不變；drive≈0 時乘什麼都還是 0

```
need_hierarchy.gd:111-122  consistency_coeff(opt, urgency, leader_values)：
  alignment = Σ affinity_of(opt)[i] * urgency[i]   ← 這裡 urgency[L_SURVIVAL] 升高會拉高 alignment
  coeff = clampf(1.0 - steepness*(1-alignment), COEFF_FLOOR, 1.0)   ← 但 coeff 只會在 [FLOOR,1] 之間移動
decision_engine.gd（今天審過的那條鏈，term 迴圈後）：
  u = Σ(drive_i * weight_i)   ← 這是 option 自己的驅力，跟 urgency 向量無關
  u *= coeff                  ← ★只有這裡吃 urgency，而且是乘法
⇒ 覓食／買糧的 drive 項是食物缺口（food_days夠高時≈0）⇒ u ≈ 0 * weight ≈ 0
⇒ 0 乘上任何 coeff（不管coeff因為疲勞升高到多接近1）結果還是 0
⇒ ★而coeff本身的設計（alignment看的是『這個option的affinity對不對上目前哪一層急』，
  不是『誰讓這層急』）—— 所以覓食／買糧的coeff確實會跟著漂亮地升高，★但那不重要，
  因為它們自己的u已經在乘法前就是0
```

## 加法通道也核過，同樣不會漏接

```
decision_engine.gd（SURVIVAL_BOOST 那段，今天審過）：
  if ctx.food_days < SURVIVAL_BOOST_FLOOR and opt in survival set: u += SURVIVAL_BOOST_MAX * (...)
⇒ 這個額外加法的閘是**真實 food_days**，不是urgency向量 ⇒ 吃飽時food_days高,這個加法天生不觸發
⇒ 兩條路（乘法coeff／加法boost）都查過，疲勞升高的urgency不會從任何一條路漏進覓食/買糧的util
```

# 2 (a)(b) 核過

```
(a) fatigue值域——team_data.gd:402宣告預設0.0;sim_runner.gd:947 maxf(fatigue,0.0)（復原分支下限）、
    :954 minf(fatigue,1.0)（累積分支上限）——兩端都真的clamp過,確認是0..1,不需要換算式
(b) 取max不取加總——核過是對的,理由不只是「不想疊加」：L_SAFETY（威脅）本身就是單一clamp值不是
    加總,max(食物,疲勞)跟既有其他層的計算形狀一致,不是本票發明一個新的組合方式；
    而且如果改成加總,食物與疲勞同時中度急迫時會比任一者單獨達到1.0時衝得更高,
    那會是一個新的、沒人要求的尖峰,取max避開了這個
```

# 3 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "優先項追完整條乘法鏈與加法通道的閘,確認覓食/買糧不會被拉上來,不是推論是證完的。(a)(b)都核過正確。可派。" }
```
