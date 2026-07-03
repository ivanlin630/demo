# 斷①：打草穀（faction 成員 raid 連續性）+「入勢力不換腦」enforce — Design

> 藍圖裁定 `chain-rulings-envoy` 裁斷① + 升格原則「身分=權重非路徑切換」（invariants 已納,本波 enforce 第一處）。
> 根據:長窗 T32 唯一跑出複利前段的狼,月 3 入 faction 後 raid 歸零——`fid≠-1` 兩處路徑切換:
> ① `_evaluate_independent_strategy:1040` 早退（個人戰略層關機=入夥人格蒸發）
> ② `_is_prosperity_candidate:437-439` faction 成員非 leader → false（主動 raid 路關）。

## 裁定要點（WHAT,守住）
- raid **獨立弱村=日常 op** → faction 成員保留個體 raid（部將打草穀,五代常態）。
- raid **別家 faction 屬村=拖全派系下水** → 要統領令（③機制管住）。
- faction 開戰時 faction_duty 照常壓過日常（混合協調既有,PRIO_FACTION=30 > PRIO_DISPATCH）。
- **入勢力=加權重不換腦**:個人戰略層對每個 leader 永遠跑;faction 身分=context/term,不是開關。

## 修法

### A. `_is_prosperity_candidate` 放行成員（打草穀）
- 刪「非 leader → false」限制:faction 成員過候選（子隊 parent≠-1 仍擋——子隊非自主 leader）。
- 成員 raid 照走 prosperity 全 gate（archetype/score/readiness+hunger_relief/prey/scout）——日常 op 同獨立隊紀律。

### B. ③ own 因子收緊=統領令語意（day-op 不吃 war_capability 減免）
- 現 `find_prosperity_prey` 的 `own = WAR_COST_BASE + war_capability`——faction 成員 established+rung 高 → 減免高 → **成員日常 raid 可打別家屬村=違裁定**。
- 改:**war_capability 減免只給「能拍板 faction 級大事的人」**——faction leader（統領本人=令即他出）或獨立隊（自家 stakes 自家扛）。**非 leader 成員 day-op 對 believed-owned 恆 `WAR_COST_BASE`**（幾乎不中選）。
- 統領令攻擊路（faction goal directive,`PRIO_FACTION` 指定 target）**不經 find_prosperity_prey**,不受影響——打屬村走令,語意閉合。
- 這不是身分切路徑——是 stakes 歸屬的 means-end 權重（誰扛得起戰爭後果誰才減免）,連續因子照舊。

### C. `_evaluate_independent_strategy` 拆 `fid≠-1` 早退（不換腦 enforce 第一處）
- 成員 leader 也跑個人戰略層:`select_strategic_intent` 全菜單,ctx 調整——
  - `can_found=false`（已在 faction;建國 gate 本就 fid==-1）。
  - 征服 intent → 照 defer prosperity（打草穀路,A/B 已管住 target 紀律）。
  - 守成/防衛/致富=個人日常傾向,**執行層被 PRIO_FACTION 壓**（faction directive 在 → arbiter 擋個人 dispatch=大事壓日常,既有機制零新碼）。
- **scope 紀律**:本波只開「戰略 intent 層+raid 路」給成員;`_evaluate_solo` 全域（貿易/紮營/治理個人日常）給成員=後續矩陣格（F-D 傘）,不在本波——避免與 `_assign_tasks` 派工大面積互搏,一次一縫。
- found in-flight guard/timeout（②a 已修）照吃。

## 硬約束
- 零新判斷器;身分只出現在「stakes 歸屬權重」（B）與「can_found gate」（既有實體 gate）。
- 新 latch:無（全復用既有 task/arbiter）。
- 禁碰:asm 值（剛裁完）、envoy 路、R1 gate 其餘語意。

## 驗收
1. **T32 型解凍（核心）**:長窗 6 月——入 faction 的狼 raid 不歸零（月曲線連續）;`[WolfGate]` 無「★非候選(fid=...)」殺項。
2. **③管住升級驗**:成員 day-op 攻 believed-owned=0（探針 `conq.indep_atk_believed_owned` 擴 member 版或沿用）;faction directive 攻擊照常。
3. **紀律**:faction goal directive 期間成員 raid 被 PRIO_FACTION 壓（headless 場景測:directive 在→個人 raid dispatch 失敗）。
4. **不 over-war**:seeded warring 隊數/attrition 不崩;知足成員仍蹲（archetype/score gate 不分獨立/成員）。
5. 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7（S1 立國含）、coin_eq delta=0、InvariantAudit 0。行為修=pointwise 預期 DIRTY,月線 sanity。

## 檔案 scope
| 檔 | 動 |
|---|---|
| `faction_ai_system.gd` | A 候選放行、B own 減免收緊、C 早退拆+ctx 調整 |
| `headless_test.gd` | 驗收測試（成員 raid/紀律壓層/owned 不打） |
| `longwindow_bed.gd`（如需） | member-wolf 追蹤補位 |
