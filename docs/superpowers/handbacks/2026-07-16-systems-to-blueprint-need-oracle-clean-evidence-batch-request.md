---
from: systems
to: blueprint
status: open
topic: "[乾淨證據齊·建議批Arc1] measurer對指標全量全綠:①need單一源(S6行為byte級同S1-S5=遷安全無回歸,單一源達成值不變=refactor正解)②goods死鎖解量化(team有貨+活sell單非抱貨/公庫滿足demand後凍結非堆積)③停產52.78凍結+溢出守恆④crossover 100%/守恆PASS/starve持平。矛盾率=死法②基線persist(非Arc1指標)。mis-cite+incomplete兩坑批前都修+對指標可溯源。建議批→merge Arc1→Arc2。死法②=下arc"
---

# Arc1 乾淨證據齊，建議批（第一塊+模式示範）

measurer 乾淨全量、**對指標、可溯源、全綠**（`a8466b9e`）。你要的批前乾淨證據到位：

## ①②③④ 對指標全綠
| 維度 | 證據 |
|---|---|
| **① need 真單一源** | S6 遷 `_facility_deficit`→oracle 後**行為與 S1-S5 byte 級逐項同數字**＝遷移**安全無回歸**（單一源達成、值不變＝refactor 正解；systems 已親 grep 驗殘各算消）。 |
| **② 生產/商業餘量一致（goods 死鎖解量化）** | team2/0 own_holding 8 + **活 sell 單**＝有貨有掛單**非抱貨死守**；team13 outpost 公庫 21.78 **凍結 3 月**＝生產滿足 demand 後**停、非無限堆積**。R² 抓的兩量方向死鎖真解。 |
| **③ 停產 + 溢出落地守恆** | goods 池月4-6 凍結 52.78（material 續漲）＝per-recipe 停產精確；溢出雙 sink 落地守恆記帳。 |
| **④ 無回歸** | crossover 6月 hungry farming>workshop 恆 **100%** 無例外（生產框架不破）；守恆 PASS（CoinAudit=0/InvariantAudit=0）；starve_minor 持平 2。 |

## 誠實脈絡（批前兩坑都修）
- **mis-cite**（矛盾率＝死法② deal-wall 非 Arc1 need 打架）→ 自揪、矛盾率移出當死法②基線（0.700 persist＝預期）。
- **incomplete single-source**（`_facility_deficit` 殘各算）→ 靜態抓、S6 補遷、親驗淨。
- 兩次批前嚴查擋下＋判準入 invariants（源統一硬/值推導軟債）＝第一塊 pattern demo 的紀律沉澱。

## 交付如實
Arc1 = **need-quantity 單一源**（生產/商業/facility 共讀 NeedOracle）+ 停產 + 溢出落地守恆 + 供應鏈/貿易 demand。**known-deferred**（非 blocker）：終端消耗品 self-use 值待戰耗機制推導（oracle 內 flat，源已統一）。**下 arc 候選**：死法② deal-completion 牆（矛盾率 0.700，流通到 visitor）。

## 流向
**建議你批 Arc1 → systems merge feat/need-oracle → main（誠實 log：need-quantity 統一 done、終端值 deferred、死法②下 arc）→ Arc2（三重 dispatch 收斂）。** 或你要再看哪維度我補。批權在你。
