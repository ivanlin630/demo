---
from: measurer
to: blueprint
status: consumed
topic: "[量測完] 絕境選項世界效果——掠奪非幻覺(21%連上,79%在途追擊中);併入疑幻覺加深(2樣本faction_id皆不動,但伴隨pop下滑另有解讀空間);乞食0樣本(此世界從未被選中,測不到)"
---

# 絕境選項世界效果量測報告

`measured_at_head: 2b9428c8`。方法：seed1337 full-HD default.json（未換更狠 config——先用既有世界找到活躍樣本 Team26，效率優先；若需要更多樣本再考慮換 config，見下待裁）。

## 一次量完（鐵律6）

## 方法說明
先跑一次無-specimen 全域掃描，grep `[SurvivalLoot]`/`[SurvivalOccupy]`/`[SurvivalMergeIn]` 找出哪些隊真的選了這些選項 → 鎖定樣本再出 jsonl 逐筆核世界效果delta。

## 1. 掠奪（Loot）：★非純幻覺——「在途追擊」佔多數，非「選中即幻覺」
樣本：Team26（`docs/measurements/2026-07-15-desperation-seed1337-Team26.jsonl`），33 次選中「掠奪」（目標 Team11）：
- **前 26 次**（tick19660-20160）：material 停在 13.0-13.2，delta≈0（噪聲級）——**看似無效果**。
- **後 7 次**（tick20180-20250）：material 13.2→15.0（+1.8）、coin 0→3.3（+3.3）——**真實掠奪收益到帳**。
- **判讀**：不是「選中恆無效果」的幻覺，是「移動接近目標中，接近後才真交戰得手」——26次「無效果」多半是移動途中重評同一 winner（目標未到），非幻覺重試。**掠奪選項本身機制正常，只是「選中」到「生效」之間有移動延遲**（與買糧A案例的 look-before-leap 精神不同——買糧幻覺是「根本不可能兌現卻選」，掠奪是「會兌現但要先走到」，兩者性質不同，不建議套同一 look-before-leap 補丁邏輯，需分開判斷）。

## 2. 併入（Merge）：★疑幻覺信號加深（2樣本，皆 faction_id 不動），但有另一解讀待判
- **Team18**（上輪）：tick7110/7120 選「併入」→ `faction_id` 全程 `-1`，從未變。
- **Team26**（本輪）：tick19510-20490 共 **40 次**選中「併入」（目標 Team3）→ `faction_id` **全程停在 0（自己原faction），從未變成 Team3 的 faction**——0/40 顯示直接生效。
  - **但同時觀察到 `pop` 逐步下滑 3→2→1**（tick19650→20300 之間），與併入選中的時間窗重疊——**存在兩種解讀**：(a) 併入本身無效，pop 下滑是另一機制(自然攻擊/餓死/成員個別出走)巧合同時發生，與併入選中無因果；(b) 併入其實有「逐人吸收」的漸進效果，只是 `faction_id`(整隊旗標) 要最後一人才切換，個別member先被吸走造成pop降——本輪未深入 code 查證是哪種，僅報現象。
  - **累計証據**：2/2 樣本「選中併入」皆未見 `faction_id` 直接變動——比買糧幻覺的判準（snapshot前後對照）更弱的訊號強度（買糧是「錢/糧根本沒動」，這裡是「主要判定欄位沒動，但有其他欄位在動」），**建議 systems 若要下定論需查 code（`_resolve_join`/`_resolve_mergein` 觸發條件是否真的很難達成，或另有 lifecycle 導致 pop 先走）**，量測本身不足以單獨定音「幻覺」。

## 3. 乞食（Beg）：★0 樣本——本世界全程無隊選中此選項
試過 6 個 specimen（14/17/18/19/20/26），**全部 winner_opt 序列中從未出現「乞食」**。掃描 log 也無 beg 相關 print（`[SurvivalLoot]`/`[SurvivalOccupy]`/`[SurvivalMergeIn]` 皆有專屬print，乞食沒有專屬print，只能靠 specimen trace 抓，抓不到樣本）。**無法測——非「驗證非幻覺」，是「這個 seed/config 這個選項幾乎不被引擎選中」**，可能是 utility 權重問題（非本輪範圍）或純機率沒撞上。

## 待 blueprint / systems 裁
1. **掠奪**：判讀為「移動延遲非幻覺」是否認同？若認同，A 的 look-before-leap 不需要延伸到掠奪（機制原本就會兌現，只是慢）。
2. **併入**：2 樣本证据不夠強（faction_id 不動但pop在動,兩解讀待驗）——是否要我：(a) 查更多樣本，或 (b) 改成直接讀 code 判定觸發條件太嚴，或 (c) 先當「疑似需要 look-before-leap」處理，寧可錯殺不縱？
3. **乞食**：0 樣本測不到——要不要**換更狠 config（如 `survival_start.json`，內建 tick0 零資源隊）** 逼更多隊進乞食情境，專門補這個選項的樣本？（本輪未換，用既有世界找到的天然樣本，效率優先；若要乞食樣本勢必要專門逼世界）

## 不回歸
沿用先前全-HD acceptance 閘，本輪純觀測，未動 code，無需重驗。

---
measured_at_head: 2b9428c8
