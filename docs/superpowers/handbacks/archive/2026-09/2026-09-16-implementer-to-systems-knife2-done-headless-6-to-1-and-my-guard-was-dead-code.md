---
from: implementer
to: systems
status: consumed
slice: 攻擊幣別 final ｜ 刀二已補、headless **6 → 1**、★**而我那支結構排除是死碼**
topic: ★**刀二落地**（`ebbb4dd9c`）：`terms.gd` 的 `_loot` 改走 `richness_compressed(attack_loot_est, ctx.reference_wealth)`，**`ATTACK_LOOT_REF = 3.0` 刪掉不是改值**；ctx 新增 `reference_wealth` ⇒ **兩刀同一把尺**｜★★**零情報收窄後 headless 新紅 6 → 1**，剩的那條是**排序改變不是排除**（附算術）｜★★★**而這一版照出我自己兩個洞**：①`bel.is_empty()` 那支結構排除**走不到**（`has_belief` 在它之前）—— 實測 `attack.excluded.zero_intel = 0` 坐實；②床還在讀**已改名**的鍵 ⇒ **它會安靜地永遠印 0**
---

# ① 刀二（照裁，形狀與 score 那刀相同）

```gdscript
# 舊：var _loot = clampf(ctx.attack_loot_est / ATTACK_LOOT_REF, 0.0, 1.0)   ← ATTACK_LOOT_REF = 3.0
# 新：var _loot = FactionAISystem.richness_compressed(ctx.attack_loot_est, ctx.reference_wealth)
```
★**常數刪掉不是改值** —— 照你的原話：**改值會讓下一個人以為它還有校準的餘地。**
★★`ctx.reference_wealth` 是新欄位（`terms` 拿不到 `state`／`team`）
⇒ ★★★**兩刀用同一把尺** —— 否則同一個世界會有兩種「多肥」的定義，**而那種 drift 不會有任何東西紅**。

# ② headless：**6 → 1**

剩下這一條：`established+HEGEMON LEADER 應可選富屬村（own=0.75），實得 2`
★**它不是「選不出」，是「選了另一個」** ⇒ **排除層已經修好，這是排序層。**

**算術**（fixture `headless_test.gd:16985-17005`）：
```
攻擊者 pop = 10 ⇒ ref = 10 × Σ(TARGET_PER_POP × BASE_PRICE) = 10 × 415.7 = **4157**
prey1（富屬村）coin_est = 300 ⇒ r = 300/4157 = 0.0722 ⇒ compressed = **0.0673**
prey2（貧獨立）無資產欄      ⇒ richness = **0**
⇒ ★**prey1 的財富優勢只剩 0.067**，而歸屬罰（own 0.75 vs 1.0）× 野心把它蓋過去。
```
⇒ ★★**這正是「richness 相對於我」的直接後果**：
**300 coin 對一支 pop-10 的隊來說【不算富】** —— ★★★**而 fixture 的名字叫「富屬村」。**

**兩種處置，我不自己做**：

| | 做法 | 意味著 |
|---|---|---|
| 甲 | **把 fixture 的 `coin_est` 調到真的富**（例如 4000 ⇒ compressed ≈ 0.49） | ★**測試的意圖不變**（「富」屬村），只是把「富」寫成新尺上的富 |
| 乙 | **接受新行為**，改斷言 | ★★那等於說「HEGEMON 也不該為了 300 coin 去打屬村」——**可能是對的戲** |

★**我傾向甲**：**那條測試驗的是「統領扛得起戰爭 ⇒ 屬村罰減輕」，不是「300 這個數」。**
★★但**改 fixture ＝ 改我們在驗什麼** ⇒ **你按。**

# ③ ★★★我自己的兩個洞（★都是這一版照出來的）

## (i) `bel.is_empty()` 那支結構排除**是死碼**

```
`faction_ai_system.gd:272`  if not BeliefSystem.has_belief(...): continue   ← ★在前
`faction_ai_system.gd:324`  if bel.is_empty(): …                            ← ★在後
⇒ **沒有 claim 的目標根本走不到 :324**
實測（2 天窗）：`attack.excluded.zero_intel` ＝ **0**，而同輪薄情報 admitted 5211／refused 704
⇒ ★★**坐實：它一次都沒 fire。**
```
★**而 09-15 你查 `GATE_CONF_LOW = 0.0` 擋住自己那次，結論是「結構排除不是冗餘」** ——
★★**那個結論在【當時的定義】下成立**（零情報 ＝ 沒有資產欄，`confident_enough` 攔不住膽大者）；
★★★**收窄成「連 claim 都沒有」之後，`has_belief` 就把它全接走了** ⇒ **它變成冗餘。**
⇒ **要刪還是留成斷言，你裁**（我傾向**刪**，並讓 ① 驗 `no_belief` 那一支 —— 床已經改成這樣）。
★**理由**：**裝一支永遠不會 fire 的守衛，比沒裝更危險 —— 它看起來在做事。**

## (ii) 床在讀一個**已經改名**的鍵

`attack.excluded.no_priced_belief` → 09-16 改成 `zero_intel`，**而床沒跟著改**
⇒ ★**它會安靜地永遠印 0** ⇒ ★★**「0 次」與「讀錯鍵」在畫面上長得一模一樣。**
（★已修，並同時印 `thin_intel.admitted/refused`。）

# ④ 現在

- 樹 `ebbb4dd9c`，乾淨；**短窗 0 紅**（① 已改成新語意：真零情報 ⇒ `no_belief`）。
- ⏳ **等你三件**：headless 那條（甲/乙）、`bel.is_empty()` 刪或留、
  以及上一封還開著的 `bed-kind`（`probe_stats.gd` 無 kind）與 `defer-open`（`met_check` 比條件寬）。
- ⏳ ★**10 天窗驗收要重跑**（行為變了 ⇒ 舊那份數作廢），排在你裁定之後，**一次跑完再交**。
