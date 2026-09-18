---
from: systems
to: implementer
status: consumed
slice: 據點知識進 belief（新票 `feat/outpost-belief`）
topic: ★**派工**：R①/R② CLEAN，spec `docs/superpowers/specs/2026-09-17-outpost-belief-claim-HOW.md`｜★★**形狀是【延伸既有的 `state.team_tile_known`】，不開新 store** —— 寫入端 `harvest_tile_known` 已經建好，開平行 store ＝ 把「觀察怎麼變成知識」那條路再寫一次｜★★★**三條硬線**：①`key` 存在仍然只代表「見過這塊地」②**relay 來的 tile 不得帶據點子記錄**③**列舉介面定名 `BeliefSystem.known_outposts(state, observer_id)`**（那個名字是三支同病灶 site 將來的機械判準）
---

# 一、做什麼

把 `_enemy_outpost_positions()`（`faction_ai_system.gd:5876-5891`）的**地點知識**從 god-view 拆出來。
★**它現在全圖掃真實 tile ＋ live 讀 `outpost_level`／`outpost_owner`**，而那道 belief 閘擋的是**主人**不是**地點**。

```gd
state.team_tile_known[observer][tid] = true            ← ★保留：key 在 ＝ 見過這塊地（語意逐字不變）
state.team_tile_known[observer][tid] = {               ← ★★加值；key 仍在 ⇒ 舊讀者不受影響
    "outpost": {"owner_id": int, "level": int, "last_tick": int}   ★★★自己的時戳、自己一條線
}
BeliefSystem.known_outposts(state, observer_id) -> Array   ← ★列舉介面（定名，別改名）
```

# 二、★★★三條硬線（每條都有一格驗收盯著）

| # | 線 | 為什麼 | 格 |
|---|---|---|---|
| ① | **`key` 存在 ＝ 見過這塊地**，這個語意逐字不變 | 四個既有讀者**全部只走 key**（`has()` 或 `for-in-dict`），★**我跟 reviewer 各自查過，合計四支**｜★★動了它就是動到四支 | 3-g |
| ② | ★**relay 來的 tile【不得】寫據點子記錄** | `harvest_tile_known` 有兩條寫入路徑（`belief_system.gd:320-327` 視野內／`:329-333` relay）——**只聽說有這麼一個地方 ≠ 看過它上面有什麼**（§1a 三態） | 3-h |
| ③ | ★★**兩個事實不可壓成一個值** | 「見過這塊地」**不會過期**（地不會走）；「它當時有一座 L 級據點屬於 T」**會過期**（可能被拆／易主）—— **衰減理由不同就不能共用一條線** | 3-d |

# 三、★不要順手做的兩件（都有明令）

1. ★**錨定性 decay【不接】這個新欄**（blueprint 明令，理由是我量到的反向數字：受害者側 0.59% ＜ 母體側 0.96%）
   ⇒ 格 **3-e**：`decision_context` 的錨定判準**逐字未改**。★★**「欄開了 ≠ 每個想用的地方都該接。」**
2. ★**同病灶的另外兩支【不在本票】**（`_find_occupy_target`／`_find_trade_partner`）——
   它們已進 `defers.tsv`，**等本票落地後一起改**（★**三支要一起改**：改一支留兩支，下一個讀者會照殘留的抄）。

# 四、★一支長得像卻【不是】病灶的，別修它

`goal_resolver.gd:1538-1546`（`find_nearest_known_tile`）閘後 live 讀的是 **`t.terrain`**。
★**地形不會變** ⇒ 「當時」與「現在」是同一個值 ⇒ **沒有製造出不該有的知識**。
★★**判準是【那個欄位會不會變】，不是【有沒有在閘後讀 live】。**

# 五、驗收 ＋ 要量的

spec §3 共八格（3-a～3-h），★**3-a／3-b 是成對的**（「知道得太多」與「知道得太少」各消失一半），
★★**3-b 是活對照**（reviewer 核過：`vision_system` 唯一的 `record_claim` 鍵在 TEAM、
且 `TeamData.occupying_outpost_since` 證明「無人據點」是遊戲命名過的常態）。
§4 要量：`observer × 已知據點` 條目數（回答當年「免建大 store」那個顧慮）、迴避集大小 proxy 版 vs 真欄版。

★**床要印自己的版本**；★★sha 對帳那一行繼續帶。
