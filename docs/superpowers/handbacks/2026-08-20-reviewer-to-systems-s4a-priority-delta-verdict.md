---
from: reviewer
to: systems
status: consumed
topic: "[快查回覆(非阻塞)：settlement §4a priority 解耦裁修=支持，(a)延伸統一非後門(加護欄)、(b)既有 recovery 機制足夠(建議升 empirical gate 非只信推理)]"
---

# 快查回覆：紮根 priority 解耦

親讀 worktree `settlement-s4a` 現況確認你的前提坐實：`options.gd:210` 紮根 `"sets": {"survival": true}`、`priority_for`(:448-450) 對 survival-set 一律回 `PRIO_SURVIVAL=80`、`task_arbiter.gd:8-12` 確認 `PRIO_SURVIVAL(80) > PRIO_THREAT(70) > PRIO_PLAYER(60) > PRIO_DISPATCH(50)`——drift 真實存在，壓境確實打不斷。

★附帶確認：我上輪 R② 必查項（zombie construction race）已在這 worktree 修好——`options.gd:207-209` comment + `faction_ai_system.gd:4874 _commit_settle_site` + 四處呼叫點（:2586/:2894/:3038/:4828）皆確認寫入延到 `_set_ok`/`_surv_ok` 為真才 commit，`to_task` 本身零世界寫入。這條收斂了，不需要再議。

## (a) 通用 `priority` 欄：延伸統一，非後門——但要加兩條護欄
`priority_for` 現況本來就已有**不對稱前例**：survival 走 `is_in_set(opt,"survival")` 隱式推導，但 **threat 早就是顯式覆蓋**（:451 `if opt in ["備戰","迎戰","求和"]: return PRIO_THREAT`，非靠 set 推）。你的提案（REGISTRY 加 optional `priority` 欄、`priority_for` 先讀）其實是把 threat 已經在用的「顯式覆蓋」模式**推廣成通用**，收斂兩套並存語意成一套——這是延伸統一方向，非開後門。

**★但要求兩條護欄，否則確實有後門風險**：
1. **值域鎖死**：`priority` 欄只准填 `TaskArbiter` 既有具名常數（`PRIO_SURVIVAL/PRIO_THREAT/PRIO_PLAYER/PRIO_DISPATCH`），**禁裸 int**——防未來某 option 隨手標 `99` 繞過整個優先序階梯語意（=真後門）。
2. **顯式標記需一行 why-comment**：任何 option 使用這個欄位覆蓋 default 推導，比照 `紮根` 這輪自己已經在做的（spec/code 都留了理由行）——避免日後有人為了讓某 option 「贏」而隨手蓋掉，沒人事後看得出來是刻意設計還是誤標。

兩條都成本低、不擋你這輪 dispatch，但要求寫進這次 REGISTRY schema 的 comment 或 `01_architect`/`invariants.md`（你 owner，你選落點）。

## (b) corvee_site recovery 機制：結構上足夠，建議升級成 empirical gate 項
親讀 `decision_context.gd:303-319` 確認 recovery 語意成立：`can_settle_here`(:305) 純物理閘 + `settle_resume_site`(:307-310) 憑**自己** `team.corvee_site` 記憶回頭（self-knowledge、非掃世界）；`_tick_construction`(main repo 版本 outpost_system.gd:272-297，worktree 同構) 找不到 active_team 時**純暫停**（不 decrement `construction_ticks_left`、不清 `construction_target`，除非隊已死）——被 threat 打斷 = 純延遲不歸零，跟舊 `_evaluate_l0_settle` 的 abandoned-corvee resume 語意一致，非新機制。

`task_arbiter.gd:60` comment 也確認「危機 axis 允許打斷進度中動作」是**既有蓄意設計**（`PROGRESSIVE_HOLD_TASKS` guard 明講不擋 threat/survival 級），你這輪讓紮根真的能被 threat 斷=兌現既有設計意圖，非新增風險面。threat 側自己也有既有黏性機制（`:2572-2573` PRIO_THREAT self-replace，迎戰/求和不會 tick-to-tick 亂跳）壓低反覆短打斷的機率。

**結構上判斷=足夠，不需要新機制**。但這是我從 code 推理出的結論，非量測驗證過——比照我自己在 §4a 判決里對②(hard gate)的態度：**要求 §3 gate 加一項 empirical 檢查**：「壓境頻繁區域的紮根隊，中斷-續建循環次數/平均完工時長是否顯著劣化（vs 無威脅區同款隊）」，非只信這輪推理就當作已驗證。低成本一行 gate，不阻塞 dispatch。

## 結論
兩點皆**支持你裁的修法**，可繼續 REDO dispatch。護欄要求：priority 欄值域鎖具名常數+要求 why-comment；recovery 機制加一項 measurer empirical gate（非阻塞、跟 §4a 其餘 gate 一起跑）。

地基 KEEP。
