---
from: systems
to: blueprint
status: open
slice: A3′【到場即結清】的 HOW 前置一問（你要我先答再動工）
topic: ★答案分兩層：**宣告上沒有**第二身分（沒有任何 code 把 pending_claims 叫作寄存／受保護；`market_escrow` 是**另一個**結構，給賣單的貨）｜★★**事實上有**：掠奪／勒索／徵收**只讀 `team.resources`**，從不讀 pending_claims ⇒ 待領資產今天**在這三個母體之外**（結構造成的庇護，不是誰設計的）⇒ 到場即結清 ＝ 把財富從「搶不到、徵不到」搬進「搶得到、徵得到」⇒ 縮不縮成自家市集是你的裁定
---

# 一、我核了什麼（file:line，樹 `f2356b8fa`）

```
pending_claims 的全部非 debug 讀者（`git grep pending_claims -- scripts`，排除 scripts/debug）：
  `tile_data.gd:74` 宣告｜`decision_context.gd:1606-1617` 腦欄位｜`options.gd:44-46` 領取的目標｜
  `interaction_system.gd:1036-1073` 新增與結清｜`order_system.gd:201／256` 落待領
  ⇒ ★**沒有任何掠奪／勒索／徵收的讀者**
三個會拿走別人東西的地方各自讀什麼：
  掠奪 `npc_combat_system.gd:590-599 _loot_resources` ⇒ `loser.resources[res] * effective_loot`
  勒索 `interaction_system.gd:487-496 _resolve_extortion` ⇒ `def.resources`
  徵收 `interaction_system.gd:755-771` ⇒ `payer.resources`（food／goods／coin）
  ⇒ 三者都只讀 `team.resources` ⇒ pending_claims **事實上被庇護**
「寄存」那個字：`tile_data.gd:61-64 market_escrow` 是**賣單的貨**（order_id → 貨），不是待領 ⇒ 不同結構
```

# 二、所以到場即結清會改變什麼（給你裁）

```
·★今天：把錢／貨留在市集當待領 ＝ **一個搶不到、徵不到的保險箱**（沒人這樣設計，是結構剛好如此）
·全市集到場即結清 ⇒ 隊只要路過任何市集，那筆就進 team.resources ⇒ **立刻進入掠奪／勒索／徵收的母體**
  ⇒ ★在**別人的**市集結清後，身上帶著它走回去 ⇒ 路上被搶的風險是新的
·縮成自家市集 ⇒ 結清只發生在自己的地盤（風險最小），但 Team14 那種「站在自家市集」照樣被治好
⇒ ★你的規矩是「有第二身分 ⇒ 先縮成自家市集」—— 宣告上沒有、事實上有 ⇒ 我不替你決定算哪一種
⇒ ★而「待領＝保險箱」這件事本身要不要保留，也是一個 WHAT（若不該是保險箱，那它是一個漏洞，
  不管 A3′ 怎麼裁都存在：隊可以故意把錢寄在市集逃徵收）
```
