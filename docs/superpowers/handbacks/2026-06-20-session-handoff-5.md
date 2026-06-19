# Session 交接（2026-06-20 #5，系統 session）

> 給重開後新 system session（`$env:SESSION_ROLE='systems'; claude`）。承 #4（`2026-06-19-session-handoff-4.md`）。
> 本 session = **因果脊椎全收 → measure-first 量測迴圈**：探針上線 + 3 輪 world_sim 量測 + #0 戲劇尾巴（root 確證）+ 藍圖 ruling 接力。main 全綠、無未 merge。

## 你是誰
系統(Systems, HOW)。owner = invariants.md / 流程docs / progress.md / known_issues.md / CLAUDE.md / docs/process/* / auto-memory(單寫者)。不碰 game-design.md(藍圖)。開頭讀 `docs/process/00_roles.md` + auto-memory(hook 注入) + 掃 `handbacks/` 的 `to: systems / status: open`。

## 🔔 本 session 建立：自動 📬 hook（重要）
`UserPromptSubmit → .claude/hooks/handback-inbox.sh`（gitignore 本地）**每 turn 掃** `to:$SESSION_ROLE status:open` → 注入 📬，補 SessionStart 只掃一次缺口。空則靜默。已 live（本 session 已見注入）。`00_roles.md` channel 節記。**重啟後自動生效**（settings watcher reload）。memory `[[feedback_cross_role_handback]]`。

## 因果脊椎 ③G3 — 全閉環落地（本+前 session）
G3a accessor / G3b multi-claim / G3c-1 可信度+信任 / G3c-2 識破+觀察吃技能 / G3d-1 決策 gate / G3d-2 scout 查證 / G3-targeting 攻擊選擇讀 belief。誘殺脊椎閉環。詳見 `[[project_causal_spine]]` + `known_issues.md` G3 段。

## measure-first 量測迴圈（本 session 核心）
1. **探針 merged**（`spine-probes`）：`Probe`(flag gated 累計器)+`SpineTrace`(時間軸 G1/G2/G3/Named)。host=game_sim_test + world_sim。事件點 ~15 處 1 行 bump。零行為變。spec/plan `2026-06-20-spine-probes*`。
2. **world_sim 量測台 merged**（`world-sim`）：純 NPC 長跑（config 無 player→player_id=-1→不觸發絕後 game_over→世界跑滿）。`config/world_sim.json` + `scripts/debug/world_sim.gd`。`2026-06-20-world-sim-measurement*`。
3. **量測定論**：2 年 vs 90 天 emergent 6 鍵全 0 = 真沒條件非沒跑夠久。藍圖追真因 = **world-gen 人人平庸無 outlier**。
4. **#0 戲劇尾巴 merged**（`world-gen-tail`）：`generate` 窄帶凡人+archetype 狂人(霸主/屠夫/謀士/懦夫)+config 種極端 leader。**重量證 root：立國 0→1、識破裁決 0→7**（純人格值無場景）。`2026-06-20-world-gen-dramatic-tail*`。

## 下一步（藍圖 ruling 已裁，4 workstream，全 open 待 spec）
讀 2 封關鍵 ruling（已 consumed，但內容是下一步藍本）：
- `2026-06-20-blueprint-to-systems-feud-scenarios-ruling.md`
- `2026-06-20-blueprint-to-systems-dramatic-distribution.md`

| # | 項目 | 規模 | 重點 |
|---|---|---|---|
| **#0b** | #0 完善 | 小中 | dramatic-distribution ruling：(a) **升 named 忠於 tier**——`generate_for_team` 呼 generate() 不看 tier + kill_random 隨機 → 菁英 anon 升 named = 隨機低技能、老兵本事蒸發 → **技能尾巴被晉升稀釋**（讀來源 tier 設技能，複用 AnonTierSystem）；(b) leader 偏野心+能力尾巴（狂人要有本錢）。**最划算**（補 #0 缺口，使尾巴耐久）。 |
| **A** | feud 放寬 | 小中 | feud ruling：被侵害即記(劫掠/吞併/屠/背叛,非只倖存被搶)+滅族→**餘部繼承**(同夥/faction,**非血親**=④Trait/家族樹後做)+嚴重度×個性 gate(複用 G2d intensity×個性,公平交手可不結仇)。現 feud 源僅 `npc_combat:236`(敗方被 loot 卻存活)→滅團無倖存記仇→feud≈0。 |
| **#1** | 經濟閉環 | **大** | feud ruling 升「下一個大實作」：履約(現 0%,訂單只 expire 不 fulfill、interaction trade 不認 order)+腐壞/儲限(食物囤 4-5 萬無壓力,經濟空轉)。mint+更多衝突搭它。可與 A 並行。 |
| **B-QA** | scout/ambush 場景 | 小 | feud ruling：現在排驗證場景(G3d 碼從沒被看著 fire,world_sim 台現成)。偽裝低報 armed 假弱餌+莽者不確定攻擊。 |

**mint**：等 #1 重量後定（藍圖「別速建」，控金礦 faction 可能自湧現）。

**建議序**：#0b + A feud（小中,emergent 軸,並行,改完重量）→ #1 大根（並行可起）→ scout/ambush QA → mint 待 #1。**建議 #0b 起手**（補自己缺口最划算）。

## 系統域待辦（不卡藍圖，自排）
- **trust 飽和**（reconcile 每觀察 tick 重跑，world_sim 2 年 down~6000/up~5000）：gate cadence / 降 TRUST_DELTA / 同對記一次。
- **known_reputations 懸空死隊 bug**（world_sim 強審計揭 ~2380-2701 violations，root **未定**）：`erase_team` 死時清 known_reputations 但某路徑重注入（疑 update_reputation caller）。**試補 erase_team 清 team_intel → 沒降+改行為已 revert（猜錯）**。記 known_issues，需 systematic-debug 找重注入 caller，**別猜** [[feedback_avoid_rabbithole]]。

## 工作流提醒
- 每輪：merge 前自審 diff（打點位置/守恆/不凍結）+ 自跑回歸（headless flag-off 零變 + 場景跑通），不信 handback。
- world_sim 跑 2 年分鐘級（seed 77 可重現）；headless flaky 已修（IntelSystem Tier0 band 對齊 G3c-2 噪）。
- 量測數字回呈藍圖走 handback（藍圖不讀 memory）。
- 殘留 worktree：`.worktrees/{world-gen-tail,spine-probes,world-sim}` + 一堆舊的（housekeeping，非阻塞）。
- 別問技術微決策；ctx ~90% 才提醒交接。
