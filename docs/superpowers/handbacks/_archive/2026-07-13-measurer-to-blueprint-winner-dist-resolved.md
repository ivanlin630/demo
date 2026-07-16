---
from: measurer
to: blueprint
status: consumed
topic: [矛盾已解+新疑點] 71/22/7%可重現非誤;比對檔錯(v7.txt是另一支跑法);但查到util argmax疑不一致,建議升systems先於復活①②
---

# 矛盾解開 + 一個新疑點

## 結論：71/22/7% 是對的，比較對象錯了

**重跑同 seed(1337)/同 bed(`single_team_trace_bed.gd`)/main HEAD**，結果跟我原信一字不差重現：

```
[Specimen] 做什麼(winner_opt 分布): { "覓食": 83, "紮營": 1, "生產": 26, "買糧": 271 }
```

271+83+26+1=381，跟原信一致。**數字沒錯、沒過期。**

`main_story_trace_v7.txt` 對不上的原因：那份檔**完全沒有 `[Specimen]`/`[SpecimenTracer]` tag**——它不是這支 bed 的輸出，是另一支腳本（含 `[SoloAI]`/`[Order]`/`[Famine]` 全隊混雜格式）跑出來的另一次模擬。裡面的「Team7」是那次跑法自己的世界狀態，跟這支 bed 選出的「Team7」不是同一組人（bed 有自己的 pass1 候選演算法選代表隊，跟另一支腳本的隊伍編號未必對應同一支隊）。**拿兩份不同跑法的 log 互相對——比較對象本身就錯，不是任何一邊數字錯。**

## ★意外查到一個更值得關注的疑點

尾端多筆 winner=買糧，但同一筆印出的 candidates 顯示**覓食 util 比買糧高**：
```
tick=21240 winner=買糧 task=貿易 tgt=(12,3) | candidates: 覓食=0.87 買糧=0.58 生產=0.29 ...
```
理論上 argmax 該選 util 最高的覓食，但連續 67 天（271 筆）都選買糧，**覓食始終印得比買糧高卻從未被選中**——非單次噪音，是穩定現象。可能原因：candidates 印出的 util 跟最終排序依據不是同一份（例如 coeff_pressed 或 dispatch-fallthrough 在印出後才調整排序），也可能是真的邏輯不一致。**我沒定位根因**（那是 systems 的活），只確認「現象存在、可重現」。

## 附：4 隊 90 天日記（+Team7）

見 `docs/process/verdicts/winner-dist-contradiction-resolved.measure.json` `team_diaries` 欄。摘要：
- **Team7**：day0-22 覓食 → day22-23 生產 → **day23-90 買糧鎖死67天**（配合上面疑點看）。
- **Team5/Team9**：貿易(囤貨)⟷建設 規律大塊交替，週期性雙模，非病態。
- **Team10**：覓食/建設/逃跑/買糧/紮營/攻擊 交錯，day89 餓死+滅團——危機期多路徑反應（非卡死），但結局是死亡。
- **Team12**：建設為主 + 一段38筆連續逃跑（危機期）+ 少量貿易。

## 建議
Team5/9/12 型態健康（週期多模）。**Team7 的「買糧67天不變+util倒掛」是否算病態，我判不了**——這牽涉 argmax/dispatch 邏輯是否真如預期運作，屬 systems 診斷範疇。**建議先升 systems 查這個 util 疑點，再決定①②要不要復活**——如果 argmax 真的挑錯，Team7 這 71% 買糧本身就是 bug 產物，established/重評頻率的裁定基礎會需要重新看待。
