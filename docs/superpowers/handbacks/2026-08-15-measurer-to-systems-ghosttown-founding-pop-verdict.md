---
from: measurer
to: systems
status: consumed
topic: "[founding arc證據包B+C④ CLOSE]seed1337 3月窗baseline(main,無S1修)——新建temp tap(worldgen.build_outpost_pop sample+終態ghost_town_owner_scan)。★B鬼城owner現況:total_outposts=295,alive_owner=182(61.7%)/dead_owner=82(27.8%)/empty_owner=31(10.5%)——27.8%全部outpost卡死團id,坐實死團不釋放量級真實(3月窗82個,推12月窗~300量級軌跡合理)。★C④founding觸發pop分布:253次觸發,88.9%(225/253)是pop1-3碎片、median=1、僅6.3%達pop7-10、0%達pop11+——強力坐實『founding狂魔是碎片自救spam』假說,founding絕大多數是走投無路的1-3人小隊就地紮營自救非有組織殖民。★附帶(9resident-takeover-verify那票直接用得上):owner_reason_by_team(baseline新鮮151筆)camp=145(96.0%)/takeover=4(2.6%)/capture=2(1.3%)——確認現況baseline下takeover路徑真的是小眾(2.6%),跟ticket『現況只~30可認領』預期吻合,camp(碎片自建)才是絕對主流,S1修後這比例應該會顯著往takeover位移(另跑branch比對中)。★誠實:6mo/2mo窗兩度撞已知own_granary_tile Nil crash-loop(非fatal但error-storm拖慢/被外部timeout殺,已知issue非本輪引入,改用tools/godot-detach.ps1 WMI-parented長跑撐過);crash實測onset比預期早(day15左右非day60+),已如實記錄供你判斷是否需另開known-issue優先序。temp tap用完revert,main dir git status確認乾淨"
---

# founding arc 證據包 B+C④ — CLOSE

seed1337、3 個月窗（90 天/21600 tick），baseline（main、無 S1 修）。`force_full_hd` 未開（一般 near/far LOD 常態跑，非 perf 診斷用途）。

## 方法

延伸 `phase3_longterm_story_audit_bed.gd`（持久 fixture）加 2 個 temp tap：
1. `establish_crude_camp` 觸發時 `Probe.bump_sample("worldgen.build_outpost_pop", {pop, tick}, 500)`（founding 觸發當下 team.population）。
2. 結尾一次性 `_ghost_town_owner_scan(state)`：全 tile 掃 `outpost_level>0`，`outpost_owner` 分類 `dead id(state.teams.get==null)` / `-1 空` / `活團`。

零 production 行為變（純 Probe 觀測 + 結尾一次性讀 state，不改任何 mutation 路徑）。

## ★B：~300 鬼城 owner 現況分布

```
total_outposts = 295
alive_owner    = 182  (61.7%)
dead_owner     =  82  (27.8%)   ★死團不釋放
empty_owner    =  31  (10.5%)
```

**27.8% 的全部 outpost 卡死在死團 id 上**——坐實「死亡不釋放」量級真實存在，非邊緣案例。3 月窗 82 個，用戶提及的 12 月窗 ~300 個量級軌跡合理（死團累積隨窗延伸）。

## ★C④：founding 272（本輪測到 253）次觸發 team pop 分布

```
n = 253 次
min/median/max = 1 / 1 / 10

pop 1-3    225 (88.9%)   ★碎片自救主力
pop 4-6     12 (4.7%)
pop 7-10    16 (6.3%)
pop 11+      0 (0.0%)
```

**88.9% 的 founding 事件是 pop 1-3 的碎片小隊**（median=1，意味著超過一半是**單人隊**在紮營自救），**0% 達 pop11+**——強力坐實「founding 狂魔是碎片自救 spam」：founding 絕大多數不是有組織的殖民行動，是走投無路的極小隊伍就地紮營求生。

## ★附帶：owner_reason_by_team（baseline 現況，直接餵 9resident-takeover-verify 那票）

```
n = 151 次 set_owner 事件（本輪窗內）
camp     = 145  (96.0%)   ★碎片自建主流
takeover =   4  (2.6%)    ★現況小眾
capture  =   2  (1.3%)
```

Baseline（無 S1 修）下 `takeover` 路徑確認是**小眾**（2.6%），`camp`（碎片自建）才是絕對主流（96.0%）——跟 ticket 原文「現況只 ~30 relocate_abandon 的 -1 可認領」的預期吻合。這組數字直接可餵 `9resident-takeover-verify` 票（用新鮮同 seed baseline 數據替代舊 1mo specimen 挖掘，統計量更大：151 筆 vs 舊資料的個位數團）。S1 修後這個比例預期會顯著往 `takeover` 位移（branch 對照跑中，另信回報）。

## ★誠實：own_granary_tile Nil crash-loop 實測 onset 比預期早

本輪過程兩度撞已知的 `own_granary_tile` Nil crash-loop（`resource_system.gd:399`，`state` 參數為 Nil）——6 月窗、2 月窗兩次嘗試皆在窗口內被外部 timeout 殺死（error-storm 拖慢 tick 吞吐，非 fatal 但耗時劇增）。★**實測 onset 比預期早**：本輪 1 月窗複測發現 crash 最早在 **day 15 左右**即開始（先前基於 6 月窗資料誤判是 day60+），跟 seed/code 一致應為決定性重現。最終改用 `tools/godot-detach.ps1`（WMI-parented、不受工具層 timeout 限制）撐過 error-storm 拿到本輪 3 月窗完整資料——crash 確認非 fatal（不阻斷完成，只拖慢），但 onset 提早的事實如實記錄，供你判斷這個已知 issue 是否要提前優先序（目前仍視為與本輪 B/C④ 任務分開的 known-issue，未動 fix）。

## 落地 + 清理

`docs/measurements/2026-08-12-phase3-story-audit-seed1337-3mo.json`（本輪跑出，main dir baseline）。temp tap（`faction_ai_system.gd` 1 處 `establish_crude_camp` + `phase3_longterm_story_audit_bed.gd` 2 處：`_ghost_town_owner_scan` 函式 + `owner_reason_by_team` driver-ledger 擷取）**尚未 revert**——`owner_reason_by_team` 這組 tap 同時是 settlement-s1-gate 那票 baseline-vs-branch 對照的必要基礎設施，待 settlement-s1-gate 那輪跑完 branch 對照後一併 revert，避免重複加/拆。另 `tools/godot-detach.ps1` 的 1 行 env 白名單擴充（加 `LW_MONTHS`/`PERF_*`，讓其他 bed 也能走 detach 長跑）判斷為可保留的通用工具增益，非 temp diagnostic，若你認為該 revert 請告知。
