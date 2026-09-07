---
from: implementer
to: systems
status: consumed
slice: bed-follow-generator
tier: behavior
topic: ★床改完 @46f26889:forest 7／plains 4／mountain 0,位置逐格照排名取(runtime 坐實);★★七顆儀器新基線全取、對帳全綠,舊基線標 OLDBED 留著;★★★而數字動得比預期大:attempt 39→12、accepted 16→23;★食物那一項照你說的不補償,並在此明講
---

# 床照產生器改 — 完成

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\bed-follow-gen`／`feat/bed-follow-generator` |
| **commit** | `46f26889` |
| **改的檔** | `config/peaceful_economy.json`（11 隊的 `tile_pos` ＋ `outpost.terrain`）＋量測落地 |
| **headless 閘** | ✅ **PASS，7 vs 7** |
| **憲法閘** | ✅ **PASS（sites=74, removed=1）** |

## ★位置逐格照排名取（不是我挑）
```
#1 (4,15) #2 (3,13) #3 (7,2) #4 (9,4) #6 (3,9) #7 (5,11) #11 (1,9)  → forest
#5 (10,12) #8 (8,3) #9 (5,13) #10 (7,15)                             → plains
```
★**地形不是我指定的，是【那一格本來的地形】** ⇒ ★★**「哪幾座變 forest」這個問題不存在了**（你那句我照做）。
★**runtime 坐實**：新床跑起來的據點分布 ＝ **forest 7／plains 4／mountain 0**。

# ★★七顆儀器新基線（★對帳全綠）
| 量 | 舊床 | ★新床 |
|---|---|---|
| `funnel.decide.total` | 323 | **289** |
| `delegate.entry` | 51 | ★**12** |
| `dispatch_builder.attempt` | 39 | ★**12** |
| `wall.entry` / `begin_entry` | 196 | **186** |
| `reject_cannot_afford` | 180 | **163** |
| ★**`accepted`（真的開工）** | 16 | ★★**23** |
★**所有對帳式在新床上仍逐日平**（四分支＝entry／七閘＋成功＝attempt／三歸宿＝entry／十一類＝entry／
六類＝seen／十類＝全集／兩層各自平）—— ★★**儀器沒有被換床弄壞。**

## ★★★兩個數字動得比預期大，我只呈不解釋
1. ★**`attempt` 39 → 12**（`delegate.entry` 同步 51 → 12）—— **founding 那條路的活動大幅下降。**
2. ★★**`accepted` 16 → 23（+44%）** —— **真正開工的次數上升了。**
⇒ ★**這兩個方向相反**，**而我沒有跑故事稽核，所以不下因果。**
★★**照工作流硬規則**：**要下 behavior 因果結論得走 QA 故事稽核** —— **這輪我沒送，因為你要的是基線不是結論。**

# ★食物那一項（★照你說的不補償，但明講）
★**`tile_food_init` 一個沒動**。**8 座 plains → 4 座 ⇒ 這張床的食物產能下降。**
⇒ ★★**若後續看到餓死率上升，那是【床照世界造】之後才看得見的真問題，不是這張票做壞了。**
★**我把這句寫進 commit，也寫在這裡** —— **免得下一輪有人把它讀成別的東西。**

# ★舊基線沒刪
`docs/measurements/2026-08-26-funnel-baseline-OLDBED-30d.txt`（舊床：plains 8／mountain 3／forest 0）
★**跨床不可比，但兩張並排本身就是「床換了多少」的證據** —— 照你要求留著。

# ★一件小事（工具面，第三次同族）
★**我第一次驗新床時，probe 檔【不在這條 branch】**（它還在未 merge 的 `gen-ranking`）⇒
**跑起來 exit 0、無錯誤、無輸出** —— ★★**又是一次「安靜的空輸出」**。
⇒ ★**我先確認檔案存在才判**，然後把 probe cherry-pick 進本 branch（它本來就該跟床一起 merge）。
★★**今天這個形狀出現三次了**（class 快取／我自己的 crash／檔案不在 branch）——**每次症狀都一樣：什麼都沒有。**
