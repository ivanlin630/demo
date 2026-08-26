---
from: systems
to: measurer
status: open
slice: perf-arc-slice0-baseline
topic: ★訂正:我給你的 slice 0 票裡「team_discovered production 讀者 48 處/13 檔」是【錯的】,正確是 55 處/15 檔;★★原票已就地改正並附上可重跑指令——但我另外寄這封,因為改檔案不會喚醒你的 Monitor;★不影響你的做法,只影響「分解該覆蓋多大範圍」的預期
---

# ★①訂正
```
★正確（未排除任何檔）：
grep -rno "team_discovered" scripts/simulation/ | wc -l   → 55
grep -rl  "team_discovered" scripts/simulation/ | wc -l   → 15
（含 scripts/data/world_state.gd 的定義處 → 60 / 16）
```
★**我原票寫的 48／13 是錯的**，**原票已就地改正**（`docs/superpowers/handbacks/2026-08-26-systems-to-measurer-perf-slice0-scaling-curve.md`）。

## ★我錯在哪，寫出來因為你可能也會踩
| | |
|---|---|
| ①**glob 不遞迴** | 我用 `scripts/simulation/*.gd` ⇒ ★**漏掉 `events/` 子目錄，而它不會報錯** |
| ★★②**查詢機械、聚合目測** | 我用眼睛加總 `grep -rc` 印出來那一欄 |
⇒ ★★★**「我用了 grep」不等於「這個數字是機械得到的」——錯誤發生在【聚合】那一步。**
★**防線：一條指令直接產出【那個數字本身】（`| wc -l`），不要跑完再自己加總輸出。**

# ★★②而我特地【另外寄一封】的理由
★**我改了原票的檔案，但改檔案不會喚醒你的 Monitor** —— **你可能已經讀過舊版了。**
★★**「落地 ≠ 通知」，今天我已經在這上面栽過一次。**

# ★③對你的影響（★很小）
**做法一行不用改。** 只影響一個預期：**熱點分解要覆蓋的讀者面比我原本說的大一點。**
★**而那不改變判準** —— **仍然是「每段要有分母＝該段每 tick 被走到幾次」，照原樣回報。**
★★**若分解不到那個粒度，那也是有效答案，別為了填滿它去挑數字。**
