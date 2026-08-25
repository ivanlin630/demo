---
from: systems
to: implementer
status: consumed
topic: "[dispatch 生育=per-capita 相對盈餘驅動的連續速率(取代硬懸崖+抽獎)·spec=2026-08-20-breed-rate-continuous-HOW.md(§5 R²delta 必查項/§6 形狀/§7 常數/§8 錨點理由,全部已定案)·用戶拍板形狀(乙)強化版+節奏(B);R②=CLEAN(設計面)+R²delta=CLEAN(常數與算術獨立驗證通過)·★T1 度量:rel_surplus = team.food_flow_avg / max(pop × ResourceSystem.FOOD_PER_PERSON_PER_DAY, ε)=【比例量】(同時解小村被絕對門檻封死與大團被人均攤薄)·★T2 速率:births_per_person_day = BREED_BASE_RATE(0.0133) × f(rel_surplus) × persona_mult;f(r)= 0 if r<=0 else r/(r+K)、K=0.15;persona_mult 沿用既有醫療技能與 _breed_balance(兩性結構仍是先決)·★常數註解【必須寫反推式】(f=0.5×5 適齡→1 名額/30 日=用戶拍的 pacing B),禁只寫 TEST VALUE·★T3 累積器取代抽獎:team.breed_progress += rate × eligible_persons × elapsed_days;while breed_progress>=1.0 and minor_population<cap: minor_population+=1; breed_progress-=1.0·★★必查項(R² 抓、非可選):elapsed_days 必須 per-team 真實流逝——新欄 team.breed_progress_last_tick:int=-1,elapsed_days=(current_tick-last_tick)/TICKS_PER_DAY,算完更新;★sentinel -1=未初始化→【首次評估只蓋戳記不累加】(照 food_flow_last:team_data.gd:76/resource_system:237-238 既有慣例)=冷啟動噴發結構上不可能·禁用呼叫情境的 cadence 常數當 elapsed(near/far 穿梭會重複累加、headless 不會踩但有玩家遊玩是常態)·★T4 兩個新欄(breed_progress/breed_progress_last_tick)【必入 state_fingerprint 的 _emit_teams】:它們是直接因果態(值本身決定下次跨過 1.0 是哪個 tick)、非可重算 ephemeral 快取(對比 :69 排除的 food_flow_avg/need_urgency)·★T5 移除 breed 專屬的 LOD trials 分支(連續累積器不是機率型、rate×Δt 本來就是正確降頻語意)、★但保留其餘累積型補償(morale w_eff/技能 XP/comply loyalty/unrest ×trials)不動·★T6 probe:breed.born(每產一個 minor)+breed.rate_sample(取樣 rel_surplus/f/rate,便於下輪校準)·gate①常數註解指向 §7 反推(非 TEST VALUE 了事)②健康小村會生(pop3-5、rel_surplus 明顯正→有限窗真產 minor,舊規則下為 0)③餓村仍不生(rel_surplus<=0→progress 不增、零 minor)④無懸崖(r 由 0 掃到高值、產出率單調連續無跳變)⑤【迴歸測試角色】同 rel_surplus 下 pop3 vs pop30 每人速率相同(防偷渡絕對 pop 依賴;設計本身由公式結構保證)⑥LOD 等價(far/near 同窗累積相同)⑦★near/far 穿梭不重複累加⑧★冷啟動不爆(新隊首次評估產 0)⑨det×3+constitution<=75+headless 0-new+fp intended-change(含兩新欄入 fp)⑩短窗 sanity:peaceful breed.born>0 且人口曲線平滑非指數·worktree feat/breed-rate-continuous·完→handback to:systems·地基KEEP"
---

# dispatch：生育＝per-capita 相對盈餘驅動的連續速率

spec＝`docs/superpowers/specs/2026-08-20-breed-rate-continuous-HOW.md`（§5 R²delta 必查項／§6 形狀／§7 常數／§8 錨點理由，**全部已定案**）。
**用戶拍板**：形狀 (乙) 強化版 + 節奏 **(B)**。**R²＝CLEAN**（設計面）、**R²delta＝CLEAN**（常數與算術獨立驗證通過）。

- **T1 度量**：`rel_surplus = team.food_flow_avg / max(pop × FOOD_PER_PERSON_PER_DAY, ε)` ＝ **比例量**。
- **T2 速率**：`births_per_person_day = BREED_BASE_RATE(0.0133) × f(rel_surplus) × persona_mult`；`f(r) = 0 if r<=0 else r/(r+K)`、**`K=0.15`**；`persona_mult` 沿用既有醫療技能與 `_breed_balance`。
  ★**常數註解必須寫反推式**（`f=0.5 × 5 適齡 → 1 名額/30 日` ＝ 用戶拍的 pacing B），**禁只寫 TEST VALUE**。
- **T3 累積器取代抽獎**：`breed_progress += rate × eligible × elapsed_days`；`while breed_progress>=1.0 and minor<cap: minor+=1; breed_progress-=1.0`。
- **★★必查項（R² 抓、非可選）**：`elapsed_days` **必須 per-team 真實流逝** → 新欄 `breed_progress_last_tick: int = -1`；`elapsed_days=(current_tick-last_tick)/TICKS_PER_DAY`、算完更新。★**sentinel `-1` ＝ 未初始化 → 首次評估只蓋戳記、不累加**（照 `food_flow_last` 既有慣例：`team_data.gd:76`／`resource_system:237-238`）→ **冷啟動噴發結構上不可能**。**禁用呼叫情境的 cadence 常數當 elapsed**（near/far 穿梭會重複累加；headless 不會踩，但**有玩家遊玩是常態**）。
- **T4**：兩新欄**必入 `state_fingerprint._emit_teams`**（直接因果態，非可重算 ephemeral 快取——對比 `:69` 排除的 `food_flow_avg`/`need_urgency`）。
- **T5**：**移除 breed 專屬的 LOD `trials` 分支**（連續累積器不是機率型），★**但保留其餘累積型補償不動**（morale `w_eff`／技能 XP／comply loyalty／unrest ×trials）。
- **T6 probe**：`breed.born`（每產一 minor）+ `breed.rate_sample`（取樣 `rel_surplus`/`f`/rate，供下輪校準）。

**gate**：①常數註解指向 §7 反推 ②健康小村**會生**（pop3–5、`rel_surplus` 明顯正 → 有限窗真產 minor；**舊規則下為 0**）③餓村**仍不生** ④**無懸崖**（單調連續、無跳變）⑤**（迴歸測試角色）**同 `rel_surplus` 下 pop3 vs pop30 每人速率相同（防偷渡絕對 pop 依賴；設計本身由公式結構保證）⑥LOD 等價 ⑦★near/far **穿梭不重複累加** ⑧★**冷啟動不爆** ⑨det×3 + constitution ≤75 + headless 0-new + fp intended-change ⑩短窗 sanity：peaceful `breed.born > 0` 且人口曲線**平滑非指數**。

worktree `feat/breed-rate-continuous`。完 → handback to:systems。地基 KEEP。
