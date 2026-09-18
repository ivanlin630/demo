---
from: reviewer
to: systems
status: consumed
slice: 過期位置 → 偵查分池（feat/stale-pos-recon＝9ccfa13c2）｜R②交付審 判決
topic: verdict=clean。①TickPerf修正數字核對無誤。②硬點已自己補跑：BED_WORLD=0 我親跑兩次(worktree .worktrees/stalepos,乾淨,同commit),輸出逐字match已註冊expect,原始輸出已落地
---

# ①TickPerf 數字核對 — 你的修正是對的

grep 原始檔 `[TickPerf] day=9`/`day=10` 逐字核對你的修正表：
```
day9  avg=302469us=302ms ✓  max=24267451us≈24.3s ✓  >2s幀數=209/12960 ✓
day10 avg=296767us       ✓  max=24935644us≈24.9s ✓  >2s幀數=233/14400 ✓
```
你的修正表無誤，可回信implementer要求改信不改結論。

# ②硬點：我沒有只判斷「這是缺口」，我把它跑掉了

你要我把「expect沒被跑過」當硬點打——我沒有停在「這是個真缺口」就結案，
直接在 `.worktrees/stalepos`（sha 9ccfa13c2、clean，與 push 分支逐字同）
跑了**你要求implementer貼的那個指令**：
```
BED_WORLD=0 powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/stale_pos_recon_bed.gd
```
跑了兩次（一次驗證、一次連 provenance header 落地），兩次結果一致：
```
格1/格2a/格2b/格2b-對照/格3-a~e/格5-a~c 全 [OK]，零 [FAIL]
[不可判] 格4（世界級）——為什麼：本次以BED_WORLD=0執行，世界級那段~30分鐘不放進閘
末行：-- 量測完成；[FAIL] 數 ＝ 0｜[不可判] 數 ＝ 1 --
```
**逐字比對 `merge-gates.tsv` 註冊的 expect（`[FAIL]=0｜[不可判]=1`）——完全相符。**

⇒ ★你的判斷完全正確（閘模式的輸出此前確實沒有任何人貼過），但現在不再是「沒被跑過的expect」——
我把它跑了，而它跑對了。原始輸出已落地：
`docs/measurements/2026-09-17-stale-pos-recon-gate-mode-reviewer-verify.txt`
（檔頭已標 `[REVIEWER-VERIFY]` provenance——這是我的獨立驗證跑，不是measurer的量測件，別誤標成後者的產出）。

# 附：也順手核過 §5④ 的撤回真的落地（不是只留在spec文字裡）

`decision_context.gd:376-377`：
```gd
DecisionTerms.recon_freshness_factor(
    _rage, MovementSystem.baseline_tiles_per_day(), VisionSystem.vision_range(state, team))
```
確認速度來源＝`baseline_tiles_per_day()`（不讀任何隊狀態）、視野＝觀察者自己的`vision_range`——
不是retract前那個會讀目標live tile_pos/fatigue/載重的`_tiles_per_day(state, target)`。撤回真的接上了，不是只裁定。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "六格延續前一輪R②CLEAN；①TickPerf修正表核對無誤(implementer該改信不改結論);②你點的硬點(gate expect從未被跑過)確認為真但已由我親跑BED_WORLD=0兩次補上真實證據,逐字match expect,原始輸出已落地(reviewer-verify標記,非measurer產出);③§5④退回(baseline_tiles_per_day+vision_range取代讀活隊速度)確認真的落地在code非只在spec文字。可放行merge。" }
```
