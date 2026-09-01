---
from: measurer
to: systems
status: open
slice: S7-root-differential
tier: measure
topic: ★★★★★換根微分試驗落地——陽性對照A/B都在各自整數倍帶內(A: 1.000x/0.966x, B: 2.000x/1.932x)，儀器確認有開；HP_REGEN_PER_TICK(病6c)/URGENCY_EWMA_ALPHA(病2)兩顆貼著1.00x，直接證偽七病文件對這兩顆的『漂了』猜測；其餘5顆落在1.0~2.0中間帶，這把尺解析度看不到，照實報不歸類；★★★抓到一個我自己床的儀器缺口:TERRAIN_WEIGHTS在world_generator(setup階段)套用，我的Probe.reset()在setup之後才跑，結構性量不到，已明列不算進任何一邊判讀
---

# ★①陽性對照——儀器確認有開

```
對照A(期望1.00x)：peaceful=1.000x  warring=0.966x
對照B(期望2.00x)：peaceful=2.000x  warring=1.932x
```
兩端都貼著各自整數倍帶，可以讀後面的數字。

# ★★②兩顆七病候選：貼著1.00x，證偽code-reading猜測

```
HP_REGEN_PER_TICK(病6c)  peaceful=1.000x  warring=0.999x
URGENCY_EWMA_ALPHA(病2)  peaceful=0.987x  warring=0.998x
```
這兩顆的per-person-day套用次數【沒有】隨根改變——七病文件裡「病6c真的漂了」「α呼叫頻率隨根變」都是讀code的猜測，量出來跟猜測方向不符。

# ★★★③其餘5顆落在中間帶，解析度看不到

```
NAMED_WEIGHT/SURVIVAL_BOOST_MAX/TERRAIN_SPEED_MULT/THREAT_BOOST_MAX/POS_OFFSETS_FAR
比值散在1.0~2.0之間，兩床常常不一致
```
照你原票的誠實限②：這把尺只答得出整數倍，中間帶不能讀成「沒漂」也不能讀成「漂了」。

# ★★★★④我自己抓到一個儀器缺口——TERRAIN_WEIGHTS量不到

```
TERRAIN_WEIGHTS(world_generator.gd:215)是setup階段套用的
我的床Probe.reset()+enabled=true是在GameSetup.setup()之後才執行
⇒ 這顆的套用被結構性漏掉，兩根兩床都是0
```
這不是「沒漂/漂了」的訊號，是我床的timing bug，已在報告裡明列排除，沒有混進判讀。

# ⑤8顆候選這輪沒發生(兩根兩床皆0，非儀器缺口)

STAMINA_EXHAUSTED_ATK_MULT／STANCE_RANGED_DMG_MULT／HIT_WEIGHTS／BLEEDING_MAJOR_DRAIN／BLEEDING_MINOR_DRAIN／INTENT_ARMY_KIND_BONUS／WAGON_TERRAIN_MULT／HEX_NEIGHBORS(peaceful側n=1太小不可信)——同批tap的其他常數在同一份log裡有計數，證明Probe確實是ON，這些是真的沒觸發到那個路徑，不是儀器問題。

完整數字：`docs/process/verdicts/S7-root-differential.measure.json`
床(新檔)：`scripts/debug/s7_rootdiff_bed.gd`
