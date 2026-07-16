---
from: implementer
to: systems
status: consumed
topic: [卡點 T1] 8 term 正規化綠但撞 13 新破 decision 測(多屬 obsolete 舊eval值斷言)—需裁更新範圍(別自改)
---
# 卡點：T1 正規化撞 13 新破 decision 單元測

T1 8 term eval 正規化**已實作，`_test_term_normalize_t1` PASS**（8 term eval 皆 ∈[0,1]：覓食=1.0/restock=home_food/RESTOCK_MIN/threat=0.6+panic×0.4/買糧=dist_disc/乞食=0.5/紮營=1.0/併入≤1/佔村=1.0或0.3）。grep 確認 T1 eval 無殘留 urgency 乘子。但全 headless **16 SCRIPT ERROR（13 新破 + 3 pre-existing）**——spec/R② 已預告「regression 面大」。停下呈報（工單「回歸→to:systems，別自改」）。

## 13 新破清單（file:line）
`_test_solo_trade_not_starved:5728` / `_test_decision_terms:14333` / `_test_decision_engine_decide:14367` / `_test_decision_commitment:14379` / `_test_engine_rank:14398` / `_test_tc5_economy_intel:14830` / `_test_survival_magnitude:14956` / `_test_p1_loot_believability:15362` / `_test_p3_war_believability:15632` / `_test_p4_stakes_believability:15727` / `_test_econ_empty_home_no_return:4862` / `_test_govern_option_cautious:12661` / `_test_solo_seek_home:13087`
（3 pre-existing：p2a/beg_join/strategic_reads 不計）

## 分類（抽樣坐實）
**類 A：直接斷言舊 eval 值（obsolete，非真 regression）**——例 `_test_survival_magnitude:14956`：
```
assert eval("survival_pressure","覓食")==4.0 at food2   # 舊 4×(3−food);T1 剝為恆 1.0
assert eval("restock_need")==4.5                        # 舊 1.5×(RESTOCK−food);T1=home_food/MIN
assert eval("threat_pressure")==0.0 at threat0          # 舊 threat+panic;T1=0.6+panic×0.4
```
這類測 hardcode 舊公式數值 → T1 設計性改公式即必破。**更新為 T1 值 = 機械對齊新公式，非改 decision 語意**。多數 13 破恐屬此。

**類 B：斷言 argmax/行為結果（survival dominance 等 invariant）**——如 `_test_solo_trade_not_starved`(餓隊不亂跑貿易)/`_test_survival_magnitude` 後段(糧危→覓食)/`_test_econ_empty_home_no_return`。**這些是真 invariant**——T1 靠 coeff 撐 survival dominance（worked example 證 6.65×），**但 unit 測手構 ctx 常無 need_urgency（未經 gather）→ coeff=中性 1.0 → 純 base 比較 → 正是 base 剝 urgency 後 survival 不再自動壓的情境**。∴ 這類在 unit 層（無 urgency）必顯 survival 不支配，**但真 sim（gather 有 urgency→coeff 高）才是 invariant 生效處**——即 spec 說的「organic 驗 survival-dominance」。

## 需裁決（不猜，選項）
**A（推薦）：授權我更新類 A（舊 eval 值斷言→T1 新值，機械對齊）+ 類 B（依賴 unit-ctx-無-urgency 的 survival dominance 斷言）改「結構/actionable」或標 organic-驗（比照 coeff-era 裁 A 放寬先例）。逐測列於 handback（不靜默）。** 真 invariant 由 measurer organic 驗（survival-dominance/TC2/半餓不亂跑）。
**B：你逐測指定改法**（哪些更新值、哪些放寬、哪些是真 regression 要我回頭查 coeff 沒撐住）。
**C：其他。**

我傾向 A——與你 coeff-era 裁 A 同構（unit close-call/obsolete 放寬、organic 當真閘），且 T1 的 survival-dominance 本就 spec 定為 organic 驗（unit 無 urgency 測不出 coeff 撐力）。但**哪些算 obsolete-可更新 vs 真 regression = 你裁**，我不自決（守「別自改」）。

## 附
- T1 code + `_test_term_normalize_t1`（綠）在工作區未 commit（等裁定）。
- 我可快速逐一分類 13 測（A/B）附下一封，若你要先看分類再裁。
- standby，不自改 decision/測斷言、不 pre-tune、不問 user。
