# Session 交接（2026-07-04 #11，系統 session）

> 給重開後新 system session（`$env:SESSION_ROLE='systems'; claude`）。承 #10（`2026-07-02-session-handoff-10.md`）。
> 本 session = **征服維度打通 + 複利弧點火 + ★軌3 二考=世界活了（沙盒 bar 首過）**。全 merged+驗+回歸綠。

## 你是誰
系統(Systems, HOW)。owner = invariants.md / 流程docs / progress.md / known_issues.md / CLAUDE.md / docs/process/* / auto-memory(單寫者)。開頭讀 `docs/process/00_roles.md` + 掃 `handbacks/` 的 `to: systems / status: open`。不碰 game-design.md（藍圖 owner）。

## ⚠ 開頭必跑
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd      # 基準:1 FAIL(pre-existing 弱目標)+0 SCRIPT ERROR+DONE
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd  # PASS=7 DORMANT=0
```
重型 bed `GODOT_TIMEOUT=2500~5400`+背景;**輸出先落檔再篩**（勿管線 First/Last 賭表位置）;bash 跑 .ps1=127 用 PowerShell tool;**同機勿並行重 bed**（爭用互殺教訓）。

## 本 session 主線（時序,全 merged）
1. **R1 三帶+R2 judge 收編**（拔 rung-food 攻擊閘+logistics 因子;disposition 共源 judge−1）→ 狼出閘。
2. **die-off erase 批次**（pointwise CLEAN;誠實揭 erase 非主導）→ **cadence spike 修**（SSSP 永續 cache,faction_ai 20×↓;RNG 流教訓:濾鏈含 randf 勿重排/memoize）。
3. **長窗 harness + 長窗×2**:複利弧未成立三斷鏈 → zoom 三子根（found_ally 無 timeout bug/readiness 隱藏 food 閘/food<20 濾）→ 深化二假陽性判定。
4. **信使外交+F-I1 統一**（envoy 實體/廢同格追談/god-view 公式退役 judge−1;兩升格 invariant:凡 latch 必 timeout/身分=權重非路徑切換）。
5. **asm 做深+②b/②c**（餵養真掏糧/看守 dial/hunger_relief 只降搶糧;T36 raid 0→37-54/月;asm 假設證偽→藍圖旋鈕 FOOD 0.3/INIT 0.35/壯兵厚待加權）。
6. **斷① 打草穀+不換腦 enforce**（成員個體 raid;own 減免只給能拍板者;實作抓出我 spec PRIO 誤述——真 enforce=idle-guard 非優先權,已補正）。
7. **三平行軌**:佔村 option（measure:主斷=收益鏈）/誘因結盟（accept 脫 0）/馬 slice（產馬帶+breed+envoy×2.96）。
8. **收益鏈**（翻旗接治權 capture∧subjugate,works_tile_pass=93=村產出歸 owner;margin gate 序列成長;收取鏈驗無洞——effective_food 現格制確認不動）。
9. **單寫者 B（5 chokepoint,pointwise CLEAN,defect:21 stale 證偽結案）+ S1 tile-bank（~40 站點,mint 守恆 connect,兩舊 leak 結案）→ 第 3 不變量大塊全齊**。
10. **default measure**（gen_census_bed:狼候選 0.4/seed+承載力 2.3× 實測）→ **gen 校準**（roving[6,10]/pop[8,10]/outposts+40%/granary800/roving糧180;狼 1.8/seed;緩坡全月<15%）。
11. **★軌3 二考=世界活了**:default 兩 seed 全鏈 fire（立國 0→2/1、by_attack 0→1/4、同化 0→67%/43% 暴動 0）、狼弧雙向可追（Team16 raid 爬階入 faction 有起落/Team19 轉糧引擎=雙引擎人格分流）、緩坡 robust。assets `assets-2026-07-03-exam2/`。

## 當前狀態
- **報藍圖 `2026-07-03-systems-to-blueprint-exam2-world-alive` = open**（里程碑+建議 GUI slice 開燒）。等藍圖確認。
- 管線序（用戶裁 `gui-after-pipeline` 鎖定）:①段基本收完 → **② 觀測 GUI 輕 slice 條件成熟**（事件 ticker/隊伍 inspect/速度控制,畫既有探針,bar=看著狼崛起;HOW 我 own）→ ③願景凍結照舊。

## Queue（優先序）
1. **GUI 輕 slice**（藍圖確認後;Team16/19 弧=demo 素材）。
2. **envoy 結盟弧殘**（二考 delivered=0:馬鏈 6 月未貫通到信使 or timeout 值;非阻塞）。
3. **強制閘全立**（CI-scan pattern 已鋪每 chokepoint,收攏成閘=infra 不需裁）。
4. **cadence 殘餘**（far.total 0.45-0.83s/500tick=top violator + orders_ambition ~300ms,quantified in `cadence-spike-fix` handback）。
5. **矩陣剩餘**:互動 F-I2 tribute 3公式/F-I4 deception 3引擎/F-I5 RelationGraph/F-I7 combat god-view + **finder 濾鏈 C 類 watch 順盤**;人力 F-M1-7;belief F-B1/B4;S6 殘量（fatigue/work_morale/current_option/strategic_assignments）;另型 tile 欄（facility levels 等）。F-P 留玩家面。
6. G3 Phase D 照排。warring baseline JSON 已作廢（gen 變）,要 diff 先重擷。

## 本 session 工作流教訓（已入 memory/checklist 者標）
- **RNG 流神聖**:濾鏈含 randf 副作用（estimate_catch_up→observe）→「純 AND 濾可重排」假設要先驗 RNG;LW_DIAG 擾流勿混 baseline。[known_issues cadence 條]
- **輸出先落檔再篩**（管線 First/Last 砍掉報表,重跑一次 6 月）。
- **stale-spec 兩次被實作抓**（PRIO_FACTION 誤述/defect:21 誤標行為修）→ spec 引用碼行為前先驗證;實作誠實抓錯=流程健康。
- **藍圖裁定兩層制**（WHAT+驗收=硬;因果假設=假說待 measure）——本 session 藍圖 reachability/深化二觸發兩度被 measure 翻。[memory feedback_session_roles]
- **judge checklist 生效**:R2/F-I1 淨 −2;佔村=option 非判斷器;gift=先統一後加 term。watch:per-option finder 濾鏈重複（C 類）。[memory project_unification_matrix]
- **TEST 判準 vs 定性 bar**:15% 月降幅是我的 TEST 判準,藍圖 bar=定性緩坡——微超時按定性裁,別被自己的數字綁死。
- 慣例沿 #10:消費 handback→measure/spec→push（worktree base origin）→一行 spawn→收 handback→驗基準→merge→合體驗→docs→報藍圖→push。L 層聲明每 edit;merge 後 `--import`。

## 4+2 對稱不變量（invariants.md 現況）
```
凡 named 意圖  → 可解釋驅動      ✓
凡 belief     → provenance      G3 Phase D queued
凡 state 變化  → 單寫者/driver    ★大塊全齊（強制閘可全立）
凡位置        → 可解釋上位路徑    ✓
凡 tick       → 早晚成本無延遲差  in-scope 收斂（殘 far.total/orders queue）
凡 in-flight latch → timeout     新（found_ally 教訓;faction 外交直追=同型缺口 queue）
凡身分        → 權重非路徑切換    新（enforce 第一處落;後續格照守）
```
