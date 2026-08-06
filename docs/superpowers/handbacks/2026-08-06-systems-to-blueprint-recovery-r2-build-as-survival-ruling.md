---
from: systems
to: blueprint
status: consumed
topic: "[★需你裁行為意圖:recovery-r2 invest 動詞命門=飢餓村肯不肯蓋救自己的東西(build-as-survival self-rescue)·R2 決策+送料層 DONE 7/8 綠(facility_roi survival-bounded/雙 survival-bound/森投/山不投/領主絕境不投/deposit 料入村 public_storage)·但★驗執行端 RED:料到村 45 卻 build_fired=0/farming 0→0·深根 Catch-22:invest-target 村(小森 ROI+)必 food-insecure→覓食 PRIO_SURVIVAL(80)壓過領主 build 令 PRIO_DISPATCH(50)→delivered 料永不蓋;ROI+ 需小 pop(森養不起多人)、小 pop 恒覓食·_trigger_survival 現只『護已在蓋』食物設施、survival 選項集不含『建設產糧設施』→飢餓村從不 survival-發起蓋 delivered farming=§2B 早預警的手不聽腦執行層 blocker·★這是 invest 動詞命門:沒它 invest 送了料村不蓋=零效果(同 R1 arrived=0 家族但更深=決策優先衝突非 wiring)·★需你裁行為意圖(WHAT/湧現平衡):食物不安全的村、拿到 delivered 產糧設施建材、該不該把『蓋它』當求生自救行動(與覓食競爭)?=invest 動詞本義(領主投資→村蓋→產糧→復甦)的必然、但『build-as-survival』是新行為+廣 survival-repertoire 改·systems recommend:YES 但 GENUINE util 非死常數:survival 選項加『建材備妥產糧設施 self-rescue build』、util=該設施預期食安價值 vs 建工期 vs 當前飢餓窗(建工期到食<餓死窗→蓋 util>覓食 util→村蓋;否則覓食)、scope 硬限僅產糧設施+料已備(延伸既有 _trigger_survival 食物設施 protect→initiate 前例、means-end build→food 非泛化 build-instead-of-forage)·你確認意圖+scope→我寫 HOW fix→implementer 收尾驗執行端·地基 KEEP"
---

# ★需你裁：recovery-r2 invest 動詞命門 = 飢餓村肯不肯蓋救自己的東西

## R2 現況
決策+送料層 **DONE 7/8 綠**（facility_roi survival-bounded / 雙 survival-bound / 森投 / 山不投 / 領主絕境不投 / deposit 料入村 public_storage）。**但 ★驗執行端 RED**：料到村 45 卻 `build_fired=0` / farming 0→0。

## 深根 = Catch-22（決策優先衝突、非 wiring）
- invest-target 村（小森 ROI+）**必 food-insecure**（ROI+ 需小 pop、森養不起多人、小 pop≤FORAGE_VIABLE_POP 恒覓食）。
- 覓食 `PRIO_SURVIVAL(80)` 壓過領主 build 令 `PRIO_DISPATCH(50)` → **delivered 料永不蓋**。
- `_trigger_survival` 現只「**護已在蓋**」食物設施、survival 選項集**不含「建設產糧設施」** → 飢餓村**從不 survival-發起**蓋 delivered farming。
- = §2B 早預警的**手不聽腦執行層 blocker**（村不肯蓋救自己的東西）。同 R1 arrived=0 家族、但更深（決策優先衝突非 wiring bug）。

## ★這是 invest 動詞命門
沒解 → invest 送了料村不蓋 = **零效果**（送料層綠也白搭）。

## ★需你裁（WHAT / 湧現平衡）
**食物不安全的村、拿到 delivered 產糧設施建材，該不該把「蓋它」當求生自救行動（與覓食競爭）？**
- = invest 動詞本義（領主投資→村蓋→產糧→復甦）的**必然**；但「build-as-survival」是**新行為 + 廣 survival-repertoire 改**（影響所有飢餓隊、非只 recovery）→ 值你確認意圖。

## systems recommend（機制、GENUINE util 非死常數）
- **YES**，但 survival 選項加「**建材備妥產糧設施 self-rescue build**」、util = **該設施預期食安價值 vs 建工期 vs 當前飢餓窗**（建工期到食 < 餓死窗 → 蓋 util > 覓食 util → 村蓋；否則覓食=正確不亂蓋）。
- **scope 硬限**：僅**產糧設施 + 料已備**（延伸既有 `_trigger_survival` 食物設施 protect→initiate 前例；means-end build→food、**非泛化 build-instead-of-forage**）。

## 序
你確認**意圖 + scope** → 我寫 HOW fix → implementer 收尾驗執行端 → measurer 量（森村投資後真蓋 farming→inflow 翻正→breed）→ QA → merge。地基 KEEP。
