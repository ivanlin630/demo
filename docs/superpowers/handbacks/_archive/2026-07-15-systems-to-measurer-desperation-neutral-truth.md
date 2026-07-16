---
from: systems
to: measurer
status: consumed
topic: "[量測·中性世界真相·release真門檻] desperation@5fcb68e3(含confound修)——thrash真消沒消?A/B/A-2真有效?觀測現非侵入,這次綠才算數"
---

# 量測：desperation 中性世界真相（release 真門檻）

confound 修已 merge 進 desperation 分支。branch `feat/desperation-food-seeking` @ **`5fcb68e3`**（A+B+A-2+confound 全在，worktree `.worktrees/desperation-food-seeking`，push）。**觀測現非侵入**（tracer 額外 path-work 包 suppress_observe_noise）。

## ★這次是真門檻（擾動世界的綠全作廢）
之前所有 A/B/A-2 驗證都在 confound 未修的擾動世界＝不可信。這次觀測中性了，**看真實世界**。

## 要驗（seed1337 force_full_hd reproducible）
1. **★confound 真除（前提，先確認）**：`SPECIMEN_TEAM_ID=A` / `=B` / 無-specimen 三跑 → 除 SpecimenTracer entries 外**世界 byte-identical**（不再 0/71/88）。這證觀測中性、後面數字才可信。
2. **★★thrash 真消沒消（核心真相）**：中性/非侵入世界，Team26（及同型）`貿易↔idle` 同-tick flip → **真的降到 ~0 了嗎**？還是中性世界 thrash 還在（你之前量到 56 次）＝之前的「修好」是觀測假象？
3. **買糧真出貨**：中性世界餓子隊 fire 買糧 → food 真入帳（`[Order] buy food`＋food 升）？（之前 Team18 tick8970 food 0.23→9.39 是擾動世界，中性重看）。
4. **併入 A-2**：試投靠被拒→cooldown 不再纏（rejection-learning 生效）？**★blueprint 疑 Team26 併入 loop 根是「目標不可達」（沒抵達→沒被拒→A-2 打不到）**——中性世界看 Team26 併入到底是「被拒後纏」（A-2 該解）還是「不可達空追」（A-2 打不到，需 A-3）。
5. **遷移找糧 B / 連貫窮死 C**：中性世界 specimen trace 給 QA 判連貫。

## 判定路徑
- thrash 中性世界真消 + 買糧真出貨 + 併入不 loop → desperation A/B/A-2 真有效 → QA 複判連貫 → blueprint 批 merge。
- thrash 中性世界還在 / 併入是 unreachable 非 rejection → **之前是觀測假象**，回報真相 → systems 重診斷（A-3 或別的真根）。

## 下游
`.specimen.jsonl`（現可信）→ QA 故事判官。headline + 真相 handback `to:blueprint`。全量一封信。

## 溯源
raw + measured_at_head `5fcb68e3`。
