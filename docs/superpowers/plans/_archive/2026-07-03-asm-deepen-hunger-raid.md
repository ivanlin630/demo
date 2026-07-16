# ③ asm 做深 + ②b 飢餓搶糧 + ②c 濾改分 — Plan

> Spec：`docs/superpowers/specs/2026-07-03-asm-deepen-hunger-raid-design.md`（先整份讀,含硬約束）。
> 順序:Task1 ②c（最小,獨立）→ Task2 ②b → Task3 ③ asm（最大）→ Task4 合體驗收。

## Task 1 — ②c prey 濾改分

**檔**:`faction_ai_system.gd`（`_find_weakest_prey`）
1. 刪 `if bel.has("food_est") and food_est < 20.0: continue` 硬濾。
2. 弱點主排序（pop_est 最低）不變;同弱者 food_est 高者優先（輕 tie-break,TEST VALUE 實作自定,勿蓋過 pop 主序）。
3. headless 測:餓世界（全目標 food<20）prey 仍可選;富村 vs 窮村同 pop → 富村先。

## Task 2 — ②b hunger_relief + score 寬

**檔**:`faction_ai_system.gd`
1. `_evaluate_prosperity_attack` readiness 檢查:`threshold × clampf(food_days/HUNGER_SLIDE_DAYS, RELIEF_FLOOR, 1.0)`。常數 `HUNGER_SLIDE_DAYS=7.0`、`RELIEF_FLOOR=0.4`（TEST VALUE）。`food_days = effective_food/(pop×FOOD_PER_PERSON_PER_DAY)`。
2. **只在 prosperity（獨立 raid）路**:faction goal 攻擊/`can_expand`/commander directives 的 readiness 檢查**全不動**（grep 確認無誤入）。
3. `ATTACK_SCORE_THRESHOLD` 0.30 → 0.25（TEST VALUE 註記）。
4. headless 測:餓隊（food_days≈1）threshold 有效值 ≈ 0.4×原;糧足=原值;faction 路 readiness 不變。

## Task 3 — ③ asm 待遇做深

**檔**:`manpower_system.gd`、（如需）`anon_tier_system.gd`/`ResourceBank`
1. **餵養**:`tick_captives` 厚待時 holder 撥糧 `captive_n × CAPTIVE_FOOD_RATE`/日（TEST VALUE≈0.5,低於 free pop 標準口糧）,ResourceBank 扣（reason="captive_feed"）。`feed_quality = 實撥/需求`（0-1）;`morale delta = MORALE_KIND × feed_quality`;feed_quality<0.3 → 厚待失效（delta 取 MORALE_HARSH×0.5,餓著=虐待）。
2. **看守**:`decide_treatment` 回傳擴 dict `{treatment, guard_ratio}`（guard_ratio 連續 0-0.5,由 leader 慎重+持有量驅動,TEST VALUE 公式）;holder 記 `captive_guard_ratio`。`_flee_opportunity` 改連續機率:`p_flee = clampf(captive/(guard_n+1) × (1-morale) × FLEE_COEF, 0, P_FLEE_MAX)` 每日擲——刪 `readiness<0.4` 恆真項。看守 anon = `total_pop × guard_ratio`,計入 guard_n。
3. **guard-cap**:`captive_cap = guard_n × GUARD_CAP_MULT`（TEST VALUE≈3）。超限 → 本日待遇決策強制處置超額（釋放 or 苛用,依 leader cruelty means-end,走既有 _flee/苛待路由,守恆）。
4. treatment_history 記 `{treatment, feed_quality, guard_ratio}`（provenance 延伸,壓縮規則沿用）。
5. headless 測:厚待+糧足 → 同化如期;厚待+斷糧 → morale 掉;看守厚 → 逃機率壓低;超 cap → 強制處置 fire;coin_eq/pop 守恆。

## Task 4 — 合體驗收

1. **longwindow 6 月**（`LW_SEED=1337 LW_MONTHS=6 LW_DIAG=1`,輸出落檔再篩）:
   - asm 分流:completed/created ≥ 1/2 量級（暴動/逃不歸零）。
   - T36 類餬口 FORCE 狼 raid>0（[WolfGate] score/readiness 卡點消或降）;diag prey 掃 `food<20` 殺數=0。
   - 月線 sanity:隊數/attrition/found 不崩;知足者仍蹲。
2. seeded warring 2 月:不 over-war（隊數不雪崩）、faction campaign readiness 未鬆。
3. 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7 DORMANT=0、coin_eq delta=0、InvariantAudit 0。

## Handback

`docs/superpowers/handbacks/2026-07-03-asm-deepen-hunger-raid.md`:各 Task 結果、asm 分流前後表、T36 解鎖證據、新 TEST VALUE 清單、月線對照、偏離 spec 處。

## 注意

- Godot `.\tools\godot.ps1`;長窗 `GODOT_TIMEOUT=5400` 背景;**輸出先落檔再篩**。
- headless 基準 1 FAIL（弱目標未加入攻擊 goal）=pre-existing。
- 硬約束:零新 classifier;連續信號;守恆全經 AnonTierSystem/ResourceBank;新 latch（無,若引入必配 timeout）;禁碰 faction campaign readiness、R1 logistics 因子、envoy 路徑。
- guard_ratio/feed 常數全標 TEST VALUE。
