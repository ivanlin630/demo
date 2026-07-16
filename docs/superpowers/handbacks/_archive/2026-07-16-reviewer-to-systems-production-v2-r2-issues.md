---
from: reviewer
to: systems
status: consumed
topic: "[R²判決·issues] 統一生產框架v2 spec——R①兩致命解法扎實(序/CRUSH scope/granary切面/S3方向/常數分層/誠實標記全CLEAN),但v1異質審報告裡幾項額外補丁閘(礦山強制civilian/farming不拆排除/飢荒免疫特例)+P3 govern雙寫風險+2處tap缺口未見裁定,跟藍圖『拆光全部』授權有落差"
---

# R² 判決：統一生產框架 v2 spec

verdict: **issues**
premise_contradiction: false

## R① 訂正項在 v2 落地複核（CLEAN）

1. **序（S2 驗過才 S4）**：`spec:27/34/45/51` 三處一致「★序照藍圖：score 修好才拆 override，全程無餓死窗口」+ S2.4 明文「過了才准 S4 拆 override」——gate 寫死在交付切片順序裡，非口頭承諾。CLEAN。
2. **CRUSH 項 scope**：`spec:35-42` 明寫「farming/食物設施 score」，公式標題就是 `farming_score=...`（非改動共用 `_facility_score`），workshop/軍事等設施不掛此項——scope 乾淨。CLEAN。
3. **granary seam 切面**：`spec:43` 重申「只改 facility-eval reader，不動消耗/survival positional effective_food」——與 R① 核對的切點一致。CLEAN。
4. **S3 means-end 統一**：`spec:48` 「同 `_pick_facility` argmax 決策+建造 dispatch，非另開平行路」——方向對，且 `spec:49` 明文標「★待 measurer 坐實（誠實標）」，未寫成篤定 emergent。CLEAN。
5. **常數分層**：`spec:22-25` 三條分層精確對應 R① 訂正（`×0.8` flat 釘死/`×7` 人格化/`TARGET_PER_POP` 拆兩常數）。CLEAN。
6. **誠實標記**：spec 開頭「狀態」區塊 + S3.2 + 量測#5 三處一致標記「urgency 真 fire」「獨立隊 has_facility 成長」為行為層待驗證，非重寫成篤定敘事——這正是整個 R① 存在的理由，確認沒有走回頭路。CLEAN。

## issue：v1 異質框外審報告裡的額外發現，v2 未見明確裁定

我稍早派異質模型（Fable）對 v1 spec 做框外審時，除了 R① 後來擋下的兩個致命 premise_contradiction 外，**還找到幾項額外的補丁閘/風險**，v2 spec 通篇只處理了 A1（override）+ A2 + A3/A4 headline 四閘 + R① 兩致命，**對下列項目沒有明確的「拆/留/人格化」裁定**：

1. **S2 礦山強制 civilian override**（`faction_ai_system.gd:2923-2930`）：`_pick_outpost_type` 的人格秤（`:2827-2835`，本身設計良好）被「含礦→硬改 civilian」蓋掉——這是跟 A1 完全同型的病（決策焊進機制），藍圖原始授權是「拆光生產/設施子系統**所有**補丁閘」，這條在 v2 沒被提及。
2. **`_lowest_score_facility` 的「農田不拆」硬排除**（`:2979 if f=="farming": continue`）：S4.1 說「demolish-for-farming 泛化成 best utility>lowest+門檻則拆建全設施通用」，但沒說這條既有排除保不保留——若保留（合理，不該拆自己的糧倉去蓋別的），該明文寫成「規則」（世界物理：不拆命脈設施）而非放著當殘留 override 沒交代；若拆除，需要新的保護機制替代。**兩者都行，但 spec 要交代選哪個，不能沒講。**
3. **`_trigger_survival` 的「蓋農田不被飢餓中斷」特例**（`:3250-3258`）：override 拆除後，這個特例是否要泛化為「工期短+產糧設施」的通用判準？spec 未觸及。
4. **P3 govern 雙寫風險**（Fable 原始發現）：`options.gd` 已有「駐守」→ TASK_GOVERN 引擎 option；`spec:53` S4.2「govern 成競秤 option（公庫缺口×慎重 term）」沒指定這個 term 掛在哪裡——若 `_evaluate_infrastructure` 的 utility 化也秤 govern、引擎的「駐守」又秤一次，同隊兩個決策者都能派 TASK_GOVERN，重演本專案自己的 Team10 教訓（`faction_ai_system.gd:3122` 註解記載的「雙決策生產者互蓋 livelock」）。**這條需要 spec 明確指定單一 owner**（建議：govern term 併入既有「駐守」engine option，infra 層不再秤這件事——非新設計，是避免雙寫）。
5. **tap 清單漏兩處**（Fable 原始發現）：S1.3 只列「manufacturing_system 各 no-op continue」的籠統帶過，需明確確認是否涵蓋 `_run_recipe_group` 的原料不足靜默 no-op（`manufacturing_system.gd` `_can_consume_scaled` 不過→`return ""`，無 tap）——這是「下一個必然復發的 tap-gap」（有設施、有 resident，material 不夠時每 tick 靜默空轉，跟 A2 是同一種「病躲很久」病灶，只是換一個門檻條件）；以及 `tile==null or outpost_level==0` continue 路徑（據點消失後的殘任務空轉）。這兩點若不明確列入 tap 清單，S1-S4 修完後供給牆 story 會少一塊可觀測性。

## 為何值得在此輪提出（非吹毛求疵）

藍圖原始授權（`production-arc-greenlight`）明講「拆光生產/設施子系統**所有**補丁閘、全融進框架，無殘補釘再量」——這正是為了避免「打地鼠」（修一個閘、下一輪又冒出下一個）。上面 5 項都是**同一批**異質審查找到、跟 A1-A4 同型的補丁閘/風險，如果不在這一輪一併裁定，等 measurer 下一輪撞到礦山村行為異常/govern 雙派/原料靜默空轉，又要重開一輪 spec+R①+R②——這正是用戶想避免的循環。

## 結論
R① 擋下的兩個致命問題，v2 的修法扎實、我逐項核對過落地正確。**issue＝v1 異質審報告裡的另外 5 項（同型補丁閘/雙寫風險/tap 缺口）在 v2 沒有明確裁定**——不要求重新設計，只要求對每一項給一個明確的「拆/留為規則/人格化/併入既有 term」裁定並寫進 spec，避免下一輪 measurer 又抓出新的一批。**issues → halt，退回補上這 5 項裁定後可 CLEAN**（不需重升異質，同一批已審過的發現，收斂即可）。
