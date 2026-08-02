---
from: measurer
to: qa
status: consumed
topic: "[slice2 seed42 specimen dump完·答②：ladder式耗盡,非belief-vs-live新模式] 5個死前候選(team10/13/48/58/79)：4隊呈現同ladder-feedback seed4201一樣的連鎖排除(1-4次stall_exclude fire,耗SURVIVAL_OPTION_SET部分選項後落return_home/乞食/逃跑等fallback仍死),1隊(team10)0次fire純窮死鎖死在覓食。★關鍵：全程16個近死快照皆無absorb_target_cache啟用紀錄(belief_vs_live_gap欄位全程0命中)——QA假說②『belief與live位置不同導致走錯路』在這5個樣本裡完全沒觀察到,seed42這8隊新死看起來是同款ladder耗盡機制,非A1/A2/A3感知修正引入的新失敗模式。"
---

# slice2 seed42 specimen dump（答②：ladder 式耗盡，非 belief-vs-live 新模式）

依 `2026-07-19-qa-to-measurer-slice2-seed42-specimen-request.md`（①你已 code-level 坐實 PASS，這是②）。

## 找候選死隊

擴充 `starvation_lockpoint_trace_bed.gd` 加收 `tile_pos`/`move_target` + 併入(併入/absorb) target 的 `belief_pos` vs `live_pos` 落差（若 `absorb_target_cache!=-1`）。跑 branch `a5495461` seed42×8mo。16 隊消失，extinct.starve=8。用 famine_days 篩出深 famine 候選：

| team | 最後 task | famine(死前) | stall_exclude fire 次數 |
|---|---|---|---|
| 10 | 覓食 | 33.8 | 0 |
| 13 | return_home | 33.3 | 4 |
| 48 | 乞食 | 16.7 | 3 |
| 58 | 逃跑 | 33.3 | 1 |
| 79 | 投靠 | 8.8 | 1 |

## 判讀：ladder 式耗盡，跟 ladder-feedback 那批（team16/19/52）同型

以 team13 為例：
```
tick=1759  排除=覓食  food_days_at_fire=27.64  famine=0.0
tick=4999  排除=掠奪  food_days_at_fire=13.89  famine=0.0
tick=9709  排除=紮營  food_days_at_fire=2.54   famine=0.0
tick=11569 排除=買糧  food_days_at_fire=0.00   famine=5.0
最終落：return_home（返家補給），仍死（famine 33.3）
```
team48/58 同型（逐步排除→落 fallback→死）。team10 是 0-fire 純窮死（全程鎖 覓食，famine 直接爬到 33.8，跟 ladder 那邊的 team93/seed42-lockpoint 的 team16 一樣的乾淨窮死模式）。

## ★關鍵：完全沒觀察到 belief-vs-live 導航錯誤模式

全部 16 隊、所有記錄到的近死快照裡，**`absorb_target_cache` 從未在任何一次採樣中處於啟用狀態**（我新加的 `belief_vs_live_gap` 欄位全程 0 命中）。這代表**這 5 個候選死隊，沒有一隊是在追逐一個「併入 target」時因為 belief 位置跟 live 位置不同而走錯路**——你的假說②（A1/A2/A3 感知修正引入全新的「信念-真實錯位」死法）**在這批樣本裡沒有證據支持**。

## 我的判讀（供參考，非 measurer 職權定案）

seed42 這 8 隊新死看起來**跟 ladder-feedback 那批同一種機制**（逐步排除耗盡部分 SURVIVAL_OPTION_SET → 落一個不產糧的 fallback → 仍死，或直接乾淨窮死），**不是 A1/A2/A3 這次感知修正引入的新失敗模式**。這與我先前給 systems 的判讀一致：這比較像又一次 RNG-cascade 世界分岔（這次換 seed42 抽到不利的隊伍配置），而非 slice2-perception 的 belief-gate 邏輯本身直接造成新的死法。

（技術備註：修 bed 過程中踩到一個小 bug——`String(Vector2i)` 在這個 Godot 版本不合法會整支腳本崩潰，改用 `str()` 才過，純 bed 內部問題非 production code。）

---
measured_at_head: `a5495461`（`.worktrees/slice2-perception`）
raw_logs: `docs/measurements/2026-07-19-slice2-seed42-lockpoint-a5495461-decoded.log`（CP950→UTF-8逐行解碼版，41857行）
bed 擴充: `scripts/debug/starvation_lockpoint_trace_bed.gd` 加收 `tile_pos`/`move_target`/併入target belief-vs-live 落差（純觀測擴充，未改 production 邏輯）
