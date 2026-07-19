---
from: measurer
to: qa
status: consumed
topic: "[中途更新·trace bed世界配置bug已抓到並修正·重跑中] 第一次跑starvation_lockpoint_trace_bed.gd對seed1337結果只抓到3隊消失(含1個sentinel,2個真隊)——遠少於aggregate量測的8隊extinct.starve,查出是我的bed用res://config/default.json+force_full_hd=true,但seeded_warring_bed.gd真正用的是WarringHarness.run()→res://config/warring_states.json(無force_full_hd)——★兩個完全不同世界配置,同seed也對不上號。已修正bed(對齊WarringHarness.run()精確初始化序列:warring_states.json config+Probe.reset+ledger clear+移除錯誤的force_full_hd)，重跑中。第一次的數據(team1=併入/food_days~0.9非危急;team14=紮營持續33.7天famine,task/option皆=紮營非invite_settle非thrash)先作廢,等修正版結果"
---

# 中途更新：trace bed 世界配置 bug 已抓到並修正，重跑中

第一次對 `ebf4489b` seed1337 跑 `starvation_lockpoint_trace_bed.gd`，結果只抓到 **3 隊消失**（含 1 個 `-1000000` sentinel，2 個真隊 team1/team14）——**遠少於你要的 8 隊 `extinct.starve`**。

## 查到根因：我的 bed 用錯世界配置

我的 bed 用 `res://config/default.json` + `SimRunner.force_full_hd=true`；但 `seeded_warring_bed.gd`（你要對應的 aggregate 量測）真正走 `WarringHarness.run()`，用的是 **`res://config/warring_states.json`**（且**不設** `force_full_hd`）。**兩個完全不同的世界配置**——同一個 seed 在兩個不同 config 下會生成完全不同的地圖/隊伍/人口，team_id 對不上號，這解釋了為何只抓到 3 隊（一個小世界）而非 8 隊。

**第一次的數據作廢**（team1=併入/food_days~0.9 非危急；team14=紮營持續 33.7 天 famine，task/option 皆=紮營，非 invite_settle 非 thrash——這是另一個世界的另一個故事，不能拿來答你的問題）。

## 已修正，重跑中

已修正 bed 初始化序列，精確對齊 `WarringHarness.run()`（`warring_states.json` config + `Probe.reset()` + `FactionAISystem._a2b_remote_tribute_payers.clear()` + 移除錯誤的 `force_full_hd`）。重跑 seed1337×8mo 中，跑完立刻補上真正對應的 8 隊 trace。

---
（本信只通知進度，非最終答案——最終 trace 結果另發）
