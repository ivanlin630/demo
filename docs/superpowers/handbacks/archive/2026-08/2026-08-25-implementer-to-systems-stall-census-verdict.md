---
from: implementer
to: systems
status: consumed
slice: convoy-return-task-authority
branch: feat/convoy-return-task-authority @ 051aaa28 (pushed)
topic: ★母體改【直接普查】後判決落地:偵測器量到的是真事實,但「abandoned」這個名字是錯的——10 次開火落在 3 個工地、收盤普查那 3 個【全部蓋完】;★★所以磚若照現況收料,會把【慢工】記成【執行型失敗】=毒化失敗記憶;★三件要你裁
---

# 停滯偵測：普查判決 ＋ 三件待裁

**床**：`convoy_rewrite_path_bed`（`peaceful_economy` / seed 1337 / 90 天）
**重跑**：`$env:LW_CONFIG="peaceful_economy"; $env:ADHOC_DAYS="90"; .\tools\godot.ps1 --headless --script scripts/debug/convoy_rewrite_path_bed.gd`
★**開發回饋，非驗收**——驗收數字仍請 measurer 產。

---

## §1 ★我上一封的假說被我自己的量測打掉（先講這個）

上一封我說「`progress` 54→0 是因為 `build_tile()` 在 corvee_site 與腳下之間切換 ⇒ 拿 A 工地的進度跟 B 工地比」，
並照此把 baseline 綁上工地身分（`commit_stall_site`）。

★**修完之後，數字一個都沒變**（`stall_fire.construction` 仍 10，`release_clean 67 / release_with 118 / hold_blocked 11` 全同）。
⇒ **site 根本沒在換。54→0 發生在【同一塊地】上。** 我的假說錯了。

（修本身留著——它防的是真的可能發生的事，且有 sample 的 `site` 欄佐證現在看得見了；
但**它不是這 10 次的解釋**，我不把「順手修的東西」算成「找到的原因」。）

---

## §2 ★★母體改成【直接普查】，判決才站得住

前兩輪我連續用**推導**的母體，兩次都錯：①拿紮根子集當所有 construction ②拿 `construct.start − complete` 去比，
**但那兩顆計數器涵蓋哪些施工路徑，我從來沒驗過**。
⇒ 改成**收盤掃全圖 tile**，數 `construction_ticks_left > 0` 的工地。**構造性事實，不是推導。**

```
★普查·收盤仍未完工的 tile = 0   []
【所有 construction】start = 19 / complete = 19 ⇒ 未完工母體 = 0     ← 普查與計數器【互相印證】
commit.stall_fire.construction = 10
```

★**順帶洗清一件事**：中途 dump 抓到 `普查 = 3 ["6,10(team=4)", "8,10(team=3)", "10,6(team=5)"]`，
同輪 `start 11 − complete 8 = 3` ⇒ ★**`construct.start/complete` 的定義被普查獨立證實是對的**。
**是我用錯它，不是它壞掉。** 這點我要講明，免得下游把它列進黑名單。

---

## §3 ★★★判決：偵測器量到真事實，但**事件的名字是錯的**

10 次開火，**site 欄顯示只落在 3 個工地**（`6,10` / `8,10` / `10,6`），每個工地開 3–4 次：

```
{ team 4, site "6,10", waited 2400, progress 0, baseline 54, tick 2500 }
{ team 4, site "6,10", waited 2340, progress 0, baseline  0, tick 4840 }
{ team 4, site "6,10", waited 2340, progress 0, baseline  0, tick 7180 }
{ team 4, site "6,10", waited 2380, progress 0, baseline  0, tick 9560 }   ← 同一塊地，四次
```

**兩個事實同時成立**：
1. 開火時 `progress` **一律 0** ＝ `ticks_left == total` ＝ **一個 person-tick 都沒進去過**，且持續 ≥ 耐性窗（~2340 tick ≈ 23 天）
   ⇒ ★**「零進度」是真的，不是儀器假象。**
2. ★但**收盤普查 = 0** ⇒ **那 3 個工地後來全部蓋完了。**

⇒ ★★**`construction_abandoned` 宣告的是「放棄」，實際是「停很久之後復工完成」。**
**名字與事實不符**，而磚的記錄側是**照名字接的**。

★**風險講白**：磚若照現況收這個料，會把**慢工**記成**紮根執行型失敗**寫進結構身份記憶
⇒ **未來對同型工地折價** —— ★**用一個「其實會成功」的經驗去壓抑後續嘗試，那正是失敗記憶最怕的毒。**
⇒ ★**在你裁定前，我不把磚的消費端接上這個事件。**

---

## §4 三件要你裁（都是設計選擇，我不自己選）

| # | 待裁 | 選項 |
|---|---|---|
| ① | **事件語意** | (a) 改名 `construction_stalled`，磚**不收**（另找真·放棄訊號）／(b) 只在**承諾真的消失**時才發 `abandoned`（換 task 且不 `serves`／工地易主）／(c) 維持，但磚只收**終局仍未完工**的那些（需延後判定） |
| ② | **重複開火** | 同一工地每個耐性窗開一次（4 次/地）。要不要 **per-site latch**（發過就不再發，直到進度真的動過）？ |
| ③ | **範圍** | 事件對**所有 construction** 發（含 `upgrade_facility`），但磚的 acceptance 第三面**只問紮根**。要事件帶 action 讓消費端過濾，還是把 acceptance 改寫成「任何 construction」？ |

★**我的傾向（僅供參考，不當決定）**：①(b) ＋ ②latch。理由是**只有 (b) 讓事件名等於事件事實**，
而 ②的重複本質上是「同一件事被數了四次」——**任何靠它算比率的下游都會被墊高。**

---

## §5 ★另一件不是我能下結論的：那 3 個工地【70 天零進度後才完工】

`tick 2500 → 9560` 之間，`6,10` 一直是 0 進度，**然後在收盤前蓋完**。
這聞起來像手不聽腦那一族（committed 但工作面沒人上），**但我不下因果結論**——
★這需要 specimen trace 逐隊讀，屬 **measurer / QA 故事稽核**，不是我自測能斷的。
**我只把坐標交出來**：`peaceful_economy` seed 1337，team 3/4/5，tile `8,10` / `6,10` / `10,6`。

---

## §6 閘況

| 閘 | 結果 |
|---|---|
| 憲法 | **PASS**（`sites=74, removed=1`） |
| `commitment-field-scan` | **17/17 PASS**（★新欄 `commit_stall_site` 是**被這個掃描抓出來**的，不是我記得補的——它就是為此存在） |
| `decision-entry-scan` | **4/4 PASS** |
| headless | **8 ＝ baseline，0-new** ✅（3 `[FAIL]` ＋ 5 `Assertion failed`）　★上一次我用 `Select-Object -Last 15` 濾輸出 ⇒ **前面的 FAIL 被截掉，那次的「1 個 FAIL」是【濾器造成的】不是事實**，已全量重跑。　附帶：`Invalid get index 'world'` ×7 出自 `resource_system.gd:438 own_granary_tile`，**非本 slice 觸及的檔**，pre-existing |
| det×3 | 跑中 |
| measure | ★**仍缺同床 main baseline** ⇒ §N ①「有沒有下降」**依舊不可判** |

## §7 ★我自己那個掃描的界限（免得 17/17 被讀成窮盡）
候選是用**名字形狀**抽的（`_site|_target|_phase|_cache|_task` 等後綴），**不是語意推導**。
一個叫 `escort_of` 的承諾欄位**永遠不會成為候選**。
⇒ `17/17` 的意思是「**形狀規則找到的候選都分類了**」，**不是「TeamData 裡所有承諾欄位都分類了」**。
★**已寫進 script 檔頭當已知限制** —— **高估自己射程的閘，只會被信任一次。**
