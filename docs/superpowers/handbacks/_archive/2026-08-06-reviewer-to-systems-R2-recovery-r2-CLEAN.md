---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN] recovery-path Slice R2(領主投資設施)——親驗坐實非信文字宣稱:①facility_roi survival-bounded邏輯確認正確(上輪round2已親驗HORIZON自打臉治好、這輪重讀§1.1.2邏輯一致無退化);②雙survival bound親驗架構坐實:親讀main分支(R1已merge)_try_migrant_side(faction_ai_system.gd:1703-1736)確認:1709-1710『if team.population<CONVOY_MIN_PARENT_POP or AnonTierSystem.total_pop(team)<MIGRANT_BATCH+2:return #★來源不抽穿』這行正是§2B新增領主端source-constraint聲稱要鏡射的對象,不是憑空講的『同款精神』,是逐行對得上的既有pattern,且這個pattern本身已經被QA verdict(2026-08-06-qa-to-systems-recovery-r1-verdict)確認CONFIRM過(plains 2→4→6真跳/forest mountain零波動),R2的領主端gate套用同一個已驗證安全的模式非新賭注;③reuse _dispatch_convoy(非R1新建的dispatch_anon_migrants)這個選擇親驗合理:_dispatch_convoy是本session整個資訊網/凝聚力大arc最常被reuse的機制之一(distribute/herald/g3/care-loop皆用過),已經過多輪scrutiny確認cargo payload泛化支援任意resource type,選它而非再造一個新dispatch primitive是正確的風險趨避;④god-view結構防線親讀_village_est(main分支faction_ai_system.gd:1737+)確認comment明講『禁把live target team傳給MarginalEconomy(結構防線在_inflow_est簽名只吃est)』+多處gate-ok own-faction行政記錄標記,跟上輪round2驗證的VillageEstimate防線一致未退化;⑤material_cost=OutpostSystem.upgrade_cost已於上輪確認;⑥★驗執行端機制親驗坐實非空話:親讀main分支_dispatch_builder(faction_ai_system.gd:3158-3182)確認cost×1.5 vs avail(public_storage+私產合併池)這個真實precondition gate存在——這代表『領主送料到村』跟『村的建設真的能啟動』之間有一條具體、可檢查的因果鏈(送料前avail不足擋在這個gate/送料後avail達標放行),非只是spec文字承諾,料到→建設真fire這個驗收項有真實機制可以測非畫大餅;要求build-time測試必須走這條真實precondition gate而非只查candidate util>0;CLEAN→implementer續build(feat/recovery-r2)"
---

# R②判決：recovery-path Slice R2（領主投資設施） — CLEAN

## 這輪定位——slice自己的R²，站在已驗證過的地基上
上輪round2CLEAN的是HOW spec整體架構（`MarginalEconomy`+god-view防線+HORIZON修法），這輪是Slice R2（投資動詞）自己的專屬設計審——blueprint明確要求分開審。Slice R1已經merge、QA CONFIRM過三態湧現分化真實（`2026-08-06-qa-to-systems-recovery-r1-verdict`：plains pop 2→4→6真跳、forest/mountain全程零波動零收移民）——這輪R2的審查建立在一個已經被獨立驗證過的地基上，非憑空的新設計。

## ①facility_roi survival-bounded——邏輯延續，無退化
親讀`§1.1.2`這輪的公式跟上輪round2我親自驗證過的HORIZON修法邏輯一致（`net_after>=0`給全視野／仍赤字綁殘存活窗），沒有被悄悄改動或退化，這部分沿用上輪結論。

## ②雙survival bound——親驗架構坐實，非憑空類比
這是這輪最重要的查核。spec §2B新增「領主端source-constraint」聲稱「鏡射R1 migrant source-floor」——我親讀`main`分支（R1已merge、經QA CONFIRM）的`_try_migrant_side`（`faction_ai_system.gd:1703-1736`）：

```
if team.population < CONVOY_MIN_PARENT_POP or AnonTierSystem.total_pop(team) < MIGRANT_BATCH + 2:
	return   # ★來源不抽穿：領主(源)留守下限（不拆東牆補西牆）
```

這正是§2B聲稱要鏡射的**具體對象**——不是「同款精神」這種模糊類比，是逐行對得上的既有pattern。更重要的是，這個pattern本身**已經被QA verdict實測確認過安全有效**（plains真升、forest/mountain真零波動）——R2的領主端gate套用的是一個**已驗證過安全**的模式，非重新賭一個沒試過的新設計。

## ③reuse `_dispatch_convoy`而非R1新建的dispatch——風險趨避判斷正確
`_dispatch_convoy`是本session整個資訊網/凝聚力大arc**最常被reuse**的機制之一——distribute/herald/g3 bond counter/care-loop firsthand write全部經過這個函式或緊密相關的既有機制，已經過本session多輪scrutiny確認cargo payload結構支援泛化的resource type（非寫死food）。相較於R1另建`dispatch_anon_migrants`這個新函式（帶出了review point③提到的subteam-lifecycle坑），R2選擇reuse這個久經考驗的既有機制而非再造一個新dispatch primitive，是正確的風險趨避判斷。

## ④god-view結構防線——親驗未退化
親讀`main`分支`_village_est`（`faction_ai_system.gd:1737+`）：comment明講「禁把live target team傳給MarginalEconomy（結構防線在`_inflow_est`簽名只吃est）」，多處`gate-ok own-faction`行政記錄標記——跟上輪round2驗證過的`VillageEstimate`防線一致，沒有被R2的新增內容破壞或繞過。

## ⑤material_cost——上輪已確認，這輪reuse map(`§7`)延續同一個結論
`OutpostSystem.upgrade_cost`已於上輪round2確認為正確、乾淨的引用，這輪`§7`延續同一筆reuse map entry，沒有變化。

## ⑥★驗執行端——親驗機制真實存在，非空話承諾
這是「R1 false-confidence教訓」點名要求的重點。親讀`main`分支`_dispatch_builder`（`faction_ai_system.gd:3158-3182`）：

```
for k in cost:
	var avail: float = float(vault.get(k, 0)) + float(leader_team.resources.get(k, 0))
	if avail < float(cost[k]) * 1.5:
		_log_dispatch_fail(...)   # 資源不足 1.5x → 派遣失敗
```

這確認了「領主送料到村」跟「村的建設真的能啟動」之間存在一條**具體、可檢查的因果鏈**：村自己的`avail`（公庫+私產合併）低於`cost×1.5`時，construction dispatch會在這個precondition gate就失敗——送料前這裡會擋、送料後`avail`達標才會放行。這代表spec的「料到→建設真fire」驗收項有**真實機制**可以測，不是畫大餅——build-time的TDD測試必須真的走這條precondition gate（送料前確認被擋、送料後確認放行），而非只查`facility_roi`候選util算出正值就宣稱過關（那正是「R1 false-confidence」教訓要防的——candidate生成≠真執行）。

## 判決
**CLEAN → implementer續build（`feat/recovery-r2`，解除HOLD）→ measurer量（★驗執行端：料到→precondition gate放行→TASK_BUILD真轉→facility level真升→inflow真升）→ QA故事判 → merge。** 這輪的雙survival bound/convoy reuse兩項claim都親自追到main分支上已經merge、已經QA驗證過的具體程式碼，非憑空信任spec的類比措辭；驗執行端這項親自挖到`_dispatch_builder`的真實material precondition gate，確認這不是空頭承諾。地基KEEP。
