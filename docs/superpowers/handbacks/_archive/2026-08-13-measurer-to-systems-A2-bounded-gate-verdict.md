---
from: measurer
to: systems
status: consumed
topic: "[A2 merge-gate:★★★紅——候選拓寬確實work但funnel下游全滅,佔據率移動是別的路徑confound非A2機制]branch feat/survival-access-a2(628b9894)對baseline main同輪測(seed1337,1月窗,GODOT_TIMEOUT=6000):①佔據率baseline3.74%(4/107)→branch6.86%(7/102)表面看似升,但★決定性反證:settle-into-existing的實際轉換數(a2.convert_via_subteam_arrival+a2.convert_via_pair_interaction)branch跟baseline皆=0——這次佔據率變動100%來自founding路(worldgen.build_outpost baseline8→branch12),A2完全沒碰這條路,8→12的差很可能是invite路diplomacy擲骰改變下游randf序列的RNG-cascade confound(ticket自己標記的intended-change fp變),不是A2機制的因果效應;②invite真fire funnel:候選拓寬確實massively work(a2.invite_candidate_pass_filter baseline0→branch1477、a2.invite_accept baseline0→branch41)但下游災難性坍塌——a2.invite_task_settle_set只1/41(97.6%卡在TaskArbiter.try_set),而且連那唯一1筆task_settle_set最終也convert=0(卡在interaction_system.gd的TASK_SETTLE到站判定要求『co-located pair』、solo抵達空outpost者永遠沒有配對對象——這是我上一輪A2診斷票就抓到、這branch完全沒碰的同一個結構缺口);③候選過濾器本身有code-read坐實的新瓶頸候選機制:task_arbiter.gd:64-70『persist.hold』門檻(PRIO_DISPATCH=50<PRIO_THREAT=70、target若在PROGRESSIVE_HOLD_TASKS且persist_strength夠高會擋invite_settle)——這輪沒直接tap驗證但是file:line吻合40/41失敗量級的最可能候選,建議下一輪直接tap驗證;④bounded churn未見明顯失控(settle_inflight_nonsubteam全月僅短暫=1旋即歸0,resident_n成長溫和跟founding路一致無爆量);determinism獨立複3跑byte-identical(除TickPerf外)。★誠實結論:A2的『拓寬候選』這半做對了(0→1477→41真的動了)、但『讓candidate真正變成resident』這半完全沒做到(41→0),ticket原定的『佔據率真升』arc-goal本輪證據不支持是A2的因果貢獻——照報非預設綠"
---

# A2 merge-gate —— ★★★紅：候選拓寬 work，但 funnel 下游全滅

branch `feat/survival-access-a2`（`628b9894`），worktree `.worktrees/survival-access-a2`（★留 main dir 派 `--path`，未原地 checkout）。同一輪、同批 temp tap（沿用 A2 診斷票已驗證過的 11 個 `a2.*` key 精簡版 + `worldgen.build_outpost`）**同時測 branch 跟 baseline**（main），seed1337、1月窗、`GODOT_TIMEOUT=6000`。temp tap 用完即 revert，worktree 與 main dir `git status` 皆確認乾淨。

## ★① 佔據率：表面升，但決定性反證顯示跟 A2 無因果關係

```
                     baseline(main)   branch(A2)
resident_n / teams       4/107          7/102
佔據率                   3.74%          6.86%
```

單看這兩個數字像是升了。**但下面這組數字直接反證「這不是 A2 機制的功勞」：**

```
a2.convert_via_subteam_arrival   baseline=0   branch=0
a2.convert_via_pair_interaction  baseline=0   branch=0
worldgen.build_outpost           baseline=8   branch=12
```

**settle-into-existing 這條 funnel（A2 真正動刀的地方）的「實際轉成 resident」計數，branch 跟 baseline 都精確等於 0。** 這次佔據率從 3.74%→6.86% 的移動，**100% 來自 founding 路**（`worldgen.build_outpost`，跟 A2 的 diff 完全無關，A1 那輪就已經確認這是獨立路徑）——8→12 這個差最可能的解釋是 invite 路新增的診斷擲骰（`DiplomaticAiSystem.handle_diplomacy_message` 內部有 randf）改變了下游 randf 序列，是 ticket 自己也承認的「intended-change fp 變」造成的 **RNG-cascade confound**，不是 A2 讓更多團真的透過 settle-into-existing 定居下來。**佔據率數字動了，但動因跟 A2 想解決的問題無關。**

## ★② invite 真 fire funnel：候選拓寬確實 work，但下游全滅

```
                                 baseline   branch
a2.invite_call                     250       250
a2.invite_candidate_pass_filter      0      1477   ★★★候選拓寬確實massively work
a2.invite_range_pass                 0       115
a2.invite_accept                     0        41   ★候選也真的有41個接受邀請
a2.invite_task_settle_set            0         1   ★★★97.6%(40/41)卡在這一步
a2.convert_via_subteam_arrival       0         0
a2.convert_via_pair_interaction      0         0   ★★★唯一那1筆也沒轉成resident
```

**上半段（候選發現→接受）是真的有效**：`流亡` tag 過窄的問題（我上一輪 A2 診斷票的核心發現）確實被這個 filter 改動解決了——候選從 0 暴增到 1477，41 個真的接受了邀請。**但下半段（accept→實際變 resident）幾乎完全崩潰**：
- **41 個接受裡只有 1 個真正被 `TaskArbiter.try_set()` 設上 `TASK_SETTLE`**（97.6% 卡住）。
- **連那唯一 1 個被設上的，最終也是 0 轉換**——查 `settle_inflight_nonsubteam` 逐日曲線，那 1 筆在 day16-19 短暫出現、day22 就消失了（沒有對應的 `resident_n` 增量），代表它卡在 `TASK_SETTLE` 狀態一陣子後又脫離了，從未真正定居。

## ★③ 為什麼 40/41 卡在 try_set？—— code-read 坐實候選機制（這輪未直接量測驗證）

讀 `task_arbiter.gd:64-70`：

```gdscript
if new_task != team.current_task \
        and team.current_task in PROGRESSIVE_HOLD_TASKS \
        and priority < PRIO_THREAT and team.task_priority < PRIO_THREAT \
        and priority != PRIO_PLAYER \
        and team.persist_strength > PERSIST_HOLD_THRESHOLD:
    return false   # persist.hold 門檻
```

`invite_settle` 呼叫 `try_set` 用的 priority 是 `PRIO_DISPATCH=50`，而 `PRIO_THREAT=70`——**`priority < PRIO_THREAT` 這個條件恆真**。如果候選團當下的 `current_task` 落在 `PROGRESSIVE_HOLD_TASKS`（committed progressive 動作）且 `persist_strength` 夠高，`try_set` 會直接拒絕。這跟觀測到的「41 accept 但只有 1 個 task_settle_set」量級高度吻合——**這是最可能的候選機制，但這輪我沒有直接加 tap 驗證（沒有 measure `persist.hold` 這個既有 tap 是否真的在這 40 次失敗裡命中）**，是 code-read 坐實的合理假設，不是這輪測到的鐵證，誠實標注給你判斷值不值得再開一輪直接驗證。

## ★④ 為什麼那唯一 1 個 task_settle_set 也沒轉成 resident？—— 我上一輪已經找到的同一個結構缺口

追 `_convert_to_resident` 的兩個呼叫點：
- `faction_ai_system.gd` 的 subteam 抵達分支（"獨自抵達即轉居民"，dispatch 路專用）——invite 路的候選不是 subteam，走不到這條。
- `interaction_system.gd` 的 pair-interaction 分支——**要求兩個同 faction 團同時站在同一格才會觸發**，但受邀團被邀去的正是「空 outpost」（`_evaluate_outpost_residency` 的 gate 明確要求 `not _has_resident_team_on_tile`），意味著它抵達時大概率是**獨自一人**，沒有配對對象。

**這是我上一輪 A2 診斷票（settle-funnel-verdict）就已經指出的同一個結構缺口——這個 A2 branch 完全沒有觸碰這一段（`git diff` 只改了 `_try_invite_nearby_exile` 的 filter 條件，`interaction_system.gd` 一行都沒動）。** 候選拓寬得再寬，只要抵達判定還是「需要配對」，invite 路徑就永遠不會真正產出 resident。

## ★⑤ bounded churn：目前看沒有明顯失控（但樣本量太小，只有1次真正accept進settle狀態）

```
settle_inflight_nonsubteam 逐日：day1-15恆0 → day16-19短暫=1 → day22起恆0
resident_n 逐日：跟worldgen.build_outpost節奏一致，溫和成長(0→7)，無爆量訊號
```

沒有觀察到「反覆 invite-abandon thrash」或「resident 暴增」——但這輪唯一進入 `TASK_SETTLE` 狀態的樣本只有 1 個，樣本量太小，這題本質上答不了「bounded 是否成立」，只能誠實回報「這輪沒看到失控訊號，但也沒有機會真正壓力測試（因為下游 40/41 提前陣亡，根本沒有大量團同時卡在 in-flight 狀態去驗證 churn）」。

## ★⑥ Determinism —— 獨立複現 byte-identical（除 TickPerf 外）

`peaceful_economy_bed.gd`（seed70730，6月窗）在 worktree 上序列跑 3 次：

```
run1 vs run2 / run2 vs run3：過濾 [TickPerf] 後 diff = 0 行
```

**乾淨 byte-identical**，跟 implementer 報的 determinism 站得住（沒有比對 `678b3ee3` 這個確切 fp 雜湊，方法同 A1/B4B5 那幾輪——diff 全內容排除已知計時噪音）。

## Determinism / 落地

seed1337、`SpecimenDumpHelper.setup_from_env()`（未手動改 `specimen_team_ids`）。temp tap（worktree/main dir 各一份，`faction_ai_system.gd` 2 處 + `interaction_system.gd` 1 處 + bed 內 new_keys 擴充）用完即 revert，worktree 與 main dir `git status` 皆確認乾淨。

## ★裁決

**★★★紅。** ticket 原定規則「若佔據率仍不顯著升=A2也沒中真lever→照報非預設綠」——這輪佔據率數字雖然移動了，但拆解後**跟 A2 機制無因果關係**（settle-into-existing 實際轉換數 branch/baseline 皆=0，動因是 founding 路的 RNG-cascade confound）。**A2 做對了一半**（候選拓寬 0→1477→41 真實有效，解決了我上一輪找到的「流亡 tag 過窄」問題）**但另一半（accept→真正變 resident）完全沒解決**——40/41 卡在 `try_set`（`persist.hold` 是最可能的候選機制，未直接驗證）、唯一 1 個過關的也卡在「solo 抵達無配對對象轉不了 resident」這個我上輪已指出、這個 branch 沒碰的結構缺口。這票交還給你判斷——是打回 implementer 補這兩段（try_set 優先級 or persist-hold 豁免、以及 solo-arrival 的獨立轉換路徑），還是先收候選拓寬這半當 correctness groundwork（同 A1 的模式）、下一輪專打轉換段，交你裁。
