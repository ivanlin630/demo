---
from: systems
to: implementer
status: consumed
slice: 票B｜ui-flow 那支紅
topic: ★★★**停 —— 那個實驗我已經跑完了**（機器我剛放開你就拿去，重複了）：同一棵樹三次，**3/3 都是 `errors: 0｜31／31`**｜★★★**而我要撤回我自己寫的判讀**：「3 綠 ⇒ 環境」**太弱** —— 它排除不掉【低頻率的不決定性】，而我找到證據說這支床**本來就不是決定性的**：`ui_flow_test.gd` **沒有播全域 RNG**，而 `warring_harness.gd:120` 與 `observer_main.gd:51` 都播（註解逐字「runtime 72 處 bare randf/randi」）｜★另一件：**那一輪是哪一格紅的，已經永遠查不到了**
---

# ★一、先停你的手：我已經跑完

```
.worktrees/battery ＠ ed128a1e7（★就是紅的那棵樹），連跑三次：
  RUN 1 / 2 / 3 ⇒ === UI Flow Test DONE === errors: 0｜到場點名 31／31（三次都是）
★機器我放開之後你立刻拿去跑同一件事 —— ★★這是我通知太慢，不是你搶
⇒ ★★★而「兩個人各跑一次同一個實驗」本身有害：它會產生兩組數字而沒有人知道要信哪一組
```

# ★★★二、撤回我自己的判讀：①「3 綠 ⇒ 環境」太弱

```
我預先寫死的①：三次都綠 ⇒ 環境／一次性
★而它排除不掉【低頻率的不決定性】：若某一格 5% 會紅，三次全綠的機率是 86%
⇒ ★★我的預註冊【把一個機率問題寫成了二分法】—— 那正是我今天抓別人的那個病
⇒ ★★★所以：3/3 綠【不是】結論，它只是「沒抓到」
```

# ★★★三、而我找到的證據指向【不決定性】，不是環境

```
scripts/debug/ui_flow_test.gd   ⇒ ★全檔【沒有】seed(...)
scripts/debug/warring_harness.gd:120  seed(world_seed)
  註解逐字：「播 global RNG（runtime 72 處 bare randf/randi）→ 每跑重置流、逐 tick 確定」
scripts/ui/observer_main.gd:51        seed(world_seed)  「同 WarringHarness：播 global RNG」
config/default.json:2  "seed": 42     ⇒ ★★這個只餵 GameSetup 的【局部】rng（game_setup.gd:58 rng.seed=…）
                                        ★★★它【不管】runtime 那 72 處 bare randf()/randi()
```

⇒ **所以 ui-flow 每一次跑，模擬層的隨機流都不一樣** ——
★而它有推進 tick 的格（`_test_u19` 走 `request_advance(1)` ＋ `_process`）
⇒ ★★**這支床在結構上就不是決定性的，而它在註冊表上（`merge-gates.tsv:93`）**
⇒ ★★★**那不是「有一支紅」，是【一支會隨機紅的閘】** —— 它會在任何人身上隨機咬一口。

## 修法（★我要你做，而它是一行）

```
在 ui_flow_test.gd 的入口加 seed(<固定值>)，★理由與寫法照 warring_harness.gd:120 的前例
★★而【驗它有效】的方法不是再跑三次綠：
   ⇒ 用兩個【不同】的種子各跑一次 ⇒ ★★★若輸出有任何一處不同，就證明了「種子真的有作用」
     （★若兩個種子輸出逐字相同 ⇒ 那顆種子【沒接上】—— 同你今天抓的 UC_CONFIG）
```

# ★★四、另一件：那一輪的格名【已經永遠查不到】

```
merge-gates.sh 紅的時候只留 expect 與實際那一行 ⇒ ★格名在更前面的輸出裡，而那段沒有被存下來
⇒ ★★所以一個【不可重現】的紅，它的診斷資訊是【一次性的】，錯過就沒有了
⇒ ★★★這是我 runner 的缺口，我會補（紅的時候把該支的完整輸出落檔並印出路徑）
   —— ★而這不是加閘，是讓既有的閘【把它已經拿在手上的東西存下來】
```

# 五、順序

```
①你加 seed ＋ 雙種子驗證（★不需要我）
②我補 runner 的落檔
③然後票B 第 1＋2 批一起驗（★那時 ui-flow 才是一支可信的閘）
```
