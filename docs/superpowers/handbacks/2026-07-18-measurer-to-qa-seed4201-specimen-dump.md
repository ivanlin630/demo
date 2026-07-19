---
from: measurer
to: qa
status: consumed
topic: "[seed4201 specimen dump完·別猜結論已附讀法] 3隊深famine候選(16/19/52,famine_days31-33)顯示4-5次stall_exclude連鎖(幾乎耗盡整條SURVIVAL_OPTION_SET),最終落在紮營/返家補給(單一option豁免的fallback)——但這兩個fallback都不產糧,故仍死,非mis-fire誤排除正在起效的option(絕大多數fire發生於food_days=0.00=option確已無效)。★唯一可疑點：每隊『第一次』fire發生在food_days仍有11-24天時(famine尚未開始)——此時段trace因bed門檻(food_days<3.0才存snapshot)沒收到fire前的food_days走勢,無法100%排除這第一次fire是否偏早(premature switch away from覓食)。team93(逃跑,famine33.8,0次fire)=乾淨窮死無關本機制。team48(task=建設卡住,dispatch_would_succeed=true卻沒survival preempt,famine33.3,0次fire)=另一個無關本branch的既有缺口,附帶標記。"
---

# seed4201 3隊 regression specimen dump（讀法附上，不猜結論）

依 `2026-07-18-qa-to-measurer-seed4201-regression-specimen-request.md`。已跑 `starvation_lockpoint_trace_bed.gd`（bb1e75ff branch，seed=4201，8月），並擴充該 bed 加收 `survival_committed_option`/`survival_stall_cooldown` + 逐 tick 比對偵測 `stall_exclude` fire 事件本身（誰被排除、排除前承諾 option、fire 當下 food_days/famine_days）。

## 找候選死隊

37 隊消失，但 extinct.starve 只 3（extinct.other 另 2）。用「famine_days 在最後記錄快照仍高(>30)」篩出 5 個真死候選（其餘 32 隊多半是成功併入/整併，非死亡——與 probe 的 `merge.set_ok=117`/`accept.join_accept=3` 等吻合，正常）：

| team | 最後 task | famine_days(死前) | stall_exclude fire 次數 |
|---|---|---|---|
| 16 | 紮營 | 32.9 | 5 |
| 19 | return_home(返家補給) | 33.3 | 5 |
| 52 | return_home | 33.3 | 4 |
| 93 | 逃跑 | 33.8 | 0 |
| 48 | 建設 | 33.3 | 0（★另一個無關本branch的既有缺口，見下） |

（無法從此 trace 100% 精確對到 `extinct.starve` vs `extinct.other` 哪 3 隊哪 2 隊——沒有逐隊死因 tap，此為已知殘留缺口，若要 100% 精確需另接 `_on_team_extinct` 逐隊 tag。）

## team16/19/52：連鎖排除耗盡整條梯子，最終落 fallback 仍死

以 team16 為例（19/52 同型態）：

```
tick=5729  排除=覓食       food_days_at_fire=10.97  famine=0.0
tick=11279 排除=買糧       food_days_at_fire=0.00   famine=0.0
tick=19999 排除=掠奪       food_days_at_fire=0.00   famine=0.0
tick=23769 排除=返家補給   food_days_at_fire=0.00   famine=15.0
tick=25929 排除=遷移找糧   food_days_at_fire=0.00   famine=24.2
最終落：紮營（cooldown=[覓食,買糧,掠奪,返家補給,遷移找糧]全排除→單一option豁免ride）
```

**判讀**：後 4 次 fire 都發生在 `food_days=0.00`——option 當下確已無效，排除正確，非 mis-fire。最終落在紮營/返家補給（單一 option 豁免的 ride 設計正確 fire：不 idle-starve），**但紮營/返家補給本身不產糧**，所以仍死——這不是排除機制的錯，是**整條 SURVIVAL_OPTION_SET 對這幾隊的處境（孤立/資源枯竭區域）本來就沒有能真正救命的選項**，換格越換越像「耗盡選單後選個最不壞的等死」，較接近**窮死**而非 thrash（沒有來回震盪同一組選項，是單向耗盡）。

## ★唯一可疑點：每隊「第一次」fire

三隊第一次 fire 都發生在 food_days 仍有 **10.97 / 24.17 / 23.33 天**（famine_days=0，都還沒進 famine 狀態）就排除了「覓食」。這時段的 pre-fire food_days 走勢**我這次沒收到**——因為 snapshot 記錄本身有門檻（`food_days<3.0` 才存），fire 偵測雖不設門檻但沒有更早的逐 tick 對照組，看不出覓食那時是在緩慢惡化（合理排除）還是本來就還行（偏早排除）。**這是唯一無法排除 mis-fire 可能性的段落**，如需 100% 判定要再對這 3 隊在門檻放寬（如 food_days<15）重跑一次，或加專門追蹤這 3 個 team_id 從 spawn 開始的全程 food_days 序列。

## team93：乾淨窮死，與本機制無關

`逃跑`(flee) 到死，famine_days 33.8，**全程 0 次 stall_exclude fire**——沒有換格行為，單純沒能力跑贏/找到食物，跟 stall-detection 機制完全無關。

## ★team48：另一個缺口，非本 branch 造成（附帶標記）

`task=建設`（蓋建築，PRIO_AMBIENT=10）卡死到底，famine_days=33.3，**0 次 fire**（因為它從沒進 survival dispatch）。我的 bed 有一欄 `would_survival_dispatch_succeed`（複製 `TaskArbiter.try_set` 布林邏輯的唯讀重算）顯示 **true**——理論上 survival（PRIO_SURVIVAL=80）應該能 preempt 掉 PRIO_AMBIENT=10 的建設任務，但這隊實際卡在建設沒被搶。這是一個**跟 stall-detection/exemption 完全無關**的既有任務優先權疑點（此 branch 沒碰任務搶占邏輯），**不在本次 regression 調查範圍**，只是量測時順手看到附帶標記，供之後排查用（不確定是舊 bug 還是我唯讀重算邏輯本身有 edge case 沒對齊真實 try_set，未深查）。

## 我的判讀（供參考，非 measurer 職權定案）

較符合「**窮死**（該處境真的沒救，換格是新機制讓它們多掙扎幾輪但終究資源不夠）」而非「**mis-fire**（誤排除正在起效的選項）」——後 4/5 次 fire 都在 food_days=0.00 發生，證據明確。**唯一灰色地帶是每隊第一次 fire**（食物尚可時就排除覓食），若你/systems 判斷這值得深究，我可以再跑一輪針對性 trace（放寬門檻或鎖定這 3 個 team_id 全程記錄）。

---
measured_at_head: `bb1e75ff`（`.worktrees/desperation-ladder`）
raw_logs: `docs/measurements/2026-07-18-despladder-seed4201-lockpoint-bb1e75ff-decoded.log`（CP950→UTF-8逐行解碼版，47224行）
bed 擴充: `scripts/debug/starvation_lockpoint_trace_bed.gd` 加收 `survival_committed_option`/`survival_stall_cooldown` + fire 事件偵測（純觀測擴充，未改 production 邏輯）
