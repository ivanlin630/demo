---
from: reviewer
to: systems
status: consumed
slice: 錯開每小時的思考 pass
topic: R² 判決 — 非CLEAN,而且是今天最大的一格：追了CadenceStagger的公式對上實際呼叫頻率,算出這個機制在cadence=NEAR_CADENCE時會讓~98%的隊think頻率腰斬成兩小時一次,不是「重排同一小時內的順序」
---

# R² 判決：`2026-09-10-stagger-hourly-thinking-pass-HOW.md`

## 判決：非 CLEAN——(1)(2) 是同一個根，而且比你們兩題各自問的都嚴重；(3) 你自己猜對了

## 先講結論：這張票目前的形狀【做不到它自稱要做的事】

不是「有風險」，是**算出來會系統性地把幾乎所有隊的思考頻率砍半**，而不是
「同一個NEAR_CADENCE週期內錯開順序」。往下是完整推導，麻煩你自己也重算一次核對。

## 追蹤鏈：外層迴圈的呼叫頻率，對上 `CadenceStagger.next_tick` 的回傳值範圍

```
sim_runner.gd:308-309   if state.world.current_tick % NEAR_CADENCE == 0:
                            var all_teams = state.teams.keys()
                            ...（含 _run_systems，含 faction_ai，含你要插的 loop2.solo 檢查）
⇒ ★★★這整段（含你打算插入的 per-team 檢查）只在 tick 0,60,120,180... 被執行過，
   不是每個 tick 都跑——這是【前提】，你的三格問題都建立在這個前提上但都沒有
   把它跟 CadenceStagger 的公式對在一起算。
```

```
cadence_stagger.gd:44-53
   cycle_index = current_tick / cadence
   candidate   = (cycle_index + 1) * cadence + offset      # offset ∈ [0, cadence-1]
   ⇒ candidate 落在【下一個週期整個範圍】 [(cycle_index+1)*cadence, (cycle_index+2)*cadence-1]
```

**代實際數字（cadence=NEAR_CADENCE=60）**：某隊在 tick=60 想過，算出
`solo_think_next_tick`：cycle_index=1，`candidate = 120 + offset`（offset∈[0,59]）。

```
下一次外層迴圈檢查點是 tick=120：
   if 120 < candidate: continue
   candidate = 120+offset ⇒ 只有 offset==0 才會 120<candidate 為假（該隊在120就想）
   ★★★offset∈[1,59]（60 個可能值裡的 59 個，≈98.3%）⇒ 120<candidate 為真 ⇒ 該隊被跳過
   ⇒ 下一次真正檢查點是 tick=180：180 < candidate(≤179) 恆假 ⇒ 該隊在 180 才想

⇒ 對幾乎所有隊（59/60 的 hash 結果）：上次想是 tick=60，下次想是 tick=180 ——
  【間隔 120 tick，不是 60】。只有 offset 剛好算出 0 的那 1/60 的隊才維持 60 tick 間隔。
```

**這不是巧合也不是邊界情況——這是這個機制在「offset 解析度細於檢查頻率」時的
必然結果**：`next_tick` 回傳的 offset 範圍是 [0,59]（連續值），但外層檢查只能在
60 的倍數那幾個離散點取樣——任何 candidate 落在 (現在的檢查點, 下一個檢查點] 這
59 個 tick 的區間裡，效果都跟「落在下下個檢查點」完全相同（因為中間那個檢查點
根本不會被跑到）。**offset 的精細資訊在這裡被系統性地捨去，唯一留下來的信息是
「這隊算出的 offset 是不是剛好 0」。**

## (1)(2) 合併回答：不是「半錯開的怪狀態」，也不是「MIN_GAP在小cadence上要小心」——
是這個機制在 cadence==檢查頻率時，把每小時一次想【變成】兩小時一次想（對~98%的隊）

你(1)問的「視野過期」不成立——vision（`sim_runner.gd:166`）跟 faction_ai 在同一個
`_run_systems` 呼叫裡、同一個 tick 內依序跑，隊什麼時候真的想，視野就在同一個 tick
剛更新過，兩者不會脫勾。**但你問錯了風險方向**：真正的風險不是「想的時候看到舊視野」，
是「幾乎所有隊的想的頻率本身就被砍半了」。

你(2)問的「MIN_GAP在NEAR_CADENCE=60這種小cadence上會不會有問題,這支工具可能沒在
這個量級驗過」——**驗證結果：不只是沒驗過,是數學上必然壞在這個量級**。
`CadenceStagger` 目前唯一的既有用法（`THREAT_CADENCE=1440`）cadence 是檢查頻率
（60）的 24 倍，同樣的「捨去到下一個檢查點」效應在那裡只造成 ~4%的相對誤差
（60/1440），小到可以忽略；而這次你要拿它去 stagger 一個【cadence本身就等於
檢查頻率】的東西，捨去效應變成 100%的相對誤差（多等一整個週期）。這正是
「這支工具可能沒在這個量級被驗過」的精確答案：**它不是沒驗過會怎樣,是在這個
量級下的行為跟在原本用法下的行為是兩件事，不是同一個機制的小小延伸**。

## 這對這張票意味著什麼

blueprint 裁的 WHAT 是「接受世界改變」——但「接受某些隊偶爾兩小時想一次」
（你§④風險②寫的）跟「幾乎全部隊從此固定兩小時想一次」是完全不同量級的世界改變，
前者聽起來像可忽略的 wrap 邊界噪音，後者是**把整個系統的決策節奏拉慢一倍**。
這個規模的改變，我不確定 blueprint 裁「接受」的時候看到的是哪一個版本——
這格建議你算完數字後明確帶回去問清楚，不是我能替你裁的。

**技術上要怎麼修（不裁決,只是列選項給你判）**：
```
選項A：把 per-team 的 solo_think 檢查【移出】`% NEAR_CADENCE` 那個外層閘，
       改成每個 tick 都檢查（只是多數 tick 檢查完什麼都不做）——
       ★這正好牴觸你§②③「不要把整個%NEAR_CADENCE全域閘改掉」那條約束，
       需要重新評估這條約束是否還站得住,還是要縮小成「別的用途(視野/移動/forced_event)
       不受影響,但這一個新檢查允許逐tick跑」。
選項B：放棄用 CadenceStagger 的連續 offset，改成【桶】模式：
       team 的桶 = hash(team_id) % N（N=想要分幾批），
       cycle_index % N == 該隊的桶 才想 ⇒ 這樣間隔【精確】是 N×60，不是忽高忽低，
       且完全對齊現有的「只在NEAR_CADENCE倍數上檢查」這個限制,不用碰外層閘。
       ★代價：這是【新機制】不是【沿用CadenceStagger】,你§②開頭強調的「不造新東西」
       這句話需要收回或改判準——但它比A誠實,不會製造你自己都沒想到的頻率砍半。
```
我沒有偏好，但要求：**選哪個都要先把「隊的實際思考間隔分布」算出來或印出來，
不能只憑「用了CadenceStagger」就假設效果跟它在1440那個用法上一樣**。

## (3) 你自己猜對了——這支 tap 量的是【被排進 all_teams】不是【真的想】，需要第二支

驗證你的猜測：`pass.byteam` 的 bump 點在 `sim_runner.gd:312-314`，**在
`_run_systems` 呼叫之前**，量的是「這個 tick 這隊有沒有出現在 `all_teams`」——
這個集合本身完全不受這張票影響（永遠是全部隊），所以這支 tap 錯開前後都會回報
「逐隊相同」，**卻量不到你真正想守的東西**（loop2.solo 是不是真的執行了）。
你的判斷對：需要一支新 tap，掛在 `if current_tick < solo_think_next_tick: continue`
那個判斷【之後】（只在真的往下跑思考時才 bump），沿用同樣的 `%04d` per-team 格式，
這樣才能直接印出上面算出來的「間隔分布」，把我推的數字換成真的量出來的數字。

## 其餘

②的 T0/相位不可讀兩條護欄、③④驗收其餘格、④風險①③（世界改變接受／wrap分布要印出）、
⑤不做的事：設計本身沒問題，只是都建立在「間隔=~60±少量」這個現在看來不成立的假設上，
等頻率問題定案後這些格子多半還適用，不用整張重寫。

CLEAN 差：先把「幾乎全隊間隔變兩倍」這件事帶回 blueprint 確認是不是他認可的「世界改變」，
再決定技術路線（A/B 或第三案）。這格我判斷值得回上游，不是我能單獨拍板放行的規模。
