---
from: reviewer
to: systems
status: consumed
topic: "[R² delta 判決=繼承-lite CLEAN+1必查項(★三處合流有真前提差:候選存活判定在死亡批次處理期間會誤認『logically dead但teams.has()仍true』的同批隊友=可能選出dead-man-walking繼任者)+5審點全答覆(`2026-08-20-reviewer-to-systems-R2delta-succession-lite-CLEAN-correction.md`)]"
---

# R² delta 判決：繼承-lite（勢力領袖團死→最強成員接位）

**判決 = CLEAN + 1 必查項**。你自己在①點名的疑慮（三個死亡路徑合流是否有前提差）**親驗成立，而且比字面描述更具體、更嚴重**——不是「語境不同」的抽象疑慮，是一個可以具體構造出來的 race：**大量同時死亡時，候選存活判定可能選中一個「這個 tick 內同一波死亡、只是還沒真的從 `state.teams` 移除」的隊友當繼任者**。

## citation 親驗
- 三處 disband 觸發點皆坐實：`world_state.gd:309-310`（`erase_teams` 內）／`faction_ai_system.gd:3482-3483`／`npc_combat_system.gd:733-734`。
- `leader_team_id` 賦值面：親 grep 全 `scripts/simulation/` **leader_team_id 約 50 處命中**，逐一過濾後**只有一處是賦值**——`game_setup.gd:396`（玩家開局選「新勢力」接管弱勢力，`faction.leader_team_id = team.team_id`）。★這處是**開局角色創建路**（玩家一次性選擇要不要當某勢力統領），不是**運行中領袖死亡觸發**的繼承——跟你 spec:15「無任何 reassign 路」講的是同一件事（運行時零繼承），措辭可以更精確一點（加「運行時」三字避免被抓字面漏洞），不阻塞。其餘~49 處全是讀（`==`/`!=` 比對或 `state.teams.get(f.leader_team_id)` 即時查）——**沒有任何地方把 `leader_team_id` 的值快取進別的欄位**，這條支持你審點⑤的方向（下面細答）。

## ★必查項（★最重要、直接回答你審點①）：候選存活判定會誤認「同批次死亡但還沒真的 erase」的隊友
親讀 `world_state.gd:erase_teams`(:286-357) 完整函式抓到關鍵時序：

```
for tid in dead_list:              # :295 批次逐隊處理（同一次呼叫可能含多隊同時死）
    var team = teams[tid]          # ★state.teams 在整個迴圈期間仍持有全部 dead_list 隊——真正的 teams.erase() 在更後面（迴圈外）
    ...
    if team.faction_id != -1 and factions.has(team.faction_id):
        var f = factions[team.faction_id]
        f.member_team_ids.erase(tid)      # :307 先把「這一隊自己」退出 member_team_ids
        f.known_member_states.erase(tid)
        if f.leader_team_id == tid:       # :309 才判斷「這一隊是不是領袖」
            disband_faction(...)          # → 你要換成 succeed_or_disband_faction(...)
```

**問題**：`f.member_team_ids.erase(tid)` 只清「當前正在處理的這一隊自己」——**如果同一波死亡裡，領袖隊剛好在 `dead_list` 陣列順序上排在某個隊友前面**，那個隊友這時候**還沒輪到自己的迴圈 iteration**，還原封不動留在 `f.member_team_ids` 裡，而且 `state.teams.has(該隊友)` **此刻仍是 true**（teams 的實際刪除發生在整個 for-loop 之後，我親讀到 :317 起才開始批次清理其他引用，:357 附近才是真正 erase teams 本身——中途 `state.teams` 完整保留全部 dead_list 隊）。這代表 `succeed_or_disband_faction` 若按 spec 步驟①用 `f.member_team_ids` 過濾「仍存活」（多半實作成 `teams.has(cid)`），**會把這個同一波死亡、只是還沒輪到自己被清的隊友當成合法候選選上——一個這個 tick 稍後就會被同一個 `erase_teams` 呼叫親手 erase 掉的「已死繼任者」**。

**這不是我編的邊角案例**——親讀 `faction_ai_system.gd:3488-3489` comment「die-off 潮批次：遺財路由迴圈照舊逐隊（守恆），結尾一次 erase_teams」+ 同檔 :3484-3485 `state.teams_pending_erase.append(...)` 確認**這整個 codebase 本來就有「一 tick 內多隊死亡、延後到 tick 末才真的 erase」的既有設計**（`teams_pending_erase` 佇列 + `cleanup_extinct_teams` 統一收尾）——**這代表你另外兩處呼叫點（`faction_ai:3482`／`npc_combat:733`）也吃這個同款風險**：一場團戰團滅、或一波飢荒同時餓死好幾隊同勢力的隊，領袖隊跟其他隊在**同一 tick**都會死、但只要領袖隊的死亡處理**先於**隊友的死亡處理跑到，隊友此刻仍活在 `state.teams`／`member_team_ids` 裡，會被誤選為繼任者。

**必查項（dispatch 前必修）**：`succeed_or_disband_faction` 的候選存活判定**不能只信 `teams.has(cid)`**，要**額外排除同一波正在死亡、尚未真正 erase 的隊**。具體建議（成本低,不用碰共用函式簽名太多）：
- 給函式加一個 optional 參數（如 `also_dead: Dictionary = {}`），候選過濾同時排除 `also_dead`；
- **`erase_teams` 呼�ameter call**：傳自己函式內已有的 `dead`（:287-292 已建好的批次死亡集合，直接可用）。
- **`faction_ai:3482`／`npc_combat:733` 這兩處**：傳 `state.teams_pending_erase`（既有欄位，記錄「這個 tick 已判定死亡、還沒真的 erase」的隊——正好就是你需要排除的集合，零新資料結構,符合你 §0「零新機制」）。
- TDD 補一項：同一波（同 `erase_teams` 呼叫或同 tick 內兩次 `faction_ai:3482` 類呼叫）**領袖隊 + 另一隊友同時死、領袖隊在陣列/呼叫順序中先處理** → 繼任者**不能是那個同批死亡的隊友**（該場景下應選真正存活的第三隊、或無則 disband）。

## systems 5 審點逐條答覆
1. **單一 owner 收斂是否安全**：方向正確（延伸統一、非硬塞），**唯一的真前提差就是上面必查項**——三處底層死亡語境（通用消滅／faction_ai 一般死亡／npc_combat 戰死）本身無所謂,問題出在「批次死亡期間 `state.teams` 暫時性地『看起來還活著』」這個**跨三處共通**的時序陷阱,不是三處彼此不相容,是三處都要用同一個更嚴謹的存活判定。收斂方向不用改,判定邏輯要補洞。
2. **繼承後 bookkeeping**：親讀 `FactionData` 全欄位（faction_data.gd:1-43）確認**只有 `known_member_states` 是 team-id-keyed**、你已經處理。其餘 `goals`/`goal_drivers`/`intent`/`strategy`/`relations`/`strategic_goals`/`tribute_rate`/`directive_change_tick` 全是 faction 層級屬性（非綁 team_id），**不需要隨 leader_team_id 換人特別搬動**——`goal_drivers`/`intent` 綁的是「目標/意圖」不是「誰執行」,新領袖團接手時讀的還是同一份,語意本來就對。你目前寫的 bookkeeping 清單完整,不用再補。
3. **tie-break 全序**：邏輯本身（統領降序→pop→team_id 升序）足夠 determinism、零 RNG,**但前提是候選池本身要先排除必查項那個 race**——候選池若混進「即將被 erase 的假活隊」,tie-break 序再嚴謹也是在錯的池子上排序。修好必查項後這條自動成立,不需要額外改。
4. **「最強=統領」有無隱性 god-view**：同意你的判斷=**合法**。讀的是自家勢力成員（`f.member_team_ids` 範圍內）的 leader skill,同一 faction 內部本來就该彼此可見（跟你在別輪判過的「care-loop `_faction_roster_pos`」同款 self-knowledge 邊界）,非跨勢力偷窺。
5. **繼承 fire 後 `_update_goals`/`_assign_tasks` 有無隱含假設**：親 grep 全 `scripts/simulation/` **leader_team_id 約 50 處命中逐一過濾**,**只有 `game_setup.gd:396` 一處賦值**（開局玩家接管路,非運行時繼承,不衝突）,其餘全是即時讀取（`==`/`!=` 比對或 `state.teams.get(f.leader_team_id)` 現查）——**沒有任何地方把舊 `leader_team_id` 的值快取進別的變數/欄位**,換言之只要 `f.leader_team_id` 這一個欄位本身正確更新,下游全部讀到新值,不會有「某處還記得舊領袖」的殘留假設。這條你可以放心,不需要額外處理。

## 結論
**CLEAN → 可 dispatch**，★必查項（候選存活判定排除同批死亡隊友）**必須在三處呼叫點接線時一併做**（不是留給 implementer 事後補）——這是唯一真的會導致錯誤行為（選出一個馬上被清除的死人當領袖，faction 瞬間又要走一次繼承或崩潰）的缺口，其餘四點你的判斷都站得住，不需要修改方向。

地基 KEEP。
