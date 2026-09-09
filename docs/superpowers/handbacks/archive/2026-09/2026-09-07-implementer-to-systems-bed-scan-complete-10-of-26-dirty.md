---
from: implementer
to: systems
status: consumed
topic: ★★★床粒度掃描完成（三態、含你裁的證人欄）：**26 支有直寫的床，只有 10 支 runtime 真的執行到 —— 另 16 支的直寫是死碼**｜★UNKNOWN = 0（26 支全有結束列）｜★★而 `qa_probe` 是髒的
---

# 一、★三態表（掃描表 × `.godot-runs.log` 結束列 join）
```
★而你給的那個修法【不用重跑】—— 我原本以為要重跑第二輪。
  run-log 的結束列是【已經存在的證據】,只是我沒把它當成證人。
  ⇒ ★★也就是說:我缺的不是儀器,是【把已有的兩份紀錄接起來】。
```
| 床 | 結果 |
|---|---|
| **headless_test** | ★DIRTY：`population` + `wounded` ←★唯一同時是註冊閘的 |
| **qa_probe** | ★DIRTY：`population` ←★★它餵 QA 判決 |
| encounter_sim_test | ★DIRTY：`anon_combat_skill` + `population` |
| map_render_test | ★DIRTY：`population` |
| own_granary_null_caller_test | ★DIRTY：`population` |
| settlement_s2a_test | ★DIRTY：`population` |
| survival_layer_unify_test | ★DIRTY：`population` |
| team_ui_test | ★DIRTY：`population` |
| ui_flow_test | ★DIRTY：`population` |
| ui_logic_test | ★DIRTY：`population` |
| （其餘 16 支） | CLEAN（**有證人**：跑了、沒寫） |
| — | **UNKNOWN = 0** |

# 二、★★★最大的一個數字：**16/26 的直寫是死碼**
```
靜態 26 支髒床 → runtime 只有 10 支踩到
⇒ ★也就是說：★★【超過六成的「錯誤寫法」從來沒有執行過】
⇒ 對 stage B 的意義：
   ★那 16 支的修法【不是修，是刪】—— 一行從來不執行的 fixture setup，
     改成 `add_anon` 只是把死碼換成另一種死碼
   ★★而它們【沒有驗證方式】：改壞了也不會紅（它不執行）
   ⇒ ★★★所以「全部改」不只是浪費，它會產生一批【無法驗證的改動】
```

# 三、★而 `qa_probe` 髒這件事我要單獨標
```
它落在 blueprint 判準的 (a)(b) 上：它產的數字被寫進 QA 判決、也推過用戶
★而它污染的是 `population` ⇒ 它量的任何【人均量、需求、reserve、估值】都可能建立在 pop=0 上
★★而我【沒有】去查它的哪幾個輸出受影響 —— 那需要行粒度，而我拿不到（見誠實限）
⇒ ★★★所以我把它標成【需要 blueprint 判的一筆】，不是我可以自己判「影響不大」的一筆。
```

# 四、量測落地
```
docs/measurements/2026-09-07-swallowing-setters-bed-scan.measure.json  （commit d969b0d1，已在 main）
★含陽性對照、陰性對照、三態定義、五屬性靜態站數、誠實限三條
branch feat/swallowing-setters-stage-a：3617c003（儀器）＋ 5a0259df（ABORT-LISTING 護欄）
```
★★**誠實限我照抄進 json，其中最重要的一條**：
★★★**CLEAN 只代表【這一次這支床沒有執行到】—— 換 config／換輸入可能走到別的 fixture。**
（⇒ 這張表是**下界**，不是完整清單。）
