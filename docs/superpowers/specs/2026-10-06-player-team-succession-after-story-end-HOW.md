# 故事結束之後，原玩家隊照 NPC 的路補領袖（HOW）

```
票源 ＝ QA 故事稽核 `docs/superpowers/handbacks/2026-10-06-qa-to-blueprint-player-death-7day-story-verdict.md`（`1f50985f9`）
  ＋ specimen `docs/measurements/player-death-7day.specimen.jsonl`（seed 1337，樹 `57ab240ad`）
基準樹 ＝ `1f50985f9`（下面每個 file:line 都在這棵樹上，我逐處開檔核過）
★性質 ＝ **故事結束票（`d415a5791`）刀 1 的殘留**，不是新 WHAT（理由見 §1）
```

## §0 QA 讀到了什麼（一句）

```
玩家絕後之後，原玩家隊（Team15）**永遠沒有領袖** ⇒ `effective_pop_cap` 崩到 1
⇒ 第 4 天邊界的全域溢出掃描把它 **7/8 的人口與 7/8 的每一種資源**切給一支新的流亡隊
⇒ 之後它卡在 pop＝1，而且**每天都會再被切一次**（cap 永遠是 1）
★QA 的算術與 specimen 逐位對上：coin 2085.5×0.125＝260.7／food 23.6×0.125＝2.95／material 5×0.125＝0.625
```

## §1 ★★★為什麼它是刀 1 的殘留（這一段是本票的全部理由）

```
意圖帳 #43／#44：game_over ＝ **UI 層的故事結束，不是世界物理**
刀 1 拿掉的是 `sim_runner.gd` 的 early return（世界因 game_over 而停）—— 那是**一處**執法點
★而同一個舊假設還有**第二處**執法點：`scripts/simulation/event_system.gd:72-86` `handle_player_succession`
  ·`:73` `team.leader_id = -1`
  ·`:74` named 空 ⇒ `:80-83` 設 `game_over`／`game_over_reason` ⇒ **`:84` `return false`**
  ⇒ ★**繼承在這裡停止** —— 而 NPC 隊同一個處境走的是 `:41-65`（best named → **anon 晉升** → 皆無才崩潰）
⇒ 以前世界一 game_over 就停，所以「繼承停止」**從來不會被看見**（停了的世界不會有第二天）
⇒ ★★刀 1 讓世界不再停 ⇒ 這條**從沒被走過的分支**第一次活起來 ⇒ 它說的是「這支隊不再有人當家」
  ＝ 讓 game_over 繼續當世界物理（只是從「整個世界停」縮成「這支隊停止繼承」）
★★我在故事結束 spec 的 P2 只數了 `sim_runner.gd` 裡讀 `game_over` 的地方 ⇒ **那是入口不是母體**：
  「把 game_over 當世界物理」的地方不一定讀那個旗標 —— 這一處是**在設旗標的同一個分支裡 return**
⇒ 判準（進判準庫）：**拔掉一個意圖的執法點時，母體是「依賴那個舊意圖的行為」，不是「讀那個符號的行」**
```

## §2 做什麼

```
①抽出 `on_leader_death` 的 NPC 繼承段（`event_system.gd:41-65`）成一支 `_npc_succession(state, team) -> bool`
  ⇒ `on_leader_death` 的 NPC 分支呼它（行為不變）
②`handle_player_succession` 在 **`game_over` 設完之後**（`:83` 之後、原本 `:84 return false` 的位置）
  ⇒ **改成 `return _npc_succession(state, team)`**
  ⇒ ★`game_over` 照設（UI 故事結束照印）；★世界照 NPC 的路補領袖
  ⇒ ★★**只有一份繼承邏輯**（不准在 player 分支再抄一份 —— 三份會漂，漂掉那份是靜默的；你上一張剛付過）
③`player_id == -1` 那一支（`:78-79`）**不動**（它本來就讓 `on_leader_death` 的偵測走 NPC 路）
```

## §3 ★爆炸半徑（改回傳值 ⇒ 在讀的那端）

```
`handle_player_succession` 呼叫端 3 處：
  `event_system.gd:40`（`on_leader_death` 內 `return` 它 ⇒ 回傳值往上傳）
  `encounter_system.gd:1390`／`player_command_system.gd:1514`（**不讀**回傳值）
`on_leader_death` 讀回傳值的只有 **`npc_combat_system.gd:786-790`**：
  `if not succeeded and team.faction_id != -1 …: state.succeed_or_disband_faction(…)`
  ⇒ ★今天：原玩家隊若是某勢力的盟主，玩家絕後 ⇒ false ⇒ **勢力被交出或解散**
  ⇒ ★★改後：anon 晉升成功 ⇒ true ⇒ **勢力留在原玩家隊（新領袖接手）**
  ⇒ ★這是本票會改變的【第二件世界行為】—— 它與 NPC 盟主隊同處境的行為**一致**（同一份邏輯）
  ⇒ 不是缺陷，但要寫在交件裡、要有一格看得到它
```

## §4 驗收（P）

```
P1 [補到領袖] 佈置照 `story_end_not_physics_bed.gd:67-73`（真的寫入者）⇒ 玩家絕後
   ⇒ 斷言 `game_over == true`（★故事結束照設）**且** 原玩家隊 `leader_id != -1`
   ★母體地板：named 真的為空（否則走的是 choose_heir 那條，不是這條）
P2 [★★不再被切] 同一佈置推過**一個** `OVERFLOW_CHECK_INTERVAL` 邊界
   ⇒ 原玩家隊 population **沒有**被切到 1（印前後兩個數）
   ★★負對照：把 ② 那一行改回 `return false` ⇒ 這一格必須紅，而且紅的長相要是 QA 讀到的那個（8 → 1）
P3 [單一定義] 反向掃：`event_system.gd` 裡「從 anon 晉升」的 `PersonGenerator.generate_for_team(…, "member")` 呼叫 ＝ **1**
P4 [勢力那一件] 佈置原玩家隊為勢力盟主 ⇒ 玩家絕後 ⇒ 勢力**仍在**、盟主仍是原玩家隊
   ★反向：named 與 anon 都空（真的無人可補）⇒ 照舊 false ⇒ 勢力被交出／解散（那條路不能被這張票弄死）
P5 [fp] **先量**：fp 床 `player_id = -1` ⇒ 我**預測**不變（`:78-79` 那支不動）—— ★預測不是授權，量了再說
P6 [電池]
```

## ★★★★§4b 藍圖裁定（`848e2aaea`）—— 兩件加進來，而★序改了：**排在威脅欄那張之前**

```
逐字要點：①game_over 同 tick 原隊交回 on_leader_death 同一條（named → anon 晉升 → 皆無滅團）
  ⇒ ★**禁 leaderless 活隊存在超過一 tick**；床含全世界掃「leaderless 且活 ≥1 天」＝ 0；
    陽性對照拿掉那步 ⇒ pop 掉到 1 必紅
②掠奪 util 倒數第二卻被選 ＝ tap 缺口：每候選印【原始 util／需求層加權／人格調製／最終合成】四欄進 specimen
  （不耗 RNG、不改 fp），補上後請 QA 重讀同段再判「設計還是缺陷」；可併①
⇒ 與我上面 §1-§4 同向（我寫完才收到，沒有衝突）；以下把它落成格。
```

### ①的新格

```
P7 [★★全世界不變量] 一次長跑（≥ 7 天、有玩家、讓玩家絕後）之後掃全世界：
   「`leader_id == -1` 且 population ≥ 1 且這個狀態已持續 ≥ 1 天」的隊 ＝ **0**
   ⇒ ★母體地板：同一輪要**真的有**玩家絕後（`game_over == true`）＋ 掃描的隊數印出來（不是 0 隊）
   ⇒ ★★**先量**：第一次跑若掃出**原玩家隊以外**的 leaderless 活隊 ⇒ **那是既有洞不是本票弄的**
     ⇒ 逐隊印 id／何時變 leaderless／為什麼（哪個死亡路徑），**回報我，不擴本票去修**
     （★要一件世界還沒做到的事 ＝ 讓守衛為與本票無關的原因紅；先量清楚它是哪一類）
P2 的負對照即藍圖說的陽性對照（拿掉 ② 那一行 ⇒ pop 8 → 1 必紅）
```

### ②決策 tap（★可併，而它有三條硬約束）

```
合成點：`scripts/simulation/decision/decision_engine.gd:79 rank_scored` ／ `:267 rank_scored_ctx`（★先查哪一支是掠奪那一輪實際走的）
T1 ★★★**在合成發生的那一處記錄，不准重算**：tap 讀的是引擎**已經算出來**的四個數
   ⇒ 不准為了印而再呼一次 util／人格函式 —— 那會**耗 RNG**（判準庫：觀測儀器禁耗 global RNG，
     第 4 次同族血證）而且**改變被觀測物**
T2 **不改 fp**：fp 必須逐位元組不變（★這一條是「沒有改變被觀測物」的機械證明）
   ⇒ ★負對照：讓 tap 改成重算一次 ⇒ fp 必須**變**（否則 T2 那一格沒有鑑別力）
T3 四欄要**同一時刻**的值（判準庫：同一欄印的值與被斷言的值必須是同一時刻）
   ⇒ 原始 util／需求層加權／人格調製／最終合成 ⇒ 且**最終合成必須等於引擎拿去排序的那個數**（一格斷言）
完成後 ⇒ 量測員用**同一 seed 1337、同一樹段**重產 specimen ⇒ QA 重讀 Team11 那 5 次掠奪
  ★在那之前**不下「決策壞了」的結論**（藍圖逐字）
```

### commit 切法（★兩件可併同一張，不准併同一顆）

```
①一顆（改世界）／②一顆（只加觀測、fp 不變）
⇒ 一輪電池分得清：② 的 T2（fp 不變）與 ① 的 P2／P7（世界行為）各自有名字的格
⇒ ★而 ② 的 T2 負對照「重算 ⇒ fp 變」必須在 ① 已 commit 之後跑（否則 fp 變的原因分不出是誰）
```

## §5 不在本票（但要知道）

```
✘ 溢出切割**沒有留下任何 specimen 可讀的痕跡**（只有 `[PopMgmt]` print）—— QA 是用 code 回溯推出那個轉折的
  ⇒ ＝ 不變量「全量暫態可觀測性」的一個既有洞 ⇒ 登 `known_issues.md`，不擴本票
~~✘ Team11「掠奪 util 倒數第二低卻勝出」不在本票~~ ⇒ ★藍圖裁**併進來**（§4b ②）
✘ 被切出去的那支流亡隊後續 —— 本票修好之後它不會再被生出來；既有存檔裡的不處理
```
