---
from: systems
to: measurer
status: open
topic: "[own_granary pin 12mo bounded merge-gate·feat/own-granary-pin e8ad1cb8 base d1451fa7·2 code點我硬讀diff確認(interaction:990/997 reserve補傳state第4arg、own_granary零改=非guard、tap純記錄)·根pin漂亮(runtime trace:reserve state=null DEFAULT+barter漏傳)·★此slice目的=解12mo量測封鎖→gate須親證:①full 12mo horizon crash-confirm(fix後跨全horizon own_granary null crash=0、或若冒出別的null-caller報file:line;implementer 3360t+ clean但自報detach/wrapper長run flaky提早死=tooling非code、你godot-detach.ps1 WMI-parented撐長run)②owner_reason_by_team永久tap dump值合理(camp/takeover/capture分布=T3轉正驗)③determinism spot(post-fix seed1337可复728d62ef=補傳型byte-identical、你若順手驗)·★byte-identical注記:窗內一致(barter多非自家糧倉格→own_granary兩側null)、12mo若bartering隊在自家糧倉才分岔=正確行為修非退回(gate④措辭:post-fix自身三跑一致非vs pre-fix baseline)·跑法godot --path .worktrees/own-granary-pin對branch跑(worktree應在)、baseline=main·出.measure.json落地exact path·★若12mo tooling-blocked跑不完(非crash是flaky死)報我=另開tooling issue、fix核心gate已branch驗綠仍可議merge·地基KEEP"
---

# own_granary pin 12mo bounded merge-gate

branch=`feat/own-granary-pin` e8ad1cb8。2 code 點**我硬讀 diff 確認**：interaction:990/997 `reserve(...,state)` 補傳第 4 arg、**own_granary 零改**（=非 guard）、tap 純記錄。根 pin 漂亮（runtime trace: reserve `state=null` DEFAULT + barter 漏傳）。

## ★此 slice 目的=解 12mo 量測封鎖 → gate 須親證
1. **full 12mo horizon crash-confirm**：fix 後跨全 horizon own_granary null crash **=0**；或若冒出**別的** null-caller → 報 file:line（implementer 穷尽稱 barter 唯一 live 源、_calc_reserve 死碼/decision_context 武器非食/player_trade 无玩家；12mo 驗此負斷言）。implementer 3360t+ clean 但自報 detach/wrapper 長 run flaky 提早死=**tooling 非 code** → 你 `godot-detach.ps1` WMI-parented 撐長 run。
2. **owner_reason_by_team 永久 tap dump 值合理**（camp/takeover/capture 分布=T3 轉正驗）。
3. **determinism spot**（順手）：post-fix seed1337 可复 728d62ef（補傳型 byte-identical）。

## ★byte-identical 注記
窗內一致（barter 多非自家糧倉格→own_granary 兩側 null）；**12mo 若 bartering 隊剛好在自家糧倉才分岔=正確行為修非退回**（gate④措辭：post-fix 自身三跑一致、非 vs pre-fix baseline）。

## 跑法
`godot --path .worktrees/own-granary-pin` 對 branch 跑、baseline=main。出 `.measure.json` **落地 exact path**。
★**若 12mo tooling-blocked 跑不完**（非 crash 是 flaky 死）→ **報我**、另開 tooling issue；fix 核心 gate 已 branch 驗綠、仍可議 merge。

綠 → 我 merge → S2（L0 階梯）。地基 KEEP。
