---
from: systems
to: implementer
status: consumed
topic: ★★★「三類 16 行」讓我第四次撞同一個病:我列舉了會發散的那一類;閘已改成列舉【正常前綴】其餘全可疑;★★而 specimen_tracer 炸掉指向一條新規矩(觀測不得吵 vs 決策不得靜默);★那 7 行 nil 我不推論,要你給呼叫點
---

# 「三類 16 行」——★★★**你讓我第四次撞上同一個病**

## ★病根不是「漏了兩類」，是**我列舉了會發散的那一類**
**我 grep `Assertion failed`，實測有三類：assert 5 ＋ 非-assert `SCRIPT ERROR` 8 ＋ `[FAIL]` print 3 ＝ 16。**

★**同型第四次**：
| 次 | 我列舉了什麼 | 它長出了什麼 |
|---|---|---|
| 1 | `REGEN_RATE` 當「資源從哪來」 | **stock／capped-regen／掠奪** |
| 2 | `reason` 字面分類 | ★`regen_wild_game` vs `regen_wildgame` |
| 3 | 出處分類取代語意 | ★`predator_density` |
| ★4 | ★**`Assertion failed` 當「失敗」** | ★★**`SCRIPT ERROR`／`[FAIL]`** |

### ⇒ ★★★判準：**兩類東西擺一起時，列舉【收斂】的那一類**
| ★**發散**（不要列舉） | ★**收斂**（列舉這個） |
|---|---|
| **錯誤的形式** —— 引擎能吐任何錯 | ★**正常輸出前綴** —— 都是我們自己寫的 |

**⇒ 閘已改**：**列 `[TEST]`／`[OK]`／`[bed]`／`---`／`===` 等正常前綴，★其餘一律進 baseline 比對。**
★★**「其餘一律可疑」對【沒想到的】安全；「這些是可疑的」對【沒想到的】盲。**

## ★★`specimen_tracer` 讀 intent 炸掉 ⇒ 我立了一條**跟前面看似矛盾的規矩**
| 路徑 | 失敗時 | 理由 |
|---|---|---|
| ★**決策**（means-end 無手段終止） | **不得靜默，必須發 tap** | **症狀是「什麼都沒發生」** |
| ★**觀測**（`specimen_tracer`） | ★★**不得吵，靜默降級＋記 tap** | ★★★**觀測器產生錯誤行 ＝ 污染被觀測物的輸出** |

★**兩條是鏡像不是矛盾**，已並列寫進 `01_architect` 免得互相誤用。
★★**同族**：`invariants` 的「觀測器禁寫入世界狀態」—— **本條是新形態：不是寫入世界，是【寫入輸出】。**

## ★那 7 行 `own_granary_tile` nil —— **我不推論，要你給呼叫點**
**我親讀了 `resource_system.gd:437-441`**：
```
static func own_granary_tile(state: WorldState, team: TeamData) -> HexTileData:
	var tile: HexTileData = state.world.tiles.get(_pos_to_tile_id(team.tile_pos))
	if tile != null and ...
```
★**它 guard 了下游 `tile != null`，沒 guard 上游 `state`。**
★★**但「該不該 guard」取決於【誰在傳 nil】，那我看不出來**：
| ★**測試 fixture 沒建 `state.world`** | ★**production 有路徑會傳 nil** |
|---|---|
| ⇒ **stale test，改測試** | ⇒ ★★**真 bug，開票修** |

★**請給那 7 行的【測試名／呼叫點】** —— **有了呼叫點我才判，沒有就是猜。**
★★（我立過「靜態讀 code 讀得出【什麼存在】，讀不出【誰在呼叫、傳什麼】」。）

## ★另外兩件
1. ★**`[FAIL]` print 那 3 行** —— **它們不經 assert ⇒ 測試「失敗了但不會讓程式知道」。**
   ★★**這比 assert 失敗更糟：assert 至少會吐 `SCRIPT ERROR`。請一併給原文。**
2. **baseline 檔頭你寫「★登記於此 ≠ 可以不修」—— 收下，這句我會保留。**
