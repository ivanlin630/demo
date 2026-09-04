---
from: implementer
to: systems
status: open
slice: 共位互動 ★做完停在 branch（`feat/old-growth-forest`；★與共位必見同一支，照你「兩票一起 merge」）
touches: `team_data.gd`／`interaction_system.gd`／`sim_runner.gd`／控制床＋卷面
topic: ★★★#1 綠(控制床 修前 `resolve=0` → 修後 `dispatch=1 meet_target=1 resolve=1`)、#3 綠(★機械證據:`git diff origin/main` 對 `interaction_system.gd` ＝ **74 insertions / 0 deletions** ⇒ 沒有任何既有行被改寫)、#4 綠(★去重先查後標 ⇒ 結構性 0,而它的證據是 `dedup_prevented=928` 非 0)、#5 綠(三跑一致 `9870fc4f`,且與前兩刀都不同)、#6 綠(母體極小 最大 7 隊;`near.interact` 2.7–5.0ms vs `near.faction_ai` 0.57–2.22s ＝ 整 tick 的 0.2–0.5%)、#8 綠(新段零 randf/randi);★★#2 的【世界層】數字仍答不了(12 日窗 JOIN `dispatch=3`,母體太小) ⇒ 照上一封,跟考程重跑一起量;★★★而 `headless` 一支紅,性質是【既有 assertion 的訊息文字被根修推開】不是新失敗 —— 我【不自己刷 baseline】
---

# ★★★①逐條
| # | 判準 | 結果 | 證據形態 |
|---|---|---|---|
| 1 | 控制床：同格靜止 ⇒ 一個週期內互動 | ✅ | 修前 `dispatch/meet_target/resolve = 0/0/0` → 修後 **1/1/1**；`turn=2 residency_interact=1` |
| 2 | `join.resolve`>0／`true<belief` 下降（★世界層） | ⏳ | ★12 日窗 JOIN `dispatch=3`／`meet_target=0` —— **母體太小，答不了**（不是「沒改善」） |
| 3 | 不新增語意 | ✅ | ★**`git diff origin/main -- interaction_system.gd` ＝ 74 insertions / 0 deletions** |
| 4 | 同 tick 同 pair 不重複 | ✅ | ★結構性 0（先查後標）；★★**證據是 `dedup_prevented=928`** |
| 5 | determinism 三跑一致 ＋ 排序鍵 | ✅ | `9870fc4f` ×3；★與 main `8164bf58`／共位必見 `d4426199` **都不同** |
| 6 | perf：母體 ＋ 該段耗時 | ✅ | 母體最大 **7 隊**；`near.interact` **2.7–5.0 ms** vs `near.faction_ai` **0.57–2.22 s** |
| 7 | 憲法閘 ＋ 17 支 | ⚠ | ★16 支綠（含 `bed-arm` 修完復驗 PASS）／**`headless` 紅** —— 見③ |
| 8 | 零 RNG | ✅ | 新段 `randf|randi|randomize` **零命中** ＋ 三跑 byte-identical |

# ★★②#3 與 #4 我做成【機械】而不是【論證】
```
★#3：「`_try_interact` 本體未改」最強的形態不是我貼一段 diff 說「你看沒改」，
   ★★是 `--numstat` 的 **deletions = 0** —— **一行都沒被刪或改寫，整個檔案只有新增。**
★#4：「不重複」若只印 0，那 0 跟【駐留路徑根本沒跑】長得一模一樣
   ⇒ ★★★所以我數了【被去重擋下來的】：`dedup_prevented=928`（12 日窗）
     ⇒ 那是「同一對被兩邊各給一次機會、而第二次被擋掉」的直接證據 —— 正是你 spec §3 訂正裡預期的副作用
```

# ★★★③`headless` 那一支：★不是新失敗，而我【不自己刷 baseline】
```
★diff 只有一行（`2c2`），而且是【同一條既有 assertion】：
   `[gNa] 礦村未鑄幣: … task=建設 …`   →   `[gNa] 礦村未鑄幣: … task=投靠 …`
⇒ ★★失敗【數量】1 vs 1 不變、測試不變、assertion 不變 —— **只有訊息裡嵌的 task 名字被根修推開了**
⇒ ★★★而閘比的是【清單】（那是它的設計，是對的：一紅一綠會抵消）⇒ 文字一動就紅
★我沒有去更新 baseline：**那是把紅藏起來最便宜的方式**，而 baseline 屬於考程／凍結那一層
   ⇒ 你 merge 程序裡本來就有「重建凍結」—— 這一格我留給那一步，請你裁
```

# ④床的兩件事（★都不是我原本要做的，但它們擋在路上）
```
①★`bed-arm` 閘擋下新床（手工組世界、不用 helper、不在白名單）
   ⇒ ★★而白名單檔頭明寫「**新增床不得加進來（那是閘要擋的東西）**」——它是【待辦清單】不是豁免清單
   ⇒ ★★★正解 ＝ `MeasureBedHelper.arm_and_new()`（專給手工組世界，`Probe.arm()` 寫死在建世界之前）
     實測：已遷移 28→**29**、白名單 **272 不變**、未涵蓋 1→**0**、PASS
②★★★床的輪數我要訂正你一個數字（★你那封說「48 tick < T1 60 ⇒ 跑不到機會」）：
   **本床每一輪推進的是 `TICKS_PER_HOUR`(60) 不是 1 tick** ⇒ 舊床的「48」是 **48 輪 ＝ 2880 tick**
   ⇒ ★它【本來就】跨過 T1 很多輪 ⇒ 先前 `resolve=0` **不是「跑不到機會」，是當時根本沒有駐留這條路**
   ⇒ ★★我仍把輪數拉到 72（＝4320 tick ＝ 3 日）留餘裕，但理由是餘裕不是「原本不夠」
```

# ★⑤兩條誠實限（★我自己標，免得數字被讀太寬）
```
①★`near.interact` **同時涵蓋【移動】與【駐留】兩條路** —— 我沒有把駐留那半單獨切出來
②★★我**沒有 pre-slice 的 `PHASE_TIMING` 對照卷** ⇒ 上面是【絕對值】不是【增量】
   ⇒ ★★★我敢說「便宜」的理由是**絕對值夠小（<0.5% of tick）**，不是因為我比較過
★而整 tick 的 `avg 25595→36644 us` 我【不拿來用】：兩卷是不同世界（teams 99 vs 97、factions 8 vs 9）
   且當時機器不獨佔 —— 那正是我今天已經踩過一次的「不同窗兩個數字相減」
```

# ⑥現況
```
`feat/old-growth-forest`：★共位必見 ＋ 共位互動【同一支】，照你「兩票一起 merge」
★★停在 branch 等你；★★★而 `headless` 那一格請你裁（刷 baseline 屬於重建凍結那一步）
★最終 17 支全掃我跑了兩次都【被外部砍掉】⇒ 上表的「16 綠」是【單支復驗】的結果，
   ★★我標明它不是【一次完整掃過】的結果 —— 若你要那份完整卷，我再跑（★而它 276s）
```
