---
from: implementer
to: systems
status: consumed
slice: A3′ 待領在本人站上市集那一刻結清（spec 2026-10-07-a3prime-claims-settle-when-owner-stands-on-the-market-HOW）
topic: 交件；電池 2 紅＝world-fp（規格說會變，已歸因）＋play-selfcheck（同時有別人 Godot，單跑綠）；普查 P1 merge 後剩 1 對（§3 誠實限那一型的第三種形狀，照 spec 回報不擴）
---

# 一句話
分支 `feat/a3prime-claims-settle` tip `d4a92989b`（已推；＝ `292aab87f` 本體＋`ba569a70a` 閘列＋merge origin/main `f83a6edc2`，乾淨無衝突；之後 main 到 `5c6bb125a` 只動 docs，`git diff f83a6edc2 origin/main -- scripts config` 空）。
全量電池 run-id `3388-20261017-121231`（釘 `d4a92989b`，tree-after 同）：**139 ✓、2 ✗、BATTERY_RC=1** ⇒ **不是全綠**。
- ✗ world-fp no-verdict：final_fp `3f3ace84c19315433da8f6e565d7f01d`（expect `f8fb6b349bdc5fd23d9ee459c735d834`）。**我沒動 tsv 的 world-fp expect**——請你換。歸因見 §P8。
- ✗ play-selfcheck：唯一失敗＝「沒有殘留的 Godot 行程（前 2 ＝ 後 0）」——開跑時機器上另有 Godot（不是我這支鏈的）。**單跑重驗**（釘同 tree、godot-before 0）：errors 0、rc=0、godot-after 0。
- 本票閘列 `a3prime-claims-settle` ✓（8s）。

量測全落 `A:/GDS/demo/docs/measurements/2026-10-17-a3prime-claims-settle/`（41 檔）。

# P0（機械守衛）
- 動工基準 `ac9331482`：兩條 grep 皆 0 行 ⇒ `p0-start-ac9331482.txt`
- 交件 `d4a92989b`：`claim_on_arrival(` **1 行**＝`sim_runner.gd:942`；`outpost_owner != _t.team_id` 0 行 ⇒ `p0-delivery-d4a92989b.txt`
  ⇒ ★那 1 行是本票 §1① 自己新加的那一行（`_step3c` 迴圈最前面、不看任務），不是 A2 拿掉的舊入口分支（舊的是 TRADE 分支內 + owner 閘；owner 閘那條 0）。P0 寫的「＝0」是動工前條件；交件時這一條的期望本來就該是 1（spec 沒寫到交件期望，照實貼）。

# P1 普查（鑑別格，`a3prime_claim_census.gd`；不在閘內——誠實限）
| 樹 | default 1337 30 天 | fp 世界 20000 tick |
|---|---|---|
| 修前 `ac9331482`（`a3p-census-pre.txt`） | 38027 (隊,格)-tick／5 對 | 1896／5 對 |
| 修後 `292aab87f`（`a3p5-census-post.txt`） | **0** | **0** |
| 負對照 n1 拿掉②（`a3p5-census-n1.txt`） | 38027 | 1356 |
| **merge 後 `d4a92989b`**（`a3p7-census-d4a92989b….txt`） | **0** | **300／1 對** ⇒ errors 1 |

★merge 後那一對＝隊 4 @(2,21)、goods material 22、任務覓食、tick 17880..18179（300 tick）。診斷 `a3p8-diag-team4.txt`（腳本 `a3p_diag_team4.gd.txt`）：
- 條目 since 16061（隊不在場時產生 ⇒ ②接不到，正常）
- tick 17880 隊從 (2,20) 踏上 (2,21)，**同一拍 move_target 由 (0,23) 換成 (2,20)** ⇒ 不是「走到原目標」⇒ 不在 arrived_ids ⇒ ①接不到
- 之後 300 tick 停在 (2,21)、mt=(2,20)（相鄰卻不動——這本身像另一個病，我沒查）
⇒ 這是 spec §3 誠實限（「抵達以 arrived_ids 為準」）的**第三種形狀**：不是傳送／生成，是**半路踏上市集格、目標換掉**。照 §3「印出那些對，回報，不在本票擴」⇒ **沒擴**。
⇒ ★修前修後同支腳本：修後在 merge 前的樹是 0、merge 後冒出 ⇒ 是結構輪改了世界後才出現的樣本，不是本票退步。
⇒ 若要接：①的名單改成「站在 outpost_level>0 且腳下有自己 amt>0 待領的活隊」（不靠 arrived），一行等級；要不要做是你的裁。

# P2–P6 床（`a3prime_claims_settle_bed.gd`，閘列 `a3prime-claims-settle`）
修後 errors 0（`a3p3-a3prime_claims_settle_bed.txt`，到場點名 6/6）：
- P2 巡邏（TASK_PATROL）抵達 ⇒ material +7、自己條目清掉；【反向】別隊（不在場）7.0 不動
- P3 寄賣人站著、訪客吃單 ⇒ 帳本 claim_coin +35.83 ＝ 進待領 35.83；條目 0
- P3b 寄賣到期（`tick_team_orders`）人站著 ⇒ food +12 當場回手、條目 0
- P4 TRADE＋領取抵達別人市集 ⇒ 結清恰 1 次、領取落空記號 0、+7.00
- P5 帳本＝條目（逐格）；世界級對帳在普查：**所有普查跑 P5 PASS**（含 merge 後：fp claim_goods 52 ＝ taken 52；added−taken 119 ＝ 期末 119）
- P6 `_claim_pending_here(` 呼叫者＝`[add_pending_claim, claim_on_arrival]`
★修前床（`a3p-bed-pre.txt`）errors 9：P2/P3/P3b/P5/P6 紅、P4 綠（預期：修前 TRADE 也結清一次）。
  ★誠實：那一份是**改床前**版本——P3 的母體地板（「訪客真的吃到寄賣單」）也紅，原因是床把 escrow 條目同一個 dict 拿來比（已改 `.duplicate()`），而 P3 原本用 x 的 coin 差（被 peer trade 污染，已改成帳本 claim_coin ＝ added）。⇒ P3 的鑑別證據改以 **n1 負對照**為準（修好的床、母體地板綠、P3 紅）。

# P7 負對照（`neg_a3p.py.txt`；`a3p5-neg-n{1,2,3}.txt`）
- n1 拿掉②（add_pending_claim 的在場結清）⇒ P3、P3b、P5 紅（errors 5）；普查 P1 回到 38027／1356
- n2 ①改回只看 TASK_TRADE ⇒ P2、P5 紅（errors 3）
- n3 resolver 內那一行 claim_on_arrival 放回 ⇒ P4「領取落空記號 0」紅（errors 1）

# P8 world-fp（變了；已歸因）
- 基準樹 `f83a6edc2` 重跑 `wfp_attr_probe`（同 world-fp 那一趟、Probe 不開）final_fp ＝ `f8fb6b34…` ⇒ 與 expect 一致（儀器可信）
- 本樹 `d4a92989b` ＝ `3f3ace84…` ＝ 電池值
- 每 100 tick 逐域：9600 同、9700 全域分歧（`a3p8-attr-*.txt`）；逐 tick：**首分歧 tick 9689**（`a3p9-firstdiv.txt`、`a3p9-attr1-*.txt`）
- 那一 tick dump 欄位 diff（`a3p9-dump-*.txt`）：
  - 基準：(13,23) 上 `pending_claims=[{owner_team=40, goods material 15, since 9689}]`；隊 40 決策 偵查（ambition）
  - 本樹：同格 pending_claims 空（②當場結清給站在那裡的隊 40）；隊 40 決策 貿易（solo），同 tick 把那 15 material 重新寄賣（新 sell order 414、market_escrow 414）
  ⇒ 這一對就是修前普查表裡的 `40@(13,23) goods 貿易 tick 9689..9719`。**fp 變化＝本票②的預期語意**，不是別的東西。
- ⇒ 請換 expect `3f3ace84c19315433da8f6e565d7f01d`（換值是你的檔）。

# 玩家可見變化（請轉 QA／藍圖知悉）
- 玩家附身隊站在市集上取消寄賣或寄賣到期 ⇒ **貨當場回手**（以前要離開再回來才領得到）。事件會同時發 goods_returned 與 goods_claimed（claimed 先、returned 後）。
- `my_orders_panel_bed` 的 P1／E4／E5 fixture 我改了：post_order 後把賣方移出那一格（否則新語意下條目當場結清、斷言要的「掛著」不存在）。重跑 errors 0（`a3p4-my_orders_panel_bed.txt`）。
- 其他舊床修後重跑：claim_at_own_market 0、a2_trade_no_deal 0、possessed_orders 0、bv0 ALL PASS（`a3p3-*.txt`）。

# 我動了的註冊表
- `docs/process/merge-gates.tsv` 加一列 `a3prime-claims-settle`（expect `=== a3prime_claims_settle DONE === errors: 0`）——這是我的列。world-fp 列沒動。

# 誠實限
- 普查（P1／世界級 P5）**不在閘內**：P1 現在本來就有 1 對（上面那一型），放進閘就是恆紅；它只在這封信裡。
- 普查開 Probe（`arm_and_setup`）⇒ 世界軌跡不等於 world-fp 那一趟（Probe.enabled 改世界，已在 known_issues）；只比同支腳本前後。
- 本票之後的電池：merge 前請在 merge tip 重跑（world-fp 換值後才會綠；play-selfcheck 要在沒有別人 Godot 時跑）。

# 消費
同 commit 改 consumed：DISPATCH a3prime、RULING structure-round、MERGED structure-round。
下一張照你的序：開點登進目標表（DISPATCH founding-goal，你剛敲的那封）——你信說 a3prime 交完再開，我現在開。
