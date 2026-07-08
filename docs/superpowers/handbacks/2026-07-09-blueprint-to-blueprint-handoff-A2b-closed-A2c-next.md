---
from: blueprint
to: blueprint
status: open
topic: 交接——A2b 收官(QA GREEN+用戶收)+measurer 流程規則已送 systems；下一步 A2c 設計
---

# 交接（2026-07-09，重啟前）

## 開場 3 件
1. `arm 信箱待命`（Monitor blueprint mailbox）。
2. 確認狀態列 `[藍圖 WHAT]`。
3. 讀本信 → 消費(status: consumed)。

## ✅ A2b 收官（用戶已定「QA 判決不變、就這樣」）
- leader 隊戰術執行納統一引擎（A2「手不聽腦」最後一塊）。四裁示全落地（#1 征服競秤湧現/#2 軟黏+cadence 1天/#4 intent 走既有 `intent_fit`/最小純路由零 term patch）。
- **QA RELEASE GREEN 合法**（批一真數字）：守衛 A=leader_attack **109**(征服稀有非零✓)、B=remote_tribute_settle **2**(遠距貢賦流動✓)。probe A/B 留常駐迴歸斷言。
- **constitution_gate pre-existing bug**（measurer 第二輪撞）= **非 A2b 引入**(main 自身也犯)→ 歸 `known_issues`、**不扣 A2b merge**。已發 `blueprint-to-systems-A2b-preexisting-not-guilty.md`(consumed)。
- **狀態**：願景放行在案 + QA 綠 + 用戶收 → 交**系統 merge-gate**(憲法/融合驗)入 main。**下個 session 追:A2b 是否已 merge origin/main**（若未,催系統跑 merge-gate）。

## ✅ 本 session 定的工作流規則（已送,待系統寫 doc）
- **measurer 一次量完才寄一封完整信,禁分批/append**（用戶定）。根因=信箱競態:批一 consumed 後批二 append→收件方不再掃→晚到數據靜默丟→險不完整驗證 merge。
- 通則:**禁 append 到 consumed 信,修訂走新 open 信**。
- 已發 `blueprint-to-systems-measurer-single-complete-letter.md`(**open,待 systems 寫進 `03b_measurer.md`/`07`**)。已入 memory [[feedback_mailbox_trigger]]。
- apply 下個 slice(A2c 起)；A2b 不溯改。

## ★下一步:A2c（5 平行權威折入）
- reverse-findings:faction「leader 零引擎+5 平行權威+優先權倒置」。A2b 收 leader intent；A2c 折其餘(外交/戰略…)。定義見 memory [[project_reverse_engineering_arc]] + `specs/2026-07-07-reverse-findings.md` line 37。
- **藍圖邊界**(00_roles):「哪些併秤/哪些降輸入/序」= seam = 系統的。藍圖只給願景約束:**任一權威折入若改玩家體感/平衡意圖 → 鎖 spec 前呈報要 sign-off**；純內部路由系統自決。
- 流程:blueprint 寫方向 → systems spec → reviewer 審 → 回 blueprint（信箱）。下游(impl→measure→qa)用戶偏好試 LG `--from-impl`(見 memory)。

## 環境/待追
- 主目錄 = main。**★鐵律:別在主目錄 checkout feat**（共用工作樹會換掉所有 session branch,commit 落錯支;血教訓見 memory）。要 branch code → `git worktree add`。
- git index.lock 偶發(多終端並發 commit)→ 重試迴圈,別刪 lock。
- ctx 汙染三角(零鍵入/warm-redo/零汙染 三選二):現狀 warm+auto-compact 封頂,先觀察真串味再換。
