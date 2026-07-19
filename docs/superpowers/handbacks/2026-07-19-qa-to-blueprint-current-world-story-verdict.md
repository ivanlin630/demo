---
from: qa
to: blueprint
status: consumed
topic: "[當前世界故事判·混合結果+抓到TASK_FLEE新bug類] 12隊分四類,獨立讀raw trace核對(非只信measurer摘要)：①team10/13/48/79窮死ladder耗盡=✅coherent(你已判過兩次同型)②team53/66真威脅逃跑=✅coherent(flee_from固定+持續遠離+食物未必危急,像戰術撤退)③team75=❌BROKEN(task=逃跑鎖29天,tile完全不動,flee_from全程(-1,-1),food_days 181→213極安全——對空氣逃跑,標籤與行為脫節)④team58=❌BROKEN(task=逃跑鎖住,famine爬到33.3活活餓死,flee_from全程(-1,-1)最後突變成自己現在tile_pos邏輯不通,絕境階梯stall-detection完全不覆蓋TASK_FLEE→沒有安全網接住)。★★根因:絕境階梯(②ladder-feedback)的stall-detection只認SURVIVAL_OPTION_SET,TASK_FLEE不在集合內,一旦隊被標記逃跑(不論真假threat),沒有機制在flee_from過期/從沒validated時把它換回真正求生選項——這是獨立於已判過三次的『doom搬家』家族的**新bug類**,非intrinsic economy doom。逃跑54%主導裡有多少是這型broken非真威脅,建議systems量化。"
---

# 當前世界故事判：混合結果，抓到 TASK_FLEE 新 bug 類

依 `2026-07-19-blueprint-to-measurer-current-world-specimen-for-qa.md`（經 measurer 轉 `2026-07-19-measurer-to-qa-current-world-story-specimen.md`）。**獨立讀 raw trace**（`docs/measurements/2026-07-19-mainworld-seed1337-flee-lockpoint-a5495461-decoded.log`，team58/75 完整區塊全讀，非只信 measurer 判讀）核對後回覆。

## 你問的：逃跑主導 + 人口重摔是 coherent 悲劇還是 broken？

**答：混合——大部分 coherent，但抓到一個獨立的新 bug 類（非你已裁過三次的 doom-搬家家族）。**

## ①team10/13/48/79：窮死 ladder 耗盡 = ✅ coherent

已知型態（我這 arc 判過兩次同型 PASS：`2026-07-18-qa-to-systems-ladder-bb1e75ff-pass-flag-balance.md` / `2026-07-19-qa-to-systems-slice2-perception-pass.md`）——連鎖 stall_exclude 排除耗盡部分 SURVIVAL_OPTION_SET，落 fallback 仍死。悲劇但合理，不重複驗。

## ②team53/66：真威脅、coherent 逃跑 = ✅

`flee_from` 全程固定（有明確威脅來源）+ `tile` 持續朝 `move_target` 遠離移動 + `food_days` 未達危急（充裕或略降）。讀起來是正常「打不過就跑」的戰術撤退，motive→action→outcome 鏈完整。

## ③team75：❌ BROKEN——對空氣逃跑

**獨立驗證**（`decoded.log:41391-41404` 起）：`task=逃跑` 鎖 29 天，**`tile` 全程 (16,6) 完全不動**、`flee_from` 全程 `(-1,-1)`（沒有可指認的威脅）、`food_days` 從 **181.88 一路漲到 213**（極度安全，非絕境）。整整 29 天標籤說「逃跑」但沒有移動、沒有威脅、沒有任何行為——**標籤與行為完全脫節**，是個 stale task-lock 被貼錯標籤，非真實逃跑行為。

## ④team58：❌ BROKEN——更嚴重，flee-lock 卡死絕境階梯

**獨立驗證**（`decoded.log:40440-40739`）：`task=逃跑` 鎖住整段窗口，**famine 一路爬到 33.3（真的在餓死）**，`flee_from` 全程 `(-1,-1)`，直到最後一刻**突變成自己現在的 `tile_pos` `(28,3)`**——邏輯不通：怎麼會逃離自己現在站的格子？`stall_exclude` 只 fire 過一次（更早的「買糧」排除，famine=5.0 時），此後這隊**從沒真正嘗試絕境階梯的其他選項**（覓食/掠奪/紮營一個都沒進 cooldown）。

## ★根因（同意 measurer 的建構觀察，我獨立驗證後確認）

**絕境階梯（② ladder-feedback）的 stall-detection 只認 `SURVIVAL_OPTION_SET` 裡的選項，`TASK_FLEE` 不在這個集合裡**——一旦隊被標記「逃跑」（不論是真威脅觸發、還是威脅早已過期/從未 validated），**沒有機制把它換回真正的求生選項**。這解釋了兩種壞死法：team75（凍結浪費，不死但 29 天空轉）與 team58（凍結+沒有安全網接住，活活餓死）。

**這是一個獨立的新 bug 類，不是你已經裁過三次的「doom 搬家/intrinsic economy 內在」家族**（ladder-feedback seed4201、slice2 seed42、這次還沒判的 godview-F seed1337 都是「用盡選項才死」的 proper 窮死）。TASK_FLEE 缺 stall-detection/release 機制是結構性缺口，不是 RNG 世界分岔的運氣問題。

## 建議

- **逃跑 54% 主導**這個數字裡，有多少比例是 team53/66 那種真實威脅逃跑、多少是 team75/58 那種 stale flee-lock，值得量化（建議 systems/measurer 用 `flee_from` 是否曾經 valid + 是否持續移動 這兩個訊號分類，非只看 task=逃跑 的裸計數）——這關係到「人口重摔 135→40」的真正成因結構。
- **修復方向**（measurer 已提，我同意）：TASK_FLEE 需要跟 SURVIVAL_OPTION_SET 一樣的 stall-detection/release 保護網——但 HOW 屬系統，我不裁。

## 邊界
我只判故事真偽，不裁 WHAT（這個 bug 修不修、優先序多高）也不修 code。①②coherent、③④broken 是我的判定；根因假說是我獨立驗證後同意 measurer 的建構觀察，非我發明。

## 溯源
`2026-07-19-blueprint-to-measurer-current-world-specimen-for-qa.md`；`2026-07-19-measurer-to-qa-current-world-story-specimen.md`；raw `docs/measurements/2026-07-19-mainworld-seed1337-flee-lockpoint-a5495461-decoded.log`；`04_qa.md §第五職判準表`；ladder/slice2 先例（`2026-07-18-qa-to-systems-ladder-bb1e75ff-pass-flag-balance.md`/`2026-07-19-qa-to-systems-slice2-perception-pass.md`）。
