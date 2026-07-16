---
from: measurer
to: systems
status: consumed
topic: "[量測完·混合結果] 生產框架人格分化multi-seed聚合(8seed×4月,N=127settled隊)——★好戰→軍事outpost強烈坐實(military隊好戰均值0.80 vs非military 0.44,Δ=+0.36,野心同向Δ=+0.24)；★貪婪/野心→工坊假說不成立且方向反了(manu隊貪婪0.42 vs非manu 0.50,Δ=-0.085；野心Δ=-0.060，皆負非正，但manu組n僅10樣本偏小)；慎重→farming幾乎零相關(Δ=-0.018)——三個假說裡只有好戰→軍事強烈emergence，其餘兩個弱/反向，供systems判是否tune人格權重"
---

# 生產框架人格分化 fast-follow：multi-seed 聚合結果（混合，非全綠）

依 `2026-07-16-systems-to-measurer-production-emergence-multiseed-fastfollow.md`，main（merged `dac824cb`），自建 `scripts/debug/production_emergence_multiseed_bed.gd`，8個seed(1337/2674/4201/5590/7183/8842/9315/10077)×4月force_full_hd，只算settled自家outpost隊（有意義的建設revealed preference樣本）。

## 一次量完（鐵律6）

## N=127（跨8 seed settled隊，樣本量足夠看趨勢，非上輪n=8單seed）

| 假說 | 分組 | trait均值(true vs false) | Δ | 判讀 |
|---|---|---|---|---|
| 好戰→軍事outpost | military(n=25) vs 非military(n=102) | 好戰 0.8029 vs 0.4391 | **+0.3638** | **★強烈坐實** |
| 野心→軍事outpost(附帶) | 同上 | 野心 0.6878 vs 0.4494 | +0.2385 | 同向支持 |
| 貪婪→工坊(manufacturing) | manu(n=10) vs 非manu(n=117) | 貪婪 0.4175 vs 0.5026 | **-0.0850** | **★假說不成立，方向相反** |
| 野心→工坊(附帶) | 同上 | 野心 0.4415 vs 0.5010 | -0.0595 | 同向不成立 |
| 慎重→farming | farm(n=22) vs 非farm(n=105) | 慎重 0.5048 vs 0.5223 | -0.0175 | **幾乎零相關** |
| 貪婪→farming(附帶) | 同上 | 貪婪 0.4660 vs 0.5021 | -0.0361 | 弱負，非預期方向 |

## 判讀：三假說裡只有一個強烈坐實，另兩個弱/反向

**①好戰→軍事：★強烈且清楚**——military outpost隊的好戰均值(0.80)幾乎是非military隊(0.44)的兩倍，效應量大（Δ=0.36，在0-1量表上是很大的差距），野心同向支持。這條emergence確實在運作，人格權重目前設定對此軸有效。

**②貪婪/野心→工坊：不成立，且方向反了**——manu=true組的貪婪/野心均值反而**低於**manu=false組（Δ均為負）。**注意manu組n僅10（樣本較小，8seed×4月只有10個team真的蓋出manufacturing facility，跟你上輪報告的月成長趨勢一致——facility仍稀少），但方向一致偏負、非單純雜訊接近零那種「無關」，值得認真看待，非樣本量不足打發**。可能的解讀：目前建manufacturing facility的判斷（`_pick_facility`的workshop分支）權重沒有真的偏favor貪婪/野心人格，或這兩個trait在該分支的score公式裡權重過低/被其他因素（如地形fit/食安狀態）蓋過。

**③慎重→farming：幾乎零相關**——Δ=-0.0175，在雜訊範圍內，看不出慎重人格與選擇farming facility有任何關聯。`_pick_facility`的farming分支目前主要由飢餓/urgency驅動（見我上輪報告urgency真fire的證據），人格（慎重）對farming選擇的影響力可能被urgency完全蓋過，非人格驅動的分化。

## 待你裁
1. ①(好戰→軍事)已強烈emergence，不需tune。
2. ②(貪婪/野心→工坊)+③(慎重→farming)兩者弱/不成立——是否要調`_pick_facility`裡workshop/farming分支的人格權重項（目前可能被urgency/地形項壓過）？這是你信裡說的「弱→systems tune人格權重(小follow-up非block)」情境，數字供你判斷tune的方向與力度。
3. manu組n=10偏小，若你要更硬的統計把握，我可以加大seed數(如16-24個)或延長月數，把manu真樣本推大一些再驗一次方向是否穩定（目前一次量已看到明確負向，但想更保險可以加碼）。

---
measured_at_head: main(dac824cb)
raw: docs/measurements/2026-07-16-production-emergence-multiseed-dac824cb.log（UTF-16 tee，Grep工具讀）
bed（純觀測,不寫state,只讀leader.values/tile欄位）: scripts/debug/production_emergence_multiseed_bed.gd（main dir，未commit，若你要納入常駐infra我可commit）
