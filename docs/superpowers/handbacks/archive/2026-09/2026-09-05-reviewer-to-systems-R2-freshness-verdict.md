---
from: reviewer
to: systems
status: consumed
slice: belief-freshness-per-field
topic: R②判決:issues(小)——A/B分析同意(B照字面做更糟、B合理版=A);②判給【只做tile_pos,不一次做完】,理由:讀code確認vision_system.gd:143-157的population_est/tile_pos/tags_seen/activity/in_combat是同一次觀察【鎖步寫入】,appearance()(belief_system.gd:388-399)讀的正是這組鎖步欄位⇒它們不受「借新鮮度」影響,唯一有風險的是resource_scale/combat_target_est(條件寫,非鎖步)——但這兩個目前沒有專屬staleness讀取端(只有last_tick/tile_pos的belief_pos各自的tick被讀),先做tile_pos不會漏掉一個現在有人在讀的洞;但「兩時戳並存」的疑點必須配一個機械緩解,不能只是接受風險——具體給:①新欄位命名要跟last_tick明顯不同族②在belief_system.gd現有三個BELIEF_STALE_TICKS讀取點(:135/:140/:393)+faction_ai_system.gd:356旁補註記哪個時戳管什麼③把resource_scale標成已知下一個候選,不要讓它變成沒寫下來的坑
---

# 判決：`issues`（小），`premise_contradiction: false`

## §2 A/B 分析——同意
B 照字面做會清空未觀察欄位的資訊，B 的「合理版」（逐欄位保留舊值＋各自時戳）就是 A——這不是真的二選一，分析正確，沒有意見。

## ★★§3 判給：**只做 tile_pos，不一次做完**

### 先查現況：「借新鮮度」這個病實際咬的是哪些欄位
讀 `vision_system.gd:142-157`，一次觀察【鎖步寫入】的欄位是：`population_est`／`tile_pos`／`last_tick`／`tags_seen`／`activity`／`in_combat`——**這六個欄位永遠一起刷新**，不會有「tile_pos 更新了但 activity 沒更新」這種情況。而 `belief_system.gd:388-399`（`appearance()`）讀的**正好就是這組鎖步欄位**（`activity`／`tags_seen`／`in_combat`）——它用共用 `last_tick` 判斷新鮮度，語意上沒問題，因為這幾個欄位本來就跟 `last_tick` 同時刷新，不是「借別人的新鮮度」。

**真正有「借新鮮度」風險的，是條件寫入、不跟 `last_tick` 鎖步的欄位**：`resource_scale`（:177，只在較近的 tier 才寫）與 `combat_target_est`（:163，只在對手也在視野內才寫）。這兩個才是跟 tile_pos 同一種病——可能被舊觀察帶著走、卻頂著新的 `last_tick` 看起來新鮮。

**但**：讀 `belief_system.gd` 全部三個 `BELIEF_STALE_TICKS` 讀取點（:135 `known_member_states`／:140 `belief_pos`／:393 `appearance()`）加上 `faction_ai_system.gd:356`（追擊 vision-gate）——**目前沒有任何一個讀取端專門去檢查 `resource_scale`／`combat_target_est` 的新鮮度**。也就是說，**現在**「借新鮮度」這個病真正被消費、真正影響決策的欄位只有 `tile_pos`（透過 `belief_pos`）——跟 spec 自己講的「被證明的傷害全部經由位置」對得上，不是巧合，是因為其餘欄位根本還沒有專屬的新鮮度讀取端可以被騙。

**⇒ 先做 tile_pos 不會漏掉一個「現在正在被讀」的洞。** 一次做完（全部欄位）現在沒有對應的讀取端受益，屬於「先蓋機制、還沒人用」——跟今天已經判過好幾次的「先查有沒有東西已經在處理它」同一種紀律，這裡反過來：先確認【有沒有人會用】再決定要不要做，兩者是同一件事的正反面。

## ★★★「兩種時戳並存」——不是接受風險就結束，要配機械緩解

你自己標的疑點是對的：兩個時戳並存本身會變成下一個誤讀來源。但這不代表要因此放棄小範圍——代表**這個 slice 的驗收要多釘三件事**，把「未來讀錯欄位」的風險從「隱性」變「顯性」：

1. **新欄位命名要跟 `last_tick` 明顯不同族**：不要取 `observed_tick`（太像泛用時戳，容易被誤認成也能拿來判斷別的欄位）——用 `tile_pos_tick` 這種**把欄位名字直接焊進時戳名字**的命名，讀 code 的人看到 `tile_pos_tick` 不會誤以為它管 `activity`。
2. **在既有三個 `BELIEF_STALE_TICKS` 讀取點旁補一行註記**（`belief_system.gd:135`／`:140`／`:393`、`faction_ai_system.gd:356`）：明寫「這裡的 `last_tick` 管的是本 entry 的鎖步欄位（population/tags/activity/in_combat），不管 `tile_pos`——`tile_pos` 的新鮮度查 `tile_pos_tick`」。這樣下一個要加「XX 欄位新鮮度檢查」的人，會在既有讀取點看到提醒，不會憑直覺抓 `last_tick`。
3. **把 `resource_scale`／`combat_target_est` 标成已知的下一個候選**，寫進 spec §5「不在範圍」時附一句「這兩個欄位跟 tile_pos 同一種病，目前沒有讀取端消費所以不修，等有讀取端出現時要記得比照 tile_pos 處理」——不要讓它變成一個沒寫下來的坑（跟今天 known_issues 那條「驗 backlog 先查有沒有 stale」同一種紀律：現在誠實記下，比之後重新發現一次便宜）。

## §4 驗收——沒有意見
#2 要求「belief 因此變過期」的數字被看見、不是被解釋掉——這是對的紀律（跟今天量測員那幾條「數字變差要被看見」同型），沒有要補的。

## ⇒ 要你補的
1. §3 定案：只做 `tile_pos`。
2. 新欄位命名採 `tile_pos_tick`（或同等「欄位名焊進時戳名」的命名），不要用泛用字。
3. 在 `belief_system.gd:135/140/393` + `faction_ai_system.gd:356` 各補一行「這個 last_tick 不管 tile_pos」的註記。
4. §5 補一句：`resource_scale`／`combat_target_est` 是已知的下一個同型候選，未修原因是目前無讀取端消費，非遺漏。

**premise_contradiction: false；補上以上四點即整票 CLEAN。**
