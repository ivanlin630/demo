---
from: measurer
to: systems
status: consumed
topic: "[sharpened指標團人手池trace完成——★中性表+改答用戶兩問(spinoff genuine否/領主有無盲派)·★★發現:領主全程零盲派(code-read5個dispatch函式全state-aware,結構找不到blind-dispatch site)·★anon池4天內(day0-4)4筆drain全部歸零後41天(day5-45)零變化零回補·★drain構成=3筆spinoff(自動世界機制,非領主決策)+1筆anon→named晉升(自動,非死亡非派出)·★意外發現:2隻spinoff團(4/5)事後merge回Team0(named身分非anon,故anon欄不顯示但workforce有回流)·★不確定環節已標記送QA specimen核(3筆spinoff觸發tick均非日邊界,code找到event_system.gd:55離峰旁路但未100%釘死)·序:轉blueprint TG推用戶,原表+我的中性解讀併送、causal細節待QA核後可再補強"
---

# 指標團(Team0)人手池 sharpened trace —— 完成

sharpened ticket（`2026-08-11-systems-to-measurer-manpower-trace-sharpened.md`）消費。改答用戶 reframe 後的兩問，非「池空了沒」。用戶要「證據非斷言」——下面先給乾淨表，我的解讀另立一段、明確標「猜測」vs「code-read 坐實」vs「待 QA 核」三種確信度。

## 表（seed8181 dispersed、Team0、45天；day0-10 逐 tick 精細掃、之後日邊界抽樣；只列有變化的行）

| tick(day) | anon池 | Δ | population | outpost_cap | 新增team(同tile) | type | 派前有無讀池(盲派check) | 原因 |
|---|---|---|---|---|---|---|---|---|
| t0（起始） | 4 | — | 5 | 20 | — | — | — | 起始值 |
| t100(d0) | 3 | −1 | 5 | 20 | Team4 | **automatic**（世界機制，領主無得選） | n/a（非領主決策不適用） | population-overflow 分村。★population(5)≤cap(20)、非日邊界tick——觸發鏈待QA核（見下） |
| t400(d1) | 2 | −1 | 5 | 20 | — | **automatic**（世界機制，非領主決策） | n/a | anon→named 晉升（named+1同tick，person_generator.gd:103）——不是死亡不是派出，是團內自己拔擢幹部 |
| t700(d2) | 1 | −1 | 4 | 20 | Team5 | **automatic**（世界機制，領主無得選） | n/a | population-overflow 分村，同上待核 |
| t1000(d4) | 0 | −1 | 4 | 20 | Team6 | **automatic**（世界機制，領主無得選） | n/a | population-overflow 分村，同上待核 |
| day5～day45（41天） | 0 | +0 | 4-5 | 20 | （別隊分村2次，tile_pos不同、非Team0自己的） | — | — | **全程零變化**。無死亡、無派出、無回補 |

**day25 附近唯一一次領主 dispatch 訊號**：`help.letter_dispatched ×2`——這是唯一一次「領主真的派人」的訊號，且發生在 anon 池早已是 0 之後（此時池空、若真派會撞 gate，但這訊號的方向未逐一核實是否真的成功派出或被 gate 擋掉，屬未深挖的旁支，不影響主線結論）。

## 改答兩問

### ①每筆 drain 歸類：deliberate vs automatic
**4 筆全部是 automatic（世界機制），零 deliberate。** 領主本人在這局 45 天裡，一次都沒有主動 dispatch 出任何 anon（herald/scout/builder/distribute/migrant 全程 0 次，除了 day25 那 2 次 letter 而那時池已空）。抽乾 Team0 人手池的，不是領主亂派人，是：
- 3 筆 population-overflow 分村（`_create_overflow_team`，population_system.gd:55）——世界機制，領主没有「不分」的選項。
- 1 筆 anon→named 晉升（`person_generator.gd:103`）——團內自己拔擢，人沒有離開 Team0，只是從 anon 桶轉去 named 桶（不算「流失」，是內部升遷）。

### ②盲派檢查：領主派子隊前有沒有讀 available-anon
**Code-read 結論（5 個 dispatch 函式全部查過，坐實非猜測）：全部 state-aware，結構上找不到 blind-dispatch site。**
- herald `_try_herald_side`（faction_ai_system.gd:2031）：`AnonTierSystem.total_pop(team)<1` 才擋，派前檔前檢查。
- scout `dispatch_anon_messenger`（subteam_system.gd:143）：同上。
- migrant `dispatch_anon_migrants`（subteam_system.gd:112）：`total_pop(parent)<k` 才擋。
- builder/convoy 共用 `SubteamSystem.dispatch()`（subteam_system.gd:53-56）：`pop_count` 被 `parent.population` 即時值（`team_data.gd:57` getter 含 anon 現值，非 stale 副本）夾死上限；就算算式給出過大 anon_to_sub，`transfer_proportional`（anon_tier_system.gd:177 `actual=mini(count,total)`）也保證永不超額轉移。

★但這輪 45 天裡領主幾乎沒真的派過人（只 day25 兩次），所以「盲派檢查」這題目前**主要是 code 層級的結構保證**，這條 trace 本身沒有太多「領主明明沒人還硬派」的真實案例可供實測驗證——如果用戶想要更硬的實測驗證（例如刻意造一個 anon=0 但 mini-util>0 的情境看會不會硬闖），需要另一輪專門構造的 probe，非本輪範圍。

## 意外發現（中性列出，非結論）
Team4、Team5 這兩隻 spinoff 團，後來各自 merge 回 Team0（log：「[Merge] Team0←Team4完全合併」×2、「[Merge] Team0←Team5完全合併」×1，都在 day1-4 之間）。**merge 回來的是 named 身分（原 spinoff 團的 leader），不是 anon**，所以我的 anon 專欄沒有顯示這幾次事件——這不是漏抓，是因為問題問的字面是「anon 池」，merge 補的是 named 席位。但如果用戶關心的是「Team0 整體人手」而非嚴格限定 anon，這幾次 merge-back 是相關脈絡：spinoff 不是純粹的單向流失，一部分後來自己走回來了。

## ★中性判斷交還用戶
- Anon 池 4 天內見底、之後 41 天零回補（無 minor_population 可長大——全程 minor_pop=0——所以「生育回補」這條路在這個 seed 這局根本沒開）——這數字本身是真的，決策不摻假。
- 但「見底」的**成因**（3筆自動分村+1筆自動晉升，全部世界機制，零領主決策）是否算 bug，還是「小村一開局就這樣、正常」——這是設計判斷，我不下結論，交用戶自己看這張表判。
- 「派前完全不查池」這個用戶最擔心的②，code-read 結果是**沒找到**——所有 dispatch 路徑都有檔前守衛。如果用戶看完覺得這結論太乾淨想要更硬的壓力測試，可以再開一輪。

## ★★唯一不確定環節（已送 QA specimen 核）
t100/t700/t1000 這三筆 spinoff 觸發的 tick 都不是日邊界（100/700/1000 均非 240 倍數）——不可能是 `check_overflow_for_team` 正規日檢路徑。Code-read 找到 `event_system.gd:55`（Succession named-successor 分支）可以離峰直呼同一函式，但我沒能在本輪時間內確認 t100 那次是否真的踩到這條路——已寫 `to:qa` 平行請 specimen 稽核，其餘欄位的因果訊號都有明確 Probe key 佐證，不受此不確定性影響。

## 落地檔案（已 git commit）
- `scripts/debug/scale_econ_manpower_trace_bed.gd`
- `docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181.json`
- `docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181-raw.txt`
- `docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181.specimen.jsonl`

序：你轉 blueprint TG 推用戶。地基 KEEP。
