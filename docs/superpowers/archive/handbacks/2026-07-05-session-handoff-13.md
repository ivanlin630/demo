# Session 交接（2026-07-05 #13，系統 session）

> 給重開後新 system session（`$env:SESSION_ROLE='systems'; claude`）。承 #12（`2026-07-05-session-handoff-12.md`）。
> 本 session = **憲法溶入 arc wave1 執行：序0(機械修+憲法閘)→閘硬掛→序1 threat→序2 solo 全 merged + 序3 rung spec/plan/spawn**。

## 你是誰
系統(Systems, HOW)。owner = invariants.md / 流程docs / progress.md / known_issues.md / CLAUDE.md / docs/process/* / auto-memory(單寫者)。開頭讀 `docs/process/00_roles.md` + auto-memory(hook 注入) + 掃 `handbacks/` 的 `to: systems / status: open`。不碰 game-design.md（藍圖 owner）。★交付前 QA 必綠。

## ⚠ 開頭必跑（baseline，**本 session 值變**）
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd       # DONE+seeded ★52/8/1/380(序2 後,見下漂移史)
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd # PASS=7 DORMANT=0
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd    # PASS sites=32（憲法閘,序0 立）
.\tools\godot.ps1 --headless --script scripts/debug/threat_dissolution_check.gd  # ALL PASS（序1 融合驗）
.\tools\godot.ps1 --headless --script scripts/debug/solo_dissolution_check.gd    # ALL PASS（序2 融合驗）
```
- **seeded 漂移史**：46/8/1/380(序0 前)→48/8/1/382(序1 threat)→**52/8/1/380(序2 solo,現)**。arc 各張允許漂移(QA wave 級判合理非退化)。
- **★憲法閘硬掛 pre-commit**（`.git/hooks/pre-commit`，本地 gitignore）：staged 含 `scripts/simulation/*.gd` 跑閘，新增引擎外 task 指派 FAIL 拒 commit。worktree 共用→實作 commit 也擋。arc 尾轉常駐全掃鏈撤 hook。
- 重型 bed 背景跑；`>` 重導向=UTF-16 用 Select-String；同機勿並行重 bed。

## 本 session 全 merged（時序）
1. **序0**（merged 3f2765f）：3 機械修（near/far hoist + 10 常數導 TimeScale + eta 除數，全零行為變）+ **憲法 site-freeze 防閘**（constitution_gate.gd + baseline，32 指紋，8 known 標序）。
2. **憲法閘提前硬掛**（藍圖 wave1-order-gate 裁）：pre-commit hook。
3. **序1 threat**（merged 804432e）：`_dispatch_threat_response` 手算 argmax→引擎 `rank_threat`；4 反應→REGISTRY option（FLEE=survival/備戰/迎戰/求和），term=**additive personality-dominant**（weight=1.0，非 multiplicative——threat_react unbounded 會爆量）；trigger/release scaffolding 保留。融合驗雙關綠。訊號叉藍圖裁=保 approach/power/hostility 三項。
4. **序2 solo**（merged f7ce320）：`_evaluate_solo` argmax→`rank_scored`+去 `_tag_weight` 硬鎖+**capability-grounded attack**（self_armed_ratio；無牙商隊 loot util 0.0=送死非被禁，憲法分辨線）。融合+反向驗綠。**★揭框架債**（見 known_issues + [[project_framework_seams]] 縫#3）：`_tag_weight` 隱形去衝突閘+「建設」恆 applicable→loop3 idle-gate 餓死，yield 橋補，真修序6。藍圖判：獨立 ambition-diplomacy 流失=吸收可接受、軍隊 22.5%=健康盯趨勢。

## 當前 in-flight
- **序3 rung_task**：spec+plan done、pushed（05b8903）、worktree `feat/wave1-rung` 建好、**實作 session 剛 spawn**（`.worktrees/wave1-rung`）。等實作回報 handback → 你獨立驗（融合驗+seeded 漂移+framework S3 scout 不 DORMANT+threat/solo 驗不破+閘）→ merge。
- 序3 要點：唯一真缺=訓練 option（FORCE 累積練兵）；TRADE/SETTLE mapping 冗餘（既有 option 覆蓋）；idle-filler 走引擎 rank；刪 rung_task 查表。

## arc 剩餘序（arc-order 定，融合非刪每張驗 repertoire+該出現）
```
序3 rung_task（in-flight）→ 序4 vendetta（feud_pull term 掛攻擊 option）
→ 序5 prosperity（gate cascade→option 競秤,中險,+gen 重校壓此後）
→ 序6 faction dispatch（_assign_tasks/_assign_member_tasks,高收斂動主幹,★框架債縫#3 真修在此:loop3 idle-gate/建設恆applicable）
→ 序7 ReactionSystem（最大最難,拆行為選擇 vs 情緒/離隊/生育後果保留）
→ 序8 灰項 dispatch → 全掃憲法閘 + 撤 pre-commit 轉常駐
```
平行：A2/60 tempo（gen 壓 wave2 後一次校）、空間骨架、QA 物流脫0驗。

## 開放 handback（to: systems）
- 無 open（seq2 兩判、tag-soft-ruling、threat-signal-ruling 全 consumed）。等序3 實作回報 + 藍圖對 seq2-solo-done 的後續（若有）。

## 融合非刪守則（arc 最高盯點，每張）
①repertoire 沒少（原本能做的還能做）②該出現還出現（率表證沒被新權衡默默吃，含反向如商隊≠劫匪）。seeded 漂移允許但 QA wave 級判合理非退化。溶=選項→option/考量→term，撕手算 argmax、保 trigger/release scaffolding（世界機制非決策）。

## 慣例
消費 handback→measure/spec→push(worktree base origin/main)→一行 spawn→收 handback→**獨立驗基準(不信聲明,碼證)**→merge→合體驗→docs(progress/invariants/known_issues)→memory(單寫者)→報藍圖→push→清 worktree(dir 殘留鎖=Windows Godot handle,無害)。憲法閘指紋變同 commit 更新 baseline（pre-commit 擋自己）。
