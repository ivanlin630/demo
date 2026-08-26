class_name TileBank

# Pattern B 所有權 banker：tile 儲量單一 owner（第3不變量「凡 state 變化必有單寫者 + 可解釋來源」）。
# 兩池同傘：
#   public_storage（公庫, capped = _get_storage_cap）── 據點戰略儲量（食/礦/馬/coin…）
#   resources（自然池, uncapped；cap 由呼叫端 resource_cap / WILD_* 各自限）── 地格天然存量
# mirror ResourceBank / AnonTreasuryBank 簽名；reason → WorldState.record_driver（driver-ledger；預設 off 零成本）。
# 純 refactor：wrapper 保原數學（呼叫端 RHS 逐位保留）→ 守恆 / clamp by construction。
#
# ── CI-scan pattern（強制閘地基，同 B 波慣例）──
#   禁新直寫 `tile.public_storage[<res>] =` / `tile.resources[<res>] =`（tile-ref 賦值）。
#   豁免：本檔自身、world_generator / game_setup（bootstrap 初始化）、player 路徑（F-P 傘：
#         player_command_system / player_api_mapper）。新 tile 儲量寫入一律經 TileBank。

# ── 公庫容量（單點；OutpostSystem._get_storage_cap / storage_cap 委派此）──
const OUTPOST_STORAGE_CAP: Dictionary = {
	# ★★★civilian 兩級由 [200, 500] → [250, 650]（spec 2026-08-26 storage-fits-own-next-step）：
	#   ★病：L1 倉容 200 < 升級全費 150 × 緩衝 1.5 = 225
	#     ⇒ 該級據點【永遠存不滿升級所需】⇒ `upgd.dispatched` 恆 0 —— 那是【尺寸沒對齊】不是平衡。
	#   ★★動 cap 不動 cost 的理由：cap 的所有 production 呼叫端都是「還能裝多少」的夾限算術，
	#     沒有一個把 cap 當【決策輸入】；而 `OUTPOST_COST` 被 founding／facility／afford 多處
	#     拿去做「蓋不蓋得起」的判斷 ⇒ 動 cost 會同時改掉三處語意。
	#   ★L3 的 1500 不動（1500 ≥ 400×1.5＝600，本來就過）。
	"civilian": [250.0, 650.0, 1500.0],
	# ⚠️★military L1 `cap 300 == 全費 200×1.5 = 300`（★餘裕 0，關係式是 `≥` 所以成立）——
	#   ★★刻意不墊高：墊高是平衡判斷，要另外過 WHAT。
	#   ★日後 military 若出現「存得到但永遠差一點」，第一個看這一格。
	"military": [300.0, 800.0, 2500.0],
}

# ★★★倉容是否裝得下「升到下一級所需的全費」——★單一真值，閘與對照組共用同一支。
#   ★不得在別處各寫一份 `cap >= cost * margin` 的邏輯（那樣兩份會各自漂）。
#   ★★對照組把引數扭曲後必須紅；★★★其中「margin × 3」那組同時在驗
#     【實作有沒有真的用上 margin】—— 若本函式退化成 `cap >= cost`，那組就不會紅而閘看起來仍綠。
static func storage_fits(cap_amt: float, cost_amt: float, margin: float) -> bool:
	return cap_amt >= cost_amt * margin
const MOUNT_STORAGE_CAP: Array = [10.0, 30.0, 80.0]
# 食物公庫專屬容量（比通用大 → 避免定居隊數天餓死）。
const FOOD_STORAGE_CAP: Dictionary = {
	"civilian": [2000.0, 6000.0, 18000.0],
	"military": [1500.0, 4500.0, 12000.0],
}

static func cap(tile: HexTileData, res: String) -> float:
	if res == "mounts" or res == "horses":
		return MOUNT_STORAGE_CAP[clampi(tile.outpost_level - 1, 0, 2)]
	if res == "food":
		var farr: Array = FOOD_STORAGE_CAP.get(tile.outpost_type, [2000.0, 6000.0, 18000.0])
		return float(farr[clampi(tile.outpost_level - 1, 0, 2)])
	var arr: Array = OUTPOST_STORAGE_CAP.get(tile.outpost_type, [100.0, 300.0, 800.0])
	return float(arr[clampi(tile.outpost_level - 1, 0, 2)])

# ── 公庫 public_storage ──
static func get_stored(tile: HexTileData, res: String) -> float:
	return float(tile.public_storage.get(res, 0))

# 原始 set（呼叫端已算好目標值，含已 clamp / 已扣的結果）。delta 記絕對值（同 ResourceBank.set_amt 慣例）。
static func set_amt(tile: HexTileData, res: String, amt: float, reason: String) -> void:
	tile.public_storage[res] = amt
	WorldState.record_driver(tile, res, amt, reason, "resource")

# capped add（cap 單點）→ 回實際入庫量。溢出 = sink（呼叫端另處理殘量：私產留 / 落地面）。
static func deposit(tile: HexTileData, res: String, amt: float, reason: String) -> float:
	var cur: float = float(tile.public_storage.get(res, 0))
	var newv: float = minf(cur + amt, cap(tile, res))
	tile.public_storage[res] = newv
	WorldState.record_driver(tile, res, newv - cur, reason, "resource")
	return newv - cur

# clamp 到現量的提領 → 回實際取出量。
static func withdraw(tile: HexTileData, res: String, amt: float, reason: String) -> float:
	var cur: float = float(tile.public_storage.get(res, 0))
	var m: float = clampf(amt, 0.0, cur)
	tile.public_storage[res] = cur - m
	WorldState.record_driver(tile, res, -m, reason, "resource")
	return m

# ── 自然池 tile.resources（uncapped；cap 由呼叫端各自套 resource_cap / WILD_*）──
static func pool_get(tile: HexTileData, res: String) -> float:
	return float(tile.resources.get(res, 0))

static func pool_set(tile: HexTileData, res: String, amt: float, reason: String) -> void:
	tile.resources[res] = amt
	WorldState.record_driver(tile, res, amt, reason, "resource")

static func pool_add(tile: HexTileData, res: String, amt: float, reason: String) -> void:
	tile.resources[res] = float(tile.resources.get(res, 0)) + amt
	WorldState.record_driver(tile, res, amt, reason, "resource")
