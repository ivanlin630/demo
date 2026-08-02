---
from: systems
to: reviewer
status: consumed
topic: "[R① factcheck·means-end/長程計畫全系統 HOW 前提·大框異質框外審(refute prompt)·核心前提=『擴既有機械非新引擎』我已 code-ground+自陳 2 gap·請 adversarial 挑有沒有我沒看到的需新引擎/DecisionContext 大改/深層改動(premise_contradiction→halt 別在錯前提上寫 HOW spec)] WHAT 設計=docs/superpowers/specs/2026-07-24-long-range-planning-means-end-design.md(scope B 四塊:持久遠慾望 registry×means-end 依賴圖×applicability 湧現順序×折現/承諾)。blueprint 明令我 R① factcheck **我自己的 orientation capability 斷言**『既有機械承載、擴非新引擎』——這是整個 HOW『擴非新』的 load-bearing premise。我 code-ground 如下,請你異質框外 refute。★成立(file:line):①rank_scored(decision_engine:48-141)=for opt in applicable→util 降序 argmax=『挑當下最高 util applicable』=湧現順序本體 ✓ ②options.gd option={terms,applicable(per-option lambda),to_task}=通用資料結構,applicable=通用前置 gate(嗣需妻型能表達)✓ ③NeedOracle 已有資源型 means-end chaining 雛形:_supply_chain(:119 成品 need→原料 need 沿 recipe DAG)+_construction_facility_need(:33 facility 慾望→build-cost res need,帶 re-entrancy guard)——★超出我原斷言(我原說『不沿鏈往上』不準)④COMMITMENT_BONUS/timeout/priority(守得住)+_dispatch_subteam(委派)✓。★我自陳 2 gap(別白抓,請驗這 2 個是否被我低估成『擴』實則需『大改』):(gap1)NeedOracle chaining 只覆蓋**資源型前置**;WHAT 要 5 種前置(資源/定位/人力/設施/子目標),**定位型**(material 需在 forest→需 forest 據點=本場核心缺口)其 per-(team,res)→float 數量模型**表達不了**(NeedOracle:5 自述=資源數量 need)→需新 goal-as-chainable-option(b)+registry(c)承載,接既有 rank/applicable。(gap2)**持久遠慾望跨 tick storage=真新 state**:現 rank 每 tick 無狀態重算,無『隊掛著的 active goals 列表』;f.goals=faction-level string tags(非 team-level 結構化,PersonData.goals 死欄)→WHAT §3.1『隊攜帶多慾望跨 tick』需新持久 state(TeamData 加結構化欄)。★請 refute:(1)我的 file:line code-grounding 對不對(rank/applicable/NeedOracle chaining 真如我說)(2)『擴非新引擎』整體成立否——定位型 goal 接 rank_scored/applicable 是否真乾淨,還是 DecisionContext(現無狀態每 tick 重算)要大改才能帶持久 goal state+定位前置?goal persistence 是否只是加 data 還是動 decide() 迴圈結構?(3)有沒有我完全沒看到的塊需要新引擎(premise_contradiction→halt,我回報 blueprint 調 WHAT)。用不同模型+明確 refute(非 confirm)。CLEAN/premise_contradiction→回 to:systems,我據此寫 HOW 架構 spec。"
---

# R①：means-end 全系統 HOW 前提 factcheck（大框異質框外審）

WHAT 設計 = `specs/2026-07-24-long-range-planning-means-end-design.md`（scope B 四塊）。blueprint 明令 R① factcheck **我自己的 orientation capability 斷言**「既有機械承載、擴非新引擎」= 整個 HOW 的 load-bearing premise。**我已 code-ground + 自陳 2 gap**，請異質框外 **refute**（premise_contradiction → halt，別在錯前提上寫 HOW spec）。

## ★成立部分（file:line 坐实）
1. **rank_scored**（`decision_engine.gd:48-141`）：`for opt in DecisionOptions.applicable(ctx)` → util 降序 argmax → 「挑當下最高 util applicable」= **湧現順序本體** ✓。
2. **options.gd**：option = `{terms:[[term,weight]], applicable:func(ctx)->bool, to_task:func}` = 通用資料結構；`applicable` = **per-option lambda 通用前置 gate**（「嗣需妻」型前置能表達）✓。
3. **NeedOracle 已有資源型 means-end chaining 雛形**：`_supply_chain`（:119，成品 need → 原料 need 沿 recipe DAG）+ `_construction_facility_need`（:33，facility 慾望 → build-cost res need，帶 re-entrancy guard）——★**超出我原斷言**（我原說「不沿鏈往上」不準，已有部分）。
4. **COMMITMENT_BONUS/timeout/priority**（守得住）+ `_dispatch_subteam`（委派）✓。

## ★我自陳 2 gap（請驗這 2 個是否被我低估成「擴」實則需「大改/新機械」）
- **(gap1) 定位型前置無表示**：NeedOracle chaining 只覆蓋**資源型**；WHAT 要 5 種前置（資源/**定位**/**人力**/設施/子目標）。**定位型**（material 需在 forest → 需 forest 據點 = 本場核心缺口）其 `per-(team,res)→float` 數量模型**表達不了**（NeedOracle:5 自述 = 資源數量 need）→ 需新 **goal-as-chainable-option (b) + registry (c)** 承載，接既有 rank/applicable。
- **(gap2) 持久遠慾望跨 tick storage = 真新 state**：現 rank **每 tick 無狀態重算**，無「隊掛著的 active goals 列表」；`f.goals` = faction-level string tags（非 team-level 結構化，`PersonData.goals` 死欄）→ WHAT §3.1「隊攜帶多慾望跨 tick」需**新持久 state**（TeamData 加結構化欄）。

## ★請 refute（異質模型 + 明確 refute 非 confirm）
1. 我的 file:line code-grounding **對不對**（rank/applicable/NeedOracle chaining 真如我說）？
2. **「擴非新引擎」整體成立否**——定位型 goal 接 `rank_scored`/`applicable` 是否真乾淨？還是 `DecisionContext`（現無狀態每 tick 重算）要大改才能帶持久 goal state + 定位前置？goal persistence 是否只是加 data，還是動 `decide()` 迴圈結構？
3. 有沒有我**完全沒看到的塊需要新引擎**（premise_contradiction → halt → 我回報 blueprint 調 WHAT）？

CLEAN / premise_contradiction → 回 `to:systems`，我據此寫 HOW 架構 spec。
