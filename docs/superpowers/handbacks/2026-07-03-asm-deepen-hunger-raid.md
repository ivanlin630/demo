# Hand Back: ③ asm 做深 + ②b 飢餓搶糧 readiness + ②c prey 濾改分

> Spec `docs/superpowers/specs/2026-07-03-asm-deepen-hunger-raid-design.md`
> Plan `docs/superpowers/plans/2026-07-03-asm-deepen-hunger-raid.md`
> Branch `feat/asm-deepen-hunger-raid`
> Status: consumed（2026-07-03 merged,值旋鈕升藍圖）

## 實作摘要

- `scripts/data/team_data.gd`：+`captive_guard_ratio: float`（看守強度，ManpowerSystem 每日寫）。
- `scripts/simulation/faction_ai_system.gd`：
  - 常數 `ATTACK_SCORE_THRESHOLD` 0.30→0.25、`HUNGER_SLIDE_DAYS=7.0`、`RELIEF_FLOOR=0.4`、`PREY_POP_TIE_EPS=0.5`（全 TEST VALUE）。
  - `_evaluate_prosperity_attack`：readiness gate 改 `threshold_eff = threshold × hunger_relief`（②b，僅 prosperity 路）。
  - `_find_weakest_prey`：刪 `food_est<20` 硬濾（②c），改弱點主排序 + 同弱者 food_est 高者輕 tie-break。
- `scripts/simulation/manpower_system.gd`（③）：
  - 厚待真掏糧（`CAPTIVE_FOOD_RATE=0.5`，`ResourceBank.remove(...,"captive_feed")`），`feed_quality=實撥/需求` 驅 morale delta；`feed_quality<FEED_FAIL_Q=0.3` → 厚待失效（=虐待）。
  - `decide_treatment` 回 `{treatment, guard_ratio}`；新 `_decide_guard_ratio`（慎重×0.3+load×0.3，cap 0.5）。
  - `_flee_opportunity`→`_flee_probability`（連續：`captive/(guard_n+1)×(1-morale)×FLEE_COEF`，cap `P_FLEE_MAX=0.5`；刪 `readiness<0.4` 恆真項）。
  - `_enforce_guard_cap`：`captive_cap=guard_n×GUARD_CAP_MULT(3)`，超限 means-end 強制處置（殘忍→苛用部分戰損 / 否則釋放），走既有 detach/breakaway 守恆路由。
  - `treatment_history` 記 `{treatment, feed_quality, guard_ratio}`（provenance 延伸，粗量化壓縮）。
  - `tick_all` 重構：holder-level guard 決策 → enforce cap → per-group 待遇。
- `scripts/debug/headless_test.gd`：+`_test_asm_feed_starve`/`_guard_flee`/`_guard_cap`；`decide_treatment` 測改讀 `["treatment"]`。
- `scripts/debug/longwindow_bed.gd`：`_diag_gate` 複刻 hunger_relief（threshold_eff）+ food<20 殺數→0（poor 資訊化）。

### 與 spec 差異
- **看守 anon 未實體從生產抽離**：guard_ratio 為調變比例（驅 flee 機率 + cap），未真把 anon 移出生產池。spec §2 提「看守 anon 不事生產（機會成本）」= 願景；plan Task 3 步驟僅要求 guard_ratio 驅 flee/cap，未要求實體重分配。機會成本目前為隱式（leader 選高 guard_ratio = 安全但無顯性產出扣）。
- **餵養扣糧走 `team.resources.food`（ResourceBank 單寫者），非 effective_food（含糧倉）**：守恆乾淨路由。掠奪狼多為 FORCE 隊糧在 team.resources，影響小；定居 holder 若糧在糧倉可能 feed_quality 偏低（罕見）。

## 驗收結果

| 項 | 結果 |
|---|---|
| headless | 1 FAIL（弱目標未加入攻擊 goal，pre-existing）+ 0 SCRIPT ERROR ✅ |
| 新 asm 測 | feed/starve、guard→flee、guard-cap 全 PASS ✅ |
| framework | 7/7 DORMANT=0 ✅ |
| coin_eq / InvariantAudit | headless 內 OK（cohort 自洽、coin_eq、roster/faction/subteam 雙向）✅ |
| longwindow 6 月 ②c food<20 濾殺=0 | ✅ |
| longwindow 6 月 ②b T36 餬口狼 raid 0→37-54/月 | ✅ 解鎖 |
| longwindow 6 月 asm completed/created ≥1/2 | ❌ 0/5（機制正確、世界組成致 0，見根因+建議） |
| longwindow 月線 sanity（隊數/found 不崩） | ✅ 同 seed 對照 main：軌跡同形（both 104→~42 前3月die-off後平、found=1）；branch end-pop 289 vs main 324（−11%=raid↑ 增戰損，預期）；隊數同（40 vs 41）。前3月 die-off = pre-existing（main 亦 104→48） |
| seeded warring 2 月 不 over-war | ✅ |

### asm 分流（longwindow seed 1337, 6 月）— ❌ 目標未達 + ⚠ 較 main 反向惡化（誠實呈報）
**同 seed 同 DIAG=0 apples-to-apples（決定性對照）**：
| | created | completed | interrupted（scatter/escaped/released） | completed 耗時 |
|---|---|---|---|---|
| **main baseline** | 4 | **1** | 3（revolt2/escape1/0） | 24 天 |
| **本 branch** | 5 | **0** | 5（revolt1/escape3/release1） | — |

**本波 ③ 反使 completion 1→0**（同 seed）。目標是「反轉分流、completion 升」，實測**相反**。非 DIAG 假象、非小樣本方向誤讀——同條件 main 有 1 隻同化，branch 0 隻。
機制無 bug（headless `_test_asm_feed_starve` 決定性證「厚待+糧足→同化」；`_guard_flee`/`_guard_cap` PASS；in-world GuardCap fire）。**問題在 net 效果**：

**根因（實證診斷，非機制 bug）**：
1. captive 入場 morale = `CAPTIVE_INIT_MORALE=0.25`，僅高於 `FLEE_T=0.20` 0.05——極脆。任一負 delta（苛待 −0.015/日 或 斷糧厚待 −0.0075/日）數日內即跌破 flee 域。
2. 同化需 morale 0.25→`ASSIM_T=0.75`＝ +0.02/日 × ~25 日**持續厚待+餵飽**。
3. 本波新增「厚待真掏糧」→ **食貧 holder（餬口狼 eff_food≈0，見 T36 raid 但 food_flow≈0）付不起 25 日餵養** → 厚待失效→morale 掉→flee/revolt。
4. 掠食者多為 FORCE 狼（高殘忍→`decide_treatment` 選苛待）→ 直接苛待→暴動/逃。
→ **spec 病因假設（flee-always bug 是唯一結構斷）證偽**：main 那隻 completion 是「厚待+免費餵養 24 天」達標的（非被 flee 腰斬）。本波把餵養變成真掏糧後，食貧狼付不起 → 那隻反而 morale 跌→逃。**拔 flee-always 沒救到人（本無 flee 受害者可救），加餵養成本反殺掉唯一完成者**。

**非機制 bug 證據**：headless 合成 holder（野心0.5/殘忍0.5 tie→厚待 + food 9999）→ 決定性同化。in-world 0 = 世界組成（掠食者殘忍/食貧）+ 入場 morale 脆，非程式錯。

**建議 lev(交系統/藍圖裁，全 TEST VALUE，本波未擅動——`revolt 閾維持` 是 spec 硬約束)**：
- `CAPTIVE_INIT_MORALE` 0.25→↑（離 flee 域遠一點，給救援窗）。
- `MORALE_KIND` 0.02→↑ 或 `ASSIM_T` 0.75→↓（縮短 25 日同化窗）。
- `CAPTIVE_FOOD_RATE` 0.5→↓（食貧狼付得起）。
- `decide_treatment` kind/harsh util 偏厚待（壯兵 intent 加權）。
→ 需系統/藍圖決定「餬口狼該不該養得起俘虜」的願景，非實作單方balance。

### T36 類解鎖證據（longwindow seed 1337 DIAG=1）
- **②c food<20 濾殺歸零**：每月每狼 WolfGate `food<20殺=0`，窮村 `poor=1~2` 計入 viable（如 T36 月1 disc=2→viable=2 全窮村可俘）。餓世界目標不再被殺光。
- **T36（狼餬口）score/readiness 卡點消**：6 月 WolfGate T36 均**無** `★score<thr`、無 `★readiness<thr` tag（僅 `★task佔用(survival)`＝正忙 survival 掠奪＝其想要的搶糧）。對照 spec 病灶「readiness 恆 0.23<0.42 + score 0.27<0.30 永不 raid」→ 兩卡點皆消。
- **★餬口狼真搶糧（最強證據，乾淨run per-wolf 曲線）**：Team36（餬口狼 野心0.65 武力）月 raid 次數 = **37 / 52 / 45 / 54 / 50 / 43**（spec 病灶「餬口狼永不戰略 raid」→ 今狂 raid）。eff_food≈0 食貧但持續搶糧存活（pop 8→8 不死）。
- **對照 Team32（餬口 野心0.92 武力）raid=0**：但 eff_food 積累 500→1231（food_flow +6.6→+7.9）＝**食足**→ hunger_relief=1.0（不啟動下修）→ 正常門檻不 raid（GateWait 標「想 raid 未 raid」= 食足者本不該餓搶，②b 正確不誤放）。
- `surv.loot_dispatch=466`（乾淨run）；prey viable>0（②c 解鎖窮村）。
- **知足者仍蹲（對照組）**：T29（定居/知足）仍 `★archetype=定居` + `★readiness=0.23<0.23(relief0.40)` 被擋 → archetype gate + hunger_relief 下限正確，未誤放知足者。
- **②b hunger_relief 生效**：T29 月5/6 `relief0.40`（斷糧→門檻降至 0.4×，0.58→0.23），relief1.00（糧足→原門檻）動態可見。
- 漏斗：conq.intent=100 → prosperity_reached=5 → combat=25 → capture=5。獨立 prosperity raid 有發生（非全 0）。

### seeded warring 2 月（不 over-war / faction campaign readiness 未鬆）
seeds 1337/42/7，2 月：attrition 47.1% / 40.8% / 0.3%。
對照 r1 baseline（`assets-2026-07-02-r1/warring_base_1337.json`，同 harness 格式）：
- seed1337 attrition **47.1% vs baseline 47.9%**（略降，非 over-war）。
- month1 CONQUER intent 3（同 baseline 3）；month2 CONQUER 1（降）→ faction campaign readiness **未鬆**（CONQUER 未膨脹）。
- teams 79–104、9 factions 穩，無隊數雪崩。
- probe：surv.loot_dispatch=270（獨立 raid 路活躍，②b/②c 目標域）、p1.flee=4/revolt=1/assimilate=0（warring 少俘，asm 機制無崩）。
- ⚠ baseline 為 r1 era（2026-07-02），其後 main 有 envoy-fi1 等 commit → 有輕微 drift；但 attrition 差 <1pp + CONQUER 未升，足以排除 over-war。

## 連動風險

- `faction_ai_system.gd` faction goal 攻擊 / `can_expand` / commander directives：**未受 hunger_relief 影響**（已 grep：`calc_readiness`/`< threshold` readiness gate 僅 `_evaluate_prosperity_attack` line 254-255；line 355 為 threat 不同語意）。②b guard 成立。
- `ResourceBank`：新增 `captive_feed` reason（driver-ledger），無新 bank 操作旁路。
- `AnonTierSystem`：guard-cap 處置全經既有 `detach_captives`/`_spawn_breakaway`，守恆不變。
- treatment_history 結構由 String→Dict：若有他處消費 history 元素為 String → 需檢（目前僅 longwindow_bed 讀 morale/常數，未讀 history 元素型別）。

## 待主 session 確認

- guard_ratio 機會成本是否要真實體化（抽 anon 出生產）= 後續 task（spec §2 願景，本波未做）。
- 新 TEST VALUE 清單：`CAPTIVE_FOOD_RATE=0.5`、`FEED_FAIL_Q=0.3`、`GUARD_RATIO_MAX=0.5`、`GUARD_CAUTION_W=0.3`、`GUARD_LOAD_W=0.3`、`FLEE_COEF=0.3`、`P_FLEE_MAX=0.5`、`GUARD_CAP_MULT=3.0`、`HUNGER_SLIDE_DAYS=7.0`、`RELIEF_FLOOR=0.4`、`PREY_POP_TIE_EPS=0.5`、`ATTACK_SCORE_THRESHOLD` 0.30→0.25。
