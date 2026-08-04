---
from: systems
to: implementer
status: consumed
topic: "[dispatch build Part2 (a)side-action(R²CLEAN+2追蹤,spec=2026-08-04-infonet-part2-side-action-HOW.md,blueprint裁(a),diagnostic確認argmax-loss root+distribute下游herald)·fix=求援/偵察脫主argmax→平行side-dispatch(de-patch同勞力池精神):1移除求援/偵察出options.gd REGISTRY主池(entry自成一體移除determinism-neutral主winner不變)2新tick step _step6b2_info_dispatch(sim_runner置faction_ai後,shape teams,LOD_BOTH)每team(非子隊)評herald(can_send_herald pop≥2+help_target_id!=-1+mini-util>0→_spawn_anon_herald既有empty-handed)/scout(領主+can_send_scout+scout_target_id!=-1+mini-util>0→spawn anon scout亦anon化)+throttle一隊一in-flight(task_reason=='help_call'/'info_scout'子隊在則不重派)3 mini-util=help_need_severity×人格_pmult(既有help_drive/scout_drive)×RELIEF_EXPECT−ANON_COST send if>0·★2追蹤硬守:①calibration錨真值(RELIEF_EXPECT錨食物活命價值·ANON_COST錨1anon真邊際產出/食耗,DERIVED非invent能fire常數,TEST VALUE標+rationale註,同idle-labor PER_HAND紀律)②scope硬限寫死herald/scout兩條(非做成可插拔/註冊式side-task框架=繞argmax後門)·守:主argmax零改determinism byte-identical(除herald spawn效果)/mini-util genuine人格MODULATE非crank/anon零特權守5界/零新randf/★全量tap(help.herald_dispatched·mini_util值·throttle命中)·branch續feat/info-network-whole·完HANDBACK to:systems我路measurer re-measure(herald_dispatched>0+distribute>0連動+人格分化+主argmax determinism,canonical harness)→QA"
branch: feat/info-network-whole
---

# dispatch build — Part2 (a) side-action（R² CLEAN + 2 追蹤）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-part2-side-action-HOW.md`（R² CLEAN）。**branch**：續 `feat/info-network-whole`。
**root（diagnostic 確認）**：求援輸 argmax rank 3/4（winner=返家補給、util 0.04-0.21）；**distribute 下游於 herald**（distress 達領主→distribute util 0.659 贏→連動）。

## 建什麼（de-patch：求援/偵察 脫主 argmax → 平行 side-dispatch）
1. **移除 求援/偵察 出 `options.gd REGISTRY` 主池**（entry 自成一體、移除 determinism-neutral、主 winner 不變）。
2. **新 tick step `_step6b2_info_dispatch`**（sim_runner steps、置 `faction_ai` 後、shape teams、LOD_BOTH）：每 team（非子隊）評
   - **herald（求援）**：`can_send_herald`（pop≥2）+ `help_target_id!=-1` + **mini-util>0** → `_spawn_anon_herald`（既有 empty-handed 1 anon）。
   - **scout（偵察）**：領主 + `can_send_scout` + `scout_target_id!=-1` + mini-util>0 → **spawn anon scout**（亦 anon-messenger 化、不再 named subteam）。
   - **throttle**：一隊一 in-flight（`task_reason=="help_call"`/`"info_scout"` 子隊在→不重派）。
3. **mini-util = `help_need_severity × 人格_pmult`（既有 help_drive/scout_drive）`× RELIEF_EXPECT − ANON_COST`**、send if >0（genuine cost-benefit：求助期望值 vs 1 anon 成本；人格在 _pmult）。

## ★2 R² 追蹤（build 硬守）
1. **calibration 錨真值**（同 idle-labor PER_HAND 紀律）：`RELIEF_EXPECT` 錨**食物活命價值**、`ANON_COST` 錨 **1 anon 真邊際產出/食耗**——**DERIVED 真值、禁 invent「能讓求援 fire」的常數**。TEST VALUE 標 + 錨定 rationale 註。
2. **scope 硬限寫死 herald/scout 兩條**——**非做成可插拔/註冊式 side-task 框架**（=繞 argmax 紀律的後門）。confirm 只此二 info-carrier 明列。

## 守（build 硬守）
- **★主 argmax 零改動**：移除求援/偵察後主決策 **determinism byte-identical**（除 herald spawn 的世界效果）；不動主秤公式。
- **mini-util genuine 非 crank**（[[feedback_genuine_value_not_crank]]）：真 cost-benefit、人格 MODULATE 非 boost。
- **anon 零特權守 5 界**（只送 simple distress、名冊 position-only）；`constitution_gate` 綠；**零新 randf**。
- **★全量 tap**（[[feedback_full_transient_observability]]）：`help.herald_dispatched`/`mini_util 值`/throttle 命中/anon scout dispatch——餵 measurer 驗 Part2 真活+人格分化。

## 驗收（re-measure whole、我路 measurer）
- **`help.herald_dispatched > 0`**（餓 resident 現平行派信使、不再輸 argmax）+ **`distribute.dispatch / food_delivered > 0`**（症1 真通、herald→distribute 連動）。
- **人格分化**（per-team mini-util dump：務實早求/傲撐）+ 主 argmax determinism byte-identical + Part1+3 不退 + economy 不爆 + 不凍雙 seed。

**完 → HANDBACK `to:systems` → 我路 measurer re-measure whole（canonical `WarringHarness.run()` 掛 specimen 中性、禁手寫 loop）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 對用戶驗收。** 卡 → 報 `to:systems`。
