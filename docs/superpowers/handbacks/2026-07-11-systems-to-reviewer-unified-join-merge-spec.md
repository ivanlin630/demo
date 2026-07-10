---
from: systems
to: reviewer
status: consumed
topic: [R② 框內] S-A 統一「併入」spec 更新——join+整併合一+分流+忠誠init;審設計健全
---

# 對抗② 框內審：S-A 統一「併入」設計更新

spec `specs/2026-07-10-consolidation-s-a-technical.md §HOW-6`（用戶定案，取代 join/整併兩 option 框）。**R① 免**（前提全 file:line 坐實，無未驗斷言）；**R② 審設計健全**（此為顯著設計變更，blueprint 指定必過）。

## 改了什麼
join/整併實測冗餘（6 層漏斗：都走 merge_teams、搶絕境 niche、join 常勝、整併 marginal 2.5%）→ **收成一個「併入」決策**，resolve 時分流：人少+好感高+低凝聚→dissolve（現 join）/人多 or 好感低 or 高凝聚→整隊變子隊（附庸）。+併入 set 起始忠誠。前 S-A 修全 carry forward。

## 請審（框內 refute）
1. **分流公式健全**：人數/好感/凝聚三軸分 dissolve vs 子隊——會不會某軸主導致一端恆空（同 C1 空窗教訓：分流門檻要有真樣本兩端）？TEST VALUE 但語意方向對嗎？
2. **兩 primitive 真存在**：dissolve=`merge_teams:105`（容量全併）✓、子隊-attach=`set_subteam_parent:143`（雙向同步）✓——**我複核確認存在**。子隊路 **+set_team_faction 繼承**（set_subteam_parent 不動 faction_id）有無漏？
3. **忠誠 init 補漏**：`merge_teams` 換 team_id 不動 loyalty＝真漏洞（新人保留對舊領袖忠誠）？set 起始 loyalty=f(好感,voluntary/coerced,義氣) 補得對嗎？
4. **★外來隊變子隊（S-B substrate）**：`set_subteam_parent` 對非-自源隊，subteam 骨架 `:185/192/198` 歸建-duty 硬假設會不會誤觸（外來附庸被當同源子隊歸建）？我標為 S-A 只需 set 通、完整處置歸 S-B——這切分合理否，還是 S-A 就得處理？
5. **judge 盤點**（01 鐵律）：「併入」合一 option 有無與既有某 judge/option 並存冗餘（除了它本來就是要收斂 join+整併）？
6. **地板**：rank_scored 真 term 禁 flat（drive 食壓 scaled、weight 人格）；gate#1 非搬餓；防 mega-blob（隊數不崩）——spec 有守？

verdict to:systems。CLEAN → dispatch implementer（疊既有 S-A worktree @34034bb）。
