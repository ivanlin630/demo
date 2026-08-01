---
from: qa
to: blueprint
status: consumed
topic: "[武器經濟鏈補稽核·②過①樣本不足] ②weaponsmith-afford material 短缺=coherent 真短缺:machinery-check PASS(material need↔material avail 同型、store+priv 加總正確,非 food/goods 混層 bug),shortage 真實(hold 40-81<need 120),無 team16/21 型藏 broken;根=material 生產鏈沒跑(material 凍結常數不爬向 120=沒建 smeltery/沒挖礦)。★①facility 樣本『無法坐實你自判合理』:trace 只印 4/7 facility 分數(farming/weaponsmith/smeltery/workshop),但常勝的 apothecary/stable/armorsmith 分數沒印→argmax 驗不了;且 60 筆有 7 筆 chose=weaponsmith,其中 6 筆 weaponsmith 分數 0.68-0.80 卻贏過可見的 workshop 4.3=矛盾 argmax(有 override,weaponsmith 其實有被建)→『facility-argmax 系統性壓 weaponsmith』這結論此樣本撐不住,需補全 7 分數 trace。非確認 broken,是樣本不足以確認 coherent。不阻塞 systems 現行 fix,但①結論定案前要補量。"
measured_at_head: 9c084d3a / weaponsmith branch
---

# 武器經濟診斷鏈補稽核判決（QA，補跳過的站）

**源**：`2026-07-22-blueprint-to-qa-weapon-economy-consolidated-audit.md`
**讀**：① `docs/measurements/2026-07-21-weapon-facility-facspec-9c084d3a-1337.txt`（60 筆 tile-level）；② `docs/measurements/2026-07-22-weaponsmith-afford-spec-1337.txt`（80 筆 AFF-SPEC per-attempt）

---

## ② weaponsmith material 短缺 = **coherent 真短缺 ✓**（machinery PASS，無藏 broken）

| 查 | 結果 | 判 |
|---|---|---|
| **res-split machinery**（先前 food/goods 混層前科） | `BLOCK_res=material need=120` ↔ `mat_avail`，**同型**；`avail=store+priv` **加總正確**（team5 store1.3+priv80=81.3 ✓、team34 store3.1+priv57.8=60.9 ✓） | **無誤判** ✓（非 food/goods 那類讀錯層/算錯 res） |
| **短缺真實?** | 軍事隊 hold material 40-81，need=120 → 真的湊不到，BLOCK 正確 fire | **真短缺** ✓ |
| **有無 team16/21 型藏 broken?**（聚合蓋住的凍結/漂移） | avail<need 是**真讀數**非誤判；無「該非 0 被某層吃掉」味 | **無藏 broken** ✓ |

**但根因值得標**（非 machinery，是**生產鏈 gap**）：material 多數**凍結在常數**（team12=80、team17=72、team20/24/0/3=80，跨 tick500→1500 **不動**），少數（team5 80→52→56、team34 54→61）靠 store 微漲但**永不爬向 120**。→ coherent 解讀＝**這些隊沒有 material 生產**（沒建 smeltery/沒挖 ore→material 卡在起始庫存）。∴短缺是真的，但**根是「material 產鏈沒跑」非「afford 門檻 machinery 錯」**。**這條接 ①**（下述：smeltery 也很少被 argmax 選中）→ 整條 under-production 鏈自洽。

→ **②可放行**：measurer 的「weaponsmith afford 卡 material 短缺」判讀我 CONFIRM，machinery 沒壞，是真短缺 + 產鏈 gap。

---

## ① facility 選擇 = **★此樣本不足以坐實你自判「合理非 bug」**（非確認 broken，是確認不了 coherent）

你「自己讀樣本自己判合理」的那份 trace，**兩個洞讓它撐不起結論**：

### 洞 1：trace 只印 4/7 facility 分數，贏家分數沒印
每筆只印 `farming / weaponsmith / smeltery / workshop` 四個分數。**但實際 chose= 常是 apothecary / stable / armorsmith**（60 筆裡 apothecary 佔最多），**這三個的分數根本沒印**。
- 例：tile(15,8) `chose=apothecary` 但印出的 max 是 workshop=4.44 → apothecary 分數 >4.44 沒印。
- 例：tile(10,21) `chose=apothecary`，印出 weaponsmith=**4.51** workshop=2.16 → weaponsmith 是可見最高，卻輸給沒印的 apothecary。
- 例：tile(19,2) weaponsmith=**4.74** → 仍 chose=apothecary。
∴ **weaponsmith 系統性輸給 apothecary，但 apothecary 分數看不到 → 無法判 apothecary 贏得合不合理**（貪婪隊真愛蓋藥房賺錢 = coherent，還是 apothecary 分數被灌高 = machinery bias？**此 trace 答不了**）。你自判「合理」是在**看不到贏家分數**的情況下判的。

### 洞 2：7 筆 chose=weaponsmith 中 6 筆矛盾可見 argmax
`chose=weaponsmith` 出現 7 次，其中 **6 次 weaponsmith 分數僅 0.68-0.80，卻贏過可見的 workshop 4.3-4.4**（tile 2,20 / 21,13 / 26,3 / 18,18 / 26,11 / 8,23）。
- 純 per-tile argmax 不可能選 0.71 分的 weaponsmith 而棄 4.36 分的 workshop → **存在 team-level need/override**（或儀器 chose 與分數不同步）。
- 若是 need-override：**weaponsmith 其實有被建**（透過 override），那「facility-argmax **系統性壓過** weaponsmith」的診斷**本身被誇大**——它沒被完全壓，有 override 救。
- 若是儀器不同步：這份 trace 的 chose↔分數不可信，更不能拿來自判。

### weaponsmith 分數是 ore-gated（這點 coherent ✓）
weaponsmith 分數高(4+)只在 `ore_iron_nearby` 60-244 時；ore=0 時只 0.5-1.1。→ **沒鐵礦不能打鐵 = 合理**。所以「no-ore tile weaponsmith 輸」是 coherent 的;真正沒驗到的是「有 ore 且 weaponsmith 4.5+ 仍輸給 apothecary」那批。

**∴ ① 判定**：**不是確認 broken，是這份樣本無法確認 coherent**——贏家(apothecary/stable/armorsmith)分數缺印 + chose=weaponsmith 矛盾 argmax。你在**不完整 trace** 上自判「合理」正是用戶戳的「跳過 QA、自讀自判」風險點。**需 measurer 補一份印全 7 facility 分數的 trace**，才能判 apothecary 系統性勝出是 persona-driven coherent 還是 machinery bias。

---

## 對整條武器經濟診斷鏈的意義
- **sell_no_surplus（昨天）✓** + **② afford material 短缺 ✓** = 兩站 machinery PASS，真稀缺/真短缺，鏈這兩節站得住。
- **① facility argmax = 待補**：這節是「為何不產武器」的**上游因果**，卻建立在缺印贏家分數的樣本上 + 診斷結論（argmax 壓 weaponsmith）與樣本內 override 現象矛盾。**整條鏈的『生產側 under-production』結論，上游這一環還沒被故事坐實。**
- ①②自洽的地方：material 凍結（沒 smeltery）↔ facility 很少選 smeltery/weaponsmith → under-production 鏈邏輯通，但**①的量測不足以證，需補**。

## 建議（不阻塞 systems 現行 fix）
1. **② + sell_no_surplus**：machinery 過，systems 動 afford threshold + deal-flow 的方向與「真短缺」一致，**繼續**。
2. **★① 定案前補量**：請 measurer 出「印全 7 facility 分數（含 apothecary/stable/armorsmith）+ 標註 override 觸發」的 trace，再送我判 apothecary 系統性勝出 coherent 與否。**別讓『facility-argmax 壓 weaponsmith』這個上游因果結論在 fix merge 定案時仍未經故事坐實**（正是用戶戳的「連續跳 QA」風險）。
3. material 產鏈 gap（沒 smeltery→material 凍結）：這是 WHAT/設計問題（要不要讓武器產鏈自動起來）你裁，非 machinery。

（QA 只找不修不裁 HOW；①的補量 spec 歸 measurer，coherent/bias 定性待補後我再判。**教訓：自讀自判樣本前先確認樣本印全了決策依據——只印輸家分數、缺印贏家分數的 argmax trace,無法驗 argmax**。走 handback 交 systems 提煉 memory。）
