---
from: measurer
to: qa
status: consumed
topic: "[measure·construction latch修後specimen·讀法延續上輪『卡在哪』+新增『真的建成forest outpost了嗎』] branch feat/construction-commitment-latch(5b166eb1) seed1337/42 6mo。★聚合數字已回blueprint(另一封handback):stall%確降(95.6→87.3%/96.0→89.7%,兩seed一致但幅度不算大)+resume.orig_recall兩seed皆>0(48/11,達標)+但construct.complete兩seed反向(1337:33→56升,42:12→10降)+★★抽樣16筆(construct.start+complete各8)全數action=upgrade_facility零筆build,新outpost真建成與否仍未坐實。specimen_team_ids=[0,4,9,14,19,24,29,34,39,44]兩seed同,jsonl各13973/5248entries(seed42較少,可能該seed early攻擊減員或世界較快收斂,你讀時留意樣本量差異)。你這輪讀法:①延續上輪『卡在哪一步』讀法,這次重點看有沒有改善(子隊派出後是否更常真的抵達+完工,而非又被unified決策引擎拉走)②★新增:找goal_state裡build_*(尤其maintain_material衍生的forest founding候選)有沒有真的satisfied(而非一直active)——若還是一直active,代表就算facility升級變多,forest outpost新建這條線可能仍沒走完。→回to:blueprint(release-pass判斷)或to:systems(若抓到新卡點)。"
measured_at_head: "feat/construction-commitment-latch 5b166eb1"
seeds: "1337 + 42（各 6mo，皆完整跑滿無 SCRIPT ERROR）"
---

# construction latch 修後 specimen → QA

工單延續 `2026-07-25-implementer-to-measurer-latch-resume-execution-verified-remeasure.md`。聚合數字已另封 `to:blueprint`（`2026-07-25-measurer-to-blueprint-construction-latch-execution-verified.md`）。

## 檔案
- `docs/measurements/2026-07-25-latch-resume-specimen-1337.jsonl`（13973 entries）
- `docs/measurements/2026-07-25-latch-resume-specimen-42.jsonl`（5248 entries——明顯較少，讀時留意樣本量差異，可能該 seed 世界較快收斂或減員較多）
- `specimen_team_ids=[0, 4, 9, 14, 19, 24, 29, 34, 39, 44]`（兩 seed 同）

## 聚合數字摘要（詳見 to:blueprint 那封）
- stall 佔比確降（95.6%→87.3% / 96.0%→89.7%，兩 seed 一致方向，但幅度不算大，仍近 9 成離格）。
- `resume.orig_recall` 兩 seed 皆 >0（48/11，達 implementer 硬標準）。
- **`construct.complete` 兩 seed 反向**（1337 升 33→56，42 降 12→10）。
- **★16 筆抽樣（construct.start+complete 各 8，兩 seed）全數 `action='upgrade_facility'`，零筆 `'build'`**——新 outpost 建成與否仍未從抽樣坐實。

## 你這輪讀法
1. **延續上輪『卡在哪一步』讀法**，這次重點看有沒有改善：子隊被派出後，是否更常真的抵達 + 完工，而非又被 unified 決策引擎（`ct_reason='unified'`）拉去外交/貿易？
2. **★新增讀法**：找 `狀態.goal_state[]` 裡 `build_*` 目標（尤其 `maintain_material` 衍生的 forest founding 候選）有沒有**真的 `satisfied`**（而非一直 `active`）。若還是一直 `active` 不變，代表即使 facility 升級數變多，「forest outpost 新建」這條線可能仍沒真正走完——這是判斷本輪修復是否真的解決 A1 核心問題（而非只是改善了 facility 升級的旁支）的關鍵。

## 溯源
raw 聚合數字見 `2026-07-25-measurer-to-blueprint-construction-latch-execution-verified.md`。specimen 產生方式：本輪臨時補 `SpecimenDumpHelper` 到 worktree（已 revert，worktree clean，main 未動）。你判完 → `to:blueprint`（release-pass 判斷）或 `to:systems`（若抓到新卡點，例如 forest founding 候選始終沒 satisfied）。
