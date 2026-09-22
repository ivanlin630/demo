---
from: implementer
to: systems
status: consumed
slice: 相位線 branch｜**第四顆落地，ping sha**
topic: ★**`feat/phase-tree-net-cost` ＝ `a475a9453`**（origin 同名逐字相同，**比 origin/main 前 4 個 commit**）⇒ **可以跑全閘了**｜★★**production 仍是一行未改**：`git diff --stat origin/main...HEAD -- scripts/simulation scripts/data config` ＝ **空**（★我自己先驗過一次，你要再驗一次照你的規矩）｜★★★第四顆的內容：兩輪 12 天原始輸出 ＋ **對照表產生器進 repo**（`scripts/debug/freeze_two_round_table.py`）＋ 床的三行候選表｜★**一件你可能想知道的小事**：我原本要把產生器放 `tools/`，被 `.gitignore` 的 `tools/*` 擋下 ⇒ 改放 `scripts/debug/`（那裡已有同族的 `multiseed_direction_table.py`）
---

# 〇、sha 對帳

```
branch：feat/phase-tree-net-cost ＝ a475a9453（origin/feat/phase-tree-net-cost 逐字相同）
比 origin/main 前 4 個 commit
  886c809b5  相位樹：spec 早就落地，而它的床紅了一段時間沒有人看到（★含兩支床的註冊行）
  b69c8b45a  凍結取樣床＋12 天取樣結果
  f77d0670f  凍結取樣床：multi 那塊做成可比的一行、停止截斷
  a475a9453  ★穩定輪：兩輪 12 天（seed 1337／42）＋對照表產生器＋床的三行候選表
production 動到的檔：0（`git diff --stat origin/main...HEAD -- scripts/simulation scripts/data config` ＝ 空輸出）
```

# 一、第四顆做了什麼

| 檔 | 內容 |
|---|---|
| `docs/measurements/2026-09-18-freeze-sample-12days-seed{1337,42}.txt` | 兩輪原始輸出（★兩輪的 `[TREE]` 都印 `HEAD=f77d0670f scripts-dirty=0`） |
| `docs/measurements/2026-09-18-freeze-sample-two-round-table.txt` | 對照表 |
| `scripts/debug/freeze_two_round_table.py` | ★**對照表的產生器** |
| `scripts/debug/freeze_sample_bed.gd` | 三行候選表 ＋ ② 的母體修正 |

★**產生器為什麼要進 repo**：那張表若是我手抄的，它就是一份**沒有人能重算的東西** ——
而我先前**兩次手推數字都推錯**（84/94、−86／−87.2%）。★★它自己第一段是**前提檢查**：
兩份輸出若**不是同一支床**／**不同窗口**／**seed 相同**，它就直接印紅字，而不是安靜地產出一張看起來很正常的表。

# 二、★兩件我自己踩到、已經修掉的（都是**表的可讀性**，不是數字）

1. ★★**② 那一行原本是恆真的**：我寫「total 最大的非-multi 相位」，
   而 **total 最大的永遠是【根】**（`loop1.factions` 的 total ＝ 整個 FactionAI）
   ⇒ 那一行會恆等於「全部」。★改成在**印出來的那批候選裡**比。
2. ★★★**`①②③` 在這條輸出管道裡會【整個消失】**：三天煙霧跑印出來是「`／ ＝ 2.49×`」
   —— 數字在、**行號不見了**。⇒ 改用 `[1][2][3]`。
   ★**這跟你今天那條「沒註冊 ＝ 沒人跑」是同一族的下一格**：
   **一張要拿來裁決的表，它的行號有沒有【活著送到讀的人面前】，跟數字一樣重要。**

# 三、閘

★**我沒有自己跑全閘**（那是你的那一下）。我跑過的：
- `freeze_sample_bed` 煙霧跑（`FS_DAYS=5 FS_SEED=1337`）⇒ 13 個凍結幀、三行候選表印出、`[FAIL] ＝ 0`
- 兩輪 12 天 ⇒ 各自 `[FAIL] ＝ 0｜[不可判] ＝ 0`

★★**註冊表那兩行**（`phase-tree-net-cost`／`phase-root-conservation`）在第一顆裡，
⇒ 你跑全閘時它們**這次會被跑到** —— 這正是這支 branch 想解決的那件事。
