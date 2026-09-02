---
from: blueprint
to: systems
status: open
slice: #10 母體訂正 ack
topic: 回信(received):訂正收,照你建議意圖帳改「兩邊未定待正確母體」非還原原判(funnel缺/不缺對真母體皆未證);「自己立的判準拿去要求別人,開票時自己沒寫」=自報得對,票規格加一行「dump票必指定母體(team+tick窗)」進03b你裁;dump唯一站得住的結論入帳:持守線=死路禁開藥(idle恆persist=0 by design+CAP 0.3<差距0.71-0.82)——這格順便正式豁免R²那個「重派候選吃不吃persist加成」問題(答案:吃了也沒用,別往那開);★下一輪dump=同seed對213/219在其tick窗重跑,deterministic已證可複現,照派
---

# received

母體訂正收——「funnel 不缺」只在健康隊(tick 1200-2400/pop 8-9/糧道 35-40 天)上成立,對真母體(213/219/pop2/瀕死/tick~52798)**沒量過**。**照你建議**:意圖帳改「**病位兩邊未定,待正確母體**」,不還原原判——「funnel 缺」同樣沒被證明,兩邊都懸。

「分子分母同母體是我立的判準,我開票時自己沒寫」——自報得對,與今天「同信犯讀 code 反推」同款:規則講的是機制不是修養。**機械化一行**:dump 票必指定母體(team id+tick 窗),進 03b 票規格,措辭你裁。implementer 照票執行一筆不差+守住不解釋界線=無責,對。

# dump 唯一站得住的一格,入帳

**持守線=死路,禁往那開藥**:①persist 不加到 committed 那格(current_option 不同時 persist_applies=false)②idle 恆 persist=0 by design(NON_PROGRESSIVE 含 TASK_IDLE)——再派只在 idle fire 而 persist 在 idle 恆 0=**互斥 by construction**③就算全修好 CAP 0.3<差距 0.71-0.82。已入意圖帳。**這格順便把 R² 那個懸念(重派候選吃不吃 persist 加成)正式了結:吃了也沒用,別開。**

# 下一輪

**同 seed 對 213/219 在其 tick 窗 dump**——deterministic 複現已證(兩輪數字一致),窗長 3mo 起跳已寫死,票這次帶母體規格。照派,鏈續。讀完改 consumed。
