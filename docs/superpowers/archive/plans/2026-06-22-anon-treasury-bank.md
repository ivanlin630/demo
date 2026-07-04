# anon_treasury banker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** anon_treasury 設單一 owner（AnonTreasuryBank，原子 transfer/transfer_all=守恆 by construction），24 寫者路由，coin_eq 必綠（清 Pattern B 第三池）。

**Architecture:** 承 banker 模式。deposit/withdraw/transfer/transfer_all/reset。配對 += / =0 → 原子 transfer/transfer_all。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `headless_test.gd` + `world_sim.gd`。

## Global Constraints
- wrapper 跑 Godot（UTF-8）；子 session 每次 Godot run 前 `Set-Location` 進 worktree。
- **coin 守恆硬閘**：coin_eq/CoinAudit 必綠不變（最關鍵驗收）。
- 行為保留（同 coin 流）；transfer/transfer_all clamp min(amt,bal) 不透支。
- InvariantAudit 0。

---

### Task 1: AnonTreasuryBank + 路由全寫者

**Files:**
- Create: `scripts/simulation/anon_treasury_bank.gd`
- Modify: 24 寫者（grep 定位，8 檔）
- Test: `scripts/debug/headless_test.gd`（加 `_test_anon_treasury_bank`，註冊）

**Interfaces:**
- Produces: `AnonTreasuryBank.deposit(team,amt,reason)`、`withdraw(team,amt,reason)->float`、`transfer(src,dst,amt,reason)`、`transfer_all(src,dst,reason)`、`reset(team,reason)`（static）。

- [ ] **Step 1: 寫失敗測試**

`headless_test.gd` 加：
```gdscript
func _test_anon_treasury_bank() -> void:
	print("--- AnonTreasuryBank 守恆 banker ---")
	var a := TeamData.new(); a.anon_treasury = 100.0
	var b := TeamData.new(); b.anon_treasury = 30.0
	AnonTreasuryBank.deposit(a, 50.0, "salary")
	assert(abs(a.anon_treasury - 150.0) < 0.001, "deposit →150")
	var got: float = AnonTreasuryBank.withdraw(a, 40.0, "extract")
	assert(abs(got - 40.0) < 0.001 and abs(a.anon_treasury - 110.0) < 0.001, "withdraw 40 →110")
	# 守恆：transfer 總和不變
	var before: float = a.anon_treasury + b.anon_treasury
	AnonTreasuryBank.transfer(a, b, 60.0, "share")
	assert(abs((a.anon_treasury + b.anon_treasury) - before) < 0.001, "transfer 守恆(總和不變)")
	assert(abs(b.anon_treasury - 90.0) < 0.001, "b 收 60 →90")
	# transfer_all：全移
	AnonTreasuryBank.transfer_all(a, b, "absorb")
	assert(a.anon_treasury == 0.0, "transfer_all src→0")
	# withdraw 不透支
	var c := TeamData.new(); c.anon_treasury = 10.0
	var g2: float = AnonTreasuryBank.withdraw(c, 999.0, "x")
	assert(abs(g2 - 10.0) < 0.001 and c.anon_treasury == 0.0, "withdraw clamp min(amt,bal)")
	print("anon treasury bank OK")
```
註冊。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `AnonTreasuryBank` 不存在。

- [ ] **Step 3: 建 AnonTreasuryBank**

`scripts/simulation/anon_treasury_bank.gd`：
```gdscript
class_name AnonTreasuryBank

# Pattern B 所有權 banker：anon_treasury(隊公庫 coin)單一 owner。
# transfer/transfer_all 原子 → 守恆 by construction(優於分離 += / =0)。
static func deposit(team: TeamData, amt: float, reason: String = "") -> void:
	team.anon_treasury += maxf(amt, 0.0)

static func withdraw(team: TeamData, amt: float, reason: String = "") -> float:
	var m: float = clampf(amt, 0.0, team.anon_treasury)
	team.anon_treasury -= m
	return m

static func transfer(src: TeamData, dst: TeamData, amt: float, reason: String = "") -> void:
	var m: float = clampf(amt, 0.0, src.anon_treasury)
	src.anon_treasury -= m
	dst.anon_treasury += m

static func transfer_all(src: TeamData, dst: TeamData, reason: String = "") -> void:
	dst.anon_treasury += src.anon_treasury
	src.anon_treasury = 0.0

static func reset(team: TeamData, reason: String = "") -> void:
	team.anon_treasury = 0.0
	Probe.bump("g1.treasury_reset")
```

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `anon treasury bank OK`。

- [ ] **Step 5: 路由全寫者（grep `anon_treasury\s*(=|+=|-=)` over scripts/simulation/**）**

每處先讀上下文判 deposit/withdraw/transfer/transfer_all/reset：
- `salary_system.gd:76`(+=anon_paid) / `player_command_system.gd:189`(+=TRAIN) / `anon_tier_system.gd:240`(+=amt) / `movement_system.gd:233`(+=abandoned_coin) → `deposit`。
- `faction_ai_system.gd:1390`(-=amt extract) / `person_generator.gd:100`(-=bonus) → `withdraw`。
- `player_command_system.gd:1145-1146`(tgt-=share; pt+=share) / `encounter_system.gd:1132-1133`(loser-=amt; winner+=amt) / `subteam_system.gd:91-92`(absorber+=; absorbed-=) → `transfer`。
- `encounter_system.gd:1127-1128 / 1136-1137 / 1448-1449`(winner+=loser; loser=0) / `subteam_system.gd:99-100`(absorber+=absorbed; absorbed=0) → `transfer_all`。
- `subteam_system.gd:42-43`(sub=parent*frac; parent-=sub) → `transfer(parent, sub, parent.anon_treasury*frac)`（先算 frac 額再 transfer；注意原是先設 sub 再扣 parent → 改 transfer 後 sub 初始應為 0 再收）。
- **`faction_ai_system.gd:1456,1487`(=0 standalone) → 讀上下文**：若 coin 已先他移（如 extract 到別處 / 隊滅前已分配）→ `reset(team, reason)`；若無對應移出（憑空）→ **守恆風險,STOP 回報**（勿掩蓋；coin_eq 會驗）。

> 註：行號漂 → grep 重定位。排除 headless_test fixture。subteam split 改 transfer 時確保 sub.anon_treasury 起始 0（新建隊）→ transfer(parent,sub,額) 等價原邏輯。

- [ ] **Step 6: 跑回歸（coin 守恆硬閘）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `anon treasury bank OK` + **coin_eq/CoinAudit 守恆測全綠（最關鍵）** + 既有 encounter/subteam/salary/extract 測綠；`=== DONE ===`、InvariantAudit 0。**若 coin_eq 紅 → 某 transfer/withdraw 算錯 or standalone =0 實為 leak → 修對/回報，勿放寬。**

- [ ] **Step 7: Commit**

```bash
git add scripts/simulation/anon_treasury_bank.gd scripts/simulation/ scripts/debug/headless_test.gd
git commit -m "feat(state): AnonTreasuryBank 單一owner — anon_treasury原子transfer(Pattern B 第三池,守恆)"
```

---

### Task 2: 2 年 world_sim coin 守恆驗收 + grep + 回歸

**Files:** Verify only

- [ ] **Step 1: 跑 2 年 world_sim**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
**重點**：CoinAudit / 守恆指標 delta=0（coin 不憑空/不蒸發）、treasury 流動正常、`=== DONE ===`、InvariantAudit 0。

- [ ] **Step 2: grep 驗無裸寫**

scripts/simulation/** 無殘留裸 `anon_treasury =`/`+=`/`-=`（除 anon_treasury_bank.gd）。

- [ ] **Step 3: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠、**coin_eq 0**、InvariantAudit 0。

- [ ] **Step 4: handback**

寫 handback：AnonTreasuryBank API、路由清單（deposit/withdraw/transfer/transfer_all/reset 分類）、standalone =0 的處置（reset or leak 發現）、coin_eq 守恆證、2 年 world_sim CoinAudit、回歸。標 Pattern B 剩 resources(110 寫)/outpost_owner。

---

## 完成後
子 session handback：AnonTreasuryBank、路由、standalone =0 處置、coin 守恆證、2 年 world_sim。

## Self-Review
- Spec coverage：AnonTreasuryBank(deposit/withdraw/transfer/transfer_all/reset)=Task1 Step3；24 路由=Step5；coin 守恆驗=Task1 Step6 + Task2 Step1；grep=Task2。全覆蓋。
- Placeholder：無（行號 grep 重定位；standalone =0 條件分支=查上下文非 placeholder）。
- Type consistency：banker 5 函式簽名一致；withdraw 回 float（實扣）；transfer clamp min(amt,bal) 守恆；subteam split → transfer。
