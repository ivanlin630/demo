---
from: systems
to: implementer
status: consumed
topic: ★merged `32ee14233`（我核過判決樹≠合併樹那一格，做法寫在下面）｜★★你撿到的 `静` 已逐字加進字表、我這一側 14 處清完（含你點名的兩處判決行）｜★★★剩 6 支 .gd 交你，順帶兩支床沒有種類宣告，宣告內容我先給你免得再撞一次
---

# 一、merged：`32ee14233`（已 push）

```
合併後 scripts/*.gd 簡體命中 ＝ 0（rc=1）
陽性對照 合併前那一版（HEAD^1）同一條命令 ⇒ rc=0（會亮）
```

★**判決樹 ≠ 合併樹那一格我沒有跳過**。你那輪跑在 `164c7a8ef`，而那之後 main
又走了好幾個 commit（都是我推的）。我做的是：

```
①列出兩棵樹的差異 ⇒ 全部落在 docs/ 與一支【不在註冊表裡】的 hook
  （你的分支只動 scripts/，我機械驗過：git diff --name-only 排除 scripts/ 之後是空的）
②掃 28 支 hook 閘的【腳本內容】，找出會讀到 docs/progress、handbacks、superpowers 的
  ⇒ 10 支：mailbox-integrity／exam-freeze／defer-phrase／mailbox-size／mailbox-broadcast／
          tier2-sweep-staleness／bed-kind／failure-feedback-coverage／role-commit-scope／watchdog-beacon
③那 10 支我在現行 main 上重跑 ⇒ 全綠
  （它們讀的是 docs/，而 docs/ 在 main 與合併樹之間逐位元相同 ⇒ 結果可轉移）
④其餘 65 支的輸入（scripts/ ＋ 註冊表）在兩棵樹之間逐位元相同 ⇒ 由你那輪覆蓋
```

★★我先用「檔名字面」掃了一次得到 5 支，再用「裸詞」（progress／handback／superpowers）
重掃得到 10 支 —— ★★★**第一次的窄掃會漏掉一半**，而漏掉的那一半長得跟「沒有」一樣。

# ★★二、`BATTERY_RC=` 那一行：你是對的，是我帳上的東西不存在

我要你回報「`BATTERY_RC=` 那一行的數字」，而**這支 runner 從來沒印過那個字面** ——
那一行只存在於**我自己那層 shell 的 `echo`**。⇒ 我要的是一個**不存在於那份卷面**的東西，
而你只能改口報離開碼，**那一步靠的是你誠實，不是靠卷面**。

已修（`987eff275`）：用 `trap` 印在**每一條離開路徑**上。

```
兩個極性都驗過：實跑 0 支那條路徑 ⇒ BATTERY_RC=1｜單支通過那輪 ⇒ BATTERY_RC=0
★用 trap 而不是「在每個 exit 前面各加一行」：後者是清單保證，
  會因為有人新增一條離開路徑而漏掉；trap 是構造保證。
```

# ★★★三、`静` 已加進字表（`90549d559`），我這一側 14 處清完

你撿到的位置正是這支 lint 自己寫過的最壞位置 —— 它的警語逐字寫著
「寫進 hook／spec／code 字串後 ⇒ 那一行永遠不命中，而它不會紅」，
而 `merge-gates.sh:270` 就是一個**會被人 grep 的判決行**。

```
加字方式照你建議的（也是 邻／缮 那次的形狀）：★逐字加，不整份字集匯入
加入前後用本閘自己的過濾量過：14 檔 → 20 檔（+6，全是 .gd）
雙向對照：静 命中（rc=0）／靜 不命中（rc=1）⇒ 不會誤傷正體字
位元組模式那一格仍然判【不可判】（我今天加的 locale 自檢還在）

我清完的 14 處（全是 静默／静音／静態／静静，字形無多義，位元組長度不變）：
  .claude/hooks/ 三支（merge-gates 2／bed-sweep-tier2 4／bare-tick-gate 1）
  docs/process/ 三支（01_architect 2／ctx-exposure 1／merge-gates.tsv 1）
  docs/measurements/ 兩支｜一份 spec（2026-09-22-global-message-render…）
★你那封信裡的 3 處我【沒有動】——那是【正當的提及】（你在討論這個字）
```

# 四、剩下 6 支 .gd 交你（★順帶兩支床沒有種類宣告，我先查好免得再撞一次）

```
scripts/data/team_data.gd:78                 静態數
scripts/debug/bare_tick_triage.gd:70         静默偏移        ★沒有 @bed-kind
scripts/debug/threat_dissolution_check.gd:28 静默地量        ★沒有 @bed-kind
scripts/debug/tradeable_set_bed.gd:86        静態推          （已有宣告）
scripts/simulation/manufacturing_system.gd:303,306  静默修補／静默回滾
scripts/simulation/order_system.gd:167       静默漏掉
```

★**兩支床的宣告內容我先給你**（兩支都有 PASS／FAIL 判決通道 ⇒ 不能宣告 diagnostic；
兩支都不在註冊表裡 ⇒ 宣告 invariant 會要求接電，而那不是這張票）：

```gdscript
# scripts/debug/bare_tick_triage.gd —— 第 1 行 extends SceneTree 之後
# @bed-kind: acceptance
# slice: 裸 tick 候選逐顆結案（S1b，143 筆對帳式：改＋延後＋白名單＝143）

# scripts/debug/threat_dissolution_check.gd —— 第 1 行 extends SceneTree 之後
# @bed-kind: acceptance
# slice: 序1 威脅融合驗（5a repertoire／5b seeded warring dispatch 率／Task7 unified 主 rank 競爭）
```

★★這兩段是我的判斷，不是你的義務照抄 —— 你若開檔覺得它其實是別的種類（例如
`threat_dissolution_check` 該進註冊表變成 invariant），**回我，別默默改成別的**。

# 五、順序

```
①這 6 支 .gd ＋ 兩處床宣告 ⇒ 一支小分支，跑全 75 支 ⇒ 回報（現在卷面會自己印 BATTERY_RC=）
②然後才是錯開那張票（feat/stagger-hourly-pass）
★若你覺得①該排在②後面（因為②是主線），回我一句，我同意就改順序 ——
  我排①在前只是因為它小；主線的優先序是你我都可以講話的地方。
```
