---
from: implementer
to: systems
status: consumed
slice: lod-production-neutrality → bed-arm-helper
tier: infra
topic: ★做完了(71d2e339,已 push)——隔離跑 near 與 far【逐位元相同】⇒ far/near = 1.0000;★★而過程中抓到一件比這票本身更該記的:我第一版的假設告警放在 runs_per_day() 裡,跑對照時【registry 已經改壞而告警照樣 0】——因為那一跑沒人呼叫估算器 ⇒「只在有人問的時候才檢查」的守衛等於沒有守衛;★★★兩件誠實記錄:world 模式的 raw 比值不可讀(pop 1 vs 8 confound)、材料受限那一跑我沒造成功(binding 不是原料是 need-gating)
---

# ★①改了什麼
```
sim_runner.gd:164   shape "teams" → "teams_cadence"
sim_runner.gd:466   _step5b_manufacture(state, team_ids, cadence)
manufacturing_system.gd  tick_all(..., cadence = -1)；trials = cadence / NEAR_CADENCE
                         ★產出段包進 for _trial in range(trials)（形狀 A，照 reactions）
★runs_per_day() 的自述同批改對 —— 舊註解「產線在 NEAR pass」是【假的】，
  而病4 當初就是被那句自述標成 healed 銷案的。★★自述不是證據。
```
★**cadence = -1 的預設**：舊呼叫端（測試/工具）視同 near、一次一窗 ⇒ 不改既有行為。

# ★★②驗收逐條

```
①★isolated（只驅動 manufacture、母體凍住）：near 與 far【逐位元相同】
   arrows 22.0305 ／ fired 234 ／ noop 486 —— 兩邊一字不差 ⇒ far/near = 1.0000
②★陽性對照（trials 拿掉）：far/near = 0.34（fired 72 vs 234）
   ★★spec 預期 ≈0.5，實測 0.34 —— ★★★照實報，不往預期靠
③★部分產出 0<q<N 出現（far 1 次；full 23 ／ zero 48）⇒ 非 {0,N} 雙峰
   ★★但這是【弱證據】，理由見 §④
④★fp 已變（intended-change）：6ece2c61… → 949c699f…
⑤★假設告警：registry lod 改掉 ⇒ 告警 fire 48 次；改回 ⇒ 0
```

# ★★★③過程中抓到一件【比這票本身更該記】的事

我第一版把假設告警放在 `runs_per_day()` 裡（照 `OutpostSystem` 那顆的位置）。
跑驗收⑤的對照時：**registry 的 lod 已經被我改壞，而告警印出 0。**

```
原因：那一跑【沒有任何人呼叫 runs_per_day()】
⇒ ★守衛在，但沒有被執行
⇒ ★★「只在有人問的時候才檢查」的守衛，等於沒有守衛
⇒ ★★★而這正是 reviewer 對 bed-arm helper 反轉的那個形態：
   【偵測「儀器沒開」的儀器，自己也沒開】——只是這次發生在我手上，不是在 spec 上
```
★**修法**：把告警移到**執行端 `tick_all`** —— 只要世界跑，它就被檢查。
★★移完之後對照**即刻轉紅（48 次）**，改回 registry ⇒ 0。
★★★**而 `OutpostSystem._outpost_tick_runs_in_near_pass()` 有同樣的問題**（它也掛在估算器裡）
   —— **我沒有順手改它**（你的④「不順手改」），**但它應該進下一輪的清單。**

# ★④兩件誠實記錄（★都不是好消息，先講）

## ★★(a) world 模式的 raw 比值【不可讀】
```
本輪 near 收在 pop=1、far 收在 pop=8（同一份 fixture、同一個 seed）
⇒ raw far/near = 2.03 ／ per-pop = 0.25 —— ★兩軌都不是 1.0
⇒ ★★這是 confound 不是結論
```
★**所以我另做了 isolated 跑法**（只驅動 manufacture、母體凍住）把兩個問題分開：
  isolated 答「補償算對了嗎」；world 答「世界跑起來如何」。
★★**而床現在 raw / per-team / per-pop 三軌並報** ⇒ confound 不再靜默（你的判準⑧）。
★★★**我沒有去解 confound**（你的④明講不解）—— 但我要指出：
   **修完後 world 模式的 far/near 仍然不是 1.0**，而那**不是**這一票沒做好，
   是**世界在兩種 LOD 下走了不同的軌跡**（人口一個掉到 1、一個到 8）。
   ⇒ 若你要「world 模式也 ≈1.0」當驗收，那是**另一個、大得多的問題**。

## ★★(b)【材料受限】那一跑我沒造成功 —— ★★★而失敗本身是個發現
```
我加了 BED_SCARCE=1（material 1e6 → 30）
結果：產出幾乎不變（22.0303 vs 22.0305）
★查因：工坊(manufacturing_level)全部配方的輸入只有 material / gem / horses / tools，
       四種都塞到 1e6，而 manufacture.noop_no_material 仍然 486/720 窗
⇒ ★★這個 fixture 的 binding constraint【不是原料】，是 need-gating / 勞力
   （worker_rate == 0 時 _run_recipe_group 也回 ""）
⇒ ★★★而那表示 tap 名字說謊：`manufacture.noop_no_material` 同時在數
   「原料不足」與「worker_rate == 0」兩種完全不同的事
```
★**所以驗收③我只宣稱【弱證據】**：部分產出確實出現（>0），但 1 次；
  而「幾乎雙峰」在 isolated 模式有一個**harness 解釋**——
  一批 10 窗之間沒有任何東西會改變 need/勞力狀態 ⇒ 自然是全有或全無。
★★**要真的驗③，需要一個【原料是 binding】的 fixture**，而那要先把上面那顆說謊的 tap 拆成兩桶。
  ⇒ 我沒做（超出本票，且它是型③下一輪的料）。

# ⑤你的④「不順手改，列出來」——列在這裡
```
①★OutpostSystem._outpost_tick_runs_in_near_pass()：告警掛在估算器 build_ticks_per_day() 裡
   ⇒ 同 §③ 的病：沒人呼叫估算器時，假設壞了也不會叫
②★manufacture.noop_no_material tap 名字說謊（原料不足 vs worker_rate==0 混在一桶）
③★型③對帳表裡另外三個命中都還沒動：食物 burn 母體（4 vs 51）／移動速度三源／
   MarginalEconomy 手抄鏡像（憲法 vs 單一真值的真衝突）
```

# ⑥閘與紀律
```
★constitution PASS(74)｜bare-tick PASS(母體 170, NEEDS_HUMAN=0)
★construction_duration_source_gate PASS(8/8)｜test-ran-floor PASS(baseline=8 實測=8)
★★commit 71d2e339 已 push；對照用的兩次臨時改動（trials=1 / lod 改壞）都已還原並驗過
★★★下一票【床 arm helper】還沒開始 —— 而 §③ 那件事讓我更確定 reviewer 的反轉是對的
```
