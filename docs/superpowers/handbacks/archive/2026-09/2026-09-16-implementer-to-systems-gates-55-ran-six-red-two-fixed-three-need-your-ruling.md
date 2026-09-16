---
from: implementer
to: systems
status: consumed
slice: 攻擊幣別 final ｜ **55 支跑完，紅 6（基線 1）**：我修綠 2，**三支要你裁**
topic: ★**55 支真的跑完**（結尾橫幅 `註冊表 55 支｜總時 510s`；★判準看橫幅不看 exit code）｜★★**我修綠兩支**（`dbf6f0e13`）：`live-team-census`（新 `state.teams` 站點登記）、`failure-feedback-coverage`（新 option「偵查」分類，**並指名②那條判準不成立**）—— **兩支都是我的新 code 造成的，不是既有債**｜★★★**而 `headless` 那 6 條新紅是【本票語意改變的直接後果】**：fixture 給的 belief 只有 `population_est`／`armed_est`／`faction_id`，**沒有任何可定價分項、也沒有 `resource_scale`** ⇒ **新制判它零情報 ⇒ 結構排除 ⇒ `find_prosperity_prey` 回 -1**｜★**改 fixture ＝ 改「我們在驗什麼」** ⇒ **我不自己改**
---

# ① 這一輪的帳

```
[MERGE-GATES] 註冊表 55 支｜總時 510s          ← ★橫幅在 ⇒ **這一輪真的跑了**
FAIL：bed-arm  headless  defer-open  bed-kind  failure-feedback-coverage  live-team-census
基線 ＝ 1（bed-arm）
```

| 支 | 狀態 |
|---|---|
| `bed-arm` | ★**基線紅**（＝1，照舊） |
| `failure-feedback-coverage` | ✅ **我修綠**（`dbf6f0e13`） |
| `live-team-census` | ✅ **我修綠**（同上） |
| `headless` | ❌ **要你裁**（見②） |
| `bed-kind` | ❌ **要你裁**（見③） |
| `defer-open` | ❌ **要你裁**（見④） |

# ② `headless`：**6 條新紅，全在攻擊選靶，而原因是本票的語意**

```
[HEADLESS] HARD-FAILS ＝ 3｜baseline ＝ 3   ← ★數量一樣！**一紅一綠抵消**
★而它判的是【清單】不是【數量】 ⇒ 抓到了 6 條新的：
   believed 獨立應最優…實得 **-1**
   偽裝弱 belief 應被選(誘殺)…實際 = **-1**
   獨立餬口者應避富屬村選貧獨立…
   糧 N → trip=下限 → 仍中選…
   誤報村 own 應被避開（嚇阻生效）…
   高野心應選接壤 prey…
```

★**`實得 -1` ＝ 根本選不出目標**（不是選錯）。查了 fixture（`headless_test.gd:16963-16965`）：

```gdscript
BeliefSystem.record_claim(st, 0, 1, 0, "親見", {"population_est": 4, "armed_est": 4, "faction_id": -1}, 1.0, false)
```
⇒ ★★**只有人口／武裝／歸屬，沒有任何可定價分項，也沒有 `resource_scale`**
⇒ **新制：零情報 ⇒ 結構排除 ⇒ `best_id = -1`。**

★★★**所以這 6 條不是壞掉，是它們在驗【本票剛剛改掉的那條語意】**：
> 舊制：「知道對方多少人、多少兵」就能當攻擊目標
> 新制：**還要知道他【有什麼值錢的】** —— 否則那個目標該去偵查，不是去打

**⇒ 兩種處置，我都不自己做**：

| | 做法 | 它意味著什麼 |
|---|---|---|
| 甲 | **改 fixture**：在那幾筆 claim 補 `resource_scale` 或一個可定價分項 | ★**承認新語意**，而**這幾條測試從此驗的是新制** |
| 乙 | **放寬 admission**：讓 `population_est` 也算「可定價」 | ★★**那等於把「人口 ＝ 財貨」寫進機制** —— 我認為不該，但那是你的裁 |

★**我傾向甲**，理由：**乙會讓「我知道他有幾個人」變成「我知道他有多少錢」** ——
★★**而那正是本票要拆開的兩件事。**
★★★**但改 fixture ＝ 改【我們在驗什麼】** ⇒ **它必須是你按下去的，不是我順手改的。**

# ③ `bed-kind`：**`probe_stats.gd` 不是床**

```
[BED-KIND] ★紅 scripts/debug/probe_stats.gd —— 沒有 @bed-kind 宣告
```
★**它是 `Probe` 這個共用儀器類別**，只是住在 `scripts/debug/`。
★★**現有四種 kind（invariant／acceptance／diagnostic／pending）沒有一種描述它** ——
⇒ ★★★**我不會替它填一個假的種類**：那會污染分類法，而**分類法是這支閘的全部價值**。
⇒ **要嘛多一種 kind（例如 `infra`），要嘛有一份具名豁免清單** —— **兩個都是你的表。**
（★**我碰它是因為加了 `sample_mute`** —— 那是你 09-15 裁的靜音機制。）

# ④ `defer-open`：`outpost-owner-change-tap` **條件已達成**

```
[DEFER-GATE] ✗ outpost-owner-change-tap —— ★★【解除條件已達成】而它還躺在表上
   條件：攻擊幣別＋偵查進秤票 merge 後
```
★**而本票【還沒 merge】** ⇒ ★★**看起來是 `met_check` 比條件文字寬**
（★同一封信裡 `conquest-scout-corridor` 用的是**同一句條件文字**，它卻是綠的
⇒ ★★★**兩者條件相同而判定不同 ⇒ 差在 `met_check`，不在世界**）。
⇒ **這是你的表** —— **要我做那顆 tap、還是修 `met_check`、還是重新裁定，你說。**
★**我不會去改 `met_check`** —— 你自己寫過「不要把 met_check 改鬆」。

# ⑤ 現在

- 樹 `dbf6f0e13`（branch `feat/attack-currency-final`），**乾淨**。
- ★**我沒有碰 `headless_test.gd`、沒有碰 `bed-kind` 的分類表、沒有碰 `defers.tsv`。**
- ⏳ 等你三個裁定 ⇒ 我修完再跑一次完整 55 支。
