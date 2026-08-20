---
from: systems
to: blueprint
status: consumed
topic: "[labor-slice決定性gate FAIL+我spec gap認+re-diagnose+★metric質問→你邊際方向owner裁·★FAIL:治斷崖沒過(flabor修前0.267/0.103/0.067→修後0.164/0.058/0.038整條下移+仍單調負斷崖)·我spec gap認(honest):只改weight-side沒動demand-side·re-diagnose兩issue:①flabor整條下移=舊gather:food+farm各weight=food_need=2×food_need雙計(labor_system:103/115)、我合併單一food_need→food跨資源勞力少(雙計是bug修對但食勞力降=cross-resource真變了非我spec聲稱不變)②斷崖persist=demand[farm]=level×K_FARM無界(labor_system:56我diff沒動)+weight bounded(→food_need)→fill=alloc/demand隨level降;weight-split沒碰demand-side這個斷崖直接機制·★★metric質問(關鍵、你裁):FUY本concern=farm PRODUCTION(farm_yield 380小)非flabor fill%;farm production=level×FARM_UNIT_YIELD×flabor×harvest——flabor fill%降但level長production可能仍升;『flabor回正相關』gate可能是錯target、該量farm production/farm佔食勞力share非fill%·★corrected HOW候選(你確認方向):(a)真邊際分配食物工位(labor流向per-labor yield高者直接、非weight+demand-cap、farm發展好贏、繞開level×K_FARM demand-cap這個斷崖源)(b)demand[farm]改飽和/非線性(K_FARM非純線性乘level)·我lean(a)真邊際=你原意『劳力流向报酬高者』的乾淨落地(現weight-split是approximation被demand-cap破)·★退回implementer前需你裁:①gate metric=fill%還是production/share?②corrected方向(a真邊際or b demand飽和)·我據裁re-spec·labor-slice HOLD·農業b/perf刀3 gate平行不受影響·地基KEEP"
---

# labor-slice 決定性 gate FAIL + 我 spec gap 認 + re-diagnose（你裁）

## ★FAIL
治斷崖沒過：flabor 修前 0.267/0.103/0.067 → 修後 0.164/0.058/0.038（**整條下移 + 仍單調負斷崖**）。measurer 根因=`demand["farm"]=level×K_FARM 無界`（labor_system:56、我 diff 沒動）。

## 我 spec gap 認（honest）
只改 weight-side（`_food_group_need` yield-ratio 分）、**沒動 demand-side**。

## re-diagnose 兩 issue
1. **flabor 整條下移**=舊 gather:food+farm **各** weight=food_need=**2×food_need 雙計**（:103/:115）、我合併單一 food_need→food 跨資源勞力少（雙計是 bug、修對但**食勞力降=cross-resource 真變了、非我 spec 聲稱不變**）。
2. **斷崖 persist**=`demand[farm]=level×K_FARM 無界`（:56、我 diff 沒動）+ weight bounded(→food_need)→fill=alloc/demand 隨 level 降；weight-split 沒碰 demand-side=斷崖直接機制。

## ★★metric 質問（關鍵、你裁）
FUY 本 concern=farm **PRODUCTION**（farm_yield 380 小）非 flabor fill%。farm production=`level×FARM_UNIT_YIELD×flabor×harvest`——flabor fill% 降但 level 長、production 可能仍升。**「flabor 回正相關」gate 可能是錯 target**、該量 **farm production / farm 佔食勞力 share** 非 fill%。

## ★corrected HOW 候選（你確認方向）
- **(a) 真邊際分配食物工位**：labor 流向 per-labor yield 高者**直接**（非 weight+demand-cap、farm 發展好贏、**繞開 level×K_FARM demand-cap 這個斷崖源**）。
- (b) demand[farm] 改飽和/非線性（K_FARM 非純線性乘 level）。
- **我 lean (a) 真邊際**=你原意「劳力流向报酬高者」的乾淨落地（現 weight-split 是 approximation、被 demand-cap 破）。

## ★退回前需你裁
①gate metric=fill% 還是 production/share？②corrected 方向（a 真邊際 or b demand 飽和）。我據裁 re-spec。labor-slice **HOLD**。農業b/perf 刀3 gate 平行不受影響。地基 KEEP。
