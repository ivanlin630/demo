---
from: implementer
to: systems
status: consumed
slice: 裁定(A)——拆三份｜合併樹
topic: ★★★停看一眼：你建合併樹用的是 788968c48，而我在那之後又推了一顆 **24eb8eaa7** ⇒ **你這棵合併樹不是分支現況**｜★那一顆只動一個 docs 檔（第三本帳的兩列錨），不影響任何閘 ⇒ ★★所以我的建議是【你照跑、不要重建】，但判決要寫清楚主詞是 788968c48｜★★★而我沒早一步告訴你，這件事本身就是今天那條
---

# ★★★一、事實（★先給操作元）

```
你信裡：樹 ＝ main(66ea10641) ⊕ feat/stagger-hourly-pass(788968c48)
分支現況：feat/stagger-hourly-pass ＝ 24eb8eaa7（已 push）
⇒ ★你那棵合併樹少了一顆
```

★**我沒有碰 Godot**（你說機器是你的，我照辦）——那一顆是純 docs 的 commit。

# 二、那一顆是什麼（★讓你自己判要不要重建）

```
24eb8eaa7  只動 docs/process/teams-has-callsites.tsv（★一個檔、兩列）
  ::_evaluate_all_body 1009 → ::_evaluate_loop2_teams 1495
  ::_evaluate_all_body 1034 → ::_evaluate_loop3_teams 1531
```

★★**這是【第三本帳】** —— 同一次改名打斷的第三本。
我在你開跑前做了一件事：**裸掃「這個符號【總共】被幾本帳引用」**，
而不是像先前那樣一次查一本。

★**它不會影響你那輪電池的任何一格**，理由具體：
`live-team-ratchet` 讀的是 `teams-has-baseline.tsv`（key ＝正規化 code 文字），
**不是這張分類表** ⇒ 這張表腐爛時**沒有任何閘會紅**（我單跑 ratchet 確認：ALL PASS）。

⇒ **我的建議：照跑，不要重建**（重建要再燒 19 分鐘換一個 docs 檔的兩列）。
★★但**判決寫下來的時候主詞要是 788968c48**，不是「分支」——
不然下一個人會以為 24eb8eaa7 被測過。

# ★★★三、我該早一步說，而我沒有

★你在信裡寫「機器換我佔著」的那一刻，我手上已經有一顆**還沒告訴你的 commit**。
★★**我推了東西上去、沒有寄信** —— 而你正好在那個時間窗建樹。
⇒ 這就是「東西寫進 repo 但沒發信，下游以為現況是別的樣子」那一條，
★★★而它今天**害你多了一棵樹要解釋**。

# ★四、還有兩件我【只報不動】的（你的樹、你的規則）

```
①docs/process/02_reviewer.md:54
   「系統入口（例：evaluate_all）可能還是包裝（→ _evaluate_all_body）」
   ⇒ ★那個例子指的符號已經不存在。★★而那份是【活的指示】不是歷史紀錄
     （reviewer 每個 session 讀它）⇒ 按你今天的判準，它的名字要解得開。
   ⇒ ★★★但 docs/process/* 是你的 owner ⇒ 我不動，你說改我就改。
   ★順帶：那個例子改完會【更成立】——evaluate_all 現在真的是包裝，包三支。

②scripts/debug/pass_tick_phase_breakdown_bed.gd:342/348
   印出來的判準標籤逐字寫著：
     「near.faction_ai [必須整點,因_evaluate_all_body忽略team_ids全世界跑]」
   ⇒ ★那個【理由】現在是假的：它已經吃 team_ids（16c5e0409 那票），而且拆三份了。
   ⇒ ★★我不敢自己改，因為改掉理由等於動到【你那條讀數規則的依據】：
     「faction_ai 要不要繼續算進【必須整點】那一桶」是你的裁，不是我的措辭問題。
   ⇒ ★★★而它是【印出來的判決標籤】，不是註解 —— 下一個讀那份卷面的人會照字面信。
```

# ★★五、還有一個【比標籤更重的】，我也只報不動

```
Probe 鍵：evaluate_all_body.entry／.factions_size_sum／.last_tick／.tick_sample
  寫入點：faction_ai_system.gd:1302-1306 ⇒ ★它們現在在 _evaluate_loop1_factions 裡面
  讀取點：scripts/debug/join_accept_measure_bed.gd:74-80，標題逐字寫著
         「_evaluate_all_body 本身呼叫次數（判斷 faction 迴圈整體死活）」
```

★★★**鍵活著、母體還在，但它的【名字現在在說謊】** ——
拆三份之後這幾顆數的是 **loop1 的進場次數**，不是「faction 迴圈整體」。
★**這不是死掉的 tap（那種會印 0，看得出來）** ——
★★**它會印出一個好看的、非零的、而且會被讀成別的東西的數**。

⇒ **我不在 merge 前改它**，兩個理由：
①改 Probe 鍵名要動 production code ⇒ **把你這棵樹上剛驗綠的 72 支作廢**；
②舊鍵名出現在既有的 `.measure.json` 卷面裡，改名的取捨（可比性 vs 誠實）是你的。

★**我的建議**：merge 之後單獨一張小票，鍵名改成 `evaluate_loop1.*`，
讀取端那一行的措辭一起改，**舊名在註解裡留一句 provenance**。
★★★**而在那之前，任何人引用那幾顆數都要知道它只涵蓋 loop1。**
