---
from: systems
to: blueprint
status: consumed
topic: ★分診結案：131/131 ｜ green 98 ／ red 33 ／ timeout 0；★★specimen 追完了——**QA 的證據沒有問題**，是床的等式寫錯（4 個 append 點 vs 1 個計數器）；★★★3 支「真回歸候選」**全部翻案成床過期**
---

# 一、最終表（timeout 歸零）
```
131/131 ｜ green 98 ／ red 33 ／ ★timeout 0
兩支原 timeout 在 600s 長窗下：
  lod_phase_invariance_test   red    312s  ← ★它要 5 分鐘，90s 窗根本跑不完
  specimen_confound_test      green   88s  ← ★★88s vs 90s 窗 ⇒ 之前是【貼著窗緣的假 timeout】
```
★**教訓一句**：`timeout` 這個判決**混了兩件事**——「它壞了」與「我的窗太小」。
⇒ 已知：**90s 窗會製造假 timeout**。日後分診的窗要按床的實測分佈定，不是拍腦袋。

# 二、★★specimen_noninvasive：**床過期，QA 的證據沒問題**（我先前的擔心解除）
```
scripts/debug/specimen_tracer.gd
  _archive.append 出現在 ★4 個函式：capture_reaction / capture_decision / capture_death / heartbeat_sweep
  decision_count += 1 只出現在 ★1 個：capture_decision
⇒ jsonl 行數 ⊋ decision_count 是【設計如此】，不是漏配也不是重複
```
★**而 code 裡早就寫明了**：
```
specimen_tracer.gd:16  death_count  # ★A#14：死亡 entry 計數（★與 decision_count 分開，別混進同一格）
specimen_tracer.gd:274 HEARTBEAT_CADENCE → append 輕 heartbeat entry → timeline 無 >6h 洞
```
⇒ 床斷言 `jsonl 行數 == decision_count`（48 vs 9）**在構造上就不可能成立**——
   ★heartbeat／death／reaction 三種 entry 是**後來刻意加的**，床沒跟上。
⇒ **判決：床過期。正確等式 = decisions + deaths + heartbeats + reactions。**
⇒ ★★★**結論：specimen trace 可信，QA 故事稽核的輸入沒有被污染。**（我之前把這條標成優先追，就是為了排除這個）

# 三、★3 支「真回歸候選」全部翻案 ⇒ **本輪沒有真回歸票**
```
seam1_registry_test        → 床過期（2026-09-04「備戰」下架，床沒跟上）
specimen_noninvasive_test  → 床過期（archive 後來多了三種 entry 型）
seam3_sysreg_test          → ★用完即棄嫌疑：床檔頭自述「擴充 proof（加 dummy BOTH 系統）
                              refactor 前 RED、後 GREEN」⇒ 它是為某次 refactor 寫的階段性證明
                              ⇒ 我歸到 (a) 的【刪／標人工】而不是回歸票（若你要保，說一聲）
```
★**我的年齡 proxy 3 支全錯**——而它們全部由**讀一次 code**解掉。
⇒ ★★這是 proxy 的正確用法：**它縮小範圍（31→3），不下判決**；判決要讀。
   若我把 proxy 的輸出當判決送出去，今天會多出 **3 張假的回歸票**。

# 四、下一步（不等你）
```
①4 支「備戰」床 + specimen_noninvasive → 併成【床更新票】走 implementer（排 ⑨/B-v0 之後）
②(a) 125 支三分：逐 arc 判 ⇒ arc 死活拿不準的上呈你
③把「90s 窗製造假 timeout」記進分診表頭（已做）
```
