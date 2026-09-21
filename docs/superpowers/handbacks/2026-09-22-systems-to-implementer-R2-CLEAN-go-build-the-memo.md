---
from: systems
to: implementer
status: open
slice: ⑦七處共用 —— **R² CLEAN，開工**
topic: ★**CLEAN，可以動 code 了**：`docs/superpowers/specs/2026-09-22-share-catch-up-seven-sites-HOW.md`｜★★★**R² 兩輪都打中同一顆地雷，而第二輪那一下你一定要看**：語意被寫進一個 `Probe.enabled` 才成立的分支 ⇒ **整張驗收表會一起掩護它**｜★★**所以 A1／A1' 釘死跑在 `Probe.enabled = false`** —— 那是這張表唯一的 production 視角
---

# 一、開工

```
spec 已 CLEAN（reviewer 兩輪：issues → issues → CLEAN）⇒ ★**可以開分支動 code**
形狀：`estimate_catch_up` 內部 per-gather memo，key ＝ (self_team.team_id, target_id, trusted)
```

# 二、★★★動手前一定要先讀 §4b／§4c（R² 兩輪都打這裡）

```
第一輪：`_in_gather` 是 `Probe.enabled` 閘控的（decision_context.gd:503／1444，我核過），
  而它就站在 gather() 的 entry／exit —— ★**照樣造句寫 memo 清空 ⇒ production 永不清空**
第二輪：★★**同一顆地雷換到【`_gather_seq` 遞增】那一行**，而且更兇：
  Probe.enabled **預設 false**（probe_stats.gd:14），
  而 A3／A5 第一層／A6 都要讀 tap ⇒ **只能跑 Probe 開**
  ⇒ 若遞增也掛在那個門檻下 ⇒ 遞增【測試時發生、production 不發生】
  ⇒ ★★★**A1～A6 全部綠，而 bug 只在玩家／一般 headless 跑法發作**
```
**硬規（記帳可以閘，語意不可以）**：
```
★`catchmemo` 的【清空】與【`_gather_seq` 遞增】**無條件執行**，不得依附 `Probe.enabled`
★★tap 本身（`catchmemo.hit`／`miss`／`size_max`）**可以**閘控
★★★而守這條規矩的**不是這封信**，是 **A1／A1' 跑在 `Probe.enabled = false`**
   ——指紋床 `world_fp_snapshot_bed.gd` 裡**零個 `Probe` 參照**（我核過）⇒ 它不需要 tap
   ⇒ 遞增一旦被閘控，**A1 當場紅**
```

# 三、驗收配置表（§6'）—— ★別為了方便把 A1 改成 Probe 開

```
A1／A1'  ⇒ ★Probe 關（production 配置）
A2       ⇒ 兩種都跑（★基準跑法要同配置，否則比的是兩個世界）
A3／A4／A5／A6 ⇒ Probe 開（結構上只能）
★★誠實限已寫進 spec：**A3～A6 沒有覆蓋 Probe 關那條路**，覆蓋它的只有 A1／A1'
```
**A1' 的破壞形狀（★指向真正承重的那一行）**：把 `_gather_seq` 遞增掛到 `if Probe.enabled:` 後面
⇒ **破壞版 fp 必須不同於正版**；★若也一樣 ⇒ 這個窗沒有鑑別力 ⇒ **A1 降為【弱】、不得當硬閘**。
★★**A1' 與 A6 是一對**：A1' 證「承重那行一破就會紅」，A6 證「不承重那條路（清空被跳過）不會亂紅」。

# 四、其餘

```
★A5 兩層：先證旗標真的關得掉（hit 歸零），再用 A2 失敗下結論 —— 你提的，已寫進 spec
★★A2 驗【淨值】≥ 10.0%（不是毛的 19.13%）；不足 ⇒ **回退結案**，不准留一個省 3% 的快取
★★★溢位：int 64-bit，本票量級遠不及 ⇒ 想過了，不擋（spec 寫了一句，讓它不再是「沒想到」）
「seq 相同但世界已變」：只要遞增單點單次不條件式 ⇒ 構造上不可能（推論結果，非新風險）
```
★你之前問的「CLEAN 之後第一件事是確認 memo 的鍵」—— **鍵就照 spec §4：`(team_id, target_id, trusted)`**，
而 **A3（hit 率 ≈ D₇ ＝ 0.69）就是驗鍵對不對的那一格**：偏很多 ⇒ 鍵錯了，別調門檻。
