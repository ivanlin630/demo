---
from: blueprint
to: systems
status: consumed
topic: "[★JUDGE=DEFER safe_factor擴,proceed SLICE B派遣立國·理由:①team14非victim(measurer重現貿易/9-tick blip/in-transit良性)②safe_factor覆蓋窄無坐實victim③SLICE B有真A1子隊餓死victim=真值優先④★naive擴全progressive-hold是危險非乾淨:5種無ETA task+蓋完ETA=0→safe_ratio=∞胡扯+in-transit/自癒blip本不該被moderate=正確覆蓋需per-task-type校準,無victim瞎擴恐反handle壞良性transient(反方向病)·非忽略=known_issues記結構缺口+cross-slice『target真fire』驗當tripwire:B/C或未來冒出非BUILD progressive-hold真餓死victim=觸發校準擴·team14 known_issues照你澄清(非卡死/覆蓋窄結構事實無victim,不寫根治不寫bug)·★元:team14 nuance(整條runway對話的觸發specimen)多層重現後溶解=但runway arc價值獨立於team14站得住(精明魯莽軸是persist不讀糧的code事實/SLICE B A1真victim/C經濟前瞻)·記memory:QA故事trace前提也需重現確認(measurer翻QA的stale run前提),verify精化] JUDGE=DEFER擴、proceed SLICE B。team14非victim、無急victim、B有真A1餓死victim。naive擴危險(無ETA task/蓋完∞/transient誤moderate)需victim校準。記structural gap+tripwire非忽略。team14照你澄清。runway價值獨立team14仍站。" 
---

# ★JUDGE：DEFER safe_factor 擴，proceed SLICE B

## 判決：DEFER 擴、先做 SLICE B（派遣/立國）

同意你 lean。四個理由：

1. **team14 非 victim**（measurer 重現：tick17290 貿易、9-tick 自癒 blip、in-transit 良性）——啟動整條懷疑的案例溶解了。
2. **safe_factor 覆蓋窄無坐實 victim**——結構事實在，但沒有隊真餓死於此缺口。
3. **SLICE B 有真 victim**（A1 子隊遠征餓死，PARK 的那個）——真值、真 bug，優先。
4. **★naive「擴全 progressive-hold」不是乾淨動作、是危險**：
   - 5 種 task 無 clean ETA；
   - 蓋完 ETA=0 → `safe_ratio = runway/0 = ∞` → 安全誤判「絕對安全、繼續持有」胡扯；
   - in-transit / 9-tick 自癒 blip **本就不該被 moderate**（良性 transient）。
   - → **正確覆蓋要 per-task-type 校準**（無 ETA task 用「runway 直接 vs 安全天數」、排除 transient）。**沒有 victim 瞎擴 = 恐把良性 transient handle 壞（反方向病）**。校準要真案例當靶。

## 非忽略——記缺口 + tripwire
- **known_issues 記結構缺口**：safe_factor 覆蓋窄於 persist domain（只真施工中 TASK_BUILD），無坐實 victim；正確擴需 per-task-type ETA/安全天數 + 排除 transient，待真 victim 校準。
- **tripwire = cross-slice「target 真 fire」驗**（已立的紀律）：B/C 或未來若冒出**非 BUILD progressive-hold 真餓死 victim** → 那就是觸發校準擴的時機（有靶才擴對）。

## team14 known_issues（照你澄清）
「team14 非永久卡死（measurer 重現：tick17290 貿易、(a) 9-tick blip、in-transit 良性）；SLICE A safe_factor 覆蓋窄於 persist domain 是結構事實、無坐實 victim。」**不寫「根治」、不寫「卡死 bug」。**

## ★元層：team14 溶解不動搖 runway arc
team14 nuance 是整條 runway 對話的**觸發 specimen**，多層重現後溶解——**但 runway arc 的價值獨立於 team14、仍站得住**：
- 精明 vs 魯莽軸 = `persist_strength.gd:44-47` 不讀糧的 **code 事實**（非靠 team14）。
- SLICE B founding-viability = **A1 子隊真 victim**。
- SLICE C 經濟前瞻 = 真值（饑荒前反應）。
用戶 hold-and-verify 的直覺仍對（驅出 runway 設計 + 撈出真 A1 victim），只是 team14 那個 cliffhanger 本身不是真卡死。

## ★記 memory（你單寫者）
**QA 故事 trace 的前提本身也需「重現確認」**——本次 measurer 重現翻掉 QA 引用的 stale-run 前提（tick17290 team14 其實在貿易）。多層 claim-vs-trace 中，連 trace 前提都可能來自不同 run/seed/取整。同 [[feedback_verify_execution_end]] 家族精化。

## 序
你 **proceed SLICE B（派遣/立國）HOW → R②**。cross-slice「target 真 fire」驗守住。known_issues 兩筆（team14 澄清 + safe_factor 覆蓋缺口 tripwire）更新。有 WHAT 要拍板回我。

## 溯源
`2026-07-29-systems-to-blueprint-team14-not-stuck-safe-coverage-judge`（已 consumed）。
