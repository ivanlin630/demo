# 勢力凝聚力 — HOW（systems，實作設計）

status: DRAFT → reviewer R²
owner: systems（HOW）；WHAT=`2026-08-05-faction-cohesion-design.md`（blueprint LOCKED、R① CLEAN、emphasis P4-primary confirmed）
date: 2026-08-05
branch: 新 slice `feat/faction-cohesion`（off 更新後 main）
grounding: exit-attribution 量測（defect GENUINE=unrest-gated distress 非 honor cliff；de-patch 非主刀、P4 真好處接留走秤才是主刀）

## 目標（承 WHAT + grounding）
exits 是 genuine（distress-driven）→ **主刀＝給真餓 member 留下的理由（P4 真好處接留走秤）**、非拆 genuine 出口（§1 防crank 雙向：禁 boost 逼留 + 禁刪真走）。好領主（relief 史）留住真餓 member / 爛領主流失＝正確分化。

## Seam（親驗 file:line、2026-08-05 merged main）
- **defect**：`event_faction_defect.gd check`＝`unrest_turns>=DEFECT_UNREST_THRESHOLD(20)`（真 gatekeeper、measurer 證）+ `honor<0.35 OR trust<0.35`（硬 cliff）→ `execute` `clear_team_faction`。
- **uprising**：`faction_ai:4535 _evaluate_uprising`＝3 硬前置門（`avg_loy>=0.2`/`unrest_turns<60`/`_count_stress_sources<2` return）+ stand/flee 人格 split → `:4571/4577` `clear_team_faction`（兩路無條件）。
- **被救過自我記憶**：`benefactor` memory type（`_has_memory_type(leader,"benefactor")`、`faction_ai:4626`）；現只 `interaction:1204`（乞丐受助）/`player_command:1013` 寫——**relief 到 resident 現不寫**。
- **聲譽 belief**：`team.known_reputations`（`team_data:227`、道德聲望軸、belief 非 god-view）。
- **relief 受補**：`_tick_resident_unrest:3315` `受補回升→UnrestBank.reduce`（aggregate unrest、非記憶）。
- **立國**：`faction_ai:1820 if "立國" in f.goals: _declare_established`。

## §2 設計（PRIMARY→SECONDARY）

### PRIMARY：P4 真好處接留走秤（新 `_stay_benefit`）
新 helper `_faction_stay_benefit(state, team) -> float`（member 對「留在此勢力」的真期望價值、★零 god-view）：
```
stay_benefit =
    W_RELIEF   * relief_memory       # 被救過=自我記憶(benefactor memory of 領主)、被救次數/近度
  + W_REP      * heard_reputation     # known_reputations[領主](聽聞道德聲望 belief)
  ,  人格 modulate（義氣/信義高→更重視領主恩義；野心高→更輕）
```
- **★新 write（HOW 核心）**：distribute relief 真送達 resident（settle 成功、`_dispatch_convoy`/deliver settle 站）→ member leader 寫 `benefactor` memory（領主 team_id、tick）＝「領主救了我」自我記憶。**這是 P4 的地基**（沒它 stay_benefit 讀不到 relief 史）。
- **★感知鐵律硬界**：`relief_memory` 讀**自身** `benefactor` memory（self）、`heard_reputation` 讀**自身** `known_reputations`（belief）。**禁讀全知統計**（如 `faction.total_relief_count`/掃全 faction relief god-view）。
- 常數 W_* calibration 錨真值（relief 一次的 survival 價值 DERIVED、非 fire-crank）。

### defect refine（`event_faction_defect.check` 死 cliff→人格+經歷 weigh）
- 保 `unrest_turns>=20` precondition（genuine distress gate、measurer 證、**不動**）。
- among distressed：`honor<0.35 OR trust<0.35` 硬 bool → **連續 defect-util**：
  ```
  defect_util = distress_pressure(unrest) * loyalty_deficit(honor,trust 連續) - _faction_stay_benefit(...)
  defect fires if defect_util > 0
  ```
  - 真餓+被救過+好聲譽 member（低 honor）→ stay_benefit 高 → 不 defect（忍）；真餓+沒被救+爛聲譽 → defect（走）＝**正確分化**。
  - honor 0.35 cliff → distressed 中 honor 連續 weigh（照妖鏡 polish、非救命）。
- `execute` `clear_team_faction` **不動**（走的一側保留、genuine exit）。

### ★整併：第三個「留vs走」決策點（reviewer R² 必查項、systems 判整併）
`_trigger_defection_evaluation`（`faction_ai:4620-4643`、contact-loss/owner-change 觸發的 a/b/c 人格 split：留faction/投降/獨立）**已用 `has_benefactor_memory` flat+0.3**（`:4626-4627` `a_score = honor + 0.3`）＝第三個讀「被救過」訊號的入口。
- **判＝整併**（一個 stay-benefit 概念、一致精度、防同底層事實兩套讀法）：`:4626-4627` 的 `has_benefactor_memory` flat+0.3 → 改 `a_score = honor + _faction_stay_benefit(state, team)`（rich：relief-memory+reputation 人格 weigh 取代粗糙常數）。
- **界**：此處**觸發**（`_evaluate_owner_contact` contact-loss）仍 ledger arc domain（defer 不碰）；只**升級 stay-benefit 讀法**（a_score 的留-side）＝cohesion arc 的 stay-benefit 統一（三決策點 defect/uprising/defection-eval 共用 `_faction_stay_benefit`）。

### SECONDARY：uprising（`_evaluate_uprising`）
- **3 前置門→連續 polish**：`avg_loy>=0.2`/`unrest_turns<60`/`stress_sources<2` 硬 return → 折進連續 uprising-utility（trigger genuine 故 polish；unrest/loyalty 連續 weigh 非硬 cliff）。
- **★後果秤（uprising 主刀）**：Path A 守城後**別無條件 `clear_team_faction`**——秤「換領主留勢力 vs 脫離」（reuse `_faction_stay_benefit` + 人格：義氣高/stay_benefit 高→推翻本地暴領主但**留勢力**換新安排；野心高/stay_benefit 低→自立脫離）。Path B 流亡保留脫離（流亡語意=離開）。

### 立國 goal 查根（HOW 階段、P3）
- 查「立國」何時/是否被加進 `f.goals`（`:1820` 只消費、assign 點更早）——grep 「立國」寫入 f.goals 點 + 為何 founding 路（envoy found_ally→但 g2.faction_found=0）never 觸發 assign。
- 修 scope 視根：小（順修 assign 條件）→ 本 arc 順手；大（envoy establish 鏈重構）→ 歸立國/正統 arc、本 arc 只記檔。

### contact-loss（④）
**DEFER → 歸失聯帳本 ledger arc domain**（blueprint 定、反向 case、ledger 量測順帶）。本 arc 不碰。

## 守（憲法/感知鐵律）
- **★零 god-view**：stay_benefit 讀自身 benefactor memory（self）+ known_reputations（belief）；禁全知 relief 統計。constitution gate 綠。
- **§1 防crank 雙向**：兩邊真值（distress 真 / stay_benefit 真）、引擎秤；**禁忠誠加成常數/boost 逼留**（乙 crank）、**禁刪真走**（defect/uprising exit 保留、只加 stay-side）。**無穩定配額指標**。
- 人格非死常數：honor/trust/loyalty/ambition 連續 weigh。determinism byte-identical（stay_benefit 純算術+memory 讀、benefactor write 零 RNG）。

## TDD 驗收（implementer）
1. **分化（PRIMARY 命門）**：餵飽+被救過 member（低 honor）**留** vs 餓+沒被救 member（同低 honor）**走**（RED：stay_benefit neuter→兩者皆走=退回死 cliff）。
2. **好領主 vs 爛領主持久度**：有 relief 史的領主勢力顯著比疏忽領主持久（同機制人格產不同壽命）。
3. **relief→benefactor write**：distribute relief 送達 → member 得 benefactor memory（RED：write 點 neuter→stay_benefit 讀不到 relief 史）。
4. **★god-view 硬驗**：stay_benefit 讀 self-memory+belief、非全知 relief 統計（感知鐵律 gate、god-view detector 綠）。
5. **uprising 後果秤**：起義後**可能換領主留勢力**（非必然脫；RED：後果秤 neuter→回無條件 clear）。
6. **該散的散**：暴君/疏忽領主 member（無 relief 史+爛聲譽）真餓 → 仍 defect（stay_benefit 低、genuine exit 保留、非 boost 焊死）。
7. determinism byte-identical + constitution 74。

## 量測（湧現式、無配額、measurer→QA）
- **分化**：仁厚/責任領主勢力 vs 暴君/疏忽的壽命差（同機制人格產不同）。該散的照散（暴君失人心案例仍在）。
- **下游解鎖**：rep 床不再秒崩 → relief 長窗觀測可行 + L3 cross-faction domain 可行使（cohesion 驗收=解 L3/relief-general blocker）。
- 零配額（禁「X% 存活」）。determinism / 感知鐵律 / QA 故事稽核（留/走案例逐個合人格）。

## 追蹤
- `benefactor` write + stay_benefit = 全量 tap（`cohesion.stay_benefit`/`cohesion.endured_distress`/`cohesion.defect_despite_relief`/`cohesion.uprising_stay_faction`）——全量暫態可觀測性。
- W_RELIEF/W_REP calibration 錨真值（relief survival 價值 DERIVED）。
