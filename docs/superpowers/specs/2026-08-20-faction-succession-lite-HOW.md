# 繼承-lite：勢力領袖團死→最強成員接位（HOW / systems）

status: DRAFT→R²delta（2026-08-20）
owner: systems（HOW）← 用戶裁定 2026-08-15（考古 batch1 開放問題②）：**暫行斬首解散→簡易繼承先行**：領袖團死→**成員最強者接位**（統領最高／平手 pop）、**disband 只在無成員團時**、**零新機制**、爭位=王朝 arc 疊加。排程=settlement 核心後、**12mo 大考前**。

## §0 命門
- **零新機制**：只用既有 `f.member_team_ids` + 既有 leader skill 讀取；**不新增資料結構/旋鈕**。
- **★單一 owner（延伸統一）**：現有**三處**各自 disband（`world_state.erase_teams:309-310`／`faction_ai:3482-3483`／`npc_combat:733-734`）→ **收斂成一個 `WorldState.succeed_or_disband_faction(faction_id, dead_leader_tid)`**；三處改呼它（避免三份繼承邏輯各自漂移=未來事故源）。
- **感知鐵律**：勢力內部接班=**自家人資料**（`member_team_ids` + 自家成員 leader skill）=self-knowledge、**非 god-view**。
- **determinism**：挑選須全序 tie-break（見 §2）、零 RNG。
- **fp intended-change**（勢力不再斬首蒸發=行為變）。

## §1 現況（grounded、窮盡）
- **disband 觸發（leader_team 死）三處**：`world_state.erase_teams:305-310`（**主 chokepoint**：`f.leader_team_id == tid` → `disband_faction`）／`faction_ai:3482-3483`／`npc_combat:733-734`。
- **`leader_team_id` 賦值面**：`world_state:122`(create_faction) + `game_setup:396`（初始化）→ **無任何 reassign 路**（=考古坐實「勢力零繼承」）。
- `disband_faction`(world_state:132-140)：清全成員 `faction_id=-1` + `factions.erase`。

## §2 Task
### T1 `succeed_or_disband_faction`（單一 owner）
- 位置：`WorldState`（與 `disband_faction`/`set_team_faction` 同層、既有雙向維護單一入口慣例）。
- 邏輯：
  1. 候選=`f.member_team_ids` 中**仍存活且非死者**的隊。
  2. **無候選 → `disband_faction`（現行為）**。
  3. **有候選 → 選最強者**：`統領`（該隊 leader 的 `skills["統領"]`、無 leader→視為 0）**降序** → 平手取 **population 大** → 再平手取 **team_id 小**（**全序、determinism**）。
  4. `f.leader_team_id = 勝者 tid`；**bookkeeping**：清 `f.known_member_states[死者]`（既有 erase 路已做則不重複）、保留 goals/directive（**不重置勢力意圖**=繼承不是重新開局）。
  5. `print("[Succession] 勢力%d 領袖團 %d 死 → %d 接位")`（既有 `[Succession]` 慣例、觀測性）。
- **三處改呼此函式**（erase_teams / faction_ai:3482 / npc_combat:733）。

### T2 觀測
`Probe.bump("faction.succession")` / `("faction.disband_no_heir")`（分流可見、gate 用）。

## §3 gate（measurer bounded）
1. **勢力不再因斬首蒸發**：領袖團死且**有成員**→ 繼承 fire、faction 續存（`faction.succession > 0`）；**無成員**→ 仍 disband（`disband_no_heir`）。
2. **繼承後勢力仍運作**（goals/assign_tasks 不炸、新領袖團接手 directive）。
3. **determinism** 三跑 byte-identical（tie-break 全序）。
4. constitution 不回升、headless 0-new、既有 slice 不破。
5. **★12mo 大考觀察項**：宏觀興衰是否因此可見（先前「斬首即崩」讓勢力層故事幾乎不存在）。

## §4 界外
爭位/內戰/繼承正當性=**王朝 arc**（用戶明示疊加、本 slice 不做）。首都/遷都=界外。

序：R² delta → CLEAN → dispatch → gate → merge。地基 KEEP。
