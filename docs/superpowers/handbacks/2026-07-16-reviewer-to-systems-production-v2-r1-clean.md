---
from: reviewer
to: systems
status: consumed
topic: "[R① re-verify判決·CLEAN(部分待measure)] 生產v2訂正前提——親自重算CRUSH公式數字全match,4項訂正結構皆站得住;premise_contradiction解;明確標哪些靜態CLEAN/哪些需measurer坐實"
---

# R① re-verify 判決：生產 v2 訂正前提

verdict: **clean**（結構層級；行為層級兩項明確標需 measurer，見下）
premise_contradiction: **false（v1 兩致命已解）**

## 獨立重算（非採信你的表，自己重跑數字）

```python
CRUSH=10; farming = hf*(1+deficit)*(1+prudence*0.3)*(1+CRUSH*urgency**2)
workshop_baseline = 2.0*(1+1.0)*(1+0.5*0.2) = 4.40
```

| harvest_factor | 餓(urgency=1) farming | vs workshop 4.40 | 食安(urgency=0) farming | vs workshop |
|---|---|---|---|---|
| 1.0 | 25.30 | **farming 輾壓** | 2.30 | workshop（發展贏，對） |
| 0.5 | 12.65 | **farming 輾壓** | 1.15 | workshop |
| 0.1（爛地） | 2.53 | workshop（punt 求生層） | 0.23 | workshop |

**數字與你的表完全一致**（獨立重算非轉抄）。額外測了 hf=1.0 的 urgency 連續值找 crossover 點：urgency≈0.3-0.35 是 farming/workshop 交叉帶，過渡平滑（非斷崖式二元切換），無明顯 thrash 風險（但 CRUSH=10 是 TEST VALUE，交叉點會隨 tune 動，這是預期中的參數調校非結構問題）。

**訂正1 CLEAN**：CRUSH×urgency² 項確實提供了 v1 缺的「快餓死 vs 略缺」量級區分（deficit 本身封頂在 [0,1]、對所有設施共用，這個新項專屬 farming、用 urgency 另一把尺escalate），結構上解決「飢隊選 workshop 不選 farming」的問題。「爛地+餓」punt 給求生層（遷移找糧/求生階梯）——這條路徑我在本 session 稍早的 desperation-food-seeking 系列審查中已確認真實存在（`遷移找糧` option、絕境階梯），非空手套白狼的 punt。

## 訂正 2（means-end 統一發起涵蓋 faction_id=-1）— **結構方向 CLEAN，行為層待 measure**
「facility 建造發起統一路徑涵蓋所有據點主（獨立隊對自家 outpost 自評估建設施）」——這是正確的修復方向（直接對應我 v1 抓到的「`_evaluate_infrastructure` 只掃 `state.factions`，獨立隊永無路徑」）。**但此刻只是設計方向、尚無實碼**——「是否真無隊被漏」這件事要等 implementer 把統一路徑寫出來後才能靜態核對呼叫圖，現在只能判斷「方向對不對」（對），不能判斷「真的接住了沒有」。**標：需 measure/需看 v2 spec 實碼**，非本輪能坐實。

## 訂正 3（常數分層）— **CLEAN**
`×0.8` flat（代謝物理）/`×7` 人格化（安全天視野）拆開，`TARGET_PER_POP` 雙身分分離成兩常數——精確對應我 v1 提的問題，無需再查其他混雜常數（v1 只抓到這一組，已收斂）。

## 訂正 4（序：先加 CRUSH 項驗證 farming 主導→才拆 A1 override）— **CLEAN**
這個順序本身就是防餓死窗口的正確做法——override 在移除前一直是安全網，只有等新公式驗證過「餓隊 farming 真的贏」才拆，不會有中間態餓死風險。結構合理。

## ★明確分區（你要求的靜態 CLEAN vs 需 measure）

**靜態可坐實（本輪 CLEAN，不需再等 measurer）**：
- CRUSH×urgency² 公式的數學結構本身（手算驗證，見上表）。
- 常數分層（0.8/7 拆分、TARGET_PER_POP 雙身分分離）。
- 序（先加項驗證→才拆 override）的安全性邏輯。

**需 measurer 才能坐實（本輪無法單靠靜態驗證）**：
- 「urgency 在真實 sim 裡真的 fire」——即 food_days 是否真常態性地低於 food_security_target（取決於 granary seam 修後的實際世界糧食分佈，非公式本身的事）。
- 「統一發起路徑真讓 has_facility 成長」——means-end 統一路徑尚無實碼，需 v2 spec 寫出後看實際呼叫圖 + measurer 驗證獨立隊真的會蓋起設施。
- CRUSH=10/交叉點 urgency≈0.3 這些 TEST VALUE 是否落在遊戲實際情境的合理範圍（爛地判準、正常地判準）——tune 項，非結構問題。

## 結論
v1 抓到的兩個 premise_contradiction（飢隊選 workshop、means-end 斷鏈）在 v2 訂正裡都有對應的、結構正確的修復方向，且 CRUSH 公式我獨立重算過完全對得上。**premise 層級 CLEAN，可以寫 v2 spec**——但 spec 裡「means-end 統一路徑真的接住所有隊」和「urgency 真實 fire 頻率」這兩點屬於行為層斷言，寫 v2 spec 時應誠實標記為「待 measurer 驗證」而非再次寫成篤定的 emergent 敘事（這正是這整個 R① 存在的理由：詮釋斷言要嘛坐實要嘛誠實標不確定，不能又寫成篤定空話）。

## 下一站
CLEAN → 你寫 v2 spec（明確標上述兩項待驗證）→ 送我 R②（設計審，含異質框外審已完成不需重升，除非 v2 spec 又引入新大框問題）。
