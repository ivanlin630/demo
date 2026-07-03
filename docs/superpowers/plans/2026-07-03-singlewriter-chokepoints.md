# 單寫者收齊 B：chokepoint 掃收 — Plan

> Spec：`docs/superpowers/specs/2026-07-03-singlewriter-chokepoints-design.md`（先整份讀）。
> 序:Task1 S9（init 歸宿先立）→ Task2 S5/S6 → Task3 S11/S12 → Task4 驗收。
> **紀律:純 refactor 段行為位元不變;S11 defect:21=行為修段單獨 commit 單獨驗。**

## Task 1 — S9 `create_team` chokepoint
world_state.gd 立 `create_team`（註冊+known/discovered/intel row init+tile index）;10 直寫站點（manpower:217 breakaway/subteam/beast/population/gen…）收編。headless 測:建立後 registry 完整（原「忘了 init 就 desync」病例覆蓋）。

## Task 2 — S5 tags + S6 高風險欄
1. `set_team_tags/add_tag/remove_tag(reason)`;12 站點收（beast:24/event_tag_shift…）。
2. `solo_intent`:faction_ai `_set_solo` 升格單寫者（消旁寫,grep `\.solo_intent =` 殘量歸零）;`readiness`:`set_readiness(team, val, reason)`,戰鬥/恢復/manpower 站點收。
3. 其餘無主欄不動（spec 明列,勿擴）。

## Task 3 — S11 faction_id + S12 reputation
1. 8 站點改走 `set_team_faction`。**defect:21 單獨 commit**（懸空 member_team_ids 修=行為修:InvariantAudit 懸空計數前後+月線 sanity 單獨驗）。
2. sim_runner:168 等 2 站改走 `update_reputation`。

## Task 4 — 驗收
1. seeded pointwise CLEAN（seeds 1337/42/7 × 3 月）——**排除 defect:21 commit 後對照**（含它=DIRTY 預期,分開跑:refactor commits CLEAN、defect commit 單獨 sanity）。
2. 直寫殘量 grep=0（每 chokepoint 註解附 CI-scan pattern——強制閘地基）。
3. 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7、coin_eq delta=0、InvariantAudit 0。

## Handback
`2026-07-03-singlewriter-chokepoints.md`:各格站點數前後、pointwise 證、defect:21 行為修影響量、CI-scan pattern 清單。

## 注意
- Godot wrapper;pointwise bed `GODOT_TIMEOUT=2500` 背景;輸出先落檔。1 FAIL pre-existing。
- **平行紀律:禁碰 `npc_combat_system`/`outpost_system`/faction_ai `_find_occupy_target`（conquest-yield-chain 在飛同機）**;tile 層=A 波勿動。
- **bed 驗收錯開**:若同機另一子 session 在跑重 bed,等它完再跑 pointwise（wall-clock 爭用教訓）。
