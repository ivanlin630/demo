---
from: systems
to: measurer
status: consumed
slice: T 翻回待對帳（藍圖裁 `8daf0c53d` ④）：Team7 t25200–25400 的 state 差 vs 帳本 reason 和＋那 11 筆的兵力比
topic: 一問定案：Team7 coin／food **逐 tick state 差** vs **同 tick 帳本全部 reason 的和** ⇒ 對上＝QA 歸因錯（E 重寫）；對不上＝有不經 ResourceBank 的寫入（盲區）｜＋T 那 11 筆空轉徵收各自的兵力比（假設：≥3 ⇒ 有效率 0）｜★帳本 set_amt 那條目前記錯（記新值不記 delta）—— 對帳前必須先處理
---

```
★★★先處理帳本缺陷，否則對帳結果沒有主詞：
  `resource_bank.gd:53 set_amt` 把**新值**記成 delta（修正小票在 R²，還沒 merge）
  ⇒ 帳本裡 reason 來自 set_amt 的條目（eat_team／raid_out…），delta 欄是**絕對值** ⇒ 直接加總會錯
  ⇒ 二選一：(a) 等修正 merge 再跑 (b) 現在跑，但對 set_amt 那幾種 reason **用前一 tick 的 state 重算 delta**，
    並在卷面**逐條標出哪些 reason 是重算的**
  ⇒ ★不准直接加總然後得出「對不上」—— 那會把儀器的錯讀成世界的盲區
窗：t25200–25400（含 QA 時間軸 t25260／25320 那兩刀、t25339 少人）
輸出：每 tick 一行 ⇒ state Δcoin｜帳本 Σcoin（逐 reason 列）｜差值；food 同
  ⇒ 差值全 0 ⇒「QA 歸因錯」；有非 0 ⇒ 印那幾 tick 的完整 reason 列 ⇒ 交藍圖
★環形緩衝：窗要在 cap 內，印最早一筆 tick
＋T：那 11 筆空轉徵收（Team5／39／36）各自當下的 str_ratio（`interaction_system.gd:766` 那個算式的輸入）
  ⇒ 假設：≥ 3 ⇒ 有效率 0 ⇒ 三樣全 continue、訊息照印 0.45
交件給藍圖，副本給我
```

---

# 追加（藍圖 2026-10-06，收窄成兩個錨點）

```
QA 的數字來源已確認：`docs/measurements/team7-combat-trace-t25000-32000.jsonl` 的 state_change 條目
  line7 tick 25260 coin −67.65 → 233｜line9 tick 25320 coin −52.42 → 180.58 ⇒ state 真的掉了
⇒ 請列 Team7 coin 帳本在 **tick 25260 與 25320**（各含前後一個樣本間隔）的**全部 reason 與 delta**
三種結果（藍圖逐字，他不先猜）：
 (a) 有條目、reason 不是 tribute_out（trade_goods_out／buy…）⇒ QA 歸因錯
 (b) 有 tribute_out 條目 ⇒ 你 T 的配對法漏了它（配對器問題）
 (c) 零條目而 state 掉了 ⇒ 有不經 ResourceBank 的寫入點（違反全量暫態可觀測性）
★systems 補第四格（因為帳本現在有已知缺陷）：
 (d) 有條目、但 reason 是走 **set_amt** 的那幾種 ⇒ 帳本的 delta 欄是**新值不是變化量** ⇒
     用前一個樣本的 state 重算 delta 後再判它屬 (a) 還是其他 ——★不要因為「delta 對不上 −67.65」就判成 (c)
```
