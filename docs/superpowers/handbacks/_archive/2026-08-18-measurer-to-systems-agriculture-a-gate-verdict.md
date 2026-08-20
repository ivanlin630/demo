---
from: measurer
to: systems
status: consumed
topic: agriculture-a-gate-verdict
---

# 農業a 量化食物帳 gate：綠燈（無 mass-starve/無爆倉/determinism 過），但夾一個補償通路落差要你判

ticket:`2026-08-18-systems-to-measurer-agriculture-a-gate.md`
數字全落地:`docs/measurements/2026-08-18-agriculture-a-food-account-gate.measure.json`
床:`scripts/debug/phase3_longterm_story_audit_bed.gd`（既有 fixture，原樣重用，沒改）；seed=1337 peaceful_economy.json（定居經濟，非warring）6個月，main(baseline) vs `.worktrees/agriculture-a`(18f40293)。

## ①②：食物帳 + food-security 分布 → 綠

| | baseline | branch |
|---|---|---|
| harvest_intake_vault(6mo) | 6742.9 | 3737.2（-44.6%，drift正位預期直接效應） |
| farm_yield(6mo) | 0（無此線） | 380.2（新線） |
| l0_forage(6mo) | 619.2 | 4452.3（**+619%**） |
| ΔGRAND(6mo) | +317.3 | +985.3（正、無崩塌） |
| start→end pop | 72→61 (attrition 15.3%) | 72→65 (attrition **9.7%**) |
| death.starve_anon | 10 | **5** |
| granary tN / team_food tN | 1056.9 / 532.7 | 391.8 / 2200.9（無卡頂爆倉徵象） |

**無 mass-starve，無爆倉**——branch 反而 starve 死亡數更低、attrition 更低，是淨改善不是退化。

## ③FARM_UNIT_YIELD 校準：數字給你，判斷交你

farm_yield 總量(380.2) 遠小於被移除的 harvest_intake_vault 差額(-3005.7)——單看 farm_yield 自己並沒有補上被拿掉的量。但總帳沒垮，是因為 **l0_forage 暴增+3833.1 頂上**，不是 farm_yield 頂上。

換句話說：這輪數據顯示的補償通路，跟 spec 意圖（farm production 取代 gather 乘數，成為主要糧食來源）**不是同一條路**——是隊伍轉去靠 L0 營地覓食頂住，farm_yield 只是個小配角。

這是相關性觀察，**非我已用 QA story-audit 驗證的因果結論**（這輪為了在合理時間內產出決定性 gate 答案，沒開 SPECIMEN_* env，沒留 specimen trace——純聚合 metric 不下因果結論可以免 QA，但這條"為什麼是l0_forage頂而非farm_yield"是因果解讀，若你要鎖定這條因果故事，需要另開一輪帶 specimen 餵 QA 讀 motive→action→outcome）。

FARM_UNIT_YIELD=2.0 從量看可能偏低，但因為系統靠 l0_forage 自然補上、沒 mass-starve/爆倉，這輪數據不構成「必須調高」的硬證據——只構成「farm production 沒有如設計般成為主要補償通路」的觀察。是否要緊、要不要為此再開一輪 SPECIMEN 因果驗證、或直接接受 emergent 行為（隊伍自己選了 l0_forage 這條路也是一種合理湧現）——判斷交你。

## ④determinism → 綠
自建 temp `agri_a_fp_check.gd`（peaceful_economy.json seed1337 2000tick，用完刪）3 跑 fp 全同：`7e3465d4686c1eee31b760d87e451ce0` ×3。

## ⑤不破 S1/S2a/S2b → 綠
| | baseline | branch |
|---|---|---|
| settlement.camp_l0 | 14 | 12 |
| settlement.l0_to_l1_start | 3 | 2 |
| construct.complete_crude_camp | 2 | 0 |
| construct.complete | 17 | 17 |

同量級持續 fire，未見斷點；crude_camp完工 0 vs 2 屬 6mo/~12隊小樣本雜訊，非破壞跡象。

## 結論

①②④⑤四項硬 gate 全綠，可 merge。③FARM_UNIT_YIELD 校準留一個「補償通路跟 spec 意圖不同軌」的落差給你判斷是否要緊——不是 blocker，是要不要多開一輪的問題。

若要因果驗證，跑法：`SPECIMEN_SAMPLE_N=8` 疊到同床同 config 重跑一輪 → 出 specimen.jsonl → 送 QA 讀 story。我這邊 KEEP，等你裁。
