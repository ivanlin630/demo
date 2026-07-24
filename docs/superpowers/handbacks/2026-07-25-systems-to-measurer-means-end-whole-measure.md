---
from: systems
to: measurer
status: open
topic: "[measure·means-end whole 系統驗收(用戶原則②)·blueprint 判準 A1-A4 核心+B 下游+§④b specimen→QA·base=current main whole-done(S1-S7)·is_sim seed1337/42 長跑 6mo(means-end 發展長程 build 336+)·全量 specimen 餵 QA] means-end 全系統 WHOLE-DONE。blueprint 定 whole 驗收判準,派全量 specimen+數字→QA 故事稽核。base=current main(whole-done,無需 worktree);seed1337/42;★長跑 6mo(forest 據點+設施長程,3mo 看不到整鏈)。指標:★A1 means-end 鏈真被走(最核心 arc 動機):forest outpost 新建(定位型 build-closure fire)/material harvest 升/facility build via means-end(build_F candidate→建成)整鏈;★FAIL=material-short 隊卡平原 idle(material<need_keep 無 means-end 行動)數/比例。A2 多線平行:隊 active goal≥2+委派 candidate chosen+subteam dispatch 數。A3 人格差異化投資(折現):food_days 高隊 vs 低隊遠 forest/build candidate chosen 分化。A4 近零脫離:EXPAND/harvest/facility-build/deal vs race baseline(0/harvest 0.5-4.8%)升否。★B parked 消退:material afford(peak≥105 vs 0%)/coin liquidity/掛單噪音(arb_kill_nostock 月率 vs 42k-84k)消退否。★§④b bounded specimen(means-end active 隊 goal_state+frontier+chosen trace 逐 tick)→餵 QA(A1-A3+C 隊真走鏈非碰巧動,threat-oracle 血證)。★E watch(非 blocker,QA 記若扭曲核心故事):S3 unowned/S4 facility-type/S5 residency/S7 stale-satisfied。量測可溯源:原始落檔 docs/measurements/*+commit hash。→回 A1-A4+B 數字 to:blueprint(release-pass)+§④b specimen to:QA(故事稽核)。determinism 三跑 byte-identical(觀測禁耗 RNG)。"
branch: main (whole-done, S1-S7 merged)
---

# measure：means-end whole 系統驗收（blueprint 判準 A1-A4+B+§④b）

means-end 全系統 **WHOLE-DONE**。blueprint 定判準，派全量 specimen + 數字 → QA 故事稽核。

## 設定
- **base = current main**（whole-done code，無需 worktree）。**seed1337/42**；★**長跑 6mo**（forest 據點+設施長程，3mo 看不到整鏈）。
- 量測可溯源：原始落檔 `docs/measurements/*` + commit hash。

## 指標（blueprint A1-A4 核心 + B 下游）
- ★**A1 means-end 鏈真被走**（最核心，arc 動機）：forest outpost 新建（定位型 build-closure fire）/ material harvest 升 / facility build via means-end（build_F candidate→建成）整鏈。★**FAIL** = material-short 隊卡平原 idle（`material<need_keep` 無 means-end 行動）數/比例。
- **A2 多線平行**：隊 active goal≥2 + 委派 candidate chosen + subteam dispatch 數。
- **A3 人格差異化投資**（折現）：food_days 高隊 vs 低隊遠 forest/build candidate chosen 分化。
- **A4 近零脫離**：EXPAND/harvest/facility-build/deal vs race baseline（0 / harvest 0.5-4.8%）升否。
- ★**B parked 消退**：material afford（peak≥105 vs 0%）/ coin liquidity / 掛單噪音（arb_kill_nostock 月率 vs 42k-84k）消退否。

## §④b + E watch + 交付
- **§④b bounded specimen**（means-end active 隊 goal_state + frontier + chosen trace 逐 tick）→ 餵 QA（A1-A3+C 隊真走鏈非碰巧動）。
- **E watch**（非 blocker，QA 記若扭曲核心故事）：S3 unowned / S4 facility-type / S5 residency / S7 stale-satisfied。
- → A1-A4+B 數字 `to:blueprint`（release-pass）+ §④b specimen `to:QA`。determinism 三跑 byte-identical。
