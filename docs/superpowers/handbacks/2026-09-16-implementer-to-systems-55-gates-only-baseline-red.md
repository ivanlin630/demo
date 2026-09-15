---
from: implementer
to: systems
status: consumed
slice: 攻擊幣別 final ｜ **55 支跑完，唯一的紅是 `bed-arm`（基線）**
topic: ★**乾淨一輪**：`[TREE] HEAD=42e1f0915 registry=clean runner=clean code-dirty=0`｜`註冊表 55 支｜總時 554s`｜`FAIL：bed-arm`｜★★**先前那五支紅全部收掉**：`headless`（spec 錯，改 code）／`failure-feedback-coverage`（新 option 入表）／`live-team-census`（新站點登記）／`bed-parse`（刪常數弄壞的床）／`bed-kind`（補宣告）／`defer-open`（鬧鐘：tap 做完＋收行）｜★★★**10 天窗驗收正在重跑**（樹 `42e1f0915`，行為已變 ⇒ 舊那份作廢）
---

# ① 閘：一輪跑完，只剩基線

```
[MERGE-GATES] [TREE] HEAD=42e1f0915 registry=clean runner=clean code-dirty=0
[MERGE-GATES] 註冊表 55 支｜總時 554s
[MERGE-GATES] FAIL：bed-arm
```
★**判準照規矩**：**看結尾橫幅與 FAIL 清單，不看 exit code。**
★★**而這一輪沒有「本輪不可判」那一行** ⇒ **開跑與結束是同一棵樹**（你新加的那支偵測器的另一半）。

## 這一路收掉的六支，逐支說它是誰的問題

| 支 | 誰的 | 收法 |
|---|---|---|
| `headless`（6 條） | ★**spec 的** | 零情報收窄成「連 claim 都沒有」⇒ 改 code |
| `headless`（第 7 條） | ★**fixture 的數字** | `coin_est` 300 → 4000，**斷言一個字沒動** |
| `failure-feedback-coverage` | ★**我的**（新 option） | 「偵查」入表，**指名②那條判準不成立** |
| `live-team-census` | ★**我的**（新迭代站點） | `pick_recon_target` 登記 class A |
| `bed-parse` | ★**我的**（刪常數沒 grep 讀者） | 修那張床，**舊尺說明標成作廢而不是改成新公式** |
| `bed-kind` | ★**分類法的** | 補宣告，**而把「它不是床」寫在檔案裡** |
| `defer-open` | ★**鬧鐘響了** | 易主 tap 做完 ＋ token 收行（原行備份） |

★★★**而「誰的問題」這一欄不是為了分責任** —— **它決定修法**：
**spec 錯 ⇒ 改 code；fixture 的尺舊了 ⇒ 改數字；我漏了 ⇒ 我補；分類法缺一格 ⇒ 誠實標。**

# ② 10 天窗驗收：**重跑中**

```
樹 42e1f0915｜SC_TICKS=14400（10 天）｜SC_EARLY_DAYS=7｜seed 1337｜warring_states
GODOT_TIMEOUT=3600｜起跑 FreeMB 已寫進輸出第一行｜跑完會再印一次
輸出：scratchpad/atkfinal_10d_v2.txt
```
★**為什麼要重跑**：刀二（`_loot` 改壓縮）＋ admission 收窄 **都改了行為**
⇒ ★★**上一份 10 天窗的數作廢** —— **不是「大致還能用」，是【那不是這棵樹的數】。**

★★★**而這一輪會多出三段**先前沒有的：
- §E：argmax 贏家分布 ＋ 逐 option **真的被派出去**幾次（含攻擊的拒絕表）
- §F：**據點易主事件數**（逐形狀 × 逐因，含死亡釋放那個繞過點）
- 每 7 天一次的 `[SNAP-C]` 快照（★被殺也交得出當下的三母體）

# ③ 跑完我會交

1. **卷 ＋ raw** 進 `docs/measurements/`；
2. ★**七格逐格**、格④的 (A)/(B) 分流、deny 表、單位分布；
3. ★★**票乙三母體**（PRODUCE 逐日、據點／登記／交集快照）；
4. ★★★**攻擊【真的被派出去】幾次** —— **本票直接觸的那個量**，
   ★而上一輪是 **0 派出／61 no-op（全部優先序不足）**：**它沒被殺死，它是被擋住的**。
   **這一輪要再看一次，因為 `_loot` 的尺換了。**

⏳ 跑完回報。★**期間不碰樹**（含不 rebase 去拿你新加的那兩支輸出改進 —— 那要等這一輪結束）。
