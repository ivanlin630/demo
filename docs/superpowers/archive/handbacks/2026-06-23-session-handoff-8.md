# Session 交接（2026-06-23 #8，系統 session）

> 給重開後新 system session（`$env:SESSION_ROLE='systems'; claude`）。承 #7（`2026-06-22-session-handoff-7.md`）。
> 本 session = **他域解鎖鏈啟動 + P0/P1 落地**。藍圖 otherdomain ruling 消費 → 定 HOW 序 P0-P5 → 完成 P0(礦村)+P1(掠奪)，兩者 merged+reviewed+文件齊。剩 P2-P5。

## 你是誰
系統(Systems, HOW)。owner = invariants.md / 流程docs / progress.md / known_issues.md / CLAUDE.md / docs/process/* / auto-memory(單寫者)。不碰 game-design.md(藍圖)。開頭讀 `docs/process/00_roles.md` + auto-memory(hook 注入) + 掃 `handbacks/` 的 `to: systems / status: open`。

## ⚠ 開頭必跑（承 #7 坑）
merge 新 class_name 到 main 後快取 stale → 跑 `.\tools\godot.ps1 --headless --import` + 一次 headless 確認合體綠。本 session P0/P1 無新 class_name，但習慣保留。

## 本 session 主線（全 merged + review + 回歸綠 + coin_eq/InvariantAudit 0）

### 他域 ruling 消費 + HOW 序定
藍圖裁 `2026-06-22-blueprint-to-systems-otherdomain-ruling.md`（**consumed**）：混合協調（stakes-to-faction→頂層 / 日常→個體）+ believability 守則 + 主動開戰稀有吃belief + mint 現在排 G1a。**HOW 序 P0-P5**（progress.md 當前狀態頂 + [[project_unified_decision_framework]]）：P0 mint→P1 個體 options→P2 survival 全隊退役→P3 混合協調 seam→P4 頂層 stakes options→P5 戰俘。

### P0 G1a 礦村（山村特化）✅ merge `61af5c4`
- **量測推翻 stale premise**（[[feedback_verify_backlog_fresh]]）：S5/W8「無金礦/鑄幣壞」與現碼矛盾。真根=金礦只在山地、山地住不了人(food 再生 0.5)、採礦需在地→**金礦物理不可開採**(雞生蛋)。
- **用戶裁模型 B 礦村**：蓋含礦山的不自給 civilian outpost，外部供糧（bootstrap 攜糧 + market food buy）。
- 複用既有(自格採 ore/mint facility/_pick_facility/food 買單/糧倉/subteam 建造)；新增礦脈保證 guard + 貪婪 leader 選 ore-mountain **本身**(threshold gate 保稀有) + 施工子隊韌性(survival/betrayal/tribute/encirclement/discipline/tag-shift 行為豁免，皆 10 日 CONSTRUCT timeout/build 完成/滅團兜底，**只豁免行為不碰死亡/守恆**)。
- **3 輪 review**(opus 終審 APPROVE)抓修：far-construction 雙計(LOD 前提錯→刪)、distance 免疫過廣、zombie latch、facility_deficit 洩漏、測試 pre-seed。
- 結果：default.json r8 自然 fire 4/5、world_sim 1/1、真鏈端到端證(ground ore→vault→mint→coin 無 pre-seed)、coin_eq 0、framework S1-S6 PASS。spec/plan `2026-06-23-g1a-mint-mining-village`、handback `2026-06-23-g1a-mint-mining-village`。

### P1 個體域 掠奪 option ✅ merge `483e039`
- unified 隊(merchant/produce)加人格加權 `掠奪` engine option：weight 殘忍×0.5+好戰×0.3+貪婪×0.2、loot_drive base 1.0(has_weak_prey)→loot util ≤~0.8(危時 survival_pressure ≥2 仍碾壓=餓隊先求生)。複用 `_find_weakest_prey`(belief-read)+TASK_LOOT+既有 loot/extort interaction(**小徵收隨 loot，不另做 option**)。`_decide_unified` 加 combat_target wire(`td.has` 守衛=零影響既有 option)。
- **scope 嚴**(防 P0 sprawl)：只掠奪、non-unified 零碰、無新 TASK_*、無 exemption 鏈。**偵查延 backlog**(下游消費存疑=避 dormant code [[project_framework_seams]])。
- headless 全綠(人格分歧+餓隊不日常掠奪驗)、coin_eq 0、framework S1-S6 PASS。**world_sim 該 run unified 隊沒 fire loot**(RNG 沒生殘忍商隊 leader)=機制 headless 證、rare tail + P2 基建，非 dormant。spec/plan/handback `2026-06-23-p1-individual-options`。**解鎖 P2 loot**。

## 剩餘 P2-P5（依序，spec 待開）

### P2 survival 全隊退役 + loot/join 還經濟隊（**下一塊，最高風險重構**）
- **目標**：退役舊雙 owner `_evaluate_survival`(faction_ai)，loot/join/camp/beg/hunt 遷成 engine option + **全隊化**(非只 unified)。閉框架完成塊③ + 經濟↔衝突橋(餓商隊打劫/敗商隊投靠=藍圖標記1債)。
- **依賴**：P1 loot option(done=已有 `掠奪`)。
- **現況**：unified 隊 survival 切片已 done(merge `b57c79c`，spec `2026-06-22-unified-survival-slice`，unified 隊跳舊 `_evaluate_survival`+survival-class term 量級支配)。P2 = 把 camp/beg/hunt/join 也變 engine option + 套用全隊 + 退役舊 `_evaluate_survival`(雙 owner 消)。
- **設計起點**(P1 探碼已部分映射，faction_ai_system.gd)：舊 `_evaluate_survival:~2087`/`_trigger_survival:~2219`(home 路徑 loot/return / 無家 desperation loot/join/camp + fallback hunt/forage/beg)；`_evaluate_solo:~1000` loot；既有 TASK_LOOT/JOIN/CAMP/BEG/FORAGE 全存在。各變 engine option(term=desperation×人格 pref，複用既有 _loot_pref/_find_strong_neighbor/_find_unowned_farmable_tile/try_hunt_predator)。
- **風險**：碰全隊求生=回歸面最大(飢荒/絕境/camp/beg/join 既有測必綠)；退役雙 owner 要確認無讀者遺漏(框架債縫，[[project_framework_seams]])。**measure-first + 切片邊界**(像 unified slice 那樣，逐步而非一次全退)。

### P3 混合協調 seam（重塊，WHAT-adjacent forks）
- `faction_duty` term(霸主 directive→成員協同；stakes 高權壓人格/日常弱 term)+霸主頂層決策步+believability 兩不變量寫 invariants.md(頂層決 WHETHER 人格染 HOW + 脫軌逃閥)。
- ruling §1/§2 全文在 consumed handback。設計時可能有 seam 細節 fork 需問用戶(導演)。

### P4 頂層 stakes options（架 P3 上）
- 主動開戰攻擊(稀有+蓄意+吃belief+readiness gate，霸主決策)→結盟/外交→立國深做→大徵收動員。**解鎖 TC3(feud→脫軌攻擊)+誘殺閉環**。ruling §3 feel 全文在 handback。

### P5 戰俘（耦合 combat-unification E-2）
- combat capture→戰俘處置。耦合 [[project_combat_unification]] E-2 撤退門檻/意志，跨 arc。

## backlog（known_issues，本 session 新增）
- **mint coin-cap 燒 ore off-ledger**(pre-existing，G1a 首 fire 才浮現)：coin vault 飽和時 ore 消耗但 coin clamp 截掉=coin_eq 損失。小修：coin 滿跳過/部分消耗 ore。
- 礦村稀有邊際(非貪婪 leader 無平原時仍可建)、dense map distance 免疫未測、default 自然 fire 4/5 unseeded。
- 偵查(scout) standalone option 延後(P1 deferred，待 P4 或實際需求)。

## standing flag（承 #7，非阻塞）
履約脫 0 unseeded(一 run=0..5)→ 經濟底 🟡 待 seeded harness 確認穩定成交。看機制指標(restock_chosen/engine_survival)非絕對閾 [[reference_multi_sanity_unseeded]]。

## 工作流提醒（本 session 教訓）
- **量測推翻 stale backlog premise**(P0)：挑 backlog 項先 grep 驗碼 + 跑量測，別 spec 在假前提([[feedback_verify_backlog_fresh]]+[[feedback_avoid_rabbithole]])。
- **subagent 會 sprawl**(P0 一塊 10 修)：spec 寫死非目標 + scope guard，dispatch 強調最小 + 不加 exemption 鏈；每塊 merge 前 opus 終審(尤其 foundational)。
- **subagent 會猜 root cause**(P0 LOD 理論錯)：dispatch 明文「別追 X 理論，先量證」。
- **用戶分不出技術選項時**用具體走查(一座礦怎麼出現 A/B/C)幫成形，別丟術語。
- subagent worktree：每 Godot/git 前 `Set-Location` 進 worktree(cwd 預設 main repo)。godot 走 `.\tools\godot.ps1`(PowerShell，pwsh 不在 bash PATH)。
- 流程：spec(系統)→plan(系統)→worktree 子 session 實作→主 session opus 審+merge→--import+headless 合體驗→docs/memory/known_issues 更新→cleanup worktree。
