# 統領技能日常領導成長（技術 spec）

> WHAT = 用戶裁定（blueprint `command-growth-spec`，R² premise CLEAN）。established B2 硬牆真根：統領技能唯一成長=P4_expand reaction，被 `_score_expand` 繁榮閘（food>100+低壓+統領tag→base 0.55，否則 0.05）壓成絕境隊幾乎不 fire→統領凍結 ~0.25<門檻 ~0.35→established 100% 卡。
> 修：**加日常領導成長路徑（帶隊隨時間微增統領），底層保底，不取代 P4_expand。**

## 真根（reviewer R² 精確化）
- `skill_system.gd:13 REACTION_SKILL_MAP["P4_expand"]={統領,魅力}` = 統領唯一 growth 來源。
- `reaction_system.gd:154-161 _score_expand`：food/stress/tag 是**評分懲罰**（base 0.55 vs 0.05），非 literal 硬 gate——壓到 0.05 後幾乎必輸 argmax（`on_reaction` 只在 reaction 被 argmax 選中才 fire growth）。
- 因果鏈成立（empirically established 恆0、B2 gate_fail 100%）。

## WHAT（用戶裁定，固定）
- 帶隊本身（leading a team/faction，**不限 food/stress**）隨時間/cadence 微幅累積統領。
- **新增底層保底成長，不取代 P4_expand**（繁榮隊仍循 P4_expand 額外/更快成長）。
- 速率明顯低於 P4_expand → 絕境隊「終將爬過門檻但非立刻」（保留掙扎張力，只拔 structurally-practically 永不可能那部分）。

## HOW

### §1 新 cadence 成長：`_tick_leadership_tenure`（faction_ai_system.gd）
在 `_evaluate_all_body` loop2（:665 `for tid in state.teams`，已遍歷全 team 含 faction leader/獨立隊/成員）內，加 cadence-gated 統領成長：
```gdscript
# loop2 內，每 team 迭代時（既有迴圈，零新遍歷）：
if state.world.current_tick % LEADERSHIP_TENURE_INTERVAL == 0:
    _grow_leadership_tenure(state, team)
```
`_grow_leadership_tenure(state, team)`：
```gdscript
func _grow_leadership_tenure(state: WorldState, team: TeamData) -> void:
    if team.leader_id == -1: return
    var leader: PersonData = state.persons.get(team.leader_id)
    if leader == null: return
    # 帶隊 = 領導經驗被動累積。魅力驅動（對齊 REACTION_SKILL_MAP P4_expand 的 attr=魅力）。
    var charisma: float = float(leader.attributes.get("魅力", 0.5)) * leader.get_attribute_mult("魅力")
    var endurance: float = float(leader.attributes.get("毅力", 0.5)) * leader.get_attribute_mult("毅力")
    var growth: float = LEADERSHIP_TENURE_GROWTH * charisma * (0.5 + endurance * 0.5) \
        * leader.get_skill_mult("統領")
    SkillSystem.cap_add(leader, "統領", growth)
```
- **每 team 的 leader** 皆長（faction leader / 獨立隊 leader / 成員隊 leader）——帶隊即練。**含 player leader**（被動經驗非 AI 決策，不違「AI 不替玩家決策」——那是 task/意圖層，技能被動成長無害且對稱）。
- 復用既有 `SkillSystem.cap_add`（cap 1.0）+ `_grow` 同款 attr×endurance×mult 公式（一致，非另發明）。

### §2 常數（faction_ai_system.gd 頂，TEST VALUE）
```gdscript
const LEADERSHIP_TENURE_INTERVAL: int = WorldState.TICKS_PER_DAY   # 每日一次（TEST VALUE）
const LEADERSHIP_TENURE_GROWTH: float = 0.0006                     # TEST VALUE — 明顯低於 P4_expand(≈0.001~0.003/次)
```
**速率推導**（供 measurer/blueprint 調）：門檻缺口 ~0.1（0.25→0.35）。日成長 ≈ 0.0006 × 魅力(~0.6) × 毅力係數(~0.8) ≈ 0.0003/日 → 12mo(360日) ≈ +0.10 → **約一年爬過門檻**（絕境隊撐一段時間終能立國，非立刻，保張力）。魅力高 leader 更快。TEST VALUE，measurer 量實際軌跡後校。

### §3 determinism
- loop2 既有 `for tid in state.teams`（固定插入序）+ cadence gate（`% INTERVAL`）+ `cap_add`（純算術）→ **零 randf、byte-identical 於同 seed**。
- **★baseline 位移（非 regression）**：這是行為改動（統領數值變→established 變）。measurer 說明 baseline 位移，比照 world-gen variety 先例（標「command-tenure 位移，非迴歸」重生 baseline）。

### §4 不動範圍
- **P4_expand 路徑不碰**（`_score_expand` 繁榮閘 + REACTION_SKILL_MAP + on_reaction 全不動）——新路徑純加，繁榮隊照舊額外成長。
- ESTABLISH_COMMAND 門檻（0.4）、初始統領 gen（PersonGenerator）、B3/B4 其他 established 門不動（本 slice 只解 B2 成長路徑；A 門人口/B4 readiness 另議）。

## 驗收法（measurer 產數字，藍圖判）
1. **B2 解鎖**：default.json 12mo——`gate_fail_b2_command` 從 100% 卡死 → 有通過案例；`leader 統領` 12mo 爬升軌跡（pre：凍 ~0.25；post：漸升過門檻）。
2. **established > 0**：終於有 faction established（對照 pre 恆0）。**注意**：established 仍受 A 門（人口 82.7% 卡，第二層）+ B4 readiness 上游制約 → B2 解未必立刻大量 established，但 B2 不再是 100% 硬牆即達本 slice 目標。誠實區分「B2 解鎖」vs「established 大漲」（後者需上游 A 門也解）。
3. **P4_expand 不回歸**：繁榮隊統領成長路徑仍在（P4_expand 未受影響）。
4. **determinism**：同 seed byte-identical（含新成長）。baseline 位移標記。
5. **融合閘**：constitution/coin/framework/sanity 綠。

## 流程
- spec → **R²**（審成長落點/速率合理/determinism/不碰 P4_expand/範圍鎖 B2 only）→ CLEAN → implementer 疊 worktree `feat/command-tenure-growth`。
- measurer 平行 corroborate（pre 統領凍結軌跡）+ build 後全驗收。
- 這是絕境經濟第三層根修（farming 第一層/A門人口第二層之後）。established 完整解需 A 門也修（另 slice）。
