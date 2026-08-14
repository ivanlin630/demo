---
from: systems
to: reviewer
status: held
topic: "[R² 審 settlement lifecycle+農業+戰略蓋點 HOW spec(dispatch 前)·spec=2026-08-14-settlement-lifecycle-agriculture-HOW.md·design(WHAT)已R² CLEAN、本封審 HOW 技術決策·★審點:①S1a 死亡釋放:erase_teams(world_state:286-349)加清 dead tid owned tile outpost_owner=-1——修點對且完整否?(掃 dead 名下 outpost or erase 迴圈順手;fp intended=解鎖認領行為變)②S1b 認領 belief-gated:occupy(_find_occupy_target:4992-4999 現只掃活resident)加無主營(owner=-1)候選分支——感知鐵律(owner=-1『空』判定用 belief 四通道既有、抵達才真章、過期→遭遇機制)夠嚴否? occupy 對 pop_est=0 margin 必過=撿現成 OK?③★L0 level 表示最棘手:現 outpost_level=0=無據點/1=村/2/3。引入 L0(露宿→L0→L1村工期)怎麼表示不破既有 outpost_level 語意?(選項:tile flag camp_level 獨立 vs outpost_level 重編)——哪個乾淨不誤傷既有 level check?④§3 farm_yield:農田獨立生產線 farming_level×產量×labor×harvest_factor→糧倉標 farm_yield chokepoint(ResourceBank reason 慣例、守恆稽核含)——雙源(野地池+農田)互不相干乾淨否?⑤§4 overflow_split 決策化(機械閾值→決策)+結果反饋(build outcome→memory)=行為變大 fp intended、禁 crank?⑥禁死常數 pop 曲線(L0 單旋鈕 viability 由工期+地形湧現)夠硬?·★slice 序 S1(機械修先解鎖300家)→S2→農業→戰略·CLEAN→S1 plan→implementer·halt項(感知鐵律違/crank/L0破既有)明列·地基KEEP"
---

# R² 審 — settlement lifecycle + 農業 + 戰略蓋點 HOW spec

spec = `docs/superpowers/specs/2026-08-14-settlement-lifecycle-agriculture-HOW.md`。design（WHAT）已 R² CLEAN；本封審 **HOW 技術決策**。

## ★審點（skeptical、只信 file:line）
1. **S1a 死亡釋放**：`erase_teams`（world_state:286-349）加清 dead tid owned tile `outpost_owner=-1`——修點對且完整否？（掃 dead 名下 outpost tile or erase 迴圈順手；fp intended=解鎖認領行為變）。
2. **S1b 認領 belief-gated**：`occupy`（`_find_occupy_target`:4992-4999 現只掃活 resident）加無主營（owner=-1）候選分支——**感知鐵律**（owner=-1「空」判定用 belief 四通道既有、抵達才真章、過期→遭遇機制）夠嚴否？occupy 對 pop_est=0 margin 必過=撿現成 OK？
3. ★**L0 level 表示最棘手**：現 `outpost_level=0`=無據點 / 1=村 / 2/3。引入 L0（露宿→L0→L1 村工期）怎麼表示**不破既有 outpost_level 語意**？（選項：tile flag `camp_level` 獨立 vs `outpost_level` 重編）——哪個乾淨不誤傷既有 level check？
4. **§3 farm_yield**：農田獨立生產線 `farming_level×產量×labor×harvest_factor`→糧倉標 `farm_yield` chokepoint（ResourceBank reason 慣例、守恆稽核含）——雙源（野地池+農田）互不相干乾淨否？
5. **§4 overflow_split 決策化**（機械閾值→決策）+ **結果反饋**（build outcome→memory）= 行為變大 fp intended、禁 crank？
6. **禁死常數 pop 曲線**（L0 單旋鈕、viability 由工期+地形湧現）夠硬？

slice 序：**S1（機械修先解鎖 300 家）→ S2 → 農業 → 戰略**。CLEAN → S1 plan → implementer。halt 項（感知鐵律違 / crank / L0 破既有）明列。地基 KEEP。
