---
from: systems
to: systems
status: open
topic: HANDOFF——A2c-1 定案 fold+survival-value 待 spec(護欄+鐵證+seam 選項);observer slice 待做;full_probe 已立
---

# HANDOFF：A2c-1 續 + 並行活（ctx 交接，2026-07-09）

## A2c-1 現狀（一句）
純 FA5 fold **做完+全閘綠**，但鐵證證 = **shipping regression**（弱化 merge-as-survival）→ **不可 ship**。blueprint 定案升級 **fold + survival-value**，已放行 spec。**merge 暫緩**至升級版過。

## 鐵證（full_probe seed 1337，檔 `scratchpad/a2c1_fp2_{base,fold}.json`）
- **merge.consolidate_dispatch: baseline 978 → fold 154（−84%）**
- **merge_appl: 320 中 chose_other 166 = 52% 該併卻選別的**
- 下游：avg size 7.0→5.6、join.resolve 24→14、attack-eligible 416→309、extinct.starve 16→19、conq.declared 740→520。
- 因果閉合：fold→少 consolidation→隊小弱+餓→衝突全面降(下游)。

## ★★spec 必守護欄（blueprint owner，不可違）
**治生存地板，別過修回強制併（勿重造 artifact）。** 目標=中間態：
- **弱/餓/瀕死隊可靠求生併**（消 starvation regression）；**強隊有好 option 時自由選**（引擎誠實）。
- **別把 merge 調回 ~978**（=重造 artifact）。
- 分清「求生併(不併會餓死→救回)」vs「機會併(有更好活路→留給引擎)」= seam 精髓。

## 3-way full_probe 驗收線（升級版跑 baseline/現fold/升級版）
1. starvation 回健康（extinct.starve ≲ 16、avg-size 回升、join.resolve 回升）
2. merge 實派回升但**顯著 <978**（求生併回、非強制併復辟）
3. 強隊 option 自由保留（merge_appl.chose_other 仍可觀比例，非再 100% 併）
4. 衝突面回升=觀察值不設 target（下游別逆向逼）

## seam 選項（系統自決，讀 option 去向定形狀）
- consolidate_drive **對弱/餓/小隊加成**（food_days 低 / pop 小 → drive 升，壓過機會 option；強隊常態 drive 低→自由）。
- 或 applicable gate 分「求生併(餓/弱→高優先)」vs「機會併(常態→競秤)」。
- 或 survival-latch 類比（如既有 survival task PRIO；求生併給準-survival 待遇）。
- 若形狀會讓**強隊也被逼併回舊態**→改世界性格→鎖 spec 前回 blueprint。

## 定序
1. spec fold+survival-value（守護欄）→ reviewer 審 → 下游 → full_probe 3-way → blueprint 驗收 gate。
2. branch `feat/machine-A2c1 @ 423924c`（純 fold + full_probe 探針）= 升級基底。
3. blueprint 已同步用戶（52%沒併+merge−84%=白話「為何轉靜」）。

## full_probe 標準床（已立首維度）
- `warring_harness.gd` PROBE_KEYS + `faction_ai_system.gd` bump（main+worktree committed）：`merge.consolidate_dispatch` / `merge_appl.total` / `merge_appl.chose_整併` / `merge_appl.chose_other`。
- 用戶流程修：seeded 診斷床全探針一次抓全、停反應式逐維補量。**未來 slice 複用**；可再擴 team-size 直方圖 + food-flow 維度。

## 並行待辦（獨立）
- **observer inspect 擴充**（用戶親提，信 `blueprint-to-systems-observer-inspect-expand`，已 consumed）：①隊詳情露全資源(現只 food+coin，18 藏)②據點 inspect path(tile-pick+query_outpost+panel)。read-only 系統自決 seam，不需 sign-off。我 spec→reviewer→下游。
- **known_issues 已記**：phantom current_option(faction_ai:1487 寫在 try_set 前，micro-slice 修) + observer dump 月級 perf(<12tick/s，需 headless 快路徑)。

## memory 待提煉（單寫者=我，收尾寫）
- A2c-1 saga(7輪 byte0→drive→artifact→phantom→drama→因果→生存)=反應式逐維量測教訓→全探針一次抓全。關聯 [[feedback_avoid_rabbithole]] [[project_reverse_engineering_arc]]。
- A2c-1 揭露：baseline 征服密度部分 = pre-gate bypass 灌水(stale commitment)；且 merge=生存 lifeline(不只 conquest)。
