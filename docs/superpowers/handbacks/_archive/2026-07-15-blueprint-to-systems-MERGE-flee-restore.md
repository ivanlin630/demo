---
from: blueprint
to: systems
status: consumed
topic: [★批准 MERGE] flee恢復位移——QA churn消(3080→162筆)+全生命連貫→merge;精確log(cascade N1_flee/defect假警報+god-view連動+de-patch序1+RNG序改注記);backlog person-reaction/unified-solo tap/盲點閘
---

# ★批准 merge：flee 恢復位移（live 觀察後第一個真修）

QA 獨立複判:**churn 消**（逃跑最長 run 3080筆/128天→162筆/6.75天,有限會解除）+ **Team1 全生命連貫**（前段戰損好戲 + 後段獨存者真移動覓食/雙鄰邦外交 juggling/會解除逃跑,無新 churn）。flee真逃（396次移動）、aggregate 大降、憲法綠。**我批准 merge。**

## ★merge log 必含（精確、誠實）
1. **已修（de-patch）**：FLEE 恢復位移——序1 wave 誤刪 `_flee_target`+留假註解「mover 接手」（mover 不算）＝dead-code 病。修＝FLEE dispatch 算遠離 threat belief 位的可達 move_target（讀 belief 非活值，守感知鐵律）→ 隊真逃遠→threat out-of-vision→自然 release。**修假註解。**
2. **★cascade（一根解兩假警報）**：N1_flee -52%/-18%、**defect_leave -79%/-93%**（`defect_leave` probe key 被 flee-離隊+defect-離隊共用,flee-churn 反覆觸發灌虛高）、riot -47%/-13%。**「逃跑巨量」「內政 defect 千級」兩 aggregate 異常大半是此一 flee-churn 虛高,非「情緒太高/loyalty 太弱」。**
3. **★god-view 連動**：flee 讀 threat belief 反向位移 + god-view 位置 belief 化 = **完整逃脫迴路**（逃者真移動→god-view 讓追兵 belief 過期→撲空→真逃脫 organic 湧現）。**flee-restore 解鎖 god-view 逃脫在真實遊玩發生**（先前逃者不動→god-view 逃脫 organic 發生不了）。
4. **★RNG 序改注記（QA 要求）**：flee fix 改下游 RNG 消耗序列 → 新舊 specimen **非同一次模擬直接對照**,別逐筆比對誤會成不同 bug。
5. **窗口懸空非 bug**：Team1 結尾 day180 仍逃跑=量測窗切在未解段（同 Team26 死 specimen 懸空）。

## backlog（觀測完整性 + 內政殘留，非本 merge blocker）
- **person-reaction tap**（reaction_system,在補）：判內政殘留 defect 768/70 真因（低急,已非千級）。
- **tracer unified/solo commit-result**（`:1537`/`:1876` 預設 committed 虛高）→ 補真實 result。
- **★觀測盲點閘系統性掃**（你草擬中）：tap-gap 家族已 4 個,別打地鼠,一次掃全決策/事件路徑。
- N1_flee 兩 seed 降幅不對稱(52/18%)=世界差異非 bug,不追。
- **process 通則**（measurer 撞的坑,你記流程 doc）：worktree 是獨立 checkout,看不到 main dir 未 commit 的 debug 工具擴充→跑 worktree 前先確認工具同步。

## determinism
implementer TDD 自報 bit-identical,未獨立複驗（小 code 面,我接受自報;你要 measurer 補可另排）。

## 下一站
系統：merge flee-restore（精確 log 上5點）→ progress.md → `to:implementer [DONE]`。
→ live 觀察循環續:person-reaction tap→內政殘留判 / 經濟維(食物流通,還沒展開) / 觀測盲點閘。有真設計問題(如內政殘留真是 loyalty bug)升我。
