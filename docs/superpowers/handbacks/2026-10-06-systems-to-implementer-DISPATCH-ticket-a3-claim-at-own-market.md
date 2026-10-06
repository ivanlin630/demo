---
from: systems
to: implementer
status: open
slice: 票 A3：領取在自家市集被「自家市集不自交易」擋掉（先分辨、再歸位、加失敗記號）
topic: ★派工，R² CLEAN（`25c2c5a48`，兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-a-committed-action-must-change-the-world-HOW.md` §4 A3｜★序 ＝ **tap 對準① → 本票 → E2E**（其餘票 A／B 之後再排）｜★不等任何 tap
---

# 一、先分辨（用觀察輪那 4 個 tick 當陽性對照）

```
seed 1337、30 天觀察輪那一份；Team7 t28630／28911／29194／29288 committed 領取、coin 87→96 幾乎不動
⇒ 每個 tick 印：隊在哪、claim 在哪個 tile、那個 tile 的 outpost_owner 是誰、隊有沒有站上那一格
 ① 沒到場 ⇒ 移動層的事 ⇒ **回報我，不在本票修**
 ② 到場了而 claim 在自家市集 ⇒ `interaction_system.gd:933-934` 的早返回擋在 `:946` 領取之前 ⇒ 本票修
★前提已核（別被名字騙）：「領取」的 to_task 本來就回 TASK_TRADE（`options.gd:55`）；task＝貿易是設計
```

# 二、②成立時的修法（藍圖裁 `7c75aa27a`）

```
★執法點歸位：把 `_claim_pending_here(state, visitor, tile)` **移到** `:933` 那個早返回**之前**
  ★R² 讀過它本體（`:1054`）：不依賴 `:933` 之後才算出的變數 ⇒ 搬動結構上安全、不影響非自家市集那條路
★不准：在早返回裡加「是領取就不擋」的例外分支（規矩沒錯，位置錯）
```

# 三、失敗記號（★與 A2 共用一個形狀，A2 還沒派 —— 你先定形狀，A2 照抄）

```
`failure_memory.gd:96` 逐字：領取「沒有『領不到』的事件」⇒ 補一個記號：到場而沒領到／逾時沒到
⇒ ★形狀要能給 A2（「掛單到期而沒成交」）共用：**一種事件、帶動詞與原因**，不是兩種
⇒ 補上後把 `:96` 那一行的判定改掉（它自己寫著「補上 miss 記號時這格要改判」）
```

# 四、驗收

```
P1 自家市集有待領資產的隊 committed 領取 ⇒ N tick 內 coin **必增**（N 從到場移動時間推導）
   母體地板：claim 真的在自家市集（印 tile 與 outpost_owner）
   ★負對照：把 `_claim_pending_here` 移回早返回之後 ⇒ 必紅
P2 非自家市集的領取照舊（不准被這次搬動弄壞）
P3 失敗記號：佈置「到場而沒有可領」⇒ failure_memory 有那一筆；★反向：領到了 ⇒ 沒有那一筆
P4 fp：先量（行為改了，fp 多半會變 ⇒ 變了就基準與改動原子落地，沒變寫理由）
```
