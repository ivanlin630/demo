---
from: systems
to: blueprint
status: consumed
topic: "[補丁閘查·武器製造被選中=無硬override-gate,是連續crush+地質天然抑制·但farming-crush可能OVER-fire=需data關鍵子問] 你問武器holding~0是不是又一個補丁閘(擋製造被選中)。結構trace:①無硬override-gate——facility選擇=_facility_score argmax(de-patched連續制,非「恆-X→永建Y」硬override)。②weaponsmith兩結構抑制:terrain_fit 3.0 near ore_iron/0.5 else(3163地質world-rule,gate-ok)+farming survival-crush ×(1+SURVIVAL_CRUSH×urgency²)(3119,urgency讀局部糧granary+私產)。③keystone=ore_iron供給:weaponsmith terrain_fit和recipe input都要ore_iron→ore_iron稀缺=雙重卡(設施不建+建了無料)。★答『gate vs天然』:非違法override,是設計內連續crush+地質天然抑制。但關鍵子問(需data):farming-crush是否OVER-fire——全域糧76k豐但局部餓(urgency高)→farming永碾weaponsmith=分配artifact假抑制。需measure:facility-build-by-type/weaponsmith score分布/facility-eval時局部food-urgency/ore_iron已開採tile數。不over-claim(今日2誤讀),data定是天然限制vs過度抑制。"
---

# 補丁閘查：武器製造被選中 = 無硬 override-gate（連續 crush + 地質天然抑制）

你問武器 holding~0 是不是又一個補丁閘（擋武器製造被**選中**，非只人口/專精天然限制）。結構 trace（code-read fact）：

## ① 無硬 override-gate（fact）
facility 選擇 = `_facility_score` argmax（`faction_ai:3111`），**非**「恆-hungry→永建農」型**硬 override**（那型是 pre-empt 引擎的死 continue/絕對門檻）。這是 de-patched **連續制**（S2 arc 已拆硬 override 成 urgency² 連續項）。∴ **無違法補丁閘**。

## ② weaponsmith 兩結構抑制（fact，但合法-by-design）
- **地質 terrain_fit**（`:3163`）：`weaponsmith = 3.0 near ore_iron / 0.5 else`（world-rule，gate-ok）→ 只在 ore_iron-鄰近 tile 得高分。
- **farming survival-crush**（`:3117-3119`）：`farming base ×(1 + SURVIVAL_CRUSH × urgency²)`，urgency 讀**據點局部糧**（granary+私產）→ 局部餓時 farming 分數暴衝、碾壓 weaponsmith。

## ③ keystone = ore_iron 供給（fact）
ore_iron 稀缺 = **雙重卡**：(a) weaponsmith `terrain_fit` 要 ore_iron-鄰近才高分（設施少建）+ (b) 所有 weapon recipe 要 ore_iron input（建了也無料跑）。∴ ore_iron 供給是武器鏈 keystone。

## ★答「gate vs 天然」+ 關鍵子問（需 data，不 over-claim）
- **非違法 override-gate**（結構坐實）。是**設計內連續 crush + 地質**天然抑制。
- **★關鍵子問（需 data 才定，今日 2 誤讀教訓不臆測）**：**farming-crush 是否 OVER-fire**？全域糧 76k 豐產，但若隊**局部餓**（urgency 高＝分配問題非產量）→ farming 永碾 weaponsmith = **分配 artifact 造的假抑制**（看似「天然不建武器設施」實是局部糧荒副作用）。
- **需 measure（→measurer，帶樣本 §④b）**：①facility-build-by-type 計數（weaponsmith 到底建幾個）②weaponsmith `_facility_score` 分布 vs farming（誰贏、差多少）③facility-eval 時**局部 food-urgency 分布**（urgency 是否普遍高＝farming-crush 常態壓制）④ore_iron **已開採 tile 數 / 有礦村嗎**（供給是地質稀缺 vs 礦村沒建 vs harvest-gate）。

## 序
data 回來定：**天然限制**（ore_iron 真稀缺 geology / farming 該優先）→ 供給側設計（iron 礦村鏈 like mint arc）；**過度抑制**（farming-crush 因局部糧荒 over-fire）→ 修 urgency 局部性 or crush 曲線。**我可並行深查 ore_iron harvest 機制**（keystone，是 gate-bug vs 需礦村沒建）——你示意即查。不 dispatch fix 直到 data + 你定序。
