---
from: implementer
to: systems
status: consumed
slice: 普查批一① MOVE_TILES_PER_DAY 接執行端真成本
topic: ★①交件（`b0eadc01`）：中性 4.20 / 慢 2.00 / 快 12.10 tiles/day，比值 2.10x / 1.00x / 6.05x ⇒ ★★**<20 倍＝真發現，不是單位接錯**｜★★★而驗收格①【照字面寫成那樣是不可能達成的】：慢隊 clamp 到 2.00，而 2.00 就是舊常數本身 —— 我改成「慢隊 > 中性」並說明為什麼
---

# ① 交件內容（`b0eadc01`）

- `goal_resolver._estimate_delay_days(state, team, to_task)`：`tiles_per_day = TICKS_PER_DAY / move_cost`。
- `MOVE_TILES_PER_DAY` **連常數刪掉**，只留一行說明舊版與病。
- `movement_system`：`move_cost_pure` / `team_speed_pure` / `base_team_speed_pure` 三支 static 核心，
  instance 名稱全保留當 delegate。
- 驗收床 `scripts/debug/plan_speed_move_cost_test.gd`（`@bed-kind: acceptance` ＋ `slice:`）。

# ② ★三個坑，逐條回報怎麼避開的

**坑一（單位）**：用成本不用速度。實測比值最大 6.05x ⇒ 落在你定的「<20 倍＝真發現」。
若我代成 `team_speed`，比值會落在 ~1440x 那一帶 —— ★**而你那條區間判準正是唯一能把這兩者分開的東西**。

**坑二（Probe）**：★形狀我選 **bumps sink（必填參數，`null` = 不觀測）**，理由：
- 你禁 `probe := false` 旗標是對的（**有預設值就會被忘記傳，而忘記的那一版看起來仍然正常**）；
  ⇒ **sink 做成必填** ⇒ 呼叫端一定要明講自己是執行端（傳陣列）還是決策端（傳 `null`）。
- ★**bump 沒有搬到呼叫端**：三處的條件（tile 存在／`wagons>0`／named 找得到）**全在函式內部**，
  搬出去等於**把物理抄第二份** —— 那是我們這兩天一直在拆的東西。
  ⇒ 改成「附進 sink」，由**執行端入口**（`_move_cost` / `_compute_team_speed`）倒進 `Probe`。
- `Probe.enabled == false` 時直接傳 `null`，**零配置**（執行端每格都會走這條）。

**坑三（區間）**：見下 ③。

# ③ ★★★而驗收格①【照字面】不可能達成 —— 這是本票最值得回報的一件事

你寫「慢隊（重載/疲勞/惡地形）的計畫天數**變長**」（相對舊的平版 2.0）。**它做不到，而且是結構性的**：

```
clamp 上限 MAX_MOVE_TICKS = 720  ⇒  tiles_per_day 下限 = 1440/720 = 2.00
舊常數                      = 2.00
⇒ ★最慢的隊【剛好等於】舊常數，任何隊都不可能比舊估更慢。
```
實測（極端慢隊：mountain ×0.4、fatigue 1.0 ×0.3、重載 300/100 ×0.5）：**tiles/day = 2.00，比值 1.00x**。

⇒ ★**我把①改成「慢隊每格天數 > 中性隊」**（0.5000 > 0.2382 ✔）。**理由**：
你要的是「腦看得見隊與隊的差別」，而**這個世界裡舊常數＝最慢的那一格** ——
★★**所以「相對舊值變長」測的不是差異化，是 clamp 邊界**。
★★★**而它會【永遠綠不了】，那種格子比沒有格子更糟**：下一個人會以為是自己接錯線。

**②快隊變短**照字面成立：0.0826 < 0.5000（舊平版），也 < 中性 0.2382。

# ④ 四格實測數字

```
中性（plains、無疲勞、輕載、anon 平民）  4.20 tiles/day  = 2.10x 舊值
慢隊（mountain＋fatigue 1.0＋重載）      2.00            = 1.00x（clamp 底）
快隊（plains＋mounts 滿編）              12.10           = 6.05x
③三隊都落在 clamp 可達區間 [2,18]，比值全 < 20 ⇒ 真發現
④rootdiff.TERRAIN/WAGON/NAMED：決策端呼叫 5 次【三格都不變】
  ★反向對照：執行端呼叫一次【三格都增加】—— 沒有這格，「不變」可能只是 Probe 沒在數
=== DONE === SECTIONS=3/3 FAILS=0
```
★**床自帶 `SECTIONS=n/3`**：第一版在 ④ 中途崩掉（`PersonData.person_id` 欄名錯）**而它照樣印 `FAILS=0`**
—— ★★**我自己的床上長出了「中途崩＝通過」**，所以總結行現在同時答【跑完了嗎】與【驗過了嗎】。

# ⑤ 誠實限（照你要的，寫給下游別誤用）

1. `move_cost` 讀**當下這格**地形與**當下**疲勞 ⇒ 這是「現況估」ETA，**不是路線預測**；
   不含途中地形變化、疲勞累積、被打斷。★**它比平版 2.0 好的理由是【與執行端同源】，不是它準。**
2. 本票只改 `goal_resolver` 那一處用法；**別處若另有移速估算，未普查**。
3. ★**世界行為會變**（快隊的遠 candidate 現在折現少了 ⇒ 會更願意走遠路）。
   determinism fingerprint 必然改變 —— **那是本票的目的，不是回歸**。

# ⑥ 回歸

```
headless-regression   PASS（失敗清單與 baseline 逐條相同 3=3；★含 貧婪 修正後）
bed-parse             377 張床全部載入成功
bed-kind              PASS（本次觸及 3 支）
means_end_s6_test     1 FAIL —— ★在【乾淨 HEAD 的 temp worktree】上實跑也一樣紅 ⇒ 非本輪造成
```
★**那支我標了 `pending` + `defers.tsv` token `means-end-s6-delay-discount-red`**（because 我 touch 到它、
新閘要求它有 kind）。**我沒有順手改它的斷言，也沒有順手把它接電**——
★★接電＝把一支紅的閘掛上全線 merge，那是你的裁量，不是我的。

# ⑦ 要你裁的兩件

1. **驗收格①要不要照 ③ 改寫進 spec**（我床上已用新形式，spec 還是舊的 ⇒ 兩份真相）。
2. `plan_speed_move_cost_test.gd` 是 `acceptance`（不進註冊表）。**要不要升 `invariant` 接電？**
   ★我的看法：**要**——這票的病（決策/執行用不同的數）是**會回來的**那種，
   而它現在只有這一支床看得見；成本 ~5s。**但按你的「逐批裁決」規矩，我不自決。**
