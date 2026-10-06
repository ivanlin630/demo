# A1 建設是綁地點的動詞：帶自己的據點格走過去才開工；無家不可選（HOW）

```
票源 ＝ 藍圖裁 `96ce216c1`（量已窮盡：30 天 Σ(i..iv) 每日對帳成功、P4 陽性對照過）
基準樹 ＝ `b4eb250b8`
序 ＝ 照實作端序列（A1 在 A2 之後）
```

## §0 量到的（藍圖信）＋ code 現況

```
Team0：有 4 個據點、人不在家 ⇒ 「建設」to_task ＝ `{TASK_BUILD, target＝team.tile_pos}`（`options.gd:70-77`）
  ⇒ 在**腳下**施工，而腳下沒有工地 ⇒ TASK_BUILD 永遠沒東西可推進（A1 tap 的 (iii) 類）
Team3：無家（home_count＝0）⇒ 「建設」照樣可選（`applicable` 回 true，註解「bootstrap＋升級皆候選」）
抵達開工的既有管線：`movement_system.gd:400-401` 抵達時 task ∈ {CONSTRUCT, UPGRADE, EXPAND} ⇒ `begin_subteam_construction`
  ⇒ `outpost_system.gd:788-805` 依 task 呼 start_build／_subteam_upgrade_level／_subteam_upgrade_facility
⇒ ★TASK_BUILD **不在**那個清單裡 ⇒ 帶 TASK_BUILD 走到哪裡都不會開工
```

## §1 做什麼

```
①「建設」`applicable` ＝ **有自家據點**（`ctx.has_own_outpost` 或等價欄位 —— 先查 ctx 裡現成的名字）
  ⇒ 無家 ⇒ 不列（藍圖：列的條件＝做的條件）；票 B 落地後改成「列而帶 ineligible: 無據點」
  ★禁：「不在家就 skip」的盲閘（藍圖逐字 —— 那會讓 Team0 永遠不蓋）
②「建設」`to_task` ＝ **回自己的據點蓋**：target ＝ 自家據點格；task ＝ 抵達後會開工的那一種（UPGRADE／EXPAND／CONSTRUCT）
  ⇒ ★走**既有**的抵達開工管線（`movement_system.gd:400-401`），不新建第二條
  ⇒ 選哪個據點、做哪一種：★**先查**基建評估層（`faction_ai_system.gd:6113` `_evaluate_independent_infrastructure`）有沒有
    「選哪個設施／升級」的**純函式**可重用 —— 有就呼它（單一來源），沒有就回報我（不准在 to_task 裡另寫一套選址邏輯）
  ⇒ 選不出任何可做的工程 ⇒ 不列（不是列了再空轉）
⑤「建設」那一項的註解帶標記 `A1-place-bound`（★defer `a1-upgrade-blocked-wrong-type-and-pop-min` 的回訪條件錨在它上面 —— 錨在程式碼不錨在文件，免得被自己寫的進度紀錄提早推真）
③無家的隊的立業驅力：**不在本票新建選項**；本票只要求證明它沒有被困 —— 見 P3
④why 字串（★藍圖前提訂正，見 §2）：`faction_ai_system.gd:2000` 「備戰籌餉(建材枯)」改成印**數量與門檻**
  （例：「備戰籌餉（建材 80／200）」）—— 不改觸發條件
```

## §2 ★藍圖前提訂正：「建材枯」**有**讀真值

```
`faction_ai_system.gd:1996-1997` `war_chest_need := (ambition > 0.6 or martial > 0.6) and leader_team.material < WAR_CHEST_MIN`
`:23` `WAR_CHEST_MIN = 200.0` ⇒ material 80 < 200 ⇒ 條件**成立**，句子是真的
⇒ 病在**用詞**：「枯」讀起來是「沒有了」，實際是「低於 200」⇒ 給人讀的句子要印**量與門檻**（C′ 同族）
⇒ ★另：它讀的是 `leader_team`（勢力盟主隊）的 material，卻掛在 Team0 的意圖上 —— 若 Team0 不是盟主，那句話說的是**別隊**的倉庫
  ⇒ 句子裡要指名是誰的建材（先核 Team0 是不是盟主）
```

## §3 驗收（藍圖的兩格＋我加一格）

```
P1 佈置「有據點、人不在家、committed 建設」⇒ N tick 內 move_target ＝ 自家據點格，**抵達後 construction_team_id ≠ -1**
   （N 從距離×一格成本推導）＋負對照：to_task 改回 target＝腳下 ⇒ 必紅
P2 佈置「無家、committed 建設」⇒ 建設**不在可選清單**（或 ineligible「無據點」）
P3 ★無家的隊沒有被困：修後 Team3 那種隊的候選清單裡，**至少一個立業選項（求居／紮根／擴點…）是可選的**
   ⇒ 若一個都沒有 ⇒ **回報我**（那是另一個缺口：拿掉建設之後它無路可走），不在本票補
P4 why 字串：印出的量 ＝ 當下 `leader_team.resources["material"]`、門檻 ＝ `WAR_CHEST_MIN`；句子指名是誰的倉庫
P5 fp 會變 ⇒ 量；基準與改動原子落地
```

## §4 不在本票（登 defer）

```
升級既有據點被 `wrong_outpost_type`／`pop_below_min` 擋（藍圖：另一張，先登 defer）
```
