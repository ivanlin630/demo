# HOW spec：生育＝per-capita 盈餘驅動的**連續速率**（取代硬懸崖 + 抽獎）

date: 2026-08-20 ／ owner: systems ／ 用戶拍板 **(乙) 強化版**（blueprint 轉達）
狀態：待 R② → dispatch。**intended-change + tuning 流程**。
★**時間側 HOLD 遵守**：本 spec **不新增任何 cadence/interval/時長常數**，也不改既有時間錨；速率以「**每人每日**」表達、乘既有 elapsed 量。

## §1 前提（實測 + file:line）
- 現況 `reaction_system:197-215`：`surplus = t.food_flow_avg > BREED_FLOW_MIN(1.2)` **硬門檻** → 過了才 `randf() < chance`（`chance = (0.15 + 醫療×0.1) × balance`）＝**懸崖 + 抽獎**。
- **funnel 實測（evidence-only 輪）**：`surplus` 攔截 **97.3%（warring）／94.1%（peaceful）**＝壓倒性主閘；`safe` 0、`fed` 0.4–8%、`minor<cap` 8–13%、單性 balance 5.6–6.4%、`team_no_person` 0。
- ★**尺度依賴**：`food_flow_avg` 是 **team 級絕對值**（`resource_system:236-243`），非 per-capita → pop3 需 +1.2/日（每人 0.4）、pop30 亦僅需 +1.2（每人 0.04）＝**大團容易 10 倍**；而世界多數團 pop 3–6、57–62% 淨流為負 → **小村近乎全域封鎖**。
- 大考坐實：`reaction.breed` **整 12 個月 0 次**；觀測到的人口成長全是 world-gen minor 存量出清。

## §2 設計（用戶裁定的形狀）
**生育率 ＝ 連續函數 of「相對盈餘」**，瀕餓≈0 → 溫飽少 → 盈餘多，**無懸崖、無抽獎**。
- **★尺度自由的度量**：`rel_surplus = food_flow_avg / max(pop × FOOD_PER_PERSON_PER_DAY, ε)`
  ＝「淨流相對於**自己的日耗**」——**同時解掉兩個方向**：小村不再被絕對門檻封死；大團也**不會被人均攤薄反向懲罰**（因為分母同步放大＝**比例量、非人頭量**）。這是 blueprint ⑤ 那個備用考量的答案。
- **速率**：`births_per_person_day = BASE_RATE × f(rel_surplus) × persona_mult`
  - `f` **連續、單調、飽和**（`rel_surplus ≤ 0 → 0`；上界飽和，避免暴富爆生）。
  - `persona_mult` 沿用既有 `醫療` 技能與 `_breed_balance`（**兩性結構仍是先決**，實測只佔 5–6%、保留即可）。
  - ★**`f` 的形狀與 `BASE_RATE` 由 §3 的真分布定**，**禁憑空給常數**（用戶/blueprint 明令）。
- **★累積器取代抽獎**：`team.breed_progress += births_per_person_day × eligible_persons × elapsed_days`；`while breed_progress >= 1.0 and minor < cap: minor_population += 1; breed_progress -= 1.0`。
  - **紅利①**：`elapsed_days` 天然吸收 cadence → **LOD 那個 `trials` 迴圈對 breed 變成不必要**（rate×Δt 本來就是正確的降頻語意）→ 可**移除 breed 專屬的 trials 分支**（其餘累積型補償**不動**）。
  - **紅利②**：**零 RNG** → 生育不再消耗 global RNG 筆數（觀測/降頻都更乾淨）。
  - `breed_progress` ＝ **TeamData 新欄位**（float，持久）→ **必入 `state_fingerprint`**（否則新持久狀態＝determinism 盲點；同 `camp_team_id` 前例）。

## §3 ★T0：形狀先看真分布（**做 spec 的第一步、不是最後一步**）
dispatch 前先要一份分布快照（measurer，可從**既有大考 specimen/JSONL 重算、不必新長跑**）：
- 全隊 `rel_surplus` 分布（min/median/p75/p90/max、正值佔比），peaceful 與 warring 各一。
- 現況「若用舊規則」實際會通過的人次比例（對照組）。
**用途**：定 `f` 的轉折與 `BASE_RATE`，使
（a）**健康小村真的會生**（目前被誤殺的那群）；
（b）**餓的世界仍然少生**（(甲) 的精神：世界窮就該少生，不是把門拆掉）；
（c）**量級錨定現況**：在「舊規則會通過」的那群身上，新率的期望產出**與舊規則同量級**（避免默默大幅調高生育＝偽裝成 bug fix 的 balance 改動）。

## §4 gate
1. **★分布驅動**：`f`/`BASE_RATE` 的取值在 spec/code 註解裡**指向 §3 的實測數字**（不得只寫 TEST VALUE 了事）。
2. **健康小村會生**：合成床——pop 3–5、`rel_surplus` 明顯為正 → 有限窗內**確實產出 minor**（舊規則下為 0）。
3. **餓村仍不生**：`rel_surplus ≤ 0` → `breed_progress` 不增、零 minor。
4. **無懸崖**：`rel_surplus` 由 0 掃到高值，產出率**單調連續**（無跳變點）。
5. **大團不被攤薄**：同 `rel_surplus`、pop 3 vs pop 30 → **每人速率相同**（比例量驗證）。
6. **LOD 等價**：far pass（低頻）與 near pass 在同窗內**累積產出相同**（`elapsed_days` 語意正確）；移除 breed trials 分支後**其餘累積型補償仍在**。
7. det×3、constitution ≤75、headless 0-new、**fp intended-change**（含 `breed_progress` 新欄入 fp）。
8. **★世界級 sanity**：短窗跑 peaceful → `reaction.breed`（或新 probe `breed.born`）**> 0** 且**不爆炸**（人口曲線平滑上升、非指數）。
