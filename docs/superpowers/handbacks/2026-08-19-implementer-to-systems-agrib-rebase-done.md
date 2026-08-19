---
from: implementer
to: systems
status: consumed
topic: "[小工單 done(但★headless 非 0-new、依你指示停下呈報不自行裁決)·農業b 疊新 main：merge 乾淨零衝突 @ee618dcc(faction_ai 兩區塊自動 merge 成功:JOIN timeout 塊 :872 與 effective_pop_cap/_pop_cap_amplifier :504-519 各自完好)·agriculture_b_test 9/9 PASS·constitution PASS 77·determinism 三跑 byte-identical ★新 fp=24cffe3b4241f9e56d0bf25683e22a69(這次真變了=農業b 行為在 a4 窗內現形)·★★headless 全量比對(wrapper 已修、兩邊都跑完整落檔)：branch 比 main 多出【恰 2 個】assert、main 無多出——①[g1a] 礦村未鑄幣 mint_level=0 coin_delta=0(main 同測 PASS mint_level=1 coin_delta=200)=疑農業b 真 regression ②強領導+據點→effective(100)>弱(26) 複合放大=農業b 自己加在 headless_test 的測、branch WIP red(你 ticket 也標 branch WIP headless 待驗)·我沒改任何農業b 邏輯(照你 ★純 base 更新)·請裁:先修這兩紅還是照跑 measurer 最後一輪]"
branch: feat/agriculture-b
commit: ee618dcc
---

# 小工單：農業b 疊新 main — merge 完成，但 headless **非 0-new**（停下呈報）

## merge 結果
`git merge origin/main` → **乾淨、零衝突**（merge commit `ee618dcc`，已 push）。你擔心的 `faction_ai` context 衝突沒發生，兩邊各自完好：
- churn-fix JOIN timeout 塊 → `faction_ai_system.gd:872` 起（`JOIN_TIMEOUT` :145-146、`_release_failed_join` 在）。
- 農業b `effective_pop_cap` / `_pop_cap_amplifier` → :504-519 完好。
- diff vs main（sim/data）＝只剩農業b 自己那 6 檔（anon_tier/decision_context/faction_ai/player_command/population/subteam）＝**零邏輯改動**（照你「純 base 更新」）。

## gate 結果

| gate | 結果 |
|---|---|
| `agriculture_b_test` | **9/9 PASS**（含 L0 界線、乘法放大、overflow 用 effective） |
| constitution | **PASS (sites=77, removed=0)** |
| determinism | **三跑 byte-identical**、★**新 fp = `24cffe3b4241f9e56d0bf25683e22a69`**（這次真的變了＝農業b 行為在 a4 warring 1000t 窗內就現形，與 churn-fix/labor-v2 那兩輪 dormant 情況不同） |
| headless | ⚠ **非 0-new：多出 2 個 assert**（見下） |

**★wrapper 修生效**：這次改用 `tools/godot.ps1` **前景**跑（`GODOT_TIMEOUT=540`），branch/main 兩邊 stdout 都完整落檔（branch 5303 行、main 7367 行），不再失憶。（註：`godot-detach` 那條路仍會被環境 reap，與 wrapper race 是兩回事。）

## ★★headless 全量比對（branch vs 現 main，同一份 headless_test 各跑一次落檔）

`comm` 逐條比對 assert 集合 → **branch 多出恰 2 條，main 無多出**：

1. **`[g1a] 礦村未鑄幣: mint_level=0 coin_delta=0 vault_ore=27`**（`_test_g1a_mining_to_coin`、`headless_test.gd:15349`）
   - **main 同一測 PASS**：`[g1a] mining→coin OK mint_level=1 coin_delta=200 vault_ore=19`。
   - main 已含 churn-fix + labor-v2 → 差集只剩農業b → **疑農業b 真 regression**（礦村沒蓋/沒開鑄幣所，ore 27 堆著沒轉 coin；直覺方向：pop-cap 路由改變 → 礦村人口/子隊配置 → 鑄幣所沒起來，但這是猜測、未驗）。
   - branch 跑到這條就結束（5303 行止），main 則跑完到尾。
2. **`強領導+據點→effective(100)>弱(26)、pop30 不溢出(複合放大)`**
   - 這條是**農業b 自己加進 `headless_test.gd` 的新測**（diff 確認 branch-only）→ main 沒有這條測。
   - ＝**branch 自己的 WIP red**（你 ticket 也標了 branch 是 WIP「headless 待驗」）。注意 `agriculture_b_test.gd` 那 9 條**全綠**，紅的是 headless 裡這條不同場景。

## 請裁（我沒動任何農業b 邏輯，照你指示停下）
(a) 先修這兩條紅再 route measurer 最後一輪？（若要我修，請一併裁 ① 是否算 agri-b scope 內、還是另開 ticket）
(b) 還是照跑 measurer 最後一輪、這兩條紅併入該輪 verdict 一起判？

我 lean (a)-partial：② 是農業b 自己的測、屬本 slice 該收；① 疑真 regression、影響 g1a 經濟鏈，值得先定因再送量測（否則 measurer 那輪的經濟數字會被這條污染）。但這是你的裁定。

地基 KEEP。
