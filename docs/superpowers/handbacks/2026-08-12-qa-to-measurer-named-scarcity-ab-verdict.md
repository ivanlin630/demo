---
from: qa
to: measurer
status: consumed
topic: "[named-scarcity A+B specimen稽核verdict]①T0 util=0.0507比你想的更極端:不是『many裡挑到低點』,是T0全45個真決策記錄(181筆扣heartbeat)裡訓練candidate『只出現這一次』,tick10後直到tick10680全部44筆real-decision裡訓練連candidate都不生成(非只輸,是applicable=false整個消失)——比你的結論更強②T12 CONFIRM:13個真決策點(非只day-boundary)pop全程=4零變動,非抽樣漏看③implementer fp四次來自named_scarcity_ab_test.gd自己手動造spare=0/desired=4逼officer_need=1.0的極端unit case,兩realistic床從頭到尾沒接近這個量級(util 0.05-0.11遠低於need=1.0時的1.3),非衝突是fixture本質差異design-intended"
---

# named-scarcity A+B 前後對照 specimen 稽核 verdict

## 1）T0 util=0.0507 是否具代表性

**比你原本想的更極端，而且是更強版本的同一個結論**。我掃了 T0 全部 181 筆 specimen 記錄，扣掉 `phase:heartbeat`（無決策的空轉 tick）後剩 45 筆真決策記錄——**訓練這個 candidate 在這 45 筆裡只出現了一次，就是你抽到的 tick10 那筆（util=0.0507）**。tick10 之後到 tick10680（跨 44 筆真決策、涵蓋 day31-44 左右）**訓練連 candidate 都沒生成過**，不是「持續出現但 util 低」，是**整個從候選清單裡消失**。

所以你的樣本不是「運氣差撿到低點」——它是**唯一的數據點**，代表性問題反而要反過來看：真正的故事比「util 低」更極端，是「這個選項對 T0 來說絕大多數時間根本不存在」。

讀 `8afaa64a` diff 找到可能機制：訓練的 `applicable` 閘 = `has_trainable AND (FORCE archetype OR ambient_train_drive>0)`。T0 是 FORCE archetype（跟前一輪 tier-up-chain 稽核同個設定），理論上 FORCE 分支應該讓它一直保留資格，除非 `has_trainable`（隊上是否還有可訓練的 anon）轉 false——T0 是小隊（pop 6→5），很可能訓練完/用掉僅有的可訓 anon 後池子空了。這條我讀得到現象（消失）但沒 100% 坐實成因（`has_trainable` 實際數值我這輪沒加 tap），如果要坐實建議在 `has_trainable` 計算點加個 tap。

## 2）T12 完全零變化是否為抽樣假象

**CONFIRM，不是抽樣漏看**。T12 全程只有 13 筆真決策記錄（60 筆扣 heartbeat），**這 13 筆逐筆核對，`pop` 全部=4，沒有一筆例外**——這已經是最細的粒度（每個真決策點都查過，不是只查 day 邊界），15 天內真的一次都沒變過。

## 3）跟 implementer fp 的差異點

不是衝突，是 fixture 設計本來就不同量級。讀 `8afaa64a` 的 `named_scarcity_ab_test.gd`（implementer 自己的單元測試）：他們是**手動建構** `spare=0, desired=4` 這組數字去逼 `officer_need==1.0`（測試碼裡直接寫死這兩個值，不是從模擬世界長出來的狀態）——這是刻意做的極端邊界案例，用來 machine-demonstrate「officer_need 真的能推 train_drive(1.3) 贏過 build(1.11)」，不是一個真實村莊會自然走到的狀態。

你這兩個 realistic fixture（4team/diverse）裡，訓練 util 全程只在 0.05-0.11 這個量級（換算回 officer_need ≈ 0.04-0.09，離 1.0 差一個數量級），從頭到尾沒有一隊接近過那個極端值。兩邊結論並不矛盾：**機制本身正確運作（unit test 證明 need→util 這條線是通的），但一般村莊的 officer_need 天然就很難逼近 1.0**——「一般村莊幾乎不會 fire」這個結論站得住，信心程度高（不是沒測到，是兩個獨立 realistic fixture 都同向）。

---
*QA 驗收官 · 2026-08-12*
