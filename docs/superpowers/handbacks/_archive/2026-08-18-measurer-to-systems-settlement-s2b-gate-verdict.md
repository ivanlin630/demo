---
from: measurer
to: systems
status: consumed
topic: "[settlement S2b bounded merge-gate 紅]branch feat/settlement-s2b(5b2c8980)vs baseline main,seed1337 peaceful_economy.json床(ticket指定的founding/peaceful非warring)。★流程:phase3_longterm_story_audit_bed.gd加LW_CONFIG env覆蓋(mirror既有LW_MONTHS慣例)支援切config,godot-detach.ps1同步補LW_CONFIG白名單(先前只加了LW_MONTHS一輪疏漏,首跑撞這個bug誤跑成warring config已診斷修正重跑)。①L0→L1端到端真fire=★紅——settlement.l0_to_l1_start全期(6mo+12mo皆同)僅fire 1次(team12,pop=1,tick=16000,720person-ticks目標),但construct.complete_crude_camp全程=0次:直接state掃描證實該corvee在6個月時ticks_left=710(僅10/720進度)、12個月時仍=710(6個月間零額外進度)——corvee啟動後立刻近乎完全卡死,並非工期不夠而是根本卡住不推進,一年內從未完工。②viability過濾湧現=誠實讀:一年12隊經濟床裡僅此1例嘗試corvee(settlement.camp_l0全程fire僅15-26次,多數團本就有既有outpost非L0碎片,樣本天生稀薄)——現有樣本量太小無法驗證『健康團成/瀕餓不啟』兩端分布,只能確認①的卡死案例本身是pop=1單人隊。③camp_level完工清淨無雙態=綠:l0_l1_dualstate_violations=0(6mo+12mo皆0,l0_camp_n穩定4/l1_outpost_n穩定11)。④busy-preempt壓境中斷=未測(peaceful_economy.json零threat零combat情境,此機制在此床結構性無法被exercise,誠實flag非green非red)。⑤determinism=綠:自建founding-bed專用determinism check(peaceful_economy.json config,20000tick涵蓋l0_to_l1_start事件點)3跑byte-identical=9a605311c8fbd69070db280506bf2878。⑥不破S1/S2a/47guard=綠(同③數字佐證+一年跑無崩潰無異常)。★裁決:核心gate①紅(唯一觀測到的corvee案例卡死不進、非implementer聲稱的『健康過濾湧現』),②因樣本天生稀薄無法驗證,④未測,建議退回implementer查pop=1單人團TASK_BUILD為何幾乎每tick被搶走(construct.stall遠大於construct.progress比例懸殊,21546:273於6mo)——懷疑非壓境威脅(peaceful config無威脅)而是其他決策路徑(如覓食/貿易/其他option)argmax持續贏過建設option、TASK_BUILD承諾不夠sticky讓solo小隊留在原task。"
---

# settlement S2b bounded merge-gate — 紅

branch `feat/settlement-s2b`（5b2c8980）。seed1337、`config/peaceful_economy.json`（ticket 明訂 founding/peaceful 床，非 warring——implementer 自報 warring 床 dormant，已遵照）。baseline=main（含 S2a）。

## ★流程備註：LW_CONFIG env 覆蓋 + detach 白名單補漏

`phase3_longterm_story_audit_bed.gd` 原本 config 寫死 `warring_states.json`；本輪加 `LW_CONFIG` env 覆蓋（mirror 既有 `LW_MONTHS` 慣例，default 不變=backward compat），並發現 `tools/godot-detach.ps1` 的 env 白名單先前只補了 `LW_MONTHS`（`settlement-s2a-gate` 那輪），漏了 `LW_CONFIG`——首次跑誤用了 default warring config（"49 teams, 8 factions"）而非我要的 peaceful（應為 "12 teams, 0 factions"），已診斷（比對 teams/factions 數字發現不符）並修正重跑。

## ①L0→L1 端到端真 fire — ★紅

```
settlement.l0_to_l1_start（全期，6mo 與 12mo 一致）=  1 次
construct.complete_crude_camp（全期）              =  0 次
```

僅有的 **一筆** corvee 啟動事件：`team12`（pop=1）於 `tick=16000` 在 tile `(11,7)` 開工，目標 720 person-ticks（`L0_TO_L1_CORVEE_DAYS=3` 天 × pop=1）。

★終態直接掃描（`construction_ticks_left`）：

```
6 個月時（tick 43200）:  ticks_left = 710   （僅推進 10/720，1.4%）
12 個月時（tick 86400）: ticks_left = 710   （6 個月間零額外進度！）
```

**這不是「工期不夠」，是「啟動後立刻近乎完全卡死」**——一整年內只推進了 10 個 tick 的工期，且第 6 個月到第 12 個月之間**完全零進展**。`construct.stall` 全期 21,546 次 vs `construct.progress` 全期僅 273 次（懸殊比例，且這 273 次含全部 12 隊、非只 team12 這一筆 crude_camp）——`_tick_construction` 每次檢查該 tile 時，`team12` 幾乎永遠不在 `TASK_BUILD` 狀態（tile 上找不到 `current_task==TASK_BUILD` 的隊 → `construct.stall`），代表 `TaskArbiter.transition(...TASK_BUILD...)` 執行後，team12 幾乎立刻被別的 argmax 結果或其他機制拉走，corvee 承諾（commitment）極不 sticky。

**這跟 implementer 聲稱的「L0→L1 端到端真 fire」不符**——唯一一次嘗試從未真正完工。

## ②viability 過濾湧現 — 誠實讀：樣本天生太稀薄，無法驗證

`settlement.camp_l0`（L0 建營觸發次數）全期僅 15（6mo）→26（12mo），這是 12 隊小型經濟床（多數團 t0 已有既有 outpost，非碎片流浪）——**一整年只有 1 個團嘗試 corvee**，樣本量太小無法驗證「健康團成 / 瀕餓不啟或工期中死」這組對照分布，只能確認①的卡死案例本身是 pop=1 單人隊（理論上工期最短、最該最快完工的案例，結果反而卡最死）。誠實回報：不是「查不到過濾湧現」的證據缺失，是這個 fixture 天生不適合驗這條 gate（founding 動態太少），若要驗②需要換一個 founding-heavy 的 fixture（如 warring_states.json 那種每 3 月窗 200+ 次 founding 事件的規模，但那個床 corvee 本身 dormant，兩者互斥）。

## ③camp_level 完工清淨無雙態 — 綠

```
l0_l1_dualstate_violations = 0（6mo 與 12mo 皆 0）
l0_camp_n = 4（穩定）  l1_outpost_n = 11（穩定）
```

零違反——雖然①沒有完工案例可驗證「完工時是否清淨」，但既有的 4 個 L0 + 11 個 L1 全程無雙態衝突，界線本身守住（跟 `settlement-s2a-gate` 那輪的驗證延續一致）。

## ④busy-preempt 工期中斷 — 未測（fixture 結構性無法 exercise）

`peaceful_economy.json` 零 threat、零 combat——這個機制（壓境威脅打斷 `TASK_BUILD`）在這個 fixture 裡結構性不可能被觸發。誠實 flag：非 green 非 red，是「這條 gate 在本次跑的床上無法測」。★但①觀察到的「幾乎每 tick 都不在 TASK_BUILD」現象，懷疑根因**不是**④設想的「壓境威脅打斷」（peaceful 床沒有威脅），可能是別的機制在搶——建議 implementer 用 `construct_stall_samples` 的 `ct_task`/`ct_reason` 欄追 team12 每次 stall 時實際在做什麼 task（本輪 8 筆 stall sample 因 cap 被其他 11 隊的 upgrade_facility stall 事件填滿，未捕捉到 team12 專屬樣本，需擴大 cap 或濾定 team 才追得到）。

## ⑤determinism（founding bed）— 綠

自建 `s2b_founding_fp_check.gd`（`peaceful_economy.json` config、20000 tick，涵蓋 `l0_to_l1_start` 事件點 tick=16000）：

```
run1/run2/run3 = 9a605311c8fbd69070db280506bf2878  （全同）
```

3 跑 byte-identical 確認——這是**獨立於 implementer 聲稱的 warring-bed fp（`6a51b8c3`）之外**的 founding-bed 專用 determinism 驗證，ticket 明確要求。

## ⑥不破 S1 reclaim / S2a L0 / 47 guard — 綠

`l0_l1_dualstate_scan` 數字（③已列）全程穩定、一年跑無崩潰無異常，佐證既有機制未受 S2b 破壞。

## ★裁決

**紅——建議退回 implementer。** 核心 gate①（L0→L1 端到端真 fire）在僅有的一筆真實案例裡未完工、且卡死 6 個月零進展，跟 spec 承諾的「健康團成」不符。②因 fixture 樣本天生稀薄無法驗證（非缺失證據，是這條 gate 需要換床）。④未測（fixture 結構性排除，非 red）。③⑤⑥綠。

**具體待查方向**（供 implementer 參考，非我裁定 root cause）：`construct.stall:construct.progress` 比例懸殊（21546:273），懷疑 `_evaluate_l0_settle` 設的 `TaskArbiter.transition(...TASK_BUILD, PRIO_DISPATCH)` 這個承諾不夠 sticky，讓其他 argmax 結果（可能是覓食/貿易/或別的 ambient option）持續搶走 solo 小隊的 task——非 peaceful 床原本設想的「壓境威脅打斷」（peaceful 床根本沒有威脅）。建議先查 `TASK_BUILD` 是否真的在 `PROGRESSIVE_HOLD_TASKS`（`task_arbiter.gd` 既有 `persist.hold` 機制）內、或這個 in-place corvee 的 commitment 強度夠不夠對抗一般 argmax 每 tick 重新競爭。

## 落地

- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-6mo-peaceful_economy.json`（main baseline + worktree branch，各一份）
- `docs/measurements/2026-08-12-phase3-story-audit-seed1337-12mo-peaceful_economy.json`（worktree branch）

temp diagnostic（worktree-only）：`_l0_l1_dualstate_scan` 擴充（含 `active_construction` 終態掃描）+ `construct.start`/`.stall`/`.timeout_cancel`/`settlement.l0_to_l1_start` 加入 `new_keys` allowlist + sample 欄位寫入 dump + `settlement.l0_to_l1_start` 加 `bump_sample`（原本只有 counter）+ `s2b_founding_fp_check.gd`（temp determinism script）。main dir 側只保留了 `LW_CONFIG` env 支援（永久，通用工具增益）+ `settlement.l0_to_l1_start`/`construct.complete_crude_camp`/`construct.complete` 三個 key 加入 allowlist（`settlement-s2b-gate` 前一輪 partial commit 已加，保留）；main dir 未加 `_l0_l1_dualstate_scan`/`construct.start`/`.stall`/`.timeout_cancel`（因主要用於本輪 worktree-only 診斷，main dir 沒有 camp_level 相關新行為需要這些欄位）。全部 worktree temp diagnostic 待此票收尾後 revert。
