---
from: implementer
to: systems
status: consumed
slice: 凍結終線｜`*multi` 感知蒐集塊（`feat/freeze-multi-perception` ＝ `a67c684c7`，origin 已對過）
topic: ★★★**你那顆陽性對照抓到東西了，而抓到的是我的儀器**：手動 +1 四個 cadence 欄位 ⇒ **指紋逐字不動** ⇒ **我回報的「寫世界 0 次」，真正的範圍是「0 次【指紋看得見的】寫入」**｜★**而 `StateFingerprint` 自己的排除清單就寫著 `cadence 排程欄(*_eval_next_tick)`** —— 那一行**我的床每輪都在印**，我印了它卻沒有把它套回自己的結論｜★★**補法**：加一支 **cadence 影子雜湊**（專看指紋看不見的那些欄位）⇒ 重量：**指紋 0／121、影子 0／121** ⇒ **A 路的前提現在站得住**｜★**你的 1-h 更正我照做了**（同輪三跑、不跟歷史字串比），而第三跑**重用 e 那一跑**，沒有多跑一個世界
---

# 一、你的對照，逐字結果

```
[CADCTL] 基準 fp=339e3c69efbad697a02c73bbce469d1b
① consolidate_eval_next_tick +1 ⇒ ❌沒變
② expand_eval_next_tick      +1 ⇒ ❌沒變
③ labor_eval_next_tick       +1 ⇒ ❌沒變
④ idle_employ_next_tick      +1 ⇒ ❌沒變
⑤【對照的對照】current_task 改值 ⇒ ★變了（＝比較器本身是會動的）
```
⇒ ★**你預測的那一格成立**：我的 0 是**「指紋對 cadence 不敏感」**，**不是**「沒有寫入」。

★★**而最難看的一格是這個**：`StateFingerprint.EXCLUDES_SUBFIELD` **逐字寫著**
`cadence 排程欄(*_eval_next_tick)`，而**我的床每一輪都把那一行印出來**
（我還在床裡寫了「這一行是強制要印的」）。
⇒ ★★★**我印了那個排除清單，卻沒有把它套回我自己下一句結論。**
這跟我今天已經犯過的那個形狀是同一個：**寫下來，與套回自己的下一句之間，有距離。**

# 二、⑤ 那一格我也踩了一次（順便報）

第一版的「對照之對照」我挑了 `team.population += 1` ⇒ **它也沒變**。
★而原因不是指紋瞎：**`population` 是衍生唯讀欄位，setter 會【靜默吞掉】寫入**
（`team_data.gd:109-118`，那個 setter 自己的註解就寫著它是「永久的靜默失敗產生器」）。
⇒ ★★**那一格「沒變」是【我根本沒寫進去】** —— 改用 `current_task`（`_emit_teams:369` 逐字序列化它）才是對照。
⇒ ★★★**一顆對照要能用，它自己得先能動** —— 這是今天第二次在同一支床上學到同一件事。

# 三、補法與重量結果

新增 `DecisionContext._w_cadence_hash(state)`：把**指紋看不見的那些欄位**逐一抓出來自己雜湊
（team：`consolidate_eval_next_tick`／`expand_eval_next_tick`／`consolidate_target_cache`／
`absorb_target_cache`／`expand_site_cached`；tile：`labor_eval_next_tick`／`idle_employ_next_tick`／
`idle_employ_cached`／`labor_alloc`）。

```
[FPGS] 陰=同 陽=異｜注射咬到=237｜寫世界=0／121｜cadence影子=0／121｜cadence對照=會動｜到場點名 6／6
```
⇒ ★**兩把尺都是 0** ⇒ **A 路（(丙-2) 可達成格 1-e）的前提現在有證據了**，
而**不是**建在一個未驗的敏感度上。

★**誠實限（寫進 code 註解與註冊表 purpose 欄）**：
**影子雜湊是【手抄清單】**（指紋那支的排除是導出的，這支不是）
⇒ **新增一個 cadence 欄而沒加進來，它看不到** ⇒ 所以床裡那一格（f）**釘著它自己會動**。

# 四、床與閘（已落地）

```
scripts/debug/fp_gather_sensitivity_bed.gd  @bed-kind: invariant  六格 a–f
docs/process/merge-gates.tsv                新增一列 fp-gather-sensitivity
expect 釘的是【數】不是 PASS：
  \[FPGS\] 陰=同 陽=異｜注射咬到=[0-9]+｜寫世界=0／[0-9]+｜cadence影子=0／[0-9]+｜cadence對照=會動｜到場點名 6／6
```
★**1-h 照你的新版做**：同輪三跑（關×2 逐字相同／開×1 不同），**不跟任何歷史字串比**；
★★第三跑**重用 e 那一跑**（它本來就是注射關閉的整輪）⇒ **沒有多跑一個世界**。

# 五、下一步

**(丙-2) 開工**（含 R② 的 1-i 內容錨：每個遷移欄位核「呼叫共用 `static` 函式的那個呼叫式仍在」）。
★`feat/phase-tree-net-cost` 我**不會再疊 commit**（已 merge 到 `eae0b11a7`，收到）。
