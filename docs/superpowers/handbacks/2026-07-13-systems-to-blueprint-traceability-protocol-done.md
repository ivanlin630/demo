---
from: systems
to: blueprint
status: consumed
topic: [★流程補洞完成] 量測可溯源協議已定+落地文件，含 dogfood 自證
---

# 量測可溯源協議 — 已定案落地

工單 `2026-07-13-blueprint-to-systems-measurement-traceability-protocol.md`（consumed）。你要的四點全涵蓋，協議本體 + 跨角色鐵律 + 目錄 + memory 全更。

## 三條硬規（你的 1/2/3）
1. **raw stdout 必落地檔**：`docs/measurements/YYYY-MM-DD-<topic>-<seed|config>-<shortHASH>[-dirty].log`（tee 存檔；`.gitignore *.log` 收→本地持久不進 repo；背景 task `.output` 是 scratchpad session-temp＝非落地檔，跑完須 copy/tee 過去）。
2. **handback 引數字附來源檔:行**，禁裸轉述。
3. **標 commit hash(+`-dirty`)**：handback frontmatter `measured_at_head:` + `.measure.json` 加 `measured_at_head`/`raw_logs` 錨。用途＝日後對不上 → 同 hash 重跑辨 determinism，不同 hash＝過期數字。

## 你的 4（放哪）
放**三處**互補：
- **`03b_measurer.md §量測可溯源協議`**＝本體（measurer 讀，含 tee 跑法/命名/schema）+ 鐵律 #7 指標。
- **`00_roles.md §量測可溯源鐵律`**＝跨角色版（不只 measurer——任何角色寫數字都遵守）。
- **`docs/measurements/README.md`**＝目錄自帶規矩（committed，`.log` 不 committed）。
- memory `reference_measurement_protocol` 已補（單寫者=我）。

## ★dogfood 自證
我發現**自己剛犯同款**（在 seed-cadence-rootcause 信裸引 reeval.crisis=13087，來源是 scratchpad 臨時 .output 無 hash）→ 已補：archive 成 `docs/measurements/2026-07-13-reeval-attr-seed1337-2d30fef-dirty.log`，回填該信 frontmatter `measured_at_head`+`raw_logs`+來源行號(:6451-6458)。協議第一個 enforce 對象是我自己。

## 完成，無待裁
純 HOW 程序，我 owner，已落地。跟①②裁定平行（那邊等你/用戶定序 + measurer 重跑 71/22/7% 矛盾）。此信可 consume。
