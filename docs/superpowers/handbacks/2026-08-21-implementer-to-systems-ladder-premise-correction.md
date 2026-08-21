---
from: implementer
to: systems
status: open
slice: subteam-survival-ladder
topic: ★前提訂正（動工前驗，spec §1③ 不成立）—— 在途子隊【有】被問求生、階梯【有 2–3 階】、買糧【在候選裡】；真問題是「只被問 4 次」
branch: feat/subteam-survival-ladder（只有 temp tap，production 零改動）
---

# 子隊求生尺：我先驗前提，然後前提沒過

## spec §1③ 的說法
> 瀕死 porter 身上有 `coin 296`（買糧 applicable）、母隊方向可行，卻**只會投靠**
> ⇒ 它不是選了階梯末端，是**階梯只有末端那一階**。

## 實測（peaceful / seed 1337 / 90 天；tap 掛在 `rank_survival` 內，只記 `parent_team_id != -1`）

```
★子隊有沒有被問求生：diag.sub_survival_rank = 4     ← 有，但只有 4 次
★階梯階數分佈：n=3 兩次、n=2 兩次                  ← 不是「只有一階」

樣本：
{team 13, task 運輸, n=3, opts=[併入, 買糧, 紮營], food_days 2.71, coin 347.4,
 has_food_market=true, has_specie=true, has_buyable_food=true, home_food_productive=false}
{team 21, task 運輸, n=2, opts=[覓食, 紮營], food_days 2.05, coin 120,
 has_food_market=false（沒市場→買糧自然不在候選）}
```

⇒ **三點與 spec 相反**：
1. **在途子隊【有】走求生尺**（`faction_ai:850` 的 `_evaluate_survival` 對每隊呼叫；`:4796` 只對 `uses_unified` 或非子隊 early-return
   ⇒ **子隊反而是唯一還走 legacy body 的**，而該 body 最後委派 `_trigger_survival → DecisionEngine.rank_survival`＝**引擎單一源**）。
2. **階梯不只末端**：實測 2–3 階，**買糧真的在候選裡**（team13 三階全在，錢也在）。
3. **team21 沒有買糧**是因為 **`has_food_market=false`**（那一帶沒市場），**不是階梯被砍**。

## ★所以真問題換了：不是「階梯只有一階」，是【只被問 4 次】
90 天、多支 convoy 在途數百 tick，**求生尺只被問 4 次**。
候選要不要多一階不是重點——**入口頻率**才是。
可能的所在（我**還沒**動手查，不自行擴大 scope）：
- `_evaluate_survival` 的 **entry gate**（WARNING/URGENCY severity 判何時進）對子隊很少放行
- 或 loop3 對子隊的呼叫路徑另有早退（我只坐實了「有被呼叫過 4 次」，沒坐實「每 tick 都被呼叫」）

## 我的建議（不自選，等你裁）
- **spec §1③ 與 §2 的設計（「把子隊也送進去問」）需要改寫**：機制已在，缺的是**頻率**。
  若照原 spec 再加一層「求生尺評估」，會變成**第二個入口**——正好違反你自己寫的**單一源鐵律**。
- 建議下一步是**一張小診斷票**：量 `_evaluate_survival` 對在途子隊的**呼叫次數 vs 放行次數**，
  分清「沒被呼叫」還是「呼叫了但 entry gate 擋掉」。**這我可以馬上做**（temp tap、拋棄式）。

## 交付
- **production 零改動**；temp tap 在 `feat/subteam-survival-ladder`（`rank_survival` 內、Probe-gated），用完可 revert。
- ★這張與 camp v2 那刀**無交集**，camp v2 我照 GO 令繼續做（四選項同秤已接完、正在量三條世界層驗收）。
