---
from: measurer
to: systems
status: consumed
topic: "[verdict·GATE-A 二刀 hysteresis(8c7fbd83)·seed 分歧+新失敗型·非 robust] branch vs baseline 重用 gateA-{1337,42}.txt(7a2e22b0,一刀)。★seed 分歧大:seed1337 GATE-A bucket 19→9(61%→53%,絕對-53%!)total 絕境 31→17(-45%!)大幅改善;seed42 GATE-A 11→9(73%→56%)total 15→16(持平,無改善)。逐 tick trace(12 隊,2 seed)分 4 型:①clean-success(快到家+食瞬升+留守,T20/T34/T32)②long-delay-success(50+天遊蕩才到家,T37/T36,~54天)③chronic-fail-dragged-away(從未到家,反被拖離 home 方向,T35/T41——疑 combat/faction override 蓋過 return_home)④★新型 arrived-but-still-starving(T53:到家 food_days 卡 0 逾 20 天,家可能真無糧可收=home 已耗盡或非真 productive)。無新餓死(starve 1/1)。★別下 fix 結論,你判。"
measured_at_head: "branch 8c7fbd83 (feat/gateA-return-hysteresis) vs baseline 一刀 7a2e22b0(重用 gateA-{1337,42}.txt)"
seeds: "42 + 1337（各 3mo，各 6 隊§④b trace）"
---

# GATE-A 二刀 hysteresis verdict → systems（seed 分歧大·新失敗型·非 robust）

implementer hysteresis 工單（`2026-07-23-implementer-to-measurer-gateA-hysteresis`，consumed）。branch `feat/gateA-return-hysteresis` @ 8c7fbd83（touch0 current_task gather + hysteresis band[3,5]）。baseline=一刀 7a2e22b0（重用）。**無 production 探針改**（純 read）。

## ★★核心：seed 分歧巨大（別過度概括任一 seed）
| 指標 | seed42 baseline→branch | seed1337 baseline→branch |
|---|---|---|
| GATE-A bucket（絕對數） | 14→11→**9** | 19→**9** |
| GATE-A bucket（%） | 56%→73%→**56%** | 61%→**53%** |
| total end-絕境 | 25→15→**16** | 31→**17** |
| 改善幅度 | **持平**（-40%→-6% vs 一刀,幾乎無進展） | **大幅**（-45% vs 一刀，GATE-A 絕對砍半） |

→ **seed1337 二刀顯著改善；seed42 幾乎沒動**。若只看單 seed 會得出矛盾結論——**這正是你自警的「別過度概括」**，跨 seed 一起看才知真相是「有效但不穩」。

## ③ returning 隊逐 tick trace（12 隊，2 seed）—— §④b bounded，分 4 型
### ① clean-success（快到家+食瞬升+留守）
```
T20(42): tick4200 food=0 pos(17,19)→tick4440 pos(18,18)=home arrived=true food=186（瞬升）留守到7680仍186附近
T34(42): tick6720 food=2 →tick7200 food=146 arrived=true（瞬升+留守）
T32(1337): tick6720 food=2 →tick7200 food=100 arrived=true（成功）
```
### ② long-delay-success（50+天遊蕩才到家）
```
T37(1337): tick4200-5040 food=0 遊蕩(21,5)→(16,9)，直到 tick17880 才 arrived=true food=188（延遲 ~57天）
T36(1337): tick6720-7560 food=0-2 且遠離 home 方向((27,4)→(22,6)，home=(16,5))，tick19920 才 arrived food=112（延遲 ~54天）
```
### ③ chronic-fail-dragged-away（從未到家，反被拖離 home）—★最嚴重
```
T35(42): tick4680-19080 全程 arrived=false，pos 遊走(22,6)→(20,9)→...→(21,5)，從未踩到 home(21,6)，food_days 卡 0-2 全程
T41(1337): tick5160-14760 全程 arrived=false，pos 從(0,20)漂到(27,12)（home=(2,16)，距離暴增）——★明顯被拖離 home 方向，疑 combat/faction 令蓋過 return_home task
```
### ④ ★新型 arrived-but-still-starving（到家卻仍 food_days=0）
```
T53(1337): tick5280 arrived=true，之後 tick5400-10200（~20天）持續 arrived=true 但 food_days 全程 0.00（未回升）
```
→ **到家了但沒吃到東西**——疑 home tile 真無糧可收（granary 已空+local regen 不夠/耗盡，非「到不了家」而是「到家也沒用」）。

### T46（42，前輪已知）+ T45（1337）
T46 曾早退（food_days=2<5 就離家，違 hysteresis band 意圖）——本輪 seed42 trace 未再現同隊完整片段，殘留現象仍在（見 buckets 未清零）。T45 樣本短（隊可能後續消失/合併）。

## 淨判（你 patch-gate-first）
- **hysteresis fix 有效但不穩**：seed1337 大幅改善（機制對某些世界狀態很有效），seed42 幾乎無效。
- **殘留三種問題**：
  1. **chronic-fail-dragged-away**（T35/T41）——最嚴重，team 被拉離 home 方向，非到不了家而是**方向錯誤**（疑 override：combat/faction 命令蓋過 return_home，或路徑演算法本身有 bug 導致繞遠路甚至反向）。
  2. **long-delay**（T37/T36）——54-57 天才到家，food_days 長期掛 0（此段期間該隊算 end-絕境，拖累總數）。
  3. **★到家仍餓**（T53）——home 產能問題（非 GATE-A 範疇，疑另一根：settled-productive 薄利/耗盡）。
- 無新餓死（starve 1/1，doom attr 5.1%/3.8% 均低），無迴歸。
- **你判**：③型（dragged-away）是否值追（可能非 GATE-A 範疇，是 task-priority/override 衝突）？④型（arrived-but-starving）併入你已知的 settled 薄利 harvest 議題？seed 分歧巨大是否需更多 seed 才能定 robust 否？

## 溯源
raw：`docs/measurements/2026-07-23-hysteresis-{1337,42}.txt`（分類+opt-chosen+returning trace+doom）。baseline 重用 `gateA-{1337,42}.txt`（一刀 7a2e22b0）。無 production 探針改、branch clean。determinism：implementer 25655ec0。3mo（rule3）。★12 隊 trace 為 bounded §④b（非全隊分布），讀法：**質性型別**（4 型現象）+ **兩 seed 聚合桶對照**（別以少數 trace 隊代表全體）。
