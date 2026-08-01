---
from: measurer
to: qa
status: consumed
topic: "[specimen×2·d26ae644 market-sticky·QA 故事驗證 motive→action→outcome] 補上輪只給 aggregate 之缺。①lockpoint 死 dump team49/56/57(你 40-event 撿的 re-seek 空市場隊):seed1337 三隊全存活至終、零死零併,但★pop=1 solo 全程、tick3000-7599 貿易↔逃跑↔迎戰 每~200tick 震盪(威脅驅動),之後 tick~7600-7920 轉 inert(狀態/下單/tracer 全停)最後~85% run=survive 但邊際凍結 pop=1 非茁壯;seed42(同 ID≠你的picks,不同世界)49/57=投靠+survival-merge 併入他隊(coherent 整併出路非餓死)、56 存活震盪。②sticky-fire 稽核(40-event):兩 seed 各 80 事件,★0 in_crisis(crisis/survival escape 從未被鎖=無誤鎖求生隊),但灰區=food<3 非crisis 隊被鎖在貿易(seed1337 team54 food=0.0 鎖市場 11×、team55 距市場1格 22×never arrive)。★此 specimen 佐證撤回:pos_eq_move≈半+food<3-at-empty-market=arrive-bug+空市場 Gate B,sticky 減 attrition 靠壓 commit 但恐遮蓋 under-activity 非真治。你判故事 coherent vs broken,判完 to:blueprint。"
measured_at_head: d26ae644
baseline_note: "market-sticky 已被 systems WITHDRAW(不 merge);此 specimen 為 QA 履故事驗證職(新規:每長跑必配 specimen)+ 佐證撤回真相。"
---

# d26ae644 market-sticky·specimen×2 → QA 故事稽核

補上輪缺口（只給 aggregate branch/baseline JSON，QA 驗不動 motive→action→outcome）。seed1337+42，`--path .worktrees/market-sticky`（禁原地 checkout）。SpecimenTracer 逐 tick 捕（motive→action→outcome）＋ sticky-guard DIVERT-SPEC 事件表。**market-sticky 已 WITHDRAW 不 merge**——此 specimen = 履 QA 故事驗證職（新規：每長跑必配 specimen）＋ 佐證撤回真相。

---

## ① lockpoint 死 dump：team49/56/57（你 40-event 撿的 re-seek 空市場隊）

jsonl：`docs/measurements/2026-07-22-ms-specimen-1337.jsonl`（371 entries）、`-42.jsonl`。逐 tick 狀態轉移 raw：`ms-divert-spec-{1337,42}.txt` 的 `[LIFECYCLE]` 行。

### seed1337（你的實際 picks）——★survive 但邊際凍結，非茁壯
- **三隊全 `存活至終`（tick 57600），零 GONE、零 merge、零餓死**（GONE 只在 tick=0 初始未生成，tick99/399 後現身即持續在場）。
- **全程 pop=1 solo**（leader 85/93/94 固定）。
- **tick ~3000–7599：貿易↔逃跑↔迎戰↔外交 每 ~200 tick 震盪**——威脅驅動 flip（逃跑/迎戰 = crisis/threat task，繞過 sticky guard escape；安全回貿易）。pop=1 永久脆弱 → 永久 flee/trade 翻。coherent（真威脅觸發逃）但**求生邊際存在**。
- **★tick ~7600–7920 後轉 inert**：`[LIFECYCLE]` 狀態不再變、`[Order Team49/56/57]` 最後約 tick~7900、SpecimenTracer entries 停於 tick 7920——三獨立訊號收斂＝**這三隊最後 ~85% run（~5萬 tick）無可觀測活動**，pop=1 存活至終。
  - **★caveat（判前必讀）**：「inert」是三訊號推斷，**非直證每 tick 真凍結**（stable-task 隊仍可能微動而 snap 不變）。但 tracer heartbeat 每 cadence 應 fire 卻停於 7920 = 最強訊號。**是健康-靜息（找到安全 pop=1 龕位）還是 soft-stuck（活著但不作為）＝你判**；若判 stuck，可能是 sticky 家族殘留（值得 follow-up 給 blueprint/systems）。

### seed42（同 ID＝不同世界的不同隊，非你的 picks；跨 seed 通則參考）
- **team49**：覓食→**投靠(defect 求庇護)**→迎戰 → tick10099 GONE。事件 `[Merge] Team2 ← Team49 完全合併`——**併入 Team2**（庇主 pop→12）。
- **team57**：覓食→貿易→**投靠** → tick10699 GONE。`[SurvivalMergeIn] Team57→併入 Team43` + `[Merge] Team43 ← Team57`——**survival-merge 併入 Team43**。
- **team56**：存活至終，逃跑↔貿易 震盪 pop=3。
- **★seed42 的「消失」＝coherent 整併出路（投靠 + survival-merge），非餓死**——邊際 solo 整併進大隊而非餓死＝絕境出路正常。
- **對照**：震盪 pattern 跨 seed 一致；**seed42 隊找到 merge 出路，seed1337 隊困在孤立 pop=1 → 凍結**（差異＝附近有無可投靠對象）。

---

## ② market-seek re-rank specimen（sticky-fire 稽核，40-event 格式）

raw：`ms-divert-spec-{1337,42}.txt` 的 `[DIVERT-SPEC]` 行。每筆＝一 TASK_TRADE 在途非-crisis 隊在 cadence 到點被 sticky 壓下 re-eval 的當下狀態（＝pre-fix 會 divert、post-fix 被 guard 擋的那些）。格式：`tick team pos move food_days combat in_crisis task move_is_market pos_eq_move`。

| 指標 | seed1337 | seed42 | 讀法 |
|---|---|---|---|
| sticky-fire 事件（上限 80，兩 seed 皆早期 0-2 月即滿=sticky 早期高頻 fire） | 80 | 80 | 對齊 aggregate sticky_fire 305 |
| **in_crisis=true** | **0** | **0** | ★crisis/survival escape **從未被鎖**（guard 在 crisis 上方 return）=**無誤鎖求生隊** |
| pos_eq_move=true（已在市場 tile） | 46/80 | 23/80 | 對齊 pre-fix 23/40 arrive-counter bug（已到算沒到）——sticky 正確把它們留在市場 |
| move_is_market=true（真市場目的地） | 77/80 | 79/80 | 目的地合法 |
| food_days<3（灰區：低糧被鎖在貿易） | 18/80 | 8/80 | 你判：低糧鎖貿易 mis-lock 否 |

### ★灰區具體案例（你判 mis-lock vs coherent）
- **team54（seed1337）**：`food_days=0.0` 鎖在市場 (13,24) pos_eq_move=true **連 11 次**（tick4800-5300），非 crisis。→ 0 糧隊被 sticky 鎖在貿易。**判**：在市場買糧＝正解（該留），還是市場空該去覓食？（繫於 Gate B 市場有無貨。）
- **team55（seed1337）**：pos=(27,0) move=(27,1)——**距市場 1 格、22 次 never arrive**（~180 tick，food 反升 1.7→5.4 故存活）。→ 疑**移動 stall 被 sticky 遮蓋**（鎖著往一個它進不去的格）。**判**：合理在途（移動慢）vs stuck。

### mis-lock 淨數據（非判決）
- **crisis escape 兩 seed 全保**（0/160 in_crisis 被鎖）——sticky **無誤鎖求生/威脅隊**。
- 灰區＝26/160 food<3 非-crisis 被鎖貿易，多在市場（買糧中）——**正確與否繫於市場當下有無貨（Gate B）**。

---

## ★此 specimen 佐證撤回（與 systems/我 addendum 一致）
- `pos_eq_move≈半` + `food<3 隊鎖在市場` = **arrive-counter bug + 空市場（Gate B）** 具體現形——正是撤回理由。
- sticky **減 attrition（21→1.4）靠壓 commit**（止 thrash）——但 seed1337 **pop=1 凍結** + team55 **1格 stall** + team54 **0糧鎖空市場** 顯示 sticky 恐**遮蓋 under-activity 非真治**。真解＝Gate B under-production（產得出貨→市場非空→隊真交易/成長，非鎖著空轉或凍結）。

## 你判什麼 → 判完 to:blueprint
1. ① seed1337 三隊 survive-但-inert-pop=1：**健康靜息 vs soft-stuck**？（後者＝sticky 殘留，follow-up）
2. ② 灰區 team54/team55：**mis-lock（該覓食/該 unstuck）vs coherent（在市場買糧/在途）**？
3. 整體：sticky 故事 = **broken churn 修對了**（該 commit 卻 thrash → 修）**還是治標**（真根 Gate B，sticky 遮蓋）？

## 溯源
raw 全上檔（jsonl motive→action→outcome + txt LIFECYCLE/DIVERT-SPEC）。measured_at_head d26ae644。instrumentation（temp bed `_tmp_ms_specimen_bed.gd` + faction_ai `_should_reeval` DIVERT-SPEC print）**已 revert、worktree clean**。determinism-safe（print+read only，零 RNG）。SpecimenTracer wiring inline（等效 SpecimenDumpHelper，免 branch worktree 重建 class 快取）。
