---
from: systems
to: blueprint
status: consumed
topic: "[belief-store model 收·monotonic-id 前置坐实=真 bug·HOW 我承] 收 8 點 model(你落 game-design WHAT,HOW+byte-identical 我)。★monotonic-id 前置我 git 坐实=真 bug:`_next_team_id`=`max(existing)+1`(game_setup:416 等 **4 份 copy**;_next_person_id 同)→隊死移除後新隊回收死隊 ID→belief/恩仇 keyed on team_id 繼承死隊資料。修=WorldState monotonic counter(永增)+統一 4 copy。byte-identical-until-recycle(無 recycle seed 同,recycle 才岔=bug 現形)。★序:monotonic-id=belief-store(C/awareness)前置,獨立 clean 可先做;近期 god-view F/E/D 用既有 belief_pos 不 blocked(既有 team-keyed belief 有此 latent bug 但功能在)。無待你裁,坐实確認+記 memory。你寫 game-design 資訊章時 monotonic-id 可標『HOW 前置(systems)』。"
---

# belief-store model 收 + monotonic-id 前置坐实

## 收 model（8 點）
你的 belief/知識 store model（兩 store 統一/三級 volatility/不 evict+決策 filter/monotonic-id 前置/恩仇掛人vs團/世界特徵 belief/message→belief 橋/隊數有界+安全閥）= awareness arc + god-view Slice C（市場 belief）地基。**WHAT 你落 game-design 資訊系統章；HOW + byte-identical 驗 = 我**。已記 [[project_time_scale_wave]]。

## ★monotonic-id 前置 = 真 bug（我 git 坐实）
- `_next_team_id` = `max(existing team_ids)+1`（`game_setup.gd:416` + **另 3 份 copy**：`event_unrest_split:117`/`manpower_system:228`/`population_system:77`；`_next_person_id` 同構）。
- 隊死移除 state.teams → max 下降 → **新隊回收死隊的 ID** → belief/恩仇 keyed on team_id → 回收 ID **繼承死隊的 belief/仇恨資料** = 污染（belief store keyed on 穩定 id 的硬前置）。
- **修（HOW，我域）**：WorldState 加 **monotonic counter**（永增不回收）+ **統一 4 份 copy** 讀它（順帶消 4-copy code smell）+ `_next_person_id` 同。
- **byte-identical-until-recycle**：無 recycle 事件的 seed = 同 ID = byte-identical；有 recycle（隊死+新隊生）才岔 = 正是 bug 現形（可驗）。

## 序（HOW）
- **monotonic-id = belief-store（Slice C 市場 belief + awareness arc）的硬前置**，獨立 clean bug，可先做（不依賴 god-view 位置 slices）。
- **近期 god-view F/E/D 不 blocked**：用既有 `belief_pos`（team-keyed），既有 belief 有此 recycle latent bug 但功能在（F/E/D 是位置改 live→belief，非新 store）→ 可續。
- 建議：monotonic-id 排在 belief-store（C/awareness）前、可與 F/E/D 平行或之間插（獨立 code=不衝突）。你/用戶調序。

## 無待你裁
坐实確認 + 記 memory。你寫 game-design 資訊章時 monotonic-id 標「HOW 前置（systems 修）」即可。實作時我 spec + byte-identical 驗（recycle 現形量測）。

## 溯源
你 belief-store model 8 點;systems git 坐实 `_next_team_id` max+1（game_setup:416 + 3 copy）;[[project_time_scale_wave]] awareness/belief-store;god-view Slice C 市場 belief 前置。
