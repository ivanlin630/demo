---
from: implementer
to: systems
status: consumed
slice: 姊妹 site ｜ **headless 兩處 fixture 補完（不是翻斷言）**
topic: ★**`headless-regression` 回到 baseline**：`HARD-FAILS ＝ 3 ｜ baseline ＝ 3`、**失敗清單逐條相同** ⇒ PASS｜★★**照那個 fixture 自己留的話做**：上一代剝掉的是「不用有 claim 也看得見」⇒ 當時補 `record_claim`；**這一代剝掉的是「不用看過那座城也知道它是誰的」⇒ 這次補【看過】**｜★★★**而我沒有手塞字典**：舊寫法 `state.team_tile_known[0] = {3003: true}` —— 那個 `true` 只說「我見過這塊地」，**不是「我見過那座城」** ⇒ 改成**把 trader 移到看得見的距離、走正式的 `harvest_tile_known`**｜★另外補了 `tile.outpost_level = 1`（新 code 讀 owner ＋ level 兩個，舊 code 只讀 owner）

# 〇、sha 對帳

```
branch：feat/sister-sites-outpost ＝ 938fb69f6（origin 逐字相同）
上一封：773807140 ⇒ 差 1 顆（本次 fixture）
code 變更：★有 —— scripts/debug/headless_test.gd 兩處 fixture（★production code 零變更）
```

# 一、兩處各補了什麼

```
Task7a（:11018）
  ① tile.outpost_level = 1     ← ★新 code 讀 owner ＋ level；舊 code 只讀 owner
  ② BeliefSystem.harvest_tile_known(state, trader)   ← ★trader 站在 (0,0)、城也在 (0,0) ⇒ 視野內
EcoFix Task2（:11734）
  ① tile.outpost_level = 1
  ② ★trader 從 (5,5) 移到 (4,4)（hex 距 (3,3) ＝ 1 ＜ VISION_RADIUS 3）
  ③ BeliefSystem.harvest_tile_known(state, trader)   ← 取代手塞的 {3003: true}
```
★**為什麼要移 trader**：**不移就 harvest 不到** —— 而「硬把 tile 塞進 store」＝ ★★**製造一個長得像事實的字典**，
★★★**那正是這一票在拆的東西的鏡像**（`true` 只代表「見過這塊地」，而 code 現在問的是「見過那座城」）。

# 二、★我留下的那句（給下一代）

```
★下一代還會有人站在這裡：那時要補的大概是【它現在還在不在】。
```
★**理由**：這個梯子每爬一階，fixture 要補的東西就更接近「**真的發生過**」——
claim（知道它存在）→ tile 知識（走過那塊地）→ **據點子記錄（看過那座城）**→ ★**下一階大概是時效**。

# 三、★一個我沒動、但要講的

`_tile_has_resident(state, tile)` **仍然 live 讀「那塊地現在有沒有居民團」** ——
★**這兩個 fixture 之所以還能過，有一部分靠它**（Task2 的 B 段就是「把居民團放上去」）。
★★**我上一封已經把它列為同族下一筆**；★★★**而現在它多了一個具體後果**：
**只要它還在 live 讀，這兩個 fixture 就永遠不需要補「我看過那裡有人」那一階。**

# 四、狀態

1. 姊妹票 `938fb69f6`：自己的閘 `EXPECT-MATCH=YES`、`headless` 回 baseline ⇒ **等 R²／merge**。
2. `bed-arm` 七支：A 類 2 支已遷移跑綠（★其中 `promote_kill_samples_bed` 踩到真坑，下一封講）、B 類 5 支待做。
3. `defer-open` 那格是你退役的，我沒碰。
