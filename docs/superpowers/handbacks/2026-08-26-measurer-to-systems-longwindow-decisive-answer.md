---
from: measurer
to: systems
status: consumed
slice: perf-arc-slice0-longwindow
topic: "決定性答案：週期性，不是一次性——387次hourly spike貫穿16天測試窗，369/387(95.3%)間距恰好=10tick=1小時；量級是舊已修hourly issue的100~1000倍；跑到tick3839/7200被砍但靠checkpoint機制保住全部387筆"
---

# ★★★答案：週期性，不是一次性

**每小時(每10 tick)都發生**，貫穿整個測試窗（tick=9 遊戲第0天 → tick=3839 遊戲第16天，387次連續無中斷）。

checkpoint 387筆記錄裡，**369筆(95.3%)間距恰好=10 tick**（`WorldState.TICKS_PER_HOUR=10`）。
不是隨機零星，是穩定的每小時 cadence。

⇒ ★★★**你票裡兩個假設的判定**：
| 答案 | 是否成立 |
|---|---|
| 純一次性 | ❌ 不成立 |
| **週期性** | ✅ **成立——每小時一次** |

---

# ★與 known_issues:910 對照——不是殘留，是新的

當年（2026-07-02）修過的 `faction_ai hourly spike` 被壓到 **50-70ms**。
本輪量到的 hourly spike：**中位數 6.8M us（6.8秒）、平均 9.2M us（9.2秒）**、範圍 1.7M~82.7M us（1.7~82.7秒）。
★**量級大 100~1000 倍** —— 這不是舊 issue 的殘留，是別的東西（你的預判被坐實）。

---

# ★統計摘要（387筆全量，checkpoint條件=dt>1s或tick%500==0，非抽樣）

| | |
|---|---|
| dt_us 中位數 | 6,817,496 |
| dt_us 平均 | 9,218,152 |
| 前10筆中位數（teams 101~112） | 10,670,154 |
| 後10筆中位數（teams 穩定202） | 8,488,361 |

★隊數從101翻倍到202，spike中位數**沒有等比例放大**（前10反而比後10高）——
跟你先前收下的「slice0曲線次線性」發現一致，**不支持『隊數越多spike越誇張』的簡單假說**。
只列數字，不強行解釋。

---

# ★未完成聲明

跑到 **tick=3839 / 7200（53.3%）** 被外部 `GODOT_TIMEOUT=3600s` 砍掉，**沒跑完**。
★**靠 checkpoint 機制（spike當下即時flush落地）保住了全部387筆**——這是這輪的核心突破：
前兩次（30分鐘、1小時）長跑被砍掉時輸出全部歸零，這次改成「每次spike發生就當場寫檔+flush」，
就算被砍也已經有東西在磁碟上。

★**後半段（tick3840~7200，約第16~30天）完全沒量到**——若那段行為系統性不同（例如隊數再漲、
spike再變大/變小），本輪答不出來。387筆已經是決定性樣本（16天、387次連續無中斷），
但要不要追完剩下14天，我不自己決定，你裁。

---

# 落地
`docs/process/verdicts/perf-arc-slice0-longwindow.measure.json`
raw: `docs/measurements/perf-longwindow-current-1month.txt.checkpoint.perf_scale.txt`（387行）
床改動：`scripts/debug/perf_scaling_curve_bed.gd` 加 checkpoint flush-on-spike 機制
