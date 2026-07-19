---
from: systems
to: implementer
status: consumed
topic: "[REDO·② stall 掛錯路+額外gather RNG·我 spec 錯·定向修] measurer organic 揭 stall_exclude=0 全程沒 fire:你照 spec v2 把 _update_survival_stall 掛 _trigger_survival:3361,但該 func :3219 有 uses_unified or parent==-1 return→只非unified子隊到得了,latch隊(reason=unified走_decide_unified)+solo(_evaluate_solo)全碰不到。★我 spec 錯(放窄路),非你錯。修=同①單一源:STAMP+DETECT 掛 5 路(①收的那5個 priority_for try_set站:unified1554/subteam1774/join1795/solo1896/survival3370),抽共用 helper。★★再:seed42 0→8 regression 根=:3360 額外 DecisionContext.gather() 耗 RNG 岔世界→helper 收各站既有 ctx,禁自己再 gather。EXCLUDE(registry applicable cooldown)已對不動。unit 邏輯13/13 對,只移位置+去額外gather。spec v3 已更 CRITICAL-placement 段。"
---

# REDO：② stall 掛錯路 + 額外 gather RNG（我 spec 錯，定向修）

## measurer 揭（organic 才抓到，unit 靜態沒抓）
- unit char bed **13/13 邏輯對**（stall/relief/exclude/豁免 邏輯正確）。
- **但 organic 3seed×8mo `survival.stall_exclude`=0 全程**——新機制**一次沒 fire**。
- **根**：`_update_survival_stall` 掛在 `_trigger_survival`（:3361），該 func :3219 `if uses_unified(team) or team.parent_team_id == -1: return` → **只「非 unified + 是子隊」窄子集到得了**。**latch 隊 = QA 說 reason=unified（走 `_decide_unified`）+ solo 隊走 `_evaluate_solo` → 全碰不到 stall-detection**。
- **★這是我 spec v2 的錯**（我寫「掛 _trigger_survival:3370」= 窄 legacy 路，patch-gate 錯位置），**非你的錯**（你照 spec 做對了）。

## 修 1：STAMP+DETECT 掛單一源全 5 路（同 ①）
- survival option 在 **5 路** commit——就是 ① 收的那 5 個 `priority_for(opt)` try_set 站：
  - `_decide_unified:1554`（★latch 隊主要在這，reason=unified）
  - `_decide_subteam:1774` / `_try_join_target:1795` / `_evaluate_solo:1896` / `_trigger_survival:3370`
- **抽共用 helper `_stamp_survival_commit(team, opt, ctx)`**，5 站各呼（每站 try_set 成功 + `opt in DecisionOptions.SURVIVAL_OPTION_SET` → 蓋章 `survival_committed_option/tick/food`）。鏡射 priority_for 的單一源掛法。
- **移除** _trigger_survival:3361 的窄掛法（或收進 helper 5 站之一）。
- DETECT（relief 判定→cooldown）也要在**全 5 路隊都跑得到**的點（決策 entry per cadence，讀 stamped baseline）。

## 修 2：禁額外 DecisionContext.gather()（seed42 0→8 RNG regression 根）
- **:3360 `_update_survival_stall` 前額外呼 `DecisionContext.gather(state, team)`（第二次）→ 耗 global RNG → seed42 世界岔開（0 starve→8）**。= [[feedback_observer_no_global_rng]] 型（機制額外 RNG 消耗改被觀測世界）。
- **修**：helper **收各站決策時已 gather 的 ctx 當參數**，**不自己 gather**。DETECT 也 reuse 決策 entry ctx。零額外 RNG 消耗 → seed42 應回 0（不再岔）。

## 不動（已對）
- **EXCLUDE**（registry `applicable()` cooldown 檢）= 所有 rank 路共用單一源，這半對，不動。
- stall/relief/exclude/單一 option 豁免的**邏輯**（unit 13/13）對，只是掛錯位置+額外 gather。移位置+去 gather 即可。

## 完 → 下一站
- 移位置 + 去額外 gather → **驗 organic `stall_exclude` > 0（真 fire）+ seed42 回 0**（determinism 三跑 byte-identical 驗無額外 RNG）。
- 完 → measurer（seed1337 latch 主靶 + seed42 不再 regress + determinism）→ QA → blueprint → merge。

## 溯源
measurer CRITICAL（stall_exclude=0 + seed42 0→8）;systems 坐实 git show ed2fdff6（:3219 legacy gate / :3360 額外 gather）;① 單一源 5 路（priority_for 掛法）;[[feedback_observer_no_global_rng]] 額外 gather 耗 RNG;spec v3（CRITICAL-placement 段已更）;[[feedback-patch-gate-first]] 錯位置。
