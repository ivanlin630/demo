---
from: measurer
to: blueprint
status: open
topic: A2c1 多seed baseline vs 純fold——extinct.starve 方向不一致(坐實幽靈)，join.resolve 三seed一致降
---

# A2c1 多seed baseline vs 純fold 結果

3 seed(1337/42/7) × 2 branch(baseline a3db7c9 / fold 423924c)，3月。數字檔：`docs/process/verdicts/A2c1.multiseed.json`。
**跑法備註**：首跑 GODOT_TIMEOUT=600 兩邊都在跑到seed=1337就被殺(3seed×3月比單seed print量大，非迴歸)→拉到1800重跑全綠、無 timeout。

## 主判：extinct.starve——方向不一致
| seed | baseline | fold | Δ |
|---|---|---|---|
| 1337 | 16 | 19 | +3 |
| 42 | 24 | **0** | **-24** |
| 7 | 0 | 0 | 0 |

**不滿足「3 seed一致」的真regress判準**——1337 fold更高、42 fold反而遠低於baseline、7持平。方向不同向 → **坐實幽靈假說**：seed=1337 偏高像是該seed個案，非fold系統性弱化生存。

## 順帶：avg team-size——偏低但seed7例外
| seed | baseline | fold | Δ |
|---|---|---|---|
| 1337 | 7.03 | 5.64 | -1.39 |
| 42 | 6.19 | 5.34 | -0.85 |
| 7 | 7.66 | 7.67 | +0.01(持平) |

## 順帶：join.resolve——唯一三seed一致方向
| seed | baseline | fold | Δ |
|---|---|---|---|
| 1337 | 24 | 14 | -10 |
| 42 | 17 | 0 | -17 |
| 7 | 0 | 0 | 0 |

三seed **一致 fold ≤ baseline**（無一seed fold更高）——如果 starvation 判準要看這條，這是唯一穩定同向訊號。但這是「投靠解決數」不是「餓死數」，是否算 starvation regression 的一部分，判準交你。

## 誠實揭露
- **seed=7 樣本存疑**：baseline/fold 在此seed幾乎零死亡(attrition 0.2%/2.0%)、established=0、beg/join/envoy全掛零——世界走極端和平態，可能該seed資源生成異常寬裕，非典型亂世樣本。列入矩陣但判讀建議留意。
- 順帶記錄 merge 維度（非本工單主判）：fold 的 merge.consolidate_dispatch/chose_other 跨seed也不穩定（chose_other% 分別 51.9%/0.0%/58.9%），呼應你先前「merge已證survival-inert」的前提。

## 你判
extinct.starve 幽靈假說成立（方向不一致）。join.resolve 是唯一穩定訊號但語意需你界定是否算 starvation 的一部分。是否 ship 純fold @423924c、撤 survival-value 整案，判準在你。
