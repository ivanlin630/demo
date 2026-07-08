# Session 交接（2026-07-02 #10，系統 session）

> 給重開後新 system session（`$env:SESSION_ROLE='systems'; claude`）。承 #9（`2026-07-01-session-handoff-9.md`）。
> 本 session = **統一矩陣 program 開局 + 逐格燒**（intent 統一/致富錨 → coin/食物/征服 measure → means-end 接戰術層/交易網轉 → combat_target+BEG/JOIN → seeded harness → capture PAY → 單寫者 slice1/2/3）。全 merged+驗+回歸綠。**主線=measure-first 每燒一層露上游真瓶頸。**

## 你是誰
系統(Systems, HOW)。owner = invariants.md / 流程docs / progress.md / known_issues.md / CLAUDE.md / docs/process/* / auto-memory(單寫者)。開頭讀 `docs/process/00_roles.md` + auto-memory(hook 注入) + 掃 `handbacks/` 的 `to: systems / status: open`。**不碰 game-design.md（藍圖 owner）**。

## ⚠ 開頭必跑
```
.\tools\godot.ps1 --headless --import              # merge 新 class_name 後快取 stale
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd   # 基準:1 FAIL(pre-existing 弱目標未加入攻擊 goal)+0 SCRIPT ERROR+DONE
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd   # PASS=7 DORMANT=0
```
**重型 seed（warring/scaling/econ）用 `GODOT_TIMEOUT=2500~3000` + run_in_background**（跑分鐘級）。**bash 跑 .ps1=exit 127,用 PowerShell tool**。**PowerShell 無 `rm -f`**（用 Remove-Item 或 bash tool rm）。

## 本 session 主線：統一矩陣 program（藍圖 refactor 止打地鼠）

### 起點：藍圖問「為何一路沒發現架構沒統一」→ 教訓 + 矩陣
- measure-first 只抓近端不抓架構;過早喊 done 誤導。memory `feedback_structural_audit_complement`（+ claim-time trigger 自糾——我當場又犯，寫「全貌」被用戶戳「有逐行逆向?」才補窮盡）。
- **統一矩陣稽核**：first-pass grep（誤稱 team.resources 被 53 直寫繞=**錯**）→ 逐檔窮盡 sweep 全 76 production 檔（8-batch fan-out）。全貌 `specs/2026-07-01-unification-matrix-audit`（9×7 矩陣 + 30+ fork）。**核心對**（同 TeamData + computed getter no-op setter=最強單寫者）。memory `project_unification_matrix`。

### 逐格燒（全 merged+回歸綠，每批 framework 7/7 + coin_eq 全池 delta=0）
1. **首燒 戰略 intent 統一**：`select_strategic_intent`「任何 leader 一套菜單」。**致富錨接上**（specimen 想=致富→做=貿易,前「日常」無 driver=經濟真根解）。CONQUER 0→1。F-D3/D4/D6 收。
2. **單寫者 slice1 coin 守恆**：`CoinAudit` 全池（team+treasury+person.coin+tile vault+abandoned,剔 ore）+person.coin 單寫者+mint ledger。
3. **B 食物張力**：R1 供給 cadence 對齊（修 24× bug、移 far 冗餘 regen）+FOOD_PER_PERSON 2.4→0.8+R2 flow-not-stock。forest 苟活/plains 繁榮/不 mass-starve。**⚠全窗 warring 揭征服/擴張被壓平**（食物 rung-flow-gate 需盈餘才開戰）。
4. **單寫者 slice2 ledger+roster**：Pattern B driver-ledger 真記（5 bank）+roster chokepoint（add/remove_member）。**audit 揭 leader/team_id desync**。
5. **征服名實 measure**：**證偽首燒假設**（非掠奪搶排序,是兩條攻擊路徑）。
6. **means-end 接戰術層**（願景進化第一深化,memory `project_playable_priority` 升「逐步逼近完整 AI 四關」）：戰術層 intent-blind→`intent_fit` term reshape。**症狀 a 致富→貿易全解=交易網終於轉**（前真閘=建設 util 碾貿易非食物）。症狀 b 征服 route 6.6× / c 匱乏→搶 gated。
7. **單寫者 slice3 leader desync 根修**：`set_leader` chokepoint force-sync + 反向 roster audit + ledger tick。
8. **combat_target+BEG/JOIN**：social_target 拆戰鬥語意+chokepoint,新 JOIN resolver,**死路消 join.resolve 0→4**（F-S4+F-I3 收）。
9. **seeded warring harness**：WarringHarness 逐 tick 確定+pointwise diff（noise floor=0）→ **emergence/over-war 硬-verifiable**（解一路撞的 unseeded 盲點）。
10. **capture 完成 depth**：潰逃兩路 PAY（loot+rout capture）。**measure 揭主崩上游=intent 126→combat 12（~10% attack→combat 轉化=targeting/reachability）**。

## ★ 當前狀態 + 征服者 emergence 下一瓶頸
- **經濟維度：交易網轉了**（means-end 致富→貿易全解）。
- **征服維度：卡 attack→combat 轉化（~10%）**——capture PAY 已備好（戰若發生有收成）,但**攻擊派了打不到人**（targeting/reachability）。survival-trap 亦隨此=打得到→搶得到→餵飽。**征服維度最後一哩=attack→combat 轉化。measure-first 定,非猜。**

## 沙盒願景定稿（藍圖 `sandbox-vision-locked`,已對齊）
- `game-design.md`「完整沙盒願景」段（藍圖 owner）。五代十國 / 1-2 代 / 沙盒優先。七維度（經濟✓/征服差 capture/資訊+AI 深度+統一架構+per-tick 在飛;正統宗教文化/關係聯姻/繼承爭位性別/天災/敘事可見/玩家面 未開）。燒序:統一矩陣 → 4 正統(接 G3) → 5 聯姻(RelationGraph) → 6 繼承(1-2 代鉸鏈) → 7 天災 → 敘事可見 → 玩家面。
- **★新硬不變量納 invariants「凡 tick 早晚期成本無延遲差」（效能域）**;**die-off erase spike 另案→必收**（違此不變量,known_issues 標紅,seeded harness 量）。

## 3+1→4 對稱不變量骨架（invariants.md）
```
凡 named 意圖  必有可解釋驅動   ← 決策域   ✓ commander-v2 enforce（+ intent_fit 接戰術）
凡 belief     必有 provenance   ← 信息域   G3 待 enforce（Phase E done、D queued）
凡 state 變化  必有單寫者/driver ← 所有權域 Pattern B slice1/2/3 起步（ledger+roster+leader+combat/social_target;剩 tile-bank）
凡位置        必有可解釋上位路徑 ← 選擇/階級域 獨立戰略層 ✓
凡 tick       早晚期成本無延遲差 ← 效能域   硬不變量（die-off spike 必收）
```

## ⏸ 待藍圖（open handback,非阻塞）
- **`thirdburn-trio-done`（本 session 最後）**：下燒三軌收下 + **建議下燒=attack→combat 轉化（targeting/reachability）**=征服者最後一哩。平行候選:die-off 必收 / 矩陣剩餘(tile-bank/互動 resolver/人力雙模型) / manpower assimilate cadence / G3 Phase D。

## 剩餘 queue（統一矩陣未燒格 + 跨軌 depth）
- **attack→combat 轉化**（征服者下一瓶頸,measure「90% 攻擊為何不進戰鬥」→ targeting/reachability/攔截）。
- **die-off erase spike 必收**（違 per-tick 不變量;erase O(N) 索引化/批次,seeded harness 量早晚曲線）。
- **單寫者剩餘**：tile-granary-bank / tile.resources bank（第3不變量最後大塊）。
- **互動 resolver 統一**（F-I1 兩 diplomacy resolver / F-I2 tribute 3 公式 / F-I5 RelationGraph orphaned）。
- **人力雙模型**（F-M1 prisoner_population↔captive / F-M2 skill / F-M3 injury / F-M4 equipment）。
- **means-end 後增量**：防衛/守成/建國/擴張 intent uplift（每個守四關）。
- **manpower assimilate cadence**（以戰養戰人側慢,morale 0.25→0.75 ~25 天,churn 下 P1Absorb=0）。
- **G3 Phase D**（植假 primitive,資訊維度/玩家錨 C;spec `2026-06-29-g3-info-warfare-unified` §Phase D）。
- **強制閘 + 設計 checklist**（program ②③,ledger 落地後可查對象在了→立閘;checklist 納 01_architect）。
- **TEST VALUE 平衡 pass**（FOOD 0.8/INTENT_FIT_DRIVE 1.5/HEALTHY_ROUT_FACTOR 0.35…全暫定）。

## 工作流教訓（本 session）
- **measure-first 每燒露上游真瓶頸,別猜**：致富→建設 util（解）→交易網轉;征服→攻擊分裂（解）→capture PAY（補）→attack→combat 轉化（下一）。每步 measure 定真根。[[feedback_avoid_rabbithole]]
- **寫進 memory ≠ 用 memory**（claim-time trigger 自糾;被動 memory=Pattern B stub,強制閘>記憶）。[[feedback_structural_audit_complement]]
- **窮盡 sweep 修正 first-pass 錯**（用戶戳「真全貌?」;grep+節選 ≠ 逐行）。
- **並行三軌 disjoint 檔案/函數**：同檔不同函數 ort auto-merge 幾乎無手動衝突（全 session ~5 批三軌全 clean）。plan 標 scope guard「動哪檔哪函數」。
- **征服 measure 證偽首燒假設**（別信自己上輪的假設,measure 打臉自己）。[[feedback_verify_backlog_fresh]]
- 子 session handback 誠實但會漏/誤判（如 slice3 handback 誤稱 FAIL 名「治療 goal」實「攻擊 goal」）→ 主 session 對基準驗。

## 流程慣例（本 session 穩定）
- 藍圖 handback 進 → 消費（status:open→consumed）→ measure/spec → push origin/main（子 session base origin,先 push [[feedback_worktree_stale_base]]）→ 出一行 spawn 指令（子 session `.worktrees/<feat>` 自建）→ 收 handback → 驗 baseline（1 FAIL pre-existing）→ 順序 merge（disjoint auto-merge）→ 合體驗（headless+framework+coin_eq）→ docs（progress/known_issues/invariants）+ handback 藍圖 → push。
- 用戶「都好了/第N個好了」=子 session 完成,去收。「看」=digest+plan。「一起做/都行」=平行 spawn。
