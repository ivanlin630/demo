---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN] manufacturing per-labor-allocation de-patch——親讀manufacturing_system.gd:67確認補丁閘精準坐實(current_task!=TASK_MANUFACTURE把已整合好的勞力池邏輯62-96整段擋在前面)，符合補丁閘優先查診斷通則教科書案例；gather對稱claim憑本session早前直接讀過collect_resources零task-gate的記憶確認；grep其餘9處TASK_MANUFACTURE引用皆優雅降級非硬依賴，vestigial follow-up拆分乾淨"
---

# R②判決：manufacturing per-labor-allocation de-patch — CLEAN

## 補丁閘診斷——親讀code確認精準
`manufacturing_system.gd:67`：`if team.current_task != TeamData.TASK_MANUFACTURE: continue`——這一行擋在:82-96(已整合勞力池的完整生產邏輯：`ensure_fresh`+`labor_share=team_pop/pool`+`worker_rate=level×labor_mult×labor_share×skill`)**之前**。任何隊只要當下`current_task`不是恰好"製造"，不管設施多滿、材料多夠、勞力池分配多少，一律`continue`跳過——這精準對應measurer實測到的「飽和度6.7%+材料消耗0.000全程」：facility蓋出來後，除非隊剛好在那個tick被決策engine選中執行"製造"這個特定task，否則永遠不會真的跑。

這是這個session反覆驗證過的診斷通則的教科書案例——[[feedback-patch-gate-first]]「補丁閘優先查」：勞力池整套機制(need-gate/demand-cap/labor_share防雙算)已經settled且正確，卡住的不是這套機制本身，是一個更早、更表層的task-based補丁閘把它整個蓋住。de-patch(移除這一行)是對的手術，不是又加一層補償邏輯。

## gather對稱——確認為真
我在本session稍早(統一勞力池HOW/merge兩輪)直接讀過`resource_system.gd`的`collect_resources`全文，那個函式**沒有任何`current_task`檢查**——只看`tile.outpost_level`跟team位置，不管隊當下在做什麼task都會跑。這次claim「manufacturing應該跟gather對稱」跟我親自讀過的既有事實一致，不是新斷言。

## 保留gate/need-gated——沿用已驗證機制
`labor_mult=fill×LABOR_SCALE`，need=0時勞力池`fill=0`→`labor_mult=0`→`worker_rate=0`→不產——這條「no floor」性質是我在統一勞力池那兩輪已經逐行驗證過的既有機制，這次de-patch沒有改動這部分，只是讓它終於能被真正觸發到。materials(`_can_consume_scaled`)/position(outpost_level>0)/軍隊排除(pool_of只PRODUCE)——這些gate在移除:67那一行後全部原封不動繼續生效，沒有被連帶拆掉。

## TASK_MANUFACTURE其餘用途——親自grep確認優雅降級非硬依賴
`grep`到9個非manufacturing_system.gd的引用檔案，核心sim檔案(`faction_ai_system.gd`/`npc_ai_system.gd`)裡的用法都是「這個task出現在某個清單裡時如何處理」(PREEMPTIBLE_TASKS/STATION_TASKS/interruptible清單/NPC目標評分)——如果隊之後很少真的把current_task設成"製造"，這些清單只是less relevant，不會造成任何錯誤或crash。你自己note裡點名「TASK_MANUFACTURE decision option可能vestigial」這個follow-up跟這個grep結果一致，拆分成獨立清理項不混進這次minimal de-patch是對的範圍控制。

## 判決
**CLEAN → dispatch隔離`feat/mfg-labor-depatch`。** 補丁閘診斷精準、de-patch是正確手術、gather對稱claim核實為真、保留gate沒被連帶破壞。dev-verify 5驗(尤其②不over-produce/④constitution site應減非增)+§8三驗(領導軸ratio真追平)照既定計畫走。
