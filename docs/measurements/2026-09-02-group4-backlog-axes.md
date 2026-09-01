# ④真 backlog 37 條 —— ★四軸表（★軸來自條目自己的文字，不是 systems 判的）

★**我不排序** —— ★★排序是 blueprint 的；我只把【條目自己說的話】整理成可排序的欄。

| 軸 | 意思 | 來源 |
|---|---|---|
| ★憲 | 條目自稱【違不變量／憲法級】 | 條目文字 |
| ★修法已知 | 條目裡已寫修向／根因已坐實／成因已寫在註解 | 條目文字 |
| ★有期限 | 條目自稱【某 slice 前必修】 | 條目文字 |
| ★條目自稱緩 | 非急／低優先／範圍小／非阻塞 | 條目文字 |

| # | ki 行 | ★憲 | ★修法已知 | ★有期限 | ★條目自稱緩 | 條目 |
|---|---|---|---|---|---|---|
| 1 | 771 |  |  |  | 緩 | smeltery + armorsmith = weaponsmith afford-ceiling 同 |
| 2 | 779 |  |  |  | 緩 | crisis 門檻 flow-based 漏偵絕對餓（food=0×500tick 不 fire，202 |
| 3 | 783 |  |  |  | 緩 | market-seeker 卡空市場不放棄→餓死（2026-07-22，QA 40-event 撿，DE |
| 4 | 787 |  | 修 |  |  | workshop demand-deficit 封頂太粗→連續（follow-up，2026-07-21 |
| 5 | 799 |  |  | 期 |  | ★null-belief-flee 凍結（個體 FLEE 對空氣逃，2026-07-20，Slice E |
| 6 | 803 |  |  | 期 |  | market_orders capture/demolish 不清（pre-existing 洩漏，20 |
| 7 | 807 |  |  | 期 |  | god-view 殘留 can_reach（faction_ai:1115，2026-07-20，Sli |
| 8 | 820 |  |  |  |  | ★野獸洩進 team 決策迴圈（beast-decision-loop leak，2026-07-19， |
| 9 | 836 |  |  |  |  | crisis-immunity 覆蓋不全（2026-07-19，team16 揭） |
| 10 | 840 |  |  |  |  | ★subteam-idle-latch = 第三種手不聽腦（6 隊，2026-07-19，QA 抓 me |
| 11 | 871 |  |  |  |  | task-priority-preempt 缺口（team48 型，2026-07-18，QA ② la |
| 12 | 875 |  | 修 |  |  | ★乞食死 rung——引擎幾乎不選乞食（2026-07-15，desperation QA 複判抓，絕境 |
| 13 | 879 |  | 修 |  |  | ★凍結威脅實體無 resolve/despawn（2026-07-15，QA desperation 複 |
| 14 | 883 | 憲 |  |  |  | ★SpecimenTracer combat-death 盲點（2026-07-15，違全量暫態觀測不變 |
| 15 | 887 |  |  |  |  | survival-latch: _evaluate_survival 每-tick 重觸 churn（2 |
| 16 | 895 |  |  |  |  | 求和 sue-for-peace 無 handler（2026-07-15，diplomacy grou |
| 17 | 899 |  |  |  |  | has_food_market god-view 既有債（2026-07-15，desperation- |
| 18 | 903 |  |  |  |  | ★Team18 lone-survivor death-limbo + intent 誤標致富（2026 |
| 19 | 915 |  |  |  |  | ★reeval_attribution_bed 死亡偵測 false-positive（2026-07- |
| 20 | 919 |  |  |  |  | ★小 pop int()/round() 截斷病=結構類（2026-07-10 sweep，bluepr |
| 21 | 994 |  |  |  |  | 觀測 GUI 揭項（2026-07-04 observer slice，純觀測揭露、sim 未動） |
| 22 | 1470 |  |  |  | 緩 | 決策引擎（貿易/訓練/囤貨 applicable-vs-target gap，2026-07-13 re |
| 23 | 1491 |  |  |  |  | 選敵 finder（_find_weakest_prey 同-faction 不濾 — R② Fix F |
| 24 | 1494 |  | 修 |  |  | god-view 位置 belief 化 follow-up（2026-07-15 merge 6aa3 |
| 25 | 1516 |  |  |  |  | state-transition specimen tap（下批候選，R² advisory 2026- |
| 26 | 1594 |  |  |  | 緩 | 生產框架 arc follow-up（2026-07-16,供給側成功後殘項） |
| 27 | 1718 |  |  |  |  | ★CONFIRMED tap-gap：faction-leave 4 出口無 Probe tap（202 |
| 28 | 1930 |  |  |  |  | `predator_density` 住在 `tile.resources` —— 資料模型混雜（202 |
| 29 | 1937 |  |  |  |  | ★★★`own_granary_tile` nil 崩 —— **修過一次沒修乾淨，而根不在呼叫點**（ |
| 30 | 1977 |  |  |  |  | ★★★註解描述了一個【不存在】的事實 —— `_calc_reserve`（2026-08-25，我當場 |
| 31 | 1992 |  |  |  |  | ★`local_value` 仍有 ~12 個 blind 呼叫點（2026-08-25，窮盡掃出，★不 |
| 32 | 2124 |  |  |  |  | ★★detail 檔的節【重複 4×】且副本已分歧（2026-08-27 發現，★早於今天、不是今天造成 |
| 33 | 2203 |  |  |  |  | ★五支決策支的【選擇】沒有落在可比較的持久欄位 —— 可觀測性缺口（2026-08-28） |
| 34 | 2235 |  |  |  |  | ★`harvest_system` 還有三個【無名骰子】（2026-09-01，S5a merge 時記 |
| 35 | 2246 |  | 修 |  |  | ★g1a 礦村未鑄幣【復發】（2026-09-01 記，systems） |
| 36 | 2263 |  |  |  |  | ★★★床的結構性盲區：`Probe.reset()` 在 `GameSetup.setup()` 之後（ |
| 37 | 2280 |  |  |  |  | ★settlement_s2b_test：**一張紅著、沒有人在讀的床**（2026-09-01） |
