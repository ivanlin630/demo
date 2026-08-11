# 統一派遣模型 — 匿名不落單、組成看重要性（WHAT / vision）

status: DRAFT（pending R①[機制可承載性、硬數據] + R² → build）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-11
溯源：anon-drain 調查（真源 v4=領主 deliberate scout + succession 機械升 leaderless messenger、over-claim ×4 用戶 measure-first 仲裁定案）→ 用戶拍 B 並逐步 refine 出世界規則。grounding 表 `2026-08-11-...-dispatch-grounding-table`（code-read file:line）。

## §1 ★世界規則（用戶定案、命門）
1. **匿名永不單獨行動;單獨行動必為記名。** 匿名 = 無獨立能動性的群體、只以跟班身分在記名領隊底下成群行動。**孤匿名不存在**——一個單獨行動者必然是有身分的記名個體。
2. **∴ bug 根本消失**：現況「leaderless 孤匿名 messenger → succession 機械升 named」= code 先製造世界矛盾（孤匿名）、引擎才去修（升格）。取消孤匿名 → succession 無誤觸對象。succession 安全網對**真 leaderless 團**（記名領隊真死的隊）照常運作。

## §2 派遣組成 = 依任務重要性的 genuine 決策
- 關鍵事（要害偵察/談判/救援）→ 派**親信（記名）**、可多記名。
- routine 單人事（送信）→ 派一個**次要記名**跑腿（單獨=記名、非孤匿名）。
- 規模事 → **記名領隊 + 匿名跟班團**。
- 由「**重要性 × 手上有幾個可動用記名 × 信任 × 人格**」決定（多疑領主重要事只信親信/手下記名少 → 派匿名團或少做）。util 秤、人格 modulate、非固定模板。
- **★genuine 戰略約束**：單人任務消耗記名、記名有限 → 領主能同時派的單人任務受限於可動用記名數（親信珍貴、挑著用）。= genuine 非 crank。

## §3 全員歸隊（return-cycle）
派出的記名任務完歸記名 roster、匿名跟班歸匿名池。**無 monotonic drain**。（群派遣 envoy/builder/convoy/settler/facility-builder 已符;修的是 4 個現況孤匿名 scout/herald/care-scout/rescue。）

## §4 匿名→named 只湧現（genuine 事件、非機械）
- 領隊戰死 → 跟班接班（真 succession、真故事）。
- 跟班不爽 → 脫隊/叛（真動機）。
- **★主動/deliberate 升格（領主刻意提拔能幹匿名）= parked 未來討論（用戶 2026-08-11）**、本 arc 不做。
- 機械升格（succession 誤觸孤匿名）**除**（§1.2 根本消失）。

## §5 fix scope（grounding 定、窄）
- **改**：scout `_try_scout_side:2045` / herald `_try_herald_side:2004` / care-scout `_dispatch_care_scout:5110` / rescue `:5231`（現孤匿名 → 依 §2 改記名或記名帶團 + §3 歸隊）。
- **已符**：envoy/builder/convoy/settler/facility-builder（named-led + 歸隊）。
- **genuine 永久**：migrant（settlers 落地 target 村、非 drain-bug、不動）。
- succession 安全網（`faction_ai:784`）：對真 leaderless 團照留、孤匿名對象消失即不誤觸（§1.2）。

## §6 量測（湧現、fp / 硬數據，4× over-claim 教訓）
- anon 池**不再 monotonic drain**（solo dispatch 走記名、匿名恆在團、歸隊）。
- 組成**依重要性分化**（要害→記名/親信、routine→次要記名、規模→記名帶團）+ 人格 modulate。
- 湧現升格照 fire（領隊死→接班）於 genuine 場景;機械升格 0。
- **★re-measure 下游**（anon 漏光疑 relief/care/builder 派不出真根之一 → 修後量會不會跟著通、**不預設**、免再 over-claim）。
- **★★re-measure 團數 / O(N²) perf（用戶 2026-08-11 連結假設）**：機械升格每次生一個獨立記名幽靈團（trace Team4/5/6=升格信使）→ 疑膨脹團數餵 O(N²)。修後斷此團源 → 量「幽靈團生成數 / 總團數 / per-tick 成本」修前 vs 修後、**測其對 O(N²) 貢獻量級**（顯著=白賺 perf 勝、次要=誠實記）。★假設非結論（4× over-claim 教訓）、硬數字定。連 [[project_framework_seams]] perf O(N²) / 時間統一 wave。
- determinism;無 regression;constitution 綠（組成=決策非硬閘、無新死常數）。
