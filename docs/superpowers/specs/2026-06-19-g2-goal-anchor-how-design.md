# G2 目標錨 — 系統 HOW 設計

> 配對藍圖 WHAT spec `2026-06-19-g2-goal-anchor-design.md`。本 doc = 系統解 §8 移交的 HOW 決策點 + seam 架構 + 子 spec 拆解。WHAT 不在此 drift（願景回藍圖 doc）。
> 走查依據：現有三套 goal 已量（npc_ai_system goals / strategic_ai_system / faction_ai）。

## 0. 統一 seam 一句話

**leader values → 隊野心狀態(rung+archetype，單一真值源) → 衍生 faction/strategic/team 行為。** 個人關係目標(復仇/守護)疊在其上作偏置/脫軌。三套 goal 收斂到此單鏈。

## 1. 現狀錨點（接入面）

- `strategic_ai_system._update_faction_goals`(:42-68)**已有** faction-leader values→strategic_goals 雛形（expand/defend/trade_net），但 faction 級、扁平無階梯、每 tick 重建。→ **重構**為讀階梯狀態。
- `npc_ai_system.get_goal_task_override`(:93)**dormant 無 caller**，形狀=per-person goal→task 覆蓋字串。→ **接入**（給 caller + 擴充讀階梯/圖）。順解框架債 dormant 項。
- `npc_ai_system.check_goal_alignment`(:64) loyalty nudge → **保留**（成員摩擦 §6 復用）。
- `person.relations` 扁平 `{pid:float}`（npc_ai:33）→ **升 typed-edge 圖**（G2a）。
- `person.goals` 多重 birth(per-value) + 記憶觸發 → birth 餵 archetype/封頂；關係型遷圖。

## 2. G2a — typed-edge 關係圖 schema（基礎縫）

### 結構
`PersonData` 新 `relation_edges: Array`（取代擴充 `relations` 語義；migration 見下），每邊：
```
{ "type": String, "target": int, "intensity": float, "tick": int }
```
經純函數 helper `RelationGraph`（仿 `AnonCohort` 模式，邏輯不散落）操作：
- `add_edge(p, type, target, intensity, tick)`（同 type+target 已存在 → 取 max intensity / 更新 tick）
- `edges_of_type(p, type) -> Array`
- `edges_to(p, target) -> Array`
- `strongest(p, type) -> Dictionary`（intensity 最高，無回 {}）
- `decay(p, rate)`（選用，intensity 隨時間衰減；TEST VALUE）

### 硬約束達成（§4）
- **核心不知型別**：helper 只按 `type` 字串 filter，加型別 = caller 用新字串 + 寫對應 reader，**圖核心零改**。✓
- **G2 只填/讀**：`feud` / `killed` / `protect` / `gratitude`。
- **可塞未來型別**（不建只留骨架）：`kin`/`parent`/`child`/`spouse`/`master`/宗教/結拜——schema 同型，未來加 reader 即可。
- **血仇傳播**（G2d）：殺 X → X 親族/同夥 `add_edge(feud, killer, intensity, tick)`。「親族」此階用同隊 named 近似（家族樹是縫後續內容，G2 不建）。

### migration（扁平 → 圖）
舊 `relations{pid:float}` = 泛好感（write_memory `_update_relations` 高頻寫）。兩條路（G2a plan 決）：
- (a) 保留 `relations` 純量泛好感（loyalty/反應用），**新增** `relation_edges` 只放 typed。兩結構分職，churn 小。← 傾向
- (b) 全收進圖（泛好感 = `type:"affinity"` 邊）。純，但 write_memory 高頻 + 既有 reader 全要改，churn 大。
傾向 (a)：泛好感與 typed 關係語義本就不同（一個是連續情感、一個是事件型邊），分開不違「單一圖」精神（圖指 typed 關係事實）。G2a plan 釘。

## 3. G2b — 隊野心階梯狀態 + 統一 seam（核心）

### 狀態存哪
**存 `TeamData`**（leader=隊的人生 → 每隊一份）：
- `ambition_rung: int`（0=生存…4=稱霸，當前實際所在階）
- `ambition_archetype: String`（"武力"/"商業"/"定居"，由 leader values derive，換 leader 重算）
- `ambition_cap: int`（終極野心封頂階，由 `leader.values.野心` derive）
- 換 leader（死/替/分裂）→ 重 derive archetype/cap、rung 不重置（繼承當前實力位置）但方向變。emergent drama。

### rung 升降（§3.3）
- 每階一個**最低安全門檻**（餘糧/基地/兵力，全 TEST VALUE）。不到不升；安全崩 → 退階（可退回生存）。
- 門檻**之上**步調由個性：高野心/低慎重 → 躁進（搆到就過度擴張，可能自崩）；高慎重 → 鞏固（遠超才動）。
- 評估點：cadence（如沿用 `STRATEGIC_INTERVAL` 或 faction_ai 既有 cadence），讀**隊安全指標 + leader 個性**。

### archetype derive（§3.2，§8）
從 leader values 側寫（非新欄位）：`野心/好戰→武力`、`貪婪→商業`、`義氣/慎重→定居`。混合側寫決勝 = 最高分軸（TEST VALUE 權重；平手 tie-break 釘一序）。

### 統一接線
- **strategic_ai `_update_faction_goals` 重構**：不再 raw value 計分；改讀 faction-leader team 的 `ambition_rung + archetype` → 映射 strategic_goals。faction 行為 = faction-leader 階梯的衍生。
- **`get_goal_task_override` 接入**：faction_ai 隊任務決策處（survival/prosperity 評估鏈內，**優先序低於生存**——絕境仍先活，§參戰意志同理）加 caller：`var ov := NpcAiSystem.new().get_goal_task_override(state, leader)`；非空且當前無更高優先 task → 採用。擴充 override 讀 `team.ambition_rung + archetype + 關係圖強邊`。
- 優先序：生存(survival) > 私人脫軌(強 feud+衝動) > 階梯常態行為 > 既有 prosperity/idle。釘進 task 仲裁（接 known_issues #8 task 仲裁意識，但 G2 不做完整仲裁，只插一層）。

### rung → 行為映射（§3.2 表 × §8）
每 (rung, archetype) → 既有 `TASK_*` / `faction.goals` tag 集合。骨架（TEST VALUE，細節 G2c）：
- 生存/積累（通用）→ TASK_FORAGE/PRODUCE/TRADE/REST 攢資源人。
- 擴張：武力→TASK_ATTACK/LOOT(征服)；商業→TASK_TRADE+設據點；定居→開墾/招民(TASK_PRODUCE+招募)。
- 立國/稱霸：對應 faction strategic_goals(expand/trade_net/治理) 強度與目標選擇。

## 4. G2c — archetype 分岔（rung×archetype → task/tag 全表）
G2b 落骨架後，G2c 填滿三走法 × 五階的 task/tag 映射 + 餵 ②G1 不同需求（武力要武器、商業要貨/商路）。社會身份調制留 ④Trait（G2 不碰）。

## 5. G2d — 私人驅動疊加 + 血仇傳播
- 讀 G2a 圖強邊（feud/protect）：弱 → 偏置（不改 rung 方向，調對象，擴張優先挑仇人邊）；強(高 intensity)+衝動(好戰高/慎重低) → 脫軌（override 拉全隊打仇人，覆蓋階梯常態，但**不覆蓋生存**）。
- 血仇傳播：`_kill_named_npc`/death 鏈 → 對死者同隊 named `add_edge(feud, killer, ...)`。

## 6. 情報綁定（§5，貫穿）
階梯**對象選擇**（挑誰擴張/復仇）只讀 `team_intel`/`team_known`，**禁讀 `team_discovered` 作真值**（僅可見性）。挑對象的 helper 走 intel。→ ③G3 上線即消費者。G2 階段 intel 殘缺即用現有 team_known。

## 7. §8 決策點對照（移交回覆）
| §8 項 | HOW 裁定 |
|---|---|
| 三套 goal 統一 seam | leader→隊階梯狀態(TeamData)→衍生；strategic_ai 重構讀階梯、override 接入 |
| typed-edge 圖 schema | `RelationGraph` helper + `relation_edges` Array；核心按 type filter，加型別零核心改 |
| 階梯門檻閾值 | TEST VALUE，存 const/config，正式平衡 pass 調 |
| rung→TASK_*/tag 映射 | G2b 骨架 + G2c 全表（三 archetype 分岔） |
| archetype 判定 | leader values 最高軸（野心/好戰→武力、貪婪→商業、義氣/慎重→定居），TEST VALUE 權重 |
| get_goal_task_override 接 vs 重寫 | **接入**（形狀對，補 caller + 擴充階梯/圖讀），不重寫 |
| 升降/冒進/脫軌個性公式 | TEST VALUE（野心/慎重/好戰 權重），G2b(升降/冒進) + G2d(脫軌) |

## 8. 子 spec 拆解（依賴序，各自 land + 回歸閘）
1. **G2a 關係圖 schema** — RelationGraph + relation_edges + migration + 血仇傳播 hook 預留。無行為改（純結構 + reader），最先。
2. **G2b 階梯狀態 + 統一 seam** — TeamData 欄位 + derive + 升降 + strategic_ai 重構 + override 接入 caller。核心，依賴 G2a（脫軌讀圖）但可先接骨架。
3. **G2c archetype 全表** — rung×archetype→task/tag 填滿。依賴 G2b。
4. **G2d 私人驅動 + 血仇傳播** — 偏置/脫軌 + feud 傳播。依賴 G2a+G2b。

## 9. invariants（落 invariants.md，隨子 spec）
- **隊目標單一 owner = leader 野心狀態**（`TeamData.ambition_*`，由 leader values+安全 derive）；strategic/faction 行為為衍生，禁他處獨立定隊目標。換 leader → 重 derive。
- **關係圖核心型別無關**：`RelationGraph` 只按 type 操作；加型別 = 加 reader，不改核心。typed 關係事實只經 RelationGraph 寫。
- **目標決策只讀殘缺情報**：對象選擇讀 team_intel/team_known，禁 team_discovered 作真值。

## 10. 回歸閘（承藍圖 §9）
headless 1000+ tick 無錯 + coin_eq=0(4 config)；行為可見 log（多階弧 / 兩型勢力 / 脫軌 / 情報誤判）；Graph/goal 改不破 coin/pop 守恆。不用 multi drift。
