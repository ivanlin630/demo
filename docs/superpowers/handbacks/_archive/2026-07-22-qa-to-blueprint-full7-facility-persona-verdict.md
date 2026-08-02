---
from: qa
to: blueprint
status: consumed
topic: "[full-7 facility 故事判·apothecary 主導=coherent 非 machinery-bias] 補全 7 分數後決定性證據:apothecary 分數二元——22× 恰=0.00(無 herb)、其餘 4.82-5.06(herb tile)→herb 地利 gate,非全域恆膨脹(公式 bias 會處處>0)。apoth=0 從不蓋 apothecary;apoth>0 也不強制(18 案例 apoth>0 卻蓋別的)。18『反例』=coherence 證明:mil tile apothecary SKIP_notallowed→蓋 weaponsmith、civ tile stable(plains 6-7)贏 apothecary 4.9→蓋 stable=argmax 全正常。∴facility machinery HEALTHY;apothecary 40× civ 主導=herb 地利+persona 微調 driven coherent,非 bias。weaponsmith mil 12× WINS 選址正常(你撤回 argmax verdict 對)。★殘留 WHAT-note:apothecary 5.06 該不該每個 herb tile 都壓過 workshop 4.44(40×vs11×)=平衡/多樣性問題你裁,非 bug。weapon gap 定位 afford-material(Gate B)不變。"
measured_at_head: main
---

# full-7 facility argmax 故事稽核判決（QA，收尾 ① facility thread）

**源**：`2026-07-22-measurer-to-qa-full7-facility-persona.md`（補全我上輪揭的 4/7 gap）
**讀**：`docs/measurements/2026-07-22-full7-facility-spec-1337.txt`（80 案例，全 7 分數 + candidate 標註）

## 判決：facility machinery **HEALTHY**，apothecary 主導 = **coherent 非 machinery-bias** ✓

### 決定性證據：apothecary 分數是**二元**（herb 地利 gate，非全域膨脹）
apothecary 分數分佈（全 80）：**22× 恰為 `0.00`**，其餘全落 **4.82–5.06**。**中間沒有值**。
- 這就是 herb terrain gate 的 signature：**無 herb → apothecary=0.00**；**有 herb → ~5**（terrain_fit=herb 3.0 頂起來）。
- **反證 machinery-bias**：若 deficit/persona 公式讓 apothecary 全域恆高，該處處 >0；實際 22 tile 恰 0 → **不是全域膨脹，是地理 gate**。measurer 初判「地理-coherent」**CONFIRM**。

### 相關性全對（argmax 沒病）
| 情境 | chose | 判 |
|---|---|---|
| apoth=0（無 herb，22 案例的 CAND 部分） | 從不蓋 apothecary → workshop/stable/weaponsmith | ✓ 無 herb 不蓋藥坊 |
| apoth>0 且是 civ CAND 且無更高 | apothecary 40× | ✓ herb tile apothecary 5.06 > workshop 4.44 合法勝 |
| apoth>0 **卻蓋別的（18 反例）** | mil tile SKIP_notallowed→weaponsmith/armorsmith；civ tile stable(plains 6-7)>apothecary 4.9→stable | ✓ **反例正是 coherence 證明**：apothecary 高分**不強制**選它，tile-type gate + 更高分的 stable 正常壓過 |

**18 反例的意義**：apothecary score 4.82-5.01 但 chose≠apothecary——若是 machinery 恆膨脹壓一切，這不該發生。實際：(a)mil tile apothecary `SKIP_notallowed`（civ 設施不能上軍事格）→ 正確 tile-gate；(b)civ tile 上 stable（plains，score 6-7）argmax 正常贏過 apothecary。→ **argmax 健康，不是 apothecary 霸凌**。

### 分數微變 = persona/deficit 疊在 herb base（雙 driver 都 coherent）
herb tile apothecary 分佈 4.82-5.06（非單一值）→ herb terrain 頂到 ~5 的 base 上，**persona/deficit 微調 ±0.2**。地理 gate（0 vs 5）+ 個性微調（4.82 vs 5.06）**兩個 driver 都合理**，非單一公式 artifact。

### q2 stable / q3 weaponsmith
- **stable**：常 score 6-7 但多 `SKIP_terrain`（需 plains）→ 真勝出少（civ 7 / mil 2）= **terrain-gated 合理**，非壓抑。
- **weaponsmith mil 12× WINS**：選址正常，**你撤回 facility-argmax verdict 是對的**（我上輪洞2「weaponsmith override」= 其實是 mil tile weaponsmith-CAND 正常勝，非 override anomaly）。**選址無 machinery 病，weapon gap 在 afford-material（Gate B），與 facility 選擇獨立**——這條定位不變。

## 收尾：① facility thread 結案
- 我上輪揭「4/7 缺印贏家分數→argmax verdict overreach」→ systems 撤回 → 補全 7 → 現證 **machinery HEALTHY**。**QA 站的價值兌現**：不完整樣本的 overreach 被擋下、逼重量、重量證明健康（不是抓到 bug，是擋下沒坐實的結論 + 確認乾淨）。
- **facility 選擇無 machinery 病**。weapon under-production 根 = afford-material（Gate B 產鏈），非 facility argmax 壓 weaponsmith。整條武器經濟診斷鏈的 facility 環**站得住了**。

## ★殘留 WHAT-note（歸你，非 bug）
apothecary 5.06 **該不該每個 herb tile 都壓過 workshop 4.44**（civ 40× apothecary vs 11× workshop）= **平衡/多樣性設計問題**：你要不要 herb tile 幾乎必出藥坊、經濟設施多樣性夠不夠？這是 herb terrain_fit=3.0 的**平衡旋鈕**（machinery 正確反映地理，但旋鈕值是你的 WHAT）。**非 machinery bug，是 tunable**。你裁要不要調。

（QA 只找不修不裁；machinery 判 HEALTHY，平衡旋鈕歸你 WHAT。**教訓兌現：上輪『只印輸家分數的 argmax trace 無法驗 argmax』→ 補全後二元分數 pattern 一眼證地理 gate;故事稽核不是每次抓 bug,也擋 overreach+確認健康**。走 handback 交 systems 提煉 memory。）
