---
from: systems
to: implementer
status: open
topic: "[dispatch·means-end S2 資源型 resolver·spec HOW §10 S2+組件 C/E/G+F護欄·resolver 實作資源型 frontier+NeedOracle 泛化+資源維持 goal-set+最小 goal 生成+must-fix① range 斷言首上場·定位型仍 stub·★base=LOCAL main HEAD 96d2f083(含 S1 merge)非 origin·新 branch feat/means-end-s2-resource off local HEAD] 架構 spec R①R②全 CLEAN、S1 骨架已 merged。S2=第一個實質 slice:goal frontier 資源型 resolution 接通(byte-identical 打破=開始有行為,但只資源型+定位/人力/設施 stub)。★base 鐵律:off LOCAL main HEAD 96d2f083(非 origin,~90+ commits local-ahead)。修(照 spec 組件):①★最小 goal 生成(組件 A,S2 版:每隊冪等確保 goal_state 含 5 個資源維持 goal;S7 才做 util-門檻掛退 cadence 泛化):maintain_food/maintain_material/maintain_tools/maintain_weapons/maintain_coin,active when holding<target②GoalRegistry(組件 B)填這 5 個 goal 的 resource 前置:{kind:resource,res:<res>,qty:<need>}(qty 走 NeedOracle need_keep 通用)③★NeedOracle 泛化(組件 E):脫 CONSTRUCTION_COST_RES=[material,tools] 硬 scope→資源型前置 qty 用通用 need_keep(任 res 非只 material/tools);re-entrancy guard 精神保留④GoalResolver.frontier_candidates(組件 C,取代 S1 stub)實作資源型:walk goal_state active goal→walk prereqs→resource 前置查 holding vs qty,未滿→生「取得 res」candidate;取得手段 S2 先接『買』(既有買糧 options:243/買料:259 的 to_task,市場取得不需定位);★採(需 forest 定位)/產(需設施)=定位/設施前置 S2 回無 candidate(S3/S4)⑤★must-fix① util 護欄(組件 G/§8,首上場硬做非留 plan):candidate.util=payoff_base×dev_urgency_coeff(ctx)[鏡射 NeedHierarchy.consistency_coeff,絕境 food_days→0 係數→0]+clamp 上界<SURVIVAL_BOOST_FLOOR 對應 survival 保底(硬保證 goal candidate 永不蓋 survival);折現(延遲)S6 才加,S2 util 即時取得無延遲折。TDD:①resolver 資源型 candidate 真出現(缺 res 隊生取得 candidate)②NeedOracle 泛化(非 material/tools 的 res 也算 need)③定位/人力/設施前置 S2 回無 candidate(stub 邊界)④★★must-fix① 合成 range 斷言(unit,絕境合成 ctx food_days→0:任意 payoff 的 resource candidate util<survival-boosted static option util=護欄硬迴歸,reviewer 指定 S2 回歸點別漏)⑤determinism 2 跑 byte-identical(resolver 純讀狀態+NeedOracle 禁 randf)。閘:constitution_gate PASS(GoalResolver 讀 belief 非 god-view;禁 RNG)+headless 0 new+determinism。★whole-system-first:S2 只資源型,定位/人力/設施/子目標/折現/委派=S3-S6 別提前。完成=systems+reviewer R²(非自判)→to:systems 收驗+S2 R²(★reviewer 會查 range 斷言護欄)。task=systems+reviewer。"
branch: feat/means-end-s2-resource
---

# dispatch：means-end S2 資源型 resolver（第一個實質 slice）

架構 spec **R①R② 全 CLEAN、S1 骨架已 merged**。S2 = goal frontier **資源型** resolution 接通（byte-identical 打破＝開始有行為，但只資源型；定位/人力/設施 stub）。

## ★★base 鐵律
- off **LOCAL main HEAD `96d2f083`**（含 S1 merge）非 origin（~90+ commits local-ahead 未 push）。

## 修（照 spec 組件 A/B/C/E + F 護欄）
1. **★最小 goal 生成**（組件 A，S2 版；S7 才做 util-門檻掛退 cadence 泛化）：每隊冪等確保 `goal_state` 含 5 個資源維持 goal——`maintain_food / maintain_material / maintain_tools / maintain_weapons / maintain_coin`，`active` when `holding < target`。
2. **GoalRegistry**（組件 B）填這 5 個 goal 的 resource 前置：`{kind:"resource", res:<res>, qty:<need>}`（qty 走 NeedOracle `need_keep` 通用）。
3. **★NeedOracle 泛化**（組件 E）：脫 `CONSTRUCTION_COST_RES=["material","tools"]` 硬 scope → 資源型前置 qty 用**通用 `need_keep`**（任 res 非只 material/tools）；re-entrancy guard 精神保留。
4. **`GoalResolver.frontier_candidates`**（組件 C，取代 S1 stub）實作**資源型**：walk `goal_state` active goal → walk prereqs → resource 前置查 `holding vs qty`，未滿 → 生「取得 res」candidate；取得手段 S2 先接**「買」**（既有 買糧 `options:243` / 買料 `:259` 的 to_task，市場取得不需定位）；★**採（需 forest 定位）/ 產（需設施）= 定位/設施前置 S2 回無 candidate**（S3/S4）。
5. **★must-fix① util 護欄**（組件 G/§8，**首上場硬做非留 plan**）：`candidate.util = payoff_base × dev_urgency_coeff(ctx)`〔鏡射 `NeedHierarchy.consistency_coeff`，絕境 `food_days→0` 係數 →0〕**+ clamp 上界 < `SURVIVAL_BOOST_FLOOR` 對應 survival 保底**（硬保證 goal candidate 永不蓋 survival）；折現（延遲）S6 才加，S2 util 即時取得無延遲折。

## TDD
1. resolver 資源型 candidate 真出現（缺 res 隊生取得 candidate）。
2. NeedOracle 泛化（非 material/tools 的 res 也算 need）。
3. 定位/人力/設施前置 S2 回無 candidate（stub 邊界）。
4. ★★**must-fix① 合成 range 斷言**（unit，絕境合成 ctx `food_days→0`：任意 payoff 的 resource candidate util < survival-boosted static option util ＝護欄硬迴歸，**reviewer 指定 S2 回歸點別漏**）。
5. **determinism 2 跑 byte-identical**（resolver 純讀狀態 + NeedOracle 禁 randf）。

## 閘
- `constitution_gate` PASS（GoalResolver **讀 belief 非 god-view**；禁 RNG）+ headless 0 new + determinism。

## 完成 + 紀律
- ★**whole-system-first**：S2 **只資源型**，定位/人力/設施/子目標/折現/委派 = S3-S6 **別提前**。
- 完成 = **systems + reviewer R²**（非自判）→ `to:systems` 收驗 + S2 R²（★reviewer 會查 range 斷言護欄）。
