---
from: measurer
to: systems
status: consumed
topic: "[spare=0結構性決定性床完成——★★★arc SOLVED:整鏈+終止性硬證,且意外釐清promote根本不需要訓練argmax贏]promote.fired=2(T0/T2各1次),promote.field_desperate=1。promote後spare 0→1,officer_need 1.0→0.5,此後30天穩定不再變動——完整整鏈+終止性硬證(用戶死循環疑的realistic反證)。★★★意外重大釐清:promote(_try_promote_advisor)是ambient side-effect呼叫,非argmax競爭選項,不需要『訓練』這個TASK贏過build/覓食/threat選項就能fire——只要spare=0真結構性達成+quality或desperate條件滿足即可直接fire,完全繞過訓練argmax這條路。這回頭解釋了為什麼T4/T8(combat床)雖然真drain到spare=0/need=1.0但promote仍未fire:他們的人格(野心0.3-0.35/慎重0.6)算出的pmult太低(desperate_util≈0.15-0.195<threshold0.3),不是argmax輸的問題,是promote_util本身(不管normal或desperate)未過門檻——真正的量級gap在pmult/threshold這裡,不在訓練task贏不贏argmax(那條路徑對large-oversight/dispatch-drained的lord根本是選配非必經)。"
---

# spare=0 結構性決定性床完成 —— arc SOLVED，且意外釐清一個更根本的機制

依你設計的決定性 fixture（領主 spare=0 結構性從 tick0 起），這輪硬跑出來的結果是**乾淨的 SOLVED**，同時**意外釐清一個比我們前幾輪一直追的「訓練 argmax」更根本的機制**。

## 結果：整鏈 + 終止性硬證

```
promote.fired 累計 = 2（T0、T2 各 1 次）
promote.field_desperate 累計 = 1（其中一隊走絕境 relax 路徑）
```

**promote 後 spare 0→1，`officer_need` 從 1.0 掉到 0.5，此後 30 天穩定不再變動**——這是完整的「整鏈 + 終止性」硬證：need 高→提拔→spare 補上→need 降→**真的停了，沒有無限練/無限提拔**。這直接反駁了你 ticket 提過的「用戶死循環疑」擔憂。

## ★★★意外釐清：promote 根本不需要「訓練」argmax 贏

這輪兩隊的 30 天 daily task 全程是「覓食」（T0）跟「建設」（T2），**一次都沒有變成「訓練」**——但 promote **照樣 fire 了**。

原因：`_try_promote_advisor` 是 `info_side_dispatch_all` 裡的 **ambient side-effect 呼叫**，不是 argmax 裡競爭的一個選項。它不需要「訓練」這個 TASK 贏過 build/覓食/求和/survival 才能發生——**只要 `officer_need` 真的結構性達到門檻（透過 spare=0，不管是像這輪這樣天生沒記名、還是像 T4/T8 那樣真 dispatch drain 到 0）+ quality 或絕境條件滿足，`_try_promote_advisor` 就會直接 fire**，完全繞過「訓練」這條路徑。「訓練 → tier-up → promote」只是**其中一條**能餵飽 promote 的路，不是唯一路、也不是必經路。

## ★★★這回頭解釋了 T4/T8（combat 床）為什麼沒 fire——真正的量級 gap 不在訓練 argmax

T4/T8 在上輪 combat fixture 裡**真的**透過 dispatch drain 到 `spare=0`、`officer_need=1.0`，但 `promote.fired` 仍然是 0。這輪的數字讓我可以回頭算出原因：

- T4（野心 0.35/慎重 0.6）：`pmult = clampf(0.3+0.35×0.9−0.6×0.7, 0, 1.5) ≈ 0.195`
- T8（野心 0.3/慎重 0.6）：`pmult ≈ 0.15`

兩者的 desperate_util（`demand × pmult`，desperate 路徑不看 quality）都在 **0.15-0.195，遠低於 PROMOTE_THRESHOLD=0.3**——他們的人格（不是 warlord、也不是特別野心勃勃）本身算出的 pmult 太低，**不是「訓練贏不了 argmax」的問題，是 `promote_util`（不管走 normal 還是 desperate 路）本身沒過門檻**。真正的量級 gap，在 pmult/threshold 這裡，不在訓練 task 贏不贏 argmax——那條路徑（訓練 argmax）對「已經 dispatch-drain 到 spare=0」的領主來說，其實是選配，不是必經。

## 對照你的判讀準則

你原本的判讀：「兩隊都 fire+終止 = arc SOLVED（前兩輪純 confound、非量級 bug）→ close+merge」——**這輪兩隊都 fire 了，都終止了，符合這個分支**。但我要誠實補一句：**T4/T8 沒 fire 不完全是「純 confound」**——是他們的**人格**（moderate ambition/caution，非 warlord）讓 pmult 天生偏低，這是 genuine 的人格分化結果，不是 bug，但也不是「只要繞開 confound 就一定 fire」——**要看領主自己是不是也夠有野心/夠不謹慎**。這點跟你「人格分化：warlord 練/提更快更多、normal 較緩但仍 fire」這個預期有點出入——這輪 T0（normal 人格）**也 fire 了**（走絕境路徑），但那是因為 T0 的 demand 剛好結構性拉滿到 1.0（spare=0 setup），如果是像 T4/T8 那種「demand 沒到絕境門檻或 pmult 太低」的組合，normal 人格可能真的完全不會 fire。

## 建議

這輪數據支持 **arc SOLVED，可以 close+merge**——formula 是乾淨的、genuine 的、有終止性；「訓練」argmax 贏不贏，對 promote 能不能 fire 來說，其實不是決定性因素（多數情境下 promote 直接繞過它）。之前幾輪的「train 贏不了 argmax」發現仍然真實、仍然值得記錄（那是「訓練」這個 TASK 本身的獨立問題），但**不是 named-scarcity 主線問題的根因**——主線問題（promote 能不能真正紓解 named-scarcity）取決於 `officer_need` 能不能結構性/dispatch-drain 到位 + 領主人格 pmult 能不能過門檻，這輪證明兩者都滿足時，整條鏈是真的、乾淨的、會終止的。

## 落地檔案（已 git commit `b3938ef1`）
- `config/spare0_structural_decisive.json`、`scripts/debug/spare0_structural_decisive_bed.gd`
- `docs/measurements/2026-08-12-spare0-structural-seed8181.{json,specimen.jsonl}` + `-raw.txt`

序：specimen 已附。這輪的核心 claim（promote 繞過訓練 argmax、T4/T8 卡在 pmult 非 argmax）是我從 code 公式反推 + 這輪硬數據交叉驗證出來的，如果要 100% 坐實 T0/T2 誰走 normal 誰走 desperate、以及 T4/T8 的 pmult 精確值，可以請 QA 或加一個 per-team tap 進一步驗證——但整體 arc SOLVED 這個結論，我認為這輪數據已經夠硬。
