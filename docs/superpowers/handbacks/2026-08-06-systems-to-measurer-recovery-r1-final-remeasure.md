---
from: systems
to: measurer
status: open
topic: "[最終重量 recovery-r1(arrived 三根全修、feat/recovery-r1 commit 5810f95c)·systems R² merge-gate CLEAN(亲验三根:①try_merge_back _TRANSIT_TASKS+=TASK_MIGRATE=你抓的 bed-root(migrant 生於 lord 格未出發即被吸回 vanish)、同 SETTLE 在途不吸回②空手 anon→survival preempt→配口糧 MIGRANT_RATION_DAYS=15 真扣 parent food 守恆 DERIVED 非 crank③fixture anchor·r1_test 改跑真全 advance_tick(300) pipeline=驗執行端修生效:dispatched=1+arrived=1+村 pop2→4 真升(非 hand-step)·9/9+headless 0-new+constitution 74+determinism byte-identical)·★你上兩輪測不出正是這三根(全 pipeline 才現)——你 no-player LOD 診斷+『只跑1次消失』線索直接導向 merge-back bed-root、關鍵貢獻·量(你 deb10640 bed+cluster_pos anchor):①★migrant.arrived>0(bed 真抵達、非只 unit)②plains 欠人村抵達併入→target pop 真升(村真回補=復甦 slice 真效果)③三態全譜補 forest 樣本(marginal−1.30 負→0 dispatched)④分化(plains 收 vs forest/mountain 不收、命運由地)·★禁靜態斷言 dump 真 arrived/pop-delta/per-target marginal·避 warring perf、落地 docs/measurements/·回 systems→QA→merge(R1 收官)·R2 投資/R3 遷村後續·地基 KEEP"
---

# 最終重量 recovery-r1（arrived 三根全修）

feat/recovery-r1 commit `5810f95c`。**systems R² merge-gate CLEAN**（亲验三根）：
1. `try_merge_back _TRANSIT_TASKS += TASK_MIGRATE` = **你抓的 bed-root**（migrant 生於 lord 格、未出發即被 merge_back 吸回=vanish）、同 SETTLE 在途不吸回。
2. 空手 anon → survival preempt → 配口糧 `MIGRANT_RATION_DAYS=15`（真扣 parent food、守恆、DERIVED 非 crank）。
3. fixture anchor（test-side）。
- **r1_test 改跑真全 `advance_tick(300)` pipeline = 驗執行端修生效**：dispatched=1 + **arrived=1** + 村 **pop 2→4 真升**（非 hand-step）。9/9 + headless 0-new + constitution 74 + determinism byte-identical。

★你上兩輪測不出正是這三根（**全 pipeline 才現**）——你 no-player LOD 診斷 + 「只跑 1 次消失」線索直接導向 merge-back bed-root=**關鍵貢獻**。

## 量（你 `deb10640` bed + cluster_pos anchor）
1. ★**`migrant.arrived>0`**（bed 真抵達、非只 unit）。
2. **plains 欠人村抵達併入 → target pop 真升**（村真回補=復甦 slice 真效果）。
3. **三態全譜補 forest 樣本**（marginal −1.30 負 → 0 dispatched）。
4. **分化**（plains 收 vs forest/mountain 不收、命運由地）。

## 守 / 序
- ★禁靜態斷言、dump 真 `arrived` / pop-delta / per-target `marginal`。
- 避 warring perf。落地 `docs/measurements/`。回 systems → QA → **merge（R1 收官）**。R2 投資 / R3 遷村後續。地基 KEEP。
