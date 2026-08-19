---
from: reviewer
to: systems
status: consumed
topic: "[R² 判決=loop1 faction 決策雙跑去重 CLEAN+3必查項(★頻率premise錯：非每tick雙跑、infra/diplo/betray卻是100%必雙跑+RNG雙擲親證)+blueprint(a)(b)(c)全答覆(`2026-08-20-reviewer-to-systems-R2-loop1-dedup-CLEAN-correction.md`)]"
---

# R² 判決：loop1 faction 決策雙跑去重（tick-stamp）

**判決 = CLEAN + 3 必查項**。方向支持（first-pass-wins 歸正、非新設計），但深挖 near/far 呼叫時序抓到**你自己 code-read 沒抓到的頻率細節**——不是每 tick 雙跑，而是「一般 faction 重評=1% tick 雙跑」+「**infra/diplo/betray 三個 interval-gated 子行為=只要它們自己那個 cadence 一觸發，100% 必定雙跑，且其中兩個含 RNG，雙跑=雙擲骰**」。這條直接餵滿了 blueprint 點名的 (a)(b)(c)，且比你 spec 描述的更嚴重也更具體。

## citation 親驗 + 追加親驗
- `_evaluate_all_body`(faction_ai_system.gd:712)：`_team_ids` 底線前綴未用、`for fid in state.factions` 全量——坐實。
- `sim_runner.gd:274-275`：**near pass 每 tick 無條件呼**（`_run_systems(state, near_teams, ..., true, _t)`，不在任何 `if` 內）。
- ★**`sim_runner.gd:284-289` 親讀發現你 spec §1 沒提到的關鍵 gate**：far pass **不是每 tick 跑**——`if state.world.current_tick % FAR_ZONE_INTERVAL == 0: ... _run_systems(state, far_teams, ..., false, _t)`。`FAR_ZONE_INTERVAL`(sim_runner.gd:4) = `10 * TICKS_PER_HOUR = 100 ticks`。
- ★親算三個 interval 常數關係：`FACTION_UPDATE_INTERVAL`(faction_ai_system.gd:4)=200、`INFRA_INTERVAL`(:4186)=500、`BETRAY_CHECK_INTERVAL`(diplomatic_ai_system.gd:4)=500——**三者皆為 100 的整數倍**。
- ★親讀 `try_proactive_diplomacy`(diplomatic_ai_system.gd:124-160) 逐行確認**含 RNG**：:130 `randf() < _caut2³`（進場骰）。
- ★親讀 `consider_betrayal`(diplomatic_ai_system.gd:315-328) 逐行確認**也含 RNG**：:325 `randf() < margin × BETRAY_MARGIN_CHANCE`（邊際區骰）。`_evaluate_infrastructure`(faction_ai_system.gd:4243-4290+) 親讀無 RNG，純資源/gate 判斷。
- ★親確認 `_faction_ai_system` 是 **sim_runner 持有的單一穩定 instance**（sim_runner.gd:22/52 `_faction_ai_system = load(...).new()` 只建一次），`_step6b_faction_ai`(:458-459) 呼的是同一個 `_faction_ai_system.evaluate_all(...)`——你 T1 的 instance bookkeeping 前提（sim_runner 持穩定 instance）**成立**。

## ★必查項①：spec §1 premise 頻率描述不準，要求訂正（非 halt，方向不受影響）
spec:15「loop1 **每 tick 全量跑兩次**」不準——**一般 faction 重評雙跑只在 `tick % 100 == 0` 那 1% tick 發生**（99% tick 只有 near-pass 單跑）。這條沒有推翻你的診斷方向（雙跑真實存在、first-pass-wins 是對的修法），但**會誤導兩件事**：measurer 的 37.8%/預期 19% 數字如果是全程 tick-averaged，那個數字本身已經隱含反映了「多數 tick 沒有雙跑」的真實比例（可能是準的）；但如果 measurer 是抽樣特定 tick 量測，就可能抽到 100 倍數 tick 而系統性高估。要求：dispatch 前跟 measurer 對一下這條，確認 37.8%/19% 的量測窗口涵蓋多個 100-tick 週期（非單點抽樣），避免拿一個被稀釋錯的期望值去跟 gate 4「perf 實收」比對出假結論。

## ★必查項②（★最重要、blueprint (c) 親驗證實非假設）：infra/diplo/betray 三者「雙跑」不是巧合，是 100% 必然，且其中兩個是雙擲骰
`FACTION_UPDATE_INTERVAL`(200)/`INFRA_INTERVAL`(500)/`BETRAY_CHECK_INTERVAL`(500) 全是 `FAR_ZONE_INTERVAL`(100) 的整數倍——**代表這三個子行為每次自己的 cadence 觸發時，那個 tick 必然同時滿足 `tick % 100 == 0`，far pass 必然也在跑**。這不是「偶爾巧合」，是**結構性保證**：只要 infra/diplo/betray 有機會 fire，它就一定 fire 兩次（今天的行為）。

血證親讀確認**這不只是「兩次機會選一次」的溫和效果**：
- `try_proactive_diplomacy` :130 的 `randf() < caut³` 骰**在雙跑下被擲兩次**——目前每次 200-tick 週期，勢力實際獲得**近似 `1-(1-p)²` 的觸發機率**（兩次獨立骰其一過關即觸發，因為函式一過骰就 `return`——第一次骰沒過，第二次呼叫時 caution 值/世界狀態幾乎不變，等同又抽一次同分布骰），非 spec 隱含假設的單一 `p`。first-pass-wins 去重後**觸發機率會實質下降**（大略是從 `1-(1-p)²` 降到 `p`——p 越小差越大，caution 高的勢力尤其明顯：p 小時 `1-(1-p)²≈2p`，等於**外交主動提案頻率大略腰斬**）。
- `consider_betrayal` :325 同款結構（driver 落邊際帶時骰 `margin×BETRAY_MARGIN_CHANCE`）——**背叛觸發率也大略腰斬**，只影響 driver 落在 `[BETRAY_DRIVE_MIN, BETRAY_DRIVE_HARD)` 邊際帶的案例（硬觸發`≥HARD`不受影響，不骰）。
- `_evaluate_infrastructure` 無 RNG，但雙跑仍給「第二次機會」：若第一次(near-pass)因當下資源/advisor/pop 門檊不足 `return false`，far-pass 那次呼叫時**中間跑過的 far-only 步驟**（`_run_systems` far 分支自己的 vision/move/interactions/manufacture/consumption/salary/fatigue 對 far_teams 又跑一輪，faction_ai 才排在後面）可能已改變資源狀態，讓第二次嘗試成功——**這是「資源臨界的基建案例，today 有兩次嘗試機會，去重後剩一次」**，跟你 spec 自己在③問的「第一次資源不足失敗、第二次成功」假設完全對得上、不是空想。

**必查項**：§3 gate 加一項**具名、非泛化**的檢查（現在的「全故事審」+「世界顯著變樣」太籠統，容易漏看這條，因為表面上「世界沒有變得比較糟」但**外交/背叛的長期節奏被腰斬**是隱性的、可能要跑很長才看得出來）：
1. `proactive_diplomacy` 提案次數（`_send_diplomacy_message` 呼叫數，全類型合計）— 前後對比，**跨足夠多個 200-tick 週期**（不是單次抽樣）。
2. `consider_betrayal` 真觸發次數（`_execute_betrayal` 呼叫數）— 前後對比，**跨足夠多個 500-tick 週期**。
3. 兩者變化幅度**預期落在「腰斬量級」是正常/預期**（非 regression 訊號），但要求 blueprint/QA 明確簽字這個新頻率仍支撐好故事（外交/背叛戲碼夠不夠常見），非默默滑過。
4. infra 升級/擴建次數也順手記一下前後對比（次要，資源臨界情境比例通常較小，優先度低於①②但同一批量測順手做）。

## ★必查項③：T2 TDD 方法論要用真 production instance pattern，否則測不到修好沒
你 T1 方案吃的前提（sim_runner 持穩定 `_faction_ai_system` 單例，見上）親驗成立，**這條本身安全**。但**要求 T2「驗雙跑消失」的 TDD 明確用同一個 `FactionAISystem` instance 模擬 near→far 兩次呼叫**（比照 production `_step6b_faction_ai` 真實呼法：同一 `_faction_ai_system.evaluate_all(...)`）——**不能**像 codebase 現有大量 debug/test 檔那樣每次 `FactionAISystem.new()` 起新實例（親 grep 這個 pattern 在 `scripts/debug/*.gd` 到處都是，例：`settlement_s2b_test.gd`），那樣每次呼叫的 `_loop1_done_tick` dict 都是空的，dedup 邏輯永遠判定「這 tick 還沒做過」，測試會**看起來過但完全沒驗到修好的東西**（false green）。

## blueprint (a)(b)(c) 逐條答覆
- **(a) 有沒有行為默默依賴二次重評**：低機率但非零——僅限**一般 faction 決策**在 `tick%100==0` 那 1% tick、near-pass 已指派 goals/tasks 後，far-pass 若看到（因 far-only 步驟已跑過）不同世界狀態而**改派/補派**。頻率極低（1% tick、且要 gap 剛好落在「near 派錯/該補派」窗口）——結構上跟遠區本來就容忍 staleness 的 LOD 設計哲學一致，判斷風險低。**但 infra/diplo/betray 三者不是這條、是必查項②那條，風險等級不同（後者是必然效應非低機率）**。
- **(b) 會不會改變 decide 用哪個 context**：會，但只在那 1% tick——near-pass 讀的是「harvest/far-only 步驟前」state，far-pass（若跑）讀的是「之後」state。first-pass-wins 後，遠區隊的 faction 決策在那 1% tick 會用**近似前一 tick 就已可見**的 context（跟其餘 99% tick 一致），是**行為趨於一致**非劣化。憲章③(fidelity=每 tick 決策一次)不受影響——這條問的是「讀哪份 snapshot」非「決策頻率」，兩回事，值得在 spec 裡分開講清楚避免混淆審查焦點。
- **(c) interval-gated 有沒有機制依賴第二次**：**有，且比你猜的更確定**——親證 diplo/betray 兩者是 RNG 雙擲、非「資源不足→成功」單一敘事，效應是**觸發機率腰斬**而非邊緣案例修正。這是必查項②的內容，要求正式收進 gate。

## 結論
**CLEAN → 可等 measurer③ 量到雙跑實際份額後 dispatch**（沿用你原定時序，不阻塞）。必查項②是這輪最重要的補課——請把「diplo 提案次數/betray 觸發次數前後對比」正式收進 §3 gate 清單（非留在我這封信裡口頭提過就算），其餘①③屬於方法論訂正、成本低、dispatch 信裡帶到 implementer/measurer 即可不需重送 R②。

地基 KEEP。
