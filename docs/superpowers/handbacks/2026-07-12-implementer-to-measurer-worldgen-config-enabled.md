---
from: implementer
to: measurer
status: consumed
topic: [§2/§3 啟用] default.json 移除顯設→seeded range 觸發 → 跨 seed 變測 + 重 baseline（併前 done 信）
---

# world-gen §2/§3 config 啟用 done（@40bb665 feat/worldgen-variety）

接前 `worldgen-variety-done` 信。§2/§3 range 之前只在無顯設觸發，default.json 釘死擋住。現移除：

## 改
- `config/default.json`：移除 `outposts.total_count`(14)/`factions.count`(3)/`factions.weights`([3,2,1])。
  → §2 觸發：據點數 rng.randi_range(8,14)(硬上限=地圖 tile×0.25)、勢力數 rng.randi_range(2,4)、weights code 自生 seeded(size 0<fcount→regenerate,無截斷)。§3 地板守。
- **控制 config 不動**（warring_states/tyrant/warzone 顯設保留=量測隔離基線，blueprint 裁）。

## 我驗
- JSON valid、`--import`/multi-sanity(coin_eq/inv=0)綠、default.json 世界生成無崩。
- weights 自生機制確認：weights=[](移除)→size 0<fcount→每 faction rng.randi_range(1,4) seeded 自生，count 2-4 皆對得上、無截斷/error。

## ★待你（default.json 上跑，非 warring 控制 config）
1. **§2/§3 跨 seed 真變**：default.json 多 seed → 據點數(8-14 內)+勢力數(2-4 內)**每 seed 不同分布**（非固定 14/3）。
2. **全域地板守**（放野退化不破：覆蓋/每勢力≥1）+ 硬上限留空地 + build-outpost fire。
3. **determinism byte-identical**（同 seed default.json）。
4. §4 重 baseline（世界結構變，一次性重生標位移）。

## 註
- **headless_test 有 FAIL**（`弱目標未加入攻擊 goal` :3180 等）——查證為 **hand-constructed 場景**（state.teams[80/81] 手建，world-gen-independent），**pre-existing 非本改**。gate 測（coin_eq/inv=0/constitution/determinism/build_outpost）全綠。若你要我一併查 headless_test pre-existing FAIL 標回 systems。
- config + §1~3 code 一起在 worktree @40bb665，merge 一起入 main。

merge 閘=reviewer diff R² + 你全 gate（determinism/地板/build-outpost/§2跨seed變/重baseline）+ blueprint 質感。
