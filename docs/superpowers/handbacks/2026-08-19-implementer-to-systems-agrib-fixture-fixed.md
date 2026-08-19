---
from: implementer
to: systems
status: consumed
topic: "[g1a fixture 修 done·branch feat/agriculture-b @5b986d44·★headless 現 0-new(assert=恰 6 個已知 pre-existing、FAIL 行=3 個已知 Team23×2/弱目標;[g1a] 轉綠 mint_level=1 coin_delta=200 vault_ore=21)+agriculture_b_test 9/9 全綠+determinism fp 仍 24cffe3b4241f9e56d0bf25683e22a69(未變、test-only 確認)·連帶查:_mk_produce_team_on 全檔恰 2 caller(g1a T3 鑄幣鏈/T4 低糧 food buy)、皆不依賴『cap 很小』隱含前提→無測翻紅或變 trivially-true·production code 零改、未加任何 floor·★另報:此 worktree 的 population_system.gd 有【別人(疑 measurer)未 commit 的 Probe tap】(popcap.snapshot/popcap.overflow_fire)+未追蹤 agrib_final_round_bed.gd/sidecar txt→我照 WIP 掃入紀律只 commit headless_test.gd 單檔、沒碰它們]"
branch: feat/agriculture-b
commit: 5b986d44
---

# g1a fixture 修完（具名科目① = fixture artifact，已坐實）

## 修法
`_mk_produce_team_on`（`headless_test.gd:15297`）的 leader 只設 `values`、**從沒設 `skills["統領"]`** → `effective_pop_cap` 讀 `skills.get("統領", 0.0)=0.0` → `pop_cap_from_leadership(0.0)=1` × 放大器(L1=2.0) → effective≈2 → `_seed_pop(team,10)` 立刻超額 8 → `check_overflow_for_team` 拆走生產人力（無 named advisor → `_create_overflow_team`）→ 殘隊跑不動 collect/mint → `[g1a] 礦村未鑄幣`。**你/measurer 的 code-read 我複驗過，完全成立。**
→ 補 `ldr.skills["統領"] = 0.5`（對齊其他 fixture 慣例：:1640/:1667/:1689/:1764 等皆 0.5）。

## ★連帶查（共用 helper，照你要求先掃過才改）
全檔 `_mk_produce_team_on` **恰 2 個 caller**：`_test_g1a_mining_to_coin`（T3 鑄幣鏈）、`_test_g1a_mining_food_supply`（T4 低糧 food buy）。
- T3：斷言＝礦石被採 + mint 建成/coin 增加 → cap 變大只是讓生產人力不被拆，**正是該測的前提**。
- T4：斷言＝低糧發 buy 單（`active_orders` 有 food buy）→ 與 pop_cap 無關、不依賴小 cap。
→ **沒有測依賴「這隊 cap 很小」**，無翻紅、無 trivially-true 化。不需要逐測訂正、不用停下呈報。

## 驗（全部跑過）
| gate | 結果 |
|---|---|
| headless `[g1a]` | **轉綠**：`mining→coin OK mint_level=1 coin_delta=200 vault_ore=21` |
| headless 整體 | **0-new**：assert = **恰 6 個已知 pre-existing**（覓食 base／p2a join weight／197 擋／紮營=1.0／ambient_train_drive／rung 擴張）、FAIL 行 = 3 個已知（Team23 ×2、弱目標）＝與 main 同集合 |
| `agriculture_b_test` | **9/9 全綠** |
| determinism | **fp 仍 `24cffe3b4241f9e56d0bf25683e22a69`**（未變 → test-only 改動確認、production 零改） |

production code **零改動**，**未加任何 pop-cap floor**（floor 要不要＝organic 數據定、measurer 長跑中）。

## ★另報一件（不是我的改動，但你該知道）
此 worktree（`.worktrees/agriculture-b`）目前有**別人（疑 measurer）未 commit 的東西**：
- `scripts/simulation/population_system.gd` 被就地加了 Probe tap（`popcap.snapshot` bump_sample cap=6000 + `popcap.overflow_fire`），**未 commit**。
- 未追蹤檔：`scripts/debug/agrib_final_round_bed.gd`、`docs/measurements/2026-08-19-agrib-final-round-sidecar.txt`。

我照「別 session WIP 別掃入」紀律，**只 commit `scripts/debug/headless_test.gd` 單檔**（explicit pathspec），沒碰上述任何一項。
提醒兩點：① 那個 tap 在 branch 上是**未 commit 狀態**，若 measurer 的長跑結論要可重現，得先 commit 或明記；② tap 是純觀測（`Probe.bump`/`bump_sample`、零 RNG），所以我上面那些 gate 數字不受影響（determinism fp 也確認未變）。

地基 KEEP。
