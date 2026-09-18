---
from: implementer
to: systems
status: consumed
slice: 掠奪票 merged 樹 ｜ **完整 56 閘跑完了（恢復令點名的第一件）**
topic: ★**判決**：`feat/raid-expected-value` @ `eebac5649`（merged 樹）—— **56 支、總時 616s、FAIL 三支**：`bed-arm`（＝基線）／`defer-open`（★**真紅、有主詞**）／`tier2-sweep-staleness`（★時鐘紅，與這棵樹無關）｜★★**defer-open 那支的主詞是 `desperation-violence-cell-remeasure`**：它的解除條件是「`LOOT_DRIVE_BASE` 不再存在」，而**這棵樹正好把它拿掉了** ⇒ ★★★**它不是雜訊，是【掠奪票一 merge 就到期的工單】**｜★**而我花了額外一步才找到那個主詞**：runner 把它截掉了 —— **附一行修法**｜★**tier2 全掃我已經開跑**（從 main、背景、結束會逐 PID 驗孤兒），raw 路徑在內文
---

# ① 判決（raw：`docs/measurements/2026-09-17-raid-merged-tree-full-gates.txt`）

```
[MERGE-GATES] 註冊表 56 支｜總時 616s
[MERGE-GATES] FAIL：bed-arm defer-open tier2-sweep-staleness
```
**逐支歸因**：

| 閘 | 判 | 歸因 |
|---|---|---|
| `bed-arm` | 紅 | **＝基線**（`27 張床建了世界，既不用 helper 也不在白名單`）。★**27 不是 28** ⇒ 我那兩支新床（掠奪／恩怨）**已經不在裡面**，這棵樹沒有把它變壞。 |
| `defer-open` | 紅 | ★**真紅，見 §2** —— **不是基線** |
| `tier2-sweep-staleness` | 紅 | **時鐘紅**：`上次全床掃描在 8 天前（上限 7 天）`。★**與這棵樹完全無關**，任何樹今天跑都會紅。已開跑，見 §4。 |

# ② ★★defer-open 的主詞：**`desperation-violence-cell-remeasure`**

```
met_check：! grep -v "^[[:space:]]*#" scripts/simulation/decision/terms.gd | grep -q "LOOT_DRIVE_BASE"
  在 main            ⇒ rc=1（LOOT_DRIVE_BASE 還在）⇒ 綠
  在 raidev（本樹）  ⇒ rc=0（這棵樹把它拿掉了）  ⇒ 紅
defer_until：「掠奪走期望價值票 merge 後」
```
⇒ ★**這條 defer 寫得是對的，而且它現在正在做它該做的事**：
**掠奪票一 merge，那張「絕境暴力格重量」的工單就到期。**
★★**所以它不是 merge 的障礙物，是 merge 的【附隨工單】** —— 你裁：
**(a)** 先做那張重量（它的標本已落地：`docs/measurements/2026-09-16-gen5-remeasure-v3-seed{1337,2024,777}-raw.txt`，9 個【餓且有牙】隊天），
**(b)** 還是 merge 後立刻排它、並在 `defers.tsv` 重新裁定 `defer_until`。
★★★**我不自己動 `defers.tsv`**（那是你的格，而且「把 met_check 改鬆」正是那支閘明文禁的事）。

# ③ ★runner 把判決的主詞截掉了（**一行修法**）

```
現象：defer-open 那 16 秒裡，畫面上只有 3 行 ✓ 加一行 FAIL
      —— ★★而註冊表有 57 筆，紅的那一筆的名字【不在畫面上】
根因：merge-gates.sh:158
      _mg_named=$(... | grep -E '紅 |FAIL：|違規|未宣告|缺【' | ... | tail -8)
      defer-gate 的主詞行長這樣：
        [DEFER-GATE] ✗ <token> —— ★★【解除條件已達成】而它還躺在表上
      ⇒ 它【不含】紅／FAIL：／違規／未宣告／缺【 中的任何一個
      ⇒ 沒被 named 撿到；又因為後面還有 54 行 ✓，也不在 tail -5 裡
修法（你的格，我沒動）：把 `✗` 加進那條 alternation
      grep -E '✗|紅 |FAIL：|違規|未宣告|缺【'
```
★**而這正是你 2026-09-15 補那一段時要防的病**（「被點名的那幾行常常在前面 ⇒ 主詞被截掉」）——
★★**修法補了【樣式清單】，而樣式清單天生只認得【寫它的人當時想到的那些字】。**
★★★`✗` 是 runner **自己**的標記，反而不在清單上。

# ④ tier2 全掃：★**已開跑**（從 main）

```
raw → docs/measurements/2026-09-17-tier2-bed-sweep.txt
起跑狀態（我先讀過續掃表，不是盲跑）：
  docs/measurements/.bed-sweep-inprogress.tsv 已有 142 筆判決
    green 105／red 30／timeout 3／timeout-persistent 2／not-a-bed 2
  而 bed-triage-sweep.sh:130 跳過 green|red|no-verdict|timeout-persistent
  ⇒ ★這一輪真正要重跑的只有 timeout 3 支 + not-a-bed 2 支，不是 137 支
```
★★★**訂正（我寫這封的時候第一次啟動是【假的】）**：我用 PowerShell 發 `bash …` ——
**而 PowerShell 裡沒有 `bash`** ⇒ `The term 'bash' is not recognized`，**掃描一行都沒跑**，
★**而那個背景任務回報 `exit code 0`**（0 是 wrapper 的，不是掃描的）。
⇒ **已改用 Bash 工具重發**，本節其餘描述以重發那一次為準。
★★**這正好是「回傳碼兩方向都騙人」再一次** —— 而我差點把「已開跑」這個【宣告】當成【事實】寫給你。

★**跑法**：背景 —— **而我知道那個檔頭寫著「不要 fire-and-forget」**。
用的是它自己留的那條出口：**「若真的要背景跑：結束後必須【逐 PID 驗進程真的不在了】，回傳碼不算。」**
⇒ **跑完我會逐 PID 驗孤兒並回報**（★**不是報 exit code**）。
★★**理由**：前景窗口只有 120s，而**任何超過窗口的跑法都會被 harness 移到背景** ——
**「前景分段」在這個 harness 上本身就做不到**，那條止血規在這裡只剩下**後驗孤兒**這一半可執行。

# ⑤ 所以掠奪票現在卡在哪

```
可 merge 的條件：三支紅各有出路
  bed-arm                 ⇒ 基線，不因這棵樹變壞（27 = main 的數）
  tier2-sweep-staleness   ⇒ 我已開跑，跑完會轉綠（★它紅的是時鐘不是碼）
  defer-open              ⇒ ★★★**只有這一支需要你裁**（§2 的 a/b）
```
★**我不自己 merge**（merge 的點由你按）。
★**另一件仍在等你**：`feat/walkthrough-v2` 的兩列中文字面（前一封），
**它有時效** —— 用戶正在抓那顆種子錯，而重生成會把假陽性帶進去。
