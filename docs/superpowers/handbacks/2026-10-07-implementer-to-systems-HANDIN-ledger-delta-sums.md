---
from: implementer
to: systems
status: open
slice: 帳本 delta 加總必須等於資源變化（觀測儀器缺陷，小票）
topic: ★**交件｜BATTERY_RC=0｜107 綠／0 紅**（run-id `6014-20261007-033049`，HEAD `9f4283b0d`）｜branch `feat/ledger-delta-sums` 遠端 tip **`72a268c80`**｜fp **不變（量的）**｜負對照 4／4 紅（其中 clear_all 那一支要佈置才看得到，§三）
---

# 一、改了什麼

```
scripts/simulation/resource_bank.gd   set_amt：record_driver(amt − prev)＋_tap_coin(amt − prev)
                                      clear_all：逐資源記 −舊值（＋coin tap）；"*resources*" bulk 拿掉
                                        （`git grep '\*resources\*'` 全站只命中寫它的那一行 ⇒ 零讀者）
scripts/simulation/tile_bank.gd       set_amt／pool_set：記 amt − prev（pool_set 原本連 prev 都沒取）
                                      ★TileBank 五處全改走 record_driver_store，store ＝ "public"（公庫）／"pool"（自然池）
scripts/data/world_state.gd           record_driver 簽名不動；新 record_driver_store（多一個 store 鍵）；
                                      兩支共用 _append_driver（cap／丟棄計數那段只有一份）
四支寫入口各加一行 Probe-gated 計數（bank.call.*，純觀測、零 RNG）—— 床的母體地板
新床 scripts/debug/ledger_delta_sum_bed.gd（@bed-kind invariant）＋註冊列 ledger-delta-sum
```

# 二、床（default seed 1337，3 天）

```
P1 每 tick 清帳加總 ⇒ 每一個 (實體, 庫, 資源)：Σdelta ＝ 結束 − 開始（容差 1%·max(1,|變化|)）
   判 959 個（team 440／pool 585／public 11／person 44）｜中途生滅不判 121｜不符 0
   寫入口被呼：team_set_amt 1719／team_clear_all 2／tile_set_amt 13／tile_pool_set 31512
P1b clear_all 佈置在活隊上（Team0，清 20 種、非 0 的 5 種）⇒ 每種 Σdelta ＝ −舊值｜不符 0
P2 ledger 開／關 1 天 fp 相同（412205d9840e）
P3 每 tick 清帳之下丟棄 0（最早一筆 tick hint 60）
★person.coin（adjust_person_coin）：44 個全對 —— 那支 `maxf(...,0)` 夾底在這 3 天沒觸發；觸發時它記的 delta 會大於實際變化（未修，回報）
```

# 三、負對照（各在獨立 worktree 把一處改回記 amt、跑整支床）

```
n1 ResourceBank.set_amt   ⇒ P1 不符 33
n2 TileBank.pool_set       ⇒ P1 不符 443
n4 TileBank.set_amt        ⇒ P1 不符 4
n3 clear_all 不逐資源記   ⇒ ★第一版 P1 照綠：自然的 clear_all（3 天 2 次）都發生在**要消失的隊**上
                              ⇒ 被「中途生滅不判」排除 ⇒ P1 看不到 clear_all 的記帳
                           ⇒ 補 P1b（佈置在活隊）之後 ⇒ P1b 紅 5（food／material／coin／weapon_melee_low／armor_low 帳本 Σ 0）
```

# 四、fp

```
本輪 world-fp ✓、world-fp-ctrl ✓ ⇒ 基準不動｜為何沒變：只改帳本記的數與 Probe 計數，不改任何資源數值
```

# 五、新列

```
id      ledger-delta-sum
cmd     GODOT_TIMEOUT=1200 powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/ledger_delta_sum_bed.gd
expect  === ledger_delta_sum DONE === errors: 0
```

# 六、之後（spec §3）

```
D 題的「鏡像」用修好的帳本重讀 —— 量測員的活，帳本現在可信（每筆 delta 是變化量、TileBank 分得出庫）
```
