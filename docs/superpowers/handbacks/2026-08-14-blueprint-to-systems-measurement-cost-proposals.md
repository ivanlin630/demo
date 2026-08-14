---
from: blueprint
to: systems
status: consumed
topic: "[提議(量測協議優化、owner你們裁、非workflow憲法變動):砍重複跑成本四招·背景=用戶戳『實作跑一次+量測重跑一次』雙倍時間、12mo=7h·★獨立重跑價值不砍(本月抓6+假結論=最值錢防線)、砍的是重跑成本:①fp檢查點驗證(最大招):床每月存世界fp→measurer重跑前1-2月驗fp吻合=證實作產物可信→直接分析其全程數據免重跑全程;fp不合or決策關鍵才全重跑;成本7h→幾十分鐘、獨立性保(前綴抓env/RNG汙染)②一跑餵所有人:床預設全dump(aggregate+specimen+守恆)、launch檢查表已有、免specimen式白燒一晚③checkpoint-resume(世界save/load)=基建候選:查day301終局崩該從day280快照續跑非重跑300天;同時是未來玩家存檔地基;值不值現在做=下輪排序用戶裁④平行多開detached(多seed/窗吞吐翻倍)·①②可直採(protocol層、你們owner);③掛下輪排序;④已可用·評估回我"
---

# 提議：砍重複跑成本四招（量測協議優化、你們 owner 裁）

獨立重跑價值不砍（本月抓 6+ 假結論）、砍重跑成本：
1. **fp 檢查點驗證**：床每月存世界 fp → measurer 重跑前 1-2 月驗 fp 吻合 = 證實作產物可信 → 直接分析其全程數據免重跑全程。fp 不合 or 決策關鍵才全重跑。7h→幾十分鐘、獨立性保。
2. **一跑餵所有人**：床預設全 dump（aggregate+specimen+守恆）。
3. **checkpoint-resume（世界 save/load）= 基建候選**：查 day301 崩從 day280 快照續跑;同時是未來玩家存檔地基;下輪排序用戶裁。
4. 平行多開 detached（已可用）。
①②可直採（protocol 層你們 owner）;③掛排序;評估回我。
