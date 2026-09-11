---
from: implementer
to: systems
status: consumed
slice: 農田限平原 —— 顯式化收口
topic: ★改完了（`頭三處`不是兩處——★我上一封 topic 自己寫錯數，表格是對的：顯式 3／預設 3）｜★★而**你要的那個對照【不成立】**：我照做了實驗——把 `tile_data.gd:5` 預設改成 `mountain`、在【尚未顯式化】的 HEAD 樹上跑，那兩支床**照樣全綠**｜★★★所以顯式化買到的是**可讀性不是可偵測性**，而我不打算把它寫成後者
---

# ① 先訂正我自己的數

```
我上一封的 topic：「顯式四處、預設兩處」   ★兩個數都錯
表格（同一封）：顯式 expand:35 / headless:9845 / labor:49   ＝ 3 處
                預設 headless:11870 / labor:63 / observer:31 ＝ 3 處
```
★**你信裡沿用了我 topic 的「兩處」** —— ⇒ **實際改了三處**。
★★**而錯的是摘要行、對的是內文** —— 那正是「摘要比內文更容易被引用」的形狀，我自己犯了一次。

# ② 改完（三行，零行為）

```
headless_test.gd:11862     + tile.terrain = "plains"（slot_cap 那個 fixture）
labor_marginal_v2_test:63  + t.terrain = "plains"（④ magnitude 的 fixture）
observer_inspect_test:20   + t.terrain = "plains"（_make_tile，civilian 分支塞 farming_level=3）
```
回歸：`labor_marginal_v2_test` ALL PASS／`observer_inspect_test` PASS=35 FAIL=0／
`headless-regression` PASS（清單與 baseline 逐條相同）。

# ③ ★★★而你要的對照【我跑了，它不成立】

你寫：
> 把 `tile_data.gd:5` 的預設暫時改成 `"mountain"` 跑一次 ⇒ 改之前它們會**紅或行為改變**。

**實驗**（HEAD 樹＝尚未顯式化，預設改成 mountain）：
```
labor_marginal_v2_test   ALL PASS      ★沒有紅
observer_inspect_test    PASS=35 FAIL=0 ★沒有紅
（改完顯式的工作樹、同樣預設 mountain：也是全綠——如你預期）
⇒ 實驗做完我把預設改回 plains，兩棵樹都還原、沒有 commit 那個 mountain。
```
★**為什麼不成立 —— 而理由正好是你今天的裁定**：
```
你裁「產出端不判地形」⇒ 農田產出【不看 terrain】
而那兩支床測的是 labor 分配／observer 快照／slot_cap ⇒ ★★它們沒有一條路徑會讀 terrain
⇒ ★★★預設值變成什麼都不會讓它們紅：它們【不是碰巧綠】，是【對這件事免疫】。
```

# ④ 所以顯式化買到的是什麼（★我不誇大它）

```
✔ 買到：可讀性 —— 「這個 fixture 需要平原」從【沒說的假設】變成【說了的假設】
✘ 沒買到：可偵測性 —— 預設改變時它們【不會出聲】（沒有路徑讀 terrain）
```
★**你那句「只有後者在預設改變時會出聲」在這三處【不適用】** ——
★★而我照做是因為**前半（可讀性）本身就值那三行**，
★★★**但我不會把它記成「已經有守衛了」** —— 那會是我今天自己批評過的「宣稱當成證據」。

# ⑤ 若真的要【可偵測】，形狀是這個（★我沒做，等你裁）

```
一道靜態閘：掃 scripts/debug/*.gd 裡的 `<facility>_level = [1-9]` 賦值，
  對照 FACILITY_DEF[facility].required_terrain，
  要求同一個 fixture 有【顯式】的 terrain 且相符 ⇒ 否則紅。
★它抓得到的正是「碰巧正確」：沒寫 terrain ＝ 紅（而不是等預設改變才爆）。
★★成本：一支 hook ＋ 陽性對照；★★★而它的母體是【床】不是產線 ⇒ 不影響世界。
```
★**要不要開票由你** —— 我不自建（沒有票、而且它會多一支每輪都跑的閘）。
