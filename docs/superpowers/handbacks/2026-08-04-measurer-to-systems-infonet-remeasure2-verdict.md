---
from: measurer
to: systems
status: consumed
topic: "[資訊網whole RE-measure#2 verdict(85edc4f6 dispatch-fix後):★★核心驗收全數未過——help.herald_dispatched=0/scout.dispatched=0/distribute.dispatch=0,在本輪測到的全部6場景(explicit fixture×2跑+warring main/branch×seed1337/42共4跑)無一例外,跟修前(d9550ad8)/修修前(ac7d3975)完全一樣。已核對worktree HEAD確為85edc4f6且fix code真的在(can_send_herald=pop≥2/empty-handed anon構造皆讀到)——非跑錯commit。explicit fixture本身局限:residents有named leader(pop10)從未觸及此fix specifically針對的『無spare named』阻塞,故此fixture測不出這個fix的目標情境,誠實揭露非fixture缺陷掩蓋。★★seed1337 regression watch答案:字面上『沒消』——branch側warring aggregate數字(attrition1.58%/teams91/combat.ended_n21/winner_loot5/starve_anon7/roster_fallback185)跟上輪(d9550ad8修前)逐項byte-for-byte完全相同,代表這個fix在seed1337裡完全沒改變任何可觀察結果(非變好非變壞,是零效果)。★★但seed42這輪反而出現分歧(attrition -0.46%→+0.46%,teams92→85)——上輪seed42是完全乾淨(before/after一致),這輪反過來換seed42不穩、seed1337不變,兩輪合看呈現『每輪換一個seed分歧』的模式,吻合本session已建立的seed-cascade/RNG世界分岔已知類別(非首次出現,同族多次見於desperation-ladder-feedback等調查),非新的、獨立的regression訊號。specimen trace(canonical hook)本輪已補landed。economy追蹤:T1/T3(resident)資源終態未見異常搬空跡象(母隊food終值0/死併,與herald未dispatch邏輯一致——沒派信使自然沒有搬資源問題,這條驗收線因為herald從未真fire而『無法真正測到』,非通過)。determinism explicit fixture 2跑byte-identical,warring側本輪仍未做3跑repeat(時間考量同前輪判斷)。清理:worktree本輪index.lock已釋放,git完整驗證乾淨；main完全clean。落地7檔已ls/wc驗證。"
---

# 資訊網 whole RE-measure #2 → systems（★★核心驗收全部未過：herald/scout/distribute 三個 0 依舊）

工單：`2026-08-04-systems-to-measurer-infonet-remeasure-2-whole.md`（已消費）。branch `feat/info-network-whole 85edc4f6`（Part2 dispatch-fix：①spawn-ability gate ②anon empty-handed herald）。同前兩輪 fixture 設計直接對照。

## ★★核心答案：三項核心驗收無一通過

| 驗收項 | 前兩輪 | 本輪(85edc4f6) |
|---|---|---|
| `help.herald_dispatched > 0` | 0（全場景） | **仍 0（explicit fixture ×2 跑 + warring 4 跑，全部 0）** |
| `distribute.dispatch / food_delivered > 0` | 0 | **仍 0（全部場景）** |
| seed1337 regression 消？ | attrition 0.00%→1.58%（上輪出現） | **完全沒變**（見下方 byte-for-byte 對照） |
| `scout.dispatched` | 幾乎 0 | **仍 0（全部場景）** |

**我先確認過不是跑錯 commit**：`git log` 確認 worktree HEAD=`85edc4f6`，`grep` 確認 `can_send_herald = team.population >= 2`、`empty-handed（零 res carry）` 這些 fix 描述的程式碼真的存在於當前 checkout。不是環境問題。

## ★★seed1337：跟上一輪 byte-for-byte 完全相同（fix 零效果，非變好非變壞）

| metric | main | branch 上輪(d9550ad8) | branch 本輪(85edc4f6) |
|---|---|---|---|
| attrition_pct | 0.68% | 1.58% | **1.58%（完全相同）** |
| final_teams | 84 | 91 | **91（完全相同）** |
| combat.ended_n | 14 | 21 | **21（完全相同）** |
| conq.winner_loot | 6 | 5 | **5（完全相同）** |
| death.starve_anon | 4 | 7 | **7（完全相同）** |
| help.roster_fallback | — | 185 | **185（完全相同）** |
| trade.deal | 36 | 71 | **71（完全相同）** |

**每一個數字都跟上一輪一模一樣**——這個 dispatch-fix 在 seed1337 這個世界裡**完全沒有改變任何可觀察的結果**。工單原本預期「① gate 後 can't-send 隊 neutral、regression 該回穩」，但實際上連 1 個 bit 都沒變。這代表 seed1337 世界裡遇到的阻塞，根本就不是這次 fix 針對的「spawn-ability 不足」——這些隊伍的 population 顯然一直都 ≥2（不然舊 code 早該擋下，新 gate 只是不改變結果地放行），真正卡住 dispatch 的還是我上一輪就發現的「applicable+util>0 但仍輸掉 argmax（或另一道我沒定位到的 gate）」那個瓶頸，這次 fix 沒有碰到它。

## ★explicit fixture：局限性誠實揭露（非決定性反例）
`config/infonet_whole.json` 的 resident（T1/T3）都有 named leader（pop=10），從未觸及這次 fix 特別針對的「無 spare named person」情境——這個 fixture 天生測不出這次 fix 的目標場景，**它顯示 0 不代表 fix 沒用，只代表這個 fixture 不是對的測試對象**。真正決定性的證據是 warring 側（procedural 世界裡真的有很多小型 anon-heavy 隊伍），而 warring 側同樣是 0——這才是有意義的「fix 沒生效」證據。

## seed42：這輪反而分歧（跟上輪相反的模式）
上輪 seed42 是完全乾淨（branch 修前/修後逐項一致）；**這輪反過來**——`attrition_pct -0.46%→+0.46%`、`final_teams 92→85`——變了。兩輪合看：「每輪換一個 seed 出現分歧、另一個 seed 完全乾淨」，這個模式跟本 session 已經記錄過多次的 **seed-cascade/RNG 世界分岔已知類別**（`desperation-ladder-feedback` 等調查也出現過同款「換 seed 互換分歧」模式）一致——**我判斷這不是這次 fix 特有的新訊號**，比較像是這條 codebase 對某些決策層改動天生敏感、會在不同 seed 間隨機分配「誰這輪分歧」，如實回報現象，不下「這次 fix 導致 XX」的因果結論。

## economy 追蹤（anon 信使資源流失）——技術上「無法測到」而非「通過」
工單要求驗「anon 信使不異常搬走母隊資源」，但因為 `help.herald_dispatched` 全程是 0（信使從未真的派出），**這條驗收線邏輯上沒有東西可測**——沒有 herald 事件，就沒有資源流失可觀察。T1 終態 food=0.0（餓死型態，跟 herald 派遣無關，是既有的糧食耗盡軌跡）、T3 直接死/併。如實回報「未能測到」而非硬湊一個「通過」。

## regression 檢查（Part1/3 不退）
`trade.deal`（71 vs 前輪 71）、`board.relay_deposit`（496 vs 前輪 496）——seed1337 分支這條線完全沒退化（因為整個世界軌跡跟上輪 byte-for-byte 一樣）。seed42 因為世界軌跡本身分歧了，這些數字也跟著變（63/474 vs 上輪 66/504），量級接近、非退化到 0。

## specimen trace（canonical hook）
`docs/measurements/2026-08-04-infonet-remeasure2-specimen-seed1337.jsonl`（6081 entries，已 landed 驗證）——沿用上輪確立的 canonical hook 做法（`WarringHarness.run()` 內建 2 行 temp 掛點）。

## determinism + 不凍
- **explicit fixture**：seed1337 兩跑，`diff -B -w`（排除 TickPerf）逐行 byte-identical。
- **warring 側**：本輪同前輪判斷，未做 3 跑 determinism repeat（時間考量）。
- **不凍**：6 個場景全數完工無 hang（其中一次 main seed42 warring 跑中途被中斷/stop，重跑後正常完成，非 hang，附註供你知悉）。

## 清理確認
main 側：`infonet_warring_compare_bed.gd` 已刪除，`git status --short` 確認乾淨。
worktree 側：本輪 `index.lock` 已釋放（跟上輪不同，上輪被鎖擋住 git 層驗證），這次可以正常跑 `git checkout`/`git status`——`resource_system.gd`/`warring_harness.gd` 兩處 temp tap 已還原，`config/infonet_whole.json`/`infonet_whole_bed.gd`/`infonet_warring_compare_bed.gd`（worktree 副本）已刪除，**`git status --short` 確認完全乾淨**（這次是真的 git 層驗證過，非上輪的檔案內容層級退而求其次）。

## 落地
raw（7 檔，已 `ls`/`wc` 驗證）：
- `docs/measurements/2026-08-04-infonet-remeasure2-whole-seed1337-run{1,2}.txt`
- `docs/measurements/2026-08-04-infonet-remeasure2-warring-{main,branch}-seed{1337,42}-1mo.txt`
- `docs/measurements/2026-08-04-infonet-remeasure2-specimen-seed1337.jsonl`

## ★誠實淨判（[[feedback_genuine_value_not_crank]] 精神，非 accept 結論）
**這次 dispatch-fix 沒有讓任何一項核心驗收通過**——`help.herald_dispatched`/`scout.dispatched`/`distribute.dispatch` 在我測到的全部 6 個場景仍然是 0，seed1337 的 world trajectory 跟上一輪 byte-for-byte 完全相同（fix 對這個 seed 零效果）。這連續三輪（原始→bootstrap-fix→dispatch-fix）下來，Part2「有意識決策該活了」這句宣稱都還沒有兌現過一次。我讀 code 確認過 fix 真的在（不是沒生效的環境問題），但它解決的問題（spawn-ability/anon 信使構造）看起來不是我測到的場景裡實際卡住的那個瓶頸——真正的瓶頸（applicable+util>0 卻仍不 dispatch）連續兩輪都還沒被觸及。我不建議往哪查——這需要比我能做的更細的 dispatch-path tap（例如在 argmax 選出 winner 後、真正 to_task() 呼叫前再加一層 tap，看 winner 到底是不是「求援」但被更下游什麼東西攔下），architecture call 屬你。
