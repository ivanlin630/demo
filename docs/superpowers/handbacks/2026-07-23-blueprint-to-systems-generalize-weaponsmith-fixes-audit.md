---
from: blueprint
to: systems
status: consumed
topic: "[用戶點破·武器坊挖到的洞邏輯上該影響所有設施類型·求盤點今天每個fix是通用機制(自動適用全設施)還是weaponsmith專屬補丁,專屬的要檢查其他設施有沒有同款洞]用戶問得對:afford門檻算不到頂/需求沒轉買單/生產不看市場/設施蓋不出來,這些洞的機制層面沒理由只影響武器坊,邏輯上該影響所有設施類型(smeltery/armorsmith/mint/stable/apothecary等)。求你盤點今天每個fix的通用度:①material need-generation(facility慾望→need)是通用耦合還是weaponsmith專屬?②buy-material動作是parameterized buy-resource(通用)還是硬寫死material?③produce_need demand-responsive修法(terms.gd)是通用formula還是只套用在特定資源/設施?④weaponsmith cost 80→70明確是weaponsmith專屬(afford×1.5全域不能動,這個我知道是narrow)——其他設施有沒有同款『天花板差一點過不了』的問題,要不要逐一查?⑤workshop-build稀少(根=food security下游)這個已經確認是通用的(不限武器坊)。★請求:通用的fix標記confirmed-general免重查;專屬的(尤其④)列出還有哪些設施可能有同款洞,決定要不要主動逐一查還是等各自資源鏈自然浮現時再修(別過早large-scope調查,但至少要有意識這些洞可能還藏在別的設施裡)。"
---

# 用戶點破：武器坊挖到的洞該檢查是否影響所有設施

## 為何要查
今天在武器坊這條線挖到的機制層面問題（afford 門檻算不到頂、需求沒轉成買單、生產不看市場需求、設施本身蓋不出來）——這些洞的**機制層面**沒有理由只影響武器坊，邏輯上該影響所有設施類型（smeltery/armorsmith/mint/stable/apothecary 等）。

## 求盤點今天每個 fix 的通用度
1. **material need-generation**（facility 慾望→material need，means-end 耦合）——是通用機制（任何設施的慾望都能驅動它自己的資源 need），還是 weaponsmith 專屬接線？
2. **buy-material 動作**——是 parameterized 的 buy-resource（通用，任何資源都能買），還是硬寫死只認 material？
3. **produce_need demand-responsive 修法**（`terms.gd`）——是通用 formula（所有生產任務都吃 belief-demand），還是只套用在特定資源/設施類型？
4. **weaponsmith cost 80→70**——這個我知道明確是 weaponsmith 專屬（全域 ×1.5 不能動，只降了這一個設施的成本）。**其他設施有沒有同款「天花板差一點過不了」的問題**？
5. **workshop-build 稀少**（根=food security 下游）——這個已經確認是通用的（不限武器坊），不用重查。

## 求動作
通用的 fix 標記 confirmed-general，不用重查。專屬的（尤其 ④）列出還有哪些設施可能有同款洞——不用現在就開一個大範圍逐一查的調查（避免過早 large-scope），但至少要有意識這些洞可能還藏在別的設施裡，等它們的資源鏈自然浮現問題時，你會知道「這可能是同一個家族」而不是又重新診斷一次。

## 溯源
用戶追問「武器坊的問題應該是所有設施也會遇到的」。
