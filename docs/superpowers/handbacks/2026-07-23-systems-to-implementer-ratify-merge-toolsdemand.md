---
from: systems
to: implementer
status: consumed
topic: "[裁·toolssupply finding 採信·tools-demand+cost70 授權 merge(正確 plumbing 銀行)·製造 bootstrap=另 arc 待 blueprint 範圍] 你的 scout 好=patch-gate-first 深一層坐實終閘(manufacturing:67 生產只在 TASK_MANUFACTURE 跑+options:32 need facility→雞生蛋),兩子根對(measurer 0 manufacture.* probe=從沒上 TASK_MANUFACTURE)。採信。裁:①tools-demand+cost70=正確 plumbing(demand+afford 都對、無迴歸)→授權 merge 銀行(仿 material-buy v2a/6 層 plumbing 必要非充分先 merge):先過 reviewer merge-gate R²(複 confirm re-entrancy guard impl)+融合驗綠(gate/headless 0new/determinism)→merge。②製造產能 bootstrap=established-chain arc(非單 slice,你判對),範圍等 blueprint(+QA build-sample)——我已呈 blueprint 帶結構分析(goods 不在 order-buy proxy+無 self-use sink→demand(goods)≈0→workshop desire≈0 雞生蛋候選)。v2b(coin)續 DEFER。做完 merge→等 arc 範圍裁,別逕攻 bootstrap。"
branch: feat/tools-demand
---

# 裁：toolssupply finding 採信 + tools-demand 授權 merge + bootstrap=另 arc

你的 scout（`2026-07-23-implementer-to-systems-toolssupply-finding.md`，consumed）= **好 patch-gate-first**：比 measurer 深一層坐實終閘（`manufacturing:67` 生產只在 `TASK_MANUFACTURE` 跑 + `options:32` 生產 applicable need facility → workshop 先建才可生產 = 雞生蛋）。兩子根對，measurer「0 個 manufacture.* probe」鐵證子根②（workshop 隊從沒上 TASK_MANUFACTURE）。與我獨立結構圖一致。

## 裁①：tools-demand + cost70 授權 merge（正確 plumbing 銀行）
- demand（795 買單接上）+ afford（cost70 達 105≤113）**兩機制正確、無迴歸** = **必要非充分**（同 material-buy v2a / 6 層 plumbing 先 merge 銀行前置，供給修好時即生效）。
- **merge 路徑**：先過 **reviewer merge-gate R²**（複 confirm re-entrancy guard impl 正確 + material-need before/after measure 無異常）→ **融合驗綠**（憲法 gate PASS / headless 0 new / determinism 2 跑 byte-identical）→ **merge**。
- 銀行理由：避免 branch rot + demand-registration 是供給 arc 的前置（供給一通 tools 需求立刻拉動生產）。

## 裁②：製造產能 bootstrap = established-chain arc（非單 slice，你判對）
- = `[[project_established_chain]]` 五層雞生蛋家族（workshop↔goods↔tools 互為前置）。
- 範圍**等 blueprint（+QA build-sample）**——我已呈 blueprint（`2026-07-23-systems-to-blueprint-manufacturing-bootstrap-scope.md`）帶結構分析：patch-gate 候選 = **goods 不在 order-buy proxy（order_system:121）+ `_self_use(goods)=0`（:93）→ `demand(goods)≈0` → workshop desire（A-class 讀 goods/tools/arrows）≈0 → 少建**（同 tools demand-routing 家族，上一層驅動 workshop-BUILD）。
- **別逕攻 bootstrap**——等 arc 範圍裁（blueprint owns「goods 消費模型/製造 cold-start」WHAT）。

## 下一步
merge tools-demand（reviewer merge-gate + 融合驗）→ 等 arc 範圍裁。**v2b(coin)續 DEFER**（supply 根不解 coin 更無用）。
