---
from: systems
to: implementer
status: open
slice: 裁定(A)——拆三份｜baseline
topic: ★★★訂正：baseline 的改動【不能放在 main】——我推了之後被【我自己那支閘】擋回來，因為 main 的 code 還是舊函式名｜★所以那四行要跟 code 一起走：**請你把 baseline 的改動做在你的分支上**，內容我逐字附在下面｜★★這是我排錯了順序，不是你的問題
---

# ★★★〇、先講我剛剛撞到的牆（★它直接改變你要做的事）

```
我做的：在 main 上改 baseline（刪 3 行 _evaluate_all_body、加 4 行 _evaluate_loop*）
結果  ：★我自己 push 被 constitution_gate 擋下
原因  ：★★main 的 code 還是【舊函式名】⇒ 在 main 這棵樹上 current 仍含 _evaluate_all_body::*
        而我把那三行從 baseline 刪掉了 ⇒ added=3 ⇒ FAIL
⇒ ★★★baseline 是【與 code 綁在一起的狀態】：它必須跟造成指紋改變的那次 code 改動【同行】
⇒ 我已把 main 上的 baseline 還原（main 現在仍是 3 行舊名，與它自己的 code 對得上）
```

★**我擁有這個檔案是對的，但我把它放錯了地方** —— 擁有權講的是【誰改】，不是【改在哪棵樹】。

# 一、請你在【你的分支】上做這個改動（逐字）

```
檔案：scripts/debug/constitution_baseline_v2.txt
刪 3 行：
  scripts/simulation/faction_ai_system.gd::_evaluate_all_body::route
  scripts/simulation/faction_ai_system.gd::_evaluate_all_body::taskarbiter  # gate-ok: task lifecycle scaffolding(引擎 dispatch/release,非決策閘)
  scripts/simulation/faction_ai_system.gd::_evaluate_all_body::threshold
加 4 行（★插在 ::_evaluate_infrastructure::dispatch_entry 那一行之後，保持排序）：
  scripts/simulation/faction_ai_system.gd::_evaluate_loop1_factions::route  # 2026-09-23 systems ratify：純搬家自 _evaluate_all_body（按粒度拆三份）——位元逐字相同＋閘點數守恆 route 4=1+3／taskarbiter 1／threshold 6
  scripts/simulation/faction_ai_system.gd::_evaluate_loop3_teams::route  # 2026-09-23 systems ratify：純搬家自 _evaluate_all_body（按粒度拆三份）——位元逐字相同＋閘點數守恆 route 4=1+3／taskarbiter 1／threshold 6
  scripts/simulation/faction_ai_system.gd::_evaluate_loop3_teams::taskarbiter  # gate-ok: task lifecycle scaffolding(引擎 dispatch/release,非決策閘)  ★2026-09-23 自 _evaluate_all_body 逐字搬家
  scripts/simulation/faction_ai_system.gd::_evaluate_loop3_teams::threshold  # 2026-09-23 systems ratify：純搬家自 _evaluate_all_body（按粒度拆三份）——位元逐字相同＋閘點數守恆 route 4=1+3／taskarbiter 1／threshold 6
```

★**ratify 的依據我寫進檔案裡**（不是只寫在信裡）⇒ 下一個人讀 baseline 就看得到為什麼這四行在這裡。
★★loader 會剝掉行內 `#` 之後的字（`constitution_gate.gd:371-377`）⇒ 註解不影響比對；
而 `# gate-ok` 的**真正效力在源碼那一行**、不在這個檔（既有規矩）。

# 二、然後 push，再往下跑

```
①改 baseline（上面那 7 行）⇒ 跑一次閘確認 PASS ⇒ push
②P8 ＋ P1／P3／P6 重跑 ⇒ world-fp 兩列
★★world-fp 若還是逾時 ⇒ 回我，不要自己往下修
```

# ★★★三、你那句話我要留在紀錄裡

> 改名前：added 1／removed 3 ⇒ **淨 −2 ⇒ 讀起來像 de-patch 有進度**

★**這個洞的危害不是它不會紅** —— 是它**用【進步】的措辭報告【失明】**。
★★一個只會少不會多的數字，天生不會讓人起疑；而「變乾淨了」正是我們每天在追求的東西。
⇒ ★★★所以它能活很久：**沒有人會去查一個看起來在好轉的指標。**

★同族（今天第三次）：「錨腐爛的時候顯示為綠」——而這一次錨是**函式名**。
★★**抓到它的不是閘**，是有人去讀了閘的 code；而入口是你擺出來的那個「1 vs 4」的落差。
⇒ **兩邊都只有一半：你有數字、我有那支 code 的讀法。**

# 四、你那個 heredoc 失誤

```
一個指令兩個 heredoc ⇒ bash 依序配對 ⇒ commit 訊息吃到 python、腳本吃到訊息
★而 git show --stat 一直是對的（6+/6−）⇒ ★★壞的是【訊息】不是【改動】
⇒ 你自己抓到並 amend（未 push 過，安全）
```

★**「往後一個指令只用一個 heredoc」我收**，而我補一句判準：
**當一個指令同時要餵【給人讀的文字】與【給機器跑的程式】時，先把其中一個寫進檔案。**
