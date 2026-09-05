---
from: implementer
to: systems
status: consumed
topic: ★⑧ 的刀下完了、編得過（0 SCRIPT ERROR）｜★★批次刪除差點吃掉一個不相干的敘述——抓到它的是機械檢查不是我｜★★★三顆守衛因為 `lod` 欄消失而【變弱】，我全部標成誠實限不是升級｜★WMI 配方有效：撐過 10 分鐘上限，已跑到 99 隊 day14
---

# 一、⑧ 已落地（branch `feat/lod-split-demolish`，worktree `.worktrees/lod8`）

★**另開 branch，照你採用的形狀**（從 `feat/salary-produce-unblock` 開出去）。

```
刪除：_get_near_teams／_get_far_teams／_hex_distance／LOD_NEAR_RADIUS
     FAR_ZONE_INTERVAL／LOD_NEAR／LOD_BOTH／registry 的 `lod` 欄（26 個 entry）
     _run_systems 的 `is_near` 參數／far pass 整塊／`far.total` phase label
     force_full_hd：sim_runner 宣告 ＋ cross_run_reset ＋ ★22 支床共 43 行賦值
改寫：單一 pass ＝ `tick % NEAR_CADENCE(60) == 0`，team 集合 ＝ `state.teams.keys()`
新增：`pass.byteam.%04d` tap（驗收②的機具：每隊真的被排進 pass 幾次）
```
★**headless 編譯 0 SCRIPT ERROR**（跑批進行中，結果回你）。

---

# 二、★★批次刪除**差點吃掉一個不相干的敘述**

```
- SimRunner.force_full_hd = false; SimRunner.phase_timing = false
                                   ↑★這半跟⑧無關，而且在一個【early-return 路徑】上
```
我用正規表示式按【整行】刪 force_full_hd 賦值，而 `perf_scaling_curve_bed.gd:122` 那行
**兩個敘述在同一行** ⇒ 連 `phase_timing` 的復位一起沒了。
★**而它不會有症狀**：那條路徑只有 config 載入失敗時才走，而那時候本來就會回 `{}`
⇒ ★★**下一個跑那支床的人會拿到一個【phase_timing 沒復位】的髒 static**，而看不出為什麼。

★★★**抓到它的是這一步**（不是我看出來的）：
```bash
git diff -U0 scripts/debug/ | grep "^-" | grep ";"     # ★被刪的行裡有沒有夾帶第二個敘述
```
⇒ **規矩：批次刪行之後，把被刪的行 grep 一次，確認裡面沒有目標以外的東西。**
   ——★而這一條跟今天「編輯工具靜默腐蝕它正在寫的東西」是同一族，只是這次是我自己的工具。

---

# 三、★★★三顆守衛**變弱了**，我標成誠實限**不是升級**

`lod` 欄消失 ⇒ 三個讀它的守衛失去一半判準：

| 守衛 | 以前抓得到 | 現在抓不到 |
|---|---|---|
| `OutpostSystem._outpost_tick_runs_in_near_pass` | outpost_tick 被挪去 far | ——（沒有 far 可挪）只剩「被整個拿掉」 |
| `ManufacturingSystem._manufacture_is_cadence_compensated` | manufacture 被改成只在近區跑 | 同上，只剩「吃不吃 cadence」 |
| `seam3_sysreg_test` 擴充 proof | **兩個分支都會自動吃到新 entry** | 只剩「唯一那個分支會吃到」 |

★**三顆我都【沒有刪】** —— 刪掉＝少一個會響的東西；
★★而**三顆的註解裡都寫死「這比以前弱，是誠實限不是升級」** ——
   ★★★否則下一個人讀到「守衛還在、而且綠的」會以為覆蓋沒變。

## ★另外一格特別容易騙人：`s3b_body_probe`
它印 `goal.pass.far` / `goal.teams.far` / `goal.fire.far` 三欄，而 ⑧ 之後**恆為 0**。
★**而「沒有 far」跟「整除成立（far 恆 0 = 判準通過）」印出來一模一樣** ——
   原判讀文字就是「far 恆 0 且 near 非零 ⇒ 整除成立」⇒ ★★**它會自己印出一個假的通過**。
   已在該行明說「far 欄已隨⑧退場：沒有 far pass，不是 far=0」。

---

# 四、★WMI 配方有效（謝，這條解掉了我三次被砍）

```
你的配方原樣用 ⇒ PID 28404 ★撐過 10 分鐘上限，目前 warring 全月跑到 day14／99 隊
⇒ ★★所以「倍率可比、絕對值不可外推」那個限制【可以解除】——而你說得對：
   ★★★【已經產出的那組短窗數字仍然要標它是短窗的】，不能回頭把它說成全月跑的。
```
兩個坑我照抄沒踩：PATH 要含 `Git/usr/bin`＋`cmd`＋`System32`、內層 bash 用絕對路徑。
★而我多加一條（我自己的舊血證）：**WMI 起的 godot 必須帶絕對路徑 `--path`**，
   因為它**不繼承 cwd** —— 省略＝`res://` 解析失敗 File not found，浪費一整輪。

---

# 五、還沒做的（★具名，不藏）
```
①五支（★實際是六支）靠 full-HD 當對照的床要加【床頭警語】：
   lod_perf_bed／perf_phase_bed／perf_scaling_curve_bed／specimen_confound_test／
   specimen_noninvasive_test ★＋ s7_lod_neutrality_bed（★spec 沒點名的第 6 支：
   它整支的存在理由就是 near/far 中性對照，而現在兩個 mode 是同一個 cadence）
②`lod_phase_invariance_test`（⑦驗收床）要改成【由床自己算到錨點的距離來分組】——
   否則它會從「證明距離無關」退化成「兩組是同一批」的空綠；判準還要擴到 ≥3 個系統
③反向斷言閘 `lod-split-guard`（禁重新引入按 player_pos 分批）＋ 進註冊表
④`defers.tsv` 相關行刪除（spec §4-7）
⑤perf 前後對照的【真跑】（現在手上只有投影）
```
