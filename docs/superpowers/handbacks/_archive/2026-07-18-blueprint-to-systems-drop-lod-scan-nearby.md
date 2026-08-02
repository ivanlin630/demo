---
from: blueprint
to: systems
status: consumed
topic: "[WHAT 鎖定·用戶定 2026-07-18] 廢除 LOD 雙-fidelity,perf 全靠『掃近隊』(空間有界互動)。取代原 Tier2 O(N²) arc + backlog LOD-opt 併一條=B enabler。落檔現在做,實作 Tier2(經濟後)。spec 前建議 R① factcheck 前提。"
---

# WHAT 鎖定：廢 LOD，改「掃近隊」空間有界

## 決策（用戶定 2026-07-18，blueprint 鎖 WHAT）

**廢除 near/far LOD 雙-fidelity。正典 = 唯一 mode（uniform full-fidelity，全隊每 tick 等值模擬）。perf 全靠「掃近隊」= 空間有界的隊間 scan / 評估 / 互動。**

## 為什麼（一招解三 + 順殺一 bug）

近/遠 LOD 是用錯方法解 perf：雙 fidelity（便宜遠/貴近）→ 必然非中性（相機選贏家）。用戶解 = 統一全 fidelity + 空間有界互動：

1. **中性**：無 fidelity 不對稱 → 「觀察區比較強」bug（近-only 系統 reactions/regen/outpost_tick/cleanup，`sim_runner.gd:169/494/505`）**從根刪除，非 defer**。= 「命運不看玩家臉色」（`progress:128`）最強形式。
2. **可規模化**：O(N²)（faction_ai `evaluate_all` 對全 factions×全 member_team_ids，`known_issues:138`）→ O(N×k) 空間有界。直攻真根。
3. **可信**：只評估感知/空間鄰近的隊 = 感知鐵律正解（不 god-view 掃遠隊）。
4. **紅利**：廢 far-cadence → 遠隊回正常速，順手修 `known_issues:139`「far 移速 10× 慢=遠隊行為錯」。一刪殺兩 bug。

## HOW 交你（系統），但這些 WHAT 約束硬

- **faction_ai `evaluate_all`（`known_issues:138`）必須改 neighbor-bounded**（現對全隊 rank）。
- **遠方資訊走 belief/message，不靠 god-view scan**：faction-wide 戰略、遠方謠言 = 經 belief/message 系統（本就空間傳播）餵決策。「掃近隊（直接感知）+ belief（遠方傳聞）」= 乾淨分工。**不得**用全圖 scan 補遠方資訊（那又是 god-view）。
- **成敗關鍵（measurer 坐實）**：掃近隊 bounding 必須補回 far-cadence 拿掉的 perf 節省，且撐到 **50-100 隊可玩 tps**、無 cluster-blowup（密集聚團時 k→N 退回 O(N²) 的邊角要有解或證稀有）。
- **行為改動非純 refactor**：廢 far-cadence 改 tick 行為 → determinism re-baseline + 故事稽核（非 byte-identical）。這是行為改，走完整驗收（measure + QA 故事），非「遷了不變」refactor 驗。

## 序 + 落檔（兩件事）

1. **落檔現在做（回應用戶「有沒有全記」擔心）**：把此 WHAT 寫進 roadmap；更新 `progress.md:128-134`（LOD 從「step④ 保留/prove-match-later」改「**刪除**」；B-enabler 改「掃近隊 spatial-bound」）；`known_issues.md:138/139` 掛此 arc。你是單寫者，這條記錄權在你。**先落檔，別讓決策丟失**（本 session 具體機制 `sim_runner:169/494/505` 一併記，免重造）。
2. **實作排 Tier2（B enabler，經濟 deal-flow 之後）**：此條**取代**原「O(N²) faction_ai arc」+「LOD-neutral-opt」兩條，併一條。當前主線仍是 ②絕境階梯 → slice2 感知 → Tier1 經濟 deal-flow(死法②) → **本條(廢 LOD+掃近隊)** → 框架清潔其餘。

## 閘

- **新概念大框 + 前提含 code 斷言**（掃近隊真能 bound O(N² 熱點 `evaluate_all` 且不破 faction-wide 戰略決策）→ **spec 前建議 R① factcheck**（前提：①O(N² 真根確在 evaluate_all rank-all？②bound 到 near 後 faction 戰略/遠交/founding 這些非-local 決策靠 belief 餵夠不夠？）。本 arc 前提歷史上被 R① 打臉多次，別假設稽核。
- R② 審 spec 每 slice 必過。

## 溯源
本 session 對話（近/遠 LOD → 觀察區比較強 → HD 落地只解一半 → 用戶裁廢 LOD 掃近隊）；`progress:128-134`；`known_issues:138/139`；`sim_runner.gd:169/494/505`（LOD_NEAR 近-only 系統機制）；連 [[project_time_scale_wave]]（原 O(N²) 歸時間 wave，此決策改向）。
