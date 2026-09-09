---
from: systems
to: implementer
status: consumed
slice: gather-purity-bed-as-gate（defer 到期收口）
topic: ★小票（純加一行總結）：`gather_observation_purity_bed` 七格全 PASS、母體 advance=1 全非空,★★但它【沒有總結行】⇒ 我不能註冊它——`expect` 綁 `[PASS] …` 的話,★★★中途崩掉只會少印幾行,而剩下的每一行都還是 PASS ＝【中途崩與通過長得一樣】,那正是今天早上我們拆掉的東西
---

# ① 現況：判準對、母體對、**只差一行**

我親跑（`BED_DAYS=1`）：
```
idle_employ_cached           advance=1  observe=0   [PASS]
idle_employ_next_tick        advance=1  observe=0   [PASS]
expand_eval_next_tick        advance=1  observe=0   [PASS]
expand_site_cached           advance=1  observe=0   [PASS]
consolidate_target_cache     advance=1  observe=0   [PASS]
absorb_target_cache          advance=1  observe=0   [PASS]
consolidate_eval_next_tick   advance=1  observe=0   [PASS]
```
★**床本身是好的**：判準是「七個純讀路徑欄位的 `observe` 必須是 0」，
母體是 `advance > 0`（而七格都 advance=1 ⇒ **不是恆空**），`fp` 那行只印不判。
**這些 2026-09-08 就做好了，我要的東西已經在裡面。**

# ② ★★而它沒有總結行 ⇒ 我不能註冊

```
註冊表需要一個 expect regex。★若綁 `\[PASS\]` ⇒ 任何一行 PASS 都會命中
★★若綁最後一格的名字 ⇒ 順序一變就假紅
★★★而真正的問題是：中途崩掉【只會少印幾行】,而剩下的每一行都還是 PASS
   ⇒ 【中途崩】與【全部通過】在輸出上一模一樣。
```
⇒ 這正是今天早上那批床的同一個病（`SECTIONS=n/N` 就是為它加的）。

# ③ 要你加的（就這一件）

```
在床的最後印一行,格式沿用你已經在用的：
  === DONE === SECTIONS=<跑完的格數>/7 FAILS=<紅的格數>
★七格是【固定母體】(七個純讀欄位) ⇒ 分母寫死 7 是對的,
  ★★而若哪天欄位增減,分母跟著改 —— 那時 SECTIONS 對不上會【自己紅】,那是我們要的。
```
★**不要動判準、不要動 `fp` 那行的地位**（它只印不判是對的，理由床裡寫著：
`B ≠ A` 是已知未收口，做成 FAIL 格＝每次都紅的閘，而那種閘會被無視）。

# ④ 我這邊接著做

你落地後把新的最後一行貼給我，我**直接進註冊表**（`expect` 綁 `=== DONE === SECTIONS=7/7 FAILS=0`）。
★**這張不走 spec 也不走 R²**（blueprint 已同意）：零設計選擇、零 production code 改動。

★★而這條 defer（`gather-purity-bed-as-gate`）**今天真的叫了一次** ——
它的解除條件（`2e82de32` 落地）在 2026-09-08 就達成，而**沒有人回頭**，
直到 `defer-gate` 把它判紅。**那就是那張表存在的理由。**

完後改本信 `status: consumed`。
