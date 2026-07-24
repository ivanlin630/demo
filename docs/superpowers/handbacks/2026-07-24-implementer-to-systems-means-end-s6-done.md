---
from: implementer
to: systems
status: consumed
topic: "[done·means-end S6 折現·means-end arc 收官·must-fix① 折現後仍守·收+驗+S6 R²請] feat/means-end-s6-discount 2d89ca6c off local main f3f3580e(含 S5)。修:_candidate_util 加 delay-based discount(payoff×dev_coeff×discount(delay,人格 rate))+_mk_candidate 加 team 傳 delay。★護欄:折現乘法≤1 只變小→must-fix① 不破。TDD 8/8(★絕境遠趨零/★★must-fix① range regression 折現後仍守;RED discount 移除→3 FAIL)/headless 0-new/gate 74 removed=0/determinism d08b90a7。★means-end S1-S6 arc 收官。完成→收+驗+S6 R²→CLEAN merge。"
branch: feat/means-end-s6-discount
commit: 2d89ca6c
spec: docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md
---

# done：means-end S6 折現（★means-end arc 收官，請 systems 收+驗+R²）

HOW spec §10 S6+§7。遠慾望「看得遠」：投資型（延遲回本）candidate util 按 delay × 人格折現率折，絕境隊折趨零不走遠路 forest（WHAT §6）。

## 修（組件 F）
1. **`_candidate_util` 加 delay-based discount**：`util = payoff × dev_coeff × discount(delay, rate)` clamp `GOAL_UTIL_CAP`。
2. **delay 估**（淺啟發有界）：移動天數（`target hex dist ÷ MOVE_TILES_PER_DAY`）+ build/settle 工期（`BUILD_DAYS_EST`）。
3. **discount** = `1/(1+rate×delay_days)`（delay=0→1 近/即時不折，遞減有界）。
4. **★人格折現率 rate** = `DISCOUNT_BASE × (絕境因子 + 1 − 慎重)`（權重非 gate）：絕境 food→0→高（短視，遠 candidate 折趨零→**不走遠路 forest 輸眼前糧危**）/ 慎重高→低（遠視肯投遠利）/ 極慎重→趨 0（純遠視）。
5. **`_mk_candidate` 加 team 參數**傳 delay（6 call site 更新）。
6. **★護欄**：折現是**乘法**（discount ≤ 1）→ 只讓 util **更小**非更大 → `dev_coeff`（絕境→0）+ clamp `GOAL_UTIL_CAP` must-fix① 護欄不破；survival boost 破頂仍優先。

## 驗（皆綠）
- TDD `means_end_s6_test` **8/8**（①遠 candidate 折現 util 低於近 ②近/即時 discount≈1 ③人格折現率:慎重遠視 > 衝動短視
  ★④**絕境遠 candidate 趨零**（不走遠路，WHAT §6 效果硬驗）★★⑤**must-fix① range 斷言 regression**：折現後絕境 goal candidate util 仍 < survival-boosted static（clamp 不破，reviewer S6 指定回歸）⑥delay 估有界）。RED：discount 移除→①③④ FAIL（load-bearing）。
- headless **0-new**（3 baseline）。
- **gate PASS sites=74 removed=0**（折現純算術讀狀態，無 god-view/RNG）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `d08b90a7`（折現純算術禁 randf，tie-break；≠S5 digest=discount 真改決策）。

## ★★means-end 長程規劃 arc 收官
S1 骨架 → S2 資源型 → S3 定位型+閉環 → S4 設施發展 → S5 委派 → **S6 折現**。全鏈湧現：
**想要 F → 缺料 → 買/採@forest（絕境不走遠路=折現壓遠端）→ 建 outpost → 採 → 湊料 → 建 F（夠 pop 可委派子隊並行）**。
統一決策框架/DecisionEngine goal frontier 與 static option 同 rank 池 argmax 競爭；must-fix① 護欄保 survival 恆贏。

## ★whole-system-first / S7 followup（backlog，非本 arc）
- goal 生成 cadence 泛化（掛退 util-門檻）；perf optimize（S4 flagged:goal gen facility_deficit team-cadence 較慢）；
- facility-type 改建 / unowned 優選精修（S4/S5 flagged）；_try_dispatch_or_invite residency 8-12 浪費帶 de-patch（S5 flagged）。

## 完成判定 = systems + reviewer R²（★非自判）
請 systems 收 + 驗 + S6 R²（★reviewer 查 **must-fix① 折現後仍守**[乘法只變小] + 人格折現率語意[絕境短視/慎重遠視] + delay 估有界）→ CLEAN merge → **means-end arc 收官**（後續 S7 followup=backlog）。
base=local main f3f3580e（含 S5）。
