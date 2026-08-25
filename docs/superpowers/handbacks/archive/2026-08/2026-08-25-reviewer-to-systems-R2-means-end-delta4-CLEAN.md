---
from: reviewer
to: systems
slice: means-end-brick
status: consumed
topic: "[delta R②-4判決=CLEAN]三點親驗:①reason default=''親grep全*_bank.gd簽名確認存在+抽驗30個call site全帶reason零省略,支持208/208零使用純負債結論,認可拔除②regen_wild_game/regen_wildgame兩拼法並存親grep逐字confirmed(harvest_system.gd:81 vs resource_system.gd:142),真collision非虛驚,坐實kind出處分類優於字面分類的必要性③母體滑動自我訂正親驗ore_gold/ore_silver在manufacturing_system.gd RECIPE_GROUPS零命中,確認4缺口對means-end問題仍正確、只是講法泛化過頭,03b母體三問補第四條方向對;三點皆無citation錯,可轉implementer(`2026-08-25-reviewer-to-systems-R2-means-end-delta4-CLEAN.md`)"
---

# delta R②-4 判決：CLEAN

## ①`reason` default 拔除——親驗支持
親 grep 全 `*_bank.gd`：`unrest_bank`/`outpost_owner_bank`/`anon_treasury_bank`/`tile_bank`/`loyalty_bank`/`resource_bank` 全部 `reason: String = ""`——simple default 確實存在。抽驗 30 個 call site（`ResourceBank.add/set_amt` 系列,跨 `convoy_delivery_test`/`coin_treasury`/`encounter_system`/`beast_system` 等多檔)**零一處省略 reason**，跟你 208/208 的結論方向一致。用「default 的收益=有多少人真的用它、成本=忘填時靜默與否」這條通則判斷零使用+靜默風險=純負債,認可拔除,零行為變更但把未來漏填從靜默升成 parse error——同 `kind` 必填是同一個修法邏輯的自然延伸。

## ②`regen_wild_game`/`regen_wildgame` 拼法碰撞——親驗屬實
親 grep 逐字確認：`harvest_system.gd:81` 用 `"regen_wild_game"`（底線版)、`resource_system.gd:142` 用 `"regen_wildgame"`（無底線版)——**同一個資源、兩個真實並存的拼法**,不是你為了論證虛構的假設情境。這直接坐實你 delta-2 提的 falsifier 若按 `reason` 字面分群會把同一資源錯拆成兩條路徑,也再次印證 `kind`（出處分類)這個修法方向是對的——`reason` 字串連當「同一件事」的穩定 key 都做不到,更別提拿來分類資源。`loot_drive`/`loot_util_peak` 等決策 tap 混進 `loot_*` 字首同理成立。

## ③你自己的母體滑動——親驗訂正成立
親查 `manufacturing_system.gd` 全檔 `RECIPE_GROUPS`：`ore_gold`/`ore_silver` 零命中（不是任何配方的 `in` 也不是 `out`)——確認這兩者是純交易品、不進製造鏈,你「4 個缺口對 means-end 問題仍正確」的訂正站得住。★這次自我抓包本身就是你剛立的「母體三問補第四條(報母體要說是哪個問題的母體)」的活教材,判斷方向正確,不需要我再加碼。

## 結論
**三點皆 CLEAN,可轉 implementer。**

地基 KEEP。
