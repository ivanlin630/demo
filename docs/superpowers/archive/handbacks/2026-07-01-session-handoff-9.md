# Session 交接（2026-07-01 #9，系統 session）

> 給重開後新 system session（`$env:SESSION_ROLE='systems'; claude`）。承 #8（`2026-06-23-session-handoff-8.md`）。
> 本 session = **他域鏈 P2a→P4 收尾 + commander-v2 統一統領 + 沙盒 bar/(a) 崛起 arc（食物統一/失能-capture/獨立戰略層）**。全 merged+review+回歸綠。

## 你是誰
系統(Systems, HOW)。owner = invariants.md / 流程docs / progress.md / known_issues.md / CLAUDE.md / docs/process/* / auto-memory(單寫者)。開頭讀 `docs/process/00_roles.md` + auto-memory(hook 注入) + 掃 `handbacks/` 的 `to: systems / status: open`。

## ⚠ 開頭必跑
merge 新 class_name 後快取 stale → `.\tools\godot.ps1 --headless --import` + 一次 headless 確認合體綠。**重型 seed（warring/climb/rung/food_ledger diagnose）用 `GODOT_TIMEOUT=2000~3000`（bash env prefix，別 PowerShell `$env:` 內嵌會被吃）+ run_in_background（跑 5-50min）。**

## 本 session 主線（全 merged + review + 回歸綠 + coin_eq/InvariantAudit 0）

### 他域鏈 P2a-P4（承 #8 P0/P1）
- **P2a 絕境 option**（投靠/紮營/乞食，閉標記1 join 債）、**P2b-1 survival 選擇統一**（non-unified `_trigger_survival` 委派 `rank_survival`，消雙 owner）、**P3 混合協調**（faction_duty term + 攻擊 option + 脫軌逃閥）、**P4 徵收/外交**（faction_stakes 泛化）。**war-priority 補丁**(P4)後被 commander-v2 revert。

### commander-v2 統一統領決策（統一決策 arc 真根最後一處）
`_update_goals` 多閾值並行→**means-end 意圖驅動**（意圖 predicate→子需求現算→真 affordance 匹配→每令帶 driver）。**北極星不變量「凡 named 意圖必有可解釋驅動」**納 invariants。裁 A（只真 affordance，欺敵/貿易戰=孤兒→anchored-pre-player）。單姿態方向作廢一輪（教訓 [[feedback_no_patch_on_settled_architecture]]）。

### 沙盒 bar / (a) 崛起 arc（★本 session 大戲，連串 measure→fix）
用戶升尺：**世界無玩家也要好玩（沙盒自己說故事）**（memory `project_playable_priority` 已升）。戰國 seed 揭 default 龜縮（CONQUER=0/established 卡1）。**measure-first 逐層挖（別猜，用戶多次戒 guessing）**：
- 能人 pop 崩 = **飢餓非戰敗**（我一度錯猜「戰鬥輸家」被用戶戳，改 measure）。
- **戰鬥不決勝**（0 擊潰，撤退先於殲滅）→ **失能-capture ✅**（潰逃俘 wounded→captive，capture 0→5/assimilate 0→2）。
- **食物模型沒統一**（成長讀私產 silo）→ **統一食物 ✅**（成長讀 effective_food coherent，forest 6→12）。藍圖 🟡 讀 A（能累積）收下/讀 B（特化交易環）=下一經濟 arc。
- **rung2→3 卡 = 能人是獨立隊**（無自建派系 intent）→ **獨立戰略層 ✅**（統一決策 arc 第三塊：野心獨立隊建國 means-end，複用 create_faction）。**S3 回歸主 session 抓修**（子 session 誤稱 pre-existing；獨立戰略 defer prosperity 候選保 scout gate）。
- **(a) 機制鏈完成（累積/捕俘/founding/征服 三源全活）**；**⚠ 活世界大規模 emergence（established 多/CONQUER 明顯）未在混亂 warring seed 顯現＝平衡層 confound（attrition 熔爐），非機制缺**。

## 3+1 對稱不變量骨架（納 invariants.md）
```
凡 named 意圖  必有可解釋驅動   ← 決策域  ✓ commander-v2 enforce
凡 belief     必有 provenance   ← 信息域  G3 待 enforce
凡 state 變化  必有單寫者/driver ← 所有權域 Pattern B 待 driver-ledger
凡位置        必有可解釋上位路徑 ← 選擇/階級域 獨立戰略層 ✓（起始劇本豁免）
```

## ⏸ 待藍圖（open handbacks，非阻塞）
- **`indep-layer-done-a-mechanism-complete`（本 session 最後）**：(a) 收尾驗收（機制就位 vs 活世界大規模 emergence）+ 下一向（讀 B / G3 / (a) 平衡 tune）。
- 早前 open：G3 Phase E plan（spec 已交 `2026-06-29-g3-info-warfare-unified`，Phase E/D 核心/P 降 optional）。

## 剩餘 queue（藍圖排序後）
- **讀 B 經濟 arc**：覓食=苟活地板、繁榮須交易（forest 賣木買糧；接「覓食限 pop≤15」延伸，非 nerf 補丁）。
- **G3 Phase E**（信息域 keystone，provenance enforce：god-view 2 漏補 + 審計閘 + 背叛 belief 化）→ D（欺敵 primitive，anchored-pre-player 玩家面前必落地）→ P（玩家鏡頭，降 optional）。
- **(a) 活世界 emergence 平衡**（attrition vs founding/established rate tune）＝若藍圖要大規模征服湧現。
- **Pattern B driver-ledger**（第三不變量 enforce）+ **StressBank**（第 6 池）。
- **prisoner_population→captive 存儲統一**（Phase 2）、**named 俘虜戲**（受控人力 Phase 2）、**宣告 solo founding**、**P2b-2 全退 survival entry**（耦合 P3/P4）。

## 工作流教訓（本 session）
- **measure-first 逐層挖，別猜**（用戶多次戒；我錯猜「戰鬥輸家」被戳→養成「先 grep 既有 print / instrument 量 → 再下結論」）。[[feedback_avoid_rabbithole]]
- **子 session 誠實但會漏/誤判**：S3 回歸子 session 誤稱 pre-existing → 主 session **對自己早先 known-good（PASS=7）驗** 抓出。review 必對基準驗，別信子 session 自評。[[feedback_verify_backlog_fresh]]
- **統一非補丁**（藍圖鐵律 + [[feedback_no_patch_on_settled_architecture]]）：食物/獨立戰略都走「延伸統一架構」非局部特例。矛盾補丁=紅旗。
- **重型 seed 驗證床有天花板**（混亂 warring 噪音 confound 大規模 emergence）→ 機制驗走 unit/deterministic/乾淨 bed；活世界大規模看趨勢非絕對。
- subagent worktree：完成明確 branch 名 push（別留 auto-name）；卡重型 seed 沒 push 時，work 在 local worktree（`git worktree list`）可自 merge。
