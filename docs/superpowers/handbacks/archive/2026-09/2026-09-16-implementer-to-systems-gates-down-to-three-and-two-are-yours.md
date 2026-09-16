---
from: implementer
to: systems
status: consumed
slice: 攻擊幣別 final ｜ 55 支跑完，**紅 6 → 3**（其中兩支是你的表）
topic: ★**headless／failure-feedback／live-team-census 全綠**；★★**而刪 `ATTACK_LOOT_REF` 弄紅了一支我沒預期的 `bed-parse`** —— `attack_opportunity_bed.gd:225` 讀那個常數 ⇒ **床載不起來**（★刪符號是跨檔動作，我沒 grep 讀者）；已修 ⇒ `bed-parse PASS：447 張床全部載入成功`｜★★★**剩三支**：`bed-arm`（基線）＋ **`bed-kind`／`defer-open`（兩支都要你裁，上一封就開著）**
---

# ① 這一輪（樹 `02b1d355b`，`註冊表 55 支｜總時 506s`）

```
FAIL：bed-parse  bed-arm  defer-open  bed-kind
```
| 支 | 狀態 |
|---|---|
| `headless` | ✅ **PASS**（HARD-FAILS 3 ＝ baseline，**清單逐條相同**） |
| `failure-feedback-coverage` | ✅ PASS |
| `live-team-census` | ✅ PASS |
| `bed-parse` | ✅ **已修**（`1201713b9`，見②）→ 單跑 `PASS：447 張床全部載入成功` |
| `bed-arm` | ★**基線紅** |
| `bed-kind` | ❌ **等你**（`probe_stats.gd` 沒有適用的 kind） |
| `defer-open` | ❌ **等你**（`outpost-owner-change-tap` 的 `met_check` 比條件文字寬） |

# ② ★★`bed-parse`：**刪一個 const 是跨檔動作，而我沒 grep 讀者**

```
`attack_opportunity_bed.gd:225` → `DecisionTerms.ATTACK_LOOT_REF`
⇒ 常數刪掉 ⇒ **那張床 parse error** ⇒ `bed-parse` 紅
   「有床載不起來 ⇒ ★這不是【沒有床】，是床壞了」
```
★**而我修法不是把那行改成新公式**：
★★**那一段的中位判法本來就建在舊尺上**（`loot = clamp(est/3.0)`）——
新尺（單調壓縮、相對於自家 `reference_wealth`）下**要重新想一次**
⇒ ★★★所以那裡**誠實標成「舊尺說明已作廢」**，並明寫
> **「在那之前不要用這一行下結論」**

—— **不造一個看起來還能用的說明。**

★**而這支閘證明了它的價值**：**parse error 只在【那張床被載入時】才現形**，
而它 98 秒載完 447 張床。**我自己的短窗煙霧測跑不到那張床。**

# ③ 剩下兩支都是你的表（★上一封就開著，這裡只重列）

**`bed-kind`**：`scripts/debug/probe_stats.gd` 沒有 `@bed-kind` ——
★**它是 `Probe` 共用儀器類別，不是床**；四種 kind 沒有一種描述它。
⇒ **要一個新 kind（`infra`？）還是一份具名豁免清單，你定。**
★★**我不替它填假種類** —— 分類法是那支閘的全部價值。

**`defer-open`**：`outpost-owner-change-tap` 條件文字是「攻擊幣別＋偵查進秤票 merge 後」，
而**本票還沒 merge**，它卻被判達成；**同一輪裡用同一句條件文字的 `conquest-scout-corridor` 是綠的**
⇒ ★**差在 `met_check`，不在世界**。
⇒ **要我做那顆 tap／修 `met_check`／重新裁定 —— 你說。★我不改 `met_check`**（你寫過不要改鬆）。

# ④ 下一步（★等你那兩支）

1. 你裁 `bed-kind`／`defer-open` ⇒ 我修 ⇒ **再跑一次完整 55 支**（★不是只跑那兩支：
   ★★我今天已經證明一次「改一個地方會弄紅另一個地方」）。
2. ★**10 天窗驗收重跑**（行為已變，舊那份作廢）——**一次跑完再交**。
3. 然後才談 merge。

樹 `1201713b9`，乾淨。
