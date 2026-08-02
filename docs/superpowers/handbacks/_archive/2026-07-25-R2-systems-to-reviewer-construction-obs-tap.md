---
from: systems
to: reviewer
status: consumed
topic: "[R²·construction pipeline 可觀測性補洞(A1 stall 一階定位)·純觀測非改行為·補全量暫態可觀測性不變量·spec=2026-07-25-construction-pipeline-observability-A1-stall-trace.md] A1 forest founding 仍 FAIL(outpost_built 兩 seed 0,dispatch 6080/1447 巨量但 completion 0)。systems code-trace 到極限反覆得『該 work』但 measure=0=construction pipeline 全無 Probe tap→違全量暫態可觀測性不變量→QA/systems 盲區猜一階。∴先補 pipeline permanent tap(不變量義務)→measurer 定位一階→一次修全部卡點(別 whack-a-mole)。★純觀測 slice:加 Probe.bump/tap 於 start_build/facility build 成功後(current_task_after 確認 transition 生效)+_tick_construction active_team==null stall(揭施工隊去向/task_reason=一階根)+_complete+timeout_cancel+_try_resume reject 原因分類。不修行為(latch/召回放寬待一階定後)。★reviewer focus(refute):(1)★觀測禁 RNG 全 tap 覆蓋否(第3次同族教訓 feedback_observer_no_global_rng,Probe 禁耗 randf/randi,三跑 byte-identical 硬驗)?(2)tap 純觀測不改行為否(無 side-effect 改 state/決策)?(3)tap 點夠定位一階否(start_build 後 current_task 實際值+stall 施工隊去向+召回 reject 分布)=能不能一輪坐實一階卡段?(4)因果鏈候選群(spec §已坐實:transition guard 攔#2/召回 remote is_owner 荒地=-1 失效#4)file:line 對否?CLEAN→dispatch implementer 加 tap→measurer 定位。有洞→回 to:systems。"
---

# R²：construction pipeline 可觀測性補洞（A1 stall 一階定位）

spec：`docs/superpowers/specs/2026-07-25-construction-pipeline-observability-A1-stall-trace.md`

## 背景（root）
A1 forest founding **仍 FAIL**：outpost_built 兩 seed 全程 0，dispatch 6080/1447 巨量但 completion 0。QA 定位卡「施工啟動後~完工前」（Team49 抵達✓+start_build✓，tick43200 仍不完工、跑去 trade/賣 material）。

systems code-trace 反覆得「該 work」但 measure=0 → **construction pipeline 全無 Probe tap** → 違全量暫態可觀測性不變量（憲法同級）→ 盲區猜一階。**先補可觀測性**（不變量義務）→ measurer 定位一階 → 一次修全部（whole-system-first）。

## 純觀測 slice（不修行為）
加 permanent `Probe` tap：start_build/facility build 成功後（`current_task_after` 確認 transition 生效）+ `_tick_construction` active_team==null stall（揭施工隊去向 + task_reason ＝一階根）+ `_complete` + `timeout_cancel` + `_try_resume_construction` reject 原因分類。**行為修（latch / 召回放寬 / tile 自倒數）待 tap 定一階後 systems 出修 spec**。

## code-trace 因果鏈候選（spec §已坐實，file:line）
- #2 **transition guard 攔**（task_arbiter.gd:116）→ current_task 留 TASK_CONSTRUCT → _tick_construction 認 TASK_BUILD 找不到（一階最強候選）。
- #4 **召回 remote 失效**（faction_ai:2742 `is_owner = t.team_id == tile.outpost_owner`，荒地 outpost_owner==-1 恆假）＝確定 code 缺，解釋既有 21/31 vs remote 0/N。

## ★reviewer focus（refute，異質模型）
1. ★**觀測禁 RNG 全 tap 覆蓋否**（第 3 次同族，`feedback_observer_no_global_rng`：Probe 禁耗 randf/randi，三跑 byte-identical 硬驗）？
2. tap **純觀測不改行為否**（無 side-effect 改 state/決策）？
3. tap 點**夠定位一階否**（一輪坐實：start_build 後 current_task 實際值 + stall 施工隊去向 + 召回 reject 分布）？
4. 因果鏈候選 file:line 對否？

**CLEAN → dispatch implementer 加 tap → measurer 定位一階。** 有洞 → 回 `to:systems`。
