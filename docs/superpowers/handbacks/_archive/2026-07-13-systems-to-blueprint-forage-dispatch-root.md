---
from: systems
to: blueprint
status: consumed
topic: [零跑結論·redirect] commitment被數字否證(非真因);真根=覓食undispatchable(local game枯竭+只掃相鄰)→fallthrough生產+買糧排生產下;別建commitment閥,查forage-dispatch/food-ranking
---

# 零跑結論：不是 commitment，是覓食 undispatchable fallthrough

## ★commitment 被數字否證（patch-gate-first，你要求「查實際計算」）
trace：`覓食=0.95 生產=0.58 買糧=0.30 … winner=生產`。
- `COMMITMENT_BONUS=0.3`（`decision_engine:6`）。生產+0.3=0.88 **仍 < 覓食 0.95**→commitment 無法讓生產贏。
- 且 trace **生產顯示 0.58 非 0.88**→capture_options 記 post-commitment util(current_option 已加)→**commitment 根本沒加到生產**(current_option≠生產,或此路無 commitment)。
- ∴ **commitment 不是真因**。建 commitment 逃逸閥=修錯對象。

## ★真根（code 坐實）：覓食最高但 dispatch 失敗→fallthrough
`覓食` ranked 第一(0.95),但 dispatch loop 跳過→落第二(生產)。為何跳過：
- `to_task("覓食")` target=`_find_forage_tile`(`:3195-3209`)：**只掃 7 個相鄰格**的 wild_game，全無 game→返回 **`(-1,-1)`**。
- dispatch loop `if tgt==(-1,-1) and task!=FLEE: continue`→**覓食 undispatchable→跳過→生產(第2 util,有 outpost 恆 dispatchable 但不產糧)**。
- Team7 尾：pop5、local game 枯竭(久蹲同區)→覓食找不到 tile→產糧(無用)→餓死。**死法=覓食想做但做不到,非 commitment 鎖生產**。

## 複合問題（同一 trace 揭）
1. **覓食 undispatchable-fallthrough**：最高 option 做不到→落到**非食物** option(生產),非落下一個**食物** option(買糧)。dispatch fallthrough 不分「同需求替代」。
2. **買糧(0.30)排生產(0.58)之下**：餓隊食物取得(買糧)分數<生產→即使覓食失敗也產糧不買糧。買糧 base(dist_disc)×coeff 對餓隊偏低,待查。
3. **覓食只掃相鄰不移動**：local game 枯竭隊無法遠行覓食(無 move-to-game)。

## ∴ 別建 commitment 逃逸閥（修錯對象）
真根三選一/組合（帶數據修，非猜）：
- **A**：覓食 undispatchable 時 dispatch fallthrough **優先同需求(食物)替代**(買糧/掠奪/併入)，非任意次高(生產)。
- **B**：買糧/食物 option 對餓隊 ranking 抬(coeff/base 校)——餓隊該食物優先於生產。
- **C**：覓食支援遠行找 game(move-to-forage,非只 7 相鄰)——但這較大(movement)。

## 附：survival-path 該不該 merge
- **② FLEE gate 確認根治**(spurious FLEE 907→0)=淨正進度。
- **① latch 重選**：此 trace 是 **unified(produce tag)隊**→`_evaluate_survival:2993 uses_unified→return`→**① 對此隊 N/A**（① 只作用非-unified survival 隊）。∴ ① 未被此 trace 驗（unified 隊走 _decide_unified 主 rank，非 survival 路）。① 邏輯正確但需非-unified 餓隊 trace 才驗。
- determinism CLEAN/0 新 error/無回歸。**建議 merge survival-path**(② 淨正,① 正確待非-unified 驗)→forage-dispatch 真根另 slice。

## 判斷請求
1. 確認 **merge survival-path**(② FLEE gate 進度 + ① 正確待驗)？
2. forage-dispatch 真根修：先讓 measurer 補數據（買糧 coeff/覓食 target-fail 頻率/餓隊 food-option 分布）分清 A/B/C 哪個主導，再出 spec？我推薦**先補數據分 A/B/C**（同 9-zero/normalize 的 measure-first：別猜哪個修法）。
3. commitment 逃逸閥：真根非 commitment→**擱置**（除非別處另有真 commitment over-stick 案例，此案不是）。

零跑至此（code 審 _find_forage_tile/dispatch loop/COMMITMENT/trace 數據，無跑 sim）。等你裁 merge + forage-dispatch 查法。
