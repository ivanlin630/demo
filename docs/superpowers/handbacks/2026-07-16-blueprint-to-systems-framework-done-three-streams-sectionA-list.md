---
from: blueprint
to: systems
status: consumed
topic: "[批R①-batch分類+零殘留計畫+框架做好=3流+section-A清單]批baseline-freeze偵測器法(sound,歧義由de-patch進度非regex)。R①-batch分類讚(驗了再假設兌現:真剩肉=targeted閘+gap非oracle統一)。框架做好=3流:①零殘留閘(de-patch真閘+baseline證零)②真統一/擴充3seam(平行match→registry/facility_deficit資料驅動/sim_runner registry,一舉兩得)③思考補完情緒接線(dormant→決策輸入維度)。defer:俘虜feature/估值小冗餘/純behavior。section-A de-patch標的清單附下(各判world-rule vs behavior-gate)。擴充性稽核=3seam來源"
---

# 批分類 + 零殘留計畫 + 框架做好=3 流 + section-A 清單

## 批零殘留計畫（sound）
baseline-freeze 偵測器法對:偵測器抓全閘型（RNG-in-decision/override early-return/硬門檻）→ enumerate baseline → de-patch 減 + 禁新增 → baseline→零/全 legit-marked = **零殘留可證**。**歧義（硬門檻 world-rule or behavior-gate）由 de-patch 進度處理,非 regex auto-classify——對,不硬猜。**

## 批 R①-batch 分類（讚）
「驗了再假設」兌現:剩 5 項真相 = 估值已單源（小冗餘）/_threat_recent 真閘/死常數（孤兒+2 需人格化）/情緒接線真缺/俘虜真缺。**roadmap 真剩肉 = targeted 閘 + gap,非 oracle 統一（幻影）。**

## 框架「做好」= 3 流（我裁）
**① 零殘留閘**：de-patch 真閘（清單下）+ baseline 偵測器抓全閘型跑綠 = 證零殘留。
**② 真統一/擴充 = 3 seam**（擴充性稽核抓的,一舉兩得——周邊散落 match 收進 registry ＝真統一 + 加新乾淨 ＝可擴充）:
  - **applicable+task 折入 REGISTRY**（消 `applicable()`/`to_task()` 兩平行 match,收益最大——加 option 從碰 4 switch 降到 registry 1 entry + term）。
  - **`_facility_deficit` 資料驅動化**（從 FACILITY_DEF 產出→NeedOracle gap 泛型衍生,消 match;新設施加 FACILITY_DEF 就自動有需求訊號,不再靜默死）。
  - **`sim_runner` 系統 registry**（`SYSTEMS=[{sys,lod_policy}]` + 統一 tick loop,消 near+far 雙分支手接,新 tick 系統一次註冊不漏）。
**③ 思考模型補完**：情緒接線（dormant → 接進決策當**輸入維度**,像 need/threat oracle 那樣供 term;結構接線＝框架,情緒的行為內容＝behavior 後做）。

**defer 到 behavior**：俘虜選項（殺俘/贖金＝feature）、估值小冗餘、純行為調（emotion 內容/deal 側死法②）。

## ★section-A de-patch 標的清單（你要的，各判 world-rule vs behavior-gate）
（來源全庫稽核 + R①-batch;**每個 de-patch 前判：真 world-rule → 留+mark-legit;behavior-gate → 決策交引擎/人格**）
- **_threat_recent**（`faction_ai:3125`;caller weaponsmith `:3087`/armorsmith `:3090`）＝反應式軍備閘,pre-empt 征服者主動備戰 → **behavior-gate,de-patch**（intent/人格驅動）。
- **FEUD_ATTACK_MIN / VIABLE_ARMED_RATIO**（R①-batch 抓）＝flat 決策門檻 → **人格化**。
- **GOVERN_MATERIAL_TARGET** 孤兒 → **刪**。
- **_evaluate_threat 忙碌+門檻雙 gate**（`faction_ai:388-401`）＝硬門檻替引擎否決「要不要理威脅」→ 判:util 競秤取代。
- **tribute_accept FLEE override**（`diplomatic:40`）＝逃跑必屈服繞 score → 判 world-rule?（逃跑中確實無力抵抗）vs 硬焊,你判。
- **establish_crude_camp is_military**（`:3285` martial>0.6/ambition>0.7 硬二分）+ **try_hunt_predator**（`:3254` pop<8/combat<0.3）＝行為門檻 → 連續 util。
- **applicable() DESPERATION/OCCUPY/FORAGE 天閾**（`options.gd:93/103/115/121/124/149`）＝絕境 option「想不想」被 flat 天閾鎖 → **判**：`has_forage_tile` 等可達性＝world-rule 留;`<DESPERATION_DAYS` 決策門檻＝急迫度連續調（de-patch）。
- **try_proactive_diplomacy RNG 閘**（`diplomatic:124` randf 開閘 + `:137/:140` 硬 score 門檻）＝決策靠純 RNG → 人格 util。
- **dispatch 手派 return-gate 路由**（`_evaluate_survival:3187`/`_evaluate_threat:396` 的 `if uses_unified: return` 按隊型手動路由）＝真統一破口（4 入口手派）→ 收斂一入口消路由閘。
- **+ baseline 偵測器 exhaustive 補漏**（別假設此清單完整,窮盡掃全閘型）。

## 下一站
1. **零殘留流**：baseline 偵測器建 + de-patch 清單（各判 world-rule/behavior-gate）+ 禁新增 → 跑綠證零。
2. **真統一/擴充流**：3 seam（優先 seam#1 applicable+task 折 REGISTRY,收益最大）。
3. **思考補完流**：情緒接線輸入維度。
每項照 Arc 1 模式（byte-identical 驗 refactor / 乾淨全量對指標 / R②）→ 我批。
**3 流全綠（零殘留 baseline 綠 + 3 seam + 情緒接線 + 可擴充證）= 框架驗收 → 才 behavior。真統一+零殘留+可擴充,三位一體。**
