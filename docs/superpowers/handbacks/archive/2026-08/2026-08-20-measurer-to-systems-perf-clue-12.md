---
from: measurer
to: systems
status: consumed
topic: "perf-clue-package-12"
---

# perf 線索包①②：意外結論，真兇不在原點名候選

`.measure.json` 落地：`docs/process/verdicts/perf-clue-package-12.measure.json`
raw log：`docs/measurements/2026-08-20-perfclue-profile-day5.log`+3份bisect log（見json）

## ①phase細profile：決定性但真兇跟你點名的不一樣

**outer桶（可信）**：`near.faction_ai`（含evaluate_all+info_side_dispatch_all）**獨占93.1% wall time**（191.5s/205.8s），其餘near.*全部相位加總不到7%。這是既有SimRunner `_ph`成熟機制，數字扎實。

**你點名的4個具名候選（L0階梯檢查/farm生產線/construction tick/labor rebalance）——全部<0.15% of wall，不是真兇**：
- l0_settle: 14846us (0.01%)
- farm_prodline: 85232us (0.04%)
- construction_tick: 101879us (0.05%)
- labor_rebalance: 18967us (0.01%)

★這4個確實原本都缺獨立phase marker（構造上被吃進loop3.prosperity/near.consume/near.outpost_ambush混桶）、我這輪已補temp tap驗證，但驗完發現吃時間的根本不是它們。

**真兇在near.faction_ai內部核心決策機制**：inner breakdown相對占比前四大是loop1.factions(19.0%)/loop1.assign_tasks(18.8%)/unified.rank(17.5%)/assign.leader_unified(12.8%)/gather.market(6.7%)。

**★唯一已code-read坐實的具體機制發現**：`_evaluate_all_body`的loop1（`faction_ai_system.gd:717-729`，member_snap+update_goals+assign_tasks）**完全忽略傳入的`_team_ids`參數**，每次呼叫都對`state.factions`全量掃描——意味著near-pass跟far-pass（`faction_ai` SYSTEMS entry是lod=LOD_BOTH）各付一次全量loop1成本，LOD近遠分流對loop1完全不生效。這是唯一我有信心的具體finding。

**★誠實揭露一個未解缺口**：我的fai_inner累加器（_fai_ph_cumulative）跑出來的總和696.5s，比outer near.faction_ai桶(191.5s)高3.6x，沒完全root-cause。loop1的near+far雙付只能解釋~10%膨脹（呼叫頻率比10:1），剩下的沒查出來——懷疑可能還有其他DecisionContext.gather呼叫路徑（如options.gd）沒被gate在同一次evaluate_all的zoom窗口內、疊加寫入同一static dict。inner breakdown的**相對占比**方向性參考應該還站得住，但**絕對值不可信**，需要你/implementer code-read確認機制後才能定案這塊。

## ②slice歸因bisect：意外——這規模窗內查無單一slice可歸因

同床同seed同窗(10天)、三個commit(94e2f826 pre-L0 / 3d30b3ed post-S2b / 現main b1c8917b)嚴格序列跑(非併發、避免CPU contention污染timing)。

**結果：三者在49→56-73團範圍內per-team成本幾乎重合**（day10：preL0 2415us/team、postS2b 2463us/team、mainhead 2209us/team——mainhead甚至持平或略快，不是變慢）。end_teams三者也幾乎一樣(72/72/73)。**此規模窗內沒有單一slice可歸因的顯著加價**。

**推論**：你原引用的『+34%』degradation很可能只在更高團數規模顯現（我們已知的152-242團範圍），不在這次10天/49-73團的bisect覆蓋內。附帶一個矛盾線索：既有的242團→3278us/team跟152團→4410us/team兩個高N單點，走勢方向剛好跟這次低N範圍（N越大越貴）相反——但這兩個高N點來自不同run/不同config/不同day-in-run，非同方法論控制，不能直接拼曲線，只能算confound警訊。

**若要精確鎖定『+34%』真正歸因的slice，需要在100-200團規模區間用同一bisect方法論補測**——這次budget/時間下沒做（單段10天窗都要跑約5分鐘，100-200團規模的窗會需要顯著更長，且該規模團數要嘛拉長天數要嘛換更高壓config）。

## 順手產物（非③正式交付，附帶記錄）

低N趨勢初步冪次擬合：mainhead N=56→73, us/team 1264→2209，k≈2.1（noise大，preL0/postS2b各自擬合出2.7/2.9，僅方向性參考=超線性、疑似O(N²)量級非O(N)）。

## cleanup

3個temp worktree(perf-clue-mainhead/perf-bisect-preL0/perf-bisect-postS2b)已移除；4個temp tap(faction_ai_system.gd含_fai_ph_cumulative累加器/labor_system.gd/resource_system.gd/sim_runner.gd)已revert確認乾淨；2個自建bed已刪；`--headless --import`乾淨編譯確認。

## 總結+交你裁

①②都得到決定性但意外的結論：真兇不是你原點名的4個候選、也不是任何單一slice——是near.faction_ai本身內部機制（loop1全量掃+決策排序鏈），且這個機制在49-73團規模就已經吃掉93%時間，但成本增長率（O(N²)量級疑似）意味著它會隨你們接下來的12mo大考規模繼續惡化。loop1忽略team_ids是我唯一能給你的具體file:line修復切入點（非量測員能判HOW，只給你線索）。inner breakdown絕對值3.6x對不上的部分我沒能力獨立查完，需要implementer/你code-read確認。100-200團區間的slice歸因補測是否要做、還是先接受"規模驅動非slice驅動"的結論直接往③(scaling曲線正式版)走，交你裁。

我接著照佇列插隊處理lag份額quantify（12mo大考前必完），完成後回③④⑤。
