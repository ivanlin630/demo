# 訂正：礦儲量遞減【已存在】——撤回「無儲量遞減」HOW 缺口

status: NOTE（影子藍圖自撤；含 canon 兩處要改）
from: 影子 blueprint session（不發信、不寫 memory）
to: 正藍圖（改 `mechanism-intents.md:49`）→ systems（關 `defers.tsv` `ore-depletion-counter`）
date: 2026-09-09
撤回對象: `_archive/2026-09-07-currency-and-wages-rulings.md` §HOW 缺口那句「現行 code 無儲量遞減…兩路窮盡搜索零命中」——**錯**。

---

## §1 證據（file:line）

| 行 | 內容 |
|---|---|
| `scripts/simulation/resource_system.gd:458` | `TileBank.pool_set(src_tile, res, maxf(current - gain, 0.0), "harvest_deplete")`——採集後**從 tile 扣**，`res` 是變數，ore 走同一行。公庫路／私產路兩條 intake 都會到這行（只有「滿載不採」`continue` 跳過，且那次也沒採）。 |
| `scripts/simulation/resource_system.gd:184` | regen 迴圈註解「ore / gem 不再生」——只補 food/material/wild_game。 |
| `scripts/simulation/faction_ai_system.gd:5207` | 「S2 修：ore_gold/silver 改用 resource_cap（永不清零），避免採集後相鄰 plains 評分大幅掉分」——**別人早就撞到礦會被採空**，才把選址改讀 cap。 |
| `scripts/simulation/world_generator.gd:94` | 只是初值（5–30 × mult），不是「永恆」。 |

⇒ **礦是有限的，設計裁定（礦有限三幕）在 code 已成立，不需要新計數器。**

## §2 canon 裡要改的兩處

1. `docs/mechanism-intents.md:49`「HOW 缺口=現行無儲量遞減(worldgen 寫一次全庫零扣減,需採集遞減計數器)」→ 刪這子句。
2. `docs/process/defers.tsv:115` `ore-depletion-counter` → 關（前提不成立）。
   ★順帶：該列的觸發檢查 `git grep -q 'depletion\|remaining_yield'` **對現況也是盲的**——真實 reason 字串是 `harvest_deplete`，`depletion` 不是它的子字串 ⇒ 這格永遠不會亮。守衛母體沒驗（同型第 N 次）。
3. `docs/game-design.md:1559` 敘事段寫「儲量遞減」是設計語意，**對，不動**。

## §3 我為什麼錯（負斷言假窮盡，形態＝我自己加的過濾條件）

我搜的是「`tile.resources["ore_gold"]` 的寫入點」＋「ore 減法語彙」——兩路都**帶著 ore 字面**。
真正的扣減是 generic：`pool_set(src_tile, res, current - gain)`，`res` 是迴圈變數，字面上沒有 ore。
⇒ 「零命中」是我的過濾條件造的，不是世界的。宣稱「兩路窮盡」時沒問「若不窮盡哪格會亮」。
正確做法＝先裸掃 `TileBank.pool_set\|set_amt` 全部 caller（tile.resources 的唯一寫入面），再分類。

## §4 撤回後真正剩下的問題（是量測，不是設計）

`gain = productivity × current × COLLECT_RATE(0.05) × day_fraction` ⇒ **正比於存量＝指數衰減**，永不精確歸零，但會「有效枯竭」（採量 < mint 一批所需）。
- 三幕能不能在可玩時距內走到「錢荒」，取決於衰減速度 vs 初始總量——**現有量測沒有這條序列**（warring-3mo jsonl 只有 `mint_level_dist`，全程 L0）。
- 要的是一張**量測票**：`qty.harvest_taken.ore_gold` 累計 vs worldgen 初始總量，看 90 天／180 天採掉幾成、`g1.mint` 何時停。
- 不是修法票。「礦怎麼還沒挖完」若成立，答案在 `COLLECT_RATE`／`mult`／礦格數，而且那是「三個月後還會是真的嗎」的平衡題，不是缺口。

## §5 對前一場討論的影響

我在票討論裡說「枯竭先、票後，否則票永遠不 fire」——**前半撤回**。序改為：
票 coin 類 key＋估值 → 財政秤加「印票」選項 → trust 進 belief＋傳聞 → 玩家動詞 → 床。
「錢荒會不會來」由 §4 量測票回答，不擋票的設計。
