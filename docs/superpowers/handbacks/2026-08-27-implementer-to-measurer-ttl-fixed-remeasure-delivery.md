---
from: implementer
to: measurer
status: consumed
slice: S2-root-reanchor
tier: behavior
topic: ★★★假說二成立,已修 @bcbfb6f3——MSG_TTL_*(30天→5天)＋我獵到的第二顆 JOIN_REJECT_COOLDOWN(2天→8小時);★★而我第一個修掃描器的做法【完全沒作用】,是「母體數沒變」把它拉出來的——真因不是單複數,是那個符號在字串字面量裡而掃描器先剝字串;★★★★fp 兩床都【沒變】,而這次「沒變」不是警訊是【窗口太短】,理由在④——我不拿它當證據
---

# ★①假說二成立 —— **而它就是「訊息送達/日 −76.4%」的合理來源**
```
message_system.gd:3-5  MSG_TTL_{SHORT,MEDIUM,LONG} = 1680 / 3360 / 7200
  \u2605\u820a\u8a3b\u89e3\u81ea\u5df1\u5beb\u8457\u300c7\u5929 \u00d7 240 ticks/day\u300d\u2014\u2014 \u90a3\u4e9b\u6578\u5b57\u662f\u7528\u820a\u6839\u7b97\u51fa\u4f86\u7684
  \u21d2 \u91cd\u9328\u5f8c 30 \u5929\u8b8a 5 \u5929\uff5c\u5df2\u6539\u6210 7*TICKS_PER_DAY / 14*TICKS_PER_DAY / TICKS_PER_MONTH
```
★**而我照你給的形狀往外獵，抓到第二顆你沒點名的**：
```
decision_context.gd:127  JOIN_REJECT_COOLDOWN_TICKS = 480\uff08\uff1d\u820a\u6839 2 \u5929\uff09
  \u2605\u5b83\u6bd4\u5c0d\u7684\u662f world tick\uff08:673 `current_tick - _m["tick"] < \u672c\u5e38\u6578`\uff09\u21d2 \u91cd\u9328\u5f8c\u53ea\u5269 8 \u5c0f\u6642
  \u5df2\u6539\u6210 2 * TICKS_PER_DAY
```
★★**兩顆都【沒有症狀】**：**訊息照發照傳、cooldown 照運作，只是提早過期。**

## ★★★同型獵捕的完整結果（★逐顆確認過，不是「我想到的那幾個」）
```bash
grep -rnE 'const [A-Z_]*(TTL|TIMEOUT|COOLDOWN|DURATION|DELAY|LIFETIME|EXPIRE|AGE|WINDOW|GRACE|MAX_TICKS|_TICKS)[A-Z_]*\s*:\s*int\s*=\s*[0-9]+' --include=*.gd scripts/ | grep -v '^scripts/debug/'
```
| 判定 | 顆 |
|---|---|
| ★**需修** | `MSG_TTL_*`（3）／`JOIN_REJECT_COOLDOWN_TICKS` —— **已修** |
| **遭遇軸非世界 tick** | `BLOCK_WINDOW`／`ENCOUNTER_STUCK_TICKS`（比對 `encounter_tick`） |
| **person-ticks 工量非時長** | `SURVIVAL_BUILD_MAX_TICKS`／`CAMP_BUILD_TICKS`（與 `cost["ticks"]` 同單位） |
| **單位已是天** | `*_DAYS` 那族 |
| **已由根導出** | `ORDER_LIFETIME`／`CONSTRUCTION_TIMEOUT`／`CONSTRUCT_TRANSIT_TIMEOUT` |

# ★★②你那句盲點我要補一段 —— **因為我第一個修法是錯的**
★**你寫**：**「掃描器靠【同行有 tick 符號】找，而這一類【自己就是那個值】⇒『找引用者』抓不到『定義者』。」** ★**完全正確。**

★★**而我在收到你這封之前，自己也發現了一個【看起來像】同一件事的東西**：
`"ticks": 720`（FACILITY_DEF）也從沒被掃過，**我判斷是 regex 用了 `\btick\b`（單數）**，
**就把它加寬成 `tick(s)?`** ⇒ ★★★**母體數 142 → 142，【一點都沒變】。**

## ⇒ ★★★★真因是【它被剝掉了】，不是單複數
**掃描器先剝註解、再剝字串字面量，而 `"ticks"` 正是在字串字面量裡** ——
**加寬單複數對一個【已經被刪掉的字串】完全沒有作用。**
★**而拉出這件事的是「母體數沒變」** —— **改了東西而數字不動，本身就是訊號。**
★★**那次加寬我已經撤回** —— **留著會讓下一個人以為那條有覆蓋到，而它沒有。**

★★★**所以盲點其實有【兩種】，你點名的那種更嚴重**：
```
\u2605a. \u7b26\u865f\u5728\u5b57\u4e32\u5b57\u9762\u91cf\u88e1\uff08"ticks": 720\uff09\u21d2 \u88ab\u5265\u6389
\u2605\u2605b. \u3010\u6839\u672c\u4e0d\u5f15\u7528\u7b26\u865f\u3011\uff08const MSG_TTL_SHORT = 1680\uff09\u21d2 \u2605\u2605\u2605\u9019\u7a2e\u6c38\u9060\u4e0d\u6703\u9032\u5019\u9078\u96c6
```
★**b 沒辦法靠「掃 tick 符號」解** —— **要解得換一條軸：★★【名字像時長 ＋ 值是裸整數】，而那正是我上面那條 grep。**
★★**要不要把那條 grep 做成守衛的第二軸，你裁**（我沒有自己加，因為它會改變守衛的判準面）。

# ★★★★③g1a 未歸因已落地 known_issues —— 收到
★**而你「不留實驗鷹架」那句我照做了**：**三個臨時實驗（插 seed／插探針／臨時 worktree）全撤，工作樹乾淨。**

# ★④fp 兩床【都沒變】—— ★而這次「沒變」不是警訊
```
warring 4f1c0eda\u2026\uff5cpeaceful c5ef5b06\u2026\uff08\u8207 S2 \u4e3b\u9ad4\u76f8\u540c\uff09
```
★**理由**：**`fp` 窗口是 1000 tick，重錨後【不到一天】** ——
**而這兩顆常數的時長是 2 天 / 7 天 / 14 天 / 30 天 ⇒ 窗口內根本走不到它們的效果。**
⇒ ★★**這是「窗口太短」不是「修改無效」** —— ★★★**我不拿 fp 當這兩顆的證據**（同今天那條：證據要對得上命題）。
★**要證它們，得用 ≥30 遊戲日的床** —— **而那正是 measurer 手上的統計等價床。**
★★**建議**：**這兩顆修完後，「訊息送達/日」那項值得重量一次** —— **若 −76.4% 收斂，假說二就從「成立」變成「已解釋該項偏差」。**

# ⑤閘
```
headless Q1 \u8dd1\u5b8c \u2705\uff5cQ2 baseline 7 / \u5be6\u6e2c 8\uff08\u591a\u7684\u4ecd\u662f g1a\uff0c\u672a\u6b78\u56e0\uff09
\u61b2\u6cd5\u9598 PASS\uff5c\u88f8 tick \u5b88\u885b PASS\uff08\u6bcd\u9ad4 142\uff09\uff5ctime_const_check PASS\uff08\u542b\u6839\u503c\u54e8\u5175\uff09
```
★**headless 的 `MsgPruneTest` 跟著修**：`prune_old_messages(state, 9999)` 的 9999 是舊根下「比 TTL_SHORT(1680) 大」的數，
**新根 TTL=10080 > 9999 就假紅** ⇒ 改成 `MSG_TTL_SHORT + 1`（**測的是「超過 TTL 就該被 prune」不是 9999 這個數**）。

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\message_system.gd:3-13
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\decision\decision_context.gd:127
commit bcbfb6f3
```
