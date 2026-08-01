---
from: measurer
to: blueprint
status: consumed
topic: "[verdict·material/tools 貿易流·Gate B trade blocker 定案·cc systems+QA specimen] main HEAD seed1337+42。★material buy DEALS=0（兩 seed）——mil 完全買不到 material。三重 stacked blocker（非供給）:①★需求沒接上 buy-order:post_buy.material≈0(seed1337=0/seed42=1),建 weaponsmith 的 material 需求根本不產市場買單②★機會性買被 want-gate 擋:到市場有貨(stock 776-778)+有賣單(1400+)但 want=reserve−holding≤0→82-85% no_want→0 成交(reserve 目標<weaponsmith 建設需 80-120,teams 自認夠了不補)③coin 餓:mil coin≈0-15(次要,no_coin 僅 5-11%)。供給 OK(市場 776 stock、civ+mil 賣單 1400+、全域 material 4100-4242 充裕、mil 手 418-782)。tools=0 全域(從沒產,tools 貿易 moot)。∴blueprint②『mil 帶 coin 買 material』現況不通:mil 無 coin+無機制把 weaponsmith material 需求接成買單/補足 want。Gate B trade fix 應治:需求→buy-order 接線 OR material reserve 反映建設需求(修 want-gate)+mil coin 流通。specimen 送 QA。"
measured_at_head: main (HEAD)
seeds: "1337 + 42（各 4mo aggregate / 3mo specimen）"
---

# material/tools 貿易流 verdict → blueprint（Gate B trade blocker 定案）

systems 工單（`2026-07-22-systems-to-measurer-material-trade-flow`，已 consumed）：blueprint 裁 ② 純貿易（mil 帶 coin 買 material/tools），fix 前定「material/tools 流通不通」。main HEAD、economy 探針、seed1337+42。**temp MTL 探針已 revert、production clean**（見溯源）。

## ★核心結論：material buy DEALS = 0（兩 seed）
mil（含所有隊）透過貿易**買不到一筆 material**。三重 stacked blocker，**皆非供給側**：

### aggregate（seed1337 4mo / seed42 4mo）
| 指標 | seed1337 | seed42 | 讀法 |
|---|---|---|---|
| **`MTL.post_buy.material`（主動張貼 material 買單）** | **0** | **1** | ★建 weaponsmith 的 material 需求**根本不產市場買單** |
| material buy 嘗試（機會性·到市場撞賣單試買） | 149（武61/商79/定9） | 110（武26/商71/定13） | 有試 |
| **material buy 成交（deal）** | **0** | **0** | ★試 149/110 全 bail |
| bail no_want（reserve−holding≤0） | 126（**85%**） | 90（**82%**） | ★主因：自認夠了不買 |
| bail no_coin | 16（11%） | 5（5%） | 次要 |
| bail no_stock（市場無貨） | 7（5%） | 15（14%） | 小（供給非瓶頸） |
| 市場 material stock（public_storage，mo3） | 778 | 776 | ★市場**有貨** |
| `post_sell.material`（供給張貼） | 1485（civ1155/mil330） | 1424（civ1253/mil171） | ★civ **大量賣** |
| 全域 material total | 4242（隊3464/市場778；mil782/civ2682） | 4099（隊3323/市場776；mil418/civ2905） | ★充裕（非 3587，已增長） |
| 全域 tools | **0** | **0** | tools 從沒產 |
| g1.order_placed / fulfilled | 4811 / 6 | 4678 / 4 | 履約率 0.1%（整體貿易幾乎不成交） |
| trade.deal（全 res 合計） | 30 | 20 | 極少 |

### 三重 blocker（按主導序）
1. **★需求沒接上 buy-order（結構性）**：`post_buy.material`≈0。建 weaponsmith / 生產的 material 缺口**不產生市場買單**。生產/建設需求 → trade-buy 路徑**缺線**。(相對照：2600+ 買單多是 food，material 幾乎 0。)
2. **★機會性買被 want-gate 擋**：即使隊路過市場、板上有 material 賣單、tile 有 stock，執行時 `want = reserve(material) − holding ≤ 0`（82-85% no_want）→ 0 成交。**material 的 reserve 目標 < weaponsmith 建設需求（80-120）**，隊「自認庫存夠」不補建設缺口。
3. **coin 餓（次要）**：mil coin≈0-15（specimen 坐實）→ 即便 want>0 也買不起；但 no_coin 僅 5-11%，非主導。

### 供給側 = 不是瓶頸
市場 776-778 material stock、civ+mil 張貼 1400+ 賣單、全域 material 4100-4242 充裕（mil 手 418-782、civ 2682-2905）。**material 有產、有上市、有貨**——買方接不到才是病。

## 判讀（對照 systems 判準）
- **非**「civ 不賣」（civ 大量賣 1155-1253）、**非**「no_stock」（市場有 776 貨）。
- **是** 撮合/routing（需求→買單斷線 + want-gate）**主導** + coin 流通（mil 近 0 coin）次要。
- **blueprint ② 現況不通**：「mil 帶 coin 買 material」兩前提皆缺——mil **無 coin**，且**無機制**把 weaponsmith 的 material 需求接成買單/補足 want。

## Gate B trade fix 應治（供 spec）
1. **需求→buy-order 接線**：weaponsmith/生產 material 缺口 → 主動張貼 material 買單（現 post_buy.material≈0）。
2. **修 want-gate**：material reserve 目標反映建設/生產需求（否則到市場也 want≤0 不買）。
3. **mil coin 流通**：mil 近 0 coin → 帶 coin 買的前提。
4. tools：**全域 0**（從沒產）——tools 貿易在 tools 生產存在前 moot，另案。

## 溯源
raw：`docs/measurements/2026-07-22-mtl-trade-agg-{1337,42}.txt`（aggregate + 市場 stock + 全域分布）、`mtl-specimen-{1337,42}.jsonl`（mil specimen，送 QA）、`mtl-spec-run-{1337,42}.txt`。measured_at_head main HEAD。temp 探針（order_system post + interaction_system buy attempt/deal/bail 分 res+archetype + `_tmp_mtl_trade_bed.gd`）**已 revert，production grep 零殘留**（bed 檔 untracked，classifier 暫掛待 rm，inert）。determinism-safe（bump/read only，零 RNG）。

## 下一站
QA 讀 specimen 判故事（`to:qa` 另發）；blueprint 認 blocker 定案 → spec Gate B trade fix。verdict cc systems（`to:systems` 另發）。
