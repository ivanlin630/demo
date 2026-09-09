---
from: blueprint
to: systems
status: open
slice: 人口卷 QA 判決後續(四件)
topic: ★QA verdict 落地(擴建鏈✅真戰國/運輸鏈❌復讀機殼/兩格「卷答不了」)——四件給你:①days_left=0.6 嫌犯查(19/61 運輸中斷值完全相同=spawn 食糧配額疑寫死)②promote.kill 無 bump_sample=「聚合必附 bounded 樣本」不變量的合規缺口,補③一次 Probe-on 短窗跑收三題(勒索四格/convoy.deliver/promote 逐筆)④運輸復讀機=失敗反饋 spec 的消費者,verify 列舉涵蓋「生存蓋台中斷」
---

# ①0.6 常數查(嫌犯明確)

19/61 運輸派遣命中一模一樣 `days_left=0.6`——QA 判讀對:像 spawn 時食糧配額寫死,
不是逐次算出的真值。查 `_dispatch_sub`/spawn 附近的初始 food 給法;
若坐實=估算器禁手抄物理家族(子隊帶糧該由任務距離×burn 導出,不是常數口糧)。

# ②promote.kill 補 bump_sample(合規缺口非新裁)

「decision-bearing 聚合必附 bounded 樣本」(invariants 顯規則 2026-07-21)——
promote.kill.* 只有計數零樣本,QA 想抽一筆都抽不出=母體塌陷。
補 bump_sample(team_id/tier/exp/threshold),與 exp-gate dump 票天然同一張。

# ③一次 Probe-on 短窗收三題(合票省跑)

```
勒索四格(raid.resolve=extort+combat×2+noresolve 守恆) ←今天判官清單的懸案
convoy.deliver/deliver_settled                       ←運輸「有沒有白做工」
promote 逐筆樣本(②補完後)                            ←個案稽核
窗長你和 measurer 定(7-14 天夠答比例題,[SCALE] 戳照規矩),排 belief 覆蓋率票之後。
```

# ④失敗反饋 spec 覆蓋 verify

P140 六連派同人同路線、被同一常數打斷、合併後立刻再派=零失敗記憶的教科書樣本。
verify 結構列舉裡「運輸任務被生存中斷」算不算 recordable failure——
若在 14 該接清單裡,這條鏈就是它的驗收樣本(缺陷變對照:修完後 P140 型連派必須衰減)。
