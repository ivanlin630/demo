# G1a 鑄幣觀測 + W8 驗證 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 鑄幣**機制已存在**（`OutpostSystem._tick_mint` ore→coin，用 GOLD_TO_COIN_RATIO，守恆正確），但**無 log → 無法觀測「coin 被鑄」**（藍圖 §12 驗收項）。加 mint log + 端到端守恆測試證機制運作，據結果更正 W8 文件狀態。

**Architecture:** 不改鑄幣邏輯（已對、已守恆）。只加觀測 log + 測試 + 文件更正。若測試證機制 OK 但實機 sim 鑄幣罕見 → 屬建造/經濟平衡（另案），非機制 bug。

**Tech Stack:** Godot 4.2.2 GDScript；headless harness。

## Global Constraints

- wrapper 跑測試。新 `_test_*` 註冊 `_initialize()`。
- **不改鑄幣守恆邏輯**（`_tick_mint` 用 `GOLD_TO_COIN_RATIO=20`/`SILVER_TO_COIN_RATIO=5`，與 coin_eq 同 const）。
- 回歸閘：`=== DONE ===` + 0 assert fail + **coin_eq delta=0**（鑄幣守恆硬閘）+ InvariantAudit 0。
- 來源：known_issues W8；藍圖 G1 spec §6/§12；HOW `g1-supply-chain-how-design` §3。

## File Structure

- `scripts/simulation/outpost_system.gd`（`_tick_mint` 加 log）。
- `scripts/debug/headless_test.gd`（端到端鑄幣守恆測試）。
- `docs/known_issues.md`（W8 狀態更正）。

---

### Task 1: mint log + 端到端守恆測試

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`（`_tick_mint` :207-226，加 print）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `_tick_mint` 鑄出 coin>0 時 print `[Mint] tile(x,y) ore→coin +N`（觀測藍圖 §12「coin 被鑄 Δ>0」）。邏輯不變。

- [ ] **Step 1: 寫失敗測試**

加到 `scripts/debug/headless_test.gd`：

```gdscript
func _test_mint_conserving() -> void:
	print("--- G1a：鑄幣端到端守恆 ---")
	var os := OutpostSystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4)
	tile.mint_level = 1
	tile.public_storage = {"ore_gold": 10.0, "ore_silver": 20.0, "coin": 0.0}
	s.world.tiles[tile.tile_id] = tile
	# 鑄幣前 coin_eq（ore + coin 同口徑）
	var ore_g0: float = float(tile.public_storage["ore_gold"])
	var ore_s0: float = float(tile.public_storage["ore_silver"])
	var coin0: float = float(tile.public_storage["coin"])
	var eq_before: float = ore_g0 * OutpostSystem.GOLD_TO_COIN_RATIO + ore_s0 * OutpostSystem.SILVER_TO_COIN_RATIO + coin0
	os._tick_mint(s, tile, null)
	var eq_after: float = float(tile.public_storage.get("ore_gold",0)) * OutpostSystem.GOLD_TO_COIN_RATIO \
		+ float(tile.public_storage.get("ore_silver",0)) * OutpostSystem.SILVER_TO_COIN_RATIO \
		+ float(tile.public_storage.get("coin",0))
	assert(float(tile.public_storage.get("coin",0)) > coin0, "應鑄出 coin")
	assert(abs(eq_after - eq_before) < 0.01, "鑄幣守恆 eq before=%.2f after=%.2f" % [eq_before, eq_after])
	print("mint conserving OK")
```

`_initialize()` 加 `_test_mint_conserving()`。

- [ ] **Step 2: 跑 harness 驗證（測試應已過——機制存在；若 log 未加則僅缺觀測）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `mint conserving OK`（機制本就守恆）。若 fail → 鑄幣邏輯有未知 bug，停查（非預期）。

- [ ] **Step 3: 加 mint log**

`scripts/simulation/outpost_system.gd` `_tick_mint`，在 coin 加入後（gold/silver 兩段各自或合計後）加觀測 print。例（合計後）：

```gdscript
	# 在 _tick_mint 末尾，若本次有鑄出
	# （依現碼結構：gold 段 coin_added、silver 段 coin_added；可各 print 或累計）
	# 範例：silver 段後加總印
	if coin_added > 0.0:
		print("[Mint] tile(%d,%d) +%.1f coin (mint_lv=%d)" % [
			tile.tile_pos.x, tile.tile_pos.y, coin_added, tile.mint_level])
```

> 依 `_tick_mint` 實際變數作用域插入；gold/silver 兩段若各有 `coin_added`，各印或先累計再印一次。不改轉換邏輯。

- [ ] **Step 4: 跑 harness 驗證通過**

Expected: `mint conserving OK`、`=== DONE ===`、coin_eq 守恆、InvariantAudit 0。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/outpost_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g1a): mint 鑄幣觀測 log + 端到端守恆測試(W8 機制驗證)"
```

---

### Task 2: W8 文件狀態更正

**Files:**
- Modify: `docs/known_issues.md`

- [ ] **Step 1: 更正 W8**

`docs/known_issues.md` W8 條：鑄幣**機制已完整存在**（world_gen 放金銀礦 → resource_system harvest 進 public_storage → `OutpostSystem._tick_mint` ore→coin 守恆轉換 → `tick_all` 已 wired），`_test_mint_conserving` 證守恆。原「鑄幣廠從沒用」= 無 log 致無法觀測的錯覺 / 或實機建造罕見（屬經濟平衡，非機制缺）。標：機制 ✅、實機鑄幣頻率 = 平衡/G1c 需求驅動後觀察。

- [ ] **Step 2: Commit**

```bash
git add docs/known_issues.md
git commit -m "docs(g1a): W8 鑄幣機制 ✅ 已存在(加 log 驗證);更正 stale 描述"
```

---

## Self-Review 註記

- **非實作鑄幣**：機制（`_tick_mint`）早存在且守恆；本 plan = 觀測 log + 守恆測試 + 文件更正（verify-backlog-fresh，同 B-1）。
- **守恆**：測試用 `GOLD_TO_COIN_RATIO`/`SILVER_TO_COIN_RATIO`（coin_eq 同 const）算 eq，證 delta=0。
- **OUT**：鑄幣建造頻率/經濟平衡（mints 實機是否常蓋）= 另案；需求驅動鑄幣 = G1c 後。不在此。
- **執行確認**：`_tick_mint` 的 `coin_added` 變數作用域（gold/silver 兩段），log 插入點對齊。
