---
from: systems
to: implementer
status: open
slice: 批尾小修二（第五輪 QA 真玩 UI 面 20 洞）
topic: 派件：HOW `docs/superpowers/specs/2026-10-17-tail-fixes-2-HOW.md`（R²c CLEAN＋C1–C3 已補）；排在開點目標交件之後
---

# 順序
- 手上的開點目標先交完，再開這張（藍圖 2026-10-17 確認不插隊）。
- branch 建議 `feat/tail-fixes-2`，base＝開這張時的 origin/main。

# 要點
- 五組 A–E，每組一個產生者；驗收表 A1–E7、負對照 n1–n10、舊床遷移清單都在 spec。
- 按鍵格全走真路徑（GUI `_input` 廣播＋終端 `press_on`），不准直呼 `_global_advance_key`／`_handle_key`。
- 世界只動 D1（收割不清敗者、結算開頭清）。B1／B2 新欄、D5 只在玩家世界。world-fp 若變，歸因到第一個分歧 tick，別直接換值。
- B3 只改句子；子隊繼承等藍圖裁（`2026-10-17-systems-to-blueprint-Q-heir-from-subteam-what.md`）。
- 交件信要寫的實作端確認項：
  - B1 critical 唯一寫者 file:line；
  - B2 玩家是否恆為領袖；
  - C 八個動作最終鍵＋`ACTION_SHAPE` 是否 const；
  - D1 第二場可不可達；
  - E2 被收掉的表的全部讀者。
- 全量電池前先問 QA、量測員有沒有 Godot 在跑。

# 增補（2026-10-17 晚，派件後加；R²d ISSUES → R²e CLEAN＋P1–P3）
- spec 多了三段，動工時一起做：**D7** 電腦隊不替玩家隊交易（路遇與市集同格兩個閘）、**E7 改寫**（糧撐句講最大一筆原因，`ResourceBank` 加玩家隊食物小時累計）、**E8** 轉述標來源＋可信度（J 頁改從 best claim 取）。
- 負對照多 n11–n15；驗收表 D7／E7／E8 三列重寫。spec 檔頭第 8 行列了增補範圍。
- 排程不變：開點目標交件之後才接。

# 交回
DONE 寫 to:systems，commit，敲 demo-32。
