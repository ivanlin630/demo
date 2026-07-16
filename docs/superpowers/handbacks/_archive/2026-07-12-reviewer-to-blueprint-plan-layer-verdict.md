---
from: reviewer
to: blueprint
status: consumed
topic: [對抗①verdict/框外] 中長期計畫層 = issues，四疑全成立，打回
---

# 對抗① + 框外挑框 verdict — 中長期計畫層 design

## verdict: issues（非 premise_contradiction，設計實質缺口，halt）

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {
      "claim": "phase 從依賴序導出＝湧現、非手寫（靶A）",
      "file_line": "specs/2026-07-12-midlong-term-plan-layer-design.md §計畫=導出的承諾軌跡 + §交systems的HOW第62行",
      "truth": "部分成立：spec 自稱「導出非手寫」，但同段 HOW 清單要求新增 `team.plan_phase + 承諾/進度狀態欄`——顯式存儲 sequence/state，湧現只在 phase→option 偏置那層成立，序列本身是被存起來的狀態機。依賴序非嚴格單調（糧夠人不足時 survival/threat 一觸發即在求糧↔成長間橫跳，spec 只用「承諾擋噪音」搪塞未證明無亞穩態）。且 archetype 由人格導出、目標階受野心cap壓縮，多數隊 cap 窄→仍擠同一條低階序列，只是把「反應式卡低階」換成「承諾式卡在序列某步」，本質未變。"
    },
    {
      "claim": "進度條件式承諾真同時避開死鎖+抖動（靶B）",
      "file_line": "specs/2026-07-12-midlong-term-plan-layer-design.md §韌性 第41行",
      "truth": "成立：「進度條件式承諾＝不僵化的答案」純屬文字宣稱兩全其美，把難題全丟給 HOW（第61行「停滯門檻幾cadence」）。核心漏洞：「離milestone變近」訊號本身建在每tick波動的noisy資源上，spec未給任何平滑/積分/趨勢窗口機制抗噪，等於用一個抖動訊號去抑制抖動。門檻鬆→餓死、緊→退回反應式抖動的兩難，spec未觸及可調域證明。"
    },
    {
      "claim": "rung改計畫驅動真穩+不破既有用途（靶C）",
      "file_line": "specs/2026-07-12-midlong-term-plan-layer-design.md §rung改計畫驅動 第50-51/63行；現況 decision_context.gd:254 ambient_train_drive/`:121 ambition_gap`",
      "truth": "成立且被低估：spec自身第50-51行「降只在持續失敗、遲滯、瞬時跌不降」正是內建缺陷——人口已崩但判定窗未到時，隊仍以高階行為（練兵/擴張）撐著，「保留現實檢查」只是口號，無旁路讓survival立即壓過rung行為模式。下游`ambient_train_drive`/`ambition_gap`/GUI讀rung值，更新時機從固定10h變事件驅動後這些消費者的頻率假設會變，spec第63行僅列「複用盤點」未盤這三個既有讀取點的相容性。"
    },
    {
      "claim": "計畫層真塞進「一term+一狀態欄」、無新求解器（靶D）",
      "file_line": "specs/2026-07-12-midlong-term-plan-layer-design.md §核心原則+§四層模型+§韌性 第60行",
      "truth": "成立：phase選擇（缺口×個性×隊形三維）+序列導出+承諾追蹤+進度偵測+停滯判斷+重規劃+劇變偵測+5情境韌性矩陣＋新state欄——客觀上是掛在rank_scored下的獨立state machine，非單一term。spec用「只是偏置term」自我豁免，但真正跑計畫的是那顆狀態機。與專案「統一決策框架、禁多重求解器」原則正面衝突。spec自己第60行都要求「過框架內冗餘lens」——連spec都不確定沒重造。"
    }
  ],
  "note": "異質審（別模型代跑opus，refute-by-default）四疑全部成立，非各打五十。design方向（中長期承諾層修反應式短視）合理，但把planner偽裝成「一term+一狀態欄」是實質性低估與框架違規。file:line factcheck（LADDER_EVAL_CADENCE:13/target_rung:64/ambient_train_drive:254/ambition_gap:121/COMMITMENT_BONUS:6）皆核實無誤，非premise層錯，是設計實質缺口。" }
```

## 打回，最關鍵兩項修改要求
1. **正面承認並界定那顆 state machine**：明確它是不是新求解器，若是，證明它如何在統一框架下不構成第二引擎（否則過不了憲法/統一框架閘）。別再用「偏置 term」自我豁免掉實質複雜度。
2. **給進度訊號的抗噪機制與 rung 遲滯的安全旁路**：具體定義進度如何從 noisy 資源平滑計算（趨勢窗/積分非瞬時差）、以及人口崩潰時 survival 如何無視 rung 遲滯立即接管——否則靶B/C 的死鎖與「該降沒降」會讓「順便修崩潰」的動機反而變成「新增崩潰模式」。

## file:line factcheck（前提，皆確認無誤）
- `ambition_ladder.gd:13 LADDER_EVAL_CADENCE=10*TICKS_PER_HOUR` — 確認10h重算。
- `ambition_ladder.gd:64 target_rung` / `:99 ambition_eval_next_tick` — 確認瞬時重算現況。
- `decision_context.gd:254 ambient_train_drive=0.5 TEST VALUE` — 確認唯一FORCE-archetype低magnitude偏置，claim「幾乎不主動驅動爬升」屬實。
- `decision_context.gd:121 ambition_gap` — 確認存在，僅供`ambition_drive`term用於生產/建設gate，用途窄，claim「算了幾乎沒用」屬實。
- `decision_engine.gd:6 COMMITMENT_BONUS=0.3` — 確認存在，戰術黏性用途。

halt，待 blueprint 針對四疑重修 design 後回 reviewer 重審。
