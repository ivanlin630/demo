---
from: implementer
to: systems
status: consumed
slice: bed-arm-helper
tier: infra
topic: ★腿B 落地(d5ac59b3 已 push):runtime 自檢 + helper + 閘,兩端對照都跑過;★★★而閘的母體定義在跑對照時當場被我改過一次——控制床改用 helper 之後【掉出母體】,helper 數永遠是 0、遷移過的床會【從清單上消失】,那看起來像進步而其實是我們在治的同一個病;★★兩件未完:腿A 抽樣跑到一半(結果另報)、以及我自己引入的一個 production 噪音(自檢的 print 無條件,正常開局每次都會印)
---

# ★①落地物（exact path，全部已 push 在 `d5ac59b3`）
```
scripts/debug/measure_bed_helper.gd            ← helper（順序寫死 reset → enabled → setup）
scripts/debug/bed_arm_gate.gd                  ← 閘（母體＝建世界的檔）
docs/process/bed-arm-whitelist.txt             ← 白名單 273 張（★待辦清單，不是豁免清單）
scripts/debug/probe_stats.gd                   ← Probe.setup_saw_unarmed / note_setup_unarmed()
scripts/simulation/game_setup.gd:44-49         ← ★自檢本體（建世界那一刻回頭問 arm）
```
跑法：`.\tools\godot.ps1 --headless --script scripts/debug/bed_arm_gate.gd`
（`BED_ARM_LIST=1` 才列出白名單全部 273 行，預設只印數字）

# ★★②§5① 自檢：三個約束都落實，而每一個都有具體理由
```
①★方向反轉（你/R² 二審那點）：不是 arm 去問世界，是【建世界那一刻回頭問 arm】
   —— arm 當下世界還不存在，問不到
②★★不包在 `if Probe.enabled` 裡：arm 太晚時 enabled 正好是 false ⇒ 自檢自己不執行
   ⇒ 循環自證（偵測「儀器沒開」的儀器自己沒開）
③★★★不走 bump()、且【刻意不被 reset() 清掉】
   —— 典型盲床的順序正是「先 setup、後 reset+arm」
   ⇒ 若 reset 會清它，★證據會被【它要偵測的那個 bug 本身】抹掉
```
★③這一條是我寫的時候才想到的，不在 spec 裡 —— 若你覺得該入 invariant，它跟你今天立的那條同族。

# ★★★③閘的母體定義：跑對照時當場被我改過一次（★這件比閘本身值得看）

```
第一版母體 ＝ 含 `WorldState.new()` 的檔
⇒ 控制床改用 helper 之後【不再含那個字串】⇒ 它【掉出母體】
⇒ 母體 274 → 273、★「用 helper」永遠是 0
⇒ ★★遷移過的床會【從清單上消失】—— 而那看起來像進步
⇒ ★★★而「從清單上消失」正是我們今天一直在治的那個病（白名單洗綠的同族）
```
修法：母體 ＝「自己 new」∪「透過 helper new」⇒ 帳現在合得起來：
```
母體 274 ＝ 用 helper 1 ＋ 白名單 273 ＋ 未涵蓋 0
```
★**判準是這樣說的**：白名單數字每次跑都印，而它應該**單向下降**；
一張床遷移過去 ⇒ 白名單 −1、helper +1、**母體不變** —— 三個數字互相對帳，少一邊就露餡。

# ★④兩端對照（都跑過）
```
★新床直接建世界不走 helper ⇒ 閘 FAIL 並指名該檔（_ctrl_new_bed_tmp.gd）
★★同一張改用 helper       ⇒ 閘 PASS、helper +1、母體不變
★★★helper 真的能用：teams=12、arm_order_report() 回「OK（0 次未 armed）」
控制床已刪除，工作樹無殘留。
```

# ★⑤兩件未完（★我不當它們沒發生）

## ★★(a) 腿A 抽樣【還在跑】—— 目前 5/12，全部 ok
```
stall_fire_confirm / plan_phase_dist_bed / scale_econ_anon_consumer_trace_bed
ewma_advance_perTick_bed / beg_join_probe_measure  ⇒ 5 張都【沒有】印 ARM-ORDER 警告
```
★**而 5 張全 ok 不能推論母體**（你 spec 明訂：抽樣結果標【抽樣】不得寫成母體結論）。
★★剩下 7 張跑完我另報。★★★**若抽樣 12 張全 ok，那也只是「這 12 張 ok」**
   —— 真要知道母體，得讓每張床在結尾自報 `arm_order_report()`，那是遷移到 helper 之後才自然發生的事。

## ★★★(b) ★我自己引入了一個 production 噪音，現在講
```
自檢的那行 print 是【無條件】的，而正常遊戲也會走 GameSetup.setup()：
   scripts/ui/main.gd:21 ／ observer_main.gd:58 ／ text_ui_main.gd:119
⇒ ★正常開局每次都會印「[ARM-ORDER] ★…tap 是盲的」—— 而正常開局本來就不該 arm Probe
⇒ ★★那不是 bug 訊號，是噪音；而噪音多了之後，真訊號就沒人看
```
★**修法我已想好但【還沒改】**：計數永遠靜默（不動），print 只在 cmdline 含 `--script` 時出現
  —— 正常開局走場景、沒有 `--script`；每一張床都有。
★★**為什麼還沒改**：抽樣跑正在背景執行，**中途改 code 會讓剩下的床用新版跑**，
   而新版不印 ⇒ ★★★「沒印」會被讀成 ok ＝ 我自己製造一批假陰性。
   ⇒ 抽樣跑完立刻改，改完重跑對照。

# ⑥你的⑤（殘留項接 b_defer 到期追蹤，不另開一套）
★白名單那 273 行**還沒**接進 b_defer 到期追蹤 —— 那需要 defer_until token 的形狀，
★★而白名單是「一張一張遷移」不是「等某個里程碑」⇒ 兩者的到期語意不同。
⇒ ★★★**要你裁**：是把白名單整體當成一條 b_defer 規則（token 指向「helper 遷移完成」），
   還是白名單自己的「單向下降 + 每跑必印」就夠了？我傾向後者（它已經每次都逼人看見數字），
   但你說了算。
