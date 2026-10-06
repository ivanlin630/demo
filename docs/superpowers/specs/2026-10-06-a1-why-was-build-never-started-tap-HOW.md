# A1 建設：先補「為什麼沒開工」的只觀測 tap（HOW）

```
票源 ＝ 藍圖裁 `b8001b297`（③）：Team0／Team3 在 construct.start、wall.reject_*、village.build_fired **都不出現**
  ⇒ 擋它們的門**沒有儀器**（第 ③ 類）⇒ 先補 tap、量到再修，★禁零證據改派工邏輯
基準樹 ＝ `07af20022`
★本票只加觀測：fp 與決策序列必須逐位不變
```

## §0 ★一個靜態假設（寫出來是為了讓 tap 能**證偽**它，不是結論）

```
①NPC 選項「建設」永遠可選：`options.gd:70-77` `applicable` 回 true（註解：bootstrap＋升級皆候選），
  `to_task` ＝ `{"task": TASK_BUILD("建設"), "target": team.tile_pos}` —— **在自己腳下施工**
②而 TASK_BUILD 本身**不開工地**：`_tick_construction`（`outpost_system.gd:367-`）只推進**已存在**的工地
③開工地的路徑（`construction_team_id = 某隊` 的寫入點，`git grep` 全站兩處＋start_build 內一處）：
   ·`outpost_system.gd` `start_build`（設 construction_team_id／construction_target）
     ← 只經 `begin_subteam_construction`（`:799`，task ＝ **TASK_CONSTRUCT「建造」**時）
     ← 只經 `movement_system.gd:401`（子隊抵達）；或玩家指令 `player_command_system.gd:984`
   ·`faction_ai_system.gd:7155 _commit_settle_site`（紮根的 commit-hook）
   ·`outpost_system.gd:401`（既有工地換手）
   ·★R² 補（我漏的）：**基建評估層** —— `_evaluate_infrastructure`（def `faction_ai_system.gd:6183`）／
     `_evaluate_independent_infrastructure`（def `:6113`）以**獨立 cadence**（`infra_eval_next_tick`）
     直呼 `_subteam_upgrade_facility`，**完全不經** `_dispatch_builder`／`begin_subteam_construction`，
     也不是「建設」選項 commit 出來的
⇒ ~~原文：開工地的路徑「只有」這幾條~~ ⇒ ★**本票鎖定的是上面這幾條路徑＋理由**，不宣稱只有這幾條
⇒ ★而基建評估層是**升級既有設施**；Team0／Team3 若 `home_count == 0`（沒有自家據點）它大概摸不到
  —— 這句是**推論**，第一步先印 Team0／Team3 的 `home_count`（＝ `state.own_outpost_count`）確認不是走那條
⇒ **假設**：選了「建設」、而腳下沒有工地的隊 ⇒ TASK_BUILD 永遠沒有東西可推進 ⇒ committed 建設、世界不動
★★這是**負斷言**（「沒有別的開工路徑」）—— 靜態讀碼最不能支持的那一種 ⇒ 由下面的 tap 證偽或證實
```

## §1 做什麼（只觀測，`Probe.enabled` 時才跑）

```
T1【建設中的隊在幹嘛】每日邊界，對每一支 `current_task == TASK_BUILD` 的隊分四類（互斥窮盡，第四類不准省）：
   (i)  腳下有工地且 construction_team_id ＝ 本隊（在推進）
   (ii) 腳下有工地但屬於別隊（★R²：這是**正常的前閘狀態**不是異常；應與 `funnel.build_gate.tile_occupied` 大致同向 ⇒ 順手交叉核）
   (iii)★腳下**沒有工地**（construction_team_id == -1）
   (iv) 以上皆非（印出它的狀態，數它多大 —— 判準庫：最後一格永遠是「以上皆非」）
   ⇒ 計數鍵 `build.state.<i|ii|iii|iv>`＋樣本（team／tick／tile／ct_id；**隊伍鍵用 "team"**）
~~T2【建造子隊為何沒派】（新建 `build.not_dispatched.<名>`）~~
   ★R² 打回：**已經存在** —— `_dispatch_builder` 的 7 個早返回旁邊**早就各掛了** `funnel.build_gate.*` 具名計數
   （`git grep -c funnel.build_gate faction_ai_system.gd` ＝ 9；成功 `funnel.build_gate.dispatched`），
   且已有床 `scripts/debug/construction_funnel_bed.gd` 在對帳（不在註冊表）⇒ 照原文寫＝重做一份、命名體系還不一樣
T2′ ⇒ **先跑那支既有床**，配 Team0／Team3 的條件讀 `funnel.build_gate.*`
   ⇒ 計數是全域的 ⇒ 若分不出隊：**只補**那幾個計數的樣本（帶 `"team"` 鍵，沿用 `funnel.build_gate.*` 命名），不另起一族
   ⇒ 答得出來就不新建任何東西
（原文保留：）T2【建造子隊為何沒派】`faction_ai_system.gd:5340-5526 _dispatch_builder` 的每一個真實早返回點
   （今天 7 處：:5379／:5384／:5411／:5416／:5431／:5449／:5455）各一個**具名**計數 `build.not_dispatched.<名>`
   ⇒ 名字照那一處的實際條件取（藍圖給的候選：無目標格／無可建設施／不可負擔／不合資格／沒閒人）
   ⇒ ★對不上候選名的那一處，名字照條件取、並在樣本裡帶**行號**（藍圖逐字：其他要印行號）
   ⇒ 那支函式自己的分母 tap（`:5342`，「掛在嘗試、在所有 early-return 之前」）已存在 ⇒ Σ各早返回＋成功 ＝ 分母（可對帳）
```

## §2 驗收

```
P1 [不改世界] Probe 開／關，fp 與決策序列逐位相同
P2 [T1 窮盡] 每日 Σ(i..iv) ＝ 當日 TASK_BUILD 的隊數（印兩個數）
P3 [T2′] 既有 `construction_funnel_bed.gd` 的對帳照它自己的判準跑；本票只要求印 Team0／Team3 落在哪幾個 `funnel.build_gate.*`
P0 [先確認路徑] Team0／Team3 的 `home_count`（基建評估層摸不摸得到它們）
P4 [陽性對照] 佈置一支「選了建設、腳下沒工地」的隊 ⇒ T1 必計入 (iii)
⇒ 之後：量測員在 30 天觀察世界（seed 1337、玩家活著）跑一次，交藍圖 ⇒ 若 Team0／Team3 落在 (iii)，假設成立 ⇒ 再寫修法
```
