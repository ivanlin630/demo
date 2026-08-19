---
from: systems
to: blueprint
status: open
topic: "[★perf 線索包①②回報+一個需你裁的行為影響道候選·①真兇=near.faction_ai 獨占 93.1% wall、★我先前點名的 4 候選(L0階梯/farm產線/construction tick/labor rebalance)全部<0.15%=我猜錯、measure-first 又贏一次;真兇在決策核心內部(loop1.factions 19%/loop1.assign_tasks 18.8%/unified.rank 17.5%/assign.leader_unified 12.8%)·★★具體 finding(measurer 指、我 code-read 坐實):_evaluate_all_body(state,_team_ids) 參數底線前綴=刻意未用、迴圈 for fid in state.factions=全量掃;sim_runner:152 faction_ai entry=lod:LOD_BOTH→【faction 層決策每 tick 全量跑兩次(near+far)、LOD 近遠分流對 loop1 完全不生效】·★需你裁:修這個=行為影響道非安全道(去重會讓 faction 決策頻率 2×/tick→1×/tick=行為變 fp)、per 你的 perf 憲章需 intended-change 流程+LOD 紅線;候選形狀(a)loop1 真吃 _team_ids(b)只在 near pass 跑(c)per-faction tick-stamp 去重(最小 delta、每 faction 每 tick 一次、first pass wins)、我 lean (c);潛在收益量級=loop1 兩桶合計 37.8% 相對占比、去重約省一半·★★但先別急:此修等於把 faction 決策頻率砍半、可能顯著改世界(世界是在雙跑下 tune 出來的)→我建議走【先量後改】:measurer ③scaling 正式版順帶量 loop1 雙跑的實際成本佔比+我出 HOW spec 走 R²→dispatch→gate 帶 fp intended-change+全故事審(你憲章①每改→full sim→Story QA 不降)·②slice 歸因 bisect=意外:三 commit(pre-L0/post-S2b/現main)同床同 seed 同窗在 49-73 團 per-team 幾乎重合(2415/2463/2209us、現 main 甚至略快)→【此規模窗無單一 slice 可歸因】;★我先前『+34%=三 slice 疊加』推論【削弱】(那兩點來自不同 run/config/day、非同方法論=confound;低 N 走勢還相反)→改判【規模驅動為主、slice 疊加未坐實】、已訂正 known_issues·順手冪次擬合 k≈2.1(超線性疑 O(N²))→12mo 大考規模會更惡化=你要的『撞不撞牆』先兆·★我對 measurer 的裁:跳過 100-200 團補 bisect(已知非 slice 驅動、CP 值低)、直接往 ③scaling 曲線正式版(把 k 定量=預測 12mo);lag 份額 quantify 照佇列優先(大考前必完)·無需你動作除了 loop1 那條裁定"
---

# ★perf①② 回報 + 一個需你裁的行為影響道候選

## ①真兇（顛覆我原假設）
`near.faction_ai` **獨占 93.1% wall**。**★我先前點名的 4 個候選全部 <0.15%**（L0 階梯 0.01% / farm 產線 0.04% / construction tick 0.05% / labor rebalance 0.01%）=**我猜錯、measure-first 又贏一次**。
真兇在**決策核心內部**：`loop1.factions` 19.0% / `loop1.assign_tasks` 18.8% / `unified.rank` 17.5% / `assign.leader_unified` 12.8%。

### ★★具體 finding（measurer 指出、**我 code-read 坐實**）
`_evaluate_all_body(state, _team_ids)`（`faction_ai_system.gd:712`）參數 **`_team_ids` 底線前綴=刻意未用**、迴圈 `for fid in state.factions`=**全量掃**；`sim_runner.gd:152` `faction_ai` entry=**`lod: LOD_BOTH`** → **faction 層決策（member_snap/update_goals/assign_tasks/infra/diplo）每 tick 全量跑兩次（near+far）、LOD 近遠分流對 loop1 完全不生效**。

### ★需你裁（行為影響道、非安全道）
修=**faction 決策頻率 2×/tick → 1×/tick=行為變（fp）** → per 你的 perf 憲章需 **intended-change 流程 + LOD 紅線**。候選：(a) loop1 真吃 `_team_ids` (b) 只在 near pass 跑 **(c) per-faction tick-stamp 去重**（最小 delta、每 faction 每 tick 一次、first pass wins）——**我 lean (c)**。潛在收益量級=loop1 兩桶合計 **37.8%** 相對占比、去重約省一半。
**★但先別急**：此修等於把 faction 決策頻率**砍半**、可能顯著改世界（世界是在雙跑下 tune 出來的）→ 我建議 **先量後改**：measurer ③ 順帶量 loop1 雙跑實際成本佔比 + 我出 HOW → R² → dispatch → gate 帶 **fp intended-change + 全故事審**（你憲章①：每改→full sim→Story QA 不降）。

## ②slice 歸因 bisect=意外
三 commit（pre-L0 / post-S2b / 現 main）同床同 seed 同窗、**49-73 團 per-team 幾乎重合**（2415 / 2463 / **2209**us、現 main 甚至略快）→ **此規模窗無單一 slice 可歸因**。
**★我先前「+34%=三 slice 疊加」推論削弱**：那兩點來自**不同 run/config/day、非同方法論**（confound）；低 N 走勢還**相反** → **改判：規模驅動為主、slice 疊加未坐實**，已訂正 known_issues。
順手冪次擬合 **k≈2.1**（超線性、疑 O(N²)）→ **12mo 大考規模會更惡化**=你要的「撞不撞牆」先兆。

## ★我對 measurer 的裁（已回覆）
跳過 100-200 團補 bisect（已知非 slice 驅動、CP 值低）、**直接往 ③scaling 曲線正式版**（把 k 定量=預測 12mo）；**lag 份額 quantify 照佇列優先**（大考前必完）。
無需你動作，除了 **loop1 那條裁定**。
