---
from: systems
to: measurer
status: consumed
slice: perf-arc-slice0-baseline
tier: measure
topic: ★★★效能 arc 開了(用戶裁),而第一件不是刀是【分母】:要一條 scaling 曲線+熱點分解,否則每一刀的效果無法歸因、「50+ 隊到了沒」也回答不了(=不可達驗收);★零 code 改:config-only 隊數階梯+既有 SimRunner.phase_timing;★★每段要有分母(被走到幾次),否則「這段很慢」分不出單次慢 vs 被走很多次
---

# ★①背景一句
用戶裁定**效能 arc 即刻開**（事件比例計算五刀，目標**零 LOD、50+ 隊**）。
★**而我不打算先切刀** —— **先要分母。**

# ★★②為什麼先要曲線（★不是流程潔癖）
```
目標寫的是「50+ 隊」，而我現在不知道【現況幾隊會爆、爆在哪一段】
⇒ ①每一刀改完變快了,是這刀還是上一刀?   ②「到了沒」根本回答不了 ＝ ★不可達驗收
```
★**今天那條材料 arc 的教訓就是這個形狀**：**沒有分母的數字答不了問題。**

# ★★★③要你產的兩樣（★零 production code 改）
## (a) scaling 曲線
- ★**config-only 隊數階梯**：`config/perf_scale.json` 變體（現況 20 factions×3~5 ＋ roving 12~18 ⇒ ~72~118 隊）
  ★★**seed 固定**（現況 `1337`），只動隊數相關欄位
- **每階段報 per-tick 中位數**（★**判準沿用 `reference_hob_perf_protocol`：比 per-tick，★不撞絕對門檻** —— 機器差異會製造假 reject）
- ★★**母體用【實際生成的隊數】，不是 config 期望值** —— **兩者會差，而差多少你不報就沒人知道**

## (b) 熱點分解
- ★**用既有 `SimRunner.phase_timing`**（`sim_runner.gd:123`），**不必新增儀器**
- ★★★**每一段要有分母＝該段每 tick 被走到幾次**
  ⇒ **否則「這段很慢」分不出【單次慢】還是【被走很多次】** —— ★**而那兩者的刀完全不同**（前者優化演算法、後者剪呼叫）

# ★④跑法你決定
★**跑幾階、每階幾 tick、要不要平行 —— 那是執行細節，你自己定，不用回來問我**
（`GODOT_TIMEOUT` 那類照 `reference_hob_perf_protocol`）。
★★**唯一我要的是【形狀】**：**曲線 ＋ 分解 ＋ 每格有分母。**

# ★★⑤而有一件我特別想知道，但【不要為了它挑數字】
```
world_state.gd:25  team_discovered: Dictionary   # int team_id → Array[int]
★production 讀者：**55 處、15 個檔**（★**訂正 2026-08-26：原寫 48／13 是錯的**）
    `grep -rno "team_discovered" scripts/simulation/ | wc -l`  → 55
    `grep -rl  "team_discovered" scripts/simulation/ | wc -l`  → 15
  （★**未排除任何檔**；含 `scripts/data/world_state.gd` 定義處則為 60／16）
```
★★★**N² 的成本不是「它存在」，是【誰在每 tick 走它】。**
⇒ ★**若分解能指出「這 48 個讀者裡，實際吃掉時間的是哪幾個」，那會直接決定第三刀怎麼切。**
★★**但這是我想要的答案，不是你要證明的結論** —— **照原樣回報，包含「分解不到那個粒度」也是有效答案。**

# ★落地
★**請標 exact path**（`docs/measurements/…` ＋ `docs/process/verdicts/….measure.json`），
★★**別寫「在我手上」** —— **今天有三次那樣的交接卡住下游。**
