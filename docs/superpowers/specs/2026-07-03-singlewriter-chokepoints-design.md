# 單寫者收齊 B：chokepoint 掃收（S5/S6/S9/S11/S12）— Design

> 管線序（用戶裁 `gui-after-pipeline`）:統一矩陣剩餘全燒。本波=五格機械同型 chokepoint（S10 已 stale:slice3 set_leader 收,劃掉）。
> **freshness 已驗（2026-07-03 investigator）**:S5=12 直寫/S6=5+/S9=10/S11=8/S12=2,全 LIVE。
> A 波（S1 tile-bank,30 寫+coin 憑空鑄）另 spec,等 conquest-yield-chain merge 後燒（同檔 outpost）。

## 原則（Pattern B 既有慣例,mirror set_combat_target/set_leader/roster chokepoint）
- world_state.gd 立 chokepoint（單寫者+可 reason）→ 全直寫點改走 → audit 可查。
- **純 refactor=行為位元不變 → seeded pointwise CLEAN 必須**（同 dieoff-batch 標準;不 CLEAN=語意破打回）。
- 例外容忍:入口 init（team 建立時欄位初值）與 chokepoint 收編並不矛盾——建立走 S9 chokepoint 內 init。

## 五格

### S9 team 建立 chokepoint（先做——其他格的 init 歸宿）
- `state.create_team(team) `（或同名）:teams[id] 註冊+team_known/discovered/intel row init+tile index 邀請。現 10 直寫點（manpower `_spawn_breakaway`/subteam 派出/beast/population/世界 gen…）全改走。
- erase_team 已有=對稱補齊。

### S5 tags chokepoint
- `state.set_team_tags`/`add_tag`/`remove_tag`（reason 參數）。12 直寫點（beast:24/event_tag_shift/…）收編。load-bearing tags（軍隊/生產/流亡,movement:51 讀決策）=真值源保護點。

### S6 無主 team 欄（本波收 高風險欄,非全欄）
- 收 `solo_intent`（`_set_solo` helper 已在 faction_ai——**升格搬 world_state 或立 wrapper,消旁寫**）+ `readiness`（戰鬥/恢復/manpower 多系統寫→`set_readiness(reason)`）。
- 其餘（fatigue/work_morale/current_option/strategic_assignments/ambition_*）**本波不動**（列 known_issues 殘量,一次全收=diff 爆炸;ambition_* 已有 AmbitionLadder.update 單點=實質 chokepoint）。

### S11 faction_id 直寫掃收
- 8 站點（defect:21/split/beast/manpower/population/reaction）改走 `set_team_faction`（bidir 既有）。defect:21 最險（離 faction 沒清 member_team_ids）——**此站點修=行為修**（懸空鏈修復,pointwise 可能 DIRTY,單獨標記/單獨驗:InvariantAudit 懸空 faction 計數前後）。其餘站點若 faction 已不存在=純 refactor。
- 既有 known_issues「event_faction_defect:21 待 systematic-debug」一併收。

### S12 reputation 掃收
- sim_runner:168 等 2 站改走 `update_reputation`。最小。

## 驗收
1. **seeded pointwise CLEAN**（3 seeds×3 月）——除 S11 defect:21 行為修段（單獨 commit 單獨驗:InvariantAudit 前後+月線 sanity）。
2. 直寫殘量=0:grep 各欄直寫（chokepoint 檔自身除外）——**強制閘 program 地基**:每 chokepoint 附 CI-scan grep pattern（註解記,未來閘用）。
3. 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7、coin_eq delta=0、InvariantAudit 0。

## 檔案 scope（與 conquest-yield-chain 平行紀律）
`world_state.gd`（chokepoints）+ 直寫站點檔（event_*/beast/manpower/population/reaction/sim_runner/subteam/faction_ai 限 `_set_solo`/tags 站點）。**禁碰**:`npc_combat`/`outpost_system`/`_find_occupy_target`（收益鏈軌）;asm 值;tile 層（A 波）。
