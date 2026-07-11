# Spec — 名聲磁鐵 slice（reputation-driven 自願歸附，技術/systems HOW）

> 願景 = `consolidation-unified-decision-design.md §★★★名聲驅動自願歸附`（blueprint，用戶裁 β 分軸+分階段 2026-07-11）。= consolidation arc 的解答，**繞征服死結**（弱隊自願投奔名聲好的保護傘=pull，不動征服平衡）。本 slice = **閉環 3（決策讀名聲）+ 閉環 2（道德事件喂名聲）**；**閉環 1（gossip 傳播）defer**（磁鐵證有效才投）。屬決策統一 program [[project_unified_decision_framework]]。

## 現況錨點（characterize，file:line 坐實）
- `relation_edges` 型別 = feud/killed/protect/gratitude（`relation_graph:5`）；加邊點已在：`npc_ai:29` feud、`:84` gratitude、`:86` protect。API `RelationGraph.add_edge/strongest/edges_of_type`。
- `known_reputations`（`team_data:187`，per-team dict，clamp 0~1）= **情報信任 + diplomatic 行為混合**（belief `:209/212` intel 準確度 + diplomatic 結盟/背叛）——**非道德/保護名聲**。∴ β 新軸。
- FLEE 決策 `decision_engine:79` = `求生欲*0.8+(threat_react-0.5)*0.3`，**不讀名聲**。投靠 `terms.gd:89 join_drive`、finder `_find_strong_neighbor`，**不讀名聲**。

## §1 新軸 `protector_rep`（β 分軸，per-observer 主觀）
- `TeamData` +`protector_rep: Dictionary`（key=protector team_id，value 0~1，default 0.5，clamp）——**結構鏡射 `known_reputations`，語意獨立**（protector_rep=值不值得投奔/道德保護；known_reputations=情報信任）。
- **★過框架內冗餘 lens**：兩軸語意須明確分（reviewer 驗，正是 β 理由）——別把 protector_rep 當 known_reputations 換皮；一個是「這隊情報準不準」、一個是「這隊值不值得託付」。
- 主觀 per-observer（禁讀全域真值）。

## §2 閉環 2 — 道德事件喂 `protector_rep`（只吃直接經歷，gossip defer）
在既有加邊點（`npc_ai:84/86/29` + killed）**同時**更新**觀察者隊**對 subject 的 protector_rep：
- `protect` / `gratitude`（受助/被護）→ observer.protector_rep[subject_team] **+= REP_GAIN×intensity**（護人→名聲漲）。
- `feud` / `killed`（被害/背叛）→ **-= REP_LOSS×intensity**（背叛→跌）。
- 常數 TEST VALUE：`REP_GAIN`(~0.1)/`REP_LOSS`(~0.15，跌快於漲=名聲難得易失)。
- **★subject→team 映射**：relation_edges 在 person(leader)、subject_id 型別（person or team）**implementer build 時確認**——若 subject=person，resolve 其 team 當 protector key；observer=該 person 的 team。**跑不順標明回 systems**（別猜）。

## §3 閉環 3 — 決策讀名聲（磁鐵發動）
1. **`join_drive`（`terms.gd:89`）× 名聲加成**：`join_drive_final = join_drive × (1 + protector_rep[host] × REP_MAGNET_W)`——高名聲 host → 投靠 util 升（trace 場景 E：逃 1.0 vs 投靠 0.82，掛名聲後高名聲 host 翻盤）。低名聲/中性(0.5) → 加成小/無。`REP_MAGNET_W`(~1.0 TEST VALUE)。
2. **投靠 finder（`_find_strong_neighbor`）偏好高 `protector_rep`**：不只選「強」鄰，選「強 × 名聲好」的保護傘（避免投奔強暴君）。
3. **context**：+`best_protector_id`/`best_protector_rep`（finder 選的高名聲保護傘 + 其 rep），join_drive 讀。
4. FLEE（`decision_engine:79`）本 slice **不改公式**——靠 §3.1 讓投靠 util 升過 FLEE 即可（投靠贏=磁鐵動）。若投靠與 FLEE 不同 rank 集無法直接競（投靠 survival / FLEE threat），build 時確認可達性，卡則標回 systems。

## 守則（blueprint 硬）
- **主觀非全知**：讀 per-observer `protector_rep`，禁全域真值。
- 決策走 rank_scored 真 term；`protector_rep` vs `known_reputations` 語意明確分（冗餘 lens）。
- 複用既有（relation_edges 事件源、known_reputations 結構 pattern），禁重造。
- **不動征服平衡**（暴君照征，仁君靠名聲拉投靠）。

## 驗（measurer 磁鐵測，核心假設）
- **弱隊會不會湧向高 `protector_rep` 保護傘、長出聯邦？**
  - 磁鐵發動（高名聲 host 吸到投靠 dispatch/complete>0、聯邦成形/隊聚合）→ 回 blueprint → 投資閉環 1 gossip。
  - 磁鐵不動（rep 高但投靠仍輸逃/其他）→ 別浪費 gossip，回 blueprint 重估（weight 量級/別卡點）。
- 附觀察：高名聲仁君 vs 低名聲暴君 是否分化「自願聯邦 vs 征服帝國」兩路。
- protector_rep 真波動（脫離 0.5，護/背事件驅）+ gate#1 非搬餓 + determinism + 三端不退化。

## 觸及檔
| 檔 | 改點 |
|---|---|
| `team_data.gd` | +`protector_rep` dict + accessor（clamp） |
| `npc_ai_system.gd`（或加邊點） | protect/gratitude→漲、feud/killed→跌 protector_rep |
| `terms.gd` | `join_drive` × 名聲加成 |
| `faction_ai`（`_find_strong_neighbor`）| finder 偏好高 protector_rep |
| `decision_context.gd` | +best_protector_id/rep |
| `warring_harness.gd` | +protector_rep 波動 / 投靠-by-rep / 聯邦成形 探針 |
