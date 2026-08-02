---
from: implementer
to: measurer
status: consumed
topic: material-hold-protection — measure（脫貧第三腿·★三腿齊 端到端+守護硬迴歸）
branch: feat/material-hold-protection
commit: 1017fe31
spec: docs/superpowers/specs/2026-07-23-material-hold-protection.md
---

# material-hold-protection — 做完，量測請收（★三腿齊：食 GATE-A + coin extraction + 本刀）

## 改動（4 touch，decouple 兩 urgency）
根：`trade_valuation:94` material reserve=need_keep×_reserve_factor，`_urgency=max(food,coin)` → coin_urg(91% chronic)壓 factor → construction-material 賣掉不累積 → afford×1.5 湊不到。

- **① `_reserve_factor_food_only`**（新，`_urgency` 只用 food_urg；refactor `_food_urgency` 抽出，`_urgency` 沿用=max 不變）。
- **② `reserve(material):94`**：有 active construction-need（`_construction_facility_need>0`）→ food-only factor（對 coin_urg 免疫，守要蓋的料）；否則照舊 `×_reserve_factor`。
- **③ acute food 釋放**（★守護）：food-only factor 仍含 food_urg → `food_days<DESPERATION → food_urg↑ → factor↓ → protected material 釋放賣糧求生`=**不抱料餓死**（survival first 不變）。
- **④ `coin_need` material**：對齊 `cost×1.5 − holding`（afford×1.5，非只 need_keep shortfall）→ extraction 拉夠 coin 買足量。

## 自驗（皆綠）
- TDD `material_hold_test` **10/10**（①construction+coin 高+food OK→reserve 高不賣 ②★acute food→reserve 降可賣[守護硬驗餓隊能賣] ③非-construction 照舊 ④coin_need=cost×1.5-holding ⑤守恆 ⑥decouple food-only coin 免疫 vs max 受 coin）。RED：②reserve gate→用 max coin 壓 / ④1.5→1.0 coin_need 20≠120。
- headless 0-new（3 baseline）。
- gate PASS sites=74（material-hold 加 **0 新閘**；trade_valuation 非 decision-file；removed=1 是**繼承 extraction de-patch** 非本刀，systems merge 統一更新 baseline）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `d1071c59`（純算術/urgency 讀狀態無 randf）。

## 量測請抓（spec §驗收，★三腿齊=extraction merged+GATE-A+本刀）
1. **construction-material 累積**（賣壓降 / material holding 升）。
2. **afford×1.5 達成率升**。
3. **★facility 建成端到端升**（blueprint 判準：三腿齊 facility 升=成功、不升=還有漏）。
4. **coin_urg / material reserve 分布**（construction-material reserve 不再被 coin 壓）。
5. **★★守護硬迴歸**：**有沒有隊抱著 protected material 餓死**（acute food 隊 protected material 有無釋放；QA 故事稽核必查）。
6. **無新餓死 total**。
7. §④b sample + specimen → QA（貪婪 vs 慎重 texture）。

床：`godot --path .worktrees/material-hold` 對 branch 1017fe31 跑（★禁原地 checkout）。
base=extraction merge 後 main 347a336b（含 coin 腿）。

## 完成判定 = systems + reviewer（merge-gate R²）。做完 → to:QA 判故事：
committed 想蓋隊守住料熬過 coin 焦慮→買齊→建成 coherent；★acute 餓隊仍賣料求生**不抱料餓死**（守護）；貪婪 vs 慎重 texture。
**★脫貧三腿齊**——若 facility 端到端仍不升=還有漏（blueprint 判下一根）。generalize（means-end committed 資源）先 scoped material。
