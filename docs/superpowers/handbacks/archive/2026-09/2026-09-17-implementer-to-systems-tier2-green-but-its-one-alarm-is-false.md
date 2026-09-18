---
from: implementer
to: systems
status: consumed
slice: tier2 全床掃描 ｜ **閘轉綠了，而★它這輪唯一那個警報是【假的】**
topic: ★**閘已綠**：`[TIER2-STALENESS] PASS 上次全床掃描 0 天前`（戳記 `1789584601`）｜★**孤兒驗過**：`GODOT-COUNT=0`（**逐 PID 看，不是看 exit code** —— 該檔頭自己的規矩）｜★★**但這輪印的「由綠轉紅 1 支」是假警報**：`game_sim_test.gd（green → 60）` —— **`60` 是【秒數】，不是判決**；那一列的**判決欄是空的**，而同一支床在**另一列是 `green`**｜★★★**根因是續掃表有【重複鍵】**：4 支床各有 2-3 列（`data_test` 3、`lod_phase_invariance` 3、`headless_test` 2、`game_sim_test` 2）⇒ **diff 比的是一個鍵不唯一的表**｜★**所以它能造假警報，就同樣能【蓋掉真的】** —— 這是 `.claude/hooks/*` ＝你的格，我沒動
---

# ① 閘的狀態（★**掠奪票那支紅已經消掉**）

```
raw：docs/measurements/2026-09-17-tier2-bed-sweep.txt
[tier2] 完成：143 支｜★綠→紅 1 支｜baseline 已更新｜時間戳已蓋
[tier2] baseline 只收判決列:收 135 支｜★丟 8 支 no-verdict(timeout/hang/crash) 或 CONTENDED
複驗：bash .claude/hooks/bed-sweep-tier2.sh --check-staleness
      ⇒ [TIER2-STALENESS] PASS 上次全床掃描 0 天前（上限 7）   rc=0
孤兒：GODOT-COUNT=0（★逐 PID 查，不是讀回傳碼）
```
⇒ **掠奪 merged 樹的三支紅，現在剩兩支**：`bed-arm`（基線）＋`defer-open`（**只有它需要你裁**）。

# ② ★★那個「綠→紅」是假的

```
印出來的：  [tier2] ★★由綠轉紅：scripts/debug/game_sim_test.gd（green → 60）
表裡的兩列：
  行 39 ： scripts/debug/game_sim_test.gd  <空>   60    CONTENDED(collisions=2)
  行140 ： scripts/debug/game_sim_test.gd  green  117   CONTENDED(collisions=2)
```
★**`60` 是秒數欄**：那一列**判決欄是空的** ⇒ 比對時拿到空字串，
**而訊息把它當成「新判決」印了出來** ⇒ 畫面上長得像「這支床紅了」。
★★**準確地說**：**表裡沒有任何一列說它紅了** —— 一列 `green`（117s）、一列**沒有判決**，
baseline 收的是 `green`。
★★★**而「沒有一列說它紅」不等於「它是綠的」** ——
**那一列之所以沒有判決，正是因為那一次跑沒有跑出判決**（`CONTENDED(collisions=2)`）
⇒ **它現在的真實狀態，這張表答不出來**；能確定的只有「**這個警報不是從一個紅判決來的**」。

# ③ ★★★真正的根因：**續掃表的鍵不唯一**

```
awk 統計 .bed-sweep-inprogress.tsv：
  scripts/debug/data_test.gd               3 列
  scripts/debug/lod_phase_invariance_test.gd 3 列
  scripts/debug/headless_test.gd           2 列
  scripts/debug/game_sim_test.gd           2 列
  （空判決列：1）
本輪 log 也看得見同一件事：
  [tier2] ＋新床：scripts/debug/data_test.gd（not-a-bed）
  [tier2] ＋新床：scripts/debug/data_test.gd（not-a-bed）      ← 同一支印兩次
  [tier2] ＋新床：scripts/debug/lod_phase_invariance_test.gd（timeout）   ×2
```
⇒ **續掃是【append】不是【update】**：同一支床每被重跑一次就多一列，
而 `bed-triage-sweep.sh:130` 的跳過判準（`green|red|no-verdict|timeout-persistent`）
**讀到哪一列取決於順序**。

★**而這一點比那個假警報嚴重**：
**這張表是 tier2 唯一的比較基準，而它能把一支床同時記成兩種狀態。**
★★**能造出假警報的機制，就能【蓋掉真的】** —— 順序反過來的時候，
**真的 green→red 會被同一支床的舊 green 列吃掉，而畫面上什麼都不會出現。**
★★★**而 tier2 的整個價值就是「只在綠→紅時吵人」** ⇒ **它的訊號可信度等於這張表的鍵唯一性。**

# ④ 我沒動的東西 ＋ 建議的修法形狀

`.claude/hooks/*` ＝ **你的格**，我只報不改。**修法形狀（不是補丁）**：
```
(a) 寫入改成【以 bed 路徑為鍵覆寫】而不是 append
    —— ★★而「清掉重來」是 2026-09-08 明文禁的（它會銷毀續掃成果）
       ⇒ 要的是 upsert，不是 truncate。
(b) 比對前先驗【鍵唯一】：重複鍵 ⇒ ★印「不可判」而不是印一個警報
    —— ★★★「我不知道」和「沒有變化」在現在這版畫面上長得一樣。
(c) 空判決欄不得參與 diff（它現在會被當成一個新狀態印出去）
```
★**順帶**：`(green → 60)` 這個字面本身就是證據 —— **一個判決欄位印出了秒數**，
⇒ ★★**那一行的格式字串與它讀的欄位對不起來**，而**沒有任何東西會因此變紅**。

# ⑤ 現況彙整（★**兩件在等你一句**）

```
① feat/raid-expected-value @ eebac5649：★只剩 defer-open 需要你裁
     （desperation-violence-cell-remeasure：先做重量 vs merge 後排它＋重裁 defer_until）
② feat/walkthrough-v2 @ merge 完成：★兩列中文字面要你裁，★★而它有時效
     （用戶正在抓種子錯；重生成會把「兩個都叫還能撐幾天、值差三倍」的假陽性帶進去）
③ feat/grudge-ledger-a @ 7f2d8ae2d：FAIL 只剩 bed-arm（＝基線）⇒ 可 merge，等你點
機器：FreeMB 9292、用戶遊戲仍開著；本輪三個長跑都跑完沒被殺，孤兒 0
```
