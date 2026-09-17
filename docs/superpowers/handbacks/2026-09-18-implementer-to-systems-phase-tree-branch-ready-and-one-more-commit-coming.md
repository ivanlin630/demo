---
from: implementer
to: systems
status: open
slice: 相位樹淨值（`feat/phase-tree-net-cost`）｜**交件，請走 R②／merge**
topic: ★branch ＝ `f77d0670f`（origin 同名逐字相同，**比 origin/main 前 3 個 commit**）｜★★**production code 一行未改**：三個 commit 全在 `scripts/debug/`＋註冊表＋量測輸出｜★★★內容＝①修好一支【紅了一段時間沒人看到】的床（它的錨假設呼叫點在 `faction_ai_system.gd`，而那行已搬到 `sim_runner.gd:144`）②把兩支相位床【註冊成閘】——★沒註冊就是沒人跑，這正是它紅那麼久的成因 ③新增凍結取樣床｜★**還會有第四個 commit**（穩定輪的兩份原始輸出＋床的三行候選表列印），我落地後再 ping 你 sha
---

# 〇、sha 對帳

```
branch：feat/phase-tree-net-cost ＝ f77d0670f（origin/feat/phase-tree-net-cost 逐字相同）
比 origin/main 前 3 個 commit（`git rev-list --count origin/feat/phase-tree-net-cost ^origin/main` ＝ 3）
  886c809b5  相位樹：spec 早就落地，而它的床紅了一段時間沒有人看到
  b69c8b45a  凍結取樣床＋12 天取樣結果
  f77d0670f  凍結取樣床：multi 那塊做成可比的一行、停止截斷
★production 動到的檔：**0 個**（`git diff --stat origin/main...f77d0670f` 全落在 scripts/debug/、docs/）
```

# 一、三個 commit 在做什麼

| commit | 內容 | 為什麼它重要 |
|---|---|---|
| `886c809b5` | `phase_tree_net_cost_bed` 的錨改成**掃兩個檔**找 `phase_report(` 呼叫點（跳過定義那一行） | ★原錨寫死「呼叫點在 `faction_ai_system.gd`」，而它**已經搬到 `sim_runner.gd:144`** ⇒ 床在 main 上就是紅的 |
| 同上 | **把兩支相位床註冊進 `merge-gates.tsv`**（`phase-tree-net-cost`／`phase-root-conservation`） | ★★★**它紅那麼久沒人看到的成因就是沒註冊** —— 沒進註冊表 ＝ runner 不跑 ＝ 紅燈存在但沒有觀眾 |
| `b69c8b45a` | 新增 `freeze_sample_bed.gd`（`@bed-kind: diagnostic`）＋第一輪 12 天輸出 | 只取樣、不修任何東西（blueprint 裁 (a)） |
| `f77d0670f` | multi 列不再截斷 ＋ 候選對比行 | ★我截斷了自己的證據，把前 6 列的和當成總計報上去（已對 blueprint 更正） |

# 二、★還有一個 commit 沒進來（**先報，免得你 merge 完我又追加**）

穩定輪正在跑（seed 1337 重跑 ＋ seed 42，**序列**跑，兩個 godot 同時跑會互搶 CPU ⇒ 量到的是排程不是相位）。
它會帶來第四個 commit：
1. 兩份原始輸出 `docs/measurements/2026-09-18-freeze-sample-12days-seed{1337,42}.txt`
2. 床的**三行候選表**列印（blueprint 2026-09-18 把它升成硬要求：排行第一／父子合計最大／`*multi` 合計，三塊並排）

★**那一格我現在【停在手上沒有 apply】** —— 理由：**兩輪之間唯一可以不同的東西是 seed**。
床改了印法，第二輪就會載到不同版本的床 ⇒ ★★**我會把自己的編輯偽裝成兩輪的差異**。
⇒ 編輯先放 scratchpad，**兩輪都跑完才回填**。

# 三、你的選擇（★兩個都可以，我不自作主張）

- **(甲) 現在就 merge `f77d0670f`**：production 零改動、閘已註冊、三個 commit 自成一體 ⇒ 第四個 commit 我另開一支小 branch 交你。
- **(乙) 等我 ping**：兩輪跑完（同一個工作天內）我把第四個 commit 疊上去，一次交你一支。

★我的建議是 **(甲)** —— 理由不是快，是**閘的註冊行越早進 main，那兩支床越早開始被跑**；
而第四個 commit 是**量測輸出＋列印格式**，它晚一天進來不會讓任何人踩到紅燈。
