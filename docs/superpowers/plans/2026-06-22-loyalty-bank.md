# loyalty banker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** loyalty 設單一 owner（LoyaltyBank），~25 寫者路由（adjust/set_baseline），禁裸絕對 set（清 Pattern B 第二池 loyalty，HIGH）。

**Architecture:** 承 UnrestBank 模式。LoyaltyBank.adjust(p,delta,reason,cap=1.0)（cap 保各 site clamp）+ set_baseline(p,value,reason)（lifecycle 基線）。clamp 寫者行為保留；無 clamp 寫者正確化 [0,1]（回歸驗）。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `headless_test.gd` + `world_sim.gd`。

## Global Constraints
- wrapper 跑 Godot（UTF-8）；子 session 每次 Godot run 前 `Set-Location` 進 worktree。
- 行為保留（clamp 寫者同數學+cap；salary overpay cap=MAX_LOYALTY 0.95）。
- 不碰守恆 → coin_eq/InvariantAudit 0。

---

### Task 1: LoyaltyBank + 路由全寫者

**Files:**
- Create: `scripts/simulation/loyalty_bank.gd`
- Modify: ~25 寫者（grep 定位）
- Test: `scripts/debug/headless_test.gd`（加 `_test_loyalty_bank`，註冊）

**Interfaces:**
- Produces: `LoyaltyBank.adjust(p,delta,reason,cap)`、`LoyaltyBank.set_baseline(p,value,reason)`（static）。

- [ ] **Step 1: 寫失敗測試**

`headless_test.gd` 加：
```gdscript
func _test_loyalty_bank() -> void:
	print("--- LoyaltyBank 單一 owner ---")
	var p := PersonData.new(); p.loyalty = 0.5
	LoyaltyBank.adjust(p, 0.3, "test")
	assert(abs(p.loyalty - 0.8) < 0.001, "adjust +0.3 →0.8，實際=%.3f" % p.loyalty)
	LoyaltyBank.adjust(p, 0.5, "test")
	assert(abs(p.loyalty - 1.0) < 0.001, "adjust 超 →clamp 1.0，實際=%.3f" % p.loyalty)
	LoyaltyBank.adjust(p, 0.5, "overpay", 0.95)
	assert(abs(p.loyalty - 0.95) < 0.001, "cap=0.95 →0.95，實際=%.3f" % p.loyalty)
	LoyaltyBank.adjust(p, -2.0, "test")
	assert(p.loyalty == 0.0, "adjust 大負 →clamp 0，實際=%.3f" % p.loyalty)
	LoyaltyBank.set_baseline(p, 0.25, "conquered")
	assert(abs(p.loyalty - 0.25) < 0.001, "set_baseline 0.25，實際=%.3f" % p.loyalty)
	print("loyalty bank OK")
```
註冊。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `LoyaltyBank` 不存在。

- [ ] **Step 3: 建 LoyaltyBank**

`scripts/simulation/loyalty_bank.gd`：
```gdscript
class_name LoyaltyBank

# Pattern B 所有權 banker：loyalty 單一 owner。delta 走 adjust(cap 保各 site 上限)，
# lifecycle 基線(split/defect/recruit/init)走 set_baseline(唯一蓄意絕對路徑,有 reason)。
static func adjust(p: PersonData, delta: float, reason: String = "", cap: float = 1.0) -> void:
	p.loyalty = clampf(p.loyalty + delta, 0.0, cap)

static func set_baseline(p: PersonData, value: float, reason: String = "") -> void:
	p.loyalty = clampf(value, 0.0, 1.0)
```

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `loyalty bank OK`。

- [ ] **Step 5: 路由全寫者（grep `\.loyalty\s*(=|+=|-=)` over scripts/simulation/**, 排除 headless_test fixture）**

每處（先讀上下文確認 delta/絕對 + clamp）：
- delta（`+=`/`-=`/`clampf(+d)`/`minf(+d,1)`/`maxf(-d,0)`）→ `LoyaltyBank.adjust(p, <delta>, "<reason>")`；**salary:68 overpay → `adjust(p, (ratio-1.0)*OVERPAY_BONUS, "overpay", MAX_LOYALTY)`**。
- 絕對 set：
  - `event_unrest_split.gd:122-127`（6 transfer-type 基線）→ `set_baseline(p, <值>, "<type>")`
  - `reaction_system.gd:276` `=0.0`（defect）→ `set_baseline(p, 0.0, "defect")`
  - `player_command_system.gd:1317` `=0.5` → `set_baseline(p, 0.5, "recruit")`
  - `game_setup.gd:208`(=1.0)/`485`(=cfg) / `person_generator.gd:54` / `recruit_tutorial.gd:20`（init/creation）→ `set_baseline(p, <值>, "init")`
- 具體 delta 值/reason 對齊原行（如 npc_combat:266 `-= (1.0-yi_qi)*0.05` → `adjust(p, -(1.0-yi_qi)*0.05, "betrayal")`）。**保留原運算的數值**。

> 註：行號會漂 → grep 重定位。排除 headless_test.gd 的 `p.loyalty = N` fixture（測試設定不路由）。`game_setup`/`person_generator`/`recruit_tutorial` 的 creation set 用 set_baseline（一致性；無累積 delta 可洗，行為同）。

- [ ] **Step 6: 跑回歸（行為不變）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `loyalty bank OK` + 既有 loyalty/defect/salary(超付 cap 0.95)/義氣/split 測全綠；`=== DONE ===`、coin_eq/InvariantAudit 0。**若某 loyalty 測紅：(a) clamp 差異（原無 clamp 可負而測依賴負值）→ 記錄回報 systems（可能是潛在 bug）；(b) delta/reason/cap 對錯 → 修對。勿改測試掩蓋。**

- [ ] **Step 7: Commit**

```bash
git add scripts/simulation/loyalty_bank.gd scripts/simulation/ scripts/debug/headless_test.gd
git commit -m "feat(state): LoyaltyBank 單一owner — loyalty 全寫者路由(Pattern B 第二池)"
```

---

### Task 2: 2 年 world_sim 驗收 + 回歸 + grep 驗

**Files:** Verify only

- [ ] **Step 1: 跑 2 年 world_sim**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
觀察 loyalty/defect/分裂 行為近基準、`=== DONE ===`、無異常（如大批 defect=clamp 改變）。

- [ ] **Step 2: grep 驗無裸寫**

確認 scripts/simulation/** 無殘留裸 `.loyalty =`/`+=`/`-=`（除 loyalty_bank.gd）。漏網 → 路由。

- [ ] **Step 3: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠、coin_eq/InvariantAudit 0。

- [ ] **Step 4: handback**

寫 handback：LoyaltyBank API、路由清單(含 clamp 變異處理 + 無 clamp→clamp 的 site)、grep 驗、2 年 world_sim loyalty/defect、回歸。標 Pattern B 剩 resources/anon_treasury(守恆敏感)/outpost_owner。

---

## 完成後
子 session handback：LoyaltyBank、路由完整性、無 clamp→clamp 的行為影響(若有)、2 年 world_sim、回歸。

## Self-Review
- Spec coverage：LoyaltyBank=Task1 Step3；路由=Step5；grep 驗=Task2；2yr=Task2。全覆蓋。
- Placeholder：無（行號 grep 重定位）。
- Type consistency：`adjust(p,delta,reason,cap=1.0)`/`set_baseline(p,value,reason)`；salary overpay cap=MAX_LOYALTY(0.95)；clamp [0,cap]。
