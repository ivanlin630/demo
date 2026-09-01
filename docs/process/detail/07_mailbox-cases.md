# 07_mailbox_trigger — 血證與長說明（detail）

<!-- ★2026-09-02 從 `docs/process/07_mailbox_trigger.md` 主檔【整節搬入】（主檔 324 行 > 200 上限）。
     ★★搬的是【全文】不是摘要 —— 主檔留一行表列指回這裡。 -->

## ★stall 處置準則（watchdog v4，2026-08-21 用戶定案）

watchdog v4 不再問「有沒有東西在動」（v3 病：量測跑半天＝全靜＝被誤判成停滯），
改問「**有沒有人在等一個不會來的東西**」。fire 走 stdout → 喚醒 **blueprint**（arm 它的 session）。
訊息由 bash 算完整（誰沒開／最老的信／活著的角色／長工作／最後 commit），目標是 **blueprint 一輪短回合就能判**。

| 收到 | 動作 |
|---|---|
| 🔴 `DEAD-ROLE` | **推用戶**——只有他能開終端。訊息帶 `$env:SESSION_ROLE='<role>'; claude` |
| 🟡 `UNRESPONSIVE` | 信是給我自己的 → 自己動。不是 → 寫信催該角色，**不推用戶**。同一封第二次才推 |
| 🟡 `COMMIT-NO-LETTER` | 查 commit 是誰的活 → 寫信要他補推下一站（他出貨了但沒推鏈） |
| 🟡 `CHAIN-BROKEN` | 查最後一封信在等誰。等用戶裁 → 推；等角色 → 補寫下一站信；查不出 → 推用戶 |
| 🟠 `RUNAWAY` | 推用戶（長工作超過 8h，可能要殺 godot） |

★ 原則：**只有「開終端／WHAT 裁決／授權」才推用戶**，角色間能解的 blueprint 自己推鏈。

**七類分類器**（`DEAD-ROLE` / `RUNNING` / `RUNAWAY` / `UNRESPONSIVE` / `COMMIT-NO-LETTER` / `CHAIN-BROKEN` / `OK`）：
- `DEAD-ROLE` **獨立於 RUNNING**——信給一個沒開的角色，不管別人在不在忙，都是 bug。
- ★★`COMMIT-NO-LETTER` **也獨立於 RUNNING**（2026-08-25 修，用戶問「怎麼還會停頓」才挖出）：
  ★**病**：`elif [ -n "$running" ]; then class="OK"` 把它連同 `UNRESPONSIVE`/`CHAIN-BROKEN` 一起跳過。
  ★**實況**：implementer **在跑背景 job（`running` 非空）★同時★ commit 了卻沒發信** ⇒ **watchdog 判 `OK` 靜默，而鏈確實斷了。**
  ★★★**根因：`RUNNING` 只證明【有人在忙】，不證明【鏈沒斷】—— 兩者可以同時為真。**
  ★**判準同 `DEAD-ROLE`**：**「出貨了沒推鏈」是【已完成的事實】，跟他現在忙不忙無關。**
  （`T_IDLE` 門檻保留 ⇒ **跑 job 期間剛 commit 還沒寫信的正常中間態不會誤報**。）
  ★`UNRESPONSIVE`/`CHAIN-BROKEN` **維持在 RUNNING 之後** —— 那兩類「正在忙所以還沒回」是合理解釋，本類不是。
- `RUNNING`（beacon／godot 進程／檔案活動任一為真）→ **靜默，不管跑多久**，除非撞 `RUNAWAY`。
- 同一 class 連續成立 → **`RE_ARM`(4h) 內只響一次**（v3 病：fire 後重置 ⇒ 每 5h 重響）。
- ★`COMMIT-NO-LETTER` 與 `CHAIN-BROKEN` 用的 git 信號**不可混**：前者只看 `main`，後者看全 ref。
  （v3 病：取全 ref 最新 commit ⇒ merge 到 main 卻沒寫信，反而把警報壓住 1h。）

**參數**（用戶 2026-08-21 拍板）：`POLL=15m` / `T_DEAD=15m` / `T_UNRESP=1h` / `T_IDLE=1h` / `T_MAX_RUN=8h` / `RE_ARM=4h`。
**長工作 beacon** 的寫法與紀律見 `03b_measurer.md` / `03_implementer.md` §長工作 beacon。

---

## ★P9：派工單 frontmatter 必帶 `slice:` 與 `tier:`

本體與兩檔定義見 `01_architect §P9 交接縫`。要點：`slice:` ＝ branch 名去掉 `feat/`＝**唯一真相來源**；`tier:` **只寫在派工單**（其他產物不寫，免第二個真相）；**tier 由 systems 定，做的人不得自選**；**兩檔都不砍 review**。閘：`bash .claude/hooks/seam-gate.sh`（★**2026-08-21 起預設 HARD ＝ 擋 merge**；逃生門 `SEAM_MODE=soft`）。

---

## ★merge 後必驗：git 說「已合併」≠ code 真的在樹上（2026-08-21 實戰事故）

```bash
bash .claude/hooks/merge-verify.sh        # 掃最近 30 個 merge；exit 1 = 有改動被丟
```

**病**：Windows 上 `git merge` 會瞬鎖 index —— 半途 `MERGE_HEAD` 在、但**沒有任何 staged**，
commit 出來就是**把 branch 記成已合併、改動卻沒帶進來**。
★ **比丟改動更陰險的是**：git 從此認為那條 branch **已 merged** ⇒ 之後再 `git merge` 只會說 *nothing to do*，
**而 code 根本不在樹上**。症狀是「功能莫名其妙不見了」，**而 log 看起來完全正常**。

**血證 `4bdce7c1`**：branch 改了 4 個檔，**3 個新檔進來了、被修改的 `specimen_tracer.gd` 沒進來**
（Windows 鎖的典型半途 stage）。HEAD 裡連 `parent_team_id` 都找不到，但 `git merge` 說沒事可做。

★ **偵測判準第一版我也寫錯過**：問「這個 merge 整體有沒有變化」抓不到——
那個 merge 同時帶了別的檔，**整體有變化，只是把 branch 的改動丟了**。
**正確問法是逐檔**：「branch 改過的每個檔，在 merge 結果裡拿的是誰的版本？」

**修法**：從 branch **補一個新 commit**（**別重寫 history**），**逐檔 `md5sum` 對過再 commit**。


---

## ★★承諾即檔名（用戶在場核定 2026-08-21）

**任何信裡寫「已派／將開票／已排／已通知」，必附【實際檔名】。**
**收件端簽收時 `ls` 驗它存在** —— **驗不到就當那件事沒發生**，回信說「檔名不存在」。

```bash
ls docs/superpowers/handbacks/<你聲稱的檔名>     # 收件端簽收動作的一部分
```

### 為什麼要這條（血證：systems 自己犯兩次）
1. **T3 累加案**：我在 spec 改了設計、**沒推派工單** ⇒ implementer 照**舊版**做了整整一輪。
2. **gate 9 warring 票**：只寫在一封**後來被 consumed 的信**裡，**從沒變成正式工單** ⇒ 掉在地上，**用戶問起才發現**。

★ **偵測器的兩個極限**（這條紀律要補的正是第二個）：
- **粗粒度**：信量大時，**任何一封無關的信都會遮蔽警報**（watchdog 只問「有沒有信」）。
- **★機器全盲**：「**信裡承諾的票沒開**」—— **散文承諾追蹤，機器分不出來**。

★ **這是 [[feedback_specimen_handoff_landed_path]] 那條血訓的推廣**：
當初是「specimen 別說『在我手上』，要標**已落地的 exact path**、而且 producer 自己開檔驗」。
**現在推廣到工單本身**：**別說「我派了」，要說「我派了 `<檔名>`」，而且收件端自己 `ls` 驗。**

### ★誠實標注（不可省）
**「散文承諾追蹤」全自動化不可行** —— **prose ≠ schema**，機器讀不出「這句話承諾了一張票」。
本條紀律 ＝ **收件端人工驗 ＋ 檔名紀律** ＝ **目前能 arm 的最大範圍**。
**其餘（沒附檔名的承諾、口頭排程、信中提到但沒開的票）＝ `declared, unenforced`**，
**明寫在 P7 三態表裡，不假裝有守。**

## ★★跨代縫：**「自退協議」的前提是雙方同版**（用戶 2026-08-25 抓到，額度斷電四天期間曝光）

**病**：`watchdog v4` 與 `inbox-watch v2` 都用「**新的一定贏、舊的自退**」搶佔。
**但那個前提是「舊方也跑新版、會讀 lock 歸屬」。**
跨代時舊方是**上一代常駐碼**（compact 前 Monitor 起的）：
**不讀 lock 歸屬、永不讓位、每 poll 還 touch** ⇒ lock 永遠新鮮
⇒ **新版永遠停在「待命」，舊版照舊每 5h 響 14 連發。**

★**根因不是 lock 寫錯，是【對稱升級假設】** —— **跨代才是常態，不是例外。**
（同族：〈估算器禁手抄物理〉的「第二份拷貝必 drift」；差別只在這裡的第二份是**舊版程式**。）

### 修法：**機械判代，不用等逾時**
本版 lock ＝ **3 欄**（`pid` / `session_id` / `claude_pid`）⇒ ★**欄數 < 3 ＝ 舊代**。
- `watchdog.sh` `claim_lock` 回傳 **0 搶到／1 同代持有（會自退）／2 舊代持有（不會自退）**
- `inbox-watch.sh` arm 時同款判：舊代前任 ⇒ **不准輸出「將於下輪自退」那句安撫話**（跨代下那是假話）

### ★輸出紀律（本專案既有原則的又一次應用）
**守衛不要輸出「需要被解讀的狀態」，要輸出「已經處置完的結果」。**
- 可以自解的 ⇒ 說「無須人工介入」
- **不能自解的 ⇒ 必須說出「人要做什麼」**：
  `🔺 需人工介入：… 處置：TaskStop 那個舊 Monitor task（pid=X）→ 本進程下一輪自動上位`
- ★**升級訊息要複述**（`ESCALATE_EVERY`，預設 8 輪）—— **只說一次會被錯過**，而錯過＝回到無限等。
- 同代久不讓位（疑似卡住）⇒ `STANDBY_MAX_ROUNDS`（預設 8 輪 ≈ 2h）後**也升級**，不無限等。

### 已知停擺型：**額度斷電**（不修，記型）
**全角色 API 餓死、監視器活著但腦全下線。** `watchdog` 分類器對它報 `CHAIN-BROKEN`
—— **分類正確，但當下無人能動**。**不需要修分類器**；認得這個型就好。

### ★跨代縫是**全 harness 通病**，不是兩支 script 的 bug（窮盡掃描 2026-08-25）

**三個案例**：`watchdog`（永遠待命）／`inbox-watch`（同信吐兩次）／
★`tg_poll`（**8/19 老 poller 與 v2 搶 `getUpdates` offset** —— 這個**不是重複，是訊息靜默遺失**）。
**同型缺口出現三次 ＝ 架構信號** ⇒ 不逐案修，做窮盡掃描。

**掃描範圍 ＝ 常駐單例（有 `while true` ／ poll loop 者）**：

| 檔 | 跨代保護 |
|---|---|
| `.claude/hooks/watchdog.sh` | ✅ 已修 |
| `.claude/hooks/inbox-watch.sh` | ✅ 已修 |
| `tools/telegram/tg_poll.py` | ✅ 已修（**顯式 `proto=` 版本戳**） |
| `tools/orchestrator/run.py` | 無 lock，但**非常駐 poller**（pipeline runner、機器軌少用）⇒ 不在此範圍 |
| `tools/telegram/fetch_chat_id.sh` | 一次性 helper，非單例 |

### ★規則：**常駐單例必須自報協議版本**
**欄數判代只是 retrofit** —— 它只認得出「**比現行少欄**」的世代，
**對「舊版也寫同欄數」無效**（`tg_poll` 正是這種）。
⇒ **一律加顯式 `proto=N` 戳**。偵測規則**向後相容、不對現役版本誤報**：

| 前任 lock | 判定 |
|---|---|
| 欄數 < 現行下限 | **舊代**（不會自退） |
| 有 `proto=N` 且 `N <` 現行 | **舊代** |
| 欄數足但**無 `proto`** | **同代**（現役版本，會讀歸屬、會自退） |

### ⚠️ 實作陷阱（我自己踩到，記下來）
★**偵測必須讀「覆寫 lock 之前」的快照。**
第一版我把偵測函式寫在 `open(LOCK,"w")` 之後才呼叫 ⇒ **它讀到的是自己剛寫的內容**
⇒ **永遠判「同代」、守衛靜默失效**。
★**一個永遠回 False 的守衛比沒有守衛更糟** —— 它讓人以為已經被保護了。

### ★待命型 vs 自退型：**「替屍體保溫」是待命型獨有的病**（blueprint 現場抓 2026-08-25）

**症狀**：holder pid 已死，lock 卻一直被 touch 保鮮 ⇒ **`lock stale` 永不成立**
⇒ 全體永遠待命、升級訊息空響。

| 單例 | 非持有者行為 | 有無此病 |
|---|---|---|
| `inbox-watch.sh` ／ `tg_poll.py` | 讓位檢查後**直接 exit** | ❌ 天然免疫（碰不到 touch） |
| ★`watchdog.sh` | ★**留在待命迴圈**（設計如此：要等著接手） | ✅ **唯一有風險** |

**修法**：`touch` **必須 gate 在「lock 第一欄 == `$$`」之後** ——
★**把不變量做成【局部檢查】，不要靠控制流保證**（日後有人搬動那行也不會復發）。

### ★★修完 harness ≠ 生效：**「誰在跑哪一版」要當成交付的一部分**
血證：屍體保溫修好時，blueprint 正在跑的 watchdog **是修前版本**
（`.watchdog.lock` 只有 3 欄、沒有 `proto=` 戳）⇒ **修法對它尚未生效，要重 arm 才吃得到。**
★**這是跨代縫的第四個案例** —— 前三個是「舊版不讓位」，這個是「**修好了但跑著的還是舊碼**」。
⇒ **harness 交付要附一句：「請重 arm，否則跑的還是舊版」**，不能修完就當生效。

### ✅ 法條第一次執行的結果（2026-08-25）—— **驗了才知道有一半沒生效**

**`watchdog`**：blueprint 換血重 arm 後 **實測 `61124|7ddd77f1…|8928|proto=4`**
（**4 欄、有戳、holder 存活**）⇒ ★**新碼確實在跑，不是「應該在跑」。**

★★**但同一次掃描順手發現**：**六支 `inbox-watch` 全是 3 欄、無 `proto=`**
⇒ **六個角色（含 systems 自己）跑的都還是修前版本。**

**處置（比例原則，不是全員重 arm）**：
| | 判斷 |
|---|---|
| **`watchdog`** | ★**待命型 ⇒ 有屍體保溫死鎖風險** ⇒ **必須換血**（已完成、已驗） |
| **`inbox-watch`** | ★**自退型 ⇒ 對屍體保溫天然免疫**；缺的只是**跨代告知訊息**，**不影響信件送達** |

⇒ **`inbox-watch` 標 P7 📜 `declared`：「已修、未部署」，各角色下次自然重 arm 時生效。**
★**不為它要求全員重 arm** —— 但**必須明說**，
**否則「修好了」會被默認成「生效了」，那正是這條法條要防的事。**
