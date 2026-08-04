---
from: systems
to: reviewer
status: consumed
topic: "[R²審herald非team carrier+A③名冊refine spec(2026-08-04-infonet-herald-carrier-HOW.md,blueprint全裁GO,diagnostic確認2root):B=herald team-carrier full-sim黑洞(on_leader_death promote 1-pop出throwaway named=team-ness副作用,full-sim team互動吃herald tick)+A=warring target前置(solo-heavy正確罕fire,mobile-lord名冊解不出)·fix=B herald非team輕carrier(state.in_transit_letters物件非state.teams成員→免撞succession/cull/subteam/on_leader_death/combat-target/全full-sim team互動=B root根治;spawn reframe _try_herald_side建letter+detach 1pop;新tick step _step_tick_letters move→抵seat deposit(lord co-located→team_known/不在→seat board領主留著等取Part1接力)/timeout/敵faction隊在場攔截死;payload simple distress)+A③名冊refine(_resolve_help_target target=最近自家faction固定outpost via full名冊非只lord自家=治mobile-lord,solo無lord仍不解=正確)·scout保留不動(35/40 working measure-first不修working)·★審點:①letter非team免team機具(非state.teams→無succession/cull/combat-target,B root根治)②A③名冊full(最近faction固定outpost mobile-lord解得出)③感知鐵律letter零特權(payload simple distress+名冊position-only+物理走delay+攔截死物理零god-view,constitution_gate綠)④determinism零新randf(move/攔截/timeout確定性+letter遍歷deterministic)⑤de-patch非增殖(herald team→letter物件category error正解,免succession marker補丁閘blueprint明否)·CLEAN→build→re-measure on FACTION bed(症1端到端:letter抵seat deposit→領主聞→distribute fire→糧真到)→QA"
---

# R² 審 herald 非team carrier + A③ 名冊 refine（blueprint 全裁 GO、diagnostic 確認 2 root）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-herald-carrier-HOW.md`
**root（diagnostic 確認）**：B=herald team-carrier full-sim 黑洞（on_leader_death promote 1-pop=team-ness 副作用）；A=warring target 前置（solo-heavy 正確、mobile-lord 名冊解不出）。
**WHAT 裁**：blueprint (B carrier + A 三點全 ratify)——信使=in-transit 訊息物件非 team=category error 家族正解。

## 一句話修法
B：herald 從「假裝 team」→ **in-transit letter 物件（非 state.teams）** → 免撞全部 team 機具（B root 根治）。A③：名冊 target=最近自家 faction 固定 outpost（full 名冊、治 mobile-lord）。scout 保留（working 不動）。

## ★審點（R² refute checklist）
1. **★letter 非team 免 team 機具**：`state.in_transit_letters`（**非 state.teams 成員**）→ 無 succession/cull/subteam-routing/`on_leader_death`/combat-target/全 full-sim team 互動。**確認 letter 真完全在 team 系統外**（B root=team-ness 副作用的根治、非又加 team 上的 marker/豁免補丁）。
2. **A③ 名冊 full**：`_resolve_help_target` target=**最近自家 faction 固定 outpost**（iterate faction 所有固定 outpost、非只 lord 自家）→ mobile-lord 解得出。solo（faction_id=-1）仍不解=正確（blueprint ratify）。確認名冊 full-coverage 對。
3. **感知鐵律 letter 零特權**：payload=simple distress（origin 自己 need、非讀 target live state）；名冊 target position-only 組織常識；物理走+delay；攔截/timeout/死物理零 god-view；`constitution_gate` 綠（letter 非 indexed 他隊 live 態）。
4. **determinism 零新 randf**：move/攔截（敵 faction 隊在場）/timeout 全確定性；letter 遍歷 deterministic order。
5. **de-patch 非增殖**（框內補丁 lens）：herald team→letter 物件=category error 家族正解（信使≠team）、**非又加平行機制**；**免 succession marker**（補丁閘味、blueprint 明否）。確認是「還原成真實 in-transit 物件」非「team 上疊豁免」。

## 邊界
- scout 保留 named/anon-subteam（35/40 working）、本批不轉 carrier（measure-first 不修 working）；若後續 fragile→另批 unify。
- deposit-at-seat：lord co-located→team_known 直投；lord 不在→seat board（領主留著等取、Part1 read_market_board 接力）——確認雙路 consistent。

**CLEAN → 回 systems → build（續 `feat/info-network-whole`）→ ★re-measure on FACTION bed（economy/§5 setup、症1 端到端：letter 抵 seat deposit→領主聞→distribute fire[util 0.659]→糧真到 resident）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 對用戶驗收。** 卡/BLOCKER → 報 `to:systems`。
