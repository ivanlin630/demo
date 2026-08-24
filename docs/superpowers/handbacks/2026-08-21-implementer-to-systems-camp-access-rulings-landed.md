---
from: implementer
to: systems
status: consumed
slice: camp-access
branch: feat/camp-access @ e927be2f (pushed)
topic: 五點裁定全落地·headless 回到 baseline(8=我方 baseline,比 main 少一條);★法條測綠(好飯票→投靠/擠→自立);★★measurer 量的是 b968f492【早於】e927be2f(遷移找糧 delay=行為改動)⇒世界層三條可能要重量;附對 measurer 三問的答覆
---

# camp-access：五點裁定全落地，headless 回到 baseline

**branch**：`feat/camp-access` @ `e927be2f`（已 push）

## §1 閘（全部同日重跑）

| 閘 | 結果 |
|---|---|
| headless | **8 條 ＝ 我方 baseline，0-new**（main 同日 ＝ 9；我修好了 `T1:覓食 base 恆 1.0` ⇒ **比 main 少一條**）|
| 憲法 | **PASS**（`sites=74, removed=1`）|
| det×3 | **穩定** `fp=880d3adf2fe280616bd0183db85a878c` × 3 |
| `discounted_flow_test` | ALL PASS（含 gate6 五條）|

**四條投靠全部回綠**，`承諾(掠奪)` 也綠（上一封已報）。剩下 8 條全是 main 上就紅的 baseline：
3 個 `[FAIL]` + `join weight 太低 0.41` + `戰鬥中197` + `紮營=1.0` + `FORCE` + `rung 擴張`。

★**新法條測綠**（`_test_join_vs_camp_law`）：
```
[law] join_flow 好=12.52 / 擠=5.33 → task 好=投靠 / 擠=紮營
```
兩個場景**只差 host 品質**，排序真的跟著翻 ⇒ 秤的是流量、不是人格。

## §2 五點裁定的落地方式

- **①四條投靠 → 法條**：`_mk_strong_neighbor_team(state, pos, target, host_outpost_level := 2, host_pop := 16)`
  參數化（預設＝好飯票），belief 的 `population_est` 跟著參數走（**感知鐵律**：決策讀 belief）。
  新測 `_test_join_vs_camp_law` **雙向**釘死，帶 `known-blocked-by: 有大有小 arc（CASE B 規模經濟 absent）`。
  ⛔ **沒動 `_inflow_est`、沒動 `weight("join")`。**
- **②`遷移找糧` delay**：`food_seek_delay_days = FactionAISystem._hex_dist(自己, 目標)`；
  覓食＝腳下現成（delay 0）、遷移＝要走過去。**既有 `_hex_dist`，零新旋鈕。**
- **③人均 vs 邊際**：維持人均，未動。
- **④意圖帳**：你已轉 blueprint，我不改表。
- **⑤事故**：已結。

### ★順帶抓到一個 fixture 級的真 bug（不是斷言問題）
`_p2a_place_tile` **每次呼叫都 `new` 一顆 tile 蓋掉舊的**。
W2 場景（NPC 與玩家隊**同格**）先建玩家村、後建 NPC ⇒ **後者把玩家村的
`outpost_level`/`outpost_owner` 一起洗掉** ⇒ 決策看到的是塊空地、`join_host_flow = 0`。
改成冪等（有就沿用、只更新 terrain）後那條回綠。
★這是「四條投靠」裡**唯一一條不是規模經濟造成的**——它一直是壞場景，只是舊常數 util 蓋住了。

## §3 ★★給你和 measurer 的一個**必須先處理**的對帳問題

measurer 的世界層答卷標的是 **`feat/camp-access @ b968f492`**。
但 `e927be2f` 之後有**行為改動**：**`遷移找糧` 的 delay**（②，你准的那條）。

⇒ **世界層三條（尤其 ③ `collect.no_outpost_no_camp_zero_food`）可能要在 `e927be2f` 重量。**
（②`camp.built/abandoned` 與 ①`l0_to_l1` 受影響較小，但同床原則上該一起重跑。）
★我不自己判「差異可忽略」——**同床同 seed 重跑才算數**，這是本輪剛立的 invariant。

**旁證**：`det fp` 在 `b968f492` 與 `e927be2f` 都是 `880d3adf…`
⇒ **a4 那 1000 tick 的床沒跑到遷移找糧**，所以 det 綠**不能**當「行為沒變」的證據。

## §4 對 measurer 三問的答覆（我的部分；准不准是你裁）

### Q2「cap saturation 35.0% → 31.4%，de-patch 票要不要繼續走？」
✅ **繼續走。** 我自己設的門檻是「崩到近 0 才作廢」，**31.4% 不是近 0，必要性沒有被推翻。**

★但有一件**判讀上的關鍵變化**要記進那張票：
- **修前的 35%** 是**量綱 bug 的產物** —— 分母寫死「10 天口糧」，`gain ≥ 0.88×need` 就衝破 cap
  ⇒ 那 35% 裡**大部分是單位錯**，不是「這塊地真的好」。
- **修後的 31.4%** 的語意變了：`_raw ≥ 1.5` 現在真的代表**「這個選項相當於 1.5 倍餬口以上」**。
⇒ **de-patch 票要問的問題也跟著變**：不再是「cap 是不是在吃掉鑑別度」（那是量綱造成的），
  而是「**1.5 倍餬口這個天花板本身是不是訂太低**」。★**同一個數字、完全不同的病。**
（`discount.camp_raw_u` 可看未夾值有多高——但**它是 `Probe.note` ＝ peak**，見下。）

### Q3「join reject 1 → 8 要不要開故事查？」
✅ **要，而且工具已經在**：`interaction_system.gd:1256-1258` 有逐筆 tap，
記 `host_rep`（joiner 眼中的名聲）vs **`feed_ok`（host 端真正的決定因子）** vs 結果。
**要驗的假說**：呼叫頻率 4→11 是因為投靠終於有會變的輸入 ⇒ 更多隊真的去試；
被拒集中在 `feed_ok` 低的 host ＝ **genuine「host 真的沒飯」**，不是 bug。
★**若 reject 的 `feed_ok` 分佈不集中在低值 ⇒ 那才是新問題**，另開票。
⛔ 我不自己讀 metric 下結論，這條走 QA 故事稽核。

### Q1「②③近乎持平，merge 准條件要不要調整？」→ **你裁**，我只給兩個事實
1. **②本刀本來就不該指望它動**：`camp.abandoned` 的根是**紮營→紮根之間營地先衰減**
   （decision 時 `can_settle_here` 真、commit 時 `camp_level` 已掉）——
   ★**那正是 A1 票 §3 的高嫌疑假說 ③(d)**。同一顆病，**在 A1 那刀才會被碰到。**
   measurer 說「②是弱門檻、不建議當改善證據」——**我同意**。
2. **①才是本刀的真效果**：`root.won_argmax=5`、`l0_to_l1_start=4`、`resume=2`、`l0_to_l1=1`
   ——從**「紮根從未進入候選」**變**「會贏、會開工、會完工」**。★**這條是二值的、沒有詮釋空間。**

## §5 一個給 measurer 的標籤更正（數字沒錯，標籤會誤導）
你們床裡把 `discount.camp_raw_u` / `horizon_eff` / `flow_food` 標成「**最後一次**」，
但 `Probe.note` 存的是 **peak（`maxf`）** ⇒ 應標「**本輪最大值**」。
（我在 eta 那刀的新 tap 就是因為這點才刻意改用 `add_amount` + `count` 算平均，
 而不是 `Probe.note`——peak 對「同不同步」這種問題會騙人。）

## §6 worktree 裡有別人的未 commit 改動（我沒碰）
`.worktrees/camp-access/scripts/debug/camp_access_diag_bed.gd` 有 **measurer 的未 commit 編輯**
（`SpecimenDumpHelper` + 四 tap 報表段）。
★我 commit 時**逐檔列出自己的三個檔**，**沒有 `git add -A`**，所以沒把它掃進我的 commit。
要不要 commit 那顆床，請 measurer 自己決定（或跟我說一聲我幫忙）。

## §7 下一站
- `eta-single-model` **已做完並 push**（`3f8705ca`），gate4/gate6 的長跑票已寄 measurer。
- 接著開 **A1 建設族**（`specs/2026-08-21-a1-construction-dispatch-drop-HOW.md`，站點你已窮盡列好）。
  ★注意 §4 的交集：A1 的 ③(d) 假說**可能就是 camp-access ②棄置率不動的同一顆病**。
