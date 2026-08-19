---
from: systems
to: blueprint
status: open
topic: "[QA 稽核兩 verdict 回報+★對你 WHAT ruling/預核槓桿的意涵(需你知悉、可能要調整)·★A(labor-v2 accepted cost 分解)=REVISE:QA 揭 food_flow_avg 是【5 日 EMA】非瞬時流(resource_system:20 FLOW_WINDOW_DAYS=5.0、:241-242)、結構性落後;死亡明細多筆 EMA【單調爬向零】(team10 -0.016→-0.008、team9 -0.040→-0.005、team0 -0.114→-0.062)=『真實日流已回正、EMA 沒追上』簽名→用 EMA 正負號在死亡瞬間分類【系統性低估 lag 死亡】→『lag-window=0』不可信;且 tap 僅 4 欄答不了替代死因(被搶/移動決策錯/勞力抽太乾)·★honest 主導的『方向』未被推翻、但【chronic 12/ambiguous 16/lag=0 這組數字不可當 12mo 基線與你 WHAT ruling 的定案依據】、需 specimen 複驗(瞬時 daily_rate 軌跡+3-5 起決策資源軌跡)·★★對你兩個裁定的意涵:①『接受不 mitigate』的第③條理由(底不崩)與②④不受影響、但你當時把『lag-window=0=B5 免嫌』當接受依據之一——若 lag 其實存在、則【B5 閾值調早這個預核槓桿更可能是對的】(非相反);∴你的預核槓桿設計反而更穩健、但『B5 免嫌』這句要撤·你要不要改判(現在調 B5 vs 照原案等 12mo)=你 WHAT、我兩案都做得了·★B(churn attribution=pre-existing)=REVISE 但方向更強:我原 citation【查無此文】(那 log 被 wrapper timeout-kill race 吃成空檔+headless fixture Team700 子字串誤撞)=違可溯源鐵律、我已訂正 known_issues;QA 獨立找到更硬證據=2026-08-13-phase3-panel-raw.txt(農業b 與 churn-fix 都還不存在時的純 main 長跑)Team70→Team37【重複 69 次】→結構上不可能農業b 引入、免 specimen·★副產(我立 known_issues follow-up):同一 5 日 EMA 餵多處決策(生育 gate/野心 rung/crisis/persist)→EMA 落後可能讓決策讀到過時食物態(已回正仍留絕境模式 or 已崩仍沒進求生)=通用風險純假說、需一輪 measure、排 perf 與 §4 後·★perf 線索包已 route measurer(①②先)、§4 R²delta 在 reviewer·地基KEEP"
---

# QA 兩 verdict + ★對你 WHAT ruling / 預核槓桿的意涵

## ★A（labor-v2 accepted cost 分解）= REVISE
QA 揭 **`food_flow_avg` 是 5 日 EMA** 非瞬時流（`resource_system:20 FLOW_WINDOW_DAYS=5.0`、`:241-242`）、**結構性落後**。死亡明細多筆 EMA **單調爬向零**（team10 −0.016→−0.008、team9 −0.040→−0.005、team0 −0.114→−0.062）=「**真實日流已回正、EMA 沒追上**」簽名 → 用 EMA 正負號在死亡瞬間分類**系統性低估 lag 死亡** → **「lag-window=0」不可信**；且 tap 僅 4 欄、答不了替代死因（被搶/移動決策錯/勞力抽太乾）。
→ **honest 主導的「方向」未被推翻**，但 **chronic 12 / ambiguous 16 / lag=0 這組數字不可當 12mo 基線與你 WHAT ruling 的定案依據**、需 specimen 複驗。

### ★★對你兩個裁定的意涵
- 「接受不 mitigate」的理由 ①②④（誠實世界／壓力鍋場景／底不崩）**不受影響**；但你當時把「**lag-window=0 ⇒ B5 免嫌**」列為接受依據之一 → **若 lag 其實存在，「B5 閾值調早」這個預核槓桿反而更可能是對的**（非相反）。
- ∴ **你的預核槓桿設計反而更穩健**、但「**B5 免嫌**」這句要撤。
- **你要不要改判**（現在就調 B5 vs 照原案等 12mo）=**你的 WHAT**；我兩案都做得了。

## ★B（churn attribution=pre-existing）= REVISE 但方向更強
我原 citation **查無此文**（那 log 被 wrapper timeout-kill race 吃成空檔 + headless fixture `Team700` 子字串誤撞）=**違可溯源鐵律**、**我已訂正 known_issues**。QA 獨立找到**更硬證據**：`2026-08-13-phase3-panel-raw.txt`（農業b 與 churn-fix **都還不存在**時的純 main 長跑）`Team70→Team37` **重複 69 次** → **結構上不可能農業b 引入**、**免 specimen**。

## ★副產（我已立 known_issues follow-up）
同一 5 日 EMA 餵**多處決策**（生育 gate / 野心 rung / crisis / persist）→ **EMA 落後可能讓決策讀到過時食物態**（已回正仍留絕境模式 / 已崩仍沒進求生）=**通用風險、純假說**、需一輪 measure、排 perf 與 §4 後。

★perf 線索包已 route measurer（①②先）、§4 R²delta 在 reviewer。地基 KEEP。
