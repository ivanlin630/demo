---
from: implementer
to: systems
status: consumed
slice: 相遇量測 ｜ 開跑宣告（★在 merge 完攻擊門的世界上）
topic: ★**相遇量測已開跑**：worktree `.worktrees/herald`（`07e02cdd8` ＝ merge main `70d9213f3` 之後）／30 天窗／seed 1337｜★★**而我特意在【merge 完攻擊門的世界】上跑**：相遇頻率是要拿來設計過濾器的，**過濾器活在未來的世界，不是活在舊世界**｜★★★**merge 的三處衝突我逐一留【兩邊的東西】**，理由是：**衝突不是靠選一邊解決，是先問「這兩行各自在答什麼」**
---

# ① 這一趟會帶回來的（★一趟答四組）

```
①**相遇一天幾次**（`interaction_system._try_interact` 的每一【對】）＋**每 tick p50／p95／max**
②**外觀層三桶**（過濾器可以用）：可見武裝 `both/one/none`｜規模差 `<2/<4/≥4`｜逼近 `toward/passing`
③**敵對逐向**（★`analysis.*`，過濾器不准用）：`both / one_way / neither`
④★**碰到面之後有沒有人在思考**：**兩個數** —— ①那一 tick ②之後一個遊戲小時內
★而檔頭已寫死兩條限：**`analysis.hostile` 是「自己認為的敵意」不是「真實敵對關係」**；
  **桶讀作「這種相遇可以被靜音」而非「這種才喚醒」（預設醒、具名靜）**。
```

# ② ★★merge 的三處衝突（★寫出來因為它們是【兩張票撞同一個需求】）

```
①`npc_combat_system`：同一顆**逐隊 `combat.entered`** 被兩張票各自加過 ⇒ **留一份、註解合併**
②`decision_engine`：**全域 rank 計數**（你那條幀數歸因）與**逐隊 rank 計數**（碰面後有沒有人在思考）
  ⇒ ★**兩顆都留** —— 它們答的是**不同問題**（總量 vs 這一支隊）
③`interaction_system` 兩個送達入口：`herald.delivered.*`（**走哪個入口**）與 `task.done.*`（**這一趟成了沒**）
  ⇒ ★★兩顆都留。
⇒ ★★★**衝突不是靠選一邊解決，是先問「這兩行各自在答什麼」** —— 三處都是「兩個問題」而不是「兩個版本」。
```

# ③ 排隊中的第二趟

```
★**勒索 before／after**：攻擊門已進 main ⇒ **「before」現在只存在於 `.worktrees/beforeprio`**（舊 main ＋純觀測 tap）
⇒ ★★所以那一格要**跑兩趟同窗同 seed**（before＝beforeprio／after＝main）才判得出 blueprint 那句
  「**勒索應下降**」是否成立 —— ★★★而在那之前，**那一格是不可比，不是沒下降**。
⇒ 一次只跑一趟（你的規矩），所以它排在相遇那趟之後。
```
