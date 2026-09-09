---
from: systems
to: reviewer
status: consumed
slice: 農田限平原（用戶裁 2026-09-10）
topic: R² 請審｜★HOW 裁定在 §2：【建址擋，不在產出擋，既有農田不追溯】——三條理由裡最重的是「同一個規則放兩個地方必然 drift」｜★★而驗收⑤【先跑】：civilian 據點落在非平原的比例若接近 0,①那格會永遠綠不了（界限第八條,今天已經改了四張票的形狀）｜★★★要你特別審:我裁「不追溯」有沒有造成一個【永遠不會被清掉的例外池】
---

# R²：`docs/superpowers/specs/2026-09-10-farming-requires-plains-HOW.md`

用戶 2026-09-10 裁「1 做」（農田限平原）。修法是**一行**，用**現成機制**（`stable` 已在用）。

## 已坐實的前提

```
outpost_system.gd:98-104   FACILITY_DEF["farming"] ★沒有 required_terrain
outpost_system.gd:122-127  FACILITY_DEF["stable"]  ★有 "required_terrain": "plains"
outpost_system.gd:619-620  檢查點 ＋ `wall.reject_terrain` tap（★都現成）
tile_data.gd:28            var farming_level: int = 0（★新世界沒有存量農田）
resource_system.gd:131-135 產出端：`if tile.farming_level > 0 and owner == team` ★沒有地形條件
grep -lE "farming_level *= *[1-9]" scripts/debug/*.gd ⇒ 4 支床直接構造農田
```

## 請你審三件

1. **★★★我的 HOW 裁定（§2）：建址擋，產出不擋，既有不追溯。**
   最重的理由是「**同一個規則放兩個地方必然 drift**」。
   ★但我要你判**它的代價**：採 (a) 之後，**規則上線前蓋在山上的農田會【永遠】繼續產出**
   ⇒ ★★**這是不是造出了一個【永遠不會被清掉的例外池】**？
   ★★★而我自己想到的反駁是：**新世界的存量是空的**（`farming_level` 預設 0）
   ⇒ 池子只在**存檔／長跑 session** 裡才非空。**但我沒有查存檔會不會帶 `farming_level`**
   ⇒ **若會帶，那個池子是真的**，請直接說。

2. **★驗收⑤要先跑，而它可能讓整票變成不可驗。**
   `plains` 佔 50%（地形卷）⇒ 若 **civilian 據點幾乎都落在平原**，
   `wall.reject_terrain` 會接近 0 ⇒ ★①那格**永遠綠不了**。
   ⇒ 我把⑤標成「**先跑，它決定其餘驗收有沒有母體**」。
   ★★**請確認這個順序寫對了** —— 今天「先算可達區間」已經改了**四張票**的形狀。

3. **★四支床我裁「不動、只回報清單」。**
   採 (a) 之後它們不會壞（產出端沒加條件）。
   ★但若某支床把農田蓋在**山地**上，那它餵的是**世界（規則上線後）不會產生的輸入**
   ⇒ ★★我裁**回報清單、由我逐支裁**（同 bed-kind 的逐批裁決），**不在本票內改**。
   **請判這個「不動」會不會讓那四支床從此成為【合法的假世界】。**

## 我知道的盲區

- **存檔是否持久化 `farming_level`：沒查**（見 item 1）。
- **`wall.reject_terrain` 的既有消費者：沒查** —— 若已經有東西在讀它，加一個新的 reject 來源
  可能會**汙染那個既有讀數**（★今天剛發生過一次同型：決策端呼叫污染執行端計數）。

CLEAN 才 dispatch。
