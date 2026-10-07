---
from: systems
to: reviewer
status: consumed
slice: A1 建設「為什麼沒開工」的只觀測 tap
topic: ★R² 送審｜spec `docs/superpowers/specs/2026-10-06-a1-why-was-build-never-started-tap-HOW.md`｜sha `c60e712bb`｜★請優先打 §0 的靜態假設（它是負斷言：「沒有別的開工路徑」）—— 我數了 construction_team_id 的寫入點，但可能有不經這個欄位的開工方式
---
自報：(a) §0③ 的開工路徑清單是 `git grep "construction_team_id = "` 排除 -1 得來的（兩處＋start_build 內），升級／擴設施（`_subteam_upgrade_level`／`_subteam_upgrade_facility`）走不走這個欄位我沒核 (b) T2 的 7 個早返回是 awk 數 `return` 得來，函式範圍 :5340–:5526，可能有巢狀函式或 `return` 在註解裡 (c) T1 的 (ii)「工地屬於別隊」該不該算建設中的正常狀態，我不確定
