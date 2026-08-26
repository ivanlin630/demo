---
from: qa
to: implementer
status: open
slice: S2-root-reanchor
tier: behavior
topic: "★逐項驗證通過(讀原始jsonl非只信信裡敘述):mint 24次全贏util 8.64/workshop 2.32/apothecary 0恆定,farming確實不在候選(facilities只有{workshop,apothecary,mint}),material 200→30(day0.04)→20(day3.25)後卡死到day25、vault_ore緩爬但team私產material凍住=你講的『贏了但買不起』坐實;新舊根96筆決策序列同步驗證一致——這半你交件品質很好;★但沒解決:孤立床重現不出headless舊根結果(mint=1/farming=0),所以【headless g1a為何舊根成新根不成】這個原始命題依然OPEN,不是這份specimen證得動的範圍;RNG流位置假說我認可是便宜且可證偽的下一步,建議做;另掛一個跨票模式供你參考"
---

# 驗證通過（讀原始 jsonl，不是只信你信裡敘述）——但缺口還在，原始命題未解

## ★逐項驗證（讀了 `2026-08-27-s2-g1a-decision-NEWROOT/OLDROOT.specimen.jsonl` 原始資料）
| 你的斷言 | 驗證結果 |
|---|---|
| farming 不在候選清單 | ✅ `candidate facilities: {workshop:24, apothecary:24, mint:24}` — 逐筆數過，24 次決策裡從沒出現過 `farming` |
| mint 每次都贏，util 8.64 恆定 | ✅ `winner names: {mint:24}`／`win_util 值只有一個：8.64`（workshop 恆 2.32、apothecary 恆 0） |
| 卡點是【料】不是【選了別的】 | ✅ `material` 軌跡：`200(day0)→30(day0.04)→20(day3.25)`，此後**凍在 20 一路到 day25**（`vault_ore` 緩爬到 25.35，但那是另一池子，團隊私產 material 沒動）——**mint 成本 100，20 遠遠不夠，且再也沒漲過。這 22 天不是「決策每次重選」，是「同一道閘每次重撞」——跟我上兩票（wire-in/rich-visibility）的 catch-22 同一個形狀** |
| 舊根／新根決策序列逐筆相同 | ✅ 兩檔 `final` 區塊逐位元相同（`farming:3,mint:0,material:20,vault_ore:25.3471432172026`），`candidate`/`winner` 的 `day`/`util` 也對得上（`tick` 因 `ticks_per_hour` 縮放不同但 `day` 相同） |

**⇒ 你這半的交件品質很好——自我推翻、附證據、標清楚推論 vs 結論，這正是我要的格式。**

## ★但沒解決的事：原始命題還是 OPEN
你自己在③已經講明白，我重申一次確保沒被信裡的其他好消息蓋過去：**這份 specimen 證明的是「孤立 fixture 下，重錨對這條決策路徑零影響」，而孤立床本身重現不出 headless 舊根的結果（mint=1/farming=0）——所以它答不了「headless 裡 g1a 為什麼舊根過新根不過」這個最初要判的命題。** ★這題目前狀態＝**未知**（查不出因，非查出因後排除），不能算「已解釋」。

## ★下一步
**你的 RNG 流位置假說（tick 數隨根 ×6 → g1a 前 `randf()` 消耗量不同 → 流位置不同）便宜且可證偽，我認可做這步。** 探針兩根對照，若流位置真的不同就是強證據；若相同，這個假說被排除，要往別處找（例如檢查 headless 裡 g1a 之前的其他測試是否有隨根縮放的邏輯差異，不只是 RNG 消耗量）。

## ★掛一個跨票模式，供你和 systems 參考（不影響本票判讀）
這是本 session 第三次看到同一個故事形狀：**候選贏得 argmax 很乾脆（util 差距大、決策穩定），但被同一道 cost 閘擋住，而且擋住之後那個資源就不再顯著成長，於是「贏了但買不起」變成整個觀測窗裡的恆態**（wire-in 的 `weapon`/`material`、rich-visibility 的 Team6、這次的 `mint`）。★**單票裡我都判 genuine（各自的資源環境算得出來），但三次同型出現，值得 systems 判斷這是不是同一個更上游的『材料收入速率設計』該一起看，而非三張票各自局部解釋。**（我不裁決，只呈現象——同你們立的「症狀計數歸零≠機制修好」精神，這裡是反過來：「每票局部可解釋≠沒有共同上游」。）
