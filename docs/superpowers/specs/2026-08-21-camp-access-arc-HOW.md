# HOW spec：接入 arc —— 治「滿池餓死」

slice: camp-access
date: 2026-08-21 ／ owner: systems
**WHAT ＝ 已裁存量**（blueprint 2026-08-21 授權直接出 HOW）：L0 階梯／三動機／**執行失敗反饋律**／
「**不是基建狂魔**」（修通替代路讓亂蓋自然輸；**反向 ＝ 修通紮營讓該紮的自然贏**）。

## §1 病名與 acceptance 判準（blueprint 定）
**病名 ＝「滿池餓死」。**
**修完 ＝ 站在滿池上的 parent 隊，`collect.no_outpost_no_camp_zero_food.parent` 型計數 → ~0；
且「萎縮到 `pop=1` 的村」消失。**

## §2 前提（實測坐實）
- **8／11 萎縮隊站在滿／近滿食物池上**（runway **61–364 天**）**卻 `effective_food` 只有 2.3–9.2**
- **無 outpost ＋ `camp_level = 0` ⇒ 該 cadence 物理上零被動食物**
  （`resource_system:66-78`；**累計 984 次，parent 960／subteam 24**）
- **正面對照**：`camp_level = 1` 的 team10／11 ⇒ `effective_food` **暴漲 388／457**
  ⇒ ★**L0 階梯機制本身是有效的，問題全在「為何不紮」。**
- **萎縮隊 `terrain = {plains 9, forest 2}`** ⇒ **不是承載力**（我的 `cap` 假說已死）

## §3 ★診斷先行：三分流（**判準先寫死**）
`紮營` 的 `applicable`（`options.gd:195-197`）＝
```
ctx.food_days < ctx.desperation_entry_threshold   # ★絕境門檻
  and ctx.has_farmable_tile                        # ＝ _find_unowned_farmable_tile != -1（systems 已驗：同一查詢）
  and not ctx.has_own_outpost
```

| 分流 | 判準（要 tap 證據，非推論） | 修法形狀（blueprint 已定） |
|---|---|---|
| **(i) 卡在絕境門檻** | 零採集 cadence 當下 **`food_days >= desperation_entry_threshold`** 佔多數 | ★**那個門檻就是閘 ⇒ de-patch**：**沒有被動收入的隊不該等到瀕餓才准紮營**。**禁補償補丁。** |
| **(ii) 找不到無主可耕地** | `has_farmable_tile = false` 佔多數 | 查 `_find_unowned_farmable_tile` 的**限制面**（belief-known 集合／`outpost_owner` 條件） |
| **(iii) applicable 但秤輸** | applicable 為真、但 `紮營` **不是 argmax** | **`camp_drive` 的秤**（**接失敗反饋律**：反覆不 fire 要能被看見） |

### ★R² 追加的保險 tap（採納）：`camp.applicable_but_idle`
我先前「驗掉」了「applicable 真但 `to_task` 回 IDLE」這個斷點——理由是**兩者是同一個查詢**。
★ **R² 把它修得更準**：**同一個函式，但是兩個不同時間點的呼叫**
（`to_task` 是 **fresh 重查**，**不是讀 `ctx` 的快取值**）
⇒ **中間若被同 tick 的別隊改動同一格，理論上仍可能「applicable 算時可、`to_task` 真呼時不可」**。

⇒ **加 `camp.applicable_but_idle` tap 當保險**（**非阻塞**）：
**`紮營` 被判 applicable、卻在 `to_task` 回了 `TASK_IDLE`** ⇒ bump。
★ **理由**：**「我證明不出它會發生」不等於「它不會發生」——不能證明沒有，就留一個看得見的 tap。**

★ **必須先分流再修** —— 三種的修法**完全不同**，而**總計數看起來一模一樣**。
（同今日血訓：**總平均會把不同性質的病壓成一格**。）

## §4 gate
1. ★**acceptance（blueprint 定）**：`collect.no_outpost_no_camp_zero_food.parent` **→ ~0**；
   **「萎縮到 `pop=1` 的村」消失**（`pop=1` 村數 vs baseline **顯著下降**）
2. ★**分流證據**：三分流**逐隊歸格**、**不得只給總數**
3. ★**不是基建狂魔**：修完**不得出現「到處亂蓋」** ——
   **紮營次數上升、但 `L0→L1 晉級率` 與 `L0 廢棄率` 要一起報**（**亂蓋的特徵是蓋了就丟**）
4. **失敗反饋**：若某動詞**仍反覆不 fire**，**要有 tap 看得見**（**不得靜默**）
5. **det×3 穩定**；`fp` **會變 ＝ intended-change**；憲法 ≤74；headless 0-new
6. ★**pop=1 村消失 ≠ 用生育補**：**要驗那些村是「沒掉下去」而不是「掉了又生回來」**
   （**`death.*` 與 `breed.born` 分開看**）

## §5 不做
- **不調 `FARM_UNIT_YIELD`**（tuning 議程已由 blueprint **降級**：**沒接管別調水壓**）
- **不用 `cap` 調平 forest**（**intended 地理張力**，用戶拍過；forest 出路 ＝ 貿易／遷村／控糧產地）
- **不加補償補丁**（如「零採集就自動給食物」）—— **找到閘 de-patch，或接失敗反饋**
- **不動 `subteam-ladder` 的地位**（它治的是另一根，2.4%，正當性來自用戶 WHAT）
