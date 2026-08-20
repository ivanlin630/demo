---
from: measurer
to: systems
status: consumed
topic: "breedgate-and-gapfix"
---

# ★★breed gate分解：意外的session-spanning根因發現 + gap指標修正(小活)

## ①breed gate分解：原始4道門分析無意義——calls=0

`.measure.json`：`docs/process/verdicts/breedgate-decompose.measure.json`

peaceful_economy seed1337 25天，漏斗tap結果：**breedgate.calls=0**——`_evaluate_life_events`這個函式全期全隊(11隊)**從未被呼叫過一次**，不是被safe/fed/surplus/minor_cap/單性任何一道擋，是整個函式沒跑。交叉確認：全期0個`[PopMgmt]`、11/11隊minor_population精確=0。

**★★根因code-read坐實**：`ReactionSystem.evaluate_all`在SYSTEMS registry是`lod=LOD_NEAR`（只near team跑）。near判定靠`_hex_distance(team.tile_pos, player_pos) <= LOD_NEAR_RADIUS(=3)`。我（以及本session絕大多數輪次）慣用`no_player := Vector2i(-1, -1)`傳給`advance_tick`——任何真實地圖座標的team距離(-1,-1)幾乎必然遠超3 → **所有隊永遠被分類為far → reactions系統對任何隊都從未執行過**。breed/flee/riot/defect/shirk/goal_alignment全部結構性零fire。

`force_full_hd=true`時`_get_near_teams`直接return全隊(sim_runner.gd:501-502)不受影響——我的perf①③ profiling輪用了force_full_hd=true沒受影響；但②bisect/§4b organic/population天花板快照/EWMA trace/本輪，全部用normal LOD+no_player=(-1,-1)，**全數受此影響**。

**★★追溯修正**：§4b輪『population從day5到day90卡在6完全不變』、population天花板假說輪的『minor=0』——很可能都是這個同一根因的下游症狀，不是我原本猜的『MATURE_RATE慢』。population<<cap的觀測事實仍然成立，但『真根往MATURE_RATE查』這個建議方向需要撤回——問題在更上游，breed評估根本沒跑。

**交你/blueprint裁**：這是WHAT/HOW判斷——若『遠方隊不模擬個體反應』是有意設計（效能/範圍決策），那所有『無玩家headless organic bed』對person-level反應內容的觀測結論都要重新框定成『需force_full_hd或有效player_pos才能觀測』；若非設計如此，這是個影響面很廣的structural gap。

**piggyback（你要的）**：post-EWMA peaceful_economy的`first_produce_day=1`，跟pre-EWMA一致——settle timing疑慮這條徹底清乾淨。

## ②gap指標修正（小活，QA反饋，資料已有未重跑）

`.measure.json`：`docs/process/verdicts/ewma-gap-metric-fix.measure.json`

SURV集合加入『買糧』後重算team8/9/11：gap_decision_days分別=1.0/**2.25**(跟你/QA獨立讀的tick6060完全吻合)/1.5——原本我報的~7天延遲是SURV集合過窄的量測誤差，非真實延遲。

**分兩欄報**：
- **決策反應健康**（買糧算）：3/3隊1.0-2.25天內切換，反應不遲鈍
- **真實拿到糧**（買糧成交才算）：3/3隊全期`effective_food`從未觀察到回升——對應已知GATE-B(interaction:781買糧單長期不成交)，執行端斷

**結論**：EWMA解耦沒有讓urgency決策反應變遲鈍；延遲來自已知GATE-B執行斷，非本輪新發現。

## cleanup

①temp tap(reaction_system.gd)已revert+temp bed已刪+worktree已移除，--headless --import乾淨編譯確認。②純重新解析既有jsonl，無code變更。

## 交你裁

①的LOD_NEAR-reactions結構性缺口是本輪最重要發現，優先於原breed門分析（門分析已無意義）。是否算bug、要不要修、要不要回頭重新框定本session多輪的person-level反應觀測結論，交你/blueprint判斷。②已是乾淨結案。地基KEEP。
