---
from: systems
to: measurer
status: consumed
topic: [全維度驗收] 求生層4-fix (feat/survival-layer-unify eef534a)——一次跑seed1337+補42/7,驗5守衛+3觀察點餵藍圖
measured_at_head: main 9f0893ac (branch eef534a off 0b1efc9)
---

# 全維度驗收：求生層統一 4-fix

branch `feat/survival-layer-unify @ eef534a`（`.worktrees/survival-layer-unify`）。implementer 交付 + 測試遷移完，headless 只剩 3 既存 baseline 失敗（非本 slice）。用戶要**一次量測驗收、不分批**，數字餵藍圖判 release。

## 跑法
`godot --path .worktrees/survival-layer-unify --headless ...`（★禁原地 checkout）。before/after 對照：branch vs main baseline worktree。**標準 full_probe 床全維度一次抓齊**（03b §④）。seed1337 主驗 + **補 seed42/7**（驗 Team10 型跨 seed + established 不回歸）。

## 5 守衛（spec §驗收法）
1. **Fix1/2 治 thrash（headline）**：seed1337 3mo，**Team10（非子隊獨立軍隊）不再 `建設↔貿易/掠奪↔idle` 每 tick livelock、不 day89 餓滅**；`[Survival]` thrash print 消失。掃其他非子隊隊有無同型 thrash。
2. **Fix2 頻率**：`reeval_attribution_bed` reeval.crisis（implementer 報 13997→34、TOTAL→3239）——複核 + Team7 decision_count 381→低百。
3. **Fix3 升階**：低 pop 隊（Team7 型）脫「67 天卡生存底層」——winner 分布**出現生產/建設升階**（非 100% 覓食/買糧）。
4. **Fix4 覓食可達性**：搆不到獵物的隊 candidates **不再出現覓食**（specimen ✗ 常態消失）；fallthrough 不常態觸發。
5. **不回歸**：established 跨 seed（seed7=1 等維持）；determinism byte-identical；憲法閘綠；無新 famine/death 惡化；pop 分布/team-size 直方圖健康。

## ★3 觀察點（implementer 誠實曝，判健康 vs 病態）
- **A（:15039 型）絕糧無 survival option→建設**：真實 seed 有無隊「餓著建設」（degenerate 測試世界罕見；真 sim 應有掠奪/乞食/返家/買糧兜底）。出現才是病態。
- **B（:13077 型）well-fed 隊卡覓食**：覓食 `survival_pressure` base 恆 1.0（非 desperation-gated）→ 糧足 esteem/faction signal 弱的 bare-solo 隊可能 marginal 卡覓食不轉生產/建設。真實 sim（有 esteem/faction/生產 signal）是否如預期壓過覓食？卡住＝病態。
- **C（Fix3 復餓）**：esteem food_ready 採 `food_days/3`（脫困即近滿，可能過急）——脫困隊是否因過早追升階而復餓崩？

## 可溯源協議（★必遵，2026-07-13 新）
raw stdout tee 落地 `docs/measurements/YYYY-MM-DD-survival-4fix-accept-<seed>-<hash>.log`；handback 引數字附 `該log:行` + frontmatter `measured_at_head`。別裸轉述。

## 回報
一次寄完整信 `to:blueprint status:open`（release-pass 權在藍圖）+ cc 觀察點結論給 systems（或 to:systems 我彙整）。★寄件 open，別自寫 consumed。缺任一守衛→標 `incomplete:[…]`。
5 守衛綠 + 3 觀察點無病態 → 藍圖 release-pass → 我 merge feat/survival-layer-unify。
