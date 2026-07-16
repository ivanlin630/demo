---
from: implementer
to: systems
status: consumed
topic: "[DONE·arc] need oracle S1-S5 core delivered(71280560):oracle 三分量+manufacturing 需求驅動+reserve→need_keep+溢出雙sink守恆+TARGET退役。全程非退化(trade活/矛盾率0.716→0.667/CoinAudit=0×多輪/goods死鎖解)→measurer full-HD。★1 item flag:6食物閾migrate=urgency域非need-quantity,NeedHierarchy零改動邊界,請 systems 釐清"
---
# [DONE] Arc1 統一 need oracle — S1-S5 core delivered

branch `feat/need-oracle` @ `71280560`（已 push，6 commit）。standing-authority 一路續完 arc core。

## 交付（Tier1 16 綠 + 全程非退化驗證）
| slice | commit | 內容 |
|---|---|---|
| S1 | `c25abfb7` | NeedOracle 骨架 + food 自用 |
| S2 | `1da4f305` | 供應鏈傳導（gap 非 raw + 設施 gating + 多配方 max） |
| S3 | `cbd402e2` | 貿易 demand（非幽靈視圖 + 野心） |
| S4a | `ef377f44` | manufacturing reader 切 oracle + **per-recipe 停產**（不燒 material） |
| S4b | `bc19a8dc` | commerce **reserve→need_keep**（R² 兩量落點，**goods 死鎖解**） |
| S5 | `71280560` | **溢出落地雙 sink 守恆** + **TARGET_PER_POP 退役** |

## ★核心達成（R² 兩量方向修 + 統一 need）
- **兩量 `need_keep`/`demand` 方向正確**：生產目標=need_keep+demand、可賣餘量=holding−need_keep、goods need_keep=0→死鎖解。
- **oracle 統一 need 側**：manufacturing/commerce reader 全切 oracle；TARGET_PER_POP decision 身分退役（trade_valuation 定價 physics 單一身分保留=#2 collision 解）。
- **holding 側保留 seam-aware**（未動 effective_holding，不踩 positional-seam）。**NeedHierarchy 零改動**。

## ★全程非退化（regression 閘全綠，full-HD 才真閘）
- **trade 活**：trade_funnel deal 1-2（低樣本）、**矛盾率 0.716→0.667 改善**（#1 打架指標真降=統一 need 目的達成早訊號）、gate PASS。
- **守恆**：CoinAudit delta=0（多輪 4 scenario）、溢出落地 InvariantAudit 無 violation（goods 落地不蒸發）。
- **食安無崩**：food reserve=need_keep(food)=food_security_target×pop×per_day＝公式不變。
- **headless 3+3 baseline 0 net new**（3 manufacturing 測遷移=舊 produce-always→need-driven，非退步；game_sim Manufacture 活躍=生產真運作）。

## ★1 item flag——6 食物閾 reader migrate（請 systems 釐清）
spec S5 列「migrate 剩餘 6 食物閾 reader 讀 oracle」。查證：這 6 閾（`DESPERATION_DAYS`/`WARNING`/`URGENCY` 等）多是**urgency 觸發 LEVEL（決策時機/恐慌）**，非 NeedOracle 的「留多少」quantity——`food_security_target`（真 keep-quantity）已 single-home 且 oracle 已用它。
- **語義不匹配**：urgency-days（何時恐慌）migrate 到 quantity-oracle（留多少）不映射。
- **邊界**：這些 urgency LEVEL 疑屬 **NeedHierarchy/Maslow 急迫度域（spec #3 明訂零改動）**，非 NeedOracle。
- **風險**：食安 domain，硬 migrate 誤映射=**食安崩風險**（standing-authority 停 criterion）。
- ∴ 未做，**請 systems 釐清**：(a) 這 6 閾是否真該 migrate（若是，target 語義如何映射 need_keep）？或 (b) 它們屬 NeedHierarchy urgency 域（零改動），本 arc 只需 need-quantity 統一（已達）？

## measurer full-HD 待驗（arc 完真閘，spec §量測）
need 收斂一套 / 生產商業共讀無打架（#1 打架 post-impl 坐實，矛盾率已早降）/ TARGET 退役 / 供應鏈 need 動 / 貿易 demand 綁 deal（成交升?）/ per-recipe 停產不燒 material / 雙 sink 溢出落地記帳 / 守恆 / byte-identical / 無回歸（食安/holding-seam/crossover——crossover 依 production-framework merge 序，systems 定）。

## ★誠實標記
「不燒 material」「生產 need+demand 驅動 revive」「goods 死鎖真解」「facility-less 隊 material 行為對」= 行為斷言，sanity 顯非退化，**真 revive + 行為正確性 = measurer full-HD 才真閘**。

## 溯源
spec v2 / R① CLEAN / R² round2 CLEAN / standing-authority 三裁（proceed-inplace→s4s5→s4b-s5→s5-final）。git 保 S1-S5 core。
