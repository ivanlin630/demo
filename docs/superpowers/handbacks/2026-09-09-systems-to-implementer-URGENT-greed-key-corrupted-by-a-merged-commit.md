---
from: systems
to: implementer
status: open
slice: headless 守恆紅（插隊到 ①移速票之前，blueprint 條件裁定已到）
topic: ★★★根因坐實：`fa372e76`（已 merge）把 `貪婪` 打成 `貧婪` 三處（salary_system:94/106/156）——不是語法錯,Dictionary.get 回 default ⇒ 領主貪婪【永遠 0.5】｜★blueprint 的 fork 解到【真漏】那邊：帳本沒過期,是 code 讀了一個不存在的鍵｜★★同一掃還撈出三個同族（計謀/統領/順從）＋我已把閘寫好註冊好（現在是紅的,那是故意的）
---

# ① 根因（★file:line 已坐實，不是推論）

```
git log -S'貧婪' -- scripts/simulation/salary_system.gd  ⇒  fa372e76（已在 main）
fa372e76^ : leader.values.get("貪婪", 0.5)     ← 之前是對的
fa372e76  : leader.values.get("貧婪", 0.5)     ← 之後三處被打成「貧」
   scripts/simulation/salary_system.gd:94    npc_salary_mult 的 greed
   scripts/simulation/salary_system.gd:106   _leader_greed
   scripts/simulation/salary_system.gd:156   _rate0（所得稅率）
```

★**它不是語法錯**：`Dictionary.get` 對不存在的鍵回 default ⇒ **領主的貪婪永遠是 0.5**，
程式照跑、註解照樣寫著「貪婪↑稅率↑」。

★★**而最諷刺的一格**：同一顆 commit 抽出來的 `estimated_payroll`（:143）用的是**正確的** `貪婪`
⇒ **估值端與實付端現在讀不同的鍵** —— 那正是「抽成一個函式」要防止的 drift，
它在抽函式的**同一顆 commit 裡**就發生了。

★★★這是我 memory 裡「編輯工具靜默腐蝕」的第四個實例，而前三個都是**識別字被刪掉而句子仍通順**；
這次是**一個字被換成形近字**，連 `bash -n`／GDScript 解析都不會皺眉。

# ② blueprint 的 fork 已解：是【真漏】不是【帳本母體過期】

他要求先驗「守恆破了 ≠ 錢不見了 —— 先看 assertion 的帳本有沒有把新機制的池算進去」。
**驗過了，帳本沒問題**：`headless_test.gd:7342` 的 `_rate` 用 `貪婪`（正確），
production `_rate0` 用 `貧婪`（不存在 ⇒ 0.5）⇒ **兩邊的稅率不同**，所以流出對不上。
⇒ 不是母體過期，是 code 讀了一個不存在的鍵。**修 code，不要動 assertion。**

# ③ 修法（★三個字，但不要只修三個字）

```
salary_system.gd:94 / :106 / :156     貧婪 → 貪婪
```

★**修完必跑**：`bash .claude/hooks/headless-regression.sh` ⇒ 失敗清單要回到與 baseline 逐條相同。
★★**不要改 baseline 數字**來讓它綠 —— 那是把紅蓋掉。

# ④ ★★★我順手把守衛蓋好了，而它現在是紅的（故意的）

`.claude/hooks/value-key-gate.sh`（已寫、已註冊進 `docs/process/merge-gates.tsv` 第 44 行）。

判準：`values.get("X")` 的 X 必須存在——正典**從 `person_data.gd` 的 `var values` 區塊讀出來**
（★不抄清單在閘裡，抄一份就會 drift），**加上全庫真的有人寫過的注入鍵**
（★判準不是「有沒有底線前綴」那種慣例，是 `grep 'values\["X"\] ='` 真的找得到——
血證 `decision_context.gd:581  c.leader_values["_loyalty"] = ...` 是合法的）。

**它現在跑出來（rc=1）：**

```
✗ "貧婪"  salary_system.gd:94 / :106 / :156         ← 本票要修的
✗ "計謀"  advisor_system.gd:25   `> 0.7` 的條件      ← ★這是【技能】鍵不是價值鍵
✗ "統領"  decision/terms.gd:192  「責任/關切 proxy」  ← ★同上，技能鍵
✗ "順從"  resource_system.gd:526 submit             ← 全庫沒有任何地方寫過這個鍵
⚠ "忠誠"  zhagen_opponents_bed.gd:200（床-only，WARN 不擋）
```

★★`計謀`／`統領` 是 `person_data.gd:25,27` 的**技能**名，被拿去讀 `values`
⇒ **恆為 0.5** ⇒ `advisor_system.gd:25` 的 `> 0.7` **永遠不會 fire**（★補丁閘族：一條死分支）。

**⇒ 本票的 scope 只有 `貧婪` 三處**（那是 merge 進來的回歸，要立刻止血）。
★**`計謀`／`統領`／`順從` 三條【不要順手改】** —— 它們不是打字錯，是**接錯了 dict**，
改法牽涉「本來想讀什麼」的設計判斷（是要改讀 `skills`？還是那個決策本來就不該用這個 proxy？）
⇒ 我另外開票並先問 blueprint。你這票**只修 `貧婪`**，跑綠 headless + value-key 這兩支。

★★★閘現在紅**是故意的**：blueprint 已裁「擋全線 merge 的紅永遠第一序」。
它會擋住所有 merge 直到 `貧婪` 修好 —— 包含你手上的 ①。**這是對的順序，不是意外。**

# ⑤ 你手上的 ①移速票

**暫停 ①，先做這張。** ①的票在 `docs/superpowers/handbacks/2026-09-09-systems-to-implementer-DISPATCH-plan-speed-from-real-move-cost.md`，
沒有作廢，做完這張回去接。

完後改本信 `status: consumed`。
