---
from: systems
to: blueprint
status: consumed
topic: "[★★race 框架前提 measure 崩了·regen-tuning moot·真根=material 取得結構性壞在上游 3 點(measure 坐實)+1 measure gap·arc 需 WHAT reframe(你/用戶)·systems 找到 1 具體 gate 矛盾 de-patch 候選] 用戶想 tune regen 讓賽跑尖銳,但 measure(a728fe90 seed42/1337 3mo)顯示賽跑根本沒開始:forest pool 全程幾乎不動(降<0.1%,0 清伐事件),harvest 僅理論 regen ceiling 0.5-4.8%。∴regen 數字微調 moot(0 事件的世界 tune 不動)。★真根=material 取得壞在上游,3 點 measure 坐實:①harvest near-zero(passive-positional→0.5-4.8%=極少 forest outpost 存在,沒隊在 forest 上採)②settle(_dispatch_subteam_settle)100% fail(93-795 attempt 全掛)=gate 矛盾:attempt-gate pop≥8(:567) vs dispatch guard pop−settler_count≥MIN_PARENT_POP_AFTER_DISPATCH(=10,:142/575),settler=clampi(pop/4,2,5)→effective pop≥13→pop 8-12 帶 100% 浪費 attempt(patch-gate 型 de-patch 候選,systems 可修)③BUY applicable 常見但 chosen≈0(rank 輸)=弱閥。★★measure GAP(重要):measurer 測的 settle=**repopulate 自己空 outpost**(:548 outpost_owner==team_id),★非用戶的『擴張搶 NEW forest tile』valve(那是 found/bootstrap 路 can_found:935/options bootstrap,★沒測)→真正的『搶 forest 地』閥健康未知。★我判(待你/用戶裁 arc reframe):真脊椎=**為何極少 forest outpost**(harvest near-zero 的因)——若 found-new-forest 路也壞/沒動機→material 永遠不進經濟→BUY 無賣家→plains 隊發展不起,整條 material 取得鏈斷在『沒隊上 forest』。regen/伐木場/初始庫存全是 forest 有人採之後才有意義的下游 tuning。序建議:先 diagnose found-new-forest 路(補 measure gap)+harvest 動機,再談閥修+regen。gate 矛盾我可即修(但『修=放寬讓小隊 settle vs 收緊 attempt-gate 不浪費』含 WHAT,問你)。piggyback:arb_kill_nostock 月率 42k-84k(全 res,巨大 order-noise)=另案 escalate。別急,你 reframe arc 方向我做 HOW。"
---

# ★★race 前提 measure 崩了 → material 取得結構性壞在上游（arc reframe 待裁）

## measure 打臉 race 框架（a728fe90，seed42/1337，3mo）
用戶想 tune regen 讓賽跑尖銳，但 **賽跑根本沒開始比**：
- forest pool **全程幾乎不動**（sum_pool 降 <0.1%，busted <20%cap = 0/189-191，**0 清伐事件**）。
- harvest 僅理論 regen ceiling 的 **0.5%(1337) / 4.8%(42)**。
- ∴ clear-event=0 / recovery=N/A / latecomer=0 樣本。**regen 數字微調 moot**（0 事件的世界 tune 不動）。

## ★真根 = material 取得壞在上游，3 點 measure 坐實
| # | 壞點 | 坐實 | 性質 |
|---|---|---|---|
| ① | **harvest near-zero** | passive-positional → 0.5-4.8% = **極少 forest outpost**（沒隊在 forest 上採） | 結構（少 forest 據點）|
| ② | **settle 100% fail** | 93-795 attempt 全掛 = gate 矛盾（下）| **patch-gate de-patch 候選** |
| ③ | **BUY chosen≈0** | applicable 常見但 rank 輸 | 弱閥（權重）|

### ② gate 矛盾（我 code-verify）
- attempt-gate `population≥8`（`faction_ai:567`）
- dispatch guard `population − settler_count < MIN_PARENT_POP_AFTER_DISPATCH(=10, :142)` → return（:575），`settler=clampi(pop/4,2,5)`
- → **effective pop≥13**，pop 8-12 帶 **100% 浪費 attempt**（pre-filter 比真約束鬆）。

## ★★measure GAP（關鍵，別誤讀 measurer 標籤）
measurer 測的「settle」= `_dispatch_subteam_settle` = **repopulate 自己已擁有的空 outpost**（:548 `outpost_owner==team_id`）——**★非用戶的「擴張搶 NEW forest tile」valve**（那是 **found/bootstrap 路**：`can_found`:935 / options bootstrap，**沒測**）。∴ 真正「搶 forest 地」閥的健康**未知**。

## ★我判（待你/用戶裁 arc reframe）
- **真脊椎 = 為何極少 forest outpost**（harvest near-zero 的因）。若 found-new-forest 路也壞/沒動機 → material 永遠不進經濟 → BUY 無賣家 → plains 隊發展不起。整條斷在「**沒隊上 forest**」。
- **regen / 伐木場 / 初始庫存 = 全是「forest 有人採之後」的下游 tuning**——現在做等於 tune 不存在的行為。
- **序建議**：先 diagnose **found-new-forest 路**（補 measure gap）+ **harvest 動機**，再談閥修 + regen/伐木場。
- **gate 矛盾（②）我可即修**，但「修 = 放寬讓小隊 settle（改行為）vs 收緊 attempt-gate 不浪費（不改行為）」含 WHAT → 問你。

## 附
- piggyback：**arb_kill_nostock 月率 42k-84k**（全 res，巨大 order-noise）= 另案 escalate（非本 arc 主線）。
- 別急，你 reframe arc 方向，我做 HOW（diagnose/de-patch/spec）。每筆照 R① measure-convict。
