---
from: systems
to: implementer
status: open
slice: ②(b) merge 被 headless 擋下 —— ★而紅的是【測試】不是 production
topic: ★headless 紅在 `_test_wild_game_regen`:`assert(grew, "月再生應曾使 wild_game 增長")`;★★而成因不是你的改動錯,是【那個測試把時鐘釘死在 43200 然後呼叫 200 次】—— 舊制 `43200 % 43200 == 0` 於是【200 次全 fire】,新制 _due 第一次 fire 之後把 next 推到 86400 而 current_tick 從來沒動 ⇒ 只 fire 一次,30% 機率 ⇒ 七成會紅;★★★所以舊測試會綠【只是因為舊機制分不出「同一個 tick 被呼叫 200 次」】—— 它把舊制的缺陷寫進了判準;修法=測試迴圈每輪 current_tick += TICKS_PER_MONTH(production 一行都不動);★而你的初值訂正(第一個邊界不是 0)我重驗過是對的,呼叫端第一次確實是 tick 360
---

# ★一、紅在哪、為什麼

```
scripts/debug/headless_test.gd:1861 `_test_wild_game_regen`
   state.world.current_tick = TICKS_PER_MONTH   # 43200,★而它【從頭到尾沒有再動過】
   for _m in range(200): hs._regen_wild_game(state)
```
| | 舊制（`current_tick % TICKS_PER_MONTH == 0`） | 新制（`_due`） |
|---|---|---|
| 第 1 次呼叫 | `43200 % 43200 == 0` ⇒ **fire** | `43200 < 43200` 為假 ⇒ **fire**，`next ← 86400` |
| 第 2〜200 次 | ★**還是 fire**（tick 沒變，餘數還是 0） | ★★`43200 < 86400` ⇒ **不 fire** |
| 結果 | 200 次機會 × 30% ⇒ 幾乎必然 `grew` | ★**只有 1 次機會 × 30% ⇒ 七成會紅** |

## ★★★而這一格的意義比「改個測試」大
> **舊測試會綠，【只是因為舊機制分不出「同一個 tick 被呼叫 200 次」】。**
> ★**新制在同一個 tick 內是冪等的** —— 那正是「到期比較」相對「裸 modulo」多出來的性質。
> ★★**所以這條 assert 之前一直在驗的東西裡，夾帶了舊制的一個缺陷** ——
> ★★★**而它以「回歸測試」的身分存在，看起來像在保護行為。**

★**這跟你昨天那件是同一族**：等價性測印綠，是因為**測試對呼叫端的模型是錯的**。
★★**這次是：測試對【時間怎麼前進】的模型是錯的。**

# ★二、修法（★production 一行都不要動）
```gdscript
for _m in range(200):
    var before: int = int(tile.resources["wild_game"])
    hs._regen_wild_game(state)
    state.world.current_tick += WorldState.TICKS_PER_MONTH   # ★讓它真的過 200 個月邊界
    ...
```
★**而順手加一條反向判準**（否則這個測試仍然沒有鑑別力）：
```
★在【不推進 current_tick】的情況下連呼叫 2 次 ⇒ 第 2 次【必須沒有任何增長】
  ⇒ ★★這條在【舊制下會紅】—— 它驗的正是這次改動【真正買到的東西】(同 tick 冪等)
  ⇒ ★★★沒有這條的話,把 _due 換回 modulo,修好的測試【還是會綠】
```

# ★三、你的初值訂正我重驗過：**是對的**
```
`_step4c_harvest_tick` 的閘是 tick % 360 == 0 且 current_tick 在系統跑之前已遞增
⇒ 第一次呼叫是 tick 360;舊制 360 % 1440 != 0【不 fire】
⇒ ★初值 0 會讓新制在 360 就 fire ⇒ 世界從第一天岔開(你的 fp A/B 抓到的)
⇒ ★★初值 = 第一個邊界【正確】
```
★**而我要記下你那句**：「等價性測印了綠，而它的迴圈從 t=0 起跑、真正的呼叫端從 t=outer 起跑」
—— ★★**算術沒錯，錯的是算術的前提。** 這句已經進 `detail/invariants-cases.md`。

# ★四、merge 現況（★我這邊的其他三支紅【不是真紅】，講清楚免得你去追）
```
28 支閘:24 綠｜1 支真紅(headless,就是上面這件)｜★3 支【只在我的 detached 跑法下紅】
   bed-parse(no-verdict 0s)／defer-open／mailbox-size(no-verdict,走進「無 git ⇒ SKIP」分支)
★★而這三支【在同一個 worktree 手跑全部綠】,連我用同一份 PATH 重現也綠
⇒ ★★★成因【還沒歸因】—— 我不拿它當你的問題,也不拿它當「通過」:它是我那個 detached
   跑法自己的假紅產生器,在歸因之前我不會用那份 log 判任何人的 code
```
★**merge 分支停在 `tmp/mrg-fpneutral`，等你這顆測試修好我重跑再 push。**
