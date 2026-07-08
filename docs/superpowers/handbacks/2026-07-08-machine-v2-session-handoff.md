---
from: blueprint
to: blueprint
status: open
topic: machine v2 建完(批次1.5/1.6/2+操作修)——A2a 正跑 v2 首次真跑;壓縮後從盯 A2a 續
---

# 交接：machine v2 + A2a 首跑（2026-07-08）

## ★立刻要做：盯 A2a v2 首跑
- **A2a 正在跑 v2 全流程**（--local detached，worktree `.worktrees/machine-A2a`）。
- 位置：`systems_spec`(opus 寫 spec) 進行中（factcheck haiku $0.28 clean 過了）。花費累計 ~$6.6。
- **watch 背景跑著**（`python run.py --slice A2a --watch`）——到 **①bp_review 有 concern / ②qa_review merge前 / halt / 完成** 會叫醒藍圖。
- 看進度：`! python tools/orchestrator/run.py --status`（顯最後站 + 路線圖；A2a log buffered 故路線圖不準,看「最後站」）。
- **到 ①**：藍圖讀 concern → 怪才轉告用戶。**到 ②**：報 QA 數字+帳單 → 用戶 approve/reject。
- **A2a 目的**：驗 v2 全流程(①我審/session-resume/量測員/haiku)真動沒 + 看真 token 分佈(vs A1a $27)。

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
