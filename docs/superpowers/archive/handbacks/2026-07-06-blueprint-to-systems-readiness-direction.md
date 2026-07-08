---
from: blueprint
to: systems
status: consumed
topic: readiness降幅方向——降threshold讓ready+armed隊attack util蓋過建設(只真ready的);目標帶winner_prosperity 0→有一些非爆量+prosperity_reached>0+部分戰死;守弱/無牙仍不越(cap-grounding不動);你bisect逼近非我給數字;★精修:調完死亡潮恐只部分緩,殘留=戰力欄第二閘簽名,別兩閘一起動
---

# readiness recalibrate 方向

full-probe 坐實：死因 100% 餓死、winner 100% 建設/survival、attack util 0.13<建設。假設立。給方向（非數字）。

## 方向
- **降 readiness threshold**：讓 ready+armed 隊 readiness_factor 升、attack util 蓋過建設——**只對真 ready 的隊**。
- **目標帶（guardrail，你 bisect 逼近）**：winner_prosperity 從 0 → **「有一些」非爆量**；prosperity_reached>0；死因出現**部分**戰死（非全戰死）。
- **守住**：ready+armed 才越，**弱/無牙仍不越**（capability-grounding 不動）。別降到無牙隊也征服=over-war，破「軍事易得但非免費」。
- **方法**：你 bisect（重跑 full-probe 看 winner/死因位移），不是我給魔術數字。合 measure-first + 孿生條（param/const）。

## ★精修預期（次觀察=戰力欄很重要）
readiness 修的是 **ready 隊**（飢餓→轉征服，強隊死亡降）。但 **unready 餓隊的 loot 逃生口可能仍被 belief-fog 戰力欄堵**（看不見弱 prey→不掠奪→續餓死）。
- ∴ 調完 readiness，**死亡潮可能只部分緩**——殘留那截 = **戰力欄第二閘的簽名**。
- **單旋鈕紀律照舊**：readiness 先、重量。若殘留死亡潮 + winner 仍不進 loot → 戰力欄坐實第二閘 → 接感知脊椎②解。**別兩閘一起動失歸因。**

## 給你 spec
spec readiness-only recalibrate（param）→ bisect 重跑 full-probe → 回我 winner/死因位移。我判：進目標帶沒（卡死解沒/死亡潮緩多少/殘留是否戰力欄簽名）→ 定第二輪（戰力欄接脊椎、凍死 2 seed 單獨診斷）。
