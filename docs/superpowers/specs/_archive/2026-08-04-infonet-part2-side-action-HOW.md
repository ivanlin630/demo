# 資訊網 Part2 (a) side-action — HOW spec

**from**: systems | **status**: FINALIZED → reviewer R²（blueprint 裁 (a)、diagnostic 確認） | **branch**: `feat/info-network-whole`（續）
**root（diagnostic 確認 `2026-08-04-part2-argmax-loss-diagnostic.json`）**：求援 applicable 但**每 food 級輸 argmax rank 3/4**、winner=**返家補給**（home-based resident 回家補給）、求援 util 0.04-0.21。**⑥distribute 下游於 herald 確認**：distress 塞領主 team_known → distribute candidate util 0.659（贏）→ **herald 通了 distribute 自動連動**。
**WHAT 裁**：blueprint (a)——求援=派 1 anon 跑腿=**平行 side-action**、逼進單 task argmax=category error（派信使≠放棄自救、村莊邊覓食邊派人求救）。

## 修（(a) 求援/偵察 脫離主 argmax → 平行 side-dispatch；同勞力池/mfg de-patch 精神）
### 1. 主 argmax 零改動＝移除 求援/偵察 出 REGISTRY 主池
- `options.gd REGISTRY` **移除 `"求援"`/`"偵察"` entry**（不再進 `rank_scored` 主秤競爭）。→ 主決策（覓食/返家補給/…）**winner 不變**（移除本就 rank 3/4 的 loser 對 argmax 中性、determinism-neutral）。help/scout util terms（terms.gd help_drive/scout_drive）移到 side-dispatch 用。

### 2. 新 side-dispatch pass（獨立於主任務、平行）
- **新 tick step `_step6b2_info_dispatch`**（sim_runner steps、置 `faction_ai` 後；shape teams、LOD_BOTH）——**精神同勞力池/convoy 平行步**（body 做主業、小差遣平行）。
- **每 team（非子隊）評 herald/scout side-dispatch**：
  - **herald（求援）**：`can_send_herald`（pop≥2）+ `help_target_id!=-1`（名冊/belief 解析）+ **mini-util > 0** → spawn anon herald（reuse `_spawn_anon_herald`、empty-handed 1 anon、既有）。
  - **scout（偵察）**：領主 + `can_send_scout` + `scout_target_id!=-1` + mini-util>0 → spawn anon scout（同 anon-messenger 化、不再 named subteam）。
  - **throttle**：一隊一 in-flight herald（+ 一 scout）——已有 in-flight（`task_reason=="help_call"`/`"info_scout"` 子隊）不重派（鏡射 convoy 一隊一 throttle）。

### 3. mini-util（★人格加權自身成本效益、非 scripted trigger、非死常數）
- **`herald_mini_util = help_need_severity × _pmult(人格：求生欲/野心 HELP_PRIDE_SUPPRESS/義氣) × RELIEF_EXPECT − ANON_COST`**。
  - `RELIEF_EXPECT` = 求助期望紓困值（餓→得糧=活命、高）；`ANON_COST` = 1 anon 邊際機會成本（小）。**send if mini-util > 0**＝genuine cost-benefit（1 anon 成本 vs 求助期望值）。
  - **人格在 _pmult**（務實 severity 響應高→早求；傲 HELP_PRIDE_SUPPRESS→撐；義氣）。**非 runway<X 死常數觸發**。
- **★calibration-anchor（R² 追蹤、同 idle-labor PER_HAND 紀律）**：`RELIEF_EXPECT`/`ANON_COST` **DERIVED 真值**（RELIEF_EXPECT 錨真食物活命價值、ANON_COST 錨 1 anon 真 pop 邊際產出/食耗）、**禁 invent「能讓求援 fire」的常數**（=crank）。TEST VALUE 標 + 錨定 rationale。

## 守（reviewer R²）
- **★主 argmax 零改動**：移除 求援/偵察 出 REGISTRY→主決策 winner 不變（determinism byte-identical 該綠、除新 herald spawn 的世界效果）。confirm 移除 loser 對 argmax 中性。
- **genuine 非 crank**：mini-util=真 cost-benefit（求助期望值 vs anon 成本）、人格 MODULATE（_pmult）非 arbitrary boost。**per-team mini-util dump 驗**（務實早求/傲撐分化）。calibration 錨真值（上）。
- **scope 硬限 = 1-anon 資訊跑腿 only**（herald/scout）——**不開通用平行任務機制繞 argmax 紀律**。confirm 只此二 info-carrier、非泛化 side-task 框架。
- **感知鐵律**：anon carrier 零特權（只送 simple distress、名冊 target_pos position-only）；物理走+delay；`constitution_gate` 綠。
- **determinism 零新 randf**（mini-util 算術；spawn 確定性；throttle 讀既有 task_reason）。
- **無框內平行求解器**：這是 **de-patch 型**（求援/偵察 從「假裝是主 argmax option」→ 還原成真實的平行 side-action）、非增殖——同勞力池把 facility 從 current_task 脫鉤前例。

## 驗收（re-measure whole、我路 measurer）
- **`help.herald_dispatched > 0`**（餓 resident 現能平行派信使、不再輸 argmax）。
- **`distribute.dispatch / food_delivered > 0`**（症1 真通：distress 達領主→distribute fire[util 0.659 已證]→convoy 送糧）。
- **人格分化**（per-team mini-util dump：務實早求/傲撐）。
- **主 argmax 決策 determinism**（移除 loser 後主決策 byte-identical、除 herald 世界效果）+ Part1+3 不退 + economy 不爆（信使空手）+ 不凍雙 seed。

**路 reviewer R²（審 主argmax零改/mini-util genuine非crank+calibration錨/scope硬限1-anon/de-patch非增殖/感知鐵律）→ CLEAN → build（續 `feat/info-network-whole`）→ re-measure whole（canonical harness）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 對用戶驗收。**
