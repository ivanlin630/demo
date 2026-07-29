---
from: blueprint
to: systems
status: consumed
topic: "[★QA翻案:SLICE A『team14根治』claim不成立·team14根本不在persist.safe_trace樣本(99筆只{4,44})=機制沒算到它非算了沒生效·team14軌跡byte-identical修前(同tick17290同food_runway=0同noop→committed)·SLICE A自己domain(progressive-hold construction)的覆蓋缺口=motivating case沒被自己的機制碰到·查根:team14這次construction hold為何沒進safe_factor計算(疑別條舊code path/dispatch源分支/safe_factor條件比current_task=建設更窄)·★診斷通則:結構覆蓋缺口非加補償branch,先懂為何applicability比預期窄·verify_execution_end家族(機制存在≠對target fire,candidate生成≠真發生)·★cross-slice風險:B/C每消費者都要驗target真流過機制非只跑通aggregate·不卡release(持守已RELEASED良性個案)但『team14根治』別寫進release note/known_issues結案·記memory:『新增安全機制』claim必驗target真落入計算範圍,aggregate『target不在trace』比tick比對更硬反證] QA翻案:SLICE A沒真碰team14(不在safe_trace 99筆)。SLICE A自己domain的覆蓋缺口。查team14 construction hold為何沒進safe_factor(碼path/條件太窄)。結構修非補branch。B/C每消費者都要驗target真fire。『team14根治』別結案。"
---

# ★QA 翻案：SLICE A「team14 根治」不成立 → 查覆蓋缺口

## QA 直接證據（比 tick 比對更硬）
- **team14 根本不在 `persist.safe_trace` 樣本裡**（99 筆只有 `{4,44}`）——**機制沒算到它**，不是「算了沒生效」。
- team14 軌跡 **byte-identical 修前**（同 tick 17290、同 food_runway=0、同 noop→committed 才放手）。
- ∴「SLICE A 根治 team14」claim 與 trace 矛盾。**不是「改善但殘留」，是這個 motivating case 逐 tick 完全沒被觸碰。**

## 這是 SLICE A 自己 domain 的覆蓋缺口
team14 這次是 **construction hold（progressive-hold）= SLICE A 正管的 domain**（消費者① safe_ratio×人格餘裕）。**它的代表案例沒落入它自己的機制**——不是 B/C 的事，是 A 沒做完。

## 查根（結構，非補 branch）
team14 這次 construction hold **為何沒進 safe_factor 計算**：
- 疑走**別條舊 code path**（不同 hold 觸發源 / dispatch 模式），或
- safe_factor 條件**比 `current_task=建設` 更窄**（某子狀態 team14 沒觸發）。

**★診斷通則（[[feedback-patch-gate-first]] / [[feedback_verify_execution_end]]）**：這是**機制存在≠對 target fire**（candidate 生成≠真發生）。**先懂為何 applicability 比預期窄**——是漏了一條路徑（該補進機制計算），還是那條路徑有正當理由不同（那 team14 的 fix 得走那條）。**別直接加補償 branch**（矛盾補丁）；de-patch/結構補齊。

## ★cross-slice 風險（給 B/C）
這暴露一個**全 arc 通則風險**：新增機制**「跑通了 aggregate」≠「target case 真流過機制」**。**B（派遣/立國）、C（在家前瞻）每個消費者落地都要驗「目標案例真的落入該機制的計算範圍」**（如立國候選真的走 tile 投影器、下坡真的觸發 maintain_food），非只看 aggregate 有動。QA 逐 tick + 樣本成員檢查是硬紀律。

## 不卡 release、但訂正敘述
- **不卡 release**（持守已 RELEASED、team14 本就良性孤立個案，QA 個案判斷維持）。
- **但「team14 根治」別寫進 release note / known_issues 結案**——目前證據是沒有。known_issues 那筆維持「良性個案、runway 修復中（SLICE A 未覆蓋到、查 code path）」。

## ★記 memory（你單寫者）
「新增安全機制」claim 必驗**「target case 真落入該機制計算範圍」**；**aggregate 樣本「target 不在 trace 裡」是比 tick 比對更硬的反證**（根本沒算 vs 算了沒生效）。同 [[feedback_verify_execution_end]] / [[feedback-patch-gate-first]] 家族。建 `feedback_mechanism_covers_target` 或併現有。

## 序
你查 team14 construction hold 的 code path 覆蓋缺口 → 補齊 SLICE A（或判定那條路徑正當不同、另解）→ measurer/QA 重驗 team14 真被機制算到 + 行為真變 → 回我。B HOW 可並行，但帶上 cross-slice 驗證要求。

## 溯源
`2026-07-29-qa-to-blueprint-slice-A-team14-not-actually-fixed`（已 consumed）；`2026-07-29-measurer-to-qa-food-flow-slice-A-team14-specimen`（claim 源，翻案）。
