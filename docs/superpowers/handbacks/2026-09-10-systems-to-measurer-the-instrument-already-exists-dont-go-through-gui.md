---
from: systems
to: measurer
status: consumed
slice: 效能（frame-time 診斷）—— ★取數方法：儀器已經在了
topic: ★★★別走 GUI：你要的那個數【已經有儀器在量了】——`sim_runner._record_tick_perf` 每日 flush `[TickPerf] avg／★max`，而 `PHASE_SPIKE_US=100ms` 一超過就 dump `[PhaseSpike]` 相位拆解（★opt-in `SimRunner.phase_timing`，預設 off ⇒ 零成本零行為變）｜★★所以 headless 就能取數，因為用戶抱怨的是【思考層卡住】＝一個同步 tick 吃掉幾秒，那是 tick wall-time 不是 render｜★而這正是我自己那條規矩：派「量 X」的工單前先問 X 是不是已經在某個 tap 裡、只是沒印出來——我派工時沒問，你回報「還沒有跑法」讓我補問到了
---

# ① 你要的東西在哪（★file:line，不是印象）

```
scripts/simulation/sim_runner.gd:104  func _record_tick_perf(state, dt_us)
  :107-109  _perf_max_us   ← ★【最壞單 tick】，本來就在記
  :120-124  每日邊界 flush：
            [TickPerf] day=%d avg=%d us ★max=%d us ticks=%d teams=%d factions=%d
  :110-118  ★★phase_timing 且 dt_us > PHASE_SPIKE_US ⇒ 立刻 dump：
            [PhaseSpike] tick=%d dt=%d us teams=%d | <前 6 大相位 name=us>
  :137      static var phase_timing: bool = false     ← ★opt-in，預設 off
  :138      const PHASE_SPIKE_US: int = 100_000       ← ★★TEST VALUE，100ms
相位標籤來源：sim_runner 自己的 _pht(...) ＋ faction_ai_system:828 _fai_pht_s(...)
            （loop1.member_snap／update_goals／assign_tasks／infra／diplo／gather.* …）
```

⇒ ★**「誰在凍」這個問題，`[PhaseSpike]` 那一行就是答案的形狀**：
它印的正是**那一個超過門檻的 tick 裡，前六大相位各吃了多少 us**。

# ② ★★為什麼 headless 夠（而 GUI 是更貴的路）

```
用戶原話：「我不能接受用 60fps 跑到【思考層】後卡住 5～10 秒。」
⇒ ★卡住的是一個【同步的 tick】——它在 render 之外，而且它在 headless 裡【一模一樣地發生】。
⇒ ★★GUI 只是讓它【被看見】，不是讓它【被量到】。
★★★而走 GUI 會多付三筆：畫面本身的成本混進讀數、取數要另寫管道、
   跑起來慢得多（而你今天已經被一次 OOM 重跑咬過）。
⇒ 建議：**headless 先取數**。若拆解出來的凍點【不在思考層】（例如全落在 render／observation），
  那才是需要 GUI 的證據 —— ★而那個結論本身就會是這張票的產出。
```

# ③ 建議跑法（★形狀，不是命令；跑多久／幾顆 seed 是你的執行細節）

```
①開 SimRunner.phase_timing = true（★它的成本就是那幾個 Time.get_ticks_usec()，
  而【它預設 off 這件事本身】說明沒有人在常跑它 ⇒ ★★第一次開，順手確認它真的有印）
②跑一個【隊數會長大的窗】——★因為用戶的抱怨是「跑一跑之後才卡」，
  ⇒ ★★開局那幾天不會有 spike，母體要涵蓋到隊數／派系數變多之後。
③收兩種行：
   [TickPerf] 每日一行 ⇒ ★max 那一欄的【時間序列】（它會不會隨 teams 長大？）
   [PhaseSpike] 每個 spike 一行 ⇒ ★★哪個相位吃掉那一秒
④★★★門檻 PHASE_SPIKE_US=100ms 是 TEST VALUE：
   若一個 spike 都沒印 ⇒ **先別讀成「沒有凍」**——★先確認 [TickPerf] 的 max 到底多大。
   （若 max 遠小於 100ms，那才是「這個窗裡沒有凍」；
     ★★若 max 很大而 spike 沒印，那是 phase_timing 沒開成功 ⇒ 儀器沒接電。）
```

★**判準（我這邊要的，不是數字大小）**：

```
①最壞單 tick 是多少、它【隨隊數怎麼長】（★這比平均值重要一百倍）
②那一個 tick 裡【哪個相位】吃掉最多
③★★「可慢不可卡」是憲法級 ⇒ 報告要以【max】為主詞，avg 只當背景
   ——★★★我們過去所有 perf 量測都以總時／avg 為主詞，這條規矩把主詞換了。
```

# ④ ★我派工時漏掉的那一問（記在這裡，不是客套）

```
我自己立過一條：**派「量 X」的工單前，先問「X 是不是已經在某個 tap 裡了，只是沒印出來」。**
★而我派這張票時【沒有問】 ⇒ 你收到的是一張「請你想辦法取數」的票，
  於是你合理地往 GUI 探路。
★★是你回報「還沒有任何跑法」讓我回頭去查，才發現儀器一直都在。
⇒ ★★★所以這一輪的教訓歸我：**「還沒有跑法」是一個【值得立刻回報】的狀態**，
   而你回報得很對——它讓上游有機會發現票本身少了一段。
```

# ⑤ 序

```
resident-identity 留背景跑，不衝突 —— ★你自己判的，我不介入。
frame-time 是體驗窗最後一張（blueprint 排最前），★★但【不要為了它中斷正在跑的東西】。
```
