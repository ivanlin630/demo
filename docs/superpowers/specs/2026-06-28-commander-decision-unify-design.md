# 統一統領決策 — `_update_goals` 多閾值並行 → 單一連貫戰略姿態（統一 arc 另一半）

> 系統 HOW spec。承藍圖 ruling `2026-06-28-...-unify-commander-decision`（真根=統領層仍多閾值 latch，不要 war-priority OK繃，直接統一統領決策）。
> 統一決策框架 arc 的**另一半**：隊層已統一（DecisionEngine），統領層 `_update_goals` 仍舊病。**排玩家面之前**（連貫派系=玩家在霧裡讀的對象）。

## 真根 + measure 基準

`_update_goals`（faction_ai:632-712）= **多閾值並行 append**：徵收/立國/外交/攻擊/掠奪 各算分過閾值**全發** → 同時下矛盾令。

**measure-first 基準**（`commander_directive_measure.gd` merge `8c6781d`）：各 persona leader 同發 stakes 數——好戰/貪婪/野心霸主=**4**（徵收+外交+攻擊+掠奪）、溫和/均衡=**2**（徵收+外交）。**每 persona 皆 ≥2 矛盾令**=普遍病非邊際。P4 撞的「打+談矛盾」是此症狀；war-priority（成員側 1.5>1.0）只掰成員端、統領仍下矛盾令=OK繃。

= 整條 arc 在殺的同隻病（決策不統一、latch 互搏），隊層修了統領沒遷。

## 裁定（藍圖）：統領跑統一引擎原則 = 單一連貫姿態 argmax

統領每 cadence 秤戰略姿態當競爭 option（utility argmax），挑**一個主姿態**，非並行閾值。

## 範圍

**做**：refactor `_update_goals` 從多閾值 append → **單一姿態 argmax**（persona-weighted utility + belief + 承諾 hysteresis）。輸出 `f.goals = [單一姿態]` → 成員照 P3/P4 混合協調響應（單令=無打+談矛盾）。

**姿態集**：`{守成(default), 攻擊, 徵收, 外交}`。
- **掠奪移除**（ruling=日常個體）：team-level P1 `掠奪` option 已覆蓋機會打劫；統領不另下掠奪令。
- **立國 = 分離的成長 gate**（非競爭姿態）：未立國+ready → `_declare_established`（precondition，established 後才有姿態競爭）。
- **結盟 ⊂ 外交**（diplomacy→alliance）。**大徵收 = 徵收**（強度）。

**非目標**（明文）：
- **不碰成員側 P3/P4 option**（攻擊/徵收/外交 engine option 原樣；只改統領「下什麼令」）。
- **不碰 `strategic_ai._update_faction_goals`**（expand/defend/trade_net 另層，ambition 衍生，本塊不動）。
- **不做成熟派系並行軌**（多戰線 = P3 擴充軸 #3 制度化，藍圖明定未來；現在=單一姿態）。
- **緊急徵收（food emergency）保留為 override**（survival 級，非姿態競爭——餓了必徵糧不論姿態）。
- 不新 TASK_*、不改 f.goals 消費端（leader dispatch 739-771 / member 802-827 / unified faction_stakes 仍讀 `X in f.goals`，單令照樣 work）。

## 設計：`_update_goals` 重構

### 結構（取代 632-712 多 append）
```
_update_goals(state, f):
    1. player_goal_override → f.goals=[override]（保留）
    2. 立國 gate（未 established + 統領/野心/readiness）→ _declare_established（分離，不入姿態 argmax）
    3. 緊急徵收 override（food < emergency）→ f.goals=["徵收"]、strategy="緊急徵收"、return（survival 級，不競爭）
    4. ELSE 姿態 argmax：
        score 每姿態 = Σ(人格權重 × 驅力) + 承諾 bonus(== f 現姿態)
        argmax → f.goals = [姿態]（守成 → f.goals=[] 或 ["守成"]，無 stakes 令）
```

### 姿態 scoring（persona-weighted + belief + 條件 gate）
| 姿態 | 驅力（utility 輸入） | 人格權重 | gate（條件） |
|---|---|---|---|
| **攻擊** | belief 敵弱 + readiness | 好戰/野心（既有 attack_score 0.4野心+0.4好戰-0.4義氣）| established + 有獨立 target + readiness≥MIN + own_armed≥敵×0.8（既有 belief gate，**保留**=吃 belief 非真相 WHAT#4）|
| **徵收** | 戰爭基金需求（material 低）| 貪婪/好戰 | established + 有更富 member |
| **外交** | 有獨立鄰 | 義氣/計謀 | established + readiness≥diplo_min + 有獨立 |
| **守成** | default base（知足）| 慎重/低野心 | 恆候選（無 stakes 條件時的 fallback）|

> 量級對齊：argmax 選最高。好戰霸主→攻擊姿態勝；貪婪→徵收；義氣/計謀→外交；慎重低野心→守成。**姿態選擇即染人格**（WHAT#3，不只執行染）。複用既有 attack_score/loot_score/diplo gate 的條件，重組為 scoring 而非並行 append。

### 承諾 hysteresis（WHAT#2，統領層最該硬）
- `f.strategy`（既有 String）或新 `f.posture` 存當前姿態。argmax 時對「== 現姿態」加 `COMMANDER_COMMITMENT_BONUS`（> 隊層 COMMITMENT_BONUS 0.3，戰略承諾更硬）。
- 一旦 committed 開戰，材料情勢無實質變 → 不翻（防 攻擊↔外交 每 cadence 抖=churn 病統領版，戰略反覆最蠢）。
- 釋放：姿態條件 gate fail（如敵消失/readiness 掉）→ 重 argmax；belief 變（敵顯強）→ 攻擊姿態自然落選。

### war-priority OK繃移除（藍圖明定）
單一姿態後，成員一次只見一個 stakes 令 → P3/P4 的 `FACTION_DUTY_DRIVE` vs `FACTION_DUTY_DRIVE_LESSER` 區分 **moot**（無同時多 stakes 競爭）→ **revert** `FACTION_DUTY_DRIVE_LESSER`（徵收/外交 drive 回 1.5 = 全 stakes 等量級，由統領單令決定哪個 active）。不留死 OK繃。

## believability（守 ruling 5 規格）
1. **單一主姿態**：統領挑一個（攻擊 xor 徵收 xor 外交 xor 守成），外交=不打時才做、守成=default。✓
2. **承諾 hysteresis**：統領不每 cadence 翻姿態（commitment bonus）。✓
3. **姿態吃人格**：好戰→攻擊、貪婪→徵收、義氣/計謀→外交、慎重→守成。✓
4. **吃 belief 非真相**：攻擊姿態用 belief 敵強度（既有 gate 保留）。✓
5. **並行軌=未來**：單姿態 now，多戰線=制度化擴充（P3 軸#3）標願景債。

→ **成員端無打+談矛盾**（統領下單令）→ P3 跟戰自然 3/4（不需 war-priority）。

## 驗收
- **單令**：`commander_directive_measure` 重跑——各 persona 同發 stakes 數 **4/2 → 1**（守成 leader=0 stakes，純守）。好戰霸主→[攻擊]、貪婪→[徵收]、義氣→[外交]、溫和→[守成/空]。
- **姿態吃人格**：好戰 vs 商業 leader 姿態分歧（攻擊 vs 外交/守成）。
- **承諾 hysteresis**：連續 cadence 姿態不抖（committed 開戰隊不每 tick 翻外交）。headless 多 tick 驗姿態穩定。
- **緊急徵收 override**：food<emergency leader → 不論姿態強制徵收（survival）。
- **立國分離**：未 established + ready → 立國（established 後才姿態競爭）。
- **P3/P4 不回歸**：`p3_war_scenario` 跟戰 **3/4**（統領單令攻擊→成員響應；war-priority 移除後靠單令非 drive 分級）。P4 徵收/外交 member 測：directive 單一時仍響應。
- **non-unified 不變**：802-827 讀 f.goals 單令照樣 dispatch。
- **war-priority 移除**：`FACTION_DUTY_DRIVE_LESSER` revert，全 stakes drive 1.5；headless 驗無回歸。
- **守恆 + 魂驗**：coin_eq 0、InvariantAudit 0、framework S1-S6 PASS（S1 立國/S2 feud 仍 fire）。
- **world_sim**：2yr 不崩、派系下單令（無同發矛盾）、戰略姿態穩（無反覆）、攻擊仍稀有（多數派系守成/外交/徵收）。

## 檔案
- `scripts/simulation/faction_ai_system.gd`：`_update_goals` 重構（多 append→單姿態 argmax + 緊急徵收 override + 立國分離 + 承諾 hysteresis）。可能抽 `_score_posture` helper。
- `scripts/data/faction_data.gd`：可能 `f.posture` 欄（或複用 `f.strategy`）存承諾姿態。
- `scripts/simulation/decision/terms.gd`：revert `FACTION_DUTY_DRIVE_LESSER`（徵收/外交 drive 回 FACTION_DUTY_DRIVE）。
- `docs/invariants.md`：「隊目標單一 owner」/「混合協調」段更新——統領下**單一連貫姿態**（非並行閾值）；姿態 argmax + 承諾；掠奪=日常個體非統領令。
- `scripts/debug/headless_test.gd`：新測（單姿態 argmax + 人格分歧 + hysteresis + 緊急徵收 override + 立國分離 + war-priority 移除不回歸）。
- `scripts/debug/commander_directive_measure.gd`：重跑驗 4/2→1。
- `scripts/debug/p3_war_scenario.gd`：跟戰 3/4（統領單令版）。

## 風險 + 緩解
- **P3/P4 回歸（移除 war-priority + 改統領令）**：統領單令攻擊 → 成員響應攻擊（無外交競爭）→ 跟戰 3/4 by construction（非靠 drive 分級）。驗：war_scenario + P3/P4 測。**war_scenario 需確認統領單令模式下仍構造出攻擊姿態**（leader 好戰→攻擊姿態，給弱敵 belief）。
- **承諾 hysteresis 過硬/過鬆**：過硬=情勢變不調（敵強了還打）；過鬆=抖。`COMMANDER_COMMITMENT_BONUS` TEST VALUE + gate fail 釋放（敵消失/belief 變）。world_sim 量姿態穩定度 vs 適應性。
- **緊急徵收 vs 姿態邊界**：food emergency override 必須在姿態 argmax 前（survival 優先）。確認不被姿態蓋。
- **立國時機**：立國分離後，未 established 派系不參與姿態競爭（只成長）→ 確認立國 gate 不被姿態邏輯吃掉。
- **scope sprawl**：明文不碰成員 option / strategic_ai / 並行軌 / TASK_*。只 `_update_goals` 重構 + faction_data 一欄 + terms revert + 測。
- **掠奪移除影響**：統領不下掠奪令 → 機會打劫全靠 team-level P1（unified 隊）；non-unified 軍隊的掠奪？確認 P1/team 層覆蓋，否則記 backlog（非本塊擴）。

## 開放細節（plan 定）
- `f.posture` 新欄 vs 複用 `f.strategy`。
- 姿態 scoring 量級（複用 attack_score/loot_score 公式重組）。
- `COMMANDER_COMMITMENT_BONUS` 值（> 0.3）。
- 守成姿態 = f.goals=[] vs ["守成"]（消費端容忍空？確認 leader dispatch/member 無令時 fallback 正常）。
- 掠奪 non-unified 覆蓋確認。
- war_scenario 統領單令模式重構（leader 直接好戰→攻擊姿態）。
