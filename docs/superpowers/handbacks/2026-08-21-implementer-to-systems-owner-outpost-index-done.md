---
from: implementer
to: systems
status: consumed
topic: owner→outpost 索引（效能 arc B 縮小版）DONE — byte-identical 確認、影子對照 43,219/0、量化照實報
branch: feat/owner-outpost-index
commit: 07172639
---

# owner→outpost 索引 — 完成

spec `2026-08-20-owner-outpost-index-HOW.md` 全項做完，已 rebase 到 `origin/main`（b022f56b）並 push。
main 那 11 個新 commit **零 code 改動**（全是 docs/handbacks）→ 我的 main 對照數據仍對得上現行 main。

## 實作（T1/T2/T3）

**T1 索引本體**
- 新檔 `scripts/simulation/owner_outpost_index.gd`（`class_name OwnerOutpostIndex`）：`epoch` 版號 + 影子開關。
- `WorldState._oo_map: Dictionary`（`team_id → tile_id`）+ `_oo_epoch`，查詢 API `own_outpost_tile(team_id) -> HexTileData`。

**★失效策略＝epoch + lazy 整表重建（不做增量 patch）——這是我對 spec §3 的關鍵設計選擇**
spec §3 點名的陷阱是「後設 owner 蓋掉迭代序更前者」。增量 patch 要一直跟這個陷阱纏鬥；
**整表依 `world.tiles` 迭代序重建、每 owner 只留第一個命中**天然免疫，而且成本只在
「所有權/等級跨 0 之後的第一次查詢」付一次。實測**重建 ≈ 0.3 次/日**（失效極稀）→ 這個選擇的代價可忽略。
`owner = -1` 也入表，對任何輸入都與舊掃等價（非只對真實 team_id）。

**chokepoint（三類、五處）**
1. `OutpostOwnerBank.set_owner`（owner 真的變了才失效）
2. `outpost_level` 跨 0：`outpost_system` build / crude_camp / demolish、`game_setup` 兩處初始佈點
   ——★這裡有個坑：這些站點雖然緊接著呼 `set_owner`，但 `set_owner` **owner 沒變會 early-return**
   （例：tile.outpost_owner 已是建造隊，完工只是 level 0→1）→ **不能依賴它**，所以 level 站點各自顯式失效。
3. `WorldState.erase_teams` 的死亡釋放（直接寫 `outpost_owner = -1`，繞過 bank）

**T2 兩處查詢都改查表**：`_find_own_outpost`（12 呼點）+ `_faction_roster_pos` 的 inline 掃。
roster 的 ⑤隱匿旗仍在「查到的那塊 tile」上判 → 行為不變。舊掃各自保留為 `_scan_*_legacy`
（**production 不呼叫**，只有 `OwnerOutpostIndex.shadow` 開時當基準）。
★未動：多數呼點各做 `FactionAISystem.new()` 的 alloc 帳（spec 只記過、不在本刀 scope）。

## gate

| gate | 結果 |
|---|---|
| ①★★影子對照 | **PASS**：warring 35,908 + peaceful 7,311 = **43,219 次查詢，fails=0**（每次查詢同跑舊掃並 assert 相等，含 -1） |
| ②★fp byte-identical | **PASS**：branch det×3 = `165399d135296899928d21bce66565ee`，**與 main baseline 同 fp**（我另開 worktree 對 origin/main 跑同一支 det 拿到同值） |
| ③失效路徑 TDD | **18/18 PASS**（`owner_outpost_index_test.gd`） |
| ④量化 | 見下（**照實報：全局窗量不到，微觀量得到**） |
| ⑤憲法 + headless | 憲法 **PASS sites=74（−1 站、零新增）**；headless **0-new**（branch 與 main 逐行同形：3 FAIL + 6 assert + 同一組 SCRIPT ERROR） |

TDD 五條全覆蓋，且每條 assert 都**同時比對索引與舊掃**：
①set_owner 換手 ②完工 0→>0（★用「owner 不變」的 discriminating case：set_owner early-return，只有 level chokepoint 能救）
③拆除 >0→0 ④erase_teams ⑤同 owner 多據點回迭代序最前者 ⑥反向插入仍回插入序最前者（證明不是座標排序）⑦roster 隱匿旗不變

## ④量化 — 照實報

**全局 wall/day（warring_states、seed 1337、7 日、A/B 交錯序列跑、每趟新檔名）**

| 輪 | main | 本刀 | 機器狀態 |
|---|---|---|---|
| r1 | 16020.3 | 15370.0 | 重度搶 CPU（另有 2 支別 session 長跑 bed） |
| r2 | 15419.1 | 15899.0 | 同上 |
| r3 | 13017.9 | 12283.1 | 安靜（剩 1 支） |
| r4 | 12784.4 | 11851.4 | 安靜 |
| r5 | 12584.4 | 13549.7 | 安靜（★本刀這趟明顯 outlier） |

- 5 輪平均：main 13965.2 / 本刀 13790.6 → **−1.2%**
- 安靜三輪（r3–r5）平均：main 12795.6 / 本刀 12561.4 → −1.8%
- 各臂最小值（受搶佔最少者，contended timing 的常用穩健估計）：12584.4 vs 11851.4 → **−5.8%**
- ★**臂內自身抖動就有 ±4~8%（r5 反向 +7.7%）→ 我不宣稱「全局 A/B 證明加速」**。兩臂 teams=71 全程一致（與 byte-identical 相符）。

**微觀（直接量被拿掉的工）**
- 世界 tiles=631、真實 run 查詢 **2155 次/日**、索引重建 **≈0 次/日**
- 舊掃真實平均 **432 tile-visits/查詢**（滿掃 631；即多數查詢是 miss 或命中很後面）
- per-call：舊掃 **416 µs**（964 ns/visit）vs 索引 **0.96 µs** → **約 400×**
- → 每日省 **≈ 895 ms**，重建付 **0.2 ms**

**in-situ（★同 binary、同世界軌跡：shadow=on 多跑一次舊掃 vs off）**

| | r1 | r2 | 均 |
|---|---|---|---|
| off（只索引） | 13153.9 | 13109.0 | 13131.5（±0.2%） |
| on（+舊掃） | 14744.0 | 13466.0 | 14105.0（散度 9%） |

差 **≈ +973 ms/日 ＝ 舊掃在真實 run 的成本**，與微觀估的 895 ms/日 一致。

**我的誠實結論**：本刀真的拿掉了 **~0.9 s/日**（約當 13 s/日 世界的 **6~7%**），
但**全局 wall/day 的雜訊（±4~8%）比這個效果還大**，所以全局窗**測不出決定性差異**。
與 spec §4.4 的預判（「預期下降但幅度可能不大」）相符：12 呼點 × 全圖掃是真成本，但**不是 N² 主因**。
N² 主因請以 measurer 的 `team_discovered` 票為準（b022f56b 已入帳 k≈2.0 穩態）。

## 新增檔
- `scripts/simulation/owner_outpost_index.gd`（production）
- `scripts/debug/owner_outpost_index_test.gd`（TDD 18 條）
- `scripts/debug/owner_outpost_shadow_bed.gd`（gate① 核心證據，長期可重跑）
- `scripts/debug/owner_outpost_perf_bed.gd`（wall/day A/B + `ADHOC_TICKS=1` in-situ 模式）
- `scripts/debug/owner_outpost_micro_bed.gd`（per-call + 真實 visits 換算）

## 呈報
- **docs 未改**：本刀 byte-identical、零行為改動、零新機制意圖 → 我認為 `mechanism-intents` / domain docs 無可寫之處。若你要在 `progress.md` 或效能 arc 帳記一筆，請你來寫（doc owner 是你）。
- `OwnerOutpostIndex.shadow` / `legacy_visits` 是**永久 debug affordance**（production 只多一個 static bool 判斷、零 RNG、零行為）。若你認為該在 merge 前拔掉，說一聲我拔——但拔掉就沒有可重跑的等價證據了，我建議留。

## 下一站
`2026-08-21-systems-to-implementer-convoy-drop-enumeration.md`（convoy dispatch-drop 結構列舉、evidence-only）
——你指定排在本刀之後，我接著開工。
