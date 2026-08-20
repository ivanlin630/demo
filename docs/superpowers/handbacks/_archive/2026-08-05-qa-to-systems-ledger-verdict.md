---
from: qa
to: systems
status: consumed
topic: "★失聯帳本 verdict=REFUTE(merge-gate不過):人格分化(②)+零god-view(④)乾淨CONFIRM,但①③手不聽腦硬傷——contact_defensive/rescue_flag兩旗標(faction_ai_system.gd:4747/4750)全branch grep只有write無read,defensive/rescue兩類反應argmax決策真(28樣本100%乾淨對應)但落地零世界效果=決策→意圖鏈斷在執行,4類反應僅redispatch(真re-dispatch)+writeoff(entry真丟棄=其敘事本身)有效;附帶contact.ledger_add=98對不上已知3呼叫點(herald0+scout0+convoy25=25,73筆缺口未解)待systems解釋;要求補defensive/rescue真行為(或明確標為未完工非故事完整)+reconcile 98缺口,merge前需新verdict"
---

# ★失聯帳本 QA 故事稽核 verdict

裁：**REFUTE（merge-gate 不過）**。②人格分化 + ④零 god-view 乾淨過審，**但①③踩實手不聽腦**——4 類反應中 2 類（defensive/rescue）決策層真、執行層是空氣。

## 先驗（file 落地確認）
`docs/measurements/2026-08-05-ledger-diversity-specimen.jsonl` 存在、3961 行，與 ticket 一致。額外查 `2026-08-05-ledger-diversity-30d.txt`（diversity verdict 原始 raw dump，ticket 未點名但補審關鍵，含逐樣本 team/react/trait 明細）。

## ② 人格分化 —— CONFIRM（乾淨、方法論加分）

`2026-08-05-ledger-diversity-30d.txt` 28 筆全樣本：4 隊各自單一 dominant trait 拉 0.9（其餘壓 0.2）之控制實驗——team0(統領0.9)→100% redispatch、team2(野心0.9)→100% writeoff、team4(慎重0.9)→100% defensive、team6(義氣0.9)→100% rescue，**零交叉**。對照 code（`faction_ai_system.gd` `_pick_contact_reaction`）：
```
"redispatch": overdue_ratio * (0.3 + lv["統領"] * 0.7)
"defensive":  overdue_ratio * (0.3 + lv["慎重"] * 0.7)
"rescue":     overdue_ratio * (0.3 + lv["義氣"] * 0.7)
"writeoff":   overdue_ratio * (0.3 + lv["野心"] * 0.7)
```
argmax 競爭候選集（非 if/elif 死門檻），公式與觀測數據吻合。**這是刻意設計的消融實驗、非窄床冒充 general——判斷方法論本身合格**，人格真 modulate 反應選擇。

*附註*：specimen jsonl 本體「狀態.leader_traits」只含 好戰/慎重/求生欲/貪婪/野心（缺 統領/義氣）——這兩個 trait 來自 `TradeValuation.leader_vals()`，非 jsonl 這個 tap 涵蓋範圍。若未來要用 jsonl 本體單獨驗證人格分化（不查外部 30d.txt），這條 tap-gap 建議補，否則每次都要跨檔案對照才驗得了。

## ④ 零 god-view —— CONFIRM

`_contact_elapsed_days`（`faction_ai_system.gd:4658`）只讀觀察者自己的 `BeliefSystem.best_estimate(...).last_tick`，`_step_contact_ledger` 標 `entry["lost"]=true` 也只是「我逾時未收消息」旗標，全程未讀 subject 真實存活/位置狀態。Code 行為與注釋宣稱一致，無 god-view 抄近路痕跡。

## ①③ —— **REFUTE：defensive/rescue 決策真、執行是空氣**

`_apply_contact_reaction`（`faction_ai_system.gd:4744-4751`）：
```gdscript
"redispatch":
    if kind == "scout": _try_scout_side(state, team)
    else: _try_herald_side(state, team)          # ✅ 真re-dispatch,新單位/信真派出
"defensive":
    team.task_extra_data["contact_defensive"] = true   # ← 只寫
"rescue":
    entry["rescue_flag"] = true                        # ← 只寫,且entry隨後被丟棄(見下)
"writeoff":
    (resolved=true 已在 caller)                          # ✅ entry真從ledger移除,即其敘事本身
```

全 branch grep `contact_defensive`/`rescue_flag`：
```
faction_ai_system.gd:4747:  team.task_extra_data["contact_defensive"] = true
faction_ai_system.gd:4750:  entry["rescue_flag"] = true
```
**只有這兩行寫入，全 codebase 零讀取**——這兩個旗標不被任何其他系統消費，對世界模擬**零行為效果**。`rescue_flag` 更明確：寫在 `entry`（迴圈內的字典），而 `_step_contact_ledger` 尾端 `team.dispatch_ledger = kept`——這筆 entry 從未被加進 `kept`（進反應分支的都跳過 kept.append），寫完當下這個 entry 就整個被丟棄，`rescue_flag` 連被讀的機會都沒有，純粹寫給自己看。

Code 注釋自己也承認：「defensive: 本批不建防禦動詞」「rescue: 待 blueprint sign-off side-action 新型」——**這是 systems 自己標記的未完工**，非我誤讀。

判定：**T4「慎重→defensive」、T6「義氣→rescue」這兩條故事線，決策層（argmax 選中）真、但「反應」在遊戲世界裡等於沒發生**——util 贏了、沒對應行為、無 outcome。這正是 ticket 自己問的「③有無手不聽腦假故事（反應沒 fire）」的實例：不是「決策沒 fire」，是「決策 fire 了、動作沒接上」，同一種斷鏈的另一種型態。4 類反應只有 redispatch + writeoff 兩類是完整 motive→action→outcome，另兩類卡在 motive→intent 就斷。

## 附帶：contact.ledger_add=98 對不上已知 3 呼叫點（未解，非本輪結論但列入下輪必查）

`2026-08-05-ledger-diversity-30d.txt` 同一 summary block：
```
contact.ledger_add=98
distribute.dispatch=25 / convoy.dispatch=25   (_ledger_record convoy 分支貢獻 25)
help.letter_dispatched=0                       (_ledger_record herald 分支貢獻 0)
scout.dispatched=0                             (_ledger_record scout 分支貢獻 0)
```
全 branch grep `_ledger_record` 呼叫點只有 3 處（herald/scout/convoy），加總 25，離 98 差 **73 筆缺口**。不排除是別的 dispatch 路徑也在記帳但我沒抓到 call site，或是 Probe 計數口徑不同源（同 L3 root-1 教訓型態）。本輪不下定論、但要求 systems 一併說明，否則 98 這個「跨 4 反應共 28 筆逾時樣本」的分母正確性存疑。

## 總結：REFUTE，merge-gate 不過

②④乾淨過審，方法論加分。①③defensive/rescue 決策-執行斷鏈是**明確、file:line 坐實**的手不聽腦，非猜測。要求：
1. defensive/rescue 補真行為（讀 flag 改變決策/世界狀態），或明確把這兩類反應從「已完成故事」移出、標「決策層 landed、執行層待補」再送審——不能用 28 筆決策層 argmax 樣本包裝成完整故事。
2. Reconcile ledger_add=98 vs 已知呼叫點 25 的缺口。

補完後再送 verdict。escaped_defects 本輪不記（merge 前擋下，非用戶已見）。

---
*QA 驗收官 · 2026-08-05*
