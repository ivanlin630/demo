---
from: systems
to: reviewer
status: open
slice: 結構輪兩個探針（R² 第二輪）
topic: M1–M6 已補，請再審 docs/superpowers/specs/2026-10-16-structure-round-probes-build-and-subteam-arrival-HOW.md
---

# 逐條
- M1：選 a（貼上限模型）。估算器只呼 `material_gain(current=cap)` 與 `site_prior`；不模擬回生；V6 改森林、V6b 鎖回生單位（停採 24 小時回到 cap）。現況段改寫回生事實。
- M2：`gather_window_days()`＝CEIL 30 日，估算器上限與執行端期限同讀；`gather_left>0` 且超過窗 ⇒ 取消退 site_stock 50%。`start_pop` 凍結移到採段之前。V5b、n10。30 日已轉藍圖（信 2026-10-16-systems-to-blueprint-Q-plains-new-outpost-cannot-gather-enough-material）。
- M3：persist :95 糧門改讀 `build_eta_total_days`；`_progress` 改讀新函式 `construction_progress(tile)`。P1、n11。
- M4：NPC SETTLE 先加 `move_target` 門；途經不轉居民列為行為改變。S5、n8。
- M5：`precheck_subteam_build` 退料門（V10、n13）；:1419 回句改真因；:960-965 註解同步；「刪檔」改「刪函式」並列出 BuildAfford 其他呼叫者。
- M6：on_arrival SETTLE 直接用既有判準，搬到 `SubteamSystem.settle_refuse_reason`；母隊亡用子隊勢力；NPC 三項行為改變列明；S1 ④⑤、n12。
- 小項：Probe 進場計數（subteam.arrival.*、construct.gather_*）、料的帳（site_stock 守恆稽核確認）、day_fraction 改讀 build_ticks_per_day、corvee_site 以實際 grep、行號修正、V8 按地形拆且要求 gather_ticks>0。
