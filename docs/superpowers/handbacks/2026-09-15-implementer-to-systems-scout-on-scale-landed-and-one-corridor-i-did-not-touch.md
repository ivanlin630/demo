---
from: implementer
to: systems
status: consumed
topic: ★**件③偵查進秤已落地**（branch `feat/attack-currency-scout` @ `7e2594d33`，驗收床五格三組成對在 1 天窗全綠）｜★★**要你裁一條我沒動的走廊**：`faction_ai_system.gd:482` 那條 dispatch-time scout（argmax 選了攻擊 → `confident_enough` 為假 → 直接 `try_set(TASK_SCOUT)`）—— spec 的「禁走廊」講的是**型別排除之後**那條（已確認乾淨），這條是另一件事，而**偵查進秤之後它是不是變成同一個病，是你的裁**｜★★★**30 天真窗仍在跑，數字未到手**（本信不含任何 30 天結論）
---

# 件③ 落地 + 一條我沒動的走廊

## 一、落地了什麼（exact path，全在 `A:/GDS/demo/.worktrees/atkcur`，branch `feat/attack-currency-scout`）

| commit | 內容 |
|---|---|
| `2fb04827e` | 件①②（先前已報）：belief 估值改 coin 當量；低情報目標**結構排除**出攻擊候選 |
| `674325adf` | 件③：`偵查` 進主 argmax |
| `62dddf3d3` | 件③ 修：`偵查` 的 `applicable` 拿掉 `can_send_scout`（語意錯配，見下） |
| `7e2594d33` | 驗收床 `scripts/debug/scout_on_the_scale_bed.gd`（`@bed-kind: acceptance`）+ 偵查／攻擊同尺 util 直方圖 tap |

### 件③ 的三個接線點

- `scripts/simulation/decision/options.gd:545` —— REGISTRY 新增 `"偵查"`。
- `scripts/simulation/decision/decision_context.gd:295` —— 抽出 `static pick_recon_target(state, team)`（純讀、零 RNG、不寫 state）。
  ★★★**抽出來的理由不是整潔**：`to_task` 拿不到 ctx，若兩邊各挑一次，
  **【秤比的目標】與【派出去的目標】可能不是同一個** —— 而**那種不一致不會有任何東西紅**，
  它只會讓決策與行為默默分家。所以 `gather` 與 `to_task` **呼叫同一支**。
- `scripts/simulation/decision/terms.gd` —— `recon_value` term + `weight("recon")`。

### 折現：照 spec 走既有磚，不是自己乘一個數

`value = prior × δ^days`：

- δ ＝ `DiscountedFlow.delta_of(leader.values)`（讀**慎重**，不是貪婪）。
- `days` ＝ `GoalResolver._tiles_per_day(state, team)` 導出（**單一計算點，內部用每格 tick 成本**）。
  ★我第一版寫的是 `prior / hex_dist`，那不是折現、而且**把格數當天數會差一個速度倍數**（MOVE_TILES 那條單位鐵則）。已改掉。
- ★★**我還拿掉了自己在 term 裡多乘的那一層人格**（原本 `_rmod` 又乘一次「慎重」）——
  慎重已經在 δ 裡了，**同一個人格數對同一件事算兩次**就是 crank。
  人格改走 `weight("recon")`＝計謀↑重情報／好戰↑懶得偵，**不碰慎重**。

### 一個我自己抓到的語意錯配（`62dddf3d3`）

`applicable` 我原本寫 `ctx.can_send_scout`。但那道閘問的是
「有沒有多的 named 可以派**斥候子隊**」（`named_members >= 2`），
而本 option 的 `to_task` 是**整隊自己走到 belief_pos**。★**兩者不是同一件事**；
更重要的是：**【整隊走一趟】的代價，正是它該在秤上輸掉的理由，不該在 `applicable` 裡先擋**——
先擋等於把「輸」偽裝成「不可選」，而驗收要求這兩桶**分開數**。

## 二、★★★要你裁的：一條我**沒有動**的走廊

`scripts/simulation/faction_ai_system.gd:482`（在 `_commit_conquest_attack` 裡）：

```gdscript
if not BeliefSystem.confident_enough(state, team.team_id, prey_id, _caution):
    ...
    if TaskArbiter.try_set(state, team, TeamData.TASK_SCOUT, scout_pos, TaskArbiter.PRIO_DISPATCH, "scout"):
```

**為什麼我沒動它**：

1. spec §③ 與派工信的原話是「**不得在排除之後**直接 `try_set(TASK_SCOUT)`」。
   ★型別排除那一側**已確認乾淨**：`attack_scan` 的排除只有 `continue`（`faction_ai_system.gd` 的
   `no_priced_belief` 分支），排除之後**沒有任何 dispatch**。
2. `:461-465` 的既有註解明寫它是「cascade 溶解後保留的 **means-end 機制**（世界規則非判斷器）」
   ⇒ 動它是**改設計**，不在票裡。★我不自己擴票。

**為什麼還是要你看**：偵查現在進秤了，這條路的形狀變成
「argmax 選了攻擊 → code 自己換成偵查」——**秤沒有比過這一次替換**。
那與票要消滅的病同形，只是發生在**排除之後**而非**之前**。

**這不影響本票的讀數**（先講清楚，免得你以為要先裁才能收）：兩條路在 code 上分得開 ——
走廊那條 `task_reason = "scout"`；秤那條走引擎統一 `try_set`（`task_reason = "unified"`，
且 `team.current_option == "偵查"`）。驗收床 §B 數的是 `optpool.cand.偵查` / `optpool.win.偵查`，
**那是 argmax 候選集的結構事實，走廊根本不進這個母體**。

## 三、驗收床：五格、三組成對（`scripts/debug/scout_on_the_scale_bed.gd`）

- **§A 逐筆 fixture**（①②⑤）：★**同一個 (觀察者, 目標) 對**走三個情報狀態：
  全盲 → 只有桶號 → 有可定價分項。
  - ★★選對是挑**距離最近的異派系對**，因為 `attack_scan` 的排除順序是
    `same_faction → no_belief → belief_pos → unreachable → 才輪到 no_priced_belief`
    ⇒ **隨便抓一對會先死在 `unreachable`，而那時①看起來還是綠的** —— 綠的理由卻是錯的。
    （★這正是我第一次跑出來的三紅，不是猜的。）
  - 所以①**不只驗「不在候選集」**，還驗 `why["no_priced_belief"] >= 1`；
    並加一格**方向相反**的成對自檢（①②同綠或同紅 ⇒ 判準沒有鑑別力）。
  - ⑤逐筆：`blind=true` →（給桶號）`blind=false` →（給 coin/food 估值）**不再是偵查候選**。
- **§B 真世界一趟**（③④）：母體 ＝ `optpool.cand.偵查`（★候選集這個**結構事實**，
  不是隊的情報標籤 —— 否則【生成失敗】會混進【生成後輸掉】）。
  早窗 ＝ **第 0 天起算**的前 N 天；晚窗 ＝ 全窗 − 早窗（**同一趟的前綴／後綴**
  ⇒ 中途不 reset Probe，沒有 reset 的效應不對稱問題）。
  ③若勝率 **100% ⇒ 判紅**並具名「走廊換了個皮」；母體 0 ⇒ 具名**不可判**，不是綠。
- **單位**（spec §3）：偵查與攻擊的 util 用**同一組桶界**並排印
  （`uhist.<opt>.<bucket>` / `usum.` / `un.`）—— ★fire 率答不出「是不是輸得很慘」。

### 目前有的、與還沒有的

- ✅ **1 天窗（SC_TICKS=1440、早窗 1 天）全綠，5 格 0 紅**。
  ★但那個窗**早窗 ＝ 全窗**，④那一格在該窗**是退化的** ⇒ 我不拿它當④的證據。
- ⏳ **30 天真窗（SC_TICKS=43200、SC_EARLY_DAYS=7）此刻仍在跑**
  → 落地 path：`C:/Users/I12/AppData/Local/Temp/.../scratchpad/scout_bed_30d.txt`，
  **跑完我會另寄一封帶數字的信，並把輸出搬進 `docs/measurements/`（`.txt`，非 `.log`）**。
  ★★本信**不含任何 30 天結論** —— 數字沒到手之前寫「已驗」就是我犯過的那條
  「**已請＝宣告不是事實**」。

## 四、還沒做的兩件（不是卡住，是排序）

1. **rebase**：本 branch base ＝ `7ba03814c`，而 main 已到 `5a762ba2a`（票乙 merge 後）。
   ★**跑測期間不動被量的樹**（gen4 那次的教訓）⇒ 等 30 天窗跑完立刻 rebase 再跑閘。
2. **merge-gate 註冊**：`scout_on_the_scale_bed` 要不要進 `docs/process/merge-gates.tsv`，
   ★我不自己加（**不要一直加閘**是用戶的規矩，而且註冊表是你的 owner 範圍）—— 你說加我就加，含 `expect`。

## 五、要你回的，就兩件

1. `faction_ai_system.gd:482` 那條 dispatch-time scout：**保留／拆掉／另開票**？
2. 驗收床**進不進註冊表**？
