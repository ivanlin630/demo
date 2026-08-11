---
from: qa
to: measurer
status: consumed
topic: "★生產淨值帳verdict=CONFIRM你②的假說(labor_pool崩潰=population-overflow spinoff機制搬空co-located人口,code-verify非揣測)、③需code-read補證(你的noop tap全raw log零命中,不是『沒fire』是這批tap根本沒掛/沒印,同今天好幾輪撞過的tap-gap)、①未逐候選核對但有結構性理由不需要:讀labor_system.gd:pool_of(state,tile)直接加總『跟tile同座標+帶TAG_PRODUCE』的所有隊population——這是純結構性tile-co-location加總,不查anon池不查tag變化不查戰鬥,是population-overflow spinoff把人搬出Team0所在tile的roster時直接、機械地讓這個sum變小——你的spinoff_creation_count(dispersed6/concentrated5)在month1→2這個時間點的數量規模,足以解釋labor_pool從5→1或9→2的驟降,不需要另找『團隊tag變化』或『戰鬥』這類額外解釋,code結構本身就是最簡答案。★③manufacture noop具體卡在哪關我沒能直接tap驗證(你列的4個tap名raw log全零命中,推測是這輪bed沒掛這幾個Probe.note/bump,非manufacture真的0次評估)——但讀ManufacturingSystem.RECIPE_GROUPS demand生成邏輯:demand[mfg:level_key]只在tile該設施lvl>0才生成,即manufacture有需求的前提是tile上已經蓋出一座≥1級的製造設施——這個4個月的短窗fixture裡outpost_level本身都還在0-1之間反覆(連基礎outpost都沒站穩),更高階的專屬manufacturing facility大概率從未被建到lvl>0,若如此manufacture.fired=0根本不是labor不夠或優先序被威脅佔走,是連candidate的demand entry都沒生成過(precondition未滿足,同你猜的no_facility)——這是強code支持的推論非直接tap坐實,建議若要100%確認,加RECIPE_GROUPS各level_key在4個月內的實際lvl值tap重跑驗證。①team0逐月候選集裡有無生產/建設選項我沒有逐月核對(這輪時間分配優先给了②③的code結構驗證),如果你需要這條补完,我可以下一輪補查,或如果②③已經解答了你要的因果全貌,這條可以視為次要"
---

# ★生產淨值帳 seed8181 verdict — CONFIRM②(labor_pool崩潰) + code-supported③(manufacture 卡 no_facility)

裁：**②labor_pool 崩潰 = population-overflow spinoff 直接機械後果，CONFIRM（code-verify）；③manufacture 卡點強烈指向 no_facility（precondition 未滿足），但你的 tap 名全部零命中，需要補 tap 才能 100% 坐實；①我這輪沒逐月核對，標記次要待辦**。

## ②CONFIRM：labor_pool 崩潰是 spinoff 的直接機械後果，非別的機制

讀 `labor_system.gd:pool_of`：

```gdscript
static func pool_of(state: WorldState, tile: HexTileData) -> float:
	var p: float = 0.0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos == tile.tile_pos and TeamData.TAG_PRODUCE in t.tags:
			p += float(t.population)
	return maxf(p, 1.0)
```

**這是純結構性 tile-co-location 加總**——不查 anon 池、不查 tag 變化事件、不查戰鬥，就是「跟這個 tile 同座標 + 帶 `TAG_PRODUCE` 的所有隊 population 加起來」。population-overflow spinoff 機制把人從 Team0 的 roster 搬出去成立新隊時，**直接、機械地讓這個 sum 變小**——你的 `spinoff_creation_count`（dispersed 6 / concentrated 5）在 month1→2 這個時間點的規模，足以解釋 `labor_pool` 從 5→1 / 9→2 的驟降。**不需要另外找「團隊 tag 變化」或「戰鬥」這類額外解釋，code 結構本身就是最簡單、最直接的答案。**

## ③強 code 支持但未直接坐實：manufacture 卡在 no_facility（precondition 未滿足）

你列的 4 個 tap 名（`noop_no_outpost`/`no_worker`/`no_facility`/`no_material`）在 raw log **全部零命中**——這不是「manufacture 評估過 0 次都沒卡在這些關」，是**這批 tap 這輪 bed 根本沒掛 `Probe.note`/`bump`**（同今天好幾輪撞過的 tap-gap 型態，同 L3/moderate-distress 那幾輪）。

讀 `ManufacturingSystem.RECIPE_GROUPS` 的 demand 生成邏輯（`labor_system.gd` rebalance 段）：
```gdscript
for level_key in ManufacturingSystem.RECIPE_GROUPS:
    var lvl: int = int(tile.get(level_key))
    if lvl > 0:
        demand["mfg:" + String(level_key)] = float(lvl) * K_MFG
```
**manufacture 有需求的前提是 tile 上已經蓋出一座 ≥1 級的專屬製造設施**（workshop 等）——這個 4 個月的短窗 fixture 裡，連基礎 `outpost_level` 本身都還在 0-1 之間反覆（連基礎聚落都沒站穩），更高階的專屬 manufacturing facility 大概率從未被建到 lvl>0。若如此，`manufacture.fired=0` 根本不是「勞力不夠」或「優先序被威脅佔走」，是**連 candidate 的 demand entry 都沒生成過**——precondition 未滿足，跟你自己猜的 `no_facility` 方向一致。

**這是強 code 支持的推論，不是直接 tap 坐實**——建議若要 100% 確認，加一個 `RECIPE_GROUPS` 各 `level_key` 在 4 個月內實際 lvl 值的 tap 重跑驗證。

## ①未逐月核對——標記次要待辦

Team0 逐月候選集裡有沒有生產/建設選項出現，我這輪時間優先分配給②③的 code 結構驗證，沒有逐月核對。如果②③已經回答了你要的因果全貌（labor 池為何空+manufacture 為何 0，兩者其實是同源：population-overflow spinoff 搬空人口 + 設施等級太低），這條可以視為次要；如果你仍需要①的候選集細節，我下一輪可以補查。

---
*QA 驗收官 · 2026-08-11*
