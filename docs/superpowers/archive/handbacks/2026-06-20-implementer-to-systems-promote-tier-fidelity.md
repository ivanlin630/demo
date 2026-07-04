---
from: implementer
to: systems
status: consumed
topic: #0b 升 named 忠於來源 tier — 實作完成 + world_sim 重量（含 world_sim 非確定性發現）
---

# Hand Back: #0b 升 named 忠於 tier

## 實作摘要

- `scripts/simulation/person_generator.gd`：
  - 加 `PROMOTE_TIER_WEIGHT`（晉升偏好抽高 tier）+ `PROMOTE_TIER_SKILLS`（來源 tier → 戰鬥/戰術/統領技能帶），皆 TEST VALUE。
  - `generate_for_team` 尾段：`kill_random(team, 1, "promote", PROMOTE_TIER_WEIGHT)` 帶權重抽 anon，用回傳 `{tier:死亡數}` 取首個 >0 tier = 來源 tier，呼 `_apply_promotion_skills` 套技能帶（`maxf` 不蓋 archetype 尾巴）。
  - 新私有 `_apply_promotion_skills(p, src_tier, seed)`：seeded RNG（`seed*31+7`，與 generate 內部 rng 偏移區隔）roll 帶內值，`maxf` 寫入。
- `scripts/debug/headless_test.gd`：加 `_test_promote_tier_fidelity()`，`_initialize()` 在 `_test_promote_anon_takes_share` 後註冊。

與 spec 一致，無差異。AnonTierSystem 零改、`generate_for_team` 簽名不變、不碰守恆/treasury share/cohort 數。

## 驗證結果

### headless 回歸（權威閘，全綠）
- `=== DONE ===`、0 SCRIPT ERROR、0 Assertion fail。
- `#0b tier fidelity OK (菁英戰鬥=0.76 / 平民戰鬥=0.18)` — 菁英升 named 戰鬥/統領達高帶；平民升 = generate 預設低值（階梯差成立）。
- `CoinStorage Task7 OK`（`_test_promote_anon_takes_share`，全平民隊）仍綠 → 平民升 coin share 不變（守恆不破）。
- 投靠守恆整合（coin_eq）OK；InvariantAudit population / faction / subteam 全 OK。

### world_sim 重量（2 年 172800 tick）
- 跑通無 SCRIPT ERROR，`[ProbeSummary]` 印，全程不崩。

**⚠ 關鍵發現：world_sim 非確定性（「seed 77 可重現」不成立）。**
同一 post-change branch 跑兩次 ProbeSummary 大幅分歧：

| 訊號 | post run1 | post run2 | pre-change(878f72e) run1 |
|---|---|---|---|
| order_placed | 5739 | 5552 | 6381 |
| ambition_promote | 35 | 71 | 106 |
| feud_formed | 1 | 0（未列） | 0（未列） |
| faction_found | 1 | 1 | 1 |
| detect_裁決 | 2 | 32 | 19 |
| trust_up | 14735 | 3690 | 6286 |
| 末月存活隊 | 8 | 7 | 9 |

兩次 post 跑彼此差異（feud 1↔0、promote 35↔71、trust_up 14735↔3690、存活 8↔7）已**遠大於** pre/post 差 → run-to-run 噪聲淹沒任何訊號。**無法從 world_sim 對本項做任何 emergent 因果歸因**。佐證既有 memory `reference_multi_sanity_unseeded`（drift 數字不可重現），本次擴及 world_sim：world_sim 實務上未種子化，ProbeSummary 不可作回歸/歸因閘。

→ 本項回歸結論僅依 **headless**（全綠 + tier fidelity 階梯差 + 守恆/audit 0）。world_sim 僅證「不崩、ProbeSummary 仍印、faction_found 仍 ≥1」=煙霧測試，非平衡證據。

## 連動風險

- `faction_ai` / `npc_combat` / `AmbitionLadder`：晉升 named 戰技尾巴更耐久（菁英升上來恆帶高戰鬥/統領）→ 理論上影響戰鬥結算、ambition derive、立國傾向。**但 world_sim 噪聲下測不到淨效應**；需確定性 harness 或專門場景才量得出。標記為待後續 measure，非本項可結論。
- 守恆：只改 named 生成技能值（非資源/coin/cohort 數），coin_eq 無關，headless coin_eq=0 證實。無已知守恆風險。
- `_team_seed` 複用既有（technical：技能 rng 偏移 +7 與 generate 內 rng 區隔，避免相關）。

## 待主 session 確認

1. **TEST VALUE 待平衡**：`PROMOTE_TIER_WEIGHT`（平民0.2/新兵0.6/老兵1.5/菁英3.0）、`PROMOTE_TIER_SKILLS` 帶值 = 占位，正式平衡 pass 調。
2. **world_sim 非確定性**：是否該為 world_sim 補種子化（讓 ProbeSummary 可作回歸閘），或正式接受其為「不可重現煙霧台」、emergent 量測一律走專門確定場景？建議系統裁。本項已照 measure-first 不對噪聲歸因。
3. 非戰鬥技能（醫術/商業等）刻意不動 —— 只設戰鬥/戰術/統領，避免菁英兵升上來突會醫術。如要擴帶其他簇，另開項。
