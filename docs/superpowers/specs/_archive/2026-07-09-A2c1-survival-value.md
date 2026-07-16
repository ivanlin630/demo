> **★★2026-07-09 撤銷（藍圖定案 `blueprint-to-systems-A2c1-ship-pure-fold`）**：本 survival-value 整案**廢棄，不 merge**（分支 4e57ea9）。多 seed(1337/42/7) 證「純 fold=regression」是 **seed-1337 幽靈**（extinct.starve 方向不一致 +3/−24/0）→ 解的是假問題；且 upgrade 實驗證 **merge food-blind/survival-inert**（逼併 320 starve 不動、世界逐位元同）本就無效。**SHIP 純 FA5 fold @423924c**（見 `2026-07-09-A2c1-consolidate-into-engine.md`）。food-aware merge 歸未來絕境經濟 slice（`known_issues`）。本檔存為設計紀錄/教訓。

# A2c-1 升級 Spec — consolidate_drive 生存值化（fold + survival-value）【撤銷】

- from: systems
- 依賴: `2026-07-09-A2c1-consolidate-into-engine.md`（FA5 fold，D1/D3/D4/D5 全保留不動；本 spec **只改 D2**）
- 基底 branch: `feat/machine-A2c1 @ 423924c`（純 fold + full_probe 探針，已 committed）
- 工單: `docs/superpowers/handbacks/2026-07-09-systems-handoff-A2c1-survival-value-next.md`（blueprint 定案）
- 鐵證: `scratchpad/a2c1_fp2_{base,fold}.json`（seed 1337）——merge.consolidate_dispatch 978→154（−84%）、extinct.starve 16→19、avg-size 7.0→5.6、join.resolve 24→14、attack-eligible 416→309、conq.declared 740→520

## 問題（純 fold 病灶）

純 fold（前 spec D2）用 **flat** `CONSOLIDATE_DRIVE=2.0` 常數，意圖「量級恆勝 mundane/threat option」保真舊 pre-gate 恆 fire 行為。**未收斂**：flat 常數對「小隊」一視同仁，強隊也常被其他 option（生產/貿易/攻擊）比下去 → merge 實派暴跌 84%，餓死隊上升（弱隊該併但沒併夠 → 餓死）。結構性因：舊 pre-gate 本是「小 pop 恆 fire」的 faction-level 機制，flat drive 把它降級成「有時候贏」的個人 utility，弱隊跟強隊同一把尺 → 弱隊求生輸、強隊機會併被鎖死。

## ★護欄（blueprint 定案，不可違）

治生存地板，**別過修回強制併**（勿重造 978 artifact）。目標中間態：
- 弱/餓/瀕死隊：**可靠求生併**（消 starvation regression）。
- 強隊：有更好 option 時**自由選**（引擎誠實，chose_other 保留可觀比例，非再 100% 併）。
- **別把 merge 調回 ~978**（=重造強制併 artifact）。

## 設計決定（D2 唯一改動）

### D2'. `consolidate_drive` 生存值化（`decision/terms.gd`）

拆單一 flat 常數為 **base + survival boost**，**求生軸=飢餓（主）+ 絕對瀕死 floor（次）**：

```gdscript
"consolidate_drive":
    if opt != "整併" or ctx.consolidate_target_id == -1: return 0.0
    # 求生 vs 機會分流：base 量級不保證贏（well-fed 隊自由選,不強制併）；
    #   boost 依「飢餓」拉到恆勝（不併會餓死→求生保底）。
    # ★飢餓=主求生訊號（會 discriminate,糧從飽到餓量級大變）。
    var hunger_factor: float = clampf((DESPERATION_DAYS - ctx.food_days) / DESPERATION_DAYS, 0.0, 1.0)
    # ★次訊號=絕對瀕死 floor（非相對 1-pop/cap）：只救戰損剩 ≤CRITICAL 人的（不併必亡），
    #   不救「剛建/well-fed 小隊」。理由見下 ★關鍵設計註。
    var critical_pop: float = 1.0 if ctx.population <= CONSOLIDATE_CRITICAL_POP else 0.0
    var survival_boost: float = CONSOLIDATE_SURVIVAL_BOOST * maxf(hunger_factor, critical_pop)
    return CONSOLIDATE_DRIVE_BASE + survival_boost
```

常數（`decision/terms.gd`，TEST VALUE，full_probe 3-way 校準）：
```gdscript
const CONSOLIDATE_DRIVE_BASE: float = 0.8      # < threat/mundane option 量級 → well-fed 隊常輸(自由選,保 chose_other)
const CONSOLIDATE_SURVIVAL_BOOST: float = 3.0  # BASE+BOOST=3.8 > 任何 option 量級 → 餓/瀕死隊恆勝(求生保底)
const CONSOLIDATE_CRITICAL_POP: int = 2        # 絕對瀕死線(戰損剩 ≤2 人=不併必亡),非相對小
```

**★★關鍵設計註（前輪 flat pop_factor 缺陷 + 修正，2026-07-09 Opus 重審）**：
- 前輪用 `pop_factor = 1 - population/cap` 當求生訊號。**缺陷**：branch1（容量吸收）的 `consolidate_target_of` 只在 `mt.population < mt_cap×SMALL_TEAM_RATIO(0.3)` 才回 target ∴ **所有 absorb 候選 pop/cap<0.3 → pop_factor 恆 >0.7**。pop_factor 在候選集內幾乎不變 → boost 退化成 flat ≈2.1~3.0 → 該隊**恆勝→恆併** = **重造 978 artifact**（違護欄①）。reviewer 自己 note「剛建隊糧足不該恆勝」但 maxf 只防疊加、pop_factor 單獨仍高→仍恆勝，**與該顧慮自相矛盾**。
- **修正**：求生軸主訊號改**飢餓**（`hunger_factor` 隨糧真變化 → 真 discriminate：餓隊 boost 高→求生併；well-fed 小隊 hunger=0→只 base 0.8→掉回自由選）。這才達中間態：**merge 從 978 降但非崩到 154**（餓的還併、飽的自由）。
- pop 只保留**絕對瀕死 floor**（`≤2` 人=戰損殆盡、不併必亡）處理飢餓漏網的 combat-attrition edge；不用相對值（避免把「所有小隊」誤判成求生）。
- `maxf(hunger, critical)`：任一求生訊號拉滿即恆勝，不疊加。
- **weight 不變**：`w_term("consolidate_drive")` 仍 1.0（faction 機制非人格染色）。

**（D3' 刪除）**：不再需 `consolidate_cap` ctx 欄——`ctx.population` 既有，`CONSOLIDATE_CRITICAL_POP` 是絕對常數。前輪 spec 的 D3' 整段作廢，減一欄一 helper。

## 觸及檔（增量，於前 spec@423924c 之上）

| 檔 | 改點 |
|---|---|
| `scripts/simulation/decision/terms.gd` | `consolidate_drive` eval 換算式（hunger 主 + critical_pop floor）；`CONSOLIDATE_DRIVE_BASE=0.8`/`CONSOLIDATE_SURVIVAL_BOOST=3.0`/`CONSOLIDATE_CRITICAL_POP=2` 取代舊 flat `CONSOLIDATE_DRIVE` |
| `scripts/simulation/decision/decision_context.gd` | **無新欄**（用既有 `ctx.population`/`ctx.food_days`）——僅確認前 spec `consolidate_target_id` 欄已在 |

**不碰**：D1(option applicable/to_task)、D3(consolidate_target_id/consolidate_target_of)、D4(拆 pre-gate)、D5(憲法閘)、觸發三常數、survival-sticky 機制（TaskArbiter priority-gate，不變）、`decision_context.gd` gather（不加 cap）。

## 3-way full_probe 驗收線（baseline / 純fold@423924c / 本 spec 升級版，同 seed 1337）

1. **starvation 回健康**：`extinct.starve` ≲ 16（純fold 19 → 回落）；avg team size 回升（純fold 5.6 → 回升，非必須回 7.0）；`join.resolve` 回升（純fold 14 → 回升）。
2. **merge 實派回升但顯著 <978**：`merge.consolidate_dispatch` 落在 (154, 978) 區間、明顯偏離兩端（非重造強制併、非維持純fold 崩塌）。
3. **強隊 option 自由保留**：`merge_appl.chose_other`（需先補 bump，見下）仍可觀比例（>0%，非再逼近 100% 併）。
4. **衝突面**：`attack-eligible`/`conq.declared` 觀察值記錄，不設 target（別下游逆向逼）。

**★merge_appl probe 缺口（校準前必補）**：`merge_appl.total`/`chose_整併`/`chose_other` 現只在 `warring_harness.gd:31` PROBE_KEYS 註冊，**未 bump**（純 fold spec 未接）。本 spec 落地時需在 `_decide_unified` rank 迴圈（`faction_ai_system.gd` ranked 產生處，applicable=="整併" 隊)補：
- 隊 `consolidate_target_id != -1`（applicable 命中）時 bump `merge_appl.total`；
- 若最終 `winner.opt == "整併"` bump `chose_整併`，否則 bump `chose_other`。
無此 probe，驗收線 3 無法驗（純鐵證檔手工算出 52% 是量測員 ad-hoc 算法，非 committed probe——本 spec 補成正式線，未來 slice 複用）。

## 驗收法（QA/量測員跑；systems 不跑 godot）

1. 無 GDScript 錯誤；`--headless --import` 綠。
2. constitution_gate 綠（本 spec 無新 try_set 落點，純 term/ctx 算式改）。
3. sanity：`game_sim_multi` ≥1000 tick 無崩。
4. **3-way full_probe**（上節 4 條驗收線全過）。
5. 迴歸：leader/solo/子隊/其他 category 背離不暴增；`arbiter_latch` 低檔。
6. **★守衛（硬閘）**：`merge.consolidate_dispatch` 不得回升至 ≥800（防重造 978 artifact——若升破，`CONSOLIDATE_DRIVE_BASE`/`BOOST` 調過頭，FAIL 回校準）。
   - **★famine-window 判讀（reviewer rev2 caveat）**：若 merge 衝高逼近閘，量測員需先判「高峰是否伴 famine event 窗口」——隨 famine 起訖伴生（大範圍同步飢荒→集體求生併）=健康湧現、非 formula 病（護欄①禁「恆併」非禁「飢荒時多併」）；與 famine 脫鉤的常駐高位=formula 仍偏 flat=真 FAIL。判準：merge 高峰對不對得上 food_days 探底窗口。
7. **★守衛（硬閘）**：`extinct.starve` 不得高於純fold（19）（防升級版比純fold更差）。

## 呈報藍圖

若校準後驗收線 1/2/3 無法同時滿足（e.g. 治飢餓必推 merge 破 700，或強隊自由必犧牲 starvation 回落）→ 回 blueprint：中間態不存在，需重裁「求生地板」與「978 artifact 紅線」孰先。
