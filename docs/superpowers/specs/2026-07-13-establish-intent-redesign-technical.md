# 立國 redesign：機械 B-gate → 意圖層 argmax（技術 spec）

> WHAT = 用戶/blueprint 定（`s4-merge-establish-redesign-go`；設計方向對話已確認,mirror 建國 A 門 argmax pattern）。established 鏈最後一哩:立國目前純機械四重 AND 閘（不在 argmax），加意圖層——立國成戰略 intent 競 argmax,贏了才進條件,B2/B3/B4 硬閘降 modifier。填 ESTABLISH phase 空偏置。

## 真根（前查坐實，file:line）
- **立國非 intent,是分離機械 gate**：`faction_ai:974-980` 4 條件 AND（B1 members≥2 + B2 統領≥ESTABLISH_COMMAND-disc + B3 野心≥ESTABLISH_AMBITION-0.1 + B4 readiness≥ESTABLISH_READINESS）→ `_emit_goal("立國")` → `:1378 consume → _declare_established:3350`。**不在 `select_strategic_intent:870` 的 6-intent argmax**。
- **對比建國 A 門有 argmax**：`_evaluate_independent_strategy:1197 select_strategic_intent` 建國 intent 競 argmax。**立國缺此層**=條件過就機械觸發（用戶顧慮「降門檻=人人立國」根源）。
- **ESTABLISH phase 零偏置**：`decision_context:140 _phase_option_bias(ESTABLISH)` 回 `{}`——計畫層爬到立國門口不推行動,空手等機械閘。

## WHAT（用戶/blueprint 裁定，固定）
1. **立國成戰略意圖**，加進 faction argmax（由 leader 人格 野心/統領 驅動傾向），跟其他意圖競爭,**贏了才進 B1 結構檢查**（非條件過自動）。
2. **B2/B3/B4 硬 AND 閘 → 立國傾向 modifier/軟門檻**——放寬條件≠人人立國（意圖層先篩想不想）。
3. **填 ESTABLISH phase 空偏置**——爬到此階的隊有實際傾向可推。

## HOW

### §1 立國成 faction argmax 第 7 意圖（`_select_intent:902`）
立國是 faction 級（需 ≥2 成員）→ 加進 **faction 版 `_select_intent`** 的 intent scores（非獨立版 select_strategic_intent——獨立隊走建國先）。
```gdscript
# _select_intent 內,建構 scores 後、argmax 前：
# 立國意圖（僅未立國 + B1 結構最小 ≥2 成員可選;人格×戰備軟驅,取代舊硬 AND 閘）
if not f.is_established and f.member_team_ids.size() >= ESTABLISH_MIN_MEMBERS:
    scores["立國"] = _establish_intent_score(state, f, leader_team, leader_p)
```
`_establish_intent_score`（人格驅動,B2/B3/B4 折入軟秤）：
```gdscript
func _establish_intent_score(state, f, leader_team, leader_p) -> float:
    var cmd: float = float(leader_p.skills.get("統領", 0.0))       # B2 統領（軟)
    var amb: float = float(leader_p.values.get("野心", 0.5))        # B3 野心（軟)
    var rdy: float = leader_team.readiness                          # B4 readiness（軟)
    # 立國傾向 = 野心×統領人格 base × readiness 軟調（低戰備折扣非硬擋）
    var base: float = amb * ESTABLISH_AMBITION_W + cmd * ESTABLISH_COMMAND_W
    var rdy_mod: float = clampf(rdy / ESTABLISH_READINESS, ESTABLISH_RDY_FLOOR, 1.0)
    var score: float = base * rdy_mod
    # ESTABLISH phase 加成（§3）：爬到立國階 → 傾向加成
    if leader_team.plan_phase == DecisionContext.PHASE_ESTABLISH:
        score += ESTABLISH_PHASE_BONUS
    # 承諾 hysteresis（mirror 既有 intent，別每 cadence 翻）
    if f.intent is Dictionary and String(f.intent.get("type","")) == "立國":
        score += ESTABLISH_COMMITMENT_BONUS
    return score
```
- **argmax 贏了才立國**：立國 score 進既有 `_argmax_intent`,跟守成/征服/致富/防衛/擴張競。贏 → `f.intent.type=="立國"` → 執行段 emit 立國 goal（§2）。
- **B2/B3/B4 = 軟 modifier**：統領/野心 進 base（線性貢獻非硬門）、readiness 進 rdy_mod（軟折扣 floor ESTABLISH_RDY_FLOOR,非 0 硬擋）。低值→立國 score 低→難贏 argmax（但非不可能,若他意圖更低）。**放寬:無硬 cutoff,只相對競爭。**

### §2 移除舊硬 gate + 意圖驅動 emit（`faction_ai:974-980` + 執行段）
- **移除 `:973-980` 分離硬 AND 閘**（那段 `if not is_established and members≥2 and cmd≥… and 野心≥… and readiness≥… → emit立國`）。
- 立國 emit 改由 **intent 執行段**（`_select_intent` 選中後,`_evaluate_all_body` 意圖執行處,比照 :1006 征服→emit攻擊 pattern）：`if f.intent.type == "立國": _emit_goal(state, f, "立國", "立國", "野心稱王(intent argmax)", "establish")`。
- `:1378 consume 立國 goal → _declare_established` **不動**（機制末端保留;只是觸發源從硬閘改 intent）。
- B1（≥2 成員）留在 §1 的可選 gate（結構最小,非人格門——<2 隊不成「國」是定義）。

### §3 填 ESTABLISH phase 偏置（`decision_context:140`）
ESTABLISH phase 現空偏置。**改:ESTABLISH phase → 提升立國傾向**（非偏置某 rank_scored option——立國是 goal 非 option）。兩接法擇一（實作評）：
- **A（建議,§1 已含）**：ESTABLISH phase 在 `_establish_intent_score` 加 `ESTABLISH_PHASE_BONUS`（phase 爬到→立國 intent 加成）。`_phase_option_bias(ESTABLISH)` 維持 `{}`（無對應 rank_scored option,由 intent 層接手,誠實）。
- B（備選）：若要 rank_scored option 偏置,需先讓立國成 option（大改,違「立國=goal 非 option」現況）→ 不取。
- ∴ **取 A**：ESTABLISH phase 的「行動」= 提升立國 intent argmax 勝率（phase→intent 接線,非 phase→option）。plan §「爬到立國階有行動可推」由此滿足。

### §4 常數（faction_ai 頂，TEST VALUE）
```gdscript
const ESTABLISH_MIN_MEMBERS: int = 2         # B1 結構最小（沿用 STATE_MIN_FACTION_TEAMS 語意）
const ESTABLISH_AMBITION_W: float = 0.4      # 野心對立國傾向權重（B3 軟化）
const ESTABLISH_COMMAND_W: float = 0.4       # 統領對立國傾向權重（B2 軟化）
const ESTABLISH_RDY_FLOOR: float = 0.5       # readiness 軟折扣下限（B4 軟化,非 0 硬擋）
const ESTABLISH_PHASE_BONUS: float = 0.2     # ESTABLISH phase 加成
const ESTABLISH_COMMITMENT_BONUS: float = 0.15  # 承諾 hysteresis
```
（舊 ESTABLISH_COMMAND=0.4/ESTABLISH_AMBITION=0.7/ESTABLISH_READINESS=0.7 硬門常數：READINESS 保留當 rdy_mod 分母;COMMAND/AMBITION 硬門刪或留備查——實作決。）

### §5 determinism + 統一框架
- `_establish_intent_score` 純算術零 randf;argmax 既有 deterministic → byte-identical。
- **統一框架守**：立國進既有 `_select_intent` argmax（第 7 意圖,同框競秤），**非新求解器**、非 bolt-on gate。移除舊分離硬閘=減一個框外機械 gate（框架整合,更乾淨）。

## 驗收（measurer 產數字，blueprint 判）
1. **★established > 0**：default.json 12mo（或右尺寸）——established 從恆0 → **有 faction 立國**（意圖層+軟門讓有立國傾向的 faction 過）。這是最後一哩核心驗收。
2. **非人人立國**：established 隊 = 立國 intent 真贏 argmax 的（高野心/統領/戰備傾向）,非全部 faction——`intent.sel_立國` vs faction 總數比例合理（少數強傾向 faction 立國,非爆滿）。
3. **B門 funnel 變化**：舊 `establish.gate_fail_b2/b3/b4` 硬 funnel 退役,改看立國 intent argmax 勝率分布（新探針:立國 score vs 其他 intent、勝出率）。
4. **determinism** byte-identical + baseline 位移標記（established 行為變）。
5. **融合閘**：constitution（移舊 gate/加 intent,sites 核）/coin/framework/sanity 綠 + headless 零新增。
6. **plan-layer 不回歸**：ESTABLISH phase 隊真傾向立國（phase→intent bonus 生效）。

## 流程
- spec → **對抗①（R① factcheck）**：premise（立國機械非 argmax/建國 pattern/B門門檻）file:line 坐實核 + 大框框外審（立國進 argmax 是否真統一框架非另立 gate、軟門會否人人立國/或反而沒人立國）→ premise_contradiction→halt。
- → **R②（dispatch 前設計審）** → CLEAN → implementer 疊 worktree `feat/establish-intent-redesign`。
- measurer 驗 established>0（最後一哩）。
- **註**:established 完整還受 pop 成長（繁殖/吸收多路,defer arc）制約——立國入口通了,但要有夠格 faction（≥2 成員+食足）才觸得到立國 intent。若 pop/faction 形成仍卡則標「立國入口通但上游 faction 形成需 pop arc」。
