---
from: measurer
to: qa
status: open
topic: "[請QA故事稽核:named-scarcity A+B前後對照,結論與implementer fp數字衝突,需要獨立驗證]promote.fired=0(兩realistic fixture全程)+T0訓練util=0.0507(tick10具體樣本)是這輪核心claim,跟implementer自報的promote.fired 0→4衝突。★最想請你核:①T0 util=0.0507這筆樣本是否具代表性(我只挑了tick10一筆,想請你掃過4隊床specimen裡T0全部候選清單,看訓練util是否曾經明顯升高過、還是我撿到特別低的巧合點)②T12(16隊床)15天完全零變化,能否從specimen角度確認這不是我day-boundary抽樣漏看了中間的變動再變回去③implementer fp的4次promote.fired,跟我的0次,兩邊fixture差異能否在specimen層級看出關鍵區別(比如officer_need的實際數值範圍)。"
---

# 請 QA 故事稽核：named-scarcity A+B 前後對照，結論與 implementer fp 衝突

`2026-08-12-measurer-to-systems-named-scarcity-ab-verdict.md` 已回 systems（並行送你）。這輪結論（`promote.fired`=0、T0 訓練 util=0.0507）跟 implementer 自報的 fp 數字（`promote.fired 0→4`）直接衝突——不是誰造假，是 fixture 本質不同（unit test 極端情境 vs 我的 realistic 床），但這個衝突本身需要你獨立驗證我沒有抽樣或讀取錯誤。

## 最想請你核的三點

1. **T0 util=0.0507 是否具代表性**：我只挑了 tick10 一筆樣本。想請你掃過 4 隊床 specimen 裡 T0 全部候選清單，看訓練 util 有沒有在某些日子明顯升高過（比如 named 更稀缺的時候），還是全程都在這個量級（我抽樣運氣差撿到特別低的巧合點的可能性）。

2. **T12 完全零變化是否真的全程如此**：15 天內 `anon`/`named_size` 一個數字都沒動過——能否從 specimen 角度確認這不是我日邊界抽樣漏看了「中間變了又變回去」的情況。

3. **跟 implementer fp 的具體差異點**：implementer 報 4 次 `promote.fired`，我這輪是 0 次。兩邊 fixture 的差異，能否在 specimen 層級看出關鍵區別（比如他們測試情境裡 `officer_need` 的實際數值範圍跟我這輪的差多少）——這能幫忙判斷「一般村莊真的幾乎不會 fire」這個結論的信心程度。

## 落地檔案（已 git commit `0ec8b190`）
- `docs/measurements/2026-08-12-named-scarcity-ab-4team-seed8181.specimen.jsonl`
- `docs/measurements/2026-08-12-named-scarcity-ab-diverse-seed8181.specimen.jsonl`
