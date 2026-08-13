---
from: systems
to: blueprint
status: open
topic: "[★安家福祉面板收口(答用戶『搬進據點的team過得如何』)·closed-account:真值 harvest_vault+hunt 逐團 sum 非回推、netgain CLOSE、genuine 慢性餓非公式假象·★★答案=搬進去的過得差:9居民8/9(除team47)無生存優勢、甚至比流浪更差(6團月底 food-security 0天 vs wanderer 16.1天);6團(30/58/70/83/109/111)真值採集<<飯量(team30缺口85%/team83顆粒無收0.01)、famine_days+leader_hunger 同步爬=genuine 慢性餓;只team47 thriving=靠 harvest+hunt 雙路真實高產74.32(第二名近2倍)、★非糧倉(9團糧倉餘額全月精確0.0=进出相抵 pass-through 非儲蓄、granary+2.5%總體是过路口不是個別居民靠山)·★★這 CHALLENGE 上輪『修接入=ROI』框:連 settled 的都採不到→光讓多數安家不夠、binding 更深在採集產出·同 plains team47 4.1/event vs team70 0.017/event=240x 差=下一 binding 問(gather yield 為何近零)·gather formula 因子(resource:268:gain∝current 池餘量×productivity×labor_mult×labor_share×work_morale×farming_level×prod_skill×harvest_factor)=下票 measure per-team 定、不 code-guess·★honest gaps(measurer flag):resident 樣本短(2-8天、team45僅1天 onset day23-30 月後1/3才安家)、wanderer -9.9% 部分=轉resident離池非死亡(未拆)、granary 清空路徑未 trace·★禁 over-claim:1月短窗、team47 證安家『可行』(非無用)、是『目前多數安家不產糧』非『安家沒用』·evidence-only 禁 fix·序:你帶用戶答(搬進去8/9仍慘、team47例外靠高採集)+訂正接入-arc ROI(接入非充分、gather-yield 是更深 binding)→定 arc scope(用戶裁);gather-yield WHY 下票已 pre-spec 待綠燈·地基 KEEP"
---

# ★安家福祉面板收口 — 答用戶「搬進據點的 team 過得如何」

closed-account（真值 harvest_vault+hunt 逐團 sum、非回推、netgain CLOSE、genuine 非公式假象）。evidence-only、禁 fix。

## ★★答案：搬進去的，過得差（8/9）
| | 證據 |
|---|---|
| **6 團慢性餓** | team 30/58/70/83/109/111 真值採集 **<< 飯量**（team30 缺口 85%、team83 顆粒無收 0.01）；famine_days + leader_hunger 同步爬 = **genuine 慢性餓**（非公式回音）。 |
| **食安緩衝** | 月底 food-security：只 team47（3.3 天）有緩衝；6 團 **精確 0 天**。 |
| **對照組 wanderer** | 月底仍 **16.1 天**緩衝、整月僅 1 筆 starve。→ **多數 resident 比流浪還差**（0 vs 16.1 天）。 |
| **team47 例外** | thriving 靠 **harvest+hunt 雙路高產 74.32**（第二名近 2 倍、其餘 10-7000 倍量級）——★**非糧倉**。 |

## ★★意外發現：糧倉不是靠山（9 團餘額全月 = 0.0 精確）
9 居民（含 team47）自家糧倉 `public_storage.food` **逐團逐日精確 0.0**——糧倉有真實進帳（team47 Σ40.99）**但當天就清空**=**过路口 pass-through 非儲蓄**。∴上輪「granary 總體 +2.5% 穩」對得上（进出相抵餘額趨零、統計穩但個別居民沒享受到）。**安家的保護力（若有）來自 team.food 私產撐不撐得住、不是糧倉緩衝。**

## ★★這 CHALLENGE 上輪「修接入 = ROI」框
上輪收口說「世界富、多數接不到→讓多數安家就解」。**這輪反證**：連**已 settled 的 9 團**都採不到（糧倉 0、6/9 慢性餓）→ **光讓多數安家不夠**、binding 更深在**採集產出**。
- 同 terrain（plains）：team47 **4.1/event** vs team70 **0.017/event** = **240x 差**（team70 40 次採僅得 0.67）。
- ∴接入-arc ROI **訂正**：接入（讓團安家）**非充分條件**；**gather-yield（安家後採得到糧）才是更深 binding**（呼應更早 poverty-trap 面2「resident gather 量太小」、這輪真值坐實且嚴重）。

## ★下一 binding 問（gather-yield WHY、pre-spec 待綠燈）
gather formula（resource_system:268）：
`gain = productivity × current(池餘量) × COLLECT_RATE(0.05) × labor_mult × labor_share × work_morale × (1+farming_level×0.5) × (1+prod_skill×0.3) × harvest_factor`
- ★`gain ∝ current`（tile 池餘量）：team70 極可能站在**已枯竭 tile**（current 低）or 低 labor/pop/skill。
- **下票 measure per-team dump 這些因子**（current/productivity/labor_mult/labor_share/morale/farming_level/prod_skill/harvest_factor）→ 定 240x 差真兇（枯池? 無 labor alloc? 低技能?）。**不 code-guess、留 measure**（[[feedback_measure_peroption_util_before_decision_claim]]）。

## ★honest gaps（measurer flag、別當定案）
- resident 樣本**短**：onset 全 day23-30（月後 1/3 才安家）、只捕 2-8 天定居生活、team45 僅 1 天 → 趨勢外推謹慎。
- wanderer -9.9%（444→400）**部分=轉 resident 離池非死亡**（未拆兩種流出）。
- 糧倉「當天清空」的 code 路徑**未 trace**（provision 轉 team.food? or 別的）——是 pass-through 還是 bug 未定。

## ★禁 over-claim
1 月短窗。**team47 證安家「可行」**（非「安家無用」）——精確說法是「**目前多數安家的團不產糧**」非「安家沒用」。

序：你帶用戶答（搬進去 8/9 仍慘、team47 例外靠高採集、糧倉不是靠山）+ **訂正接入-arc ROI**（接入非充分、gather-yield 更深 binding）→ 定 arc scope（用戶裁）。gather-yield WHY 下票已 pre-spec、待你/用戶綠燈。落地檔 measurer `docs/measurements/2026-08-13-phase3-settlement-panel.txt`。地基 KEEP。
