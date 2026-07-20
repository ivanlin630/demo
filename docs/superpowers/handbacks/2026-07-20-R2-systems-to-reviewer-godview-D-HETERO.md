---
from: systems
to: reviewer
status: open
topic: "[★異質 R²·god-view Slice D·核心威脅信號+measure 敏感·框外挑框] god-view arc 最大塊,升異質框外審(大結構改 path_system 3 func+11 caller、動核心威脅信號 threat_assessment:27、measure 敏感=動全盤 threat/combat/flee 行為、難逆)。★請用不同模型/代 + refute prompt。spec=2026-07-20-godview-slice-D-pathsystem-freshness-gate.md。診斷:path_system observe_velocity:175/estimate_catch_up:202/predict_intercept:241 讀 target live 位,11 caller(finder 族+threat_assessment:27)trusted=true 跳 discovery=live god-view leak。修=centralized freshness-gate(鏡射 _refresh_attack_pursuit:269 三態:本tick可見→live/斷視線→belief last-seen/過期→不可見),移 trusted=true。★refute 標的:①centralized(path_system 內建 gate)vs per-caller 哪個對(11 caller 有無特例需 live,如同-faction 協調 tally)②三態鏡射 _refresh_attack_pursuit 是否漏態(它是 attack pursuit,threat_assessment 語意同嗎)③measure 敏感=改 threat 距離會不會 coherent-vs-broken 難切(承 Slice E null-belief 混入教訓)④不可見 fallback(caller 既有 0/skip 路)夠不夠 or 有 caller 沒處理不可見會崩⑤determinism(freshness-gate 讀 belief last_tick 無 RNG)。off main HEAD。CLEAN→dispatch+before/after measure。"
---

# ★異質 R²：god-view Slice D（核心威脅信號 + measure 敏感）

god-view arc **最大塊**，框外挑框三對齊（大結構改 path_system core + 動核心威脅信號 + measure 敏感動全盤 + 難逆）→ 升**異質框外審**。

## ★★請異質模型/代 + refute prompt（非 confirm）
spec：`docs/superpowers/specs/2026-07-20-godview-slice-D-pathsystem-freshness-gate.md`。

## 診斷（請 refute）
`path_system` observe_velocity:175/estimate_catch_up:202/predict_intercept:241 讀 target **live 位**，11 caller（finder 族 `faction_ai:201/289/1364/2087/3537/3566/3596/3645/3677` + `threat_assessment:27` 核心威脅信號）`trusted=true` 跳 discovery = live god-view leak。

## 修（centralized freshness-gate）
三 func 內建 freshness-gate（鏡射 `_refresh_attack_pursuit:269` 三態：本 tick 可見→live / 斷視線→belief last-seen / 過期→不可見），移 `trusted=true`。

## ★refute 標的
1. **centralized vs per-caller**：path_system 內建 gate（DRY）vs 逐 caller gate——11 caller 有無**特例需 live**（同-faction 協調 tally、或某 finder 本該全知）？centralized 會不會誤 gate 掉合法 live？
2. **三態鏡射漏態?**：`_refresh_attack_pursuit` 是 attack pursuit 語意；threat_assessment（_approach_score 算威脅）語意同嗎——threat 該不該「斷視線用 last-seen 算威脅」還是「斷視線威脅歸零」？兩者語意可能不同，鏡射會不會錯配。
3. **measure 敏感 coherent-vs-broken 難切**：改 threat 距離動全盤——doom-delta 升的隊怎麼確定 intended（脫視野甩追）vs bug（Slice E 那種 null-belief 混入 pre-existing 又被暴露）？measure 協議夠不夠切乾淨？
4. **不可見 fallback 夠?**：caller 既有「不可見→0/skip」路（如 `_approach_score:29`）夠不夠？有沒有 caller 沒處理「不可見」回值會崩/誤判？
5. **determinism/RNG**：freshness-gate 讀 belief last_tick 無 RNG（觀測/決策鐵律）。

## 回覆
`to:systems`：CLEAN / blocking(file:line+refute)。`premise_contradiction`→halt。CLEAN → dispatch + before/after measure（不盲改）。
