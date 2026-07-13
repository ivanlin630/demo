---
from: systems
to: blueprint
status: consumed
topic: [①②根因回報] established=霸主archetype硬門檻(願景裁rarity) + 重評381根=crisis level-trigger無edge/throttle(HOW de-patch待定序)
measured_at_head: 2d30fef-dirty
raw_logs: [docs/measurements/2026-07-13-reeval-attr-seed1337-2d30fef-dirty.log]
---

> ★可溯源（新協議 dogfood，我自己剛定）：② 分支數字來源＝`docs/measurements/2026-07-13-reeval-attr-seed1337-2d30fef-dirty.log:6451-6458`，量測 HEAD=2d30fef-dirty（dirty＝含我裝的 gated probe 儀器，Probe off 時 byte-identical）。① 生成器/門檻機制為靜態 code 讀非量測數字。

# ①② 調查結果（補丁閘優先查走完，兩根都坐實）

工單 `2026-07-13-blueprint-to-systems-seed-stability-and-cadence-tune.md`（consumed）。兩項都查到真根，非猜數值。

## ① established 跨 seed — 根=**霸主 archetype 硬門檻**（願景層裁定）

**機制**（`person_generator.gd:67-70` × `faction_ai_system.gd:975-980`）：
- 一般 leader 統領技能 = `randf_range(0.0,0.3)+0.1(leader bonus)` → 範圍 **[0.1, 0.4]**。
- 立國門檻 `ESTABLISH_COMMAND=0.4`（野心折扣後 ~0.37-0.4）。**一般 leader 統領上限恰 0.4(開區間)→幾乎永遠達不到。**
- **唯一可靠破門的路 = 「霸主」outlier archetype**（`hi_s:["統領"]`→統領 randf(0.5,0.9)；`hi_v:["野心"]`→野心[0.85,1.0]，同時破 統領≥0.4 + 野心≥0.6 兩門）。
- leader outlier rate 0.45 × ¼ archetypes = **P(霸主)≈0.11/leader**。再乘「該霸主派系要存活+leader不換」→ 實際遠低。

**佐證**：warring_states 8 派系**全部**卡 統領/野心(統領 0.10-0.34，無一達 0.4)；default seed1337 established=0/2、seed42=0、seed7=1（seed7=剛好抽到存活的霸主 faction leader）。**readiness/member 兩門幾乎全過(readiness=1.0)——瓶頸純在 統領+野心。**

**這不是靜默補丁**（無 override pre-empt），是**生成器×門檻校準**讓立國 de-facto「霸主專屬、稀有」。**要不要這麼稀有=WHAT 願景裁**：
- (A) 維持稀有（立國本該是罕見大事，1/3 seed 亮=可接受）→ 收工。
- (B) 想多 seed 亮 → HOW 有兩桿可調（我來做）：降 `ESTABLISH_COMMAND` 0.4→~0.3（放頂段一般 leader 過）；或抬 leader 統領生成 base；或升霸主 archetype 抽中率。**方向(要不要更常見)是你裁，數值我調。**

## ② 重評 381 — 根=**crisis level-trigger 無 edge/throttle**（HOW de-patch）

**全世界 90 天 _should_reeval 分支計數(seed1337)**：
| 分支 | 次數 | 佔比 |
|---|---|---|
| **reeval.crisis** | **13087** | **93%** |
| reeval.cadence | 779 | 6% |
| reeval.directive | 173 | 1% |
| reeval.idle | 58 | <1% |
| reeval.stuck | 0 | 0 |
| TOTAL true | 14097 | |

**根**：`_decision_crisis`（食崩 food_flow_avg<-2.0 或 pop驟降）是 **level-trigger 非 edge**——隊陷**慢性糧負**時**每 tick 都 return true**→整條 cadence 節流被繞過。程式碼 line 1802 本**想**給 crisis 短 cadence(`DECISION_CADENCE/4`)，但 crisis 在 cadence gate 前就無條件 return true→**那段 /4 排程是死碼**。Team7 的 381 = 它在這 crisis-spin 的份額。

**這是過鬆條件=變相補丁**（符合診斷通則）。de-patch=crisis 改**邊緣觸發**（進入 crisis 當下 fire 一次，持續期間走 /4 短 throttle 非每 tick）。預估 crisis 13087→~220，Team7 381→~低百，命中理想量級。

**caveat**：measurer 已驗 Team7 行為**健康**（買糧71%多樣，非病態）——∴ ② 是**頻率/perf 優化非 correctness bug**。且改動觸決策核心、你/用戶正親判 main fidelity。**故不擅自 spec**，請你定序：
- (i) 現在做（我出 spec→reviewer R②→implementer；低風險=還原本就想要的 /4 throttle）。
- (ii) 押後（行為已健康，381 可接受，等 fidelity 判完再說）。

## 待你裁（兩問，具體）
1. **① 立國稀有度**：維持稀有(A) 還是 想更常見(B，我調數值)？
2. **② crisis-spin de-patch**：現在做(i) 還是 押後(ii)？

（我這站已做完：兩根坐實 + probe 儀器已裝（`_should_reeval` 4 gated bump，Probe off 時 byte-identical）+ attribution bed `reeval_attribution_bed.gd`。等你裁定序後續。）
