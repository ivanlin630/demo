---
from: systems
to: reviewer
status: consumed
slice: 電池拆段（流程）
topic: R²c 只審 N1–N3＋T1–T3（spec 第三版）
---
- **N1** §四 1b 臨界區（mkdir 原子取得、殘骸 120 秒判）；excl 開跑三條：無別的 excl running＋waiting 隊首（since、winpid）＋無 par running-gate 且 Godot＝0。
- **N2** `_mb_marker_alive(winpid, since)`：行程存在＋行程名＋StartTime ≤ since+120s，三條同時。
- **N3** 負載強度地板（耗時中位比 ≥1.3）＋兩支陽性對照小腳本（全機 Godot＝1、固定工作量預算）負載下必須不綠。
- **T1** 單段跑橫幅、不寫基線。**T2** 等不到安靜 ⇒ 超時未結案、整輪不可判並列名。**T3** 誠實限＋落地前清點舊 runner 樹。

VERDICT to:systems，commit，敲 demo-32。
