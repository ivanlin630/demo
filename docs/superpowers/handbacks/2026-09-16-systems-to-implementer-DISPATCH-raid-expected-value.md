---
from: systems
to: implementer
status: open
slice: 掠奪走期望價值 ｜ **DISPATCH（開工；★排在恩怨帳之後或平行，你自己排）**
topic: ★**spec**：`docs/superpowers/specs/2026-09-16-raid-expected-value-HOW.md`（審查已過，四個 file:line 逐條核過全部成立）｜★★**一句話**：`掠奪 util = LOOT_DRIVE_BASE(1.0) × cap` ⇒ **改成與攻擊【逐字同形】的期望值**，只有輸入不同｜★★★**而你會先撞到的事我先講**：`cap`（`terms.gd:315`）與 `attack_win_odds`（`decision_context.gd:975`）**是逐字相同的式子兩個名字** ⇒ **掠奪一直在讀贏率，它缺的是【搶得到多少】與【多需要】**
---

# ① 新式子
```
掠奪：(RAID_LOOT_W × take + RAID_NEED_W × need) × odds × person      ← 與攻擊 `terms.gd:276` 同形
  take  = richness_compressed(prey_richness_belief × RAID_TAKE_FRACTION, ctx.reference_wealth)
          ★**同一個壓縮函數、同一個 reference_wealth** ＝「同一把秤」的操作定義
  prey  = `_find_weakest_prey` 的 belief（★感知鐵律：讀 belief 不讀真值）
  odds  = **ctx 既有欄位**（`cap` 就是它）⇒ **刪掉 `terms.gd:315` 那份重算**（三處變兩處）
  need  = 與攻擊同源
  person= 好戰／殘忍 **在人格層調製**（憲法；★不在式子裡加常數）
★ `LOOT_DRIVE_BASE = 1.0` 刪除。★ `terms.gd:536` 的第三份 `cap` **不動**（不在本票路徑上）。
```

# ② ★`RAID_TAKE_FRACTION` **不准手填**
從世界推：**一次掠奪實際搬走多少 ／ 對方資產**（戰鬥結算的 loot 轉移量）。
★★**那條路徑拿不出數 ⇒ 回報我，不要挑一個 0.2。**

# ③ 驗收（spec §3 六格）
★**格3 是本票的目的**：掠奪與攻擊對**同一個目標** ⇒ util **同量級**（比值落在 `RAID_TAKE_FRACTION` 附近）。
★★**格4 是「不准退步」不是新功能**：無牙 ⇒ 掠奪 util ≈ 0（舊制的 `cap` 也做得到）。
★★★**而交件要帶這一句**（spec §2b）：
> **本票讓掠奪用上跟攻擊【同樣的】odds，而那個 odds 完全不讀對手 ——
> 格3 的「同量級」只能證明【尺】相同，不能證明【值】對。**
**別讓下一個人拿格3 綠了當成「贏率也對了」。**（真修法已開成下一張：`odds-must-read-the-target`。）
