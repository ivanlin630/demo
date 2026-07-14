---
from: systems
to: measurer
status: consumed
topic: "[量測·觀察交付] full-HD live 觀察——force_full_hd開沉睡系統(反應/生育/情緒/內政)+可信tracer抓全生命specimen;產物=四維觀察報告to:blueprint;raw未校準世界別預修"
---

# 量測：full-HD live 觀察（觀察是交付，非修 bug）

> **[worker 守則] 卡住/量不到/授權不明 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

blueprint 意圖：三 arc 落地（desperation/god-view/tracer-completeness），**現在有可信 tracer**（全生命+全路徑+零擾動）→ 開沉睡的世界看它怎麼動。**交付＝觀察報告，非修**。觀察到的真問題**才是**②③④⑤+經濟 arc 的設計輸入（先有結果再開藥，[[feedback_avoid_rabbithole]]）。

## ★機制確認（systems HOW，code-verified：force_full_hd 自然開，零 gate 改無 R²）
沉睡系統過去全 0 的根＝**LOD near/far 分區**：反應/生育/情緒在 **near branch**（`sim_runner:221 _step7_person_reactions`），無玩家世界（player_id=-1）→ 全隊 all-far → **跳過反應/生育**（`reaction.* 全 0` 的來源）。
- **開法＝`SimRunner.force_full_hd=true`**（`sim_runner:110` 已存在）：on→`_get_near_teams` 回全隊、`_get_far_teams` 空 → 全隊每 tick 走完整 near pipeline → **反應/生育/情緒/minor 長大全 live**。
  - breeding＝`reaction.breed`（`reaction_system:202`）＝反應之一，near-gated → force_full_hd 開。
  - 內政基質＝`reaction.<winner>`(:121) + `death.defect_leave`(:259+) → 開。
  - 情緒＝`ctx.team_panic` 讀 stress（序7 接線）→ 開。
- **零遊戲邏輯改、零 gate 改**（純 LOD regime flag）→ **無 R²**。**注**：force_full_hd＝LOD→full-HD 不同 regime，反應/生育跑起來→人口/行為本就異於 LOD baseline＝**預期**（正是要觀察的 live 世界，非 bug；full-HD 轉正典已定）。

## 設觀察跑（授權你建/擴床——觀察 infra，零遊戲改）
現無「force_full_hd + 4 維聚合 + 全生命 specimen」床（`sufficiency_bed` 有 player_id=-1+Probe+monthly 聚合**但沒開 force_full_hd**＝過去 reaction 全 0；`reeval_attribution_bed` 有 FORCE_FULL_HD env 但單隊死因）。**授權你擇一**（你的 bed 工具判斷）：
- (a) **擴 `sufficiency_bed`**：加 `SimRunner.force_full_hd=true`（讀 env `FORCE_FULL_HD` 比照 reeval_bed）+ 開 SpecimenTracer 2-4 指標團 + `SPECIMEN_JSONL_OUT` 全生命 jsonl。復用其 rate-table/monthly 機制。
- (b) **新 observe 床**（若 (a) 不合身）。
記入 `03b_measurer.md` 床庫（第三個觀察 infra）。

## 觀察什麼（四維 + 全生命 specimen，用可信 tracer）
1. **人口動態**：breed→minor→長大→成年 anon 循環。世界從「只萎縮」變「有生有死」＝**達什麼動態?**（穩態/緩長/爆炸/波動崩）。抓 pop 曲線 + breed/mature/death 率。
2. **內部政治 live（③基質首跑）**：`reaction.*`（defect/riot/dissent）+ `death.defect_leave` 真發生嗎? 團裂/叛/篡位? ③的牙第一次真咬。
3. **情緒 live**：stress/fear/panic 影響決策多少?（team_panic→FLEE 觸發率）。
4. **經濟**：食物怎麼流?（連 defer 的「食物流通/抱團」大題——先看糧怎麼流再決定供給補不補）。
5. **★全生命 specimen 故事**：2-4 隻指標團**完整一生**（生→長→政治→死/存）讀故事——用修好的 tracer（全生命無洞 + churn 現形），非窗口。

## 跑參數
- `player_id=-1`（自然世界）、**`force_full_hd=true`**、default config（~15-25 隊 perf feasibility 內；O(N²) 是 50+ 硬前提，此規模可跑）。
- 6-12 月（看人口/政治動態展開；月切面聚合）。**`GODOT_TIMEOUT=600`**（full-HD 慢，避誤殺假迴歸）。
- log/jsonl 存前 **UTF-8**（godot exe 直印=UTF-16LE，03b §5b）。
- 多 seed（2-3）看 robustness，非單 seed 賭。

## 判定路徑（觀察非驗收——無綠/紅，是「看到什麼」）
raw 數字 + specimen 故事**照實報**，**別預修、別紙上猜**。對照 blueprint 預期（人口爆/崩、政治過激/死寂）差多少＝設計課題。

## 下游
**觀察報告 to:blueprint**（人口/政治/情緒/經濟四維聚合 + 2-4 隻全生命 specimen 故事 + 對照 blueprint 預期的落差）。blueprint+用戶讀 → 定 gen 重校/②③④⑤對哪真問題做。
溯源 raw + measured_at_head（跑時 main HEAD）。
