---
from: implementer
to: systems
status: consumed
slice: S7-step3-three-knives
tier: probe
topic: ★三刀交件 77fa2e66（production 0 行）——聯集 92；只①=14 / 只②=71 / 只③=2 / ≥兩把=5，對帳 ✓;★★★刀③的陽性對照【第一版失敗】：它沒抓到我們已知的那顆（ui_logic_test TICKS_PER_DAY:=24.0）—— 修法與根因寫進落地檔;★★命名軸那欄直接把病6 那一族撈出來：宣稱 per-day/per-tick 而使用處無正規化 = 9 顆
---

# ★★★①先講刀③的陽性對照失敗（★這是這一票最該記的一件）

```
第一版刀③【沒抓到我們已經知道的那顆】：ui_logic_test.gd:77  const TICKS_PER_DAY := 24.0
★根因①：我的 const 樣式要求【模組層 + 顯式型別】，而那顆是【函式內 :=】
★根因②：值用【字串】比 ⇒ PROVISION_DAYS 的 10 vs 10.0 被誤判成「不同」（假陽性）
```
⇒ ★★**一把刀同時有假陰性（漏掉已知的）與假陽性（10 vs 10.0），而它的輸出看起來很正常。**
★**修法**：樣式放寬到允許縮排與 `:=`；值改**數值**比對。
★★**修後**：同名 5 顆 ／ 數值等價 3 顆 ／ ★**真不同 2 顆**：
```
MAP_RADIUS     debug scaling_bed.gd:11 = 16   ｜ prod encounter_system.gd:181 = 12   （比值 1.333）
TICKS_PER_DAY  debug ui_logic_test.gd:77 = 24.0 ｜ prod world_state.gd:16 = TICKS_PER_HOUR * 24
```
★★★**而 `TICKS_PER_DAY` 那顆的 prod 值是【導出式】、debug 是【字面值】** ——
**那正是鏡像危險的原因：一邊隨根走、一邊不走，而沒有任何東西比對它們。**

# ★②三刀與母體（★樣式逐條寫進落地檔，不讓「數字隨樣式變」再發生）

```
基底：production module-level const 834 ／ debug const 94
刀① 用法軸（機械）：`\w+ [+\-*]= <已知 const>`                      ⇒ 19
   ★「在 cadence pass 內」【不可機械判定】⇒ 改用可機械代理：
     該函式內有無 day_fraction / cadence_ticks ⇒ ★★NO = 常數是 per-call 速率
刀② 命名軸（heuristic）：PER_TICK|PER_DAY|_RATE|ALPHA|DECAY|REGEN|CADENCE ⇒ 76
刀③ 鏡像對帳（exact）：debug 與 production 同名而【數值不同】          ⇒ 2（修正後）
聯集 = 92（★交集不是判準）
```

## ★★★【只被一把刀抓到】—— 你要的那一格
```
只① = 14   只② = 71   只③ = 2   ≥兩把 = 5   合計 92 ✓
```
★**結論：三刀【沒有】高度重疊 —— 每把都在做不同的事。**
★★**只①那 14 顆是命名軸完全看不見的**（`BLEEDING_MAJOR_DRAIN`／`STAMINA_EXHAUSTED_ATK_MULT`／
`TERRAIN_SPEED_MULT`／`SURVIVAL_BOOST_MAX`…），**全部 `norm=NO`**。
★★★**而我要誠實標刀①的精度**：它靠 `+=`／`*=` 抓，會把
**對陣列/權重做累加**的也抓進來（`HEX_NEIGHBORS`／`HIT_WEIGHTS`／`TERRAIN_WEIGHTS`）——
**那些顯然不是時間量。⇒ 刀①是【高召回低精度】，這是候選清單不是判決，我照票不判定。**

# ★★③命名軸額外欄：**名字 vs 實際語意**（★病6 就住在這一格）

宣稱時間單位（`PER_TICK|PER_DAY`）者 **20 顆**，其中**使用處沒有** `day_fraction`/`cadence_ticks` 的 = ★**9 顆**：
```
★HP_REGEN_PER_TICK(1)         ←★★七病盤點的高優先第一名，這一刀獨立又抓到它
 BLOOD_REGEN_PER_TICK(2)       HUNGER_BLOOD_DRAIN_PER_TICK(1)   STAMINA_REGEN_PER_TICK(1)
 TIME_DECAY_PER_TICK(4)        SECONDS_PER_TICK(0 ★零使用)
 MOVE_TILES_PER_DAY(1)         ←★★★病3 那顆，命名軸也抓到
 FOOD_BRIDGE_MOVE_PER_DAY(3)   TICK_PER_DAY(3)
```
★**而這一欄【只能標可疑】**：**沒有 `day_fraction` 不等於錯** ——
**有些確實是「每次呼叫就該加這麼多」。★★判定靠換根微分試驗，不靠讀 code**（你④寫死的，我照做）。
★★★**但它有一個獨立價值**：**`HP_REGEN_PER_TICK` 與 `MOVE_TILES_PER_DAY` 是七病盤點的高優先兩顆，**
**而這一刀是【從完全不同的軸】獨立命中它們的 —— 兩條路撞到同一顆，可信度比單一路高。**

# ★④硬條款逐條對
- ★**只盤不修**：`git diff HEAD~1 --stat -- scripts/` = **0 行**。
- ★★**不判定會不會漂**：全票沒有一句「這顆會漂」——只有「norm=NO ⇒ 可疑」。
- ★★★**母體先寫死**：三刀樣式與基底數量**逐條寫在落地檔頭**。
- ★**命名軸命中者標了名實一致性**（上面那 20 顆 / 9 顆）。

# ⑤exact path
```
docs/measurements/2026-09-01-s7-step3-three-knives.txt   commit 77fa2e66，★已 push
```
★**b_defer 到期日那件我沒動**（你說走 R² 你開票）。
★★**下一步（換根微分試驗 60 vs 120）是量測員的**，我沒有開始。
