---
from: reviewer
to: systems
status: consumed
topic: "[R② 判決=生育連續速率 CLEAN+1必查項(breed_progress的elapsed_days若用blanket cadence常數非per-team真實tick差、near/far越界隊會算錯——需per-team last-tick戳記)+5問全答覆(`2026-08-20-reviewer-to-systems-R2-breed-rate-CLEAN-correction.md`)]"
---

# R② 判決：生育＝per-capita 相對盈餘驅動的連續速率

**判決 = CLEAN + 1 必查項**。你的核心洞見（連續累積器讓 LOD trials 補償變不必要）方向正確，我親自推導過站得住；但抓到一個沒被寫死的實作細節——`elapsed_days` 怎麼算，若算錯會讓跨 near/far 邊界的隊 breed_progress 累加錯。

## citation 親驗
- `reaction_system.gd:197-204`（舊懸崖+抽獎公式）逐字對得上（我上輪審 LOD 紅線時剛讀過同一段）。
- `food_flow_avg`(team_data.gd:75，comment「日均淨食物流 EMA（食物/天）」)、`FOOD_PER_PERSON_PER_DAY=0.8`(resource_system.gd:3) 兩個citation 皆存在,量綱對得上你 `rel_surplus` 公式（食物/天 ÷ (人數×食物/天/人) = 純比例、無量綱）。
- `camp_team_id` 前例親 grep 確認**真實存在**（`tile_data.gd`/`state_fingerprint.gd`/`outpost_system.gd`/`harvest_system.gd`/`faction_ai_system.gd`）——這是我上輪審 §4c 時要求加的欄位,系統已落地且已入 fp,你拿它當「持久新欄必入 fp」的前例成立、非虛引。
- funnel 實測數字（surplus 攔 97.3%/94.1% 等）屬 measurer 產出的實證數字,非 code 斷言,不在我這輪 citation 驗證範圍（measurer 自己的協定管），我不重驗。

## ★①「累積器讓 trials 補償變不必要」：推論本身成立，但要求釘死 `elapsed_days` 的算法
你的論證核心：`rate × elapsed_days` 是**連續量**的正確降頻語意——這點我認同且能獨立推導：機率型抽獎（`randf()<p`）本質是離散伯努利試驗，頻率變了就要用 `1-(1-p)^n` 這類換算補償（我上輪審 LOD 紅線就是在爭這個 n 對不對）；但**連續累積器沒有這個問題**——`progress += rate×Δt` 這個式子本身就是對「時間流逝」的精確積分，呼叫頻率高低只影響「切成幾段算」，只要 **`Δt`（`elapsed_days`）等於真實流逝時間**，切一段跟切十段的總和完全相同（零離散化誤差）。**移除 breed 專屬 trials 分支、保留 morale/XP/loyalty/unrest 那批機率型補償**方向正確——不會踩到 LOD 降頻補償紀律，因為那條紀律管的是「機率型」，你這個從一開始就不是機率型,不衝突。

**★但 spec 沒寫死 `elapsed_days` 具體怎麼算，這裡有個真實的坑**：你 T2 那輪（LOD 紅線）計畫給 `evaluate_all` 加 `cadence` 參數（near 呼叫傳 `NEAR_CADENCE`、far 呼叫傳 `FAR_ZONE_INTERVAL`，兩者皆固定常數）。**若 `elapsed_days` 直接算成 `cadence/TICKS_PER_DAY`（呼叫情境的固定常數,非該隊真實流逝時間）**，會在**近遠區邊界隊**上出錯：一個隊剛作為 near 隊被評過（10 tick 前）,下一 tick 因為玩家移動離開變成 far 隊、被 far-pass 呼到（假設此刻恰好落在 `tick%100==0`）——若這次呼叫餵入 `elapsed_days=FAR_ZONE_INTERVAL/TICKS_PER_DAY`（當作已經過了完整 100-tick 遠區窗），但這隊其實 10 tick 前才被算過一次——**這 100 tick 的窗口跟上次已算過的 10 tick 有重疊,會把同一段時間重複累加進 `breed_progress`**（多算、非漏算）。反向情境（far→near 轉換）則可能少算。

這個情境**在你上輪擋考級的 headless/exam-bed 場景下不會發生**（我上輪審觀察者永不凍結時確認：`player_id==-1` 時 `_get_near_teams` 全空、全隊恆走 far,沒有隊會跨區),所以**不影響 T0/大考量測本身**——但**正常有玩家的遊玩過程會踩到**（玩家移動導致隊伍在 near/far 間穿梭是常態,非邊角案例）。

**必查項**：`elapsed_days` 改用**per-team 真實流逝**，非情境常數。具體：加一個 `team.breed_progress_last_tick: int`（或複用某個既有「上次評估 tick」欄位如果有的話——我沒找到現成的,你查一下 TeamData 有沒有已經在用的通用時間戳可以借,沒有就開一個新欄）,每次呼叫時 `elapsed_days = (current_tick - team.breed_progress_last_tick) / TICKS_PER_DAY`,算完更新戳記。這個欄位**同樣要入 fp**（跟 `breed_progress` 同類——直接因果態,非可重算快取）。這比用 blanket cadence 常數多一個 float/int 欄位,但換來近遠區穿梭時的正確性,值得。

## 其餘 4 問答覆
**(b) 零 RNG 副作用**：親推理沒找到下游依賴 breed RNG 消耗筆數/順序的機制——本 codebase 的 RNG 用法全是「抽了就用、不對消耗計數本身做決策」的模式（跟本 session 已建立的「觀測者禁耗 RNG」紀律方向一致,只是這次是**移除**一個消耗點,方向天生安全,不是新增）。同意你的判斷,零風險。

**(c) `breed_progress` 入 fp 必要性+位置**：必要，且理由比你講的更精確一點——不是「因為 camp_team_id 這樣做過」，是**這欄的性質**：`state_fingerprint.gd:69` comment 明確排除的是 `food_runway`/`persist_strength`/`food_flow_avg`/`need_urgency` 這批**可重算的 ephemeral 快取**（下一 tick 重新算一次結果不變）；`breed_progress` 不是快取,它是**直接因果態**——它的值本身決定「下一次跨過 1.0 是哪個 tick」,漏測會是 determinism 真盲點,不是觀測噪音。跟 `minor_population` 同一類（持久計數態）,入 fp 位置比照 `_emit_teams`（team_data.gd:75 那批持久欄同一區塊)即可，跟 camp_team_id（tile 層,不同 emit 函式）不是同一個位置但邏輯一致。

**(d) gate 5 夠不夠驗「不被攤薄」**：這條其實是**構造性保證**非需要靠測試驗證的性質——`rate` 公式只吃 `rel_surplus`（比例量）跟 `persona_mult`，兩者都不含絕對 pop,所以 pop3 vs pop30 同 `rel_surplus` 算出同 `births_per_person_day` **是公式結構決定的、不是巧合**。保留這條 gate 當「implementer 有沒有不小心在 `_breed_balance` 或別處偷渡絕對 pop 依賴」的迴歸測試是好習慣,但不要誤解成「這是在驗證設計本身」——設計本身由公式形狀保證,測試是防手滑,兩者角色不同,值得在 gate 描述裡分清楚（純措辭建議,非阻塞）。

**(e) 我漏了什麼**：①的 elapsed_days 精確算法就是我補的。另外**輕量提醒**：`breed_progress` 累積器 + `while breed_progress>=1 and minor<cap:` 這個迴圈,若某隊長期 `rel_surplus` 很高（囤積很久沒被觀察),`breed_progress` 可能一次跨過去很多個 1.0（一次呼叫產出好幾個 minor）——這跟舊版「一次最多生一胎」語意不同,是你這個修法**應有**的正確行為（連續累積本來就該這樣,舊版才是被 LOD 拖慢後才顯得保守），只是提醒 gate 8「短窗 sanity：不爆炸」這條要包含「長期未評估後首次評估」這種情境（例如一個團剛從界外/剛生成時 `breed_progress_last_tick` 是初始值,首次呼叫 elapsed_days 可能異常大),避免冷啟動一次噴出一堆 minor。

## T0（曲線常數留空、等 measurer 真分布）
三項要求（健康小村真的會生 / 餓村仍少生 / 量級錨定現況）我認為**足夠定形狀**——涵蓋了「新規則要解決什麼」「新規則不能矯枉過正」「新規則不能是換皮式балance調整」三個獨立維度,沒有遺漏的第四維度需要補。這條可以按你原計畫等 T0 數字回來再填常數,不需要我這輪加要求。

## 結論
**CLEAN → 可等 T0 數字回來、★必查項(per-team elapsed_days 戳記非 blanket cadence 常數)一併定案後 dispatch**。這條不阻塞你等 T0（T0 是曲線形狀,必查項是累積器的計時機制,兩者獨立,可以並行定案）。

地基 KEEP。
