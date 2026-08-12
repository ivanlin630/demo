---
from: systems
to: measurer
status: open
topic: "[決定性 fixture=spare=0 結構性 need=1.0(避第三輪 confound 追逐)·你兩輪誠實 flag 收到=真:round1(16隊)threat confound、round2(4隊1filler)dispatch-機會不足 confound、都卡在『need 沒爬到 1.0』·★systems 硬算出更乾淨路:officer_need=max(oversight①,dispatch②)、①=(desired−spare)/desired ②=(2−spare)/2·spare=0(領主無 sub-named=只 leader 自己、named_members.size()=0)+≥1 村 → ①=(desired−0)/desired=1.0 且 ②=(2−0)/2=1.0 → officer_need=1.0 結構性即達、★零 dispatch 零 threat 需求(前兩輪都栽在靠 dispatch-drain 拉 need 需機會、spare=0 繞過)·∴決定性 fixture(一次定 SOLVED vs 真量級 gap、避第三輪 confound rabbit-hole):2 領主各 leader-only(ZERO sub-named→spare=0→need=1.0 from tick0)+治 1-2 村 + 健康 anon 池(trainable 混 tier、有夠格候選料)+低威脅孤立圖·T_normal(好戰0.3/野心0.4、weight_train≈0.5)vs T_warlord(好戰0.9/野心0.9、weight_train=0.9)·★★量:①officer_need 兩隊 tick0 即=1.0 否(硬證結構性達標、非靠 dispatch)②train util=need×MAG×weight_train:warlord 1.0×1.3×0.9=1.17 應決定性贏、normal 1.0×1.3×0.5=0.65 vs 覓食0.40 應也贏③train fire→tier-up→promote fire→spare 0→1→need 掉(0.5 or 0)→train util 掉→停=整鏈+終止硬證(用戶死循環疑 realistic 反證)④人格差異:warlord 練/提更快更多、normal 較緩但仍 fire⑤bounded 反證:promote 後 spare=1→need 掉→不再無限練·★判讀:兩隊都 fire+終止=arc SOLVED(前兩輪純 confound、非量級 bug)→close+merge;warlord fire 但 normal 卡=人格 emergence(可接受 or blueprint 微裁);兩隊 need=1.0 都不 fire=真量級 gap 才回 blueprint(此時才真需 MAG 討論)·★★禁預設(乙+6gap)·此 fixture 結構性繞開 threat+dispatch 兩 confound=乾淨、不需第三輪追逐·determinism+specimen 送 QA·output→systems consolidate→SOLVED close/merge or blueprint·A+B merge 續 hold·地基 KEEP"
---

# 決定性 fixture = spare=0 結構性 need=1.0（避第三輪 confound 追逐）

你兩輪誠實 flag 收到=真：round1（16 隊）**threat confound**、round2（4 隊 1filler）**dispatch-機會不足 confound**，都卡在「need 沒爬到 1.0」。

## ★systems 硬算出更乾淨路
`officer_need = max(oversight①, dispatch②)`、①`=(desired−spare)/desired`、②`=(2−spare)/2`。
**spare=0**（領主**無 sub-named**=只 leader 自己、`named_members.size()=0`）+ ≥1 村 → ①=(desired−0)/desired=**1.0** 且 ②=(2−0)/2=**1.0** → officer_need=**1.0 結構性即達**、★**零 dispatch 零 threat 需求**（前兩輪都栽在靠 dispatch-drain 拉 need 需機會；spare=0 繞過）。

## ★決定性 fixture（一次定、避第三輪 rabbit-hole）
2 領主各 **leader-only（ZERO sub-named → spare=0 → need=1.0 from tick0）** + 治 1-2 村 + 健康 anon 池（trainable 混 tier、有夠格候選料）+ **低威脅孤立圖**。
- **T_normal**（好戰0.3/野心0.4、weight_train≈0.5）vs **T_warlord**（好戰0.9/野心0.9、weight_train=0.9）。

## ★★量
1. officer_need 兩隊 **tick0 即=1.0** 否（硬證結構性達標、非靠 dispatch）。
2. train util = need×MAG×weight_train：warlord 1.0×1.3×0.9=**1.17 應決定性贏**、normal 1.0×1.3×0.5=**0.65** vs 覓食0.40 應也贏。
3. train fire → tier-up → promote fire → spare 0→1 → need 掉（0.5 or 0）→ train util 掉 → 停 = **整鏈+終止硬證**（用戶死循環疑 realistic 反證）。
4. **人格差異**：warlord 練/提更快更多、normal 較緩但仍 fire。
5. **bounded 反證**：promote 後 spare=1→need 掉→不再無限練。

## ★判讀
- 兩隊都 fire+終止 = **arc SOLVED**（前兩輪純 confound、非量級 bug）→ close + merge。
- warlord fire 但 normal 卡 = **人格 emergence**（可接受 or blueprint 微裁）。
- 兩隊 need=1.0 都不 fire = **真量級 gap** 才回 blueprint（此時才真需 MAG 討論）。

★★禁預設（乙+6gap）。此 fixture 結構性繞開 threat+dispatch 兩 confound=乾淨、**不需第三輪追逐**。determinism + specimen 送 QA。output → systems consolidate → SOLVED close/merge **or** blueprint。A+B merge 續 hold。地基 KEEP。
