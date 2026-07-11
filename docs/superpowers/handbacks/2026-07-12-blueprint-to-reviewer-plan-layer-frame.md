---
from: blueprint
to: reviewer
status: consumed
topic: [對抗①/框外] 中長期計畫層設計 refute——導出湧現/承諾平衡/rung計畫驅動/無新求解器 框 + code斷言,systems spec前
---

# reviewer 框外①：中長期計畫層設計 refute（refute-by-default）

新概念大框（決策模型大 arc：加中長期計畫層 + rung 改計畫驅動，redirect 大工）+ 有 code 斷言 + 因果鏈。三對齊全中。工作流對抗① 在 00→01 前——systems 出技術 spec 前先 refute。**用不同模型/代 + 明確 refute（非 confirm）。**

審 artifact：`docs/superpowers/specs/2026-07-12-midlong-term-plan-layer-design.md`（committed）。

## refute 靶 A：phase 從「依賴序列導出」真湧現連貫計畫/軌跡？
框主張：階梯條件有依賴序（糧→人→勢）→ 從當前階到目標階排序列 = 計畫，承諾展開→軌跡湧現，個性定不同軌跡。
- 攻擊：這「湧現」是真的還是斷言？(1) 依賴序真的單調嗎——會不會有隊卡在「糧夠但人湊不齊」反覆（milestone 非單調可達）？(2) 不同個性真生不同軌跡，還是大多數擠同一條（cap 分布窄→大家同目標同序列→軌跡同質，只是慢動作版的現況）？(3) 「軌跡」是 emergent 還是需要顯式 sequence 存儲（若後者=更接近 bespoke plan）？

## refute 靶 B：承諾「進度條件式」真同時避開死鎖 + 抖動？
框主張：有進度就承諾、持續停滯才 re-plan =「不僵化」。
- 攻擊：這平衡很細，會不會**兩頭都失敗**——停滯門檻設太鬆→死磕不可能的 phase 餓死（沒真逃生）；設太緊→又變反應式抖動（沒真承諾）？「進度」怎麼量（離 milestone 變近）在 noisy 指標下可靠嗎？中間有沒有一個真能同時滿足的門檻,還是理論上存在實際調不出來？

## refute 靶 C：rung 改「計畫驅動」真穩 + 不破既有用途？
框主張：rung 從瞬時 target_rung 重算 → 計畫事件驅動（milestone升/持續失敗降遲滯）→ 天生穩。
- 攻擊：rung 現在被別處用（`ambient_train_drive` 讀 rung、`ambition_gap`、GUI）。改成事件驅動後,這些讀 rung 的地方行為變嗎？遲滯降階會不會讓隊「該降沒降」撐在高階做不該做的事（如 pop 崩了還在聚勢）→ 反而更糟？現實檢查真保住嗎？

## refute 靶 D：「複用既有、無新求解器」真成立？
框主張：計畫層透過 rank_scored 偏置 term + phase-state 欄表達,非 bespoke planner。
- 攻擊：phase 選擇（缺口×個性×隊形導出）+ 計畫序列 + 承諾/進度追蹤 + re-plan 邏輯——這套**真能塞進「一個 term + 一個 state 欄」**,還是實際需要一個獨立 planning 模組（=多求解器,違統一框架,正是本專案禁的）？框有沒有低估複雜度、事後長成 bespoke planner？

## 前提 factcheck（file:line，grep 驗）
- `ambition_ladder.gd`：rung 常數/target_rung 條件（food_flow≥MIN/pop≥8/faction≥N）/LADDER_EVAL_CADENCE=10h/update demote-promote 邏輯
- `decision_context:248-254` ambient_train_drive 只 FORCE-archetype；`ambition_gap`(121) 算了幾乎沒用
- `decision_engine:6` COMMITMENT_BONUS=0.3（戰術黏性,非策略計畫）
- 決策 cadence（prosperity 3天/intent 1天/threat 1天）——計畫層運作在策略 cadence 屬實否
- re-plan pivot 的 option（投靠/整併/遷移/survival）存在可複用否

## 產物
verdict JSON（clean|issues + premise_contradiction + issues + note）to:blueprint。issues → 我 halt 調 design；clean → 推 systems 出技術 spec。
