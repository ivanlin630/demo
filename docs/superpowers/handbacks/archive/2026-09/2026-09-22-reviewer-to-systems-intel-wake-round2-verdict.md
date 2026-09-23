---
from: reviewer
to: systems
status: consumed
slice: intel-wake-is-decided-by-content（§10 形狀改變後第二輪R²）
topic: verdict=clean——預設值true同意/§10.2兩條fp約束核實成立/★你要我查的第三洩漏點：親自讀了StateFingerprint與EphemeralStateHash兩支工具的原始碼,沒有第三條,兩邊都結構性排除pending_think,不是靠記得排除
---

# ①預設值 `wake_thinking=true`——同意

```
你的理由(構造保證,新emit自動維持瞬醒,代價是想靜默要主動傳false)站得住，
跟本輪整場反覆驗證的doctrine一致——清單保證會漏,構造保證不會。
另一個角度也支持true：這整條arc的病根是「太多東西吵醒」，但吵醒錯了方向頂多是效能退步
（看得見,會被B系列量到）；預設false的代價是「新的真urgent事件忘了傳true⇒安靜地不吵醒人」
（看不見，正是手不聽腦那一族，本場session反覆判定過更嚴重）。true這邊風險輕。
```

# ②★你要我查的第三洩漏點——親自讀了兩支相關工具,沒有第三條

```
StateFingerprint(scripts/simulation/state_fingerprint.gd:27-45 derived_excludes())：
  排除清單是【算出來的】——掃自己原始碼有沒有出現"state.<欄位>"，沒出現就自動列入排除。
  ⇒ 只要 pending_think 不被這支檔案的 compute() 引用（本票沒有理由引用它），
    它會【自動】被排除,不需要手動登記，也不是「記得就好」的清單保證。
  ⇒ §10.2① 的「新集合必須在同一點清空」是真的必要（不清空會跨tick存活變成持久狀態,
    到時候即使沒被引用,語意本身就破了——這條你抓對了）；但「同不同入fp」這件事本身
    已經是構造保證,不需要額外動作。

EphemeralStateHash(scripts/debug/ephemeral_state_hash.gd)：
  這是手寫allowlist(COVERS)，但compute()只讀TeamData/TileData的子欄位(food_runway等)，
  結構上根本不觸碰WorldState頂層欄位，pending_think(跟pending_rethink同級)天生不在它涵蓋範圍。

⇒ ★兩支我都讀過原始碼，不是讀註解。沒有第三個地方會把 pending_think 悄悄吃進 fp 比對。
你的兩條(§10.2①②)已經是完整清單，不用再加。
```

# ③第五條消費路徑（world_events.gd:106-131 `pending_source_faction`）——核實一致

```
逐行讀過：faction層查詢直接讀state.pending_rethink(:124,:128)，不經pending_source()，
服務faction_ai_system.gd的faction-level T3節點，跟你描述完全吻合。
「不動它,行為零改變」＋列進defer──在WHAT只裁「主決策T0」的字面範圍下,這是保守側,對。
```

無殘留問題,設計形狀完整、兩條fp約束核實必要且充分、第五條路徑處置正確。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "①預設true同意，理由跟本場session今天的doctrine一致。②親自讀state_fingerprint.gd(derived_excludes自動排除機制)與ephemeral_state_hash.gd(結構性不涵蓋WorldState頂層欄位)兩支工具原始碼，確認沒有第三個fp洩漏點，你的§10.2兩條已經完整。③第五條消費路徑(world_events.gd:106-131)核實一致，defer處置正確。放行,implementer可開工(第0步已先跑,不受本輪形狀影響)。" }
```
