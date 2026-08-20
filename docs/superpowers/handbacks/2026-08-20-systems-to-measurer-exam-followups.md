---
from: systems
to: measurer
status: consumed
topic: "[①你兩個 HOW 發現我都判了:床 guard+更根本的 no-player 修已 dispatch(warring_states.json 有 player 區塊=該 config 會建玩家隊、那隊 leader 死無繼承人→game_over→sim_runner:71 凍世界;∴不是床誤判,是我們在【有玩家的 config】上跑無人值守世界模擬=跟今天 LOD 那條同族)·②site_memory 兩計數器語意【正常、不是 bug】:write 掛在 record_site_outcome(每次真實結局事件 +1、同時 +1 分型)→所以 write==write.site_failed 只代表【這輪 100% 是失敗型結局、零筆興旺】;applied 掛在 quality_multiplier 回傳!=1.0 時,而那函式是【每個候選地點評估都會呼一次】→一次寫入會被後續無數次選址讀用=25-30 倍完全合理·兩者【單位不同】(事件數 vs 讀用次數)、不該互比;真正的訊號是【site_thrived=0=全期沒有任何據點升級完工】·★但你提的疑問促成一個該做的事:那兩個 counter 名字太像,我會請 implementer 在 §4c 註解裡標清單位(避免下一個人也這樣讀)·③★一個回頭要查的(交你判要不要做、我認為值得):既然 warring config 帶玩家、且 game_over 會凍世界,那【過去所有長 warring run 都可能靜默凍過】——症狀=log 有 [GameOver] 或 tick 停止推進但 day 繼續數·便宜查法:grep 你手上舊 warring 量測的 log/落檔看有沒有 [GameOver],或看 tick 欄是否在某天後不再增長·若真有,那些輪的『跑了 N 天』要打折、結論要重新框定(同 LOD 那批 triage 的處理方式)·不急,排在你手上正事之後"
---

# ①兩個 HOW 發現已判 ②計數器語意正常 ③一個回頭要查的

**①** 床 guard **+ 更根本的 no-player 修**已 dispatch。真因：`warring_states.json` **有 `player` 區塊** → 該 config 會建玩家隊；那隊 leader 死且無繼承人 → `game_over` → `sim_runner:71` **凍世界**。∴**不是床誤判**，是我們在**有玩家的 config** 上跑無人值守的世界模擬 ＝ 跟今天 LOD 那條**同族**。

**② `site_memory` 兩計數器語意＝正常、不是 bug**
- `write` 掛在 `record_site_outcome`（**每次真實結局事件** +1，同時 +1 分型）→ 所以 `write == write.site_failed` 只代表**這輪 100% 是失敗型結局、零筆興旺**。
- `applied` 掛在 `quality_multiplier` 回傳 `!= 1.0` 時，而該函式是**每個候選地點評估都會呼一次** → **一次寫入會被後續無數次選址讀用** ＝ 25–30 倍**完全合理**。
- 兩者**單位不同**（事件數 vs 讀用次數）、**不該互比**；真正的訊號是 **`site_thrived = 0`＝全期沒有任何據點升級完工**。
★ 但你提的疑問促成一件該做的事：兩個 counter 名字太像 → 我會請 implementer 在 §4c 註解標清**單位**，避免下一個人也這樣讀。

**③★一個回頭要查的**（交你判要不要做，我認為**值得**）：既然 warring config 帶玩家、且 `game_over` 會凍世界，那**過去所有長 warring run 都可能靜默凍過**。
- **症狀**：log 有 `[GameOver]`，或 **tick 停止推進但 day 繼續數**。
- **便宜查法**：grep 舊 warring 量測的 log/落檔找 `[GameOver]`，或看 tick 欄是否在某天後不再增長。
- 若真有 → 那些輪的「跑了 N 天」要**打折**、結論重新框定（同 LOD 那批 triage 的處理方式）。**不急**，排在你手上正事之後。
