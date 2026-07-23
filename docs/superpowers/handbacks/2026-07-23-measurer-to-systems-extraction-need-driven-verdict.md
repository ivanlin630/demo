---
from: measurer
to: systems
status: consumed
topic: "[verdict·extraction de-patch need-driven·★機制本身確認生效但脫貧鏈端到端未閉合(跨seed一致)] branch 29c44ad9 vs baseline 重用 main f1d2a2b4(code-同,91% chronic coin_urg 已知)。★①機制生效:extraction fire率 66.0-66.3%兩seed一致(原 flat gate 幾乎不 fire,現中位人格真的取回 treasury coin),總取回 152-169 coin,無新餓死(starve1/1)。★②但脫貧鏈下游未閉合(跨seed一致方向):coin_urg chronic(>0.5)90-95% vs baseline 91%——統計上持平非改善;facility built Δ+2~+3 vs baseline Δ+4——同方向不升反降(雖小N可能雜訊但兩seed一致偏低非偏高)。★判讀:extraction 修對『能不能取回自己的錢』,但沒解『取回後能不能真的花出去變成 facility』——疑撞到我前幾輪已驗的其他閘(facility-build binding verdict:afford×1.5 門檻/faction 排隊限額每call僅1個outpost;material-afford-trace:reserve_factor 遠低1.05 material 側同樣被 urgency 壓;coin_need 只算 material-buy+food-buy 兩項未直接對齊 afford×1.5 的 material 缺口)。coin liquidity 通了但下游 material/facility 鏈的閘仍在,故'脫貧鏈端到端'未達成。別下 fix 結論,你判是否需疊加 material 側閘一起處理才會見效。"
measured_at_head: "branch 29c44ad9 (feat/extraction-need-driven) vs baseline main f1d2a2b4(code-同)"
seeds: "42 + 1337（各 3mo）"
---

# extraction de-patch need-driven verdict → systems（機制生效·脫貧鏈未閉合）

implementer 工單（`2026-07-23-implementer-to-measurer-extraction-need-driven`，consumed）。branch `feat/extraction-need-driven` @ 29c44ad9（砍 flat `greed>0.4` 死常數 → need-driven extraction，據我上輪 coin-mechanism-split verdict 的 salary_anon lockup 發現）。baseline = main f1d2a2b4（**scripts code-同**，直接重用我上輪 coin_urg 91% chronic 數字）。temp 探針（`faction_ai_system.gd` `_consider_extraction` 2 處 bump/add_amount）**已 revert、branch clean**。

## ★① 機制本身：確認生效（跨 seed 一致）
| 指標 | seed42 | seed1337 |
|---|---|---|
| extraction fire 率 | **66.3%**（67/101） | **66.0%**（70/106） |
| 總取回 amt | 152 | 169 |
| extinct.starve | 1 | 1 |
| doom attrition | 4.9% | 5.2% |

- **flat gate 砍除生效**：原本「貪婪-慎重×0.5>0.4」的死常數幾乎不 fire（我上輪 coin-split verdict 顯示 mil.extract_treasury=2、civ=33 整整 3 個月全族群合計，近乎零），**現在 66% 的 need-check 通過就真的取回自己的 treasury coin**。
- **無新餓死、無迴歸**——de-patch 本身乾淨、TDD 綠、determinism 25655ec0（implementer 報，2mo digest 同 hysteresis，行為變要長跑才顯，符合預期）。

## ★★② 但脫貧鏈下游未閉合（跨 seed 方向一致，非單 seed 雜訊）
| 指標 | baseline（重用） | branch seed42 | branch seed1337 |
|---|---|---|---|
| **coin_urg chronic(>0.5)** | **91%**（兩 seed 一致） | **95%**（58/61） | **90%**（65/72） |
| team.coin 總持有 | 555(seed42)/588(seed1337) | 762 | 802 |
| team.coin/隊平均 | 9.6/11.5 | 12.5 | 11.1 |
| **non-food facility Δ** | **+4**（兩 seed 一致） | **+2** | **+3** |
| trade.deal | — | 13 | 24 |

- **coin_urg chronic 率統計上持平**（90-95% vs baseline 91%，非清楚下降）——即便 extraction 真的把錢取回來、總持有量確實漲了（+37% seed42、+36% seed1337），**chronic 隊的比例沒有明顯改善**。
- **facility built 兩 seed 皆略低於 baseline**（+2/+3 vs +4）——雖 N 小可能雜訊，但**方向一致**（皆偏低非偏高），至少可確認**沒有觀察到脫貧鏈端到端跑通的訊號**（spec 期待 facility built 應該 up，實測未見）。

## ★判讀（供你 patch-gate-first）
extraction de-patch **修對「能不能取回自己的錢」**，但**沒解「取回後能不能真的花出去變成 facility」**。可能原因（連結我前幾輪 verdict，供你交叉核對）：
1. **`coin_need()` 只算 material-buy + food-buy 兩項**——沒有直接對齊 material afford×1.5 的缺口（我上輪 material-afford-trace verdict：`reserve_factor` 遠低於 1.05，material 側**同樣**被 urgency 壓縮，不是只有 coin 側缺）。coin 通了，material 側的閘沒動。
2. **facility-build binding verdict（本輪較早）**：faction 路徑每次 call 只有 1 個 outpost 過 early-return（排隊限額）、`dispatch_fail_afford` 是壓倒性失敗因——這條結構瓶頸**跟 coin liquidity 無關**，即使 coin 通了，排隊限額 + material afford 依然卡。
3. coin liquidity 通了只解「有沒有 spendable coin」，但**買到 material 還要過 material 側自己的 reserve_factor/afford 閘**——兩條閘互相獨立，單修一條不夠。

## 淨判
- **extraction 機制本身：正確、可 merge 的增量**（fire 率驗證、無迴歸）。
- **★但「脫貧鏈端到端」的 spec 目標未達成**（coin_urg 未降、facility built 未升，兩 seed 方向一致）——**需要與 material 側閘（afford×1.5 / 排隊限額）一起處理才可能見效**，單獨 coin 側修正不足。
- 你判：疊加 material 側 fix 再測，還是先 merge coin 側增量、material 側另開一條？

## 溯源
raw：`docs/measurements/2026-07-23-povertychain-{1337,42}.txt`（EXTRACT.* + coin_urg 分布 + facility Δ + doom）。baseline 重用 `docs/measurements/2026-07-23-coinurg-{1337,42}.txt` + `coinsplit-{1337,42}.txt`（main f1d2a2b4=branch merge-base code-同，diff --stat 零輸出已驗）。temp 探針（`faction_ai_system.gd` `_consider_extraction` 2 處）**已 revert、branch clean、grep 零殘留**。determinism-safe（bump/add_amount-only 零 RNG）。3mo（rule3）。
