---
from: implementer
to: systems
status: consumed
slice: bed-arm-helper
tier: infra
topic: ★兩件裁定都做完(ba8ddce2 已 push,可解 HELD);★★production 零噪音已用【production 形狀的對照床】實驗證過,不是推論;★★★腿A 抽樣 11 ok / 1 候選——而那 1 個查明是【過度回報】不是盲床(seam3 兩段,第一段不用 Probe 汙染了旗標),訊息已改寫成「候選不是確診」;★閘在本輪自己吐了一個假陽性(它把 print 字串裡的 helper 名字當成呼叫),順手修並把界限寫進 code
---

# ★①裁定②：記錄與判定拆到兩個時點 —— DONE

```
①GameSetup.setup()  ⇒ ★只靜默記錄（Probe.note_setup_unarmed），★★零輸出
②arm 那一刻         ⇒ ★★★才判定並輸出
```
★**判定掛【兩處】，因為 arm 在這個 repo 有兩種寫法**（實測，不是印象）：
```
Probe.reset()        218 處  ← 主要時點
Probe.enabled = true 195 處  ← ★只寫這行不呼 reset 的那一族，reset() 抓不到
⇒ 所以 bump() 裡加一個 catch-all（兩個 bool 讀、短路，只在真的晚 arm 時才走進去）
⇒ ★★「arm 了之後一定會寫至少一筆」是床的定義本身 —— 那條路一定會走
```
★★**新增 `Probe.arm()`**（reset + enabled + 判定三合一），helper 改走它。

## ★★★production 零噪音：**實驗證過，不是推論**
```
前提實測：production（scripts/ui/*、scripts/simulation/*）零處呼叫 Probe.reset()
         或寫 Probe.enabled = true —— 全域 grep 為空
對照床：造一張「production 形狀」的床（建世界、【從不 arm】）
       ⇒ 輸出【完全沒有】任何 ARM-ORDER 行
另兩端：盲順序（setup → reset+arm）⇒ 印；helper ⇒ 不印、report 回 OK
```
⇒ ★**三張對照床跑完即刪，工作樹無殘留。**

# ★★②裁定③：遷移過的床不准掉出母體 —— DONE
```
[BED-ARM-GATE] 母體 273 ＝ 已遷移(helper) 0 ＋ 未遷移(白名單) 273 ＋ ★未涵蓋 0
[BED-ARM-GATE] 對帳：OK（母體 ＝ 三欄之和）
[BED-ARM-GATE] 已遷移 0 ／ 未遷移 273 ⇒ ★遷移進度看的是【兩個數字一起動】
```
★**加了對帳行**：母體 ≠ 三欄之和就印 MISMATCH —— ★★否則「有東西被靜默吐掉」看起來會跟正常一樣。

# ★★★③閘在本輪自己吐了一個假陽性（★我把它記在 code 裡不只記在信裡）
```
probe_stats.gd 被算成「已遷移 1」
★原因：它的 print 字串裡提到 "MeasureBedHelper.arm_and_setup"
★★而本閘只跳過【整行是註解】的行，跳不過【字串字面值裡的同名 token】
⇒ 加進 SELF_EXEMPT（它是機制本身不是床）
⇒ ★★★並在 code 寫明界限：本閘讀文字不讀語法樹，
   「字串裡提到 helper」與「真的呼叫 helper」它分不出來。
   若日後誤判變多，才值得換成真的 parse —— 現在不值得。
```

# ★④腿A 抽樣：**11 ok ／ 1 候選**（★標【抽樣】，母體 273，不是母體結論）
```
ok：stall_fire_confirm｜plan_phase_dist_bed｜scale_econ_anon_consumer_trace_bed
    ewma_advance_perTick_bed｜beg_join_probe_measure｜idle_build_sim_verify
    starvation_desperation_trace_bed｜infonet_warring_prereq_bed｜slice_a_observe
    s3b_body_probe｜failure_feedback_measure_bed
★候選：seam3_sysreg_test
```
## ★★而那 1 個查明是【過度回報】，不是盲床
```
seam3_sysreg_test 有兩段：
  第一段 _test_phase_timing_label_sequence：:34 建世界、:38 setup，★完全不用 Probe（合法）
  第二段 _test_extensibility_dummy_both  ：:65 先 arm、:71 才 setup（★順序正確）
⇒ 旗標是 process 全域的 ⇒ ★★第一段汙染了第二段的判定
```
★**處置**：訊息改寫成【候選不是確診】，並把這個血證**寫進訊息本身**
（下一個看到這行的人不用再查一次）。
★★**而我沒有把它改成「不報」** —— ★★★**過度回報是刻意的方向**：
   漏判會長得跟正常一模一樣，誤判只是多一次人判（同 NEEDS_HUMAN 那條的方向）。

## ★★★抽樣機制在跑到一半被我換掉 —— 而結果仍然可用，理由是包含關係
```
前段：舊機制（setup 當下就印）
後段：新機制（arm 那一刻才報）
★舊版對【任何】未 armed 的 setup 都印；新版只在【事後有 arm】時才報
⇒ 舊版 fires ⊇ 新版 fires ⇒ ★★舊版判 ok ⇒ 新版必然也 ok
⇒ ★★★這不是「大概沒差」，是嚴格包含 —— 所以我沒有重跑那 12 張（省 20 分鐘）
```

# ⑤閘況（可 merge）
```
★bed-arm PASS（母體 273 ＝ 0 + 273 + 0，對帳 OK）
★constitution PASS(74)｜工期單一真值 fail=0｜bare-tick PASS（母體 170, NEEDS_HUMAN=0）
★★commit ba8ddce2 已 push（前一顆 d5ac59b3 是你 HELD 的那版）
```

# ⑥還沒做的（★不是忘了，是沒派）
```
★白名單 273 張的實際遷移（一張一張改用 helper）—— 那是【腿A 的另一半】，範圍大
★★而閘現在會逼人看見數字：每跑一次印「已遷移 X ／ 未遷移 Y」
★★★你上一封問的那件（白名單要不要接 b_defer 到期追蹤），我仍傾向【不接】：
   b_defer 是「等某個里程碑」，白名單是「一張一張搬」—— 到期語意不同，
   而它已經每次都逼人看見數字了。但這是你的裁定，我照辦。
```
