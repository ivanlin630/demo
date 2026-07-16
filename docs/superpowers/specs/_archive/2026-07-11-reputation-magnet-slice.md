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
- **★subject→team 映射解（build 卡點後 systems 裁）= 呼叫端就地喂**（映射歧義只在 `_write_relation_edge` 內部收 int subject；呼叫端手上有 TeamData object）。**本 slice 2 核心喂點**（team 直接在手，不需 person→team resolve）：
  - `looted`（`npc_combat:~342`）→ `loser.update_protector_rep(winner.team_id, -REP_LOSS×sev)`（massacre 級跌更兇）。
  - `aided_in_battle`（`npc_combat:~357` escort 迴圈）→ `winner.update_protector_rep(escort.team_id, +REP_GAIN×0.5)`（★核心磁鐵信號）。
  - 不碰 `_write_relation_edge`（subject-ambiguous 無 state）；不喂 team-subject 邊際事件（begged/taxed）。2 點足夠讓 protector_rep 脫 0.5 測磁鐵；太平則加 master/kindness 次階段。

## ★§3b rep-選 target（2026-07-11 rev2，磁鐵 inert 修——reviewer 校正我 mis-root）
**★systems 首判錯（reviewer premise_contradiction 抓）**：我原稱「投靠讀 `_find_absorber` same-faction absorber」=**假**。真相（file:line 複核）：**投靠(JOIN) target = `_find_strong_neighbor`（`faction_ai:3238`）**，`_find_absorber` 只餵整併/吸納（`consolidate_target_id`），投靠沒用它。且 `_find_strong_neighbor:3246` **已排除 same-faction=本就跨 faction**（我「same-faction 限致 inert」也假）。
**真 inert 根因**：`_find_strong_neighbor` 已跨 faction，但 **:3247 讀 `known_reputations`（情報信任）+ :3253 選 `best_pop`（最強）**——**不讀 protector_rep、不選護過我的**。∴ 選的強鄰 protector_rep 恆 0.5→磁鐵 inert。
**真修（小，非引新 finder）**：`_find_strong_neighbor` **選擇準則改 protector_rep**（投奔護過我的最佳保護者=§3.2 原意）：
- 保既有 filter（跨 faction :3246 / 可達 :3245 / belief :3250 / 強度 :3252）。
- **★選擇軸參數化（reviewer rev2 抓：`_find_strong_neighbor` 共用，:3422 defection-surrender 也呼——投降要「最強軍事保護」、JOIN 要「最高 rep 仁君」，衝突，systems spec 解不 punt）**：`_find_strong_neighbor(state, team, axis: String = "pop")`——
  - **★JOIN 兩呼叫點都傳 `"rep"`（reviewer 終審盤點，缺一則 gate/target 脫鉤）**：`decision_context:170`（餵 has_strong_neighbor/strong_neighbor_id = `terms.gd:90` join_drive gate + `options.gd:99` 投靠 applicable gate）**和** `options:174`（JOIN target 取值）**都**傳 `"rep"`——否則 gate 判「有強鄰」(pop-strong) vs 實際 target(rep-strong) 選不同隊脫鉤。select → argmax `protector_rep`（tie-break pop）＝投奔護過我的。喂-讀同 pair→非 0.5。
  - `_trigger_defection_evaluation`（`:3422`）**維持 `"pop"`**（best_pop 不變，投降找扛得住的強者）＝行為零變。（reviewer 盤點：共 3 呼叫點，無第 4。）
  - 共用 filter/scan/reachability（跨 faction :3246 / 可達 / belief / 強度 / known_reputations>0.3 sanity），只分流最終 select 準則＝既有函式參數化，非重造/非冗餘。
- **resolver 已跨 faction**（`_resolve_join` `interaction:237` 早於 same_faction `:243`，reviewer 複核確認）→ 不用改。
- **邊界最小版**：只投奔高 rep 保護傘+併入；S-B 政治（叛離後果/怨氣/忠誠/通牒）defer。
- context：`best_protector_rep`（選中 host 的 protector_rep）供 join_drive §3.1 讀。

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

## ★§4 收尾（2026-07-11 blueprint 裁 ship）：gossip 接口 + defer 傳播本體
磁鐵大窗確認活（18-seed **196 次完成** vs 前版 4-19=10 倍跳、跨 faction 自願歸附穩定、mega-blob 受控均 34.67 隊、三端/gate#1 綠）→ **ship**。a/b/c 收掉（consolidation 非世界抗拒，是磁鐵讓它活）。現況「中性 rep(0.5) 無差別投靠」接受為現階段（無名聲資訊時投誰都合理、mega-blob 受控）。
**★留 gossip 接口（核心，別漏；現不建本體）**：
1. **`update_protector_rep` 做成單一可擴充入口**：簽名加 `source: String = "direct"`（直接事件走 "direct"、**未來 gossip 走 "gossip"**）——不假設 source 只能直接事件，未來接 gossip 不用重構 rep 模型。per-observer 主觀（已是）。
2. **message_system 標擴充縫（TODO/seam，不實作）**：`_exchange_intel`（`message_system:182`）/`exchange_intel_on_arrival`（`:145`）附近註明「未來 gossip：相遇交換情報時，也交換對**第三方**的 protector_rep 意見 → 收方經 `update_protector_rep(…, source="gossip")` 更新（複用既有信任 gate + distortion/decay）」。
3. **確保現設計不擋 gossip**：rep per-observer + 入口 source-agnostic = 屆時「擴 message 帶名聲內容」中工非大 arc。
**defer gossip 本體**：完整名聲傳播（loop-1）歸資訊維度後續（Phase D）；接上留好的入口即可。它讓磁鐵從「無差別投靠」→「擇良木而棲（仁君聚望/暴君遭棄）」=名聲靈魂。

## 觸及檔
| 檔 | 改點 |
|---|---|
| `team_data.gd` | +`protector_rep` dict + accessor（clamp） |
| `npc_ai_system.gd`（或加邊點） | protect/gratitude→漲、feud/killed→跌 protector_rep |
| `terms.gd` | `join_drive` × 名聲加成 |
| `faction_ai`（`_find_strong_neighbor`）| finder 偏好高 protector_rep |
| `decision_context.gd` | +best_protector_id/rep |
| `warring_harness.gd` | +protector_rep 波動 / 投靠-by-rep / 聯邦成形 探針 |
