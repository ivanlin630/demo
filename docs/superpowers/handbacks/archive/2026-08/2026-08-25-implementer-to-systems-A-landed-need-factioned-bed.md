---
from: implementer
to: systems
status: consumed
slice: harvest-terrain-from-regen
branch: feat/harvest-terrain-from-regen @ WIP
topic: ★A 已實作(手抄表刪除、從 REGEN_RATE 導出、門檻常數一個都沒加、多地形用折現值挑);★headless 8=baseline 0-new;★★但 blueprint 指定的驗收床【factioned 床(236)】不在 main 也不在我這條 branch —— 我不猜它在哪,先用 peaceful_economy 量可驗的部分,同時跟你要床的位置
---

# A 落地 ＋ **要一個床的位置**

## §1 實作（★三個設計問題的答案都不是新旋鈕）

| 問題 | 我的處理 |
|---|---|
| 「哪種地形產哪種資源」 | ★`harvest_terrains(res)` **從 `ResourceSystem.REGEN_RATE` 導出**；**手抄表 `RES_HARVEST_TERRAIN` 已刪**（不是補 food 進去）|
| 「產多少才算可採」 | ★**沒有門檻常數**：`> 0` 即候選。★**`mountain` 的 food 0.5 不需要我拍一個門檻擋掉 —— 它自己會輸給 plains 的 8.0。加門檻＝把【比較】的工作換成【猜一個數】。** |
| 「多地形挑哪個」 | ★**折現值**：`pv(產量) × δ^(路程天數)` —— **遠產地被等待折現天然懲罰**，近而少產的可能反勝。**零新排序表。** |

★**一個我自己挑明的量綱決定**：折現視野 `h` 用**隊自己的存續視野**（`horizon_eff(net_food_flow, food_stock)`），
**不逐候選重算** —— ★**把 material 產量加進 food 淨流去算視野是量綱錯誤**。
`h` 對所有候選相同 ⇒ **排序純由 `產量 × δ^delay` 決定**，這正是要的。

★**B 型也留了 tap 但不處理**：`goal.harvest.not_terrain_produced.<res>`
（地形本來就不產 ⇒ 缺的是【製造】那條手段 ⇒ **你已開成 means-end 磚，不是本票**）。

## §2 閘
| 閘 | 結果 |
|---|---|
| headless | ★**8 ＝ baseline，0-new** ✅（3 `[FAIL]` ＋ 5 `Assertion failed`，`Parse Error` 0）|
| 憲法／det×3 | 跑完 code 定版後一次跑（★**要當證據的 run 跑已 commit 樹、期間不改 code**）|

## §3 ★★我需要的：**factioned 床在哪**

blueprint 指定 acceptance 要「**立刻重量 `dispatch_fail.資源不足`（factioned 床 236）掉多少**」。
★**但那張床不在 `origin/main`，也不在我這條 branch**：
```
config/ 裡沒有 factioned 相關 json
scripts/debug/ 裡沒有對應的 bed
```
⇒ ★**我不猜它叫什麼、也不自己造一張同名的** —— **自造一張「同名不同內容」的床，比沒有床更危險**
（**數字會被當成同一張床的可比數字**）。

★**請給我**：床的**檔名 ＋ 它在哪個 branch／worktree**（或它還沒 push）。

## §4 同時我不空等：先量可驗的部分
用 `peaceful_economy`（我手上有、且**先前 A/B 分佈就是在這張床上量的** ⇒ **同床可比**）：
- ★**food 是否從「不可採」變成真的產出候選**（`goal.harvest.emitted.food`）
- ★**反面：`material` 既有行為不得退化**（`goal.harvest.emitted.material` 應仍在）
- `res_prereq` 出口表是否仍窮盡對帳

★**這不能取代 blueprint 指定的驗收**，只是**我這邊能自己驗的那一半**，且標明是開發回饋。
