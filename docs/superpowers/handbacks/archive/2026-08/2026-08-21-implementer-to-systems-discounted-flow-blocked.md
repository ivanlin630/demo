---
from: implementer
to: systems
status: consumed
slice: discounted-future-flow
topic: ★折現磚落地 + TDD 11/11（兩條蟑螂地板都釘住了）｜★★但世界層【不能 merge】：headless 9→14、營地 89% 蓋了就丟、零採集反向 — 兩個裁定點交還
branch: feat/camp-access
commit: 52f08fdf
---

# 折現原語（脊椎第一磚）：磚做好了，但世界告訴我它還缺一塊

## ①磚本身（可繼承語彙，非 camp 專用公式）
`DiscountedFlow`：`value = Σ_{t≤H_eff} flow·δ^t − Σ baseline·δ^t − cost`
- **δ ＝ 耐性／慎重族**；★**貪婪不碰 δ**，它調 `w_k`（財流／權勢流／軍力流），**活命流不折**
- **地板①** `δ ≥ DELTA_FLOOR`
- ★**地板②（R² 必查項）`H_eff` 用【執行後】淨流**：`−4.8 → −0.8` ⇒ `H_eff` **1.04 → 6.25**
  （不做這條，catch-22 就換一層：沒紮營→存糧低→H_eff 小→紮營不划算→沒紮營）
- `camp_drive` 改吃這塊磚，**baseline ＝ 真實被動所得（這族 ＝ 0）**

**TDD `discounted_flow_test.gd` 11/11 PASS**：
gate3(a) 最短視人格 + 最壞存糧 → 紮營 29.37 > 永遠覓食 0｜
★gate3(b) 存糧路徑（3a 抓不到那條）→ H_eff 跟著 post-action runway 放大 6 倍｜
gate4 人格挪門檻不翻轉（36.62 vs 29.37 同號）｜gate5 轉正 full horizon、仍赤字短窗｜baseline 語意

## ②★★世界層：**我不建議 merge**，三個反向證據

| peaceful 90d 同床 | 原始 | de-patch | **＋折現磚** |
|---|---|---|---|
| `camp.won_argmax` | 12 | 11 | **24** |
| **`camp.built`** | — | — | **28** |
| **`camp.abandoned`** | — | — | **25 ⇒ 廢棄率 89%** |
| **`outpost.l0_to_l1`** | — | — | **0 ⇒ 零晉級** |
| `collect.no_outpost_no_camp_zero_food` | 1133 | 978 | **1244（★反向）** |
| `pop=1` 村數 | 12 | 10 | **12（★反向）** |
| **headless** | 9 | 9 | **14（★+5）** |

**(a) gate3 判定「蓋了就丟」**：28 蓋、25 廢、0 晉級。
**因果（code 層）**：紮營贏了 → `camp_level=1` → **但沒有任何東西把隊留在營地上** →
下一輪 覓食/貿易 又贏 → 人走了 → `camp_ticks_left` 衰減歸零（`harvest_system:43`）→ 回到零被動收入。
`紮根`（L0→L1）**永遠等不到窗口** ⇒ 零採集反而變多（隊伍在營地之間來回跑）。

**(b) headless 5 條新失敗，全是同一族**（我不拿「預期改變」帶過）：
```
[p2a] 義氣隊未投靠 task=紮營
[p2a] 投靠玩家未寫 forced_event（W2）
Path 3 應 投靠，實際=紮營
[p2b1] 義氣 homeless 隊未投靠 task=紮營
掠奪 applicable + 承諾(current_option=掠奪) → 應續掠奪，實際=紮營
```
⇒ **紮營現在會壓過「投靠」與【已承諾的掠奪】**。這是**真的行為回歸**，不是測試綁死舊語意：
拿掉絕境門檻擴大了紮營參賽的場景，而它的新價值讓它**長期坐在 cap 上**。

## ③★兩個裁定點（我停手交還，不自己調參）
1. **「蓋了要住下去」那塊磚**——這正是你說的**考後主軸「承諾泛化」**。可能形狀（我不自選）：
   (a) `TASK_CAMP` 納 `PROGRESSIVE_HOLD_TASKS` ＋ 給「住在自己營地」一個真實選項（讓 `紮根` 有窗口）
   (b) L0 衰減規則：**主人在返回途中不算棄置**
   (c) 承認 L0 只是過渡，acceptance 改綁 L1
2. **紮營該跟誰同場競技**：它現在在 `sets{survival, passive_survival}` ⇒ 吃 survival boost；
   加上新基準線後就壓過 投靠／承諾中的掠奪。
   ★**我沒有動 cap、沒有調 δ、沒有加補償補丁**——因為那只會把「翻轉結論」藏起來，
   而你上一輪才立過「不得翻轉結論」的界線。

## ④ 其餘閘
det×3 **`d5a4ce28c5f65bf6a5e97723b7b7d96a`** 穩定（intended-change）｜憲法 **PASS 74**｜
★**headless 未過（9→14）＝硬閘紅**，故本刀**標記為不可 merge**。

## ⑤ 新增的常設 tap（gate2/3/7 用）
`camp.built` / `camp.abandoned` / `outpost.l0_to_l1`（三個都在 main 不存在，之前無法評 gate3）
＋ `discount.horizon_eff` / `discount.flow_food` / `discount.camp_evaluated`
＋ 前一刀已常設的 `camp.lost_to.*` / `camp.won_argmax` / `camp.applicable_but_idle`。
