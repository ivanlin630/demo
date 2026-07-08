---
from: blueprint
to: blueprint
status: open
topic: machine v2 建完(批次1.5/1.6/2+操作修)——A2a 正跑 v2 首次真跑;壓縮後從盯 A2a 續
---

# 交接：machine v2 + A2a 首跑（2026-07-08）

## ★立刻要做：A2a 停在 review(有真發現)——處理 review 的 2 個盲點再重跑
**A2a v2 首跑結果**（--local，worktree `.worktrees/machine-A2a`，已結束非在跑）：
- 跑了 factcheck(haiku,clean,$0.28)→systems_spec(opus,$3.51,spec commit 9e84c14)→**review(sonnet,issues,$1.75)**→halt。**共 ~$5.5，遠低於 A1a 同段。**
- **review(sonnet)抓到真深盲點(halt)**：spec 設計方向健全,但①宣稱的 commitment 防抖若真鏡射 rank_ambient 就不存在 ②子集內攻擊 option applicable 閘比舊手寫嚴,**子隊攻擊觸發率可能塌陷,驗收法沒量這個**。→ **sonnet review 有價值、tiering work。**
- **但 run_local 曾崩**(interrupt chunk tuple 當 dict)——**已修 committed**。
**下一步**：藍圖裁 review 發現→修 A2a spec/工單(補 commitment 機制講清 + 加子隊攻擊觸發率驗收)→重跑。或先問用戶要不要照 review 改。**這是 halt=藍圖判的檢查點。**

## v2 首跑驗到的（正面）
- haiku factcheck 能做(變異;重試已加)、sonnet review 夠利抓深 bug、opus spec 正常、成本大降(~$5.5 vs A1a $27)。
- 崩點=run_local 沒處理 interrupt(修了);session-resume/量測員/①bp_review 還沒走到(review 就 halt 了)。

## machine v2 全貌（全 committed；設計 `docs/process/08_machine_workflow_v2.md`）
流程：`factcheck→systems_spec→review(02②)→①bp_review(00審)→systems_plan→implementer→measure→qa→②qa_review→merge`；退回→halt。
- **批次1.5**：spec/plan節點拆(fail-early)+rn_bp_review(①,concern才interrupt)+MODELS成本分層(判斷=haiku/sonnet,寫作+願景=opus)+scope限讀(讀touch_files+callers/callees,不確定就讀)。
- **批次1.6**：session-resume(systems_spec→plan --resume同session免重讀;跨角色斷)。
- **批次2**：`--decompose`(01拆feature→子片brief+A.decompose.json並行圖)+`--fan-out`(發第一並行組);⓪藍圖審=看--decompose輸出好才--fan-out。
- **操作修**：judge effect-fail重試一次(transient)、--cancel可靠殺worker、fire防呆(不double-fire)、PYTHONUNBUFFERED(log即時)、--status路線圖。

## 本 session 關鍵發現/教訓
- **haiku 能做 factcheck**(用戶戳:1失敗樣本判死太急;重測 17turns/$0.13 判得好)。變異非無能→加 effect-fail 重試一次(執行重試,非裁1判斷不重試)。
- **double-fire 撞車**：--cancel 沒殺 detached worker→殘留→兩 worker 踩同 worktree/sqlite/log(log 空)。修了。
- **scope 限讀怕漏**：改「touch_files+直接互動面(callers/callees)+不確定就讀」;兩層兜底=02②讀廣+量測員跑全sim。
- **--local vs --server**：local(預設,穩,VS Code關也活,只文字status)/server(Studio路線圖但server死=in-memory丟)。想看圖 fire 加 --server。

## 待接（A2a 跑完後）
1. **量 A2a v2 token 分佈**：session-resume省了沒?haiku穩不穩?01還是不是成本大戶?有數據才決定要不要用戶的「01 handoff(decompose→子片架構交接+寫回progress)」優化。
2. A2a merge 後：續 A2b(leader入引擎) 或用 --decompose 拆大 feature 試分解階段。
3. 殘留 worktree 鎖(A2a舊的)偶爾要 reboot 清;--cancel 已改可靠。
4. A1a 已 merged+驗(arbiter_latch 30.1%→0.1%);單點 probe 已 merged。

## 全 durable
記憶 `project_orchestrator_machine.md`(單寫者藍圖);設計 08 doc;A2a工單 `briefs/A2a.md`(已補回歸-capture特判)。壓縮後讀這份+memory+08 doc 即接回。
