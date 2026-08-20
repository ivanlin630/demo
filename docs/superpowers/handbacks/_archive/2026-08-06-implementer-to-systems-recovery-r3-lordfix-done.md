---
from: implementer
to: systems
status: consumed
topic: "[recovery-r3 收尾 fix DONE·領主令領主自己視角(解②從抗 dead+god-view 後門)·feat/recovery-r3 commit f4fda140]真根修:_try_relocate_order 領主令改領主自己視角 genuine util、★不讀村 PersistStrength/戀土(god-view 後門清)。fix:lord_sunk=subj outpost_level×INFRA_SUNK(領主 belief 可見棄置基建=自家領土 admin 知非村內心);order_util=relocate_value(belief terrain 前景差)×lord_pmult(慎重+義氣+野心規劃/仁君→高放任→低);>閾才令。村保留戀土自秤 obey/resist(_deliver_relocate_order 不動)=兩層對抗 alive。self 讀自己 sunk 合法(自知非 god-view)。★anti-crank:放任領主不下令(genuine 分化非被迫)、傲村會抗命領主照令(不讀村戀土)。驗:r3_test 10/10(+god-view-clean 傲村照令/anti-crank 放任不令/★★★自然觸發 pipeline advance_tick 中 ordered=1+self=1 真觸發→棄地+落腳真完成、非 hand-call)+constitution 75(fix 無新 site)+headless 0-new+determinism 3-run 99B4B235 byte-identical。請 R²(核領主令 genuine 領主視角+god-view 領主不讀村戀土+從抗真觸發兩層對抗+①④回歸)→measurer→QA→merge=復甦 arc 收官。"
branch: feat/recovery-r3
commit: f4fda140
---

# recovery-r3 收尾 fix DONE — 領主令領主自己視角（解 ②從抗 dead + god-view 後門）

feat/recovery-r3 commit `f4fda140`（已 push、pre-push constitution gate PASS 75）。你 R² 診斷 + blueprint 升級的真根已修。①④（爛地村真遷走+三態）回歸未破。

## 真根（你診斷）→ fix
**真根**：`_try_relocate_order` 領主令 gate 用 `relocate_value(subj, target, sunk=PersistStrength.compute(村))` = 村戀土-weighted →
- (1) 領主永不令會抗命的村（低戀土自願遷先走 / 高戀土領主不下令）→ **兩層對抗 dead**；
- (2) ★領主讀村內在戀土 = **god-view 後門**（領主哪知村民多戀土）。

**fix（領主自己視角 genuine util、不讀村戀土）**：
| 件 | 改 |
|---|---|
| `_best_relocate_target` | 改回 **raw argmax**（呼叫者秤人格+門檻、非內建 threshold）→ lord/self 各自視角 gate。 |
| `_try_relocate_order` | `lord_sunk = subj_est.outpost_level × RELOCATE_ORDER_INFRA_SUNK`（領主 belief 可見棄置 outpost 基建=**自家領土 admin 知、★非村 PersistStrength/戀土**）；`order_util = relocate_value(belief terrain 前景差) × lord_pmult`（`慎重+義氣+野心−0.75` clamp、規劃整併/仁君→高、放任→低）；`>RELOCATE_THRESHOLD` 才令。 |
| `_deliver_relocate_order`（從抗） | **不動**：村保留戀土自秤 `obey=義氣+懼−傲−戀土` → 兩層對抗 **alive**（領主令 economics、村獨立 resist 戀土）。 |
| `_try_self_relocate` | self 讀**自己** sunk（`PersistStrength.compute(self)`、自知非 god-view）+ 門檻 gate（不變）。 |

## ★anti-crank 牙
- **放任領主**（低 慎重/義氣/野心）→ lord_pmult 低 → order_util<閾 → **不下令**（genuine 領主分化、非被迫全序）。
- **傲村**（高戀土會抗命）→ 領主**照樣下令**（領主自己視角 economics、不讀村內在戀土）→ 村 resist（兩層對抗 alive）。
- 村 genuine：有從（忠）有抗（傲/戀土）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `recovery_r3_test` | **10/10 PASS**（原 7 + ★**god-view-clean**[傲村會抗命領主照令] + ★**anti-crank**[放任領主不下令] + ★★★**自然觸發 pipeline**[advance_tick 中決策層 `ordered=1`+`self=1` 真觸發 → 棄爛地+落腳真完成、非 hand-call `_begin`]） |
| constitution_gate | **PASS sites=75**（fix 只改 util 邏輯、無新 taskarbiter site；R3 的 `_begin_village_relocate` baseline entry 仍待你 ratify） |
| headless | **0-new** |
| determinism | 3-run `99B4B235629FCB00D3510520621C6A2D` **byte-identical**（同 pre-fix R3＝領主令 lord-perspective 改在 warring inert；3-run 穩=零 RNG leak） |

## 守
god-view（★領主**不讀村 PersistStrength/戀土**；self 讀自己 sunk 合法；relocate_value belief est；target own-faction admin）/ 零死常數（領主令 util = 真 economics×真人格）/ 真成本（棄據點 abandon + 路程 + 領主 belief 基建 sunk）/ determinism / constitution 75。

## 路
1. **你 R²**（核：領主令 genuine 領主視角 + god-view 領主不讀村戀土 + 從抗真觸發兩層對抗 + ①④回歸 + `_begin_village_relocate` baseline 75 ratify）。
2. → measurer 量（②從抗分化[忠村從/傲村抗] + 怨→叛/起義劇情鏈 + ①④回歸[爛地村真遷走+三態]）。
3. → QA 故事判 → merge = **復甦 arc 收官 → 轉框架收尾**。

地基 KEEP。
