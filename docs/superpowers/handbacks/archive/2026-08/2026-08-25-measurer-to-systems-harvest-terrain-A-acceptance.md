---
from: measurer
to: systems
slice: harvest-terrain-from-regen
status: consumed
topic: "A驗收四條全PASS：①RES_HARVEST_TERRAIN窮盡grep只剩1處註解,已被harvest_terrains()動態導出取代②food的『不可採』桶=空陣列[],乾淨歸零,候選數0→249③時間分佈day000~day086貫穿全90天(中段day032-037有明顯高峰34/31/28),質變確認④material的satisfied_own_terrain抽驗10筆(母體76)全部own_v≥best_alt_v無退化跡象,但非窮盡覆蓋,誠實邊界已標"
---

# A驗收：四條全PASS

## ①手工表消失（結構）：PASS
全`scripts/`樹窮盡grep`RES_HARVEST_TERRAIN`只剩1處，是`goal_resolver.gd:387`的說明性註解（講它已被刪），非活symbol。取而代之：`harvest_terrains(res)`(:394-400)當場掃`ResourceSystem.REGEN_RATE`算哪些地形產這個資源，零手抄表。

## ②food的has(res)卡點歸零：PASS，乾淨的零
落到取得手段2(採@地形)時缺的資源分類：`["food=249", "material=164", "tools=2154", "weapon_melee_low=3425"]`——其中【不可採】清單＝**空陣列`[]`**。food不再落入這個桶。產出候選數：food從A修前的0變成**249**。

## ③時間分佈質變：PASS，不是day0之後歸零

真count逐日分佈（非sample）：`day000=28`（冷啟動批，與修前一致）→ `day001~020`持續1~8的小批次不間斷 → `day026/027`各11 → **`day032=13/day033=9/day034=28/day035=34/day036=31/day037=28`（中段明顯高峰）** → `day038`之後持續1~15小批次 → 一路延伸到`day086=1`（接近窗尾仍有活動）。

**定性**：不是「day0之後歸零」——90天視窗內幾乎每隔幾天就有新的build候選產生，中段有一波明顯活動高峰。這是「一次性凍結」→「持續產生候選」的質變。

## ④material不得退化：本輪抽驗未見退化，但非窮盡

`goal.harvest.satisfied_own_terrain=76`(母體真count)，report附帶10筆逐案dump(全team10/material/mountain)，每一筆`own_v`都≥`best_alt_v`(4.529≥4.445、4.213≥4.134、3.69≥3.621)——這正是「判定沒有變寬鬆」的訊號(若變寬鬆會出現`own_v<best_alt_v`卻仍`satisfied`的違例，本輪10筆零違例)。

**★誠實邊界**：這10筆是bed既有report的sample dump，不是76筆母體的窮盡覆蓋——只能說「抽驗到的10筆沒有退化跡象」，不能說「76筆全部沒有退化」。要坐實全部需另一輪把sample cap拉到≥76或改用逐案counter，供你裁要不要追。

## 併報(非本票成敗)

`outpost.l0_to_l1=4`，`construct.start=29/complete=30`——比前兩張床都高，但B型(tools/weapon_melee_low佔92%)仍在、已標blocked-by，不是本票判準。

## 落地

`.measure.json`：`docs/process/verdicts/harvest-terrain-A-acceptance.measure.json`
`report`：`docs/measurements/breed-deathcause/harvest-terrain-A-acceptance-90d.txt`

## L3聲明

零code改動——沿用worktree既有tap與既有bed，只是換config跑一次。
