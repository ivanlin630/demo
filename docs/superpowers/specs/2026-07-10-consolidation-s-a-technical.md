# Spec — Consolidation S-A 併決策統一（技術 / systems HOW）

> 願景 = `2026-07-10-consolidation-unified-decision-design.md`（blueprint，已收 reviewer 框①三靶）。本檔 = S-A 技術 HOW（term/context/seam）。屬決策統一 program [[project_unified_decision_framework]]。**S-B 降服/附庸另 slice**。

## 目標（S-A）
退役 `consolidate_drive` flat 1.0 + `join_drive` 窄 `has_strong_neighbor` gate → **收進 rank_scored 真生存/人格 term 秤**；`_find_absorber` 納**餵養能力**（靶A 硬 gate 防搬餓）；接受方也 rank 秤（雙邊握手，靶C 薄層邊界誠實寫）。

## 現況錨點（characterize）
- `terms.gd:89 join_drive`：`if opt!="投靠" or not ctx.has_strong_neighbor: return 0.0`（窄 gate，無食壓）。weight `join`=義氣/信義/求生欲(`:222`)。
- `terms.gd:158 consolidate_drive` eval：gate `opt=="整併" and consolidate_target_id!=-1`。weight `:229` = **flat 1.0**（A2c-1「faction 機制非人格染色」=待退 flat 病）。
- `faction_ai:1562 _find_absorber`：選 absorber，**零 food 檢查**（靶A 靶）。`consolidate_target_of`→ 餵 `ctx.consolidate_target_id`(`decision_context:266`)。
- context 已有：`food_days:9`（=ef/(pop×FOOD_PER_PERSON_PER_DAY)）、`home_food:54`、`survival_pressure` term、`has_strong_neighbor:40`。
- 投靠 contact resolver 已存在（`_try_join_target`，join.resolve 活）——**靶C 薄層復用點**。

## HOW-1：term 退 flat → 生存×人格秤（地板1：真 term 非補償閘）
**驅力 = 食壓（eval magnitude）× 人格（weight）**，argmax 湧現（地板2：無 `pop<N` 硬寫）。

### `join_drive`（投靠=弱方求生 push，走 subteam join）
- eval 退窄 gate → **食壓 scaled**：`join_drive = survival_urgency(ctx)`，其中 `survival_urgency = clampf((JOIN_SAFE_DAYS - food_days)/JOIN_SAFE_DAYS, 0, 1)`（餘命越短越高；`威脅` 加碼見下）。`has_strong_neighbor` 從**硬 gate 降為 applicable 前提**（有可投靠對象才 applicable，非驅力來源）。
- weight `join` 保（義氣/信義/求生欲）+ **野心負向**：野心高者不甘投靠 → weight 疊 `_low_ambition_factor = clampf(1 - 野心, ...)`（design：野心低+餓→投靠 util 高）。
- 威脅加碼：`+ THREAT_JOIN_W * threat_norm(ctx)`（打不過的鄰→投靠更划算）。

### `consolidate_drive`（整併=全池化合併，弱方主動選）
- weight `:229` **退 flat 1.0** → `consolidate` weight = f(求生欲, 1-野心)（同 join 側人格：餓+不稱霸傾向併大）。
- eval → 食壓 scaled（同 survival_urgency），gate 保 `consolidate_target_id!=-1`（有 absorber）。

### 吸附側 pull（強方收弱隊）＝接受方 rank（見 HOW-3）
- 野心/統領力高者 weight 高（願當吸附方）——由**接受方**的 accept-util 表達（非發起方 term），見 HOW-3 握手。

## HOW-2：`_find_absorber` 餵養能力 gate（★靶A 硬 gate，防搬餓）
`_find_absorber`（`faction_ai:1562`）選 absorber 時**必過餵養能力**：
- 新 context/helper：`absorber_food_surplus = absorber.food_days`（併前餘命）；`combined_food_days = combined_ef / ((absorber.pop + absorbed.pop) × FOOD_PER_PERSON_PER_DAY)`（併後合隊餘命，ef=兩隊 food 存量和）。
- **gate**：`combined_food_days >= ABSORBER_MIN_SURVIVE_DAYS`（併後合隊須真能撐；吸附者併前有 surplus 才吸）。不過 → 該 absorber 不選（非把餓稀釋進更大隊）。
- = design「餵養真解生存非搬餓」的 code 面。`consolidate_target_of` 同步過此 gate（context target 一致）。
- **同 faction 限制**：S-A 保守**維持同 faction**（跨勢力投靠=脅迫語境，歸 S-B 降服）。註記放寬待 S-B。

## HOW-3：雙邊握手（★靶C 薄層，誠實邊界）
**承諾＝驅力統一（雙方 util 皆 rank_scored 出），非「跨隊時序協調零 bespoke」。** 單隊 per-cadence argmax 無法原子做雙邊同意 → **薄層 = contact-time resolver**（復用既有 `_try_join_target`/interaction resolver 骨架，非新概念）：
1. **發起方**（弱隊）argmax 選 `投靠`/`整併` → `to_task` dispatch 走向 absorber（move_target=absorber，既有）。
2. **接受方**（absorber）在**接觸時** resolver 查其 **accept-util**：absorber 側 rank 一個輕量 accept 判斷（野心/統領力 weight × 有餘裕收 → 願收；食壓自身太重 → 拒）。**這是薄層**：非 absorber 每 cadence 主動秤全 option，而是被動 on-contact 秤「收不收這隊」。
3. accept → `merge_teams`（整併）/ subteam attach（投靠）；reject → 發起方回退（下 cadence 重 argmax，可能轉別 absorber 或別 option）。
- **邊界誠實聲明**：此 resolver = bespoke 薄層（~1 函數，contact 觸發），**不假裝零框外**。理由=雙邊異步咬合純腦內解不了（A2c-1 教訓：別先講死強框）。復用 interaction-resolver seam（judge 盤點：非重造，同 BEG/JOIN/aid 模式）。

## ★S-A 硬驗收 gate（reviewer 靶A，spec 寫成 measurer 先驗項，非事後量）
1. **餵養真解非搬餓**：measurer 量併事件**前後合隊** `food_days/餘命`——須**實質改善**（`combined_food_days > 兩隊併前 min`，且吸附者併前 surplus>0）。搬餓（合隊更餓）=FAIL 打回。
2. **隊變大真觸殲滅可見**：organic full_probe 量**隊規模分布上移** + `end_annihilation` 隨之 **>0**（承敗北逃殲滅窄縫）。隊變大但殲滅仍 0 → 因果鏈第(3)跳斷 → 回報 blueprint 重估（別默默過）。
3. **併=湧現非腳本**：grep 確認**無** `pop<N 就併` 硬寫；食壓 term 驅 argmax。三端/戰鬥不退化、determinism/融合閘/憲法綠。

## 觸及檔（S-A）
| 檔 | 改點 |
|---|---|
| `decision/terms.gd` | `join_drive`/`consolidate_drive` eval 退 gate→食壓 scaled；weight 退 flat→人格（求生欲/1-野心/威脅）|
| `decision/decision_context.gd` | +餵養能力 context（absorber surplus/combined 餘命）；威脅量化 norm |
| `faction_ai_system.gd` | `_find_absorber`/`consolidate_target_of` +餵養 gate（靶A）|
| interaction/resolver | 接受方 accept-util 薄層（靶C，復用 `_try_join_target`）|
| `decision/options.gd` | 投靠/整併 applicable：`has_strong_neighbor` 降 applicable 前提（非驅力）|
| `warring_harness.gd` | +併事件前後 food_days/隊規模分布/殲滅 探針（3 gate）|

## 常數（TEST VALUE，measurer 校準）
`JOIN_SAFE_DAYS`(餘命門檻~5)、`THREAT_JOIN_W`(0.4)、`ABSORBER_MIN_SURVIVE_DAYS`(併後合隊最低餘命~7)、`accept-util` 人格權重。

## 流程
spec-lock 前 **reviewer 對抗②（審本 spec）**——**★大架構 call（新 option-set 語意 + redirect 大工 + 動決策腦核心）三對齊 → 升異質 refute 框外審**（別 Opus 代）。CLEAN → implementer → measurer 3 硬 gate → 數字 to:blueprint 判因果鏈（尤其靶A 搬餓/隊變大見殲滅）。**S-B risk 清單（靶B subteam 骨架硬假設）留 S-B 動工前**。
