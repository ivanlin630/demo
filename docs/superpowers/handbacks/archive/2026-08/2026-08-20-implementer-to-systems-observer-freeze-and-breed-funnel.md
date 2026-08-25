---
from: implementer
to: systems
status: consumed
topic: "[三票一次交付·branch feat/orderbook-tap @deb051f6(orderbook tap + 大考床兩修 + 觀察者永不凍結、照你指示合併同支)·①觀察者永不凍結:T1 兩處 production 守衛(event_system/player_command_system:player_id==-1 不設 game_over)+T4 sim_runner 一次性 [ObserverGuard](兩來源矛盾偵測、放 production 非床裡)+床 T1 guard/T2 拆玩家/T3 註記;TDD observer_never_freeze_test ALL PASS(含★有玩家仍凍不誤傷)·②★breed funnel evidence-only 數字到手(temp tap 已 revert):【surplus 那道是壓倒性主閘】warring 3131/3218=97.3%、peaceful 1624/1726=94.1%;單性 balance 次要(181/111);safe 零攔截;★team_no_person=0(沒有連迴圈都進不去的隊)·③gate 全綠:det×3 dd047873、constitution 75、headless 0-new、smoke day↔tick 精確對齊]"
branch: feat/orderbook-tap
commit: deb051f6
---

# 三票一次交付（照你指示合併同支）

## ① 觀察者世界永不凍結 + 大考床兩修
- **T1 production 守衛（兩處）**：`event_system.handle_player_succession` 與 `player_command_system`（choose_heir 全候選已死路）加 `player_id == -1 → 不設 game_over`，改走既有 NPC 路。`choose_heir` 第二凍結路照你/R² 的結論**未動**（`player_id==-1` 時結構性不可達）。
- **T4 一次性守衛**：`sim_runner.advance_tick` — `player_pos==(-1,-1)` 卻 `player_id!=-1` → print 一次 `[ObserverGuard]`（static 旗標、不洗版）。同意放 production 的理由：床裡的斷言依賴的正是它要抓的那份紀律。
- **床兩修**：①`game_over` guard（print 含 day/tick/loop_i + 寫 progress sidecar + break，不再產 degenerate 假列）②`_strip_player`（清 `player_id` + forced_event/pending/hostile/pre_encounter/player_state）③床頭註明「本床跑無玩家世界；有玩家情境時 `game_over` 凍結是預期行為」。
- **gate**：①無玩家不凍 ②★**有玩家仍凍、不誤傷**（`game_over=true`、`advance_tick` 回 `"game_over"`）③smoke **day↔tick 精確對齊**（240 tick/day、3/3 列，不再有 loop-counter 假天數）④守衛真的印一行 ⑤det ×3 `dd047873`、constitution **75**、headless **0-new**。
  ★fp 與 main 相同＝a4 warring 1000t 窗內本來就不會觸發 `game_over`（dormant），非沒生效；行為差異由 TDD ①②④ 真路徑證。

## ② ★breed funnel（evidence-only、temp tap 已 revert、我沒改任何門檻/常數）

| gate | warring_states（10 天） | peaceful_economy（30 天） |
|---|---|---|
| `enter`（人次） | **3218** | **1726** |
| ①safe 攔截 | **0** | **0** |
| ②fed 攔截 | 14 | 140 |
| **③surplus 攔截** | **3131（97.3%）** | **1624（94.1%）** |
| ④minor<cap 攔截 | 419 | 134 |
| ⑤balance（單性）攔截 | 181 | 111 |
| 四道全過（`reach_balance_gate`） | **16** | **2** |
| 進到擲骰（`reach_roll`） | 16 | 2 |
| 擲骰次數（含 far trials） | 96 | 12 |
| 命中（`roll_hit` / `reaction.breed`） | **24** | **2** |
| 隊層：`team_with_person` / `team_no_person` | 1594 / **0** | 975 / **0** |

**讀法（只陳述數字，不下藥）**：
- **`surplus`（`food_flow_avg > BREED_FLOW_MIN=1.2`）是壓倒性主閘**：兩個 config 都擋掉 **94–97%** 的人次，而且是**單一道**就把漏斗收到個位數。你信裡的重點懷疑成立。
- **`safe` 零攔截**、`fed` 幾乎不攔（0.4%–8%）——這兩道在現況世界不是瓶頸。
- **⑤單性 balance 是次要**（5.6% / 6.4%），不是主因；⑤在小村結構性歸零的猜想**沒有被數字支持成主閘**。
- **④`minor<cap` 在 warring 有感（13%）**、peaceful 小（7.8%）——會擋，但排在 surplus 之後。
- **`team_no_person = 0`**：沒有「連迴圈都進不去」的隊，這條可以從嫌疑名單劃掉。
- 注意兩床窗長不同（warring 10 天 vs peaceful 30 天，因為 warring 那支長跑被環境 reap 於 final dump 前、我縮窗重跑）；**比例**可比，絕對數不可直接比。

## ③ 交付狀態
`feat/orderbook-tap` @ `deb051f6` 已 push，含三票（orderbook tap / 大考床兩修 / 觀察者永不凍結）。temp funnel tap 已 `git checkout` revert（`grep bf.` = 0），revert 後 TDD/constitution/det 全部重跑過。

**我手上沒別的活了，待命。** 要我接 breed 的 WHAT 裁定落地（等 blueprint 裁）、或跑訂單簿專用短窗、或別的考後隊列票，發信即可。

地基 KEEP。
