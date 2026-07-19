---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict·異質(Sonnet)] threat-oracle S3 REVISED（surgical 切割）：CLEAN。4 審問逐項核實——release scaffolding 確 serves 全隊、無第三遺漏scaffolding（_wire_threat_task 早有 _decide_unified 呼叫點:1586 不受影響）、self-replace 擴 PRIO_THREAT 對 uprising 無副作用（source白名單擋住）。1 個非阻斷 measure 建議（preempt後選中結果分佈）。CLEAN→dispatch S3 impl。"
---

# R② 判決：threat-oracle S3 REVISED（surgical 切割）— CLEAN

## 4 審問逐項核實

**① release scaffolding 抽出後真 serves 全隊（含收斂後 unified threat task）否？**
核實通過。`faction_ai_system.gd:373-379` 的 release 監控（`if team.current_task in [TASK_DEFEND,TASK_PREPARE,TASK_FLEE,TASK_HOLD]:` → 威脅消失/FLEE-timeout→release）**函式邏輯本身不依 `uses_unified(team)` 分流**——分流判斷只出現在下面 `:387-390` 的「IDLE 分支」（避免 unified 隊 idle threat 雙觸發），release 監控段沒有這道閘，對任何隊一視同仁。抽成獨立 scaffolding 函式後語意不變，確認 serves 全隊。

**② preempt trigger 保後，busy 隊強威脅 re-rank via unified 真等價原 preempt→rank_threat 語意否？**
**部分等價，行為有變但屬設計意圖內，非新缺陷**。原本 `rank_threat` filtered-hard 保證「preempt 觸發必出 4 個 threat option 之一」；改走 `_decide_unified`(rank_scored 全 pool) 後，若 severity 不夠高、某非-threat 選項 util 更高，busy 隊被打斷重評後**可能選中非-threat 選項**（PRIO_DISPATCH 50，不一定壓得過原 task 的 priority，可能 commit 失敗、也可能成功換成別的日常任務）。這正是 S2「threat 選項全 pool 公平競秤，非恆勝」的設計本意延伸到 preempt 場景的自然結果，不是 S3 本身引入的獨立問題——若要求「preempt 觸發必產生 threat 反應」，那其實是把 filtered-hard 語意走後門留下來，跟整個 arc 的收斂目標矛盾。**不阻塞，但建議 measure 補一條**：驗證「preempt 觸發後最終選擇的分佈」（多數場景仍選 threat 反應、少數 severity 較低場景改選日常任務屬預期內，非 bug），避免這個行為差異被誤判成回歸。

**③ task_arbiter self-replace 擴 PRIO_THREAT 有無副作用（其他 PRIO_THREAT source 會不會誤 self-replace）？**
核實無副作用。逐 code 查 `PRIO_THREAT` 現有 commit 點：除即將 RETIRE 的 `:401`（`_evaluate_threat`，source="threat"）外，唯二其他呼叫點是起義 uprising（`:3693-3694`/`:3697-3698`），**source 字串="uprising"，不在 `ENGINE_SOURCES=["unified","solo"]` 白名單內**。self-replace 快捷路徑除了 priority 相等，仍受 `_source in ENGINE_SOURCES` 這道既有閘擋著（`task_arbiter.gd:58`）——擴充 self-replace 認 `PRIO_THREAT` 後，uprising 的兩處 commit **依然只能走一般晉升規則（priority 嚴格大於）**，不會被新擴充的 self-replace 分支誤放行，行為與現況完全一致。

**④ 有無第三個隨函式退役會靜默丟的 scaffolding？**
核實無遺漏。`_wire_threat_task`（`:411-414`，threat option 的 aux target 接線：DEFEND=prosperity_target、求和=order_target+order_task）本身是**獨立函式**，不在 `:385-407` RETIRE 範圍內。逐 grep 全部呼叫點：`:402`（`_evaluate_threat` 內，隨 :385-407 一起 RETIRE）、`:1586`（**`_decide_unified` 內，已存在**）、`:1774`（子隊）、`:1905`（solo）。`_decide_unified` **早就有自己的 `_wire_threat_task` 呼叫點**（非本次新增，DRY 共用設計本就如此），RETIRE 掉 `_evaluate_threat` 內那份不影響 `_decide_unified` 這份。確認無第三個遺漏 scaffolding。

（附帶一提，`:3384` 附近有註記「S-A C2：整併 survival-class 需 order_target（此 survival 路無 `_wire_threat_task`→真缺口）」——這是**既存、跟本次 S3 改動無關**的舊 debt 標記，非本輪引入，不歸此判決範圍，附註供 systems 知悉即可。）

## 判準結果
**CLEAN → dispatch S3 impl**。四個審問皆核實：①③④ 完全通過（無副作用、無遺漏）；② 有預期內的行為差異（非缺陷），建議補一條 measure 驗收條件（preempt 後選中結果分佈，含「非-threat 選項偶爾勝出屬預期」的說明），不擋開工。

measure 清單維持 spec 原案（threat 率保+preempt 保+release 不卡死+PRIO 黏性+gate 減），加審問②建議的一條即完整。

## 溯源
Spec `docs/superpowers/specs/2026-07-17-threat-oracle-severity-convergence.md` §S3（surgical 切割版）；systems handback `2026-07-17-R2-systems-to-reviewer-threat-oracle-S3-revised.md`；`faction_ai_system.gd:364-414`（`_evaluate_threat`+`_wire_threat_task`）/`:1586`（`_decide_unified` 既有呼叫點）/`:3680-3704`（uprising commit）；`task_arbiter.gd:35-86`；先前本 reviewer threat-oracle 三輪判決（v1 HALT/REVISED CLEAN/S3 HALT）。
