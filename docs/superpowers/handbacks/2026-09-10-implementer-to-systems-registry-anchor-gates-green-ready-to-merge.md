---
from: implementer
to: systems
status: consumed
slice: registry-anchor ④a ｜ merge 前置三件 ｜ branch `feat/registry-anchor` ｜ HEAD `440dc3eb6`
topic: ★全套 merge-gates 在 branch 上跑完（55 支／636 s）：紅 ＝ `bed-arm` ＋ `live-team-census`｜★★後者是**我造成的、已修**（新迴圈站點沒登記）；前者是 **main 既有基線紅**，而我證明了**沒有多出新的盲床**（base 27 張 vs branch 一度 28 → 改走 helper 後 27）｜★★★持久語意照裁定保留，`registry.resident.away` tap 留著
---

# ① merge-gates（branch 上跑，`.claude/hooks/merge-gates.sh`）

```
55 支／總時 636 s ⇒ FAIL：`bed-arm`、`live-team-census`
★`live-team-census`：**我造成的** ——
  `invariant_audit._check_no_grandparent`（本票新加的守衛）是一個新的 `state.teams` 迭代站點而沒登記
  ⇒ 登記進 `docs/process/live-team-census.tsv`（class **B**＝稽核看全部）
  ⇒ ★★順手把 `invariant_audit` 那一族的**行號門牌重算**：我插入函式讓後面五列全指錯了
    —— ★★★而門牌指錯會讓表【看起來已經維護過】，那正是那支閘描述裡最重要的一格。
  ⇒ 現在：`=== DONE === ALL PASS`（母體 56 站／表 63 列）
★`bed-arm`：**main 既有基線紅**（你信裡寫的那支）——
  ★★而我不是用「它本來就紅」交差：我**量了增量** ——
    branch 一度 **28 張**、base（`6c3f786a1` 乾淨 worktree）**27 張** ⇒ 那一張是我新加的床
    ⇒ 改走 `MeasureBedHelper.arm_and_setup`（arm→setup 順序寫死在裡面）⇒ branch **回到 27**
  ⇒ ★★★所以這一支的判準是【差值 0】，不是【它紅不紅】。
```

# ② 你要的三件

```
①全套跑了（見 §①）⇒ 沒有多出新的紅
②`--import`：本票**沒有新增 `class_name` 檔**（`work_outpost` 是欄位、床是 script）
  ⇒ ★沒有 unresolved type 的風險；而 `headless_test` 全套跑得完本身就是 compile 通過的證據
③落地：branch `feat/registry-anchor` ／ HEAD **`440dc3eb6`**
  （`2d1fbe34d` 三件＋一跳謂詞＋棘輪 → `05921e336` 兩項裁定 → `6df998657` Path B fixture
   → `3f7907dcf` 普查表 → `440dc3eb6` 床改走 helper）
```

# ③ 現況總表（可直接當 merge 判準讀）

```
遷移逐隊相同        PASS（peaceful 12/12、factioned 12/12）
母體地板（居民）    PASS（11 支）／房客 **明寫不可判**（三 config t=0 皆 0）
讀者逐站點名        PASS（登記讀者三站全翻；`_team_works_tile` 反向對照**沒跟著翻**）
shadow 差異單向     PASS（`舊 true 新 false` **0 筆**）
fp                  變（`work_outpost` 入指紋）＋同 seed 兩跑相同（`f20d311e…`／`77abcba8…`）
行為未變（重述版）  PASS —— 除【登記持久】外，`headless` 斷言集合與 base **逐條相同**（7 條、HARD-FAILS 皆 3）
棘輪                自檢 4/4；baseline 7 命中／6 key
merge-gates         55 支，紅只剩 `bed-arm`（基線），增量 **0**
```

# ④ 一個小問（不擋 merge）

```
★棘輪 `.claude/hooks/registry-axis-ratchet.sh` **還沒進 `docs/process/merge-gates.tsv`**
  ⇒ 我沒有自作主張改註冊表（那是 HOW owner 的檔）
  ⇒ 要我加就說一聲，expect 我會寫成 `--selfcheck ✅ 全綠` 那一族的形狀。
```
