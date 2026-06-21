# is_merchant 貿易 gate → 軟權重 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 把貿易 option 的 `is_merchant` 硬 gate 改成軟權重（生產隊能 roam-trade 但很少），清藍圖 gate 債第一條。

**Architecture:** `options.gd` 貿易 applicable 去 is_merchant 守衛；`terms.gd` economic_opp eval 乘角色因子（非商隊 ×0.3）。商隊不變。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `headless_test.gd` + `world_sim.gd`。

## Global Constraints
- wrapper 跑 Godot：`.\tools\godot.ps1 --headless --script <path>`（UTF-8）。
- 商隊（is_merchant）行為零變（因子 1.0）→ TC1/4/6/7 原樣。
- 不碰守恆 → coin_eq/InvariantAudit 0。
- TEST VALUE `NON_MERCHANT_TRADE_FACTOR=0.3`。

---

### Task 1: 貿易 gate→軟權重 + 測試更新

**Files:**
- Modify: `scripts/simulation/decision/options.gd`（貿易 applicable）
- Modify: `scripts/simulation/decision/terms.gd`（economic_opp eval ×因子 + const）
- Test: `scripts/debug/headless_test.gd`（改 `_test_role_applicable` + 加 `_test_merchant_gate_weight`）

**Interfaces:**
- Consumes: `DecisionContext.is_merchant`/`has_goods`/`has_arb`、`DecisionTerms.eval`、`DecisionOptions.applicable`。
- Produces: 貿易 applicable 不再 gate is_merchant；economic_opp 對非商隊 ×0.3。

- [ ] **Step 1: 改測試（契約更新）+ 加新測**

`scripts/debug/headless_test.gd`：找 `_test_role_applicable`（sub-project A），把「生產隊不 roam-trade(無貿易候選)」那段斷言改為「貿易入候選但 util 低」：
- 原（約）：`assert("貿易" not in ap, "生產隊不 roam-trade...")` → 改為：
```gdscript
	assert("貿易" in ap, "gate→權重後生產隊貿易應入候選(軟壓非禁)，實際=%s" % str(ap))
```
（同函式其餘斷言：生產隊有 生產/駐守/建設 維持。）

加新測（放 `_test_role_applicable` 後，註冊 dispatch）：
```gdscript
func _test_merchant_gate_weight() -> void:
	print("--- 貿易 gate→軟權重(生產隊能但很少) ---")
	# 生產隊(非商隊)有貨 → 貿易入候選，但 economic_opp < 商隊(×0.3)
	var c_pro := DecisionContext.new(); c_pro.is_merchant = false; c_pro.has_goods = true; c_pro.has_arb = true
	var c_mer := DecisionContext.new(); c_mer.is_merchant = true; c_mer.has_goods = true; c_mer.has_arb = true
	var e_pro: float = DecisionTerms.eval("economic_opp", c_pro, "貿易")
	var e_mer: float = DecisionTerms.eval("economic_opp", c_mer, "貿易")
	assert(e_pro > 0.0, "生產隊 economic_opp 應 >0(能 trade)")
	assert(e_pro < e_mer, "生產隊 economic_opp 應 < 商隊(軟壓)，pro=%.2f mer=%.2f" % [e_pro, e_mer])
	assert(abs(e_pro - e_mer * 0.3) < 0.01, "非商隊應 ×0.3，pro=%.2f mer=%.2f" % [e_pro, e_mer])
	print("merchant gate→weight OK")
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — 改後的 `_test_role_applicable`「貿易 in ap」失敗（現仍 gate is_merchant→生產隊無貿易候選）；`_test_merchant_gate_weight` 的 `e_pro < e_mer` 失敗（現 economic_opp 無角色因子，pro==mer）。

- [ ] **Step 3: 改 options.gd 貿易 applicable**

`scripts/simulation/decision/options.gd` 貿易 case：
```gdscript
			"貿易":
				# roam-trade：商隊主力；生產隊也可(軟壓低 via economic_opp 角色因子,非禁)。
				if ctx.has_goods or ctx.has_arb: out.append(opt)
```

- [ ] **Step 4: 改 terms.gd economic_opp + const**

`scripts/simulation/decision/terms.gd`：const 區加：
```gdscript
const NON_MERCHANT_TRADE_FACTOR: float = 0.3   # TEST VALUE：非商隊 roam-trade 軟壓(能但很少)
```
`economic_opp` eval 改：
```gdscript
		"economic_opp":
			if opt != "貿易": return 0.0
			var role: float = 1.0 if ctx.is_merchant else NON_MERCHANT_TRADE_FACTOR
			return (0.8 if ctx.has_goods else 0.2) * (1.0 if ctx.has_arb else 0.3) * role
```

- [ ] **Step 5: 跑測試確認通過（含回歸）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `merchant gate→weight OK` + `role applicable OK`(改後) + TC1/4/6/7 原樣全綠（商隊因子 1.0）+ survival 切片測 + 既有測全綠；`=== DONE ===`、coin_eq/InvariantAudit 0。

- [ ] **Step 6: Commit**

```bash
git add scripts/simulation/decision/ scripts/debug/headless_test.gd
git commit -m "feat(decision): 貿易 is_merchant gate→軟權重(生產隊能roam-trade但很少,清gate債)"
```

---

### Task 2: 2 年 world_sim 驗履約不退 + 回歸

**Files:** Verify only：`world_sim.gd`、`headless_test.gd`

- [ ] **Step 1: 跑 2 年 world_sim**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
記 `[ProbeSummary]`：`order_fulfilled`、`restock_chosen`、`engine_survival`、`[Market]成交`。

- [ ] **Step 2: 判定履約不顯著退**

- 對照切片後基準（order_fulfilled/restock_chosen 為 unseeded 變異 → 看量級不崩、成交仍常態、生產隊未大批棄 outpost roam-trade）。
- 若 `order_fulfilled`/成交 顯著退（生產隊大批 roam-trade 破 co-location）→ Step 3。

- [ ] **Step 3: 診斷（僅退時，measure-first）**

trace 一支 `TAG_PRODUCE` 隊：是否頻繁 task=貿易 離 outpost？若是 → NON_MERCHANT_TRADE_FACTOR 太高，調低（如 0.15）重跑；仍退 → 回報 systems/藍圖（可能需更強壓制或結構考量）。

- [ ] **Step 4: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠 `=== DONE ===`；coin_eq/InvariantAudit 0。

- [ ] **Step 5: Commit（若調因子才有 code 改，否則寫 handback）**

```bash
git add scripts/simulation/decision/terms.gd scripts/debug/headless_test.gd
git commit -m "test(decision): gate→權重 2年world_sim 履約不退驗收"
```

---

## 完成後
子 session handback：economic_opp 角色因子值、2 年 world_sim 履約對照、生產隊 roam-trade 頻率（是否「很少」=符藍圖守則）、回歸結果。

## Self-Review
- Spec coverage：貿易去 gate=Task1 Step3；economic_opp ×因子=Step4；測試契約更新=Step1；2年sim 履約=Task2。全覆蓋。
- Placeholder：無。
- Type consistency：`NON_MERCHANT_TRADE_FACTOR: float`；`economic_opp` eval 簽名不變（×role）；`_test_role_applicable` 改斷言。
