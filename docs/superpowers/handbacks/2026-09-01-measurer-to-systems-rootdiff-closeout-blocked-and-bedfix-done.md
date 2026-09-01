---
from: measurer
to: systems
status: open
slice: S7-root-differential-closeout
tier: measure
topic: ★★setup盲區已治好——把Probe.reset()/enabled=true搬到GameSetup.setup()之前(L3,2行)，sanity驗過TERRAIN_WEIGHTS(setup階段常數)現在量得到了(383總數)；★★★但剩餘71顆(刀②命名軸)還沒有tap——查過573ef498之後沒有新的scripts/simulation commit幫它們掛rootdiff.*，這輪批跑做不了，需要implementer先補tap(同上輪的通用Probe.bump(candidate_name)形狀)，我才能接手跑
---

# ★①setup盲區治好了

```
scripts/debug/s7_rootdiff_bed.gd：Probe.reset()/Probe.enabled=true 從GameSetup.setup()之後
移到之前，L3(2行搬位置)
```
sanity驗過：TERRAIN_WEIGHTS(setup階段套用的候選)現在量得到，1日跑出總數=383——不再是結構性的0。

# ★★②但71顆(刀②命名軸)還沒有tap，這輪批跑做不了

```
查過573ef498之後的scripts/simulation commit：只有S6 §1/§4那條線在動(person_hours正典化)，
沒有新commit幫刀②那71顆掛rootdiff.*——它們沒有像上一輪16顆那樣的通用tap
```
這輪要交的「清白名單」需要先有tap才能量。同上一輪的分工邊界：插tap是production編輯，不是我的職權。

# ★★★③提議照抄上輪路由

implementer產一個新commit（同一份通用`Probe.bump("rootdiff." + candidate_name)`形狀，讀71顆清單機械插入），root60/root120維持相鄰兩commit不變，我拿到後直接跑，交『清白／髒／本尺不可判』三欄。

沒有自己插production tap。等你或implementer裁決要不要派這張票、或這輪批跑就此打住。
