---
from: implementer
to: measurer
status: consumed
topic: "[measure·★emergence 敏感·8 config] god-view Slice B 創世②③知識+relay-discovery → feat/godview-b@23989506。★8 explicit config 逐判(靠開局全知的→omniscient_discovery:true[測 fixture 顯式全知] vs 補 belief[測真實情境],slice2 教訓別盲設全知掩蓋真 gap)+emergence 兩-channel discovery 曲線(vision+relay)+doom-delta seed1337/42/4201。TDD 12/12、headless 0new、gate 64、determinism seed1337 2mo byte-identical(md5 1693db37)、game_sim_multi 無崩。"
---
# Hand Back: god-view Slice B（創世②③知識 + relay-discovery）

承 dispatch `2026-07-20-systems-to-implementer-godview-B-dispatch.md`（R² v2 CLEAN）。★measure 敏感（emergence，8 config）。

## 實作摘要
branch `feat/godview-b@23989506`（off local main 703fa6e8；★禁 origin 落後~55）已 push（★過 installed pre-push 兩閘）。
- **創世知識（game_setup:569-599）**：all-pairs 全知 → **② 同 faction 互 discovered / ③ 本地鄰居(proximity≤`CREATION_KNOW_RADIUS`=3 TEST VALUE,≥VISION_RADIUS) / ③ 淵源(parent 若 config 有)**。窄例外 `omniscient_discovery` config flag（**default false**）→ true 保 all-pairs。
- **relay-discovery（message_system:239 _exchange_intel）**：record_claim 前，receiver 聽說未識 tgt → 連帶 discover（belief entry 由 record_claim 建）。含 distorted（lie claim 也 discover：team 真存在只 details 失真）。→ **discovery 兩-channel：①vision ②relay**。

## 我的驗證
- **TDD** `godview_b_test` **12/12 PASS**（RED→GREEN；★還原→5 FAIL[遠 diff-faction 隊全知 discovered / relay 不 discover]，證 load-bearing）。①②同 faction ②③本地鄰居+遠隊不 ③omniscient flag ④default 非全知 ⑤relay-discovery ⑥distorted relay 也 discover。
- **headless** `=== DONE ===`，3 fail = **baseline 0 new**（headless_test 不依賴 config all-pairs；8 explicit config 由別的 bed 用→見下你域）。
- **game_sim_multi sanity**：無 SCRIPT ERROR / 無崩。
- **constitution_gate** PASS **sites=64 removed=0**。
- **determinism** seed1337 2mo 2 跑 **byte-identical，md5 `1693db37`**。

## ★★請你逐判（spec 明列，別盲設全知掩蓋真 gap）
**8 explicit config**（demo/econ_bed/game_sim_test/merchant/survival_start/tyrant/warzone/world_sim）+ 其 bed（game_sim_test.gd/econ_bed/world_sim/game_sim_multi…）——**這些是你域（headless_test 不碰）**。跑起來若某 fixture/bed 依賴開局全知（初識/外交/威脅假設全 discovered）而卡：
- **omniscient_discovery:true**（判定=該測純機制、顯式要全知，非測真實情境）
- vs **補 belief/relay setup**（判定=測真實遊戲情境，該讓 discovery 經 vision/relay 長出）
- **逐個判，別盲設全知**（slice2 fixture 教訓：盲設全知掩蓋真 gap）。config flag 我已備（default false）。

## ★measure（emergence 敏感）
創世知識縮（全知→②③）→ 開局知較少 → 初識/外交/威脅靠 belief 傳播漸長。**驗 emergence 仍運作非崩**：
- **before/after doom-delta**（seed1337/42/4201）：真隊存亡不崩（開局不全知=更真實冷啟動非災難）。
- **★emergence 兩-channel discovery 曲線**：初期 discovery 隊逐漸認識彼此經 vision + **relay**（新 channel）；外交/貿易/威脅觸發不因開局不全知而卡死（情報網 message/relay 撐得起遠識——★驗 relay-discovery 真讓遠隊經聽說進 awareness）。
- **★跨-faction 預盟軟化**：舊全知下跨-faction 預盟現被 relay-discovery 軟化，per-config 查即可。
- **逐 config sanity**：8 explicit config bed 跑不崩。
- 你用 `godot --path .worktrees/godview-b` 跑（★禁原地 checkout）。

## 連動風險
- **開局 discovery 縮**（全知→②③）=預期修（冷啟動更真實）。判準=emergence 仍長（vision+relay 撐遠識）+ doom-delta 不崩 + 8 config sanity。
- relay-discovery 讓遠隊經聽說進 awareness=情報網兩-channel 兌現，非 regression。

## out-of-scope
C（市場 belief-gate+store）/1119 = 後。率/延遲/失真完整情報網 = defer（資訊操控維度另軌）。

## 完成判定
task 完成 = systems + reviewer 判，非自判。你量完（emergence + 8 config 逐判）→ .qa.json/餵 blueprint 或 pre-merge to:systems。我 hold warm 等裁決。
