---
from: implementer
to: systems
status: consumed
topic: ★**wagepen 現況（★從檔案，可複驗）**：`a396e935` 已 push，WIP **不再是未 commit 的半成品**｜★★而床印 **`ALL PASS` 而那是假的** —— ①「有錢卻不發」**從未被造出來**｜★★★接手的人**第一動作照你說的跑紅測，而讀法在下面**
---

# 一、★可複驗的狀態（★不用從記憶接）
```
branch  feat/wage-penalty-rework   HEAD a396e935（★已 push，樹是乾淨的）
改了    scripts/simulation/salary_system.gd（①②③ 全在）
新增    scripts/debug/wage_penalty_test.gd（驗收床）
產物    docs/measurements/2026-09-08-wage-penalty-acceptance.txt
跑法    powershell -File tools/godot.ps1 --headless --path A:/GDS/demo/.worktrees/wagepen \
          --script scripts/debug/wage_penalty_test.gd
```

# 二、★★★而 `ALL PASS` 是假的 —— ①那格的情境沒造出來
```
輸出：① 忠誠 0.8000 → ★0.8060（上升）｜ paid_full=3 ｜ ★★willful=0
⇒ 那是【付滿並拿到 overpay 加成】，不是「有錢卻不發」
⇒ ★★★spec §3① 仍未被驗證，而床照樣印 ALL PASS
★成因：我的兩格斷言太弱 ——
   「發薪真的發生了」與「有錢的隊不得被判成付不出」★在【付滿】時也成立
⇒ ★★唯一的破綻是輸出裡那個 `willful=0`，而它【只是 print 不是斷言】。
⇒ 修法：★①要真的造出「付得起卻定低薪」——
   而 NPC 隊的 `p.salary` 會被 `fair * npc_salary_mult` 覆寫，
   ★★所以 fixture 要嘛走 player team 路（`is_player_team`），
     要嘛壓低 `npc_salary_mult`（它由 leader 人格推導）——★我還沒查它的來源。
```

# 三、★而②那組【是真的通過了】（★兩組要分開講）
```
② 無幣村：忠誠 0.8000 → 0.8000 ／ unrest 0 → 0
   `unpayable_local = 3` ／ `unrest.suppressed_unpayable = 3`  ← ★母體非空
⇒ ★★這一組有母體、有三格 reason 佐證 ⇒ 它不是假綠
⇒ ★★★而本票的主 bug（無幣村被冤枉）就是這一組 —— 它已經修好了。
```

# 四、★第一跑抓到的另一個假綠（★留著當交接的證據）
```
第一跑：三格 reason【全 0】⇒ `_pay_salary` 根本沒被呼叫
   而床印了兩個 PASS（忠誠沒掉／unrest 沒加）—— ★兩個都是真的「數字沒變」，
   ★★而它們的解釋是錯的：薪水沒發，當然沒掉。
   ⇒ ★★★接住它的是我加的母體格（`unpayable_local > 0`）。
   成因：fixture 把 `salary_eval_next_tick` 設 0
        ⇒ 走進「第一次只初始化、`continue` 不發薪」（⑦ 遷移留下的分支）。
```

# 五、★接手清單（★三件，序不能換）
```
①先跑紅測（照你說的）—— ★而【不要看 ALL PASS】，看 `willful` 那個數字：
   `willful=0` ⇒ ①的情境沒造出來
②修 fixture 讓①真的「有錢卻不發」，並把 `willful>0` 寫成【斷言】不是 print
③④anon 那格我查過：`salary_system.gd` ★零個 `morale` 引用、anon 側沒有懲罰可移除
   ⇒ ★★與 ③ 同型，可能又是「不存在的東西」——★★★驗完再動，別先做。
```
