---
from: reviewer
to: systems
status: open
slice: 帳本 delta 加總必須等於資源變化（小票，觀測儀器缺陷）
topic: R② ＝ **ISSUES，一列，但很重**（`4ad9d0ffe`）｜(a) 你問「TileBank 寫不寫 record_driver、P1 要不要對 tile 也做」—— 答案是**寫，而且 TileBank 有兩支跟 ResourceBank.set_amt 一模一樣（甚至更糟）的同款缺陷，41 個生產呼叫點，完全不在本票範圍內**：`TileBank.set_amt`（`:65-70`，註解逐字「同 ResourceBank.set_amt 的理由」卻沒把 record_driver 那行一起修）／`TileBank.pool_set`（`:94-96`，連 prev 都沒算，比 set_amt 還差）｜(b) adjust_person_coin 已核：正確、是 person.coin 唯一寫者（零繞過），但 P1 範圍不含 person ⇒ 這條正確性今天沒有格子在驗｜(c) 核過：`"*resources*"` 全站零讀者（grep 排除寫入點後 0 命中），不必再等「先grep」
---

# 0 審了哪棵樹

`origin/main` ＝ `8daf0c53d`；spec sha `4ad9d0ffe` 是它的祖先。

# 1 ★(a) TileBank —— 不是「要不要也做」，是**同一個病已經在那裡，而且更嚴重**

## 證據：`tile_bank.gd` 四支寫入口逐一核

```
set_amt（:65-70）：
  var prev = tile.public_storage.get(res, 0)
  tile.public_storage[res] = amt
  _tally_food(tile, res, amt - prev)              ← ✓ 用變化量（跟 ResourceBank 一樣，這條對）
  WorldState.record_driver(tile, res, amt, …)      ← ✗ 記新值，不是 delta
  ★★★而它的註解逐字：「set 是蓋值⇒流量＝新值−舊值（同 ResourceBank.set_amt 的理由）」
    —— ★這句話本身就是對的診斷，但下面那行 record_driver 沒跟著改，是同一個人（或同一輪）
       寫對了 _tally_food、寫對了註解，卻漏了 record_driver 那一行
pool_set（:94-96）：
  tile.resources[res] = amt
  WorldState.record_driver(tile, res, amt, …)      ← ✗✗ 連 prev 都沒算，比 set_amt 還糟
    （set_amt 至少算了 delta 餵給 _tally_food，pool_set 完全沒有 delta 的概念）
deposit（:73-78）／withdraw（:82-87）：都用 newv-cur／-m，★這兩支是對的（跟 ResourceBank.add/remove 同形）
pool_add（:98-100）：amt 本身就是要加的量，record_driver(tile, res, amt, …) 對 —— 這支也是對的
```

## 生產呼叫點不是理論風險

```
git grep -n "TileBank.set_amt(\|TileBank.pool_set(" -- scripts/simulation/*.gd（排除 tile_bank.gd 自己）
  ⇒ 41 處，全部在 faction_ai_system.gd／ambush_system.gd 等生產系統
  （例：:994 mounts 自動提領／:5236,5247 絕戶路由資源／:5249,5253,5255 礦產累積／
   :5286,5293 NPC 存提倉庫／:5471 返家補給頂倉）
⇒ 這不是一支沒人呼叫的死函式，是跟 ResourceBank.set_amt 同等級、甚至用得更廣的寫入口
```

## 判決

```
★★★這張票的整個理由（D 題：帳本記錯導致看起來像試算寫進真帳本的嚴重懷疑）同樣適用於 TileBank
  ——任何一支用 TileBank.set_amt／pool_set 記錄 tile 公庫變化的量測，今天都會看到跟 Team7 food
  同款的「鏡像」假象，只是還沒有人去讀它、所以還沒被量測員撞到
⇒ P1 要擴大：entity 不只 team，也要對 tile（`HexTileData`）做同一個 Σdelta == end-start 恆等式
⇒ §1「做什麼」要加：
  ①TileBank.set_amt：record_driver(tile, res, amt - prev, …)（照 ResourceBank.set_amt 同一刀）
  ②TileBank.pool_set：先算 var prev = tile.resources.get(res, 0)，record_driver(tile, res, amt - prev, …)
    （它現在連 prev 變數都沒有，要新增，不是改一個既有算式）
⇒ ★不建議把這個分流到「以後另開票」——理由跟票本身的立論一樣：它是同一種病，
  同一張 P1 恆等式只要把 entity 從 team 擴到 tile 就會自動抓到兩邊，不擴大反而是留一個已知同款洞
```

# 2 (b) `adjust_person_coin` —— 核過：本身是對的，但 P1 今天不驗它

```
resource_bank.gd 底部：
  static func adjust_person_coin(person, delta, reason) -> void:
    person.coin = maxf(person.coin + delta, 0.0)
    WorldState.record_driver(person, "coin", delta, reason, "resource")
⇒ 用的是 delta 本人，不是新值 ⇒ 沒有 set_amt 那個病
★★負斷言核過（不只讀這一行就信）：git grep "person\.coin\s*=" -- scripts/simulation/*.gd
  排除 adjust_person_coin 自己那兩行 ⇒ 零命中 ⇒ 它是 person.coin 唯一寫者，沒有人繞過它直接改
⇒ 這條今天**是對的**，但 P1 的母體寫的是「每一隊每一種資源」——person 不是 team，
  P1 不會去驗 person.coin 的 Σdelta == end-start，所以這條正確性今天**沒有格子在看它**
⇒ 建議：P1 加一句或開 P1b，母體加 person.coin（entity=PersonData），理由跟 (a) 一樣——
  這張票的賣點就是「用恆等式取代枚舉」，枚舉的話 person.coin 今天剛好沒事，
  但下一個人改壞它時，不開著這一格就看不到
```

# 3 (c) `"*resources*"` 讀者 —— 核過，不必再等，答案是零

```
git grep -n '"\*resources\*"' -- scripts/   排除 resource_bank.gd 自己那一行寫入點
⇒ 0 命中
⇒ 全站沒有任何讀者在讀這個 bulk 標記 ⇒ §1②「既有那筆保留，先grep再決定」可以直接下決定：
  **沒有讀者，保留它不會多付代價，但也不必特別論證「可能有人在讀」**——這句改成「已核：零讀者」即可
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "P1 只對 team.resources 做即足夠；TileBank 不在本票範圍",
     "file_line": "tile_bank.gd:65-70（set_amt）／:94-96（pool_set，無delta計算）；41個生產呼叫點",
     "truth": "TileBank 有跟 ResourceBank.set_amt 同族甚至更糟的缺陷，而且被廣泛使用；P1 的 entity 要擴到 tile，§1 要加兩支函式的修法"}
  ],
  "note": "(b)(c) 不算issue，是答案：adjust_person_coin本身對但P1範圍不含person(建議P1b補上)；*resources*確認零讀者可以直接下決定。改完(a)那列敲sha，我只diff TileBank那段。" }
```
