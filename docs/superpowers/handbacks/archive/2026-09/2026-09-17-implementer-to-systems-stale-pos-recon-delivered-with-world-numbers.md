---
from: implementer
to: systems
status: consumed
slice: 過期位置 → 偵查分池（feat/stale-pos-recon）｜**交件，請走 R²**
topic: ★**六格全綠**（fixture 五格 ＋ 世界級格4 真跑 10 天）｜★★**世界尺度的數字比我預期大**：`recon.eligible=137596`，**其中位置過期 80927（59%）** —— 這 8 萬次在本票之前**全部被那一行 `continue` 丟掉**｜★★★**而絕境那一格很小且誠實**：母體（餓且有牙的隊天數）＝11、其中偵查有候選 10、**候選本身是位置過期的 3**、**當天 task 就是偵查 ＝ 0**（spec 說不要求它贏，我沒有把它講成贏）｜★**一個空桶要講明**：`recon.skip.claim_without_pos ＝ 0`、`recon.age_unknown ＝ 0` —— 那一類在這個世界**從未發生**，它現在是**守衛不是發現**｜★閘已註冊 `stale-pos-recon`（expect 釘住【不可判 ＝ 1】）

# 一、樹與床的身分（★你立的規矩：樹 sha 不夠，要標床的 commit）

| 欄 | 值 |
|---|---|
| 床 | `scripts/debug/stale_pos_recon_bed.gd` |
| **世界級那一輪的床 commit** | **`c22dd69a1`**（床自己印的 `[TREE] HEAD=c22dd69a1 scripts/simulation-dirty=0（clean）`） |
| 參數 | `BED_WORLD=1 BED_DAYS=10 BED_SEED=1337 BED_CONFIG=warring_states GODOT_TIMEOUT=3000` |
| 原始輸出（已落地） | `docs/measurements/2026-09-17-stale-pos-recon-cell4-world-10days.txt`（6214 行） |
| branch | `feat/stale-pos-recon` ＝ **`9ccfa13c2`**，已 push（`ls-remote` 與本地 sha 逐字相同） |

# 二、數字

## 格4（世界級，10 天）
```
母體（餓且有牙的隊天數）      = 11
  其中 偵查有候選             = 10
  其中 候選【本身就是位置過期】= 3     ← ★本票打的就是這一格
  其中 當天 task 就是偵查      = 0     ← ★★偵查【上場】但沒有贏，spec §3 格4 原話「不要求它贏」
三筆樣本（逐筆）：
  day=5  team=27 food_days=1.11 候選=21 value=32.79 現在的 task=掠奪
  day=6  team=27 food_days=0.11 候選=21 value=19.40 現在的 task=掠奪
  day=10 team=10 food_days=1.68 候選=21 value=10.45 現在的 task=逃跑
```
★**我不把「task=掠奪」讀成壞消息**：那兩天它**確實有掠奪可打**（本票沒有、也不該把偵查推到贏）。
★★**但也不要反過來讀成好消息** —— 這三筆只證明**它進了候選集**，不證明世界因此多了一場戲。

## 世界尺度（production 自己在跑決策時寫的計數，不是我的迴圈寫的）
```
recon.eligible                = 137596
  其中 位置已過期             =  80927   ← ★★★59%
recon.skip.no_claim           = 343195
recon.skip.claim_without_pos  =      0
recon.age_unknown             =      0
```
★**59% 這個數字的意思**：偵查候選評估裡，**每三次有兩次**的目標是「我知道它是誰、知道它三天前在哪」——
**而本票之前這 8 萬次全部在 `pick_recon_target` 那一行被丟掉。**

# 三、★要講明的兩個空桶（★★它們是【守衛】不是【發現】）

`recon.skip.claim_without_pos ＝ 0`、`recon.age_unknown ＝ 0`。
⇒ ★**「有 claim 但從未有過 `tile_pos`」這一類，在這個世界的這 10 天裡一次都沒發生。**
   我**只在 fixture 裡造得出它**（格2b 綠，而且有成對的對照：補上 `tile_pos` 就變成候選）。
⇒ ★★**所以那個名字現在守的是一個空桶** —— 它與 `belief_system.gd:229` 那顆
   `freshness.firsthand_no_tile_pos` 是同一族：**等式斷掉的那一刻它才會非 0。**
⇒ ★★★**而我不會因為它是 0 就說「那一類不存在」** —— `record_claim` 的註解與 `known_issues:784`
   都寫著轉述型 claim 可能不帶位置；**0 的意思是「這個窗口沒遇到」，不是「不可能」。**

# 四、閘（已註冊）

`docs/process/merge-gates.tsv` 新列 `stale-pos-recon`：
```
BED_WORLD=0 powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/stale_pos_recon_bed.gd
expect: 量測完成；\[FAIL\] 數 ＝ 0｜\[不可判\] 數 ＝ 1
```
★**為什麼閘裡那一格是【不可判】而不是跳過**：世界級那段要 **~30 分鐘**
（實測 `warring_states` 到第 9 天 1800 秒、隊數 69→101、avg tick 36ms→239ms、**max 22 秒/tick**）
⇒ 放進每輪都要跑的閘，結果會是「大家不跑這一支」。
★★**跳過會讓它與【驗過且通過】在畫面上一模一樣** ⇒ 改成 `push_error` 的【不可判】＋ expect 釘住 1。
★★★**哪天有人把那一格拿掉、或改成一個比較容易的問題 ⇒ 這一閘會紅。**

# 五、順手撿到、不在本票的一件事（★只報，不修）

上面那個 `max=22721173 us`（**單 tick 22 秒**）與 `>2s 幀數 207/12960` 是 `TickPerf` 自己印的，
★**它撞到憲法那條「可慢不可卡」**（用戶 2026-09-10 原話：不能接受跑到思考層卡住 5～10 秒）。
★★**我沒有動它** —— 不是本票，也不該由我順手改。**要不要開票是你的格。**

# 六、下一步（照你信裡的鏈）

1. **請走 R²**（reviewer 審交付），CLEAN 之後你 merge —— 我不直推。
2. 後續票（錨定性）我**已經照 spec §6 做完並 commit**：branch `feat/anchoredness-freshness` ＝ `e7e3d9223`
   （基於本票，**沒有混進本票**），六格床 `scripts/debug/anchoredness_freshness_bed.gd` 已寫、
   ★**但 6-e 世界級那格還沒跑** —— 我一次只跑一個 Godot。本票 R² 期間我把它跑掉，跑完另寄一封。
