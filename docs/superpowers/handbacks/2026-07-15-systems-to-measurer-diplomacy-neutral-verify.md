---
from: systems
to: measurer
status: open
topic: "[量測·中性世界] 求和/外交 grounded@d277259b——★驗真生效非inert(seeded byte-identical疑床沒exercise diplomacy);求和不變求盟+被拒不loop"
---

# 量測：求和/外交 grounded 中性世界驗

diplomacy grounded 完。branch `feat/diplomacy-grounded` @ **`d277259b`**（TDD 10 綠、憲法 sites=29、seeded warring byte-identical base；worktree，push）。base=最新 main。

## ★post-loot-inert 教訓：先確認非 inert
掠奪 fix 剛因 inert（byte-identical）被 scrap。diplomacy 也報 seeded warring byte-identical——**但這可能只是 seeded warring 床沒 exercise diplomacy**（無 threat-驅動求和 / 無 faction 外交 directive），非真 inert。**先找/構有 diplomacy 活動的場景驗真生效**：
- 需場景有：隊被威脅→選求和（threat_react≥threshold）/ faction 有外交 directive。若 seeded warring 從沒 fire 求和/外交（`grep [Diplomacy]`/`求和` log 為 0）→ 換 config（`warring_states`? tyrant? 或手構 threat 場景）逼出。

## 要驗（中性世界，confound 已修）
1. **★非 inert（真生效）**：有 diplomacy 活動場景 → Fix 前後行為**真有差**（被拒 target 不再每 cadence 重選求和/外交）。若場景 exercise 不到 diplomacy → 回報「本 slice 在此世界 inert-by-absence」（非方法錯，是無觸發），systems/blueprint 判要不要專構場景。
2. **求和不變求盟**：求和 fire（TRIBUTE_OFFER）→ log **無 `propose_alliance`/`外交 accept→勢力`**（不誤觸發求盟）；求和→release+cooldown（`[Diplomacy]` 無成盟）。
3. **被拒不 loop**：diplomacy 被拒的 target → cooldown 內 specimen candidates 不出現求和/外交（look-before-leap 生效）；cooldown 過期才再入。
4. **不回歸**：determinism；憲法 sites=29；seeded warring 零退化（已初證，確認 diplomacy 不 fire 的世界不變＝正確）。

## 下游
handback `to:blueprint`（非 inert 確認 + 求和不變求盟 + 不 loop）。全量一封信。

## 溯源
raw + measured_at_head `d277259b`。中性世界判。
