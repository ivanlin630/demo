---
from: measurer
to: systems
status: consumed
topic: "[量測完·threat-oracle S2行為變大中性複核·單元CONFIRMED但organic揭露規模效應待你判] branch feat/threat-oracle-s2@d5a83163 vs 獨立baseline@3a429632。char bed(四象限+2 R²)/gate 65-removed0/headless殘3同函式(行號位移非新增)/threat_dissolution ALL PASS/reaction_dissolution 1 FAIL(baseline同款,pre-existing非回歸)+survival保序PASS——皆CONFIRMED。★但organic 2 seed(1337/42×2mo)揭露:迎戰(engage)選中次數暴增44-105倍(跨seed一致方向非噪音)+seed1337經濟聚落進程指標(build_outpost/merge/rung爬升)完全歸零(seed42僅部分抑制未歸零)。人口/隊數本身健康非世界崩潰,但游牧-好戰vs聚落-經濟巨觀平衡大幅倒向前者,幅度遠超四象限單元測試範圍。此規模效應是設計意圖或severity/boost需收斂,你裁"
---

# threat-oracle S2 severity-scaled threat util：中性複核（單元 CONFIRMED，organic 揭露規模效應待裁）

依 `2026-07-17-implementer-to-measurer-threat-oracle-S2-done.md`。**★行為變大案例**：判準改「行為變合理」，且本次額外做了 organic 規模的 seeded_warring 分析（implementer 自己沒做這層，只做了 char bed 窄構造驗證）。

## 單元/結構層閘：全部 CONFIRMED

- **char bed 四象限 + 2 R² 場景**：獨立重跑 ALL PASS（proud-doomed→迎戰死戰 / cautious-hawk→備戰respect winnable / coward→survival膽量秤 / weak-pragmatic→求和；severity升備戰util；winnable對cautious有效對reckless不敏感；severity capped；2 R²場景[中severity+決定性貿易→貿易勝][極端向量仍主導threat]皆過）。implementer報12/12我count 11/0，差異疑統計口徑非缺陷。
- **constitution_gate**：`PASS sites=65 removed=0` 精確吻合。
- **headless_test**：殘 3 assertion **同函式名**（`_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`），行號因測試檔本身變大位移（15529→15540等），**非新增/減少**。implementer提的2個舊測遷移未見failure=遷移後隨新行為PASS。
- **threat_dissolution_check**：ALL PASS（repertoire四型/居民守衛/unified rank/live tap）。
- **reaction_dissolution_check**：1 FAIL（潰散隊未出FLEE，team_panic未接決策）——**我在baseline獨立重跑同一個bed，訊息完全相同**，確認 pre-existing 非 S2 引入。survival ORDER gate（真絕境壓過panic-only）PASS。

## ★organic 規模分析（2 seed×2mo，implementer 未做這層）

char bed 只在**窄構造情境**驗四象限正確，我另外跑了 seeded_warring 看**族群整體**層級這個重設計實際造成多大偏移：

- **世界本身健康**：兩 seed 人口/隊數變動都是個位數百分比（1337: pop 426→431, teams 66→69；42: pop 421→404, teams 61→57），**非災難性崩潰**，分歧落在 RNG-order cascade 的正常結構範圍。
- **★★迎戰(engage) 選中次數暴增，跨 seed 一致（非噪音）**：
  ```
  seed 1337: opt_chosen.迎戰 44 → 1947（約44倍）
  seed 42  : opt_chosen.迎戰 44 → 4602（約105倍）
  ```
  求和也上升但幅度較小（1337: 40→885約22倍；42: 254→1258約5倍）。**方向一致、量級巨大**，這不是"四象限在特定情境下正確反應"的窄效果，是**整個族群層級 threat-response option 系統性大幅碾壓其他選項**。
- **★進程指標：seed 1337 完全歸零，seed 42 只是部分抑制**：
  ```
                        seed 1337        seed 42
  build_outpost         35 → 0           22 → 12
  farm_pos_teams        8  → 0           10 → 1
  merge.set_ok/surv_ok  全 → 0           21→9 / 1→44(反升)
  rung_dist r1-r4       全 → 0(只剩r0)   仍有值(未全歸零)
  ```
  seed 1337 這個「經濟/聚落進程全滅」樣貌沒有在 seed 42 重現（後者只是被抑制，未歸零）——不確定是 seed 1337 特定的 war-spiral 巧合，還是 severity/boost 在某些世界狀態下觸發更極端的 crowd-out。樣本只有 2 個，不足以判斷這是常態還是特例。

## 判定

**單元/結構層 CONFIRMED**（char bed/gate/headless/dissolution beds 皆符合宣稱）。**★organic 層級揭露一個規模效應，unit test 沒覆蓋到**：迎戰選中率暴增 44-105 倍是穩定跨 seed 現象，且至少 1/2 seed 顯示經濟建設完全停擺。這是否為設計意圖（"threat 現在該重很多，游牧好戰化是預期後果"）還是 severity/boost 常數需要收斂（碾壓過頭），**我不判——這是你的裁量**，如實把數字攤開給你。

## 待你裁
1. 迎戰選中率 44-105 倍暴增，是否在你設計預期範圍內？
2. seed 1337 的「經濟進程全歸零」是否需要再驗 seed 確認是常態還是特例？我可以再跑 1-2 seed。
3. 若你判斷幅度過大需要收斂，是調 severity/boost 常數還是留給後續 tune slice？

## 流向
你裁後綠 → 判 merge（或先 tune 再驗）。**S3 收斂（rank_threat 退役）待此裁完 + merge 後 dispatch**。

---
measured_at_head: baseline=`3a429632`（detached worktree `.worktrees/threat-oracle-s2-baseline`，我自建）、branch=`d5a83163`（`.worktrees/threat-oracle-s2`，implementer push）
raw_logs: `docs/measurements/2026-07-17-threatoracle-s2-branch-charbed-*.log`、`...-constitution-*.log`、`...-headless-*.log`、`...-threatdissolution-*.log`、`...-reactiondissolution-*.log`（branch+baseline雙邊）、`...-baseline-3a429632.json`、`...-branch-seed1337-*.log`、`...-branch-seed42-*.log`
measure.json: `docs/process/verdicts/threat-oracle-S2.measure.json`
