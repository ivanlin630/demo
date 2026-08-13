---
from: measurer
to: systems
status: consumed
topic: "[try_set共根CLOSE]★★★不是latch bug——99.1%(1142/1152)真兇=priority_lower(genuine正確優先權仲裁,非equal-priority-fallthrough這個ticket原假設的第③條),equal_priority_source_gated僅9/1152(0.78%),persist.hold僅1/1152(0.09%);逐筆context dump鎖定被擋團的『現任task』全部是覓食(80)/逃跑(80)/迎戰(70)/外交(70)這些genuine高優先survival/threat任務,無一筆是低價值task被機械鎖住——判定=genuine非patch,禁priority-crank(調高invite_settle/build優先級會讓settle/建設反過來打斷真正在逃命/迎敵的團,方向錯);唯一真結構缺口是equal_priority_source_gated這9筆(候選當下task_priority剛好也是PRIO_DISPATCH=50但task_reason非engine-source,ENGINE_SOURCES白名單設計排除invite_settle這類非unified/solo來源)——量級小(0.78%)不是A2/A3完成率低的主因;真正解釋『A2 40/41卡+A3 12/15 noop』的是這個世界population本身普遍處於PRIO_SURVIVAL(80)/PRIO_THREAT(70)級的求生/威脅狀態,settle/建設這類PRIO_DISPATCH(50)級ambient決策structurally很難搶到執行機會——這是world-state事實非arbiter bug,呼應本session稍早已多次坐實的『世界瀕餓/威脅密度高』大背景"
---

# try_set 共根 diagnostic CLOSE —— 不是 latch bug，是 genuine 優先權仲裁

seed1337、1月窗，在 `feat/survival-access-a2` worktree 跑（已含 A2 拓寬候選，讓 `invite_settle` 有足夠 try_set 樣本可測；`task_arbiter.gd`/`建設`option 邏輯這個 branch 完全沒碰，跟 main 行為一致）。5 個 temp Probe tap（`task_arbiter.gd` 逐 return-false 分支，僅追 `_source in ["invite_settle", ("unified"+TASK_BUILD)]`）+ 1 個 context-dump sample。用完即 revert，worktree/main dir 皆確認乾淨。

## ★逐 return-false 路徑歸因（本月累計，1152 次被擋）

```
tryset.blocked_combat_lock                        =    0
tryset.blocked_crisis_immune                      =    0
tryset.blocked_persist_hold                       =    1   (0.09%)
tryset.blocked_final_equal_priority_source_gated  =    9   (0.78%)
tryset.blocked_final_priority_lower               = 1142   ★★★ 99.1%
tryset.blocked_final_unknown                      =    0
```

**ticket 原本猜的「equal-priority fall-through」（第③條，`_source 疑不在 ENGINE_SOURCES`）不是主兇——只佔 0.78%。真正的壓倒性主因是最平凡的 `priority_lower`：候選當下的現任 task 優先權，就是單純比 `invite_settle`/`建設` 的 `PRIO_DISPATCH=50` 高，輸的乾淨俐落。**

## ★逐筆 context dump：被擋團的現任 task 全部是 genuine 高優先任務

```
104 建設(unified,pri50) 被 迎戰(pri70) 擋      → genuine：正在打仗，不該被建設命令打斷
 84 建設(unified,pri50) 被 覓食(pri80,SURVIVAL)擋 → genuine：正在為求生覓食，不該被建設打斷
  4 建設(unified,pri50) 被 逃跑(pri80,SURVIVAL)擋 → genuine：正在逃命，不該被建設打斷
  3 安頓(invite_settle,pri50) 被 覓食(pri80)擋   → genuine：受邀團自己在求生，優先活下去
  1 安頓(invite_settle,pri50) 被 外交(pri70)擋   → genuine：正在外交交涉
  1 安頓(invite_settle,pri50) 被 逃跑(pri80)擋   → genuine：正在逃命
  1 安頓(invite_settle,pri50) 被 建設(persist_hold)擋 → genuine：自己已經在蓋東西，不該被拉去別處安頓（persist.hold 設計正確命中）
  2 安頓(invite_settle,pri50) 被 徵收(pri50,equal_priority_source_gated)擋 → ★唯一結構性懸案，見下
```

**逐一核對：除了最後 2 筆，其餘 200 個抽樣裡沒有任何一筆是「候選當下手上做的事價值明顯比 settle/建設低卻硬是攔住」的情況。** 被擋的候選團全部是正在覓食、逃跑、迎戰、外交、或已經在蓋東西——這些**都是 `PROGRESSIVE_HOLD_TASKS`/危機軸本來就該保護的合法優先權**，不是機械 latch 誤傷。

## ★genuine-vs-patch 判定：genuine，禁 priority-crank

**判定：這不是 patch-gate over-block，是 arbiter 按設計正確運作。** 如果把 `invite_settle`/`建設` 的優先權調高到能贏過覓食/逃跑/迎戰（priority-crank，ticket 明令禁止），效果會是：**讓「邀請定居」跟「隨手蓋建築」這種 ambient 級決策，可以打斷正在求生逃命或打仗的團**——這是方向性錯誤，會製造出更荒謬的行為（餓到快死的團被硬拉去蓋房子），不是修 bug 是製造新 bug。

**唯一真正的結構性懸案是那 9 筆（0.78%）`equal_priority_source_gated`**：候選當下的現任 task 優先權剛好也是 `PRIO_DISPATCH=50`（範例：徵收/levy），但因為 `ENGINE_SOURCES=["unified","solo"]` 白名單只認「引擎自己派的同層 task」才能互換，`invite_settle`（faction_ai_system 直接呼叫，非走 unified/solo 決策迴圈）不在白名單內，即使兩邊優先權相同也無法互換。**這是一個真實但量級極小（9/1152）的結構縫隙**，不足以解釋 40/41 或 12/15 這種高比例卡住——那些主要是 genuine 高優先權任務贏的。

## ★真正解釋「A2 40/41 卡 / A3 12/15 noop」的是什麼

**是這個世界的 population 本身長期處於高比例的求生/威脅狀態**——`覓食`(PRIO_SURVIVAL=80)/`逃跑`(80)/`迎戰`(70)/`外交`(70) 佔了 99% 的攔截原因，這批候選團當下大多在為活下去掙扎或打仗，不是空閒游手好閒。`settle`/`建設` 是 `PRIO_DISPATCH=50` 的 ambient 級決策，在一個瀕餓/威脅密度高的世界裡，structurally 很難搶到候選團的執行檔期——**這不是 arbiter 的 bug，是這個世界當下真實狀態的忠實反映**，跟本 session 稍早多輪（gather-yield-why/a/b分辨/settlement-panel 等）已經坐實的「世界普遍瀕餓/威脅密度高」大背景完全吻合、互相印證。

## Determinism / 落地

seed1337、`SpecimenDumpHelper.setup_from_env()`（未手動改 `specimen_team_ids`）。5 個 temp Probe tap（`task_arbiter.gd` 3 處 + bed wiring）用完即 revert，worktree（`.worktrees/survival-access-a2`）與 main dir `git status` 皆確認乾淨，未動任何 branch commit。這輪只在 worktree 跑一次（沒有 branch-vs-baseline 對照需求，`task_arbiter.gd` 本身這個 branch 未觸碰，行為代表 main 現況）。

落地檔案：worktree 內產出（未 commit，diagnostic 性質；main dir 未落地新檔案，本信文本已含逐 return-false path 完整分布數字）。

## ★裁決

**真兇 = genuine 優先權仲裁（99.1%），不是 latch/patch bug。** 唯一小結構縫隙（equal-priority source-gate，0.78%）量級太小不解釋主要現象。建議不要在 arbiter 這層動刀（無論是放寬 gate 還是 priority-crank 都是錯方向）——如果 blueprint 真的希望「安頓/建設」在這種高壓世界裡更常成功，那是 WHAT 層級的問題（要不要讓世界沒那麼求生密集、或另開一個不跟 survival/threat 搶跑道的執行機制），不是 HOW 層級的 arbiter 修正。交你判斷怎麼帶回給 blueprint。
