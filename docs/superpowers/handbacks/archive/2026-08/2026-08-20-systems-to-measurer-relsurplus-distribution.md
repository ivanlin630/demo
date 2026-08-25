---
from: systems
to: measurer
status: consumed
topic: "[★T0 分布快照(生育 HOW 的【前置】、不是事後補)·背景:用戶拍板生育改『per-capita 盈餘驅動的連續速率』取代現行 team 級硬門檻+抽獎;用戶/blueprint 明令【形狀看真分布定、禁憑空給常數】→所以我需要分布【才能寫死曲線】,dispatch 卡在你這份·★禁新長跑:從【既有大考資料】重算即可(exam12mo 的 peaceful 完整 12mo + warring day1-70 有效窗;specimen jsonl 有逐隊逐 tick 食物/人口,或你手上任何等價落檔)·★要什麼(peaceful 與 warring 各一份):①rel_surplus = food_flow_avg / max(pop × FOOD_PER_PERSON_PER_DAY, ε) 的分布(min/median/p75/p90/max + 【正值佔比】)——注意是【相對自己日耗】的比例量,不是絕對值也不是人均絕對值②同一份資料下、若套【舊規則】(food_flow_avg > 1.2 團級絕對)實際會通過的人次/隊次比例=對照組③★如果可能:分 pop 級距看 rel_surplus(如 pop<=5 / 6-12 / >12),我要確認【小村是不是真的相對盈餘也差】還是【只是被絕對門檻誤殺】——這兩者導向完全不同的曲線·★用途(寫進 verdict 讓後人看得懂):定 f 的轉折與 BASE_RATE,使(a)健康小村真的會生(b)餓的世界仍然少生(c)★量級錨定現況——在『舊規則會通過』那群身上新率期望產出與舊規則同量級(防止默默把生育大幅調高、偽裝成 bug fix 的 balance 改動)·★若既有資料算不出 rel_surplus(缺欄位),回報缺什麼即可,我改用短窗 tap(仍禁長跑)·完→handback to:systems"
---

# ★T0 分布快照（生育 HOW 的**前置**）

**背景**：用戶拍板生育改「**per-capita 盈餘驅動的連續速率**」取代現行 team 級硬門檻 + 抽獎；用戶/blueprint 明令**形狀看真分布定、禁憑空給常數** → 我**需要分布才能寫死曲線**，dispatch 卡在這份。

★**禁新長跑**：從**既有大考資料**重算即可（`exam12mo` 的 peaceful 完整 12mo + warring day1–70 有效窗；specimen jsonl 有逐隊逐 tick 食物/人口）。

**要什麼**（peaceful 與 warring 各一份）：
1. **`rel_surplus = food_flow_avg / max(pop × FOOD_PER_PERSON_PER_DAY, ε)`** 的分布（min/median/p75/p90/max + **正值佔比**）——★注意是**相對自己日耗的比例量**，不是絕對值、也不是人均絕對值。
2. 同一份資料下，若套**舊規則**（`food_flow_avg > 1.2` 團級絕對）實際會通過的人次/隊次比例 ＝ **對照組**。
3. ★**如果可能**：**分 pop 級距**看 `rel_surplus`（pop ≤5／6–12／>12）——我要確認**小村是不是連相對盈餘也真的差**，還是**只是被絕對門檻誤殺**。**這兩者導向完全不同的曲線。**

**用途**（請寫進 verdict 讓後人看得懂）：定 `f` 的轉折與 `BASE_RATE`，使 (a) 健康小村真的會生 (b) 餓的世界仍然少生 (c) ★**量級錨定現況**——在「舊規則會通過」那群身上，新率期望產出**與舊規則同量級**（**防止默默把生育大幅調高、偽裝成 bug fix 的 balance 改動**）。

★若既有資料算不出 `rel_surplus`（缺欄位），**回報缺什麼即可**，我改用短窗 tap（仍**禁長跑**）。完 → handback to:systems。
