# 斷①：打草穀 + 不換腦 enforce — Plan

> Spec：`docs/superpowers/specs/2026-07-03-raid-continuity-identity-weight-design.md`（先整份讀,含硬約束）。
> 順序:Task1 A+B（打草穀+統領令語意）→ Task2 C（不換腦）→ Task3 驗收。

## Task 1 — A 候選放行 + B own 減免收緊

**檔**:`faction_ai_system.gd`
1. `_is_prosperity_candidate`:刪「faction 成員非 leader → false」（保留 `parent_team_id != -1 → false`）。
2. `find_prosperity_prey` ③ own 因子:`war_capability` 減免**只給** faction leader（`f.leader_team_id == team.team_id`）或獨立隊（`fid == -1`）;非 leader 成員對 believed-owned prey 恆 `WAR_COST_BASE`。註解寫明 stakes 歸屬語意（誰扛得起戰爭後果誰減免,非身分切路徑）。
3. headless 測:成員候選過 gate;成員 day-op 對 believed-owned score 壓死（不中選）;leader/獨立照舊減免。

## Task 2 — C 個人戰略層拆早退

**檔**:`faction_ai_system.gd`
1. `_evaluate_independent_strategy` 刪 `if team.faction_id != -1: return`;成員 leader ctx:`can_found=false`（fid≠-1 者建國 gate 本就擋,確認雙保險不重複建國）,征服 intent 照 defer prosperity。
2. **scope 紀律**:`_evaluate_solo` 迴圈 `elif team.faction_id == -1` 分支**不動**（個人日常全域=後續矩陣格）;本波只讓成員跑 `_evaluate_independent_strategy`（戰略 intent）——evaluate_all solo 迴圈需調:成員也呼 `_evaluate_independent_strategy`（不呼 `_evaluate_solo`）。
3. 執行壓層:靠既有 `PRIO_FACTION(30) > PRIO_DISPATCH`,零新碼。found in-flight timeout（②a）照吃。
4. headless 測:成員征服 intent 宣告可見（conq.declared）;faction directive 在 → 成員個人 raid dispatch 被壓（try_set 失敗）;無 directive → raid 設得進;成員不重複建國。

## Task 3 — 驗收

1. **長窗 6 月**（`LW_SEED=1337 LW_MONTHS=6 LW_DIAG=1`,輸出落檔再篩）:
   - 入 faction 狼 raid 不歸零（T32 型月曲線連續）;[WolfGate] 無「非候選(fid)」殺項。
   - asm 三帶框順驗（旋鈕已入 main:FOOD 0.3/INIT 0.35/壯兵厚待加權）:糧正狼同化 completed>0、純餬口敗=ok、殘忍照炸——記分流表進 handback。
   - 月線 sanity:隊數/found 不崩。
2. seeded warring 2 月:不 over-war（attrition 對照）;成員攻 believed-owned=0（無 directive 下）。
3. 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7 DORMANT=0、coin_eq delta=0、InvariantAudit 0。pointwise 預期 DIRTY。

## Handback

`docs/superpowers/handbacks/2026-07-03-raid-continuity.md`:各 Task 結果、T32 型解凍證據、asm 三帶分流表、紀律測證、月線對照、偏離處。

## 注意

- Godot `.\tools\godot.ps1`;長窗 `GODOT_TIMEOUT=5400` 背景;**輸出先落檔再篩**。
- headless 基準 1 FAIL（弱目標）=pre-existing。
- 硬約束:零新判斷器;身分只在 stakes 權重+can_found 實體 gate;無新 latch;禁碰 asm 值/envoy/R1 其餘。
