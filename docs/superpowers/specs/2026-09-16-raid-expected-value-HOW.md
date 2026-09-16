# 掠奪走期望價值 — HOW spec

status: SPEC（待 R²）
from: systems
WHAT 來源: blueprint 裁 2026-09-16（`…-blueprint-to-systems-raid-joins-the-same-currency.md`）——
「搶一把」與「打下來」**該**用同一把秤；差別活在**物理**（搶＝快進快出小收穫低風險立即到手／打＝大收穫高成本招報復），
不活在「一個讀現實一個免讀」。好戰／殘忍照憲法在**人格層**調製。

---

## §0 前提複驗 — ★**我先撤回我自己在呈報信裡寫的一句話**

我對 blueprint 寫「掠奪**不讀贏率**」。**逐字核對後：錯。**

```
掠奪     `terms.gd:315`            cap = clampf(ctx.self_armed_ratio / VIABLE_ARMED_RATIO, 0, 1)
攻擊     `decision_context.gd:975` attack_win_odds = clampf(c.self_armed_ratio / DecisionTerms.VIABLE_ARMED_RATIO, 0, 1)
⇒ ★**逐字相同的式子，兩個名字。**
```
⇒ ★★**所以掠奪缺的不是三樣，是兩樣**：**【搶得到多少】與【多需要】** ——
  **贏率它一直在讀，只是叫 `cap`。**
⇒ ★★★**而這正是今天早上那一顆的鏡像**（`extorted`：同一件事兩個名字 ⇒ 一邊看起來是空的）：
  **這次是【同一件事兩個名字 ⇒ 一邊看起來是缺的】。**
★**第三份同式子**：`terms.gd:536` 也有一份 —— 本票把掠奪那一處改成讀 ctx 既有欄位 ⇒ **三處變兩處**（不另開票）。

## §1 新式子（★**與攻擊逐字同形，只有輸入不同**）

```
攻擊（現行 `terms.gd:276`）：(ATTACK_OPP_LOOT_W × loot + ATTACK_OPP_NEED_W × need) × odds × person
掠奪（本票）：             (RAID_LOOT_W        × take + RAID_NEED_W        × need) × odds × person
```
- `take = richness_compressed(prey_richness_belief × RAID_TAKE_FRACTION, ctx.reference_wealth)`
  ★**同一個壓縮函數、同一個 `reference_wealth`** ⇒ **這就是「同一把秤」的操作定義**（不是形容詞）。
- `prey_richness_belief` ＝ 對 **weak prey**（`_find_weakest_prey`）的 belief，走 `_belief_richness`
  ★**感知鐵律**：讀 belief 不讀真值（與攻擊同一條路徑，不另開）。
- `odds` ＝ **ctx 既有的那個欄位**（見 §0，`cap` 就是它）⇒ **刪掉 `terms.gd:315` 那份重算**。
- `need` ＝ 攻擊那一項**同源**（飢餓時搶得更急）。
- `person` ＝ 好戰／殘忍 **在人格層調製**（憲法；★**不在這裡加常數**）。
- ★**`LOOT_DRIVE_BASE = 1.0` 刪除。**

## §2 ★物理差別放在哪（★★這一節是本票的重點，blueprint 的四個詞逐一落位）

| 物理 | 落在哪裡 | ★為什麼**不是**放在公式的係數上 |
|---|---|---|
| **小收穫** | `RAID_TAKE_FRACTION`（搶走的是**能帶走的那一份**，不是整個聚落的生產基礎） | 收穫小是**世界事實**，不是偏好 |
| **低風險** | ★**目標不同**：掠奪打 `_find_weakest_prey`（最弱），攻擊打 `prosperity_prey`（最富） | ★★**同一條式子餵不同的目標，風險差自己就出來了** —— 不必為掠奪特調一個寬鬆 odds |
| **立即到手** | ★掠奪**不折現**；攻擊的收益是一個**會產出**的聚落 ⇒ 該走 `DiscountedFlow`（★**本票不改攻擊**，見 §4） | 立即 vs 延遲是**時間**，不是權重 |
| **招報復** | ★★★**掛恩怨帳**（`form_feud`／`looted` 已經會寫邊）⇒ **報復成本要從帳上讀，不是填一個常數** | **本票不接**（恩怨帳切片A 還沒落地）⇒ §4 |

## §2b ★★★R² 挖出一個比我講的更底層的事：**贏率根本不讀對手**

R²：`odds`／`cap` **只讀攻方自己的 `self_armed_ratio`** —— 我順著查下去，**事情比那句話更尖**：

```
`winnable`（`decision_context.gd:533`）= self_armed_ratio / perceived_power_ratio
  ★**belief-based、god-view-free —— 它已經存在。**
讀它的人：**逃跑**（`terms.gd:174`）、**迎戰**（`:468`）、**求和**（`:478`）
★★**全是【別人來打我】那一側。**
而**攻擊**（`attack_win_odds`）與**掖奪**（`cap`）都不用它，
用的是 `self_armed_ratio / VIABLE_ARMED_RATIO` —— **完全不讀對手。**
```
⇒ ★★★**別人來打我，我會看對方多強；我要去打別人，我不看。**

★**而修法不是「改讀 `winnable`」** —— `perceived_power_ratio` 是對【威脅來源】算的
（`:468`，`ThreatAssessment._power_ratio(state, team, _ot)`），**不是對【我要打的那個目標】**。
⇒ 真正的修法＝**對攻擊／掖奪的目標另算一次 `_power_ratio`**。

### ★★本票【不】做這件，而我要寫清楚為什麼
```
① 它同時改變**攻擊**（本票說好不動攻擊）⇒ 兩邊同時動＝**分不清誰造成差異**
② ★**而【盲】是共用的** ⇒ **不影響本票的目標（同一把秤）** ——
   兩者用同一個盲的 odds，**比值仍然是對的**；它使兩者**同向**偏誤，不使它們偏到不同的秤上。
③ ★★★**但它讓驗收格3 的「同量級」只能證明【尺】相同，不能證明【值】對** ——
   **這一句要進交件，不要讓下一個人拿格3 綠了當成「贏率也對了」。**
```
⇒ **開成下一張（統一軌遷移序）**：`odds-must-read-the-target`。

## §3 驗收床（每格能紅）
| # | 格 | 會紅的那一半 |
|---|---|---|
| 1 | 富 prey vs 窮 prey，其他固定 ⇒ **掠奪 util 分化** | 相同 ⇒ 還是常數驅力 |
| 2 | 同一 prey，自己餓 vs 不餓 ⇒ util 分化 | 相同 ⇒ need 沒接 |
| 3 | ★**掠奪與攻擊對【同一個目標】** ⇒ 兩者 util **同量級**（比值落在 `RAID_TAKE_FRACTION` 附近） | 差 4–10 倍 ⇒ 還在兩把秤上（★**這格就是本票的目的**） |
| 4 | 無牙（armed_ratio≈0）⇒ 掠奪 util ≈ 0 | 非 0 ⇒ odds 沒接上（★對照：舊制 `cap` 也做得到這件事，**所以這格不是新功能，是不准退步**） |
| 5 | ★人格（好戰／殘忍）只改 **weight**，不改 `take`／`need`／`odds` 任一項 | 人格漏進秤裡 ⇒ 違憲法 |
| 6 | ★**tap**：`raid.take` / `raid.need` / `raid.odds` / `raid.util` 逐筆可 dump | 缺任一 ⇒ 違「全量暫態可觀測性」 |
★**母體要報**：每格印「樣本數 ／ 母體」。**全 0 是母體塌陷，不是答案。**

## §4 不在本票（寫出來讓「沒做」可被看見）
- **攻擊側的折現**（`DiscountedFlow`）：★**本票只把掠奪搬上秤**；**同時動兩邊 ⇒ 分不清誰造成的差異**。
- **報復成本讀恩怨帳**：等切片A 落地（`2026-09-16-grudge-ledger-sliceA-HOW.md`）。
- `terms.gd:536` 的第三份 `cap` 重算：**不動**（它不在本票的路徑上）。

## §5 我沒有決定的
- `RAID_TAKE_FRACTION` 的值 ★**不要手填** —— 從世界推：**一次掠奪實際搬走多少**
  （戰鬥結算的 loot 轉移量 ／ 對方資產）⇒ **若那條路徑拿不出數，回報我，不要挑一個 0.2**。
