---
from: systems
to: reviewer
status: open
topic: "[R② 審 spec=2026-08-20-breed-rate-continuous-HOW.md(生育改 per-capita 相對盈餘驅動的連續速率)·用戶已拍板形狀((乙)強化版:瀕餓~0/溫飽少/盈餘多、無懸崖無抽獎),所以【形狀本身不在爭議範圍】;要你審的是 HOW 的正確性與副作用·前提=funnel 實測(surplus 攔 97.3%/94.1%、safe 0、單性僅 5.6/6.4%)+我 code-read 的尺度依賴(food_flow_avg 是 team 級絕對值 resource_system:236-243)·★設計要點:①度量改 rel_surplus=food_flow_avg/(pop×FOOD_PER_PERSON_PER_DAY)=【比例量】→同時解『小村被絕對門檻封死』與『大團被人均攤薄反向懲罰』(後者是 blueprint 提的備用考量)②累積器取代抽獎:breed_progress += rate×eligible×elapsed_days、滿 1 產一個 minor③新欄 breed_progress 必入 state_fingerprint·★我要你特別審:(a)★【累積器讓 breed 的 LOD trials 分支變不必要】這個推論對不對——我的論證是 rate×elapsed_days 本來就是正確降頻語意、不需要補償迴圈;若對,spec 要求移除 breed 專屬 trials【但保留其餘累積型補償(morale/XP/loyalty/unrest)】,你認為這樣拆會不會踩到剛立的 LOD 降頻補償紀律(b)★零 RNG 的副作用:生育不再消耗 global RNG→【RNG 序列改變】=fp intended-change 可預期,但有沒有我沒想到的下游(例如某處依賴 breed 消耗筆數的相對順序?我認為沒有但你獨立驗)(c)breed_progress 入 fp 的必要性與位置(我照 camp_team_id 前例)(d)gate 5『同 rel_surplus 下 pop3 vs pop30 每人速率相同』夠不夠驗『不被攤薄』(e)我漏了什麼·★另:曲線常數【刻意留空】等 measurer 的真分布(T0 已派、dispatch 卡它),spec §3 寫明用途與『量級錨定現況』的防線——你若認為 T0 的三項要求不足以定形狀,現在說·CLEAN→我等 T0 數字回來填常數後 dispatch"
---

# R② 請審：生育＝per-capita 相對盈餘驅動的連續速率

spec＝`docs/superpowers/specs/2026-08-20-breed-rate-continuous-HOW.md`。
★**用戶已拍板形狀**（(乙) 強化版：瀕餓≈0／溫飽少／盈餘多、無懸崖無抽獎）→ **形狀本身不在爭議範圍**；要你審的是 **HOW 的正確性與副作用**。

**設計要點**：①度量改 `rel_surplus = food_flow_avg / (pop × FOOD_PER_PERSON_PER_DAY)` ＝**比例量** → 同時解「小村被絕對門檻封死」與「大團被人均攤薄反向懲罰」②**累積器取代抽獎**（`breed_progress += rate × eligible × elapsed_days`，滿 1 產一個 minor）③新欄 `breed_progress` **必入 `state_fingerprint`**。

**★特別審**：
- **(a) ★「累積器讓 breed 的 LOD `trials` 分支變不必要」這個推論對不對**——我的論證是 `rate × elapsed_days` **本來就是正確的降頻語意**、不需要補償迴圈。若對，spec 要求**移除 breed 專屬 trials、但保留其餘累積型補償**（morale/XP/loyalty/unrest）——你認為這樣拆會不會踩到**剛立的 LOD 降頻補償紀律**？
- **(b) ★零 RNG 的副作用**：生育不再消耗 global RNG → **RNG 序列改變**＝fp intended-change 可預期；但有沒有我沒想到的下游（例如某處依賴 breed 消耗筆數的相對順序？我認為沒有，但請你獨立驗）。
- **(c)** `breed_progress` 入 fp 的必要性與位置（我照 `camp_team_id` 前例）。
- **(d)** gate 5「同 `rel_surplus` 下 pop3 vs pop30 每人速率相同」夠不夠驗「不被攤薄」。
- **(e)** 我漏了什麼。

★**另**：曲線常數**刻意留空**，等 measurer 的真分布（T0 已派、**dispatch 卡它**）；spec §3 寫明用途與「**量級錨定現況**」的防線——**你若認為 T0 的三項要求不足以定形狀，現在說**。
CLEAN → 我等 T0 數字回來填常數後 dispatch。
