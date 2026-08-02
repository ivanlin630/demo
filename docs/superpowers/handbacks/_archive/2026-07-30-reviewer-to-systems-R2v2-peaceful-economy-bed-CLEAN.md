---
from: reviewer
to: systems
status: consumed
topic: "[R²v2 CLEAN] 和平經濟床——①/③established+缺料設施修法親驗坐實真活+liveness斷言/honest措辭皆到位，implementer開工"
---

# R²v2 判決：和平經濟觀測床 HOW（訂正後）— CLEAN

## ①/③修法——親驗坐實真活
`CONSTRUCTION_DESIRE_MIN`（`need_oracle.gd:29`，真實既有常數=0.3）確認接進 `_construction_facility_need`(:59) 跟 `goal_resolver.gd`(:59/74)——established outpost + facility deficit≥0.3 + build-cost含material，`_construction_facility_need`真的會加上非0的`cost_r`（:55-61），讓`need_keep(material)`從恆0變成真的>0。`holding(≈0) < need_keep(>0)`是真不等式，`goal_resolver.gd:197`的閘不再一開局就吐空，買（200）跟forest founding delegate（206-219）兩分支都真的碰得到。這不是換個包裝的參數，是我上輪抓到的因果斷點被真正接上了。

## ★fixture-liveness斷言——比我要求的更進一步
t0斷言每①隊`need_keep(material)>0`+forest tile在range，不過就FAIL拒開工——這把「fixture活不活」變成機器可驗的閘，不是我要求的範圍（我只要求二選一：改情境或誠實措辭），你直接把「別再犯」焊進機制本身，比單次修正更耐用，值得肯定。

## honest措辭——區分到位
spec §4/§2①末段明確切開「code-provable已知」（fresh無outpost隊material-founding動機結構不存在=bootstrap gap，記known_issues）vs「live經驗案」（established隊secondary-founding/develop/trade/runway）——不再把一個必然結果包裝成待驗經驗問題，措辭跟我的核心關切完全對上。

## ②④——維持，跟我上輪核可一致

## 判決
**CLEAN → implementer（config+薄bed+liveness斷言）。** 這輪 Step0 量測地基現在站得住——4問資料出來後才有資格談分支裁定，不會再有「資料還沒跑就已知答案」的風險污染 pivot 判斷。measurer 跑完落地 docs/measurements 後回 blueprint 裁分支。
