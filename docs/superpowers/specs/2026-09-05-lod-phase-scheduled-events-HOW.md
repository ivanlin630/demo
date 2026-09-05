# HOW spec（草案；★待 R²）— **排程事件必須玩家無關地發生**（第⑦票，★憲法修復）

WHAT／裁定：blueprint 2026-09-05 —— **far pass 每 100 tick 的距離分班殘留＝直接違憲**
（**世界存在性法**：模擬層零 LOD／計算跟隨**事件密度**不跟隨**觀察者**／玩家距離分班刪除，用戶 2026-08-20 立）。
★**而「遠隊只領 1/5 薪」正是那條法要防的東西。**

## §1 病灶（★已驗算，非推論）
```
sim_runner.gd:291  near pass 閘 = tick % NEAR_CADENCE(60)      == 0
sim_runner.gd:337  far  pass 閘 = tick % FAR_ZONE_INTERVAL(100) == 0
salary_system.gd:31          發薪 = tick % SALARY_INTERVAL(10080) == 0
⇒ payday t = 10080k ⇒ 10080k % 100 = 80k % 100 ≠ 0 直到 k=5
⇒ ★payday k=1..4 對 far 隊【全部落空】;k=5 才第一次對上
⇒ ★★近隊【月月領薪】,遠隊【四個月領一次】—— 而無玩家世界裡「遠隊」＝【全部】
```
★**證據鏈**：implementer 刪掉 `TAG_PRODUCE` early-return 後，`_pay_salary` 的 **entry tap（在函式最上面）仍為 0**
⇒ **不是早退，是【根本沒被呼叫】**。★★**而那個 0 底下住著兩種東西，是分開記之後才看見的。**

## §2 ★★★為什麼既有的「LOD 降頻補償紀律」沒接住它 —— **它缺第五型**
```
既有四型:機率型(÷trials)／累積型(×trials)／離散門檻型(不補償,只延遲)／飽和型(不補償)
⇒ ★它們共同的假設是:【降頻的後果是「率的失真」】,所以處置都叫【補償】
⇒ ★★而【排程型(精確時點)】的後果【不是失真,是事件根本不發生】
   —— payday 落在 far pass 的相位縫裡 ⇒ 不是少發,是【一次都沒發】
⇒ ★★★所以處置不是「補償」,是【不要用精確 modulo 當閘】
```
★**這條要進 `invariants.md`（我 owner）** —— 見 §5。

## §3 動作（★零新機制：用既有的 `CadenceStagger`）
```
★形狀:把【精確 modulo】換成【與 last_eval_tick 比較】
   —— 事件在【到期後的第一個 pass】發生,而不是【只在恰好那一 tick 有 pass 時】發生
⇒ ★★這正是策略層已經在用的東西(INFRA_INTERVAL 那一排,全 repo 23 個呼叫點),
   而它們【免疫】於這個相位問題,不是因為運氣好,是因為判準不同
★遷移兩顆:
   ①salary_system.gd:31       SALARY_INTERVAL 10080 → %100 = 80  ★中招
   ②faction_ai_system.gd:1499 定期徵收,動態 interval             ★同一類(只在恰好 100 倍數時 far 隊徵得到)
★安全不動:faction_ai_system.gd:1170  TICKS_PER_MONTH 43200 → %100 = 0
   ⇒ ★★而它「安全」是【巧合】不是設計 —— ★★★所以它也要遷,否則下一次有人改 FAR_ZONE_INTERVAL 就會靜默中招
```
★★**禁止的修法**：**調 `SALARY_INTERVAL` 的數值讓它變成 100 的倍數** ——
★★★**那是把相位問題偽裝成調參問題**，而它會在**任何人改動 `FAR_ZONE_INTERVAL` 時靜默復發**。

### ★跨多個週期時的語意（★要寫死，不能留給實作猜）
```
salary:far pass 每 100 tick、payday 每 10080 ⇒ 兩次 pass 之間【最多跨 1 個 payday】
   ⇒ 「補一次」與「補 N 次」在此等價
★★但【定期徵收】的動態 interval 沒有這個保證
   ⇒ ★★★所以規則要寫成:【補到期的次數，而不是「發現逾期就做一次」】
      —— 否則長間隔的 far 隊會被【結構性少做】,而那又是同一種靜默失真
```

## §4 ★★同族掃描（blueprint 指定，★一併列，不留給下次）
```
判準:【裸 `current_tick % INTERVAL`】長在 shape:"teams" 且 LOD_BOTH 的 step 裡
     且 INTERVAL 不是 FAR_ZONE_INTERVAL 的倍數
★已掃(implementer,scripts/simulation 全掃 `current_tick % `,扣掉 whole-state 的):
   命中 3 處(salary:31／faction_ai:1170／faction_ai:1499),其餘走 whole-state 或 CadenceStagger
★★而本票要求【把掃描做成機械的】:一道閘,禁【新的】裸 `current_tick %` 出現在 teams-shaped 的 step 裡
   ⇒ ★★★照 print-join／live-teams 那兩道的模子(機械 grep ／ allowlist 具名放行 ／ 新出現一律 FAIL)
   ⇒ 否則這一類會【再長出第 4 顆】,而它一樣是靜默的
```

## §5 ★憲法補行（`invariants.md`，我 owner）
```
「LOD 降頻補償紀律」補【第五型:排程型(精確時點)】
   降頻後果 = ★【事件在相位縫裡整個不發生】(不是率失真)
   處置     = ★★【禁用精確 modulo 當 pass 內的閘】,改與 last_eval_tick 比較(CadenceStagger)
   ★★★驗收 = far 與 near 的【事件發生次數】相等(不是「有 fire」就算過)
```

## §6 驗收
| # | 判準 |
|---|---|
| 1 | ★**預設床（無玩家 ⇒ 全 far）上，`_pay_salary` 的 entry 次數 ＝ 30 日窗的發薪日數（4）** ——★★**不是 >0 就算過** |
| 2 | ★★**far vs near 的發薪次數相等**：同 seed，一次全 far、一次 `FULL_HD=1` 全 near ⇒ **兩邊的 entry 次數與總支付額相等**（★★★這是「玩家無關」的直接斷言，也是憲法那條的操作定義） |
| 3 | ★`faction_ai:1499` 定期徵收同樣做 far/near 次數對照 |
| 4 | ★★**鑑別力**：把遷移撤掉，判準 1 必須變回 **0**（★★★而**不是變小** —— 若撤掉後仍非 0，那我們量的不是這件事） |
| 5 | ★新閘（禁裸 `current_tick %`）**陽性對照真的跑到**：故意加一個 ⇒ FAIL 且**指名行號**；還原 ⇒ PASS |
| 6 | determinism 三跑一致（★`fp` **會變**，而且**應該變** —— 遠隊開始領薪了）＋ 全部 merge-gate |

## §7 不在範圍（★具名）
```
★①`FAR_ZONE_INTERVAL`／`NEAR_CADENCE`／`SALARY_INTERVAL` 的【數值】—— 一個都不動
★★②near/far 分班機制本身(憲法說要刪,但那是【大工】)——本票只修【排程事件被相位吃掉】這一類
   ⇒ ★★★而本票落地後,「遠隊少領薪」這個【症狀】會消失,但【分班仍然存在】—— 那要另外開票
★③⑥(拔身分閘)的效果驗收 —— 它必須【等本票落地後在預設床重跑】,因為在此之前那條路一次都跑不到
★④B 議程的 coin 證據 —— blueprint 已裁【全部作廢待⑦修後重量】
```
