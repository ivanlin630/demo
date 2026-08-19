---
from: measurer
to: systems
status: consumed
topic: "agrib-final-round-interim"
---

# 農業b最後一輪：中途插播（長跑進行中）+ 具名科目①已有答案

## ★具名科目①：fixture artifact 確認（不需 organic 驗就已定案）

code-read 直接坐實：`headless_test.gd:15297` `_mk_produce_team_on`（g1a 礦村鑄幣測試用的生產隊 fixture）**從未設定 `leader.skills["統領"]`**，只設 `values["貪婪"]/["野心"]`。→ `effective_pop_cap` 讀 `leader.skills.get("統領", 0.0)` 拿到 **0.0** → `pop_cap_from_leadership(0.0) = 1`（`team_data.gd:49`）→ outpost_level=1 放大器=2.0 → effective_pop_cap≈**2**。測試用 `_seed_pop(team, 10)` 種 10 人 → 隊一開局就超額 8 人 → `check_overflow_for_team` 立刻觸發、把生產人力拆走（overflow 隊沒有 named advisor 可帶走時走 `_create_overflow_team`，origin 隊剩不到 2 人）→ 剩下的殘隊根本不夠人力跑 collect+mint tick。

**判定：這是 fixture artifact，非 organic 世界的真實結構性問題**——測試 helper 忘了給生產隊 leader 一個正常「統領」值（其他 fixture helper 通常會設）。**建議修 fixture**（給 `_mk_produce_team_on` 的 leader 補 `skills["統領"]` 一個正常值，如 0.5），非加 production floor。

organic 世界的深層問題（真實弱領導小村是否也被結構性卡住）**仍在跑的長窗會給答案**（下面）——若 organic 快照裡 cap<5 的隊 mint_level>0 比例明顯低於 cap>=5 的隊，才是真訊號；目前 fixture 這條路已經排除是唯一原因。

## ★②③：長跑進行中（跟原始 3mo popcap 床同規模，預期耗時同等或更久）

`godot --path .worktrees/agriculture-b` 跑 warring_states.json seed=1337 3mo（自建 `agrib_final_round_bed.gd`，跟原本 `agri_b_popcap_bed.gd` 同構）。**已跑約 40 分鐘 CPU 時間，進度 day30/90**（teams 49→102，已超原始基線）。per-day cost 隨 team 數增長明顯變重（day0-10 每5天約 300s CPU、day25-30 已需約 400s+/5天）——跟原始輪同款 O(N) 甚至更差的 scaling 症狀重演，屬預期（此為原本就知道的 P0 perf 缺口，非本輪引入）。

**churn 訊號已現**：`join.abort_ghost=1` 在 day30 首次觸發（機制活著）；`popcap.overflow_fire=2`。

會繼續跑到完成（或撞 timeout，wrapper 已修=stdout 不會憑空消失）。完整②③數字（cap 分布/team 暴增/perf 曲線/同對隊反覆數）跑完後另封信報。**這封先讓你知道①已有答案+②③在途，非放你空等**。

地基 KEEP，跑法不變。
