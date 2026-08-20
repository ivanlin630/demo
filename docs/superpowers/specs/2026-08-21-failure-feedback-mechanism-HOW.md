# HOW spec：執行失敗反饋機制（Phase 0；A1 五族的形狀由本 slice 定義）

date: 2026-08-21 ／ owner: systems ／ WHAT ＝ 用戶立法〈執行失敗反饋鐵律〉（`invariants.md`）
狀態：待 R² → dispatch。★**這是 A1 的前置**：先有反饋機制，drop 點才有地方接。

## §1 法條與已裁的四項（`invariants` 已入，此處只複述判準）
「**執行失敗＝事件，必反饋決策層，禁靜默丟棄；同一原因禁無記憶反覆撞。**」
systems 已裁：**①形狀＝連續折價（非硬 cooldown）②記憶放隊層（非 leader `p.memory`）③失效升 T0、劣勢只折價 ④反射弧三段同語彙**。

## §2 ★先講一個設計風險（本 spec 最重要的一段）
**折價在「世界結構性壞掉」時，會讓 agent 安靜地放棄，而不是讓問題浮出來。**
實例：`order.abandoned` **94.4%** 的真因是 **GATE-B（貨到不了）**。若失敗折價讓隊**不再掛單**——經濟更死，而且**症狀消失、病還在**（下輪報告會看到「訂單噪音解決了」，實際上是**大家都放棄了**）。
**∴ 兩條硬要求**：
- **(a) 折價必須有 floor、不得絕對否決**（同 §4c `QUALITY_FLOOR=0.25` 的精神）→ **絕境仍可壓過折價再試**。
- **(b) ★放棄必須可觀測**：失敗事件與折價生效**都要有 tap**（`failure.recorded.<reason>` / `failure.suppressed.<option>`）→ **「大家都放棄了」要在數據上看得見**，不能靜默。
  ★這條直接接**全量暫態可觀測性**不變量：**用反饋消滅症狀，不等於消滅病**——沒有 tap 就會把後者誤讀成前者。

## §3 機制
### T1 儲存（隊層、bounded、入 fp）
`TeamData.recent_failures: Dictionary` — `key → {tick:int, count:int}`；**`key = "<option>|<target>"`**（無 target 用 `-`）。
- **prune**：讀寫時順手清過期項（**bounded、不無界成長**）。
- ★**入 `state_fingerprint`**：它**直接改變下輪 argmax** ＝ 直接因果態（同 `breed_progress` 前例；非可重算快取）。

### T2 折價形狀（★複用 §4c 語彙、禁第三種形狀）
`failure_mult(option, target) = clampf(1.0 - Σ_i (INTENSITY × count_factor_i × freshness_i), FLOOR, 1.0)`
- `freshness = max(0, 1 − age / TTL)`（**線性衰減、過期歸零**，同 §4c）。
- `count_factor` **有上限**（連撞加深、但**不無限加深**）→ 防永久封殺。
- **乘進既有 util**（**不新增 term 線**，同 §4c 掛法）。
- ★**TTL 用相對錨定**：`k × 該動作的自然重試週期`（例：convoy＝回程 ETA、掛單＝`ORDER_LIFETIME`）——**不新增全域絕對天數常數**（守時間包 §2 規約）。

### T3 失效 vs 劣勢（升不升 T0）
| 類 | 例 | 處置 |
|---|---|---|
| **失效**（當前計畫已不可行） | 路不通／目標消失／仲裁拒絕**已承諾**的任務 | **記憶 + `WorldEvents.emit` 喚醒該隊重想** |
| **劣勢**（這次不划算、計畫仍成立） | 資源不足／人手不夠／到場沒貨／暫時 throttle | **只折價** |

### T4 示範接線（**只接一族**，證明「一套機制 + 一處接線」可行）
★選 **`order.abandoned`**（94.4%、單純、**與在飛的 convoy RETURN 修無交集**）：單到期未成交 → 記 `買單|<res>` 失敗、折價下輪同 res 掛單 util。
★**其餘四族（convoy 七站／JOIN／建設 `try_set` noop／trade market bail）不在本 slice** —— A1 逐族照抄本形狀（**若照抄成立，A1 就從「五個修法」縮成「五處接線」**）。

## §4 gate
1. **同因第二次真的降分**：合成床——同一 `(option,target)` 連續失敗 → 該 option util **單調下降**、且 `count_factor` 觸頂後**不再加深**。
2. ★**floor 生效**：極端絕境（該 option 是唯一出路）→ **仍可被選中**（**不得絕對否決**）。
3. **過期恢復**：TTL 後 util **回到原值**（非永久黑名單）。
4. **失效升 T0**：仲裁拒絕已承諾任務 → **該隊當 tick 被喚醒**（用既有 `WorldEvents`）。
5. ★**可觀測**：`failure.recorded.*` / `failure.suppressed.*` 有值；**放棄率可從數據看出**（§2(b)）。
6. **示範族真的接上**：`order.abandoned` 94.4% 的世界裡，**掛單行為出現可觀測的變化**（★**不預設變好或變壞**——只要求**看得見**；變差反而是 GATE-B 的證據）。
7. det×3、constitution ≤74、headless 0-new、**fp intended-change**（決策分數真的變了）。
