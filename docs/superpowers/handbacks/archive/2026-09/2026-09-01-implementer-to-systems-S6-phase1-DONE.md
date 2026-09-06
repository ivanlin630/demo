---
from: implementer
to: systems
status: consumed
slice: S6-phase1（正典化 + 雙軌對帳）
tier: infra
topic: ★§1 改名 + §4 對帳都完成,commit daa46822 已 push;★★fp 逐位元不變(md5 相同);★★★對帳頭條=工期【表】有 4 種來源而 §2 的錨只推得動 1 種——CORVEE 那顆我第一版也漏了,原因與你漏它的原因相同(都從兩張表出發搜),已改用窄口重掃;★另有兩件要你裁:改名殺死了一條 triage 規則、headless 有一項既有紅
---

# ★①§1 改名 DONE（★純改名，零數值變動）

```
BUILD_TICKS                     → BUILD_PERSON_HOURS
FACILITY_DEF[*].cost.ticks      → cost.person_hours
build_eta_days(ticks_left, pop) → build_eta_days(person_hours_left, pop)
CAMP_BUILD_TICKS                → CAMP_BUILD_PERSON_HOURS
★tile.construction_ticks_left ——【沒有改】，照你先裁的（欄位名說謊比改壞存檔便宜）
```
★順手把三處自述註解改對（它們是這次改名要治的病本身）：
`outpost_system.gd:23/:48/:125`、`player_command_system.gd:9`，
其中 `:48` 換成實測結論並附 artifact 路徑（★不再寫「≈3 天」這種沒有出處的話）。
★★玩家可見字串 `player_command_system.gd:242` 的「%d ticks」→「%d 人時」（★它對玩家說謊）。

## 驗收（硬）
```
★fp 逐位元不變：warring seed1337，before/after md5 皆 6ece2c61215430cdcde8eca3b61039b3
★★build_eta_single_source_test：ALL PASS（fail=0）
★constitution_gate：PASS（sites=74, removed=1）
★bare-tick-gate：PASS（母體 171，NEEDS_HUMAN=0）
```

# ★★②改名的副作用：★★★它殺死了一條 triage 規則，而閘不會告訴你

```
改名後 CAMP_BUILD_PERSON_HOURS 不再落入 bare_tick_triage 的 *TICK* 母體
⇒ 那條 c_whitelist 規則變成【零命中】＝死規則＝盲點
```
★我已退休該規則，並確認**分類沒有遺失**（`const_time_triage` 母體較廣、仍涵蓋它；
`docs/measurements/2026-08-27-s1c-const-population.txt` 有它的 c_whitelist 行）。

★★**而要你裁的是通則**：目前閘只抓 **`b_defer` 的零命中**（那是我上輪加的 §1），
**`c_whitelist` 的零命中不抓** —— 樹上現有 **5 條** 既存零命中 c_whitelist 規則。
⇒ ★★★**每一次改名都會製造這種死規則，而它靜默。**
   建議（★你裁）：把「零命中」的檢查從 `b_defer` 擴到**所有** bucket，
   輸出成【註記】而非 FAIL（否則正常演化會恆紅）——形狀同我上輪那個「本輪無母體」註記。

# ★★★③§4 對帳 DONE —— 落地 `docs/measurements/2026-09-01-s6-phase1-dual-track-audit.txt`（180 行）

## 頭條：**工期【表】有 4 種來源，而 §2 的錨只推得動 1 種**
```
A1  FACILITY_DEF[*].cost.person_hours   八顆  ←【新表】＝ S6 那八項，錨推得動
A2  BUILD_PERSON_HOURS                  六顆  ←【舊制】另一張表，★不在八項裡
A3  CAMP_BUILD_PERSON_HOURS             一顆  ←【舊制】第三張，★不在八項裡
★H  L0_TO_L1_CORVEE_DAYS × TICKS_PER_DAY 一顆 ←【第三種】自己另有換算（你補的那顆）
```
⇒ ★**§2 若寫成「改錨 ⇒ 全表八項等比例跟」，它會綠，而 A2 六顆 + A3 一顆 + CORVEE 一顆共 8 顆工期原地不動。**
⇒ ★★**而三個決策端（`decision_context:392`／`goal_resolver:913`／`faction_ai:4133`）讀的都是 A2 不是 A1**
   ⇒ ★★★**NPC 心裡的「蓋一座要多久」走的是舊制那張表** —— 錨推 A1 而不推 A2，決策端認知完全不動。

## ★★我第一版的「窮盡」也漏了 CORVEE —— ★★★而漏的原因與你漏它的原因是同一個
```
我的搜索從【兩張表】的 token 出發（BUILD_TICKS / "ticks" / build_eta_days）
⇒ 而 CORVEE 不經任何一張表 ⇒ ★它在我走的管道裡天生不存在
```
★**改用真正的窄口重掃**：任何工期要生效都得寫進 `tile.construction_ticks_left`
⇒ 列舉它**所有賦值點** = 25 處，其中 `=0`（清除）17 處、**真正寫入工期的 8 處**（清單在 artifact）。
★★**這個列舉是收斂的**：窄口由引擎決定，不隨別人怎麼命名而發散；token 列舉則會。
⇒ ★★★**建議 phase2 的驗收改綁這 8 個賦值點，而不是綁「八項」** —— 綁八項的話 CORVEE 這種永遠在帳外。

## ★兩顆「拿工期當門檻」（★我只標，判定給你）
```
C1  faction_ai:5079/:5086  SURVIVAL_BUILD_MAX_TICKS = 120
    現況＝「求生期蓋得起的東西」＝ 工期 ≤ 120 person-hour（註解自述 farming 72 過、workshop 168 不過）
    ★錨推到 288（×4）⇒ 120 連 farming 都擋掉 ⇒【求生自救建設整個關掉】，★★而沒有測試會紅
    ★★★我的標記建議＝【該跟著錨走】，且形狀該是「farming 工期 × 某倍數」（接線）非死值 120
C2  faction_ai:5133  int(cost.get("person_hours", 72))
    ★那個 72 是 farming 工期的【手抄副本】當 fallback ⇒ 錨一改就分家
    ★★現況是死路徑（八顆都有該鍵），★★★但它是【會醒過來的死路徑】：新增設施漏填就吃到它
    我的標記建議＝【bug 非設計】：從 FACILITY_DEF 讀，或讓缺鍵直接爆
```
★★兩條都只是**我的建議**，不是事實 —— 判定是你的。

## ★★★CORVEE 那顆我另外查到兩件你信裡沒寫的
```
①decision_context.gd:404  camp_flow_delay_days = dist + L0_TO_L1_CORVEE_DAYS
   ★它把同一顆常數直接當【天】相加，而 :361 把它當【person-hours 的來源】
   ⇒ ★★同一顆常數在【同一個檔】裡被當成兩種單位用 —— 比「名字說謊」更進一步
②debug/settlement_s2b_test.gd:61/131 鏡了同一條式子
   ⇒ ★★★phase2 改法時這張床會【綠著說謊】：它斷言的是「等於那條式子」不是「等於某個工期」
   ⇒ 建議 phase2 把該斷言換成【對著錨的絕對值】，否則那道 gate 是空的
```
★另：`docs/estimator-ledger.md:36-37`（A5/A6）已經記過這條路徑低估 10×，標「待修」。

## ★CORVEE 現值（★標成推導，不是量測）
```
3 × TICKS_PER_DAY(1440) = 4320 person-hours ⇒ pop=10 時 = 4320/(10×24) = 18.0 天
而常數叫 CORVEE_DAYS = 3
```
★**這是算術不是量測**——同一支床（`s6_build_days_truth.gd`）改 cost 就能實跑複驗，本輪沒跑，照實標。

# ★④phase2 你先講死的那條約束，我收到並同意方向
> 紮根不得只把 `TICKS_PER_DAY` 換成 `TICKS_PER_HOUR` 了事

★而我要補一句**實作面的後果**：若照你傾向的「人力假設消失、錨直接是 person_hours」，
則 `decision_context.gd:404` 那個「直接當天數加」的用法**會失去它的來源**（3 不再是天數）
⇒ ★★**那一處必須同批改**，否則錨改了它還在加 3 天，而**它不會報錯**。

# ★⑤紀律核對 / 誠實記錄

- ★§4 對帳：**零 production 改動**（改動全在 §1 授權範圍內）
- ★★commit `daa46822`（+ 前一顆 `d4b7d337` 是 build-eta 實測）已 push
- ★★★**兩項紅燈，都不是這次造成，已逐項對照 HEAD 確認**：
```
settlement_s2b_test  FAILS=18  ⇒ HEAD（改名前）同樣 18
headless_test  比 baseline 多 1 項 [g1a] 礦村未鑄幣
  ⇒ ★HEAD 同樣紅、同一行字 ⇒ 非改名造成
  ⇒ ★★但它【不在 docs/test-baseline-failures.txt 裡】⇒ 這道閘現在對所有人都是紅的
  ⇒ ★★★要你裁：是先前某顆 commit 帶進來的真回歸，還是該入 baseline？
     我沒有往回 bisect —— 那超出這一票，且會動到別人的 branch 判讀
```
- 臨時 worktree `.worktrees/_tmp_s6base`（開來跑 HEAD 對照用）**已完全清除**（registration + 目錄）。
