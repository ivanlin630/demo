---
from: implementer
to: systems
status: consumed
slice: monotonic-team-id
topic: team_id 永不重用 DONE — 七份收斂成一個出生口、gate7 做成機械閘、六項稽核逐條有證；★fp 說法要精確（不是「必變」）
branch: feat/monotonic-team-id
commit: eacdd5df
---

# team_id 永不重用（單調遞增）

## §3.0 前置（你說「這是前置，沒過下面都白做」）
- **七份 `_next_team_id` 全刪**：`grep -c "func _next_team_id" scripts/` ＝ **0**（本刀）／main 仍為 7（尚未 merge）。
- **十處呼叫端**全部改走 `WorldState.consume_next_team_id()`——**一個動作**，不是「七處各讀同一計數器」。
- 分配器附**防禦性 floor**：若 state 內已有 ≥ 計數器的 id（未來存檔載入忘同步）→ 抬過去並 `Probe.bump("teamid.floor_bump")`
  ⇒ **看得見地自我修復，不靜默撞號**。

## gate 7：★做成閘，不是做成約定
`.claude/hooks/expect-min-gate.sh`：
- `TEAM_ID_GEN_MAX` **7 → 0**
- 新增 **pattern 閘**（awk：同一函式內 `for … in state.teams` 後 5 行出現 `return <var> + 1`）
  ⇒ **就算不叫 `_next_team_id` 也擋得住第 8 份**。
- 自驗：**本刀 0 / main 7**（閘固定 `cd` 到 main repo，所以 merge 前紅燈是預期，merge 後自動轉綠）。
- ★這條閘**不會誤殺 person id**：判準綁死「掃的是 `state.teams`」。

## §3 六項稽核（逐條結論，負斷言附窮盡證據、無 head 截斷）

| # | 項目 | 結論 |
|---|---|---|
| 1 | id 連續／緊湊假設 | **無**。全樹符合 `range(...size())`/`teams[i]` 型樣只有 2 檔 4 行，索引的是 `member_teams` / `subteams` **陣列**，與 id 無關 |
| 2 | id 上界／位元遮罩 | **無固定大小容器或遮罩**。12 筆 `1 << 30` 全是距離/tiebreak 哨兵；其中 `goal_resolver:474/493` 的 `best_id = 1<<30` 假設 id < 2^30——每次出生只 +1，**實務安全**（要撞需 10 億次出生） |
| 3 | 其他 `max(id)` 語意依賴 | 22 行全在那七份產生器內；**唯一例外 ＝ `game_setup._next_person_id`（`:435-439`）＝ person id 的同族重用**。★**不在本 slice 範圍、我沒動它**——但它會讓 person 的故事也被縫接（PersonData 身分同樣以 id 為鍵）。**要不要開票你裁** |
| 4 | 存檔／載入 | ★**全樹沒有存檔/載入路徑**：`ResourceSaver`/`store_var`/`save_game`/`load_game`/`to_dict`/`from_dict` 在非-debug code 命中 **0**（唯一 `FileAccess.WRITE` 是 `observer_main.gd:224` 的文字 dump）。∴ **今天不可能載到 stale 計數器**；未來有 loader 時由 floor guard 兜底（gate 2 目前**無對象可驗＝空過，我照實記，不宣稱通過**） |
| 5 | 負區段相撞 | **不可能**：`next_beast_id` 由 **-1000000 往下**、team id 由 **0 往上**（`beast_system.gd:22-23`） |
| 6 | fingerprint | 見下 ★精確版本 |

## ★fp：要精確，不能寫「intended-change 必變」
det×3 ＝ **`8ab0ce8f2c8a1acc385cdce95e326c68`**，**與 main 相同**。
原因：**a4 warring 床那 1000 tick 剛好沒有「高 id 隊先死、之後才有新生」** ⇒ id 序列不變 ⇒ fp 不變。

∴ 正確記法（★兩個方向都別寫錯）：
> **fp 只在「有隊死在新生之前」的世界會變；a4 床恰好不觸發，故 det 與 main 同 fp。**
> **這不等於「本刀沒有行為改變」**——convoy 世界就變了（見下 dispatch 7 → 4）。

## gate 3（三處消費端失真）——★在**真的會重現**的世界驗

main 世界 trips 太少（before/after 都是 1–2 趟、本來就一致）證不出東西，
所以我另開 scratch worktree：**同一個 convoy 世界基底（`fa8c3072`）只差本刀**（守你「同 commit 對照」的紀律）。

| 同一世界 peaceful/seed1337/75d | before（id 重用） | after（單調 id） |
|---|---|---|
| specimen `team 12` | n 65、窗 2400**→8160**、**`max_gap 2740`** | n 44、窗 2400**→4560**、`max_gap 60` |
| 第二條命 | **被縫進 id 12** | ★**自己的 id 13**（7300→8160、`max_gap 60`） |
| 全部 traced 隊的 `max_gap` | 最大 2740 | **全部 60**（＝一個 heartbeat cadence，無空白） |
| 床 | `porters_tracked 3` vs `dispatch 7` | **`porters_tracked 3 / trips_total 3`（自洽）** |
| `_ever_in_scope` 假涵蓋 | 可能（同號碼不同隊） | **結構上不可能**（號碼不再重用） |

★**仍有一筆我不掩蓋**：after 這輪 `convoy.dispatch = 4` 但床記 `trips_total = 3`（差 1）。
床是**逐 tick 掃到才算**，若某趟在被掃到前就結束（或那是 `kind=invest` 的 convoy）就會少算——
**這是床的取樣特性、不是 id 問題**，但我不宣稱「完全一致」。

★另外：after 的世界本身變了（`dispatch 7 → 4`）——**這正是 fp 會變的那類世界**，符合上面的精確說法。

## 其餘 gate
TDD `monotonic_team_id_test.gd` **9/9 PASS**（最高 id 死掉不撿回／全滅不回頭／floor guard 有 tap／beast 不相撞／真實 `SubteamSystem.dispatch` 連派＋子隊死後再派不撿號）
｜憲法 **PASS 74**｜headless **0-new**（3 FAIL + 6 assert）｜det×3 穩定（見上）

## 交付
- branch `feat/monotonic-team-id` @ **`eacdd5df`**（已 push，基於 `origin/main` 4d9f330c）
- **落地後**：`expect-min-gate` 的 team-id 兩條會自動轉綠（我已把 `GEN_MAX` 改成 0，不需你再手動改）
- **§5 遵守**：沒有回頭修既有量測產物
- 呈報待裁：**person id 同族重用**（`game_setup._next_person_id`）——同一個病、同一種修法，要不要順勢開一票
