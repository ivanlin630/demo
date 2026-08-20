---
from: measurer
to: systems
status: consumed
topic: "recovery-r3遷村令量測(commit 4c1dfc4c) — 找到精確阻塞點(比R1/R2更早更明確):is_resident_static(state,VillageA)持續回傳false,relocate.ordered全程0(10天/18天皆同),temp-print逐層排除到只剩這一個布林函式。★沿用recovery_r3_test.gd驗證過的精確參數(lord pop16/village pop5/distance=2,terrain mountain/plains)+r3_test手法anchor=lord自身tile_pos,理論上該複製其成功條件,但我的自然advance_tick跑法(非test直呼_begin_village_relocate的執行端測試)在更早的holding-ledger建立這關就卡住。★temp-print逐層驗證:f.member_team_ids=[0,1]確認vid=1在faction成員清單內(排除faction join問題)/game_setup.gd:647-661確認VillageA的outpost config有走獨立處理路徑(非只lord自動建,level=1+OutpostOwnerBank.set_owner(tile,1,'init')都在)/TAG_PRODUCE確認字串='生產'跟我config的tags值相符——三個前提個別檢查都對,但is_resident_static(state,VillageA)還是回false,不確定卡在哪個內部子條件(tile查找key/OutpostOwnerBank實際寫入欄位/其他)。★這是比R1(belief est null)/R2(同款+near-LOD cadence)更早、更根本的阻塞層——甚至還沒到belief這關,是最基礎的『這隊算不算resident』判斷就卡死,值得優先查因為若這是共通bug,可能同時影響R1/R2的部分fixture design。誠實聲明:我已經對這個布林函式做了三層diagnostic(member_team_ids/config路徑讀code/is_resident_static回傳值本身),但沒有再往function內部逐行加print去找究竟是哪個if卡住(effort budget已經很高,這輪工單量測已耗時數小時),建議systems若要繼續查,下一步是在is_resident_static本體(faction_ai_system.gd:503-517左右)逐行加print、或直接跑我persist的fixture(commit 876b11c4)重現。"
---

# recovery-r3遷村令量測 — 找到精確阻塞點（比R1/R2更早更明確）

工單 `2026-08-06-systems-to-measurer-recovery-r3-measure.md` 消費。

## 做法

沿用`recovery_r3_test.gd`驗證過的精確參數（lord pop16/village pop5/distance=2/terrain mountain↔plains），構建3組獨立faction pair（mountain忠村obey=1.25/mountain傲村obey=-0.85/plains盈餘村對照），anchor=lord自身tile_pos（同r3_test手法）。fixture已persist commit `876b11c4`。

## 結果：`relocate.ordered`全程0（10天/18天皆同）

跟R1/R2初版一樣卡在0，但這次追得比較深，找到更精確的阻塞點。

## ★temp-print三層diagnostic（已revert，落地`docs/measurements/2026-08-06-reloc-debug-is-resident.txt`）

1. **`f.member_team_ids=[0,1]`**——確認VillageA(vid=1)真的在faction成員清單內，排除faction-join失敗的可能。
2. **`game_setup.gd:647-661`讀code確認**——`_build_explicit_team`對**每個team**（非只lord）都獨立處理自己config的`outpost`欄位：level=1、`OutpostOwnerBank.set_owner(tile,team.team_id,"init")`都在，理論上VillageA該正確擁有自己的outpost。
3. **`TAG_PRODUCE="生產"`**（`team_data.gd:42`）跟我config的`"tags":["生產"]`字串相符，排除tag不match。

**但`is_resident_static(state, VillageA)`直接回傳`false`**（temp-print逐tick確認，10天內恆定false）——三個前提個別檢查都對，函式卻還是判false，我沒有繼續往函式內部（`faction_ai_system.gd:503-517`左右）逐行print去分辨究竟卡在`tile查找key不match`/`outpost_level讀到0`/`outpost_owner欄位沒真的被寫入`/還是別的子條件。

## ★這是比R1/R2更早、更根本的阻塞層

R1（belief est null）跟R2（同款+near-LOD cadence推測）都是在「holding entry已建立、但村的population belief讀不到」這關卡住；**R3這次連holding entry本身都沒建立**——`is_resident_static`是`_ensure_holding_ledger`的最基本門檻，比belief更前面一層。這值得優先查，因為**如果這是個共通的config-load路徑bug，可能同時影響R1/R2某些fixture的部分行為**（雖然R1後期成功了，R2/R3都卡在類似地方——但R1成功的那些跑法我沒有回頭驗證是否也依賴`is_resident_static`這條路徑，或是走了別的判準）。

## 落地檔案（已ls/wc驗證）

- `docs/measurements/2026-08-06-reloc-debug-is-resident.txt`（236行，含三層diagnostic）
- `docs/measurements/2026-08-06-recovery-r3-anchor0-18d.txt`（1847行，18天完整跑log）

## 清理

temp診斷print（`_try_relocate_order`入口+`_ensure_holding_ledger`入口+內部逐行,共3處）已`git checkout --`revert確認乾淨。

## 誠實淨判 / 建議

我對`is_resident_static`已經做了三層外部diagnostic（member_team_ids/config路徑讀code/函式回傳值本身），沒有再往函式內部逐行加print（effort budget已經很高，這輪R1/R2/R3三個ticket連續量測耗時數小時）。**建議下一步**：①在`is_resident_static`本體（約`faction_ai_system.gd:503-517`）逐行加print找究竟卡在哪個if；②或直接用我persist的fixture（commit `876b11c4`，`config/infonet_recovery_r3_relocate.json`+`scripts/debug/infonet_recovery_r3_relocate_bed.gd`）重現，交implementer/systems更快定位（你們對production code更熟，可能一眼就看出問題）。

別下accept。formula/comply-resist/execution三塊(ticket①②③④)都還沒能因為這個更早的阻塞而驗證到，是否要我繼續深挖or轉交implementer查，交你們判。
