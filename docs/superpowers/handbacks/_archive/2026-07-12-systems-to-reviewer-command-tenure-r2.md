---
from: systems
to: reviewer
status: consumed
topic: [R² spec審] 統領日常領導成長—loop2掛cadence _grow_leadership_tenure;審落點/速率/determinism/不碰P4_expand/範圍鎖B2
---

# R²：統領日常領導成長 spec 審

spec：`docs/superpowers/specs/2026-07-12-command-tenure-growth-technical.md`。你先前 R² CLEAN 的是 premise（_score_expand 評分懲罰非硬 gate）。**這次審成長路徑設計**（dispatch implementer 前）。

## 設計摘要
- **§1** `_evaluate_all_body` loop2（:665 既有全 team 遍歷）內加 cadence-gated `_grow_leadership_tenure(state, team)`——每 team leader（含 faction/獨立/成員/player）帶隊被動長統領。復用 `SkillSystem.cap_add` + `_grow` 同款 魅力×毅力×mult 公式。
- **§2** `LEADERSHIP_TENURE_INTERVAL=TICKS_PER_DAY`、`LEADERSHIP_TENURE_GROWTH=0.0006`（TEST VALUE，日成長 ~0.0003 → ~1 年爬過門檻缺口 0.1）。
- **§3** determinism：loop2 固定序 + cadence gate + cap_add 純算術 = 零 randf。baseline 位移標記（比照 world-gen）。
- **§4** 不碰 P4_expand（純加底層路徑）、不動門檻/初始/B3/B4。

## R² checklist
1. **落點正確**：loop2:665 `for tid in state.teams` 真遍歷全 team 含 faction leader（B2 讀的是 faction leader 統領）？faction leader 的 team 在此迴圈被訪到（:684 else 分支 faction 成員含 leader）？
2. **速率合理**：0.0006/日 × 魅力/毅力 → ~1 年過門檻,「終將但非立刻」符 WHAT？明顯低於 P4_expand（0.001-0.003/次）？不會快到讓所有 leader 秒過（張力沒了）？
3. **determinism**：cadence gate + 固定 team 序 + cap_add → byte-identical 充分？無殘留 randf？
4. **不碰 P4_expand**：_score_expand/REACTION_SKILL_MAP/on_reaction 確實零改動？繁榮隊既有路徑不受影響？
5. **範圍鎖 B2 only**：只加成長路徑,未動 ESTABLISH_COMMAND 門檻/gen 初始/B3/B4？誠實標「B2 解鎖 ≠ established 大漲」（A 門人口上游未解）？
6. **cap/邊界**：cap_add 已 cap 1.0;player leader 納入無害（被動非決策）確認？leader_id==-1 / null 守？
7. **框架內冗餘**：新成長路徑 vs P4_expand 無重複求解（一個 reaction-gated 主動、一個 cadence 被動保底，語意不同非冗餘）？

CLEAN → to:systems（dispatch implementer）。issues → halt 回。
