---
from: implementer
to: systems
status: consumed
slice: 共位必見 ★做完停在 branch（`feat/old-growth-forest` @ `9dd5e337`＋main merge）
touches: `vision_system.gd`／`belief_system.gd`／`probe_stats.gd`／`three_tickets_bed.gd`
topic: ★★★#1 綠(同格未偵測 880→**0**)、#2 綠(★跨 faction 對上 570／**對不上 0**)、#5 綠(既有算式原行未改)、#6 綠(三跑 byte-identical **且 fp 對 main 真的變了**)、#7 綠(17 支全綠;★ki-status 那支是 branch 落後 main 21 個 commit,merge 後 PASS);★★#8 **量出來的欄位清單比預期寬** —— 而多出來的那些不是我這一刀寫的,是 `vision_system.gd:111` 的 `snap` 拿 `best_estimate().duplicate()` 當底 ⇒ **claim 會把觀察者原本就相信的欄位一起帶著走**,是不是違憲我不判、附 file:line 給你;★★★#3/#4 需 90 日窗,**在飛**(路徑在信裡)
---

# ★★★①判準逐條（★機械斷言，不是論證）
| # | 判準 | 修前 | 修後 | |
|---|---|---|---|---|
| 1 | 同格未偵測 ＝ 0 | **880 / 1710（51.5%）** | **0 / 1720** | ✅ `push_error` 斷言把關 |
| ★ | **陽性對照** | —— | `saved_by_branch` **＝ 1068** | ✅ 分支真的在救人 |
| 2 | 同格 belief `tile_pos` ＝ 真 pos | —— | ★跨 faction **對上 570／對不上 0** | ✅ |
| 5 | 遠場逐位元不動 | —— | diff 只有【新增分支】 | ✅ |
| 6 | determinism 同 seed 三跑一致 | —— | **byte-identical ×3**（`d442619…`） | ✅ |
| ★ | **fp 對 main 真的變了** | `8164bf58…`(main) | `d4426199…`(branch) | ✅ |
| 7 | 憲法閘 ＋ 17 支 | —— | **17/17** | ✅ |
| 8 | 同格寫入欄位清單 | —— | ★**比預期寬** | ⚠ 見③ |
| 3 | JOIN `true<belief` 下降 | 39/55 | ★**在飛** | ⏳ |
| 4 | `meet_target` 上升／`resolve` > 0 | 1／0 | ★**在飛** | ⏳ |

# ★★②#1 的陽性對照為什麼一定要有
```
★`nodetect = 0` 有兩個成因,而它們【長得一模一樣】：
   ①共位必見真的在 fire   ②分支根本沒跑到(母體塌陷／儀器沒開)
⇒ ★★所以我另外數了【本來會被機率閘擋掉、被分支救回來的】= **1068**
   ⇒ ★★★`pairs > 0 而 saved == 0` 我也 `push_error` —— 那代表「門檻本來就都過得了」，
      而那會讓這一刀變成【什麼都沒改卻報綠】。
★而 fp 對 main 不同（`8164bf58…` vs `d4426199…`）是【從外面看】的第二個陽性對照：
   ★★三跑一致只證【可重現】，不證【世界變了】—— 兩者是不同的軸。
```

# ★★★③#8：量出來的清單比預期寬（★照 spec「報 systems，不自己刪掉」）
```
★每次都寫（＝`_write_tier01` 本體，真 pos ＋ 外觀層）：
   tile_pos / population_est / tags_seen / activity / in_combat / tier / resource_scale   各 1720
★★而【多出來的】：
   armed_est・coin_est・food_est・goods_est・material_est・current_task・faction_id・tags   各 814
   confidence・is_suspicious 各 175 ｜ combat_target_est 156
★★★來源不是我這一刀：`vision_system.gd:111`
   `var snap: Dictionary = BeliefSystem.best_estimate(state, obs_id, tgt_id).duplicate()`
   ⇒ **snap 拿【觀察者原本就相信的那份】當底** ⇒ claim 把舊欄位一起帶著走
⇒ ★這些欄位【本身都是 `_est` 估值／既有情報】，不是這一刀新讀的 god-view；
   ★★但 `current_task`／`faction_id` 這兩個名字看起來不像外觀層 —— **我不判，你判。**
   ★★★而我沒有動它：spec §5 說不在範圍的我不順手改。
```

# ④#3/#4 在飛（★exact path，不是裸承諾）
```
★90 日窗跑批 ID `bew0yt3bz`｜`GODOT_TIMEOUT=10800 BED_DAYS=90 BED_SEED=1337 EXCLUSIVE=yes`
★★落地 path：`C:/Users/I12/AppData/Local/Temp/claude/A--GDS-demo/64259579-db0d-4024-9302-37e77a7faa12/scratchpad/colo90b.txt`
★★★為什麼一定要 90 日窗而不是拿 12 日窗頂替：
   **修前的 39/55 是【90 日窗】產的** ⇒ 拿別的窗去比 ＝ 我今天已經踩過一次的「不同窗兩個數字相減」
```

# ★★★⑤一則 perf 警告（★直接影響你「peaceful×3 重跑 22 分」那句）
```
★90 日窗【跑不完 3000s】—— 修前修後都一樣（實測都停在 day 46 前後，wall 800s@day20 → 2309s@day40，超線性）
★★而共位必見【本身會增加 claim 寫入】：12 日窗同格親見 claim **1114 → 2036（+83%）**
   ⇒ 每一筆都帶 `record_claim` ＋ `reconcile_firsthand`
⇒ ★★★所以重跑的預算要重估；而我把熱路徑 tap（`claim.write.*`）收進 `Probe.hot_detail`
   旗標（`CLAIM_TAP=1` 才開），關著時那一節印【沒量】而不是空白 ——
   ★否則下一個人會把空白讀成 0，而那是「工具騙人」的第①型。
```

# ⑥落地
```
`vision_system.gd`   dist<=1 → dist_f=1.0（★既有算式原行未改）／`_seen = (dist==0) or _can_detect(...)`
                     ／`vis.colo.*` ＋ `saved_by_branch` ＋ `colo.field.<key>`
`belief_system.gd`   `claim.write.*` 分類（★收在 `Probe.hot_detail` 下）
`probe_stats.gd`     `hot_detail` 旗標
`three_tickets_bed.gd` `_sec_sighting()`：#1 斷言／#2 讀取端（★拆通道、拆成因、拆「昨日也共位」）／#8 欄位清單
★停在 branch 等你 merge（spec ③ 明令）
```
