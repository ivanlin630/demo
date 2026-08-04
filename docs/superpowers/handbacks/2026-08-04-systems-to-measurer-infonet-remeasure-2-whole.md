---
from: systems
to: measurer
status: consumed
topic: "[資訊網whole RE-measure #2(Part2 dispatch-fix後,症1該通了):branch feat/info-network-whole 85edc4f6,worktree .worktrees/info-network-whole(★godot --path對branch code跑禁原地checkout)·前輪(d9550ad8 bootstrap)修好applicable但dispatch=0(小餓resident無spare named送不出);本輪(85edc4f6)=①spawn-ability gate(can_send_herald=pop≥2/can_send_scout=named≥2治seed1337 regression)②求援herald=anon 1人empty-handed信使(leader_id=-1零res carry)·★★核心驗:①help.herald_dispatched>0(小餓resident現能送anon信使,前兩輪全0)②distribute.dispatch/food_delivered>0(症1真通:distress達領主team_known→distribute fire→convoy送糧,前輪全0)③seed1337 regression消(前輪starve_anon 1→7惡化,①gate後can't-send neutral該回穩,主seed對照)④scout.dispatched(驗領主spare named假設,若領主也普遍無→標tracking未來scout亦anon)·迴歸:Part1+3不退(trade.deal/order_fulfilled/board.relay≥前輪)+人格分化保留(per-option util dump發不發=leader人格傲撐/務實早求)+economy不爆(★追蹤:anon信使無異常資源流失,母隊糧/材/coin只該少if真扣或無)+determinism byte-identical不凍雙seed·★canonical WarringHarness.run()掛specimen中性(禁手寫loop,治91vs86 artifact)+specimen trace逐motive→action→outcome餵QA故事稽核·誠實measured回systems別下accept·綠→我路QA故事稽核(回溯三因果+whole出verdict ref)→blueprint對用戶驗收"
---

# 資訊網 whole RE-measure #2（Part2 dispatch-fix 後、症1 該通了）

Part2 dispatch-fix 交付（`85edc4f6`）：①spawn-ability gate ②求援 herald=anon 1人 empty-handed 信使。**RE-measure whole**（前兩輪 herald/scout dispatch 全 0=送不出、本輪該通）。
**branch**：`feat/info-network-whole 85edc4f6`。**worktree** `.worktrees/info-network-whole`（★`godot --path` 對 branch code 跑、禁原地 checkout）。

## ★★核心驗（症1 該真通了）
1. **`help.herald_dispatched > 0`**（小餓 resident 現能送 anon 信使；前兩輪全 0=無 spare named 送不出）。
2. **`distribute.dispatch / food_delivered > 0`**（症1 真通：distress 達領主 team_known → distribute fire → convoy 送糧；前輪全 0）。
3. **seed1337 regression 消**（前輪 `starve_anon 1→7` 惡化；① gate 後 can't-send 隊 neutral、該回穩——**主 seed 對照 main vs branch**）。
4. **`scout.dispatched`**（驗領主 spare named 假設；若領主也普遍無 spare named→標 tracking、未來 scout 亦 anon 化）。

## 迴歸驗
- **Part1+3 不退**：`trade.deal / order_fulfilled / board.relay_deposit` ≥ 前輪。
- **人格分化保留**：per-option util dump（發不發=leader 人格、傲撐/務實早求；util 一字未改）。
- **economy 不爆**（★追蹤：**anon 信使無異常資源流失**——母隊糧/材/coin 只該少 if 真 pop 扣、**非 proportional-split 搬走全資源**；驗信使空手）。
- **determinism byte-identical 不凍雙 seed**。

## ★canonical harness（治 91 vs 86 artifact）
- **用 canonical `WarringHarness.run()` 掛 specimen**（`SpecimenDumpHelper.setup_from_env` 標準 hook、**禁手寫 loop**）→ 中性 specimen。
- **specimen trace 逐 motive→action→outcome**（求援信使/賑濟/relocate/peer-trade + 死因）→ 餵 **QA 故事稽核**。

## 交付
- **誠實 measured 數字回 `to:systems`**（別下 accept 結論）。escaped_defects 記。
- 綠 → 我路 **QA 故事稽核（回溯三因果 jia/famine/anomaly + whole、出 verdict ref）→ blueprint 對用戶驗收**。灰/regression → 報 `to:systems`。
