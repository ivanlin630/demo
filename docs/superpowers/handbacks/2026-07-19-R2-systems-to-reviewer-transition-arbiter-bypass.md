---
from: systems
to: reviewer
status: consumed
topic: "[R² spec·transition-arbiter-bypass·arbiter 核心·HIGH] spec=2026-07-19-transition-arbiter-bypass.md。root(file:line 坐實):TaskArbiter.transition(task_arbiter:108-112)無條件 raw 覆寫,不檢查 combat/crisis-免疫/priority,13 caller 全繞過=手不聽腦後門。team16 血證(defection:3876 transition 等待新領主→clobber survival+繞免疫+重設 task_start_tick→crisis 永不 fire→凍死)。修=transition 加三 guard:①combat lock ②crisis-免疫 ③emergency-respect(task_priority≥PRIO_THREAT 活時低 prio 轉換 yield)。★關鍵審點:emergency guard 用 ≥PRIO_THREAT(70) 分界=保護 survival/threat/combat,放行合法降級轉換(安頓50→生產10,因 50<70)——逐 13 caller 驗這分界不打壞合法 in-place 轉換。team64/68 idle-latch 本 spec 不預設同根(另案)。off main 899865f6。CLEAN→dispatch。大框改控制流,你判要不要升異質框外審。"
---

# R² spec：transition-arbiter-bypass（arbiter 核心，HIGH）

spec：`docs/superpowers/specs/2026-07-19-transition-arbiter-bypass.md`。off main `899865f6`。

## root（file:line 坐實）
`TaskArbiter.transition`（`task_arbiter.gd:108-112`）無條件 raw 覆寫 current_task/priority/task_start_tick，**不檢查 combat lock / crisis-免疫 / 現任 priority**。13 caller 全繞過 = 手不聽腦後門。team16 血證：defection(`faction_ai:3876`) transition「等待新領主」@AMBIENT → clobber survival@80 + 繞免疫 + 重設 task_start_tick → `_famine_crisis`(3462) 恆重置 crisis 永不 fire → 凍死。

## 修：transition 加三 guard
①combat lock（同 try_set:40）②crisis-免疫（同 try_set:45-47）③**emergency-respect**：`task_priority >= PRIO_THREAT(70) 且 priority < task_priority → return`。

## ★R² 關鍵審點
1. **emergency guard 分界（≥PRIO_THREAT=70）不打壞合法轉換**：合法 in-place 轉換（安頓 DISPATCH(50)→生產 AMBIENT(10)）發生在 <THREAT 區 → guard 不擋（50<70）。**逐 13 caller 驗**（建設/生產/BUILD/beggar-restore/defection）guard 後仍達原意圖。**這是本修最大風險面**（收緊 transition 誤傷合法用途）→ 請重點 refute：有沒有哪個 caller 的合法轉換發生在「現任 ≥THREAT」情境會被誤擋？
2. **真根治非搬問題**：三 guard 是否真堵手不聽腦（team16 survival 留住），還是把問題推去別處（例：defection 被擋後 team 卡別的態）？
3. **crisis-免疫補齊**：transition 加免疫 guard 後，crisis-released task 的重鎖路（try_set + transition）是否都覆蓋（免疫不再有洩漏面）？
4. **不變量**：`emergency task 不被 in-place 轉換 stomp` 是否該進 invariants.md（我 spec 提了）。
5. **determinism/RNG**：guard 純讀 team 欄 + tick，無 RNG。

## 框外審（你判）
blueprint 標「大框改控制流」。三對齊檢查：強結論(改 arbiter 核心)+redirect(13 caller 面)+難逆(merge core)——**若你判夠格三對齊 → 升異質框外審**（別 Opus + refute prompt）。我傾向這是坐實 root 的收斂修（非新框），標準 R² 可能夠，但分界誤傷面值得一個 skeptic。你定。

## team64/68 out-of-scope
idle-latch(food-ok would_succeed=true)本 spec 不預設同 transition 根（QA/blueprint 提醒），落地後 measure 看是否一併解，沒解=另案。本 R² 不審 team64/68。

## 回覆
`to:systems`：CLEAN / blocking(file:line)。CLEAN → dispatch implementer（off 899865f6）。
