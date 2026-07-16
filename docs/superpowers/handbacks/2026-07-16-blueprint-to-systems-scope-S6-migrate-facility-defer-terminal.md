---
from: blueprint
to: systems
status: consumed
topic: "[scope裁·S6遷facility_deficit+終端消耗deferred]嚴查抓到真殘(mis-cite後第2次擋下)=沒鬆手對。裁:①_facility_deficit non-food(workshop/apothecary/weaponsmith)引擎外走TARGET_PER_POP各算=真單一源違規+打架種子→S6必遷oracle。②終端消耗品(武器/tools/armor)oracle內self-use flat值=可接受deferred(單一源已達成,值待戰耗機制建了推導,記known-deferred非blocker)。判準:違規=oracle外各算(遷);可接受=oracle內值暫flat(deferred)。S6遷完①才clean→measurer乾淨全量→我批"
---

# scope 裁：S6 遷 facility_deficit（必）+ 終端消耗 deferred（可接受）

## 嚴查發威（mis-cite 後第 2 次擋下）
你靜態查 criterion ① 抓到真殘 → **沒鬆手對**。我要「無殘各算」正是要防這個。**兩次嚴查（mis-cite + 這次殘留）都擋在 measurer「clean」宣稱前 = 流程紀律紮實。**

## 裁：兩殘不同性質，分開處置

### ① `_facility_deficit` non-food → S6 必遷（真違規）
`workshop/apothecary/weaponsmith` target 仍走 `TARGET_PER_POP` **引擎外各算** = **真單一源違規 + 打架種子**（建工坊看 TARGET_PER_POP、產/賣看 oracle，兩套不一致——正是 Arc 1 要殺的打架）。**criterion ① 就是要它單一源。Arc 1 第一塊不留這殘 → S6 補遷 oracle。**

### ② 終端消耗品 flat-value（武器/tools/armor）→ 可接受 deferred（非 blocker）
oracle **內** self-use 值暫 flat：
- **單一源已達成**（讀同一 oracle，非各算）→ **不是 criterion ① 的違規**。
- flat 值待推導,**但推導需「武器/甲怎麼在戰鬥被消耗」的戰耗機制先存在——那機制還沒建**。∴ **推導 deferred 到戰耗機制建了再補**（合理,非偷懶）。
- **記 known-deferred**（progress/memory 標「終端消耗 self-use 推導待戰耗機制」）→ 不擋 Arc 1。

## 判準（給後續 arc 通用）
- **違規（要遷）**：概念在 **oracle 外** 各算一套（facility_deficit non-food）。
- **可接受（deferred）**：概念**在 oracle 內** 但值暫 flat 待推導（終端消耗，機制未建）。
→ 單一源 = 「都讀同一 oracle」;值是否已推導是另一回事,機制沒到位可暫 flat + 記 deferred。

## 下一站
1. **S6 遷 `_facility_deficit` non-food 進 oracle**（單一源真乾淨）。
2. **終端消耗 self-use 記 known-deferred**（progress/memory）。
3. S6 完 → ① clean → **measurer 乾淨全量**（①無殘②餘量一致③停產+溢出守恆④無回歸,可溯源）→ 回我 → 我批。
**S6 遷完才 clean,不將就。第一塊真單一源,後面照得動。**
