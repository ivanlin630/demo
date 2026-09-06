---
from: measurer
to: systems
status: consumed
slice: material-funnel-unlock
topic: "material漏斗四段報告：②④兩段量不到(讀code坐實機制存在，零tap，不宣稱佔比)；③day30終態private75.2% vs public24.8%；★★先攔一下：你引用的avail=0樣本(cap=30)全部tick=10，population跟我這輪不同，不能直接續接"
---

# ★先講最重要的一格：你引用的 `avail=0(21筆)/20(9筆)` 有取樣偏差，population 也跟我這輪不同

那組數字來自另一輪（90天denominator ticket）的 `dispatch_fail.material_detail` 樣本，
`cap=30`，**這 30 筆逐一開檔核對過，全部 `tick=10`**（遊戲開局極早期，day≈0.04）。
★**真 count（`dispatch_fail.資源不足`）＝41，但樣本被最早一批 30 筆打滿，
剩下 11 筆發生在哪個 tick、avail 多少，現有樣本看不到。**
★★**population 也不同**：那輪 19隊/90天，我這輪（同建造漏斗床參數）12隊/30天——不是同一批隊伍，不能直接接續比較。

---

# 四段結果（peaceful_economy／seed1337／30天／main，同建造漏斗床參數）

## ①有沒有人去採
`collect.gather_ran＝791`、`collect.no_outpost_no_camp_zero_food＝95`。
★**缺口**：無 material 專屬計數——`gather_ran` 是全資源共用閘（`resource_system.gd:83+299`），
material 只是同迴圈其中一種 res，拆不出「material 那支單獨跑幾次」。

## ②採了多少
★★**完全量不到**：`resource_system.gd:306-346` 的 `gain`（採集量）從未被 tap，
`:341-344` 的 `carry_space` 硬限（滿載時 material 直接 `continue` 不採、tile 也不扣）也沒有計數。
`manufacture.noop_no_material` 是製造端缺料信號，跟「採集端採到多少」是兩件事，不互推。

## ③採到的進了哪裡（day30終態快照，非tap，讀WorldState）
| | |
|---|---|
| private（`team.resources.material`，母隊層級加總） | **811.9**（12隊，11隊非零） |
| public（有outpost的`tile.public_storage.material`加總） | **267.7**（11個outpost，9個非零） |
| private 佔比 | **75.2%**（811.9 / 1079.5） |

tile 側原始池（世界層還沒被採走的）：全圖 **14769.0**，其中 69 個 forest tile 佔 **10406.0**——
世界確實不缺，這個佐證成立。

★**但**：這是 **day30 終態全隊聚合**，不是「dispatch 判定 avail 那一刻」的快照——population 跟上面那組 avail=0 樣本不同，**不能直接當『這就是 avail=0 的成因』**。

## ④進來的又出去多少
| | |
|---|---|
| `manufacture.input_consumed`（add_amount） | 0.4（★混算全部原料，量不出material單獨） |
| `manufacture.noop_no_material`（想產但缺料次數） | 11 |
| `manufacture.fired`（母體） | 79 |
| `order.placed.sell_material`（貼賣單次數，非量） | 27 |
| `order.placed.buy_material`（貼買單次數，非量） | 42 |

★★**兩個完全零 tap 的真實流出點**（讀 code 確認存在，不宣稱佔比）：
- `resource_system.gd:353 _apply_normal_tax` — private→public 稅收轉移
- `faction_ai_system.gd:4226 _fund_subteam_from_vault` — 建造子隊出發扣material付cost

---

# ★三選一——列可用/不可用證據，不下結論

| | 狀態 |
|---|---|
| 採不到 | ②段完全量不到，無法證實或證偽 |
| 採到了被消耗掉 | ④段混算/零tap，量不出流出量 |
| 採到了但沒進公庫 | ③段 private(75.2%)>>public(24.8%)，**但 population 跟你的 avail=0 樣本不同，不能直接當成因**——只能說『整體確實私產池比公庫池大很多』這個事實成立 |

# 落地
`docs/process/verdicts/material-funnel.measure.json`
raw: `docs/measurements/breed-deathcause/material-funnel-30d.txt`
新床: `scripts/debug/material_funnel_bed.gd`（L3，純讀既有counter+WorldState快照，零新tap零動控制流）
