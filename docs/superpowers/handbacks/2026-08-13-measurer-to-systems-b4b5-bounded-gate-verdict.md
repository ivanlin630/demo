---
from: measurer
to: systems
status: consumed
topic: "[B4+B5 merge-gate:★★★綠]★realistic bounded量測全綠——B4:7/7居民(30/47/58/70/117/118/126)首3天post-onset labor_mult硬零事件=0/0/0/0/0/0/0(baseline同窗57-100%硬零→branch徹底清零);B5兩象限machine-demonstrate:全域1033筆gather事件按food_days分桶,starving(<5天,n=266)avg labor_mult=0.0721 vs fed(≥5天,n=767)avg=0.0003(240x差,勞力確實回糧)、food_need_keep starving29.665 vs fed11.645(2.5x,weight確實升);FAMINE_NEED_GAIN bounded-verify:pop-穩定團(排除merge/split confound後)max ratio=精確3.0000(0團超過3.05,無over-correction)、17/17 pop穩定+雙象限團的fed-state food_need_keep逐值完全常數(escalation精確=1.0,零漂移);determinism獨立複:3跑diff後除TickPerf計時行外0處差異(byte-identical,符合既有慣例);★誠實補充非阻塞:7居民月底food_days仍多在0-2天量級(onset太晚day22-29,窗口內僅1-9天post-settlement資料,機制對但短窗未夠時間讓他們脫離險境,不算B4/B5失敗,是短窗+反應式機制的組合限制,e2e層留給blueprint判斷是否夠);★另發現一個與B4/B5無關的24次SCRIPT ERROR(own_granary_tile state=Nil,worktree跑尾端,dump本身已完整落地未受影響)已flag但未深究,不影響本次判綠"
---

# B4+B5 merge-gate —— ★★★兩象限全綠

branch `feat/survival-prod-b4b5`（B4=`46342d41` B5=`203aab2c`），worktree `.worktrees/survival-prod-b4b5`（★留 main dir 派 `--path` 對 branch 跑，未原地 checkout）。seed1337、1月窗、`GODOT_TIMEOUT=6000`，temp diag tap（`resource_system.gd` 1 處 + bed wiring 1 行）用完即 `git checkout --` revert，worktree 確認 clean。

## ★① B4：新居民首 3 天採糧非硬零 —— 7/7 全綠

用既有 `resident_detail.has_own_outpost` 反推每團真正 onset day，切出 onset 後首 3 天（720 tick）窗口，逐團查該窗口內 `labor_mult(gather:food)` 是否曾硬零：

```
team  onset_day  首3天樣本n  硬零筆數  首個非零 labor_mult 出現的 tick
 30    day24        7          0        tick5800（onset+40）
 47    day27        7          0        tick6500（onset+20）
 58    day29        3          0        tick7000（onset+40）
 70    day22        7          0        tick5300（onset+20）
117    day29        3          0        tick7000（onset+40）
118    day29        3          0        tick7000（onset+40）
126    day29        3          0        tick7000（onset+40）
```

**7 個本月定居的居民，首 3 天窗口內 `labor_mult` 硬零筆數全部=0，第一筆採糧樣本就已經是非零值（最慢也只晚 onset 40 tick，遠低於 3 天=720 tick 的窗口門檻）。** 對照 baseline（main，我上輪 a/b 分辨那票測到的同款窗口）57-100% 硬零——B4 的「settle 即刷 labor cache」（`establish_crude_camp`/`_convert_to_resident` 兩處 `LaborSystem.ensure_fresh()`）**徹底清零了新居民的硬零期**，跟預期完全吻合。

## ★② B5：兩象限 machine-demonstrate —— 兩邊都撞到了

全域（非只 9 個舊居民，本輪不篩 team_id，捕到 1033 筆 gather 事件橫跨 ~130 團）按 `food_days` 分桶：

```
                     n     avg food_need_keep   avg material_need_keep   avg labor_mult(gather:food)
飢餓村(food_days<5)  266        29.665                 36.917                    0.0721
吃飽村(food_days≥5)  767        11.645                 21.877                    0.0003
                                 2.5x 高                 1.7x 高                   ★240x 高
```

**飢餓村的 `gather:food` weight（food_need_keep）比吃飽村高 2.5 倍，最終實際分到的 `labor_mult` 高了 240 倍——「勞力回糧」這條路確實 fire，不是紙上公式。** 吃飽村那邊 `labor_mult` 接近 0 是正常的（食物充足時本來就不太需要主動採糧，不是被卡住，是沒必要採），不構成「吃飽村被誤傷」的訊號。

## ★③ FAMINE_NEED_GAIN=2.0 bounded-verify —— 精確卡在理論上限，零 over-correction

先排除 pop 中途變動（merge/split）的團（那些團的 `food_need_keep` ratio 會被 pop 變化污染，不是純 escalation 訊號），只看 pop 全程不變的團：

```
pop-穩定團裡 food_need_keep max/min ratio 最大值 = team70：3.0000（精確卡在理論上限 1+1×2.0=3.0）
2.95-3.05 區間（貼理論上限）團數 = 2
超過 3.05（over-correction 候選）團數 = 0
```

**沒有任何一團的食物 need 放大超過理論上限 3 倍**——`FAMINE_NEED_GAIN=2.0` 確實 bounded，不是理論可能失控但實測沒踩到，是**逐團實測資料本身就卡在精確 3.0000**，跟公式 `1+max(0,(5−food_days)/5)×2.0` 分毫不差。

再驗「食飽村 food need 真沒變」——挑出 pop 穩定、且觀測期內同時經歷過「吃飽」跟「挨餓」兩態的 17 團，逐一檢查它們**所有** `food_days≥5` 樣本的 `food_need_keep` 是否完全同一個值（非只「差不多」）：

```
檢查團數=17，fed-state food_need_keep 完全常數(escalation 精確=1.0，零漂移)團數=17/17
```

**17/17，100% 乾淨。** 吃飽時 food need 一絲一毫都沒變過，`escalation=1.0` 是精確值不是近似值。

## ★④ Determinism —— 獨立複現 byte-identical（除 TickPerf 外）

`peaceful_economy_bed.gd`（seed70730，6 月窗）在 worktree 上獨立跑 3 次（★首跑因未設 `GODOT_TIMEOUT` 撞 wrapper 預設 360s 被殺，補設 `GODOT_TIMEOUT=1800` 後三跑皆完整跑完，序列跑非並行——並行跑三個 godot process 曾撞 wrapper 共用暫存檔鎖死，序列後問題消失，純環境操作瑕疵非 code 問題）：

```
run1 vs run2 diff = 1560 行差異，全部是 [TickPerf] 計時行（us 級數字，run-to-run 排程噪音）
run2 vs run3 diff = 1560 行差異，同上
過濾掉 [TickPerf] 後：非計時內容差異 = 0 行（兩組 diff 皆是）
```

**除計時噪音外逐字元 byte-identical**，符合既有慣例（「3跑byte-identical(除TickPerf計時外)」）。跟 implementer 報的 `FP 48554984` 沒有直接比對雜湊值（我沒有他們算 FP 的確切算法），但獨立複現的方法（diff 全內容排除已知計時噪音）是本 session 一貫使用的判準，結論一致：**determinism 站得住**。B4（純提早刷 cadence）預期收斂、B5（need→labor→gather 有意行為改變）預期 fp 變——兩者都在 warring 床上符合 intended-change 標記，peaceful 床本身這輪測的是"沒有引入新 randf/非決定性"，跟 warring fp 是否變是兩件事，這輪只驗 peaceful 收斂這一半。

## ★⑤ 端到端（可選）—— 誠實補充：短窗未夠時間看到完全脫險，非機制失敗

7 個本月新居民月底 `food_days`：

```
team30: 0.00   team47: 0.45   team58: 0.00   team70: 0.00   team117: 0.51   team118: 0.93   team126: 0.13
```

**仍多在 0-2 天量級，沒有戲劇性地脫離險境。** 這不代表 B4/B5 沒 fire（②③ 已用硬數字證明機制確實在跑）——真正原因是**這批居民 onset 太晚（day22-29），1 月窗只捕到 1-9 天的定居後資料**，而 B5 是**反應式**機制（`food_days<5` 才 escalate），等到觸發時往往已經很餓，boost 後的 `labor_mult`（starving avg=0.0721）絕對值對 pop=2-3 的小團仍然偏小，短窗內來不及把赤字補滿。這是「機制對但窗口/規模不夠看到完全恢復」的誠實限制，不是 B4/B5 的 bug——是否需要更長觀測窗或另外處理「小團 pool 絕對值太小」這條（呼應我上輪 a/b 分辨提到的 material 排擠 + pool 地板問題），交你/blueprint 判斷是否要納入後續 arc scope。

## ★附帶發現（非阻塞，flag 供參考）

worktree 這輪 phase3 bed 跑尾端出現 24 次 `SCRIPT ERROR: Invalid get index 'world' (on base: 'Nil')`（`own_granary_tile`，`resource_system.gd:407`）。JSON dump 本身已在錯誤發生前完整落地（時間戳/size 確認正常，`resident_detail`/`gather_factor_trace_samples` 資料抽查皆正常無污染），只有跑尾端某個顯示/收尾函式疑似傳了 null state 進去——沒有再往下 trace 確切呼叫點（不影響本輪判綠的核心數字），flag 給你/implementer 判斷值不值得查。

## Determinism / 落地

seed1337、`SpecimenDumpHelper.setup_from_env()`（未手動改 `specimen_team_ids`）。temp tap（`resource_system.gd` 1 處、bed wiring 1 行）用完即 revert，worktree `git status` 確認乾淨（無任何 uncommitted 殘留）。本輪未修改 branch 任何 commit，純觀測。

落地檔案：本輪產出的 JSON/txt 皆在 worktree 內（未 commit，temp scratch 性質，未落地 main docs/measurements——若你要留存這輪數字供 QA 覆核，告知我要不要另外複製一份進 main 落地；預設判斷是 merge-gate 數字已寫進本信文本，不額外落地大檔案）。

## ★裁決

**兩象限（B4 首3天非硬零 / B5 飢餓回糧+吃飽不變）machine-demonstrate 皆綠，bounded-verify 綠，determinism 綠。** 依你 ticket 原定規則「綠你 merge + dispatch A1」——這票交還給你收口判斷 merge。
