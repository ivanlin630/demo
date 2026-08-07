---
from: reviewer
to: systems
status: consumed
topic: "[R②結構審判決=CLEAN(F2教訓確認守住)+1輕量觀察非阻塞] F3 subteam-messenger 3 utils→SubteamSystem——①反向耦合:親讀3函式完整body(faction_ai_system.gd:1316-1434)確認_founding_timeout純算術(MovementSystem.BASE_MOVE_TICKS+自身const)、_equip_envoy_mounts只呼ResourceBank.add、_recall_envoy只呼TaskArbiter.release+state.detach_subteam+state.remove_tag,零一處呼faction_ai-only helper,零反向耦合;②caller exhaustive:親grep全faction_ai_system.gd逐一點名核對_founding_timeout 7處(:1210/1333/1909/2048/2073/5143/5237)+_equip_envoy_mounts 4處(:1351/2075/5145/5239)+_recall_envoy 7處(:1400/1406/1411/1590/1594/1597/1629)=18對得上spec聲稱且全落faction_ai_system.gd內;★親自對scripts/debug/*.gd重掃這3函式名=零命中,確認F2那輪caller清單漏debug/test的教訓這輪真的守住(spec自己§1也明講這輪掃=零,非我獨立驗證後才發現漏);③純code-move零邏輯改坐實,body無隱藏分支;④(輕量觀察非阻塞)taskarbiter site這條spec表述不精準——親讀constitution_gate.gd:30確認TASKARBITER_RE只鎖`TaskArbiter\\.(transition|try_set)\\(`,baseline檔:5自己明文『本閘只鎖TaskArbiter.transition/try_set呼叫面』,`_recall_envoy`裡呼的是`TaskArbiter.release(`——根本不在這個閘的抓取範圍內,親grep baseline.txt找`_recall_envoy`零命中,代表這裡實際上沒有任何baseline指紋需要『路徑更新』,比spec自己講的還要更無風險(不是要更新路徑,是本來就沒被抓,搬移零影響),非阻塞、系統下次可省這句話;判決=CLEAN(非F2那種必查項等級,①②③皆坐實乾淨、④只是spec自己一句多慮的描述不精準,不影響任何實際行為/驗證路徑)→鎖→build(F0 fp byte-identical驗)→QA→merge"
---

# R②判決：F3 subteam-messenger 3 utils→SubteamSystem HOW — CLEAN

## ①邊界乾淨否（反向耦合）— 坐實
親讀 3 函式完整 body（`faction_ai_system.gd:1316-1434`）：
- `_founding_timeout`（:1316-1318）：純算術，只用 `MovementSystem.BASE_MOVE_TICKS` + 自身兩個 const（`FOUNDING_TIMEOUT_MULT`/`FOUNDING_TIMEOUT_FLOOR_DAYS`）。
- `_equip_envoy_mounts`（:1385-1395）：只呼 `ResourceBank.add`。
- `_recall_envoy`（:1426-1434）：只呼 `TaskArbiter.release`、`state.detach_subteam`、`state.remove_tag`。

**零一處**呼叫任何 faction_ai-only helper。零反向耦合，跟 spec §1 自檢一致。

## ②caller exhaustive 無漏 — 坐實 + 親驗 F2 教訓真的守住
親 grep 全 `faction_ai_system.gd` 逐一點名核對，跟 spec 聲稱的計數逐字對得上：
- `_founding_timeout` 7 處：`:1210/1333/1909/2048/2073/5143/5237`
- `_equip_envoy_mounts` 4 處：`:1351/2075/5145/5239`
- `_recall_envoy` 7 處：`:1400/1406/1411/1590/1594/1597/1629`

合計 18，全落在 `faction_ai_system.gd` 內部，跟 spec §1「caller 全 faction_ai 內」一致。

★**親自對 `scripts/debug/*.gd` 重新掃這 3 個函式名**——零命中。上輪 F2 treasury 那份我抓到 spec 漏列 debug/test 直接 caller（`headless_test.gd:8521` 那個坑），這輪 spec §1 自己就講「本輪掃=零」——我沒有照抄 spec 的話，是自己重新跑一次同款 grep 獨立確認，結果一致：這輪真的沒有漏，F2 那次的教訓這次真守住了。

## ③純 code-move 零邏輯改 — 坐實
body 讀完無隱藏分支/邏輯，逐字搬移可行。

## ④（輕量觀察，非阻塞）taskarbiter site 這句表述不精準
spec §3 講「taskarbiter site 隨 `_recall_envoy` 移=同語意、baseline 路徑 faction_ai→SubteamSystem 更新非新增」——親讀 `constitution_gate.gd:30` 確認 `TASKARBITER_RE := "TaskArbiter\.(transition|try_set)\("`，且 `constitution_baseline.txt:5` 自己明文寫「本閘只鎖 TaskArbiter.transition/try_set 呼叫面」。`_recall_envoy` 裡呼的是 `TaskArbiter.release(`——**根本不在這個閘的抓取範圍內**。親 grep `constitution_baseline.txt` 找 `_recall_envoy`/這一帶行號零命中，證實這裡本來就沒有 baseline 指紋。

這不是問題，是比 spec 自己講的還要更無風險——不需要「路徑更新」，因為這裡從來沒被抓過，搬移對 constitution_gate 零影響。非阻塞，純粹提醒 systems 下次可以省略這句多慮的描述（或者如果之後真要擴大閘去蓋 `.release(`，那是另一個獨立的閘覆蓋範圍決策，不是這個 slice 該管的）。

## 判決
**CLEAN → 鎖 → build（F0 fp byte-identical 對 ce201650 27/27）→ QA → merge。** 不像 F2 treasury 那輪有必查項——①②③皆坐實乾淨，④只是 spec 自己一句對 constitution_gate 覆蓋範圍的多慮描述，不影響任何實際行為或驗證路徑，不需要 HOW 修正。
