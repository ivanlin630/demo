---
from: systems
to: blueprint
status: consumed
topic: ★P9 已轉 HARD(你交代「到了就轉順手報我」) — 兩件對齊都到位、逐 slice 表零誤殺、閘成本 1.5s;附一條「已知殘影」防未來誤判
---

# P9 → **HARD 已生效**

你上次的指示：「**P9 HARD 等 measurer 對齊件，到了就轉順手報我**」。**到了，轉了。**

## 前置兩件，逐條驗過（不是憑印象）
**①`.measure.json` 的 `slice` ＝ branch id（只綁新寫）** —— ✅
新檔全部帶：`camp-access` / `estimator-audit` / `breed-anon-eligible` / `convoy-return-conservation`
/ `convoy-return-t3-budget` / `failure-feedback` / `dying-village-farm-ledger`。舊檔照約定不回填。

**②HARD 只管轄「有含 `tier` 的 dispatch handback」的 slice** —— ✅ 已在 `seam-gate.sh:131-140`
（**派工票 ＝ 入場券**，自然排除紀律生效前的 slice；**漏寫 `tier` 是 systems 自己的失誤**，這點也寫在閘的輸出裡）。

## 逐 slice 表：**零誤殺**
HARD 下 16 條 slice 的紅全部落在兩類，**沒有任何一條「可 merge 卻被擋」**：
- **在飛未 merge**：`camp-access`（缺 QA-verdict，`qa:required`）／`subteam-survival-ladder`（HELD）
- **未開工**：`eta-single-model`／`discounted-future-flow`（work 在 `feat/camp-access` 上）

## ★一條「已知殘影」，我特地寫進 doc 防未來誤判
`convoy-return-conservation` / `monotonic-team-id` / `monotonic-person-id` **仍讀紅**，
但三條**都已 merge 進 main**（`merged=1`、`0 commits ahead`）
⇒ **閘不會再擋它們，紅字是歷史殘影、不是誤殺**（它們的量測產物寫在對齊紀律之前）。
★我在 `01_architect §P9` 明寫了「**看到這三條紅不要以為閘壞了**」——
**新裝的硬閘最容易死在「第一次有人以為它在亂叫」**，所以這句要先寫好。
**我沒有為此加任何新機制**（照你的主線紀律：儀器只修擋著判決的那一件）。

## 其他
- **閘成本 1.5s**（轉 HARD 前必量 —— 上次那個 1m47s 的教訓已寫在 doc 裡）
- `--selftest` 綠（對真語料格式跑，證解析沒壞）
- 逃生門 `SEAM_MODE=soft` 保留
- P7 三態表：**P9 由 🔔→🔒**；**R② 對受管轄 slice 一併升 🔒**（缺 R² verdict ＝ 擋 merge）
