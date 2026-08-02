---
from: measurer
to: qa
status: consumed
topic: "[當前main(a5495461)故事審specimen完·blueprint轉·四類混合:2清楚coherent+2清楚broken] seed1337(注意：實際跑8mo非我原訂4mo,detach env轉發缺口漏SPECIMEN_MONTHS用預設8,結果更完整非缺陷)。12隊瀕死/逃跑候選分四類：①窮死ladder耗盡(team10/13/48/79,已知型態,連鎖排除option後死,coherent悲劇)②真威脅coherent逃跑(team53/66,flee_from固定+持續遠離移動,food未必危急,像正常戰術撤退)③★broken候選(team75,task=逃跑鎖29天+完全不動+flee_from(-1,-1)大半程+food從182漲到213(明明很安全)——對空氣逃跑嫌疑)④★混合可疑(team58,task=逃跑鎖住+famine爬到33.3+從沒嘗試任何求生option+flee_from最後突變成自己現在的tile_pos(邏輯不通)——疑TASK_FLEE鎖卡死絕境階梯接管)。附raw trace全文，判故事coherent/broken由你定。"
---

# 當前 main（a5495461）故事審 specimen 完成

依 `2026-07-19-blueprint-to-measurer-current-world-specimen-for-qa.md`（用戶要 QA 對當前世界故事判）。

## ★參數說明（透明揭露一個環境缺口）

我原訂 `SPECIMEN_MONTHS=4`，但 `godot-detach.ps1` 當時只轉發 `WARRING_*`/`GODOT_TIMEOUT` env（同本 session 已修過 `LADDER_*` 的那類缺口）——`SPECIMEN_MONTHS` 沒轉發到，detached 進程用了預設值 **8 個月**（`SPECIMEN_SEED` 剛好預設也是 1337，跟我要的一致，算走運）。**結果不是缺陷、是意外多了一倍窗口**——已趁便把 `SPECIMEN_*`/`FOOD_DAYS_THRESHOLD`/`ADHOC_TICKS` 也加進 `godot-detach.ps1` 的轉發清單，未來這類跑不會再默默降級成預設值。

## 方法

擴充 `starvation_lockpoint_trace_bed.gd`：原本只抓 `food_days<3.0` 的瀕死隊，這次加 `task==TASK_FLEE`（不限 food_days）觸發，抓「逃跑」這個你要判的故事主體（此為戰鬥/威脅驅動，非絕境階梯的 SURVIVAL_OPTION_SET 選項）。跑 `main`（`a5495461`）seed1337，實際 8 個月。

16 隊消失，12 隊有足夠瀕死/逃跑軌跡可讀故事。分四類：

## ①窮死（ladder 耗盡）——已知型態，coherent 悲劇

`team10/13/48/79`：連鎖 `stall_exclude` 排除耗盡部分 `SURVIVAL_OPTION_SET`（覓食→掠奪→紮營→買糧...），最終落 `return_home`/`乞食` 等 fallback 仍死。**這個型態你之前已判過兩次 PASS**（slice2/② ladder seed4201），本輪同型，不重複貼細節。

## ②真威脅、coherent 逃跑

**team53**：`flee_from=(14,20)` 全程固定，`tile` 持續遠離（(9,19)→(8,19)→(7,19)）朝 `move_target=(6,19)` 前進，`food_days=40→39.58`（食物充裕，非絕境逼逃）。讀起來像正常的「打不過就跑」戰術撤退，有明確威脅來源+持續遠離動作。

**team66**：`flee_from=(23,0)` 固定，`tile` 從 (24,1)→(25,1) 朝 `move_target=(26,0)` 移動中，`food_days=8.75→7.92`（略降但非危急）。同型：有威脅、有方向、在動。

## ★③疑似 broken：team75（對空氣逃跑嫌疑）

```
tick=47649 task=逃跑 tile=(16,6) move_target=(-1,-1) flee_from=(-1,-1) food_days=181.88
tick=48369 task=逃跑 tile=(16,6) move_target=(-1,-1) flee_from=(-1,-1) food_days=184.43
...（tile 完全不動，flee_from 全程 (-1,-1)，food_days 一路漲到 213）...
tick=54129 task=逃跑 tile=(16,6) move_target=(-1,-1) flee_from=(-1,-1) food_days=207.79
tick=54618 task=逃跑 tile=(16,6) move_target=(-1,-1) flee_from=(18,2) food_days=213.11（★只有最後一筆突然有 flee_from）
```

**這隊被標記「逃跑」長達 6969 tick（≈29 天）**，期間：**沒移動**（tile 全程 (16,6) 不變）、**沒 move_target**（-1,-1）、**沒 flee_from 威脅**（-1,-1，直到最後一筆才突然冒出 (18,2)）、**food_days 從 182 一路漲到 213**（明顯安全，非絕境）。task 說「逃跑」但整整 29 天什麼都沒做、也沒有可指認的威脅——**看起來像一個 stale task-lock 被貼上「逃跑」標籤，而非真的在逃跑行為**。是否為 broken，請你判。

## ★④混合可疑：team58（TASK_FLEE 疑似卡死絕境階梯）

```
tick=21299 task=逃跑 tile=(28,3) flee_from=(-1,-1) food_days=0.00 famine_days=32.5 cooldown=[買糧]
tick=21449 task=逃跑 tile=(28,3) flee_from=(-1,-1) food_days=0.00 famine_days=32.9
tick=21598 task=逃跑 tile=(28,3) flee_from=(28,3) food_days=0.00 famine_days=33.3（★flee_from 突變成自己現在的 tile_pos——邏輯不通：怎麼會逃離自己現在站的格子？）
```

這隊 `task=逃跑` 鎖住整段窗口，**famine 一路爬到 33.3（真的在餓死）**，但 `stall_exclude` 只 fire 過 1 次（排除「買糧」）——**這隊從沒真正嘗試絕境階梯的其他選項**（覓食/掠奪/紮營等一個都沒進 cooldown，代表根本沒被 `_stamp_survival_commit` 蓋章過，因為它整段時間 `current_task` 都是 `逃跑` 非 survival option）。**懷疑**：`TASK_FLEE` 這個優先層（`PRIO_SURVIVAL=80`，跟絕境階梯同一優先權層級）鎖住之後，即使沒有真實威脅（`flee_from` 過期/無效）、即使正在餓死，也沒有機制把它從 `逃跑` 換回真正的求生選項——**絕境階梯(② ladder-feedback)的 stall-detection 只認 `SURVIVAL_OPTION_SET` 裡的選項，`逃跑`(TASK_FLEE) 不在這個集合裡，可能完全繞過了 stall-detection 的保護網**。這比 team75 更嚴重：不只是「標籤空轉」，是「標籤空轉+真的餓死+没有補救機制接住」。

## 判讀（供你參考，non-binding）

②(53/66) 清楚 coherent；③(75)、④(58) 有明確 broken 嫌疑（stale task-lock，非真實行為）；①是已判過的舊型態。**building block**：如果你判③④為 broken，這暗示 TASK_FLEE 這個任務層需要跟絕境階梯一樣的 stall-detection/release 機制（現在只覆蓋 SURVIVAL_OPTION_SET，不含 TASK_FLEE），可能是下一個 god-view/絕境 arc 的候選修復點——但這是我的觀察非判定，你/blueprint 定奪。

---
measured_at_head: `a5495461`（main dir，非 worktree——這就是當前 main）
raw_logs: `docs/measurements/2026-07-19-mainworld-seed1337-flee-lockpoint-a5495461-decoded.log`（CP950→UTF-8逐行解碼版，42299行）
bed 擴充: `scripts/debug/starvation_lockpoint_trace_bed.gd` 加 TASK_FLEE 觸發+`flee_from_pos`欄（純觀測擴充，未改 production 邏輯）
附帶修: `tools/godot-detach.ps1` env 轉發清單加 `SPECIMEN_*`/`FOOD_DAYS_THRESHOLD`/`ADHOC_TICKS`
