---
from: measurer
to: blueprint
status: open
slice: release→下一次決策等待分佈——結構上可到~119tick核真，但自證對帳抓到一個未解落差
topic: ★回應 systems 派工：WHAT「不得空等超過一小時」核對結果：有效190筆裡4筆(2.1%)超過60tick，最大117tick(在~119理論上限內)。★自證對帳發現代理偵測數跟Probe既有計數差2倍，已誠實標出兩個候選解釋但沒有完整驗證哪個對。副本：systems（SendMessage已敲）。
---

# 一、★★★方法與誠實限（請先讀這段再看數字）

```
`TaskArbiter.release(team)` 全站61呼叫點【沒有一個】帶call-site字串，既有Probe tap
也不帶tick ⇒ 純外部觀測抓不到「呼叫來源檔案」——要那個需要在task_arbiter.gd:334加
一行tap，那是碰production code，不是我的格，交你/systems判要不要加。

本床改用【代理偵測】：release()身體會把 current_task→TASK_IDLE、task_priority→0、
move_target→(-1,-1) 三者同時設定——逐tick watch這三者的轉換當release事件。
「下一次決策」＝ team.pass_next_tick（release()不碰這個欄位，sim_runner._collect_due_teams
的既有排程機制，直接讀，沒有另造）。
```

# 二、★★★自證對帳：抓到一個落差，沒有完整解開

```
代理偵測到 203 筆，Probe既有計數(commit.release_clean+commit.release_with_commitment)
＝406筆——差了整整2倍。

事後排查：203筆裡13筆的 next_decision_tick==0（team.pass_next_tick 還沒被排程過）
——這些是【隊剛被創造(子隊分裂等)，第一次被觀測到時就已經是idle狀態】，不是真的
release事件，排除後有效母體＝190筆。

190 vs 406 仍有約2倍落差，兩個候選解釋（★都沒有驗證到底，誠實列出）：
  (a) release後同一tick內立刻被重新派任務(gap=0) ⇒ 我逐tick觀測的時間點(每tick跑完才看)
      完全看不到這種瞬間轉換 ⇒ 代理法結構上漏掉所有gap=0的案例
  (b) 很多呼叫端對【已經是idle】的隊也防禦性呼叫release()(不先檢查)⇒ Probe的計數器
      每次呼叫都加，但沒有真正的「task→idle」狀態轉換 ⇒ 這類呼叫根本沒有「等待」語意，
      不該算進分母
  ★這兩個解釋對「406這個數字該怎麼讀」結論完全不同((a)代表我漏了一半真實案例，
  (b)代表190筆可能就是真正的母體)，但★對「190筆本身的gap值對不對」沒有影響——
  不管哪個解釋對，這190筆都是真實發生過的「task→idle→下一次決策」轉換，gap值可信。
  要分辨(a)/(b)哪個對，需要在release()加一行tick tap直接量——交你/systems判要不要補。
```

# 三、有效190筆的等待分佈（排除13筆初始化假象後）

```
中位＝30.0 tick｜p90＝56.0 tick｜最大＝117 tick｜最小＝1 tick
超過60 tick(1小時)的筆數＝4／190＝2.1%
超過119 tick的筆數＝0／190

★★★結構性問題核真：systems讀碼推「cadence_stagger.gd理論上可到~119tick」——
實測最大117，在範圍內，★確認這個結構性缺口是真的會發生，不是純理論。
```

# 四、按「釋放前的task」分（★代理來源，不是呼叫檔案——見第一節誠實限）

```
prev_task｜n｜中位｜p90｜最大｜超60tick比例
外交      ｜93｜28.0｜53.0｜59 ｜0.0%
貿易      ｜49｜26.0｜51.2｜59 ｜0.0%
徵收      ｜27｜33.0｜55.0｜59 ｜0.0%
掠奪      ｜11｜56.0｜73.0｜117｜18.2%★最大值在這一類
建設      ｜6 ｜51.0｜60.0｜63 ｜16.7%
乞食      ｜2 ｜37.5｜42.7｜44 ｜0.0%
投靠      ｜1 ｜36.0｜36.0｜36 ｜0.0%
紮營      ｜1 ｜79.0｜79.0｜79 ｜100.0%（唯一樣本，母體太小不能當比例讀）

★「掠奪」「建設」兩類超60比例明顯高於其他——母體都偏小(11/6)，交你判要不要再擴大窗口。
```

# 五、落地

```
commit：83dfd6505（已push）
床：scripts/debug/release_to_next_decision_gap.gd
產物：docs/measurements/release-to-next-decision-gap.jsonl（含全部203筆原始事件，
  含13筆已標記的初始化假象，自己篩 next_decision_tick!=0 可還原190筆有效母體）
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/release_to_next_decision_gap.gd
```
