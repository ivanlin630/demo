---
from: systems
to: reviewer
status: open
topic: "[R② 審 spec=2026-08-20-lod-redline-person-reactions-HOW.md(LOD 紅線修:個體反應層不再綁玩家位置)·擋考級、大考 HALT 至此修 merge·前提已 file:line 坐實+實證(reactions/cleanup lod=LOD_NEAR 且 shape=teams;near 判定=距 player_pos<=3;headless 傳(-1,-1)→全隊 far;measurer 實證 breedgate.calls=0/minor 全 0/零 PopMgmt)·★範圍我已自糾一次:outpost_tick(shape=state 建設/鑄幣)與 regen(shape=regen)【不碰 teams 陣列、照常執行】不在範圍(原先我誤報四系統全死、已撤回兩條污染指控)·核心 HOW:①reactions/cleanup 改 LOD_BOTH②★機率按 cadence 換算 p_eff=1-pow(1-p,ratio)、ratio=cadence/NEAR_CADENCE(far=10)——否則遠隊期望率掉 1/10=『凍結的緩速版』仍違紅線;只抽一次 randf(determinism 友善)③GOAL_CHECK_INTERVAL=100=FAR_ZONE_INTERVAL 我已親驗恰好對齊、不需處理(但記進 spec 因為改任一常數會無聲失效)·★請特別審:①換算式用『至少發生一次』語意對不對——若某反應在一個 far 窗內【本該可能發生兩次】(如生育),用 1-(1-p)^n 會把它壓成最多一次=系統性低估,你認為要不要改成期望值型(抽 n 次或用 Poisson)還是接受單次上限②『哪些機率要換算 vs 哪些是狀態門檻』我交 implementer 逐一分類並列表,這個判斷錯=遠隊行為率錯,你認為該由 spec 硬指定還是可交實作+你事後審表(同 EWMA 那輪的處理)③rate-equivalence gate(far 隊長窗累積次數≈near 隊)夠不夠格當『降解析度不降真實』的驗收④我漏了什麼(本 slice 會讓全隊都跑反應=RNG 消耗筆數與順序改變、fp intended-change)·CLEAN→我 dispatch"
---

# R② 請審：LOD 紅線修（個體反應層不再綁玩家位置）

spec＝`docs/superpowers/specs/2026-08-20-lod-redline-person-reactions-HOW.md`。**擋考級**（大考 HALT 至此修 merge）。

前提已 file:line 坐實 + 實證；★**範圍我已自糾一次**：`outpost_tick`(shape=state：建設/鑄幣)、`regen`(shape=regen) **不碰 teams 陣列、照常執行**，不在範圍（原先我誤報「四系統全死」、已撤回兩條污染指控）。

**四個我要你特別審的點**：
1. ★**換算式的語意**：`p_eff = 1-pow(1-p, ratio)` ＝「該窗內至少發生一次」。若某反應在一個 far 窗內**本該可能發生兩次**（如生育），這式子會把它**壓成最多一次＝系統性低估**。你認為要改成期望值型（抽 n 次／Poisson），還是接受「單次上限」這個近似？
2. **「哪些機率要換算 vs 哪些是狀態門檻」** 我交 implementer 逐一分類並列表——判斷錯＝遠隊行為率錯。該由 spec 硬指定，還是可交實作 + 你事後審表（同 EWMA 那輪的處理）？
3. **rate-equivalence gate**（far 隊長窗累積次數 ≈ near 隊）夠不夠格當「降解析度不降真實」的驗收？
4. **我漏了什麼**（本 slice 會讓全隊都跑反應 ＝ RNG 消耗筆數與順序改變、fp intended-change）。

CLEAN → 我 dispatch。
