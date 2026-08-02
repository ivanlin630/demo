---
from: blueprint
to: systems
status: consumed
topic: "[★★flow-fix用戶拍板ACCEPTED(我release-pass PASS+循環閉合real:Team0買料→蓋成apothecary+workshop兩設施、Team2同型、料真被用非躺倉)·SLICE A收官=經濟第一次真流動(送達26%→80%、成交0→6、世界非凍兩seed determinism齊)·★開跑甲乙並行·甲=SLICE B領主分配政策(領主派供給給居民、人格施捨↔剝削、餵unrest)·乙=規模動態/打通join投靠(修resolve 85%蒸發→小併大→世界有大有小+perf O(N²)解+legibility,一根三贏)·★約束1統一搬運脊椎(spec更新,用戶定):所有供給空間移動走同一convoy原件(_tick_convoy FETCH→OUTBOUND→DELIVER→RETURN),後勤/貿易/貢/分配=不同dispatch動機+不同DELIVER終點,禁各建平行搬運;甲分配走convoy加DELIVER終點(領主→居民)非另刻;貿易已跑convoy上;乙是consolidation不搬供給、此約束N/A·約束2隔離worktree(防floor式誤merge)·約束3各塊dev-time便宜驗會動(乙:join真resolve? 甲:分配真fire餵unrest?)非跳過·約束4【一次】整世界warring合量+tap分帳(join.resolve↑?分配fire?unrest餵?+全貌活/大小/政治)非多跑昂貴run·你設計甲乙HOW→R²→並行dispatch→各驗→合量·有WHAT回我] flow ACCEPTED(用戶拍板+循環閉合real)。SLICE A收官。開跑甲(分配政策)乙(規模動態/join)並行。約束:①統一搬運脊椎(所有供給移動走同一convoy,禁平行,spec更新)②隔離worktree③各dev驗會動④一次合量+tap分帳。你設計HOW→R²→並行→各驗→合量。"
---

# ★★flow-fix ACCEPTED（用戶拍板）→ 開跑甲乙並行

## flow-fix 收官
- **用戶拍板 ACCEPTED** + 我 release-pass = PASS。
- **循環閉合 real**：Team0 買料→蓋成 apothecary+workshop **兩座設施**、Team2 同型——**料真被用、非躺倉**。
- SLICE A = **經濟第一次真流動**（送達 26%→80%、成交 0→6、世界非凍兩 seed + determinism 齊、三閘綠、merged 2fef2081）。

## 開跑：甲乙並行
- **甲 = SLICE B 領主分配政策**：領主派供給給治下居民、人格 WEIGH（施捨↔高價剝削）、餵 unrest。
- **乙 = 規模動態/打通 join（投靠/併入）**：修 resolve 85% 蒸發 → 小團併進大隊 → **世界有大有小 + perf O(N²) 解 + legibility——一根三贏**。（診斷見 `2026-08-01...scale-dynamics-arc-diagnosed`。）

## ★約束（4 條，鎖住用戶擔心的事）
1. **★統一搬運脊椎（spec 已更新 §4）**：所有「供給空間移動」走**同一個 `convoy` 原件**（`_tick_convoy`）——後勤/貿易/貢/分配 = 不同 dispatch 動機 + 不同 DELIVER 終點，**禁各建平行搬運**。
   - **甲（分配）走 convoy 加 DELIVER 終點（領主→居民），非另刻搬運。**
   - **貿易已跑在 convoy 上**（flow-fix 的 DELIVER=賣市場）——非另一套。
   - **乙是 consolidation（不搬供給），此約束對乙 N/A。**
   - 驗收：新供給移動 grep 確認走 `_tick_convoy`/`TASK_CONVOY`。
2. **隔離 worktree/branch**（甲乙各自，防 floor 式誤 merge）。
3. **各塊 dev-time 便宜驗「會動」**（乙：join 真 resolve 了？小併大？／甲：分配真 fire、unrest 真被餵？）——單元/小場景，**別跳過**（「merged≠會動」血教訓）。
4. **【一次】整世界 warring 合量 + tap 分帳**：全貌（經濟流動+有大有小+領主政治=活了嗎）+ 歸因（`join.resolve↑`？分配 fire？unrest 餵？）——**同一 run 兩者兼得、不多跑昂貴 run**（用戶省時間的裁）。

## 序
你設計甲乙 HOW（各自，大框可升異質 R①）→ R²（CLEAN）→ **並行 dispatch**（隔離）→ 各 dev 驗會動 → **合量整世界** → 判 whole world real/spurious。有 WHAT 拍板回我。

## 溯源
`2026-08-01-systems-to-blueprint-spread-fix-MERGED-user-acceptance`（flow merged）+ `2026-08-01-qa-to-blueprint-flow-loop-closure-real`（循環 real）；用戶拍板 ACCEPTED + 統一搬運脊椎約束 + 甲乙並行合量。
