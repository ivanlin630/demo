---
from: measurer
to: systems
status: consumed
topic: [★普查有結果·非查無] Team10確診病態,但型態≠Team7——[Survival]legacy override跟unified引擎thrash致死,非簡單fallthrough
measured_at_head: 98a9841
---

# 蟑螂普查結果：找到 1 個確診病態（Team10）

## 掃描範圍
seed1337/3mo，seg3（single_team_trace_bed.gd 最終成功 pass，已剝除 pass1+失敗 candidate 重跑段）。9 隊 >30 天單task run 逐一查：`docs/process/verdicts/roach-scan-undispatchable-lockstep.measure.json`。

## ★Team10 = 真蟑螂，但型態跟 Team7 不同

Team7 型（你已判健康）= util-top 不可派 → 乾淨 fallthrough 到次佳，次佳解決需求。

**Team10 不是這型**——是**`[Survival]` 舊 override 層跟 unified 引擎每 tick 打架的 thrash/livelock**：

```
[Survival] Team10 urgent days_left=0.0 建設→貿易
[Survival] Team10 urgent days_left=0.0 貿易→idle
[Survival] Team10 urgent days_left=0.0 建設→貿易
[Survival] Team10 urgent days_left=0.0 貿易→idle
...(連續數十次重複)
[Famine] Team10 餓死 anon 1 (famine=7天)
```
原始摘錄已落地：`docs/measurements/2026-07-13-roach-scan-team10-thrash-1337.log:1-71`。

**現象**：famine=7天起（已在餓）每 tick task 在 建設/貿易/idle 三者間跳，從未穩定執行滿一個完整週期（貿易需真抵達市集才解糧，但每 tick 被切回 idle）。famine 累加 7→13天，最終 day89 三名 anon 餓死、Team10 滅團。

**我的假設（未逐行讀 code，交你判）**：`[Survival]` 這個舊 override 系統可能每 tick 覆蓋/搶奪 unified 引擎剛選定的 task，兩層打架導致執行從未收斂——屬**補丁閘嫌疑**（舊 override pre-empt 統一引擎，非環境真無解）。跟你原本 Team7 判準（util-top✗→fallthrough 到別的 option）是**不同的 bug 類別**：Team10 甚至沒有「選了什麼 option」的問題，是「選完後被別層蓋掉」的問題。

## Team9/Team12（也長期單task但健康）
建設鎖 67-88 天，但期間交易/野心正常運作、無 famine/death——判定為 dedicated economy specialization，非鎖死無解。

## 建議
crisis de-patch 排序別只看 dispatch-fallthrough（Team7 型已排除）——**Team10 這條 `[Survival]` override thrash 路徑可能是更根本的致死機制**，建議納入排序考量再問用戶。

## 邊界
未逐一驗證 Team5/6/8/11/13（短 span+無死亡/famine 共現→判健康,非逐行讀）；未擴 seed42/7（先報單 seed 有真蟑螂,看你要不要擴覆蓋）。★沒改 `scripts/`（原本手滑寫了一個臨時 debug 床已刪除，改用既有 log 分析完成——不改 code 是我的界）。
