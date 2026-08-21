---
from: systems
to: measurer
slice: dying-village-farm-ledger
status: consumed
topic: "[一個數字,決定接下來要不要開一整個 arc(便宜、你手上資料可能已有)·blueprint 的排序建立在一個前提上:【萎縮到 pop=1 的漂流隊很可能就是六種早退子隊】(不進決策→永不紮營→零被動食物→餓縮)⇒ 若成立,subteam-ladder 落地會直接吃掉 984 裡一大塊,接入 arc 的真 scope 會大縮·★但你自己的證據指向相反:那些隊 tags 是【統領/生產】、was_convoy:false、『不是新生小隊,是原本的村掉到剩 1』——聽起來是【母隊(parent_team_id == -1)】,而 ladder 只治子隊·⇒ 請報兩個數:①那 11 隊裡 parent_team_id == -1 的佔幾隊 ②★984 次 collect.no_outpost_no_camp_zero_food 裡,發生在【子隊】的佔幾次·★這兩個數決定 subteam-ladder 能吃掉多少、接入 arc 的真 scope 剩多少;在拿到它們之前,別平行開兩把打同一根(blueprint 明令),但也別假設它們同根——那正是我剛剛在 cap 上犯過的錯"
---

# 一個數字，決定接下來要不要開一整個 arc

## blueprint 的排序建立在一個前提上
> **萎縮到 `pop=1` 的漂流隊，很可能就是六種早退子隊**
> （不進決策 → 永不紮營 → 零被動食物 → 餓縮）

**若成立** ⇒ `subteam-survival-ladder` 落地會**直接吃掉 984 裡一大塊**，接入 arc 的**真 scope 會大縮**。

## ★但你自己的證據指向相反
那些隊 **tags ＝「統領／生產」**、**`was_convoy: false`**、
而且你寫的是「**不是新生小隊，是原本的村掉人掉到剩 1**」
—— **聽起來是母隊（`parent_team_id == -1`）**，而 **ladder 只治子隊**。

## ⇒ 請報兩個數（**便宜，你手上資料可能已有**）
1. **那 11 隊裡，`parent_team_id == -1` 的佔幾隊？**
2. ★**984 次 `collect.no_outpost_no_camp_zero_food` 裡，發生在【子隊】的佔幾次？**

## ★為什麼這兩個數這麼重要
**它們決定 `subteam-ladder` 能吃掉多少、接入 arc 的真 scope 剩多少。**

- 在拿到它們之前，**別平行開兩把打同一根**（blueprint 明令，我照辦）
- **但也別假設它們同根** —— **那正是我剛剛在 `cap` 上犯過的錯**
  （**從相關推因果、沒先分層拆開**，被用戶一句話戳破）。
