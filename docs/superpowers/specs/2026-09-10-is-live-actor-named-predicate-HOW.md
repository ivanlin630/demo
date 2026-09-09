# HOW spec：把「這支隊還活著嗎」變成一個**有名字的謂詞**

- **WHAT 授權**：blueprint 已核（排序在 C1 票① 之後；★C1 票① 已落地 ⇒ 本票解除阻塞）
- **序**：★體驗窗三票（效能／inspect／帶因）在前；本票與「攻擊門」同屬排在其後的一批。
- ★**本票【不改任何行為】**——它只把一個**已經存在的判斷**變成**一個名字**，
  ★★並產出一份【誰該用它】的普查清單交上游判。**普查的結果不在本票裡改。**

---

## ① 現況：一個一 tick 的殭屍窗，而它沒有名字

`scripts/data/world_state.gd:69`

```gdscript
var teams_pending_erase: Array = []   # 滅團延遲清除：tick 末單點 erase（中途 erase 不安全）
```

**這個設計是對的**（多系統在 tick 內持有 `team_ids` 快照，中途 erase 會炸），
★**代價是**：從「判死」到「tick 末真的 erase」之間，
**那支隊仍然在 `state.teams` 裡**，而它已經不是一個活著的行為者。

```
寫入端（判死）  faction_ai_system.gd:2423 / :2440 / :4408-4409
清除端          faction_ai_system.gd:4415-4438（cleanup_extinct_teams，:4438 clear()）
★讀取端（過濾）  只有兩處，而且是【逐字重複的三行】：
   faction_ai_system.gd:4404-4406
   npc_combat_system.gd:748-750
       var _pending: Dictionary = {}
       for _pid in state.teams_pending_erase: _pending[_pid] = true
       state.succeed_or_disband_faction(team.faction_id, team.team_id, _pending)
★★而 `for … in state.teams` 的站點總數 ＝ **62**（`scripts/simulation` ＋ `scripts/data`）。
```

⇒ ★★★**判斷本身是對的，但它沒有名字** ⇒ 每個需要它的呼叫點都得**自己記得重建一次**，
而「記得」在這個專案裡**從來沒有生效過**（這是我們反覆記過的形狀）。

---

## ② 修法：兩個名字，零行為改變

```gdscript
# scripts/data/world_state.gd
func is_live_team(tid: int) -> bool:
    return teams.has(tid) and not teams_pending_erase.has(tid)

func pending_erase_set() -> Dictionary:
    var d: Dictionary = {}
    for _pid in teams_pending_erase: d[_pid] = true
    return d
```

**兩處既有呼叫點改成**：

```gdscript
state.succeed_or_disband_faction(team.faction_id, team.team_id, state.pending_erase_set())
```

★**為什麼要兩個名字而不是一個**：現有兩處消費的**不是布林**，是一個
餵給 `succeed_or_disband_faction` 的**排除集合** ⇒ 只給 `is_live_team` 不能消滅那段重複。
★★而未來的呼叫點多半要的是**布林** ⇒ 兩個都給，**各自對應一種真實用法**，
★★★**不發明第三個「將來也許有人要」的介面**。

**驗收（機制層）**：

```
①★fingerprint 不變 —— 兩棵樹相同（本票不改任何判斷，只搬位置）
  ⚠ `state_fingerprint.gd:145` 讀 `teams_pending_erase.size()` ⇒ ★它本來就在 fp 裡
    ⇒ **fp 不變是可驗的，而且是本票最強的一格**。
②★★成對對照：`is_live_team` 對【剛判死、還沒 erase】的 tid 必須回 `false`，
  對【正常隊】必須回 `true`，對【已 erase 的 tid】必須回 `false`。
  ★★★三格都要，因為第一格與第三格【回同一個答案而理由不同】，
     只驗第三格會讓「殭屍窗」那格完全沒被測到。
③既有的滅團／繼承測試全綠（`recovery_r1_test.gd:119` 直接斷言 `teams_pending_erase.has(30)`
  ⇒ ★它是現成的殭屍窗樣本，不要動它）。
```

---

## ③ ★★★普查（本票的真正產出）：其餘 60 個站點，**列清單，不動它們**

```
母體 ＝ `grep -rn "in state\.teams" scripts/simulation scripts/data --include=*.gd`（★裸符號，不加過濾）
      ——★現測 62，其中 2 個已過濾 ⇒ 待判 60。
逐站點分三類：
  [A] 需要【活著的】  —— 決策／互動／戰鬥／外交等「對它做事」的迴圈
  [B] 需要【全部的】  —— 記帳／守恆／fingerprint／cleanup 自己／統計
  [C] ★待判         —— 讀 code 判不出來的
```

★**這一格的誠實限，寫在最前面**：

```
★★【讀 code 判不出某個站點「應該」過濾】—— 那是語意判斷，不是語法判斷。
   ⇒ 所以 [C] 這一類【必須存在】。★★★一份沒有 [C] 的普查是可疑的：
     它表示分類者把不確定的東西塞進了 A 或 B。
★而 [A] 裡的每一條都是【一個潛在的 bug】，但**本票不修**——
  ★★因為「對殭屍隊做事」的後果逐站不同（有的無害、有的會讓死人繼承派系），
  ★★★逐站的修法要各自有驗收，混在一張票裡會變成一次無法驗收的大改。
⇒ 清單交上游（systems→blueprint）判優先序，**分票開**。
```

---

## ④ 這張票【不做】的事

```
①★不對 60 個站點做任何修改（連「看起來很明顯」的也不動）
  ——★★血證形狀：「順手一起改」正是讓一張零行為票變成一張無法驗收的票的方式。
②不改 `teams_pending_erase` 的生命週期（tick 末單點 erase 的設計是對的）
③不改 `succeed_or_disband_faction` 的簽名
④★★★不發明「將來也許有用」的第三個介面
```

---

## ⑤ 為什麼值得做（一句）

★這是**把一條靠記憶維持的紀律，換成一個編譯器看得見的名字**。
★★而普查那一格的價值可能比改名更大：
**我們到今天才第一次數清楚，62 個迴圈裡只有 2 個知道殭屍窗存在。**
---

## ⑥ ★★★R² 回件（2026-09-10）：母體 62 → **68**，我的 pattern 系統性地漏掉一整類寫法

R² **沒有沿用我的 pattern**，獨立重撈，結果我猜中的那件事成立：

```
①state.teams.values()                      ⇒ 零命中（這條沒被用）
②in state.teams.keys() 直接迭代            ⇒ 命中，但那一行仍含「in state.teams」子字串
                                              ⇒ ★已經在我的 62 裡（faction_ai:1033／manpower:272／population:77）
③★★★keys() 先存變數、迴圈打在變數上      ⇒ 【完全繞過】——迴圈那行寫的是 in ids / in all_teams
    sim_runner.gd:309         for _tid8 in all_teams（pass.byteam probe）
    observer_query_api.gd:66  query_all_teams()
    observer_query_api.gd:133 query_map_teams()
    observer_query_api.gd:184 _residents_here_now()
    state_fingerprint.gd:77   _emit_teams()（★fp 序列化本體）
④★keys() 當【參數】傳下去，迴圈在被呼叫的函式內部  ⇒ 那一行連 state.teams 四個字都沒有
    sim_runner.gd:291 → resource_system.gd:346 flush_forage_episodes(state, team_ids)
                          內部 :348 for tid in team_ids
⑤裸 state.teams 整包當參數傳遞             ⇒ 三種呼叫形狀查過，★零命中（確認乾淨，不是漏查）
```

⇒ ★**真母體 ＝ 68**（62 ＋ 6）。★★而漏掉的不是零星一兩個，是**一整類寫法**
（先存變數再迴圈／當參數往下傳）**對我的 pattern 系統性隱形**。

### R² 對那 6 站的初判（★普查時要覆核，不得照抄）

| 站點 | 初判 | 理由 |
|---|---|---|
| `observer_query_api.gd:66/133/184` | **[A]** | ★**玩家可見面** —— 一支剛判死未 erase 的隊會在隊伍列表／地圖上**閃現一 tick** |
| `sim_runner.gd:309`（probe 計數） | [B] | 記帳本來就該看見全部 |
| `state_fingerprint.gd:77`（fp 本體） | [B] | 同 `:145` 讀 `teams_pending_erase.size()` 的道理 |
| `resource_system.gd:348`（flush_forage_episodes） | **[A]?** | 對已判死的隊清暫存／發 forage 訊息＝跟死人互動，★但後果可能無害 ⇒ 交普查裁 |

★★★**跨票通知（R² 提，我照做）**：`observer_query_api` 那三個**正是「觀察窗 inspect」那張票的消費者**
⇒ **兩張票的母體重疊** ⇒ 已知會 implementer。

## ⑦ ★第四種狀態（R² 定位，**不新增測試格**）

```
faction_ai_system.gd:4423  state.erase_teams(routed)         ← teams.has(tid) 變 false
faction_ai_system.gd:4438  state.teams_pending_erase.clear() ← pending.has(tid) 變 false
⇒ 這兩行之間（4424-4437）存在第四種組合：teams=false 而 pending=true。
★它回的答案與「已 erase」一樣是 false，但【內部原因不同】。
★★不加第四格斷言的理由（R²，我同意）：is_live_team 是一個【沒有分支的純布林 AND】
   ⇒ 三種會回 false 的組合走同一條運算，沒有任何特殊判斷能讓其中一個走不同路徑。
★★★但這個窗寫在這裡當紀錄 —— 免得以後有人以為只有三種組合存在。
```

## ⑧ R² 判決狀態

```
2026-09-10 R²：非 CLEAN（唯一阻塞＝母體 62→68），已補上 ⇒ ★R² 明示補完不用再送審，直接 dispatch。
其餘全過：兩個名字不是過度設計（★理由是【下一批票幾乎確定要用單點布林】，
不是「將來也許有人要」）／驗收表／不做的事／我自招的兩件（[C] 必須存在、[A] 本票不修）。
```
