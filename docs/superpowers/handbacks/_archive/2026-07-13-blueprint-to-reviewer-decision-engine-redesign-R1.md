---
from: blueprint
to: reviewer
status: consumed
topic: [R①對抗·premise查證] 決策引擎架構重構(需求金字塔驅動決策)——用戶已approve，查spec內斷言是否成立，特別是「現況是N個獨立term瞎子投票」這個核心premise
---

# 決策引擎架構重構 —— R①對抗（premise/factcheck）

## 背景
`docs/superpowers/specs/2026-07-13-decision-engine-needs-hierarchy-redesign.md`（已commit `34f2591`）。用戶approve，本session established調查鏈六輪深入後，發現決策引擎本身架構問題（比逐層修established門更根本），跟我brainstorm定案後寫成spec。

## 核心premise要查（factcheck，只信file:line）
1. **「現況是N個獨立term瞎子投票，最後只在rank_scored加總」**——這是整份spec的動機根基。已有一次Explore subagent窮盡稽核佐證（本session早前已做，見決策鏈artifact的稽核紀錄），但你要獨立驗證，非只信我轉述：查`terms.gd`所有term函式是否真的互不讀彼此的輸出（各自獨立從`ctx`原始資料算，還是有部分term其實已經互相參照）。
2. **「select_strategic_intent跟derive_plan_phase各自獨立算，沒人協調」**——查是否真的完全獨立（intent選出後，phase的計算函式`derive_plan_phase`有沒有讀取`ctx.intent`或`team`的intent相關欄位）。
3. **「這個專案自稱的統一決策框架只解決『不要有第二個引擎』，非語意統一」**——查`project_unified_decision_framework`相關的既有commit/spec文件，確認歷史宣稱的範圍是否真的只到「單一rank_scored公式」為止，沒有宣稱過語意層的協調。
4. **既有可複用機制是否真的存在且如spec所述**：
   - S1的EWMA趨勢+crash-bypass機制（`ambition_ladder.gd`）是否真的可以直接複用給needs金字塔的active層判定（非需要大改才能用）。
   - `plan_phase_drive`偏置機制（`decision_context.gd:133-140`）是否真的可以延伸做前瞻偏置（同一套MAG機制，只是加一組「下一層」的偏置）。
   - `found_score`/`weak_enemy`是否真的可以直接複用當「賭命跳關」的目標價值判準（查這兩個值的計算是否適合這個新用途，非答非所問）。

## 為何R①（非R②）
這是全新概念的大框架設計，含多個未驗code斷言（特別是premise 1），符合R①觸發條件（新概念大框+前提含未驗斷言）。

## 序
CLEAN後 → 走R②（dispatch前設計審，範圍/拆分/風險）→ 交systems排writing-plans（預期會拆多個slice）。若premise_contradiction，halt並回報哪個假設不成立。
