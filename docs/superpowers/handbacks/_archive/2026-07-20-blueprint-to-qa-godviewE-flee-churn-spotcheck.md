---
from: blueprint
to: qa
status: consumed
topic: "[godview-E doom-delta 輕量抽查·不是全套故事稽核·靶=seed1337 幾隻逃跑churn死案是否coherent evasion]god-view Slice E belief-化正確(4 dispatch路徑確認)+gates綠+手不聽腦僅2(finder-check bed驗,非freeze-bug)。但真隊starve雙seed同時惡化(1337 7→13近翻倍、42 0→6)——這是本輪god-view系列第一次雙seed一起變差(先前都是seed互換)+幅度最大。死隊task分布逃跑最高。想在accept前輕量確認:抽3-5隻seed1337逃跑churn死案,是不是『真實閃避失敗』(belief讀last-seen/不確定威脅,合理逃錯方向/逃輸)coherent story,而非某種belief-navigation新bug(例如逃向錯誤belief位置thrash/反覆逃同一格)。非要求全套16隊逐隊讀,3-5隻代表性抽樣即可,重點看逃跑行為本身合不合理。"
---

# godview-E doom-delta 輕量抽查（非全套稽核）

## 為何要抽查
god-view Slice E（4 dispatch 路徑 belief-化：E1征服/E2 JOIN/E3建國吞併/E5突圍）機制確認正確、gates 綠、手不聽腦僅 2（用剛委任的 finder-check bed 驗，可信非 freeze-bug 假象）。measurer 判：死因分布（逃跑最高/覓食/建設）符合「belief-化讓 AI 不能偷看 live 位置→更真實的閃避拉扯→更難」的 intended doom-delta。

**但這次不一樣**：真隊 starve 雙 seed **同時**惡化（1337 7→13 近翻倍、42 0→6）——先前幾個 god-view slice 都是 seed 互換（一個好一個壞），這次是**一起變差**，且幅度目前最大。這個尺度會定調後面 Slice D（比 E 範圍更大）能接受多深的 doom-delta，值得多一道確認。

## 求你做什麼（輕量，非全套）
抽 **3-5 隻 seed1337 的逃跑（TASK_FLEE）churn 死案**，快速確認：
- 是不是**真實閃避失敗**的合理故事（belief 讀 last-seen 位置、威脅不確定，逃錯方向/逃輸真威脅，coherent）？
- 還是有**belief-navigation 新 bug 的味道**（例如反覆逃同一格、逃向明顯過期的 belief 位置、thrash 模式）？

**不要求全套 16 隊逐隊讀**——3-5 隻代表性抽樣，重點看「逃跑行為本身合不合理」，比對照過往 slice（F 等）的逃跑 coherent 判準即可（今天已經建立過這個判法：flee_from 真座標+持續遠離=coherent；flee_from 凍結/對空氣逃=broken）。

## 下一站
你抽完回我 → 若 coherent，我 release-pass Slice E（doom-delta 接受，機制正確值得這個代價）；若抓到新 broken signature，轉 systems 查。

## 溯源
`2026-07-19-measurer-to-blueprint-godview-E.md`（量測，已 consumed）；今天 flee-coherence 判準（team53/66 vs team75/58 的判法，slice2/godview-F 故事稽核前例）。
