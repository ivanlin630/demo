# Spec：wave1 序4 — vendetta 溶入引擎（feud_pull 掛攻擊 option）

> arc wave1 序4（wave3 清掃）。承融合模式。**溶=融合非刪**。北極星：vendetta=遭遇的一個結局（血仇→攻擊），朝 encounter 評估收斂。系統 owner。

## 1. 目標
**現況違憲**（constitution-audit 序4）：`faction_ai:733-741` 強血仇→直塞 `TASK_ATTACK`@PRIO_VENDETTA(55)。`feud_pull` term 存在（`terms.gd:91` `ctx.strongest_feud if opt=="攻擊"`）**但未掛進 攻擊 option** REGISTRY → 死 stub。

**目標**：feud_pull 掛進 攻擊 option → 血仇成攻擊 option 的一個 weight 驅力（衝動 leader 血仇高→攻擊贏 rank）；刪 hand vendetta dispatch。

## 2. 現 repertoire（融合驗錨）
`_evaluate_vendetta`（fai:733-741）：`NpcAiSystem.vendetta_target(leader)` → 最強血仇 foe（存在+可見）→ `try_set(TASK_ATTACK, foe.tile_pos, PRIO_VENDETTA=55)` + prosperity_target=foe + `g2.vendetta_trigger` probe。
- **語意**：強血仇 + 衝動 leader（好戰高/慎重低）拉隊打仇人。
- **優先序**：置 `_evaluate_threat` 後 → threat@70 先設 DEFEND/FLEE 則 vendetta@55 搶不動（**威脅 > 血仇**）；vendetta@55 > prosperity@50（**血仇 > 致富攻擊**）。
- **觸發**：idle 隊（loop3，同 threat/ambient 的 idle 語境）。

## 3. 目標架構（優先序→權重序）
融合把「PRIO 覆蓋」翻成「rank 權重」：
- **feud_pull 掛 攻擊 terms** → 血仇 leader 的 攻擊 option util 升 → 贏過 prosperity 的其他 option（血仇 > 致富攻擊 = 權重序，非 PRIO 55>50）。
- **threat > vendetta 由既有 PRIO 保**：threat 仍 loop3 slice、PRIO_THREAT(70) > 引擎 dispatch PRIO_DISPATCH(50) → 被威脅時 threat 反應覆蓋血仇攻擊（威脅優先不變）。
- vendetta 隊多為**獨立**（fid=-1）→ 走 `_evaluate_solo` 的 `rank_scored`（序2 已溶）；feud-攻擊 在其主 rank 競爭。

## 4. 具體改動
### 4a. feud_pull 掛 攻擊 option（options.gd:20）
```gdscript
"攻擊": [["faction_duty", "faction_duty"], ["attack_drive", "attack"], ["intent_fit", "intent_fit"], ["feud_pull", "feud"]],
```
（`feud` weight 已存在 terms.gd `0.3 + 好戰×0.5` = 衝動/好戰染；feud_pull eval 已存在讀 ctx.strongest_feud。兩者現成，只差掛上。）

### 4b. 攻擊 applicable 加 feud 條件（options.gd:87-91）
現 gate 只認 faction_stakes/征服。加血仇路：
```gdscript
"攻擊":
    if ("攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1) \
            or (ctx.intent == "征服" and ctx.intent_target != -1) \
            or (ctx.strongest_feud >= FEUD_ATTACK_MIN and ctx.feud_target_id != -1):   # ★血仇路
        out.append(opt)
```
`FEUD_ATTACK_MIN` = TEST VALUE（血仇強度門檻，防輕微不快即開打）。

### 4c. ctx.feud_target_id（decision_context.gd）
現 `ctx.strongest_feud` 只有 intensity。加 `ctx.feud_target_id`（`NpcAiSystem.vendetta_target` 回的 foe team id，鏡射舊掃描）+ 可見/存在守衛。

### 4d. to_task 攻擊 target 路由（options.gd:160）
攻擊 to_task 現 target=`_nearest_independent`。血仇驅動時 target=feud foe：
```gdscript
"攻擊":
    var _atk_target: int = ctx.faction_attack_target if ctx.faction_attack_target != -1 \
        else (ctx.intent_target if ctx.intent_target != -1 else ctx.feud_target_id)
    # ... target = state.teams[_atk_target].tile_pos, combat_target = _atk_target
```
（多來源攻擊 target 優先序：faction directive > 征服 intent > 血仇。血仇作 fallback target。實作對齊現 to_task 攻擊結構。）

### 4e. 刪 hand vendetta dispatch（fai:733-741）
刪整段。`g2.vendetta_trigger` probe **保留**（改在引擎 dispatch 攻擊-feud 時 bump——用於 framework S2b 驗魂 + 融合驗率表）：dispatch 迴圈判 `opt=="攻擊" and ctx.strongest_feud >= FEUD_ATTACK_MIN and 非 faction/intent 驅` → bump `g2.vendetta_trigger`。

## 5. 融合驗（`vendetta_dissolution_check.gd`）
- **repertoire 沒少**：強血仇（intensity 高）+ 衝動 leader（好戰0.9/慎重0.2）+ 可見仇敵 → `rank_scored` 首選「攻擊」且 target=仇敵。無血仇/溫和 leader → 不攻（feud_pull=0）。
- **優先序保**：①威脅 > 血仇——同隊有血仇 + 壓境威脅 → threat slice(loop3 PRIO_THREAT 70) 覆蓋（DEFEND/FLEE 而非打仇人）。②血仇 > 致富攻擊——血仇隊 攻擊(feud)贏過同隊 prosperity 的其他致富 option。
- **★感知鐵律（北極星）**：feud = 已知關係（`known_reputations`/feud memory），合鐵律（已知宿敵可讀）。仇敵身分經 belief 可見判（vendetta_target 已有可見守衛）。
- **framework S2b**：`g2.vendetta_trigger` 驗魂不 DORMANT（probe 移引擎 dispatch）。
- **回歸**：seeded（漂移允許 QA wave 判）+ framework PASS=7 + threat/solo/rung 融合驗+live-seam 不破 + 憲法閘。

## 6. 憲法閘 baseline
hand vendetta dispatch（fai:735-738 的 `try_set`）在 `_evaluate_all_body`（已在 baseline 指紋）。刪它 → try_set 少一處，但 `_evaluate_all_body` 仍有其他 try_set（vendetta 只是其中一個 call）→ 指紋 func 級不變（同 func 仍有 try_set）。**閘應無變**，實作確認 removed/add。

## 7. 待藍圖 / 後序
- **無新 WHAT 待裁**（vendetta 語意同構，feud_pull/feud 現成）。FEUD_ATTACK_MIN=TEST VALUE 待 wave QA。
- 收斂北極星：vendetta 現成 攻擊 option 的 feud 驅力 = encounter 評估「遇宿敵→攻擊」結局的一步。
- spec → plan → 子 session。序4 綠 → 序5 prosperity（gate cascade→option 競秤，中險，+gen 重校）。
