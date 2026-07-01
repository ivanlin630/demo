# Hand Back: BEG/JOIN 死路探針（measure-first, F-I3）

> spec `2026-07-01-beg-join-deadpath-probe-design.md` / plan 同名。純觀測，零行為變。修不在此 branch。

## 實作摘要
- `scripts/simulation/interaction_system.gd`：`_try_interact` 埋 3 組 Probe counter（純 `Probe.bump`，no-op unless enabled）：
  - dispatch 點（player 分支後 → 恆 NPC-NPC）：`beg.dispatch` / `join.dispatch` = 到達核心互動的 BEG/JOIN 隊。
  - 197 combat_target 早退分支：`beg.early_return_197` / `join.arrived_no_handler`。
  - 247 BEG resolver 實呼點：`beg.resolve`（到此=NPC-NPC 實 resolve；JOIN 無 resolver，故無 `join.resolve` bump，恆 0）。
- `scripts/debug/headless_test.gd`：加 `_test_beg_join_deadpath_probe`（單元證死路：`beg.dispatch=1 early197=1 resolve=0` / `join.dispatch=1 nohandler=1 resolve=0`）。
- `scripts/debug/warring_states_seed.gd` / `econ_bed_diagnose.gd`：末尾印 beg/join probe 6 鍵。
- `scripts/debug/beg_join_probe_measure.gd`（新）：warring config + `BEG_PROBE_TICKS` 可覆寫 tick 上限的量測 harness（default 1 月 ~285s，配合 wrapper 360s）。

與 spec 差異：spec 列 dispatch 埋點「或在 dispatch 端 or `_try_interact` 入口統一觀察」。**選 `_try_interact` 單點**（spec 風險段允許，較準、免散落 dispatch 端）。故 `beg.dispatch` 語意 = **NPC-NPC 互動到達次數**（非唯一 dispatch；同隊多 tick 到達會重複計）。

## 量測數據

### JOIN — 死路 runtime 頻繁 hit（radius14 8-faction warring, 1 月, 42→104 teams）
```
join.dispatch=66  join.arrived_no_handler=4  join.resolve=0
```
- **66 次 NPC-NPC JOIN 互動，0 resolve → 100% 空轉**。
- **兩種 failure mode**：
  1. `combat_target` 仍設（4/66）→ 197 早退。
  2. `combat_target` 已清（62/66）→ 過 197 → **`_try_interact` 全程無 JOIN branch → 靜默 fall-through**。
- ⇒ JOIN **根本無 interaction handler**（不只被 197 擋）。單「移 resolver 到 197 前」修不了 JOIN——它沒有 resolver。

### BEG — prosperity 期 runtime 頻率低
```
warring 1 月：beg.dispatch=0
econ_bed 6 月：beg.dispatch=0（隔離 3-team，覓食/交易足，無乞食）
```
- warring 早期世界**成長非崩潰**（42→104 teams），無饑荒 → 無乞食 dispatch。BEG runtime 出現需 endgame 持續匱乏（radius14 2yr 全跑 >360s wrapper timeout，本 branch 未取）。
- **機制死路已由單元測證**：BEG 恆設 `combat_target=aid`（options.gd:104）→ `_try_interact:197` (`combat_target != -1: return`) **恆先於** :247 resolver → resolver 結構不可達 → 觸發時 **0% resolve 保證**。JOIN 的 197-block 子集 = 同一 gate 的實 runtime 證據。

## 死路影響級別 + 修向建議（修按此另定 spec，不在本 branch）
- **JOIN = 中**：runtime 頻繁（66/月 radius14），玩家可見「絕境隊投靠盟友→無事發生」空轉。修需 **(a) 新增 JOIN interaction resolver branch**（併隊/入 faction 邏輯），**且 (b) combat_target 語意拆**（社交/投靠 target ≠ 戰鬥 target）——否則 combat_target-set 子集仍被 197 擋。two-mode ⇒ 非單點修。
- **BEG = 低（但與 JOIN 連帶）**：resolver 已存在(:247)，僅被 197 擋死。runtime 頻率 prosperity 期近 0。修向二選一：resolver 移 197 前 / combat_target 語意拆。**因 JOIN 的 combat_target 語意修同源，建議 BEG+JOIN 合併一次修**（統一「社交 target」概念），別分兩刀。

## 連動風險
- `interaction_system.gd`：僅加 `Probe.bump`（enabled=false 時純 no-op），不改任何 branch/分支順序/state。coin_eq 守恆不動。headless 全綠（含 `投靠守恆整合(coin_eq)` test PASS）。**無已知行為風險**。
- debug seed 3 檔 + 新 measure 檔：純觀測輸出，不入生產路徑。
- **並行軌**：只碰 interaction 埋點 + probe + debug seed → 與首燒(faction_ai intent)/單寫者(coin) 檔案 disjoint，無衝突。

## 待主 session 確認
1. **是否開 BEG/JOIN 修 spec**：數據支持「JOIN 中優先、BEG 低但連帶」。建議合併修（combat_target 社交語意拆 = 共同根）。
2. `beg.dispatch` 語意 = 互動到達次數（非唯一 dispatch）：若要「唯一乞食隊數」需另在 dispatch 端埋點。目前粒度夠判死路（resolve=0 才是重點）。
3. BEG runtime 頻率若要實測，需 endgame-scarcity bed（非 prosperity warring）；成本 vs 價值請裁（機制已證死，頻率屬次要）。
