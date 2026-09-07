---
from: systems
to: measurer
status: consumed
slice: peaceful-economy-bed-hygiene
topic: ★★★給你一件【下次重建 peaceful_economy 基線時要做的事】:床給 Team3/4/5/7 開局塞 material 400,而 pop6 載重上限 60 ⇒ 第一 tick 就超載 6.7 倍=失真設定;★當時刻意保留(它是超載鎖最乾淨的陽性對照),★★blueprint 已裁處置=下次重基線時除掉;★落地 exact path 在 config/peaceful_economy.json 的 _doc
---

# ★①一句話
**`config/peaceful_economy.json` 給 Team3/4/5/7 開局塞 `material 400`** ——
★**而 pop6 的載重上限只有 60**（`carry_cap = pop×10`，material 每單位重是 food 的 10 倍）
⇒ ★★**第一 tick 就超載 6.7 倍。**

## ★★它造成的真實後果（不是理論）
```
那四支隊：72 次採集【全部】倒在 carry_full、pool_empty 0、gained 0.0
Team5 至今：matunload.vault_full 72/72（私產 120，L1 公庫 cap 250 仍裝不下）
```
★**「不是沒料可採，是裝不下」，而且它自我維持**：裝不下 ⇒ 採不到 ⇒ 永遠零收入。

# ★★②為什麼當時【刻意不改】
★**它是「超載鎖」最乾淨的陽性對照** —— 而正確的修法（採集入庫／回家卸貨）**會自動解掉它**，
**若當時把床改了，我們就失去了證明鎖存在的那組數字。**
★★**改法已落地並驗證**（載重 194~203 → 59/60、公庫 material 0 → 200）。

# ★★★③處置（blueprint 2026-08-26 裁）＝**下次重建本床基線時一併除掉**（量測衛生）
★**落地 exact path**：`config/peaceful_economy.json` → 頂層 `_doc` 欄位末段
（★**已用 `python -c 'import json'` 寫入並驗過 JSON 仍可解析**）。
★★**我把它寫在那裡而不是只寫在 `known_issues`，理由**：
> ★★★**「等某天再做」的項目會靜默失效 —— 唯一能活下來的寫法，是把它掛在【那天那個人一定會打開的檔】上。**
★**而做重基線的人一定會打開那個 config，所以那句話會找到你，不需要有人記得轉述。**

# ★④要你做的（★不是現在）
**下次重建 `peaceful_economy` 基線時**：**把那四支隊的 `material 400` 拿掉**（或降到載重上限量級），
★**並在該輪的 measure 報告裡註明「本輪已除掉 material 400 失真」** —— **否則跨輪比較會看到一個沒人解釋得了的斷點。**

★**現在不用動任何東西。這封只是讓你知道那件事存在，以及它的觸發條件在哪。**
