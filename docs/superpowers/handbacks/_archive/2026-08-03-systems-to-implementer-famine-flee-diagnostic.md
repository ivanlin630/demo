---
from: systems
to: implementer
status: consumed
topic: "[饑荒-flee sanity診斷(blueprint②併§5,measure-first別下修結論只交真值):§5居民pop10→2餓死runway0為何沒求生逃?已知§5 dump居民task多為覓食(survival food-seek有fire)卻仍餓死→discriminator=覓食為何救不了·tap餓死居民(PRODUCE隊綁據點)runway→0全程:①每cadence rank_survival選哪option?(覓食/買糧/FLEE/掠奪/併入,SURVIVAL_OPTION_SET)②覓食真yield食嗎?(COLLECT_RATE×local tile food resource;local outpost格是否food-barren=採不到)③居民曾relocate嗎?(FLEE/移到food-rich格)還是結構性pin在outpost格(綁據點只採腳下貧瘠格從不搬)④買糧試了嗎?被啥擋?(options:246需錢+聽過food賣單has_buyable_food;food=0沒coin沒heard sell→買糧not-applicable?)⑤對照:同饑荒下mobile非resident隊有FLEE/relocate、此resident有沒?·discriminate:(a)resident結構pin(覓食只local barren從不relocate)=綁據點bug/(b)全做了但糧全域缺=supply root·bed復用§5-integration或jia_distribute_diag(有餓居民);純觀測tap零行為變;落地docs/measurements→我讀定root·別下修結論"
branch: feat/famine-flee-diag
---

# 饑荒-flee sanity 診斷（blueprint ② 併§5，measure-first）

**問**：§5 居民 pop10→2、food=0、runway=0 **餓死**——為何沒求生逃/求生 seek 活下來？§5 dump 顯居民 task 多為**覓食**（survival food-seek **有 fire**）卻仍餓死 → **discriminator＝覓食為何救不了**。

## tap 餓死居民（PRODUCE 隊綁據點）runway→0 全程
1. **每 cadence `rank_survival` 選哪 option?**（覓食/買糧/FLEE/掠奪/併入＝`SURVIVAL_OPTION_SET`；食→0 時 `SURVIVAL_BOOST_MAX=2.5` 碾壓，該全在秤）。
2. **覓食真 yield 食嗎?**（`COLLECT_RATE × local tile food resource`）——**local outpost 格是否 food-barren**（採不到=覓食空轉）？
3. **居民曾 relocate 嗎?**（FLEE / 移到 food-rich 格）還是**結構性 pin 在 outpost 格**（綁據點只採腳下貧瘠格、從不搬）？
4. **買糧試了嗎? 被啥擋?**（`options:246` 需錢 + 聽過 food 賣單 `has_buyable_food`；food=0 沒 coin 沒 heard sell → 買糧 not-applicable？）。
5. **★對照**：同饑荒下 **mobile 非 resident 隊**有 FLEE/relocate、**此 resident 有沒**？（blueprint 假設：綁據點不跑、mobile 有此隊沒）。

## discriminate（★三讀法、measure 定；blueprint guardrail：逃不逃=人格非死常數）
**關鍵先分「FLEE/relocate candidate 有無生成」**（補丁閘/決策層 vs 人格選擇）：
- **(a) FLEE/relocate candidate 從沒生成**（rank_survival 裡根本沒 FLEE option、或 not-applicable for PRODUCE 綁據點隊）＝**bug**（結構 pin、居民無法遷徙求生、mobile 隊有此隊沒）。
- **(c) FLEE candidate 有生成、但輸 argmax 給人格一致的撐-choice**（覓食/駐守/固執 hold）＝**可能人格真選擇撐（罕見合理、非 bug）**。**須報**：leader 人格（勇氣/固執/求生欲）+ 勝出 option 的 util vs FLEE util——**是否 personality-consistent**（高固執/低求生欲→撐死合理；若低固執卻不逃=可疑）。
- **(b) 全做了（覓食/買糧/FLEE 都 fire、也 relocate 過）但仍死**＝**supply root**（food-rich 格也採光、全域糧不足、非行為 bug）。

★守 blueprint guardrail：**別預設餓死=bug**（可能是人格選擇撐死=合理湧現）；但**也別放過「決策根本沒生成」**（=真 bug 補丁閘）。measure 定候選生成 vs argmax（[[feedback_patch_gate_first]] execution-stall 家族：candidate 生成?→argmax?→人格是否一致）。

## 交付
- bed 復用 `§5-integration` 或 `jia_distribute_diag`（有餓居民那個）；**純觀測 tap、零行為變**。
- 落地 `docs/measurements/` → 我讀定 root。**★別下修結論、只交真值 + (a)/(b) 判別數據。** 卡 → 報 `to:systems`。

（背景：此診斷是 info-as-decisions arc 第一刀「餓村莊決定求援」的前置 sanity——先確認餓死不是既有求生機制的簡單 bug，再談求援信使決策。HOLD 任何 fix build，只診斷。）
