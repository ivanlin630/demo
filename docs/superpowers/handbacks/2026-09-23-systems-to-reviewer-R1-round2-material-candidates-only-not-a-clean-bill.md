---
from: systems
to: reviewer
status: open
topic: R① 第二輪的【原料】：那 11 支未驗系統｜★★★而我要先說清楚：這份東西只能【標候選】，**不能判乾淨** —— 我的掃描被委派鏈打敗了兩次，過程寫在裡面
---

# ★一、先說我的掃描壞在哪（兩次，都是我自己抓到的）

```
第一版：掃 sim_runner.gd 裡那 11 個 func 的函式體
  ★而它們是【兩行的轉發存根】（_step5_collect_resources → _resource_system.collect_resources）
  ⇒ ★★我掃的是包裝紙 ⇒ 「8 支無訊號」是垃圾
第二版：追一層委派，掃真正的系統方法；★內建陽性對照（必須抓得到已知的 faction_snapshot）
  ⇒ 陽性對照通過（4 個訊號）
  ★★★但我再抽查，發現 faction_ai 的 evaluate_all 【也是包裝】（→ _evaluate_all_body）
  ⇒ 那一格的「無訊號」仍然是垃圾。委派鏈不只一層。
```

⇒ ★**所以「無訊號」在這份材料裡的意思是【我的掃描沒有走到】，不是【它乾淨】。**
（三格塌成兩格：乾淨／髒／沒看到 —— 而我的工具把第三格印成了第一格。）

# 二、標到的候選（★這一半有用）

```
manufacture   manufacturing_system.gd::tick_all     ★雙層 for ＋ state.teams[] 索引
reactions     reaction_system.gd::evaluate_all      ★雙層 for
strategic_move sim_runner.gd::_step2a_strategic_move  state.teams[] 索引
collect       resource_system.gd::collect_resources  state.teams[] 索引
consumption   resource_system.gd::resolve_consumption state.teams[] 索引
```

★上面兩支（雙層 for）是我最想要你先看的：那正是 `faction_snapshot` 被抓到的形狀。

# ★★三、掃描沒走到的（★不是乾淨，是沒看到）

```
regen, salary, fatigue, faction_ai, info_dispatch, cleanup
★faction_ai：已確認 evaluate_all 是包裝 ⇒ 真正的邏輯在 _evaluate_all_body（及更下層）
★info_side_dispatch_all：本體是 per-team 迴圈，但它再委派給 _try_herald_side／_try_scout_side／
  _try_distribute_side ⇒ 跨隊讀取若存在，會在【那一層】
```

# ★★★四、我要你怎麼用這份東西

```
★把它當【起點的排序】，不要當【母體的分類】。
★★六支「沒走到」的，仍然要逐檔核 —— 和那五支候選一樣，一支都不能少。
★★★若你發現我的候選標錯（某支雙層 for 其實是走訪自己的成員而不是別隊），
  那也是有用的結果：它會告訴我【雙層 for】這個訊號太寬。
```

# 五、我沒有做的

```
✘ 我【沒有】把掃描擴成 N 層 —— 那會變成我在重做你的工作，而且我今天已經證明
  我的分類器在這一族上不可靠（兩次）。
✘ 我【沒有】下任何「可錯開／不可錯開」的判斷。
```
