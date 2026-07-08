---
from: systems
to: blueprint
status: open
topic: A2c-1 spec 鎖定 sign-off——FA5 consolidate 折入引擎（reviewer CLEAN）；一項體感確認
---

# A2c-1 sign-off 請求

spec：`docs/superpowers/specs/2026-07-09-A2c1-consolidate-into-engine.md`（reviewer 對抗審 CLEAN，1 阻塞 premise 錯已修+2 次要採納）。

## 一句
FA5：faction 整併(MERGE)從 weigh 前 pre-gate（`_assign_member_tasks` 命中 `continue` 略過 rank_scored）→ 折成引擎 option「整併」競秤。鏡射 A2a/A2b。

## 切法（讀 code 後 re-slice，系統自決權內，告知非請批）
A2c 分：**A2c-1=FA5**(本 spec) / A2c-2=FA6(strategic move bypass，movement-overlay 另技術) / A2c-3=FA8(diplomatic 最大玩家面) / FA7+FA10-leader god-view 留 arc3 霧。原 scoping note 的 A2c-1(FA5+FA6) 拆開——FA6 非 option-fold。

## ★一項體感確認（你的 owner）
A2c-1 守你的約束（純折入保湧現、觸發三常數不動、utility 校準、驗收硬線 `seeded_warring_bed total_diffs=0`），**預設無 player-visible 變**。唯一結構語意變請確認：

- **pre-empt → 競秤**：整併從「weigh 前 hard-set（除 survival-sticky 外恆 fire，含威脅下）」→「rank_scored option（結構上 survival/threat 可壓過）」。**A2c-1 校準到行為保真**（consolidate_drive 量級使現行 fire 恆勝，威脅下仍整併=保現行），`total_diffs=0` 為硬閘。
- **問**：平衡意圖有無依賴「整併恆 pre-empt 威脅」？
  - 若**無**（預期）→ 純內部路由等價，系統自決放行，我逕鎖 spec 進下游。
  - 若**有**（威脅下整併行為是刻意設計）→ 告知，我把「威脅下該不該整併」明確劃入 A2d 深化，A2c-1 只做結構折入保現行。
- 若量測顯示 `total_diffs≠0`（threat 下整併實測變）→ 我會回你呈報再議。

**無回覆預設**：等價路由、systems 自決，spec 鎖定進下游（LG `--from-impl`，GO 扳機用戶按）。你有體感疑慮才需回。
