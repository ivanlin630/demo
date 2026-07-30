---
from: systems
to: implementer
status: open
topic: "[實作·後勤SLICE A供給-delivery convoy(GATE-B撮合物理送貨)·spec=2026-07-31-logistics-slice-A-supply-delivery-convoy-HOW.md(R²CLEAN)·(A)新deliver決策option:surplus holder有res X surplus(effective_holding>reserve+margin)+知市場outpost掛buy X order(belief-gate複用_nearest_market_outpost_with)→生{task:TASK_CONVOY,target:市場,cargo:{X:qty},kind:deliver}入argmax util秤·(B)convoy生命週期:②新TASK_CONVOY+porter FETCH撥款樣式withdraw X+③各階段專屬_evaluate_subteam early-return分支(FETCH/OUTBOUND/DELIVER/RETURN比照TASK_BUILD/SETTLE防generic fallback:1753攔截)+DELIVER TileBank.deposit市場granary+RETURN到家釋放pop非settle/merge+④撤persist-hold(子隊本sticky)·接_market_visitor_buy→fulfilled>0·★★三驗收線:①真派真deposit granary②fulfilled>0③貨物理真離賣方·★追蹤項(R²):deliver payoff正規化公式交付須附per-option util真dump驗deliver candidate真fire(別假設,本session鐵律)·純算術零RNG cargo守恆不凍] 後勤SLICE A物理送貨。deliver option+convoy生命週期。★交付附per-option util dump驗deliver真fire。三驗收線+不凍+守恆全綠。"
branch: feat/logistics-slice-A
---

# 實作：後勤 SLICE A — 供給-delivery convoy（GATE-B 撮合物理送貨）

R² CLEAN（②③④ lifecycle 修正精準對應、DELIVER→買方 TileBank.get_stored 連結坐實、measured 驗真 fire 紀律內建）。這是**後勤 arc 物理送貨第一刀、GATE-B 撮合真 fix**（measure 定案 grounded：賣方菜單缺 deliver option）。

## spec
`docs/superpowers/specs/2026-07-31-logistics-slice-A-supply-delivery-convoy-HOW.md`（讀它）。

## scope（兩塊一體）
### (A) 新 deliver 決策 option（§2）
- 觸發：隊有 res X surplus（`effective_holding(X) > TradeValuation.reserve(X) + margin`）+ **知市場 outpost 掛 buy X order**（belief-gate，複用 `_nearest_market_outpost_with` 找 known 市場有 X demand；★感知鐵律讀 belief 非 god-view）。
- 生 candidate：`{task: TASK_CONVOY, target: 市場 pos, cargo: {X: deliver_qty}, kind: "deliver"}` 入 rank 池。`deliver_qty = min(surplus−reserve, 市場 demand, 載重上限)`。
- util 走既有 `_candidate_util`（payoff=賣 X coin gain 正規化 × dev_coeff × discount），**util 秤非 scripted**。

### (B) convoy 生命週期（§3，②③④ plumbing）
- **②新 `TASK_CONVOY`** 常數（team_data.gd）。
- porter subteam dispatch（複用底盤）+ **FETCH**（`_fund_subteam_from_vault` 撥款樣式 withdraw X 進 porter carry、載重上限 cap）。
- **③各階段專屬 `_evaluate_subteam` early-return 分支**（比照 TASK_BUILD/SETTLE `faction_ai:1719-1760`，★防 generic fallback `:1753-1755` merge_queue 攔截半路棄貨）：FETCH→OUTBOUND（travel 市場）→DELIVER（`TileBank.deposit` 市場 granary）→RETURN（回母隊釋放抽出 pop，★非 `_convert_to_resident`/`_merge_into` 消失）。
- **④撤 persist-hold**（子隊非 IDLE 本 sticky `faction_ai:1758-1760`）；防護靠③專屬分支。
- 接既有 `_market_visitor_buy` → **`order_fulfilled>0`**。

## ★★TDD（三驗收線 + measured deliver fire + 不凍）
- **★①deliver convoy 真派真到真 deposit**：seeded 場景（賣方 surplus X + 買方 demand X + 市場）→ `convoy.dispatch>0` → FETCH（賣方 vault X 減）→ DELIVER（市場 granary X 從 0 升）→ RETURN（pop 回）。
- **★★②`order_fulfilled>0`**：和平床 re-run，material `order_fulfilled` 從 0 起來。
- **★③貨物理真離賣方**：賣方 material 真到市場倉（`ever_moved=true`、離 inventory 到 granary）。
- **★★追蹤項（R²）：deliver option 真 fire measured 驗**——**交付 handback 須附賣方 per-option util 真 dump**（deliver candidate 贏 argmax when surplus+demand），**別假設**（本 session 5 次假設決策 fire 血證、鐵律 [[feedback_measure_peroption_util_before_decision_claim]]）。deliver payoff 正規化實數在此驗（util 夠高真 fire）。
- 不凍（seed1337 attrition 非→0）+ cargo 守恆（賣方 vault−/porter/granary+）+ 純算術零 RNG + determinism 三跑 + constitution 74 + observability + headless 0-new。

## 交付
handback `to:systems`（★**附賣方 per-option util dump 驗 deliver 真 fire** + 三驗收線數）→ R²（複驗 deliver 真 fire measured + lifecycle 不被攔 + 守恆 + 不凍）→ measurer（三驗收線 + 不凍）→ QA。**★這是 GATE-B 撮合真 fix、三驗收線 blueprint 鎖。** 卡住報 `to:systems`（別空等、convoy 生命週期別偷用既有 settle/merge）。
