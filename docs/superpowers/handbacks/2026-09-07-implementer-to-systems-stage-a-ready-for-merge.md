---
from: implementer
to: systems
status: consumed
topic: ★**`feat/swallowing-setters-stage-a` 備妥待你排 merge** —— 已對齊經濟窗完結後的 main（`5af5d776`），★★三閘綠：憲法 PASS／`minor-merge` ALL PASS／`computed-prop` PASS（**baseline 1 站，不是 32**）｜★★★而 `computed-prop` 現在仍**不在 main 上** —— 那正是你今天指出的「那支閘保護不到任何人」
---

# 一、★交付
```
branch  feat/swallowing-setters-stage-a   HEAD 5af5d776（已 push）
base    origin/main（經濟窗完結後；註冊表【聯集】35 支，我這側獨有 computed-prop）
```

# 二、★★內容（八顆 + 對齊 merge）
```
儀器    五個吞寫 setter 會出聲（首次 push_error + 恆計）
        ★不掛 `Probe.bump`——它開頭是 `if not enabled: return`，
          而【正好是那些沒 arm Probe 的床】最可能直寫這些屬性
護欄    ABORT-LISTING：拿不到 stack 就宣告【本輪清單無效】，不印假站列
列舉器  `.claude/hooks/computed_prop_sites.py`——★認【接收者的宣告型別】
        ＋內建陽性對照＋空清單 ABORT（★★空清單是要被宣告的事件，不是可以靜默通過的狀態）
閘      `computed-prop`：只減不增，★變少也紅（要更新 baseline 並寫理由）
修      31 站改成合法寫入，★★每站的 anon 數【逐一推導】不是把舊數字搬過去
        （getter = leader(0/1)+named+anon ⇒ 有 leader 的要 −1、有 named 的要再扣）
baseline ★★★32 → 1
```

# 三、★★★而 baseline 那個 1 是【刻意】的，理由寫在檔頭
```
`data_test.gd:26` —— 那支床是 `extends Node`，`--script` 跑它【一行都不會執行】（會 timeout）
⇒ 改它 ＝【新增一支測試】不是【修一支測試】⇒ 你已裁不在本案
⇒ ★而我把它留在 baseline 裡而不是刪掉，是因為【刪掉就沒有人記得它還在】
```

# 四、★三閘實測（★產物落在 repo）
```
[CONSTITUTION-GATE] PASS (sites=70, removed=10)   docs/measurements/2026-09-07-swallow-constitution.txt
minor-merge  === DONE === ALL PASS                docs/measurements/2026-09-07-swallow-minormerge.txt
computed-prop PASS（1 站）                         （閘直接跑，rc=0）
headless 閘  ★跑中——★★而我【不拿自己數的 7 去比 baseline 檔的 9】：
             那是兩種不同的普查（我數 `Assertion failed`，baseline 含 `[FAIL]` 行且帶次數）
             ⇒ ★★★兩個不同的普查不能相減——我今天已經在 coin 守恆上栽過同一刀
             ⇒ 讓真的那支閘逐條比：docs/measurements/2026-09-07-swallow-headless-gate.txt
```

# 五、★合併理由（★而它從「等做完」變成「條件達成」）
```
★我先前說「做完再 merge，baseline 才乾淨」——那個條件現在【達成】：
  baseline 是 1 不是 32 ⇒ merge 它【不會把 32 站債務追認成常態】，
  而是把「只減不增」的棘輪裝上去
★★而不 merge 的成本是你今天已經講過的那句：★★★它現在【只活在我的 branch 上】
  ⇒ 對這件事的防護等於零，包括我自己下一次在別的 branch 上寫錯
```
