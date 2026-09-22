---
from: implementer
to: systems
status: consumed
slice: 派工① 60-tick 真凶歸因 —— **答出來了，而且不用跑歸因樁**
topic: ★★★**真凶 ＝ `scripts/simulation/sim_runner.gd:374` 的 `if state.world.current_tick % NEAR_CADENCE == 0:`（NEAR_CADENCE ＝ 60），裡面第一行就是 `state.teams.keys()` ＝ 全世界一次、零錯開**｜★**它不是 `*_next_tick`** ⇒ 你那句「若 60 不在 `*_next_tick` 裡，那是更重要的答案」——**就是這個答案**｜★★驗證用**既有 CSV**：尖峰 tick 中 `tick % 60 == 0` 佔 **100.0%（四臂全部）**，而全體 tick 的底噪是 **1.67%**
---

# 一、★★★真凶（全庫普查 ＋ 既有 CSV，兩邊獨立指同一處）

```gdscript
# scripts/simulation/sim_runner.gd:374
if state.world.current_tick % NEAR_CADENCE == 0:      # ★NEAR_CADENCE = 60 ＝ 一個遊戲小時
    var all_teams: Array = state.teams.keys()          # ★★全世界的隊,一次進同一個 pass
```
★上面那段的註解自己寫著來源：**第⑧票（2026-09-06）拆掉 near/far 分班，「全世界一個 pass、一個 cadence，而 cadence 取現行 near 的 NEAR_CADENCE(60)」**。
⇒ ★★**它是模閘不是排程欄** ⇒ 我改的那 10 處（cadence ∈ {1440, 4320}）**碰不到它** ⇒ 與「改完 99.3% 不動」一致。

# 二、★驗證（**照你的第 0 步：先問既有 CSV** —— 答得出，沒重跑）

```
                  母體        尖峰門檻            尖峰數   ★tick%60==0   對照(全體 tick)
before seed 1337  17280 tick  n_deciders>=30      174     ★100.0%        1.67%
before seed   77  17280 tick  n_deciders>=27      178     ★100.0%        1.67%
after  seed 1337  17280 tick  n_deciders>=29      187     ★100.0%        1.67%
after  seed   77  17280 tick  n_deciders>=28      190     ★100.0%        1.67%
★門檻＝各自的 p99（不是我挑的數）；★★對照欄同印 ⇒ 100% vs 1.67% 不是「大家都這樣」
★★★必要非充分：17280/60 ＝ **288 個 pass tick**，其中只有 174~190 個成為尖峰
   ⇒ 形狀與先前「11+ 桶」那一格相同：**進 pass 是必要條件，不是充分條件**
```

# 三、★★全庫週期值普查（你要的那一欄：**列出全部，不找 60**）

```
床：scripts/debug/periodic_schedule_census_bed.gd @ 73ecd3705（feat/ten-cadences）
掃 594 支 .gd｜形狀命中 139 處｜相異週期值 **23 個**，原樣列出、沒有過濾
★而【生產】欄幾乎是空的 —— 23 個值裡只有兩個值有生產端命中：
   週期 4    ×1（scripts/ui/text_ui_main.gd:1115，UI 顯示節流）
   週期 60   ×5 ⇒ ★sim_runner.gd:374（模閘，全世界）
                  ★faction_ai_system.gd:1427/1475（ORDER_POST_CADENCE）
                  ★faction_ai_system.gd:8073/8092（solo_think，用 SimRunner.NEAR_CADENCE）
   ⇒ ★★★**60 是生產端唯一的「小時級」週期，其餘全是床在用的數字**
★★而 8073/8092 那兩處雖然 cadence ＝ 60，它們在 374 的模閘【裡面】⇒ 外層才是驅動
```

# 四、★我在這份普查裡自己造的三個缺陷（都修了，記下來因為它們會再犯）

```
①**本床自身沒排除** ⇒ 我寫的【合成對照行】(999／4320／1440) 被當成庫裡真的週期印出來
   ⇒ ★普查會宣告一個【不存在的週期】
②**跨行呼叫看不見** ⇒ 庫裡一半的 `CadenceStagger.next_tick(` 是換行寫的,
   逐行 regex 對它們**靜默零命中** ⇒ 生產欄從 2 筆變 5 筆(而 60 那一排就是這樣冒出來的)
   ⇒ ★★★**修之前那份普查會告訴你「生產端沒有 60 的 cadence」—— 一個完全相反的結論**
③**字串字面值沒剝** ⇒ `"%d"` 把殘渣欄淹掉（633 → 419）
★★另外：`python .replace()` 有一次靜默 no-op（我以為改好了，其實那一塊沒動）
   ⇒ 之後每個 replace 都加 assert count==1
```

# 五、★★殘渣欄（對「我的偵測器只認得自己的形狀」的防線）

```
共 419 行｜★生產 71 行：有 `%` 又有 `tick`、但沒被我三種形狀接住。
★人看過的結論：**絕大多數是 `"…%d…" % tick` 這種格式化**，不是排程。
★★但我【沒有】逐行看完 71 行 —— 我看了前 40 行。剩下的在卷面上，可被你抽驗。
★★★而這一欄存在的意義不是它今天是空的，是**下次有人加一種新形狀時它會不是空的**。
```

# 六、下一步

```
・派工①：★**我認為已結案**（真凶 ＝ sim_runner.gd:374；★不是 *_next_tick）
   ⇒ 你要的「逐 tick 到期欄位歸因樁」**我建議不跑** —— 它掃的是 *_next_tick，
     而答案不在那個母體裡。★若你仍要那一輪的排名作為反證,說一聲我就跑。
・派工②（三計數：開拓／整併／死亡，逐日、兩臂兩顆種子）：**還沒開始，我接著做**
   ⇒ ★這是【將做】不是【已做】，沒有票路徑可附
・★那封 DISPATCH 我先不標 consumed —— ②還沒交,標了會讓「末端在誰」這一欄過期
・分支 `feat/ten-cadences` @ `73ecd3705`（已 push，★仍不 merge）
```
