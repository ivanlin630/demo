# HOW spec：觀察者 inspect 深度（★缺的比想像少 —— 五個欄位）

owner: systems ｜ 2026-09-10 ｜ **player_reachable: yes（觀察者）** ｜ 用戶原話：
「我需要的世界沙盒 UI 要全面資訊，例如選據點就能知道誰是擁有者、誰是居民團；
選隊伍能看到詳細目標而不是單純一個 tag」

## §1 ★現況（我 grep 過，而它比「面板沒掏給他」樂觀得多）

```
observer_query_api.query_team(:79) 已回傳：
   id label leader_name pop pop_named pop_anon pop_minor pop_captive
   food food_flow coin resources_nonzero rung rung_cap archetype plan_phase
   faction_id faction ★task ★task_reason ★solo_intent readiness fatigue wounded tile_pos tags is_beast
observer_query_api.query_outpost(:142) 已回傳：
   tile_pos outpost_type outpost_level ★owner_team_id ★owner_team ★owner_faction
   ★facilities_nonzero garrison ★resources_nonzero resource_cap
```
⇒ ★★**擁有者、設施＋等級、公庫存量、task、intent 都【已經有了】。**

## §2 ★★★所以缺的是【五個具名欄位】，不是「一個面板」

```
據點：✘ 居民團清單（誰住在這）
隊伍：✘ 目標【對象】（task 有了，target 沒有）
      ✘ goal 細節（用戶原話：「詳細目標而不是單純一個 tag」）
      ✘ morale
      ✘ 威脅感（threat_react / threat_id）
```
★**而它們的資料【全部在 state 裡】**（觀察者＝god-view，不受感知鐵律限制）
⇒ ★★這是**掏欄位**，不是**造機制**。

★**逐欄的來源（★實作前請各自 grep 確認，我只查到這一層）**：
```
居民團清單  ⇒ 對該 tile：`is_resident_static(state, t)` 為真的隊（★而它是【位置謂詞】——
              ★★★所以面板要印的是「【此刻】在這裡的居民團」,而不是「屬於這裡的居民團」,
              ★而那兩者不同,已記 known_issues「兩個位置謂詞」條）
目標對象    ⇒ `team.current_target` / task 對應的 target 欄（★實際欄名請查）
goal 細節   ⇒ decision 端的 goal/plan 結構（★★這一格【最可能長大】,見 §3）
morale      ⇒ team 的 morale 欄（★查實際欄名）
威脅感      ⇒ `DecisionContext` 的 `threat_react` / `threat_id`
              ★★★而 ctx 是【每 tick 重算的】,不是存在 team 上 ⇒ 面板要嘛重算一次,
                 要嘛讀最近一次的快照 —— ★這是本票【唯一的設計選擇】,見 §3
```

## §3 ★★兩個會讓本票長大的地方（★先劃線）

```
①「goal 細節」要多細？
   ⇒ ★本票的界線：印【引擎自己存的那個 goal 結構】,★★不新增「解釋文字」層
   ⇒ ★★★若印出來人看不懂,那是【票②（人話層）】的事,不是本票
②「威脅感」要不要重算 ctx？
   ⇒ ★重算＝觀察一次就跑一次 gather（★★而 gather 有副作用嗎？——【實作前必查】,
     ★★★今天已經有「觀測改變被觀測物」的血證）
   ⇒ ★建議：先查有沒有現成的快照；沒有的話【印「未快照」而不是重算】,
     並把「要不要存快照」留給下一張票。
```

## §4 驗收（blueprint 指定＝用戶當場用）

```
①點據點見：擁有者／★居民團清單／設施＋等級／公庫存量
②點隊伍見：當前 task ＋ intent ＋★目標對象 ＋★goal 細節／資源／pop／★morale／★威脅感
③★★而【五個新欄位】各要一格自檢：斷言【值真的來自 state】而不是空字串／預設值
   ★成對對照：構造一支【有目標】與一支【沒目標】的隊 ⇒ 面板上【看得出差別】
④★★★零機制改動：本票只讀不寫 ⇒ determinism fingerprint【不變】
   ★而若「威脅感」選了【重算 ctx】那條路 ⇒ ★★fp 可能會變（gather 若有副作用）
     ⇒ 那時【停下來回報】,不要自己吞掉
```

★誠實限：
1. 本票**只掏欄位**，不做排版、不做人話層（那是票②）。
2. ★**「居民團清單」印的是【此刻在這裡的】** —— 而那可能是 0-1
   （已坐實：`known_issues`「這個世界沒有村莊那一層」）
   ⇒ ★★**若用戶看到空清單，那不是面板壞了，是世界如此** —— **這句要印在面板上或寫進交件信。**
