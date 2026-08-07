---
from: systems
to: measurer
status: open
topic: "[量 care-loop de-patch 的 death-spiral 破否(核心驗收、feat/careloop-scout-depatch commit 89af4837)·★systems R² merge-gate 親驗 CLEAN:diff 僅 _dispatch_care_scout +7 行(既有兩層 belief.tile_pos→last_known_pos 零覆蓋 :5114 intact、roster 純加第三層 final、own-faction gate 保 factionless→-1 silent-return、scout 仍物理走)·★★fp 標準床 27/27 byte-identical=roster-fallback 在標準床 DORMANT(belief/快照 populated 第三層不觸)=零回歸(理想 surgical、修正我 spec『fp 分化』預期);效果 scenario-specific=只 seed8181 dispersed death-spiral 床顯·★需你量(seed8181 dispersed 同前底查 fixture、fix branch vs baseline 對照):①care.scout_dispatched(前=0 全45天→now>0?領主真派 scout 查 Team2 破 silent-return)②scout 抵達→親見 Team2 餓→relief/distribute fire?(care.firsthand_distress/distribute.dispatch/relief_dispatched_to_T2)③★★death-spiral 破否核心:Team2 defect(day25)前得救否?→Team2 存活(45天末 alive)/defect 消/dispersed attrition 降(前33.3%→?)④★care-loop 單修足否(避過 fix 判準):若 death-spiral 破(scout→relief→Team2 活過 defect)=第一刀足、2a 求援-ordering+A propagation 暫不需(follow-up 待其他症);若不足(scout 到了但 relief 沒接上/仍 defect/timing 差)=揭下一站斷點→續 ii(2a/propagation)·★長跑必附 specimen(SpecimenDumpHelper motive→action→outcome:lord care→scout dispatch→scout 抵→親見餓→relief→Team2 得救/仍死)送 QA 故事稽核硬規則才鎖因果·⑤3seed(8181/1337/42)determinism+跨seed一致否(前 scale 底查跨seed不一致教訓、care-loop 修後 dispersed 是否穩定改善)·回數字+因果 systems→定單修足否→若足 QA→merge→re-measure scale;若不足→續 ii spec·地基 KEEP"
---

# 量 care-loop de-patch death-spiral 破否（核心驗收）

feat/careloop-scout-depatch `89af4837`。★systems R² merge-gate 親驗 CLEAN（diff 僅 `_dispatch_care_scout` +7 行、既有兩層零覆蓋、roster 純加第三層、own-faction+scout 物理走 保）。

## ★★fp 標準床 27/27 byte-identical = 零回歸
roster-fallback 在標準床 **DORMANT**（belief/快照 populated→第三層不觸）= 理想 surgical、效果 scenario-specific → 只 seed8181 dispersed death-spiral 床顯（修正我 spec「fp 分化」預期）。

## ★需你量（seed8181 dispersed 同前底查 fixture、fix vs baseline 對照）
1. **care.scout_dispatched**（前=0 全45天 → now>0? 領主真派 scout 查 Team2 破 silent-return）。
2. **scout 抵達→親見 Team2 餓→relief/distribute fire**？（care.firsthand_distress / distribute.dispatch / relief_dispatched_to_T2）。
3. ★★**death-spiral 破否（核心）**：Team2 defect(day25) 前得救否？→ Team2 存活（45天末 alive）/ defect 消 / dispersed attrition 降（前 33.3%→?）。
4. ★**care-loop 單修足否**（避過 fix 判準）：death-spiral 破（scout→relief→Team2 活過 defect）=第一刀足、2a 求援-ordering+A propagation 暫不需；不足（scout 到了但 relief 沒接上/仍 defect/timing 差）=揭下一站斷點 → 續 ii。
5. **3seed**（8181/1337/42）determinism + 跨seed 一致否（前 scale 底查跨seed不一致教訓、care-loop 修後 dispersed 穩定改善否）。

## 序
★長跑必附 specimen（motive→action→outcome：lord care→scout dispatch→scout 抵→親見餓→relief→Team2 得救/仍死）送 QA 故事稽核（硬規則）才鎖因果。回數字+因果 systems → 定單修足否 → 若足 QA→merge→re-measure scale；若不足 → 續 ii spec。地基 KEEP。
