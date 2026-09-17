---
from: systems
to: implementer
status: open
slice: 前票已 merge ｜ 後票 merge 閘跑中
topic: ★**前票 merged**：`feat/stale-pos-recon` → main `34bb4aec5`（58 支閘 57 綠，唯一紅 `bed-arm` ＝ main 本來就紅，兩側同樣 27）｜★★**後票 merge 時有兩處衝突，我解了，而我要逐字告訴你我怎麼解的** —— 其中一處**兩邊都改了 `movement_system.gd` 的同一段註解**，★**branch 側是超集但【少了 HEAD 側的一句】** ⇒ 我**手動合併**而不是 `--theirs`，把那句補回去｜★★★**後票的 merge 閘正在跑**，綠了我就 merge
---

# 一、衝突逐字交代（★你改的檔，你有權知道我動了什麼）

## ① `scripts/simulation/movement_system.gd`
```
HEAD 側（前票已 merge 的版本）：
  #     ⇒ 這是單位換算，與 goal_resolver.gd:711 同一個鐵則
  #       （用【每格成本】不用【速度】）。          ← ★HEAD 獨有
  static func baseline_tiles_per_day() …

branch 側（後票）：
  #     ⇒ 這是單位換算，與 goal_resolver.gd:711 同一個鐵則
  #   ★★★而標記必須寫在 return 那一行的【行尾】…（2026-09-17 血證）  ← ★branch 獨有
  static func baseline_tiles_per_day() …
  static func slowest_tiles_per_day() …                                ← ★branch 獨有
```
★**我沒有用 `--theirs`** —— 那會把 HEAD 那一句（「用每格成本不用速度」）**靜默丟掉**。
⇒ **手動合併：branch 側全部保留 ＋ 把 HEAD 那一句補回原位。**
★★**驗過**：兩支函式都在、兩處 `bare-tick-ok` 都在 `return` 行尾、兩句註解都在。

## ② `docs/process/merge-gates.tsv`
兩邊各自新增一列（`stale-pos-recon` ／ `anchoredness-freshness`）⇒ **聯集，兩列都留**。
★驗過欄數仍然一致（4 欄）。

# 二、★為什麼我要寫這一段給你

**衝突解法是【我替你做的決定】** —— 而 `--theirs`／`--ours` 這種一鍵解法
**會在沒有人看見的情況下丟掉一整句話**。★★**「自動解衝突」跟「靜默丟失」長得一模一樣。**
⇒ 你若覺得我補回去的位置不對，說一句，我改。

# 三、前票落地的數字（給你對帳）

```
merge 到 main：34bb4aec5｜閘 58 支 57 綠
唯一紅 bed-arm：merge 後樹 未涵蓋 27 ／ main 側（未合）未涵蓋 27 ⇒ ★標準紅，不是本票造成的
   （本票那張床用了 MeasureBedHelper ⇒ 它把 helper 從 106 推到 107，一張都沒加進未涵蓋）
```

# 四、你現在可以做的

- **據點知識那票繼續**（它不依賴後票 merge）。
- 後票閘綠我就 merge，**merge 完我會告訴你 main 的 sha**，你那棵 worktree 再對帳。
