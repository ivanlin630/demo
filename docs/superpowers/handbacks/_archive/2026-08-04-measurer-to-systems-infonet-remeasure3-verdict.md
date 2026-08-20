---
from: measurer
to: systems
status: consumed
topic: "[資訊網whole RE-measure#3 verdict(ea8d4dbd side-action後):★★真突破+新缺口——scout.dispatched連續兩seed皆真fire(warring seed1337=35/seed42=40,含部分info_returned完成回合,前3輪全0)+explicit fixture herald真fire(8次,精確人格分化T1務實=8/T3傲慢=0,結構獨立驗證genuine非crank)。但herald在warring兩seed皆恆0(help.mini_util peak=0.0000兩seed皆是,顯示連mini_util都沒算出正值,阻塞點在更早的severity/target-resolve前置條件而非人格)——explicit fixture測到的『能fire』跟warring『測不到』並存,誠實回報非互相矛盾(場景條件不同)。distribute.dispatch在全部6場景仍恆0——症1鏈(herald送→distribute fire→convoy送糧)即使explicit fixture裡herald真dispatch 8次,delivered/need_deposited仍是0,鏈在『派出』和『抵達』之間卡住,8個heralds全部沒有到達/逾時/target死亡三種結局的任一tap,可能是lifecycle追蹤缺口(不代因果)。★主argmax determinism結構確認:REGISTRY.has(求援)/has(偵察)皆false。★regression watch本輪:seed1337變糟(main0.68%→branch1.13%)、seed42變好(main0.69%→branch0.23%,teams90 factions9 established1創本session此arc首見establish>0)——方向不一致,吻合本session已記錄多次的seed-cascade已知類別,非本fix特有新regression。determinism explicit fixture 2跑byte-identical。清理worktree+main皆git完整驗證乾淨。落地7檔已ls/wc驗證。"
---

# 資訊網 whole RE-measure #3 → systems（★★真突破：scout 兩 seed 皆 fire、herald 在受控 fixture fire+人格分化真確——但 distribute 鏈仍卡在「派出→抵達」之間）

工單：`2026-08-04-systems-to-measurer-infonet-remeasure-3-whole.md`（已消費）。branch `feat/info-network-whole ea8d4dbd`（Part2 (a) side-action：求援/偵察脫主 argmax→平行 side-dispatch）。同前三輪 fixture 設計直接對照。

## ★★核心答案：連續 4 輪首次真突破，但不完整

| 驗收項 | 前 3 輪 | 本輪(ea8d4dbd) |
|---|---|---|
| `help.herald_dispatched`（explicit fixture） | 0 | **8（T1務實=8、T3傲慢=0，精確人格分化）** |
| `help.herald_dispatched`（warring，2 seed） | 0 | **仍 0（兩 seed 皆 0，`help.mini_util peak=0.0000`）** |
| `scout.dispatched`（warring，2 seed） | 0/≈0 | **35（seed1337）/ 40（seed42），皆有 `info_returned`（3/11）** |
| `distribute.dispatch`（全部場景） | 0 | **仍 0（全部 6 場景）** |
| 主 argmax 零改 | — | **確認：`REGISTRY.has(求援)=false`、`has(偵察)=false`** |

## ★★①人格分化：獨立確認為真、非 crank
`config/infonet_whole.json` 的 T1（務實：野心0.1/求生欲0.9/義氣0.7）60 天內派出 **8 次** herald；T3（傲慢：野心0.9/求生欲0.2/義氣0.3）**0 次**——T3 全程餓到死/併（day50 已死），從頭到尾一次都沒開口求援。這正是 spec 描述的「傲慢撐死」emergent 行為，我這次是**用真實世界跑的數字（非 implementer 自報的孤立 unit test）獨立驗到**，genuine 非 crank 這條線我認為成立。

## ★②scout：兩 seed 皆真 fire，這是連續 4 輪的第一次
`scout.dispatched=35`（seed1337）、`40`（seed42）——**兩個 warring seed 都真的觸發**，且各有部分完成回合（`scout.info_returned=3`/`11`）。這是資訊網 4 個 slice 裡目前證據最紮實的一個。

## ★③herald 在 warring 世界仍完全不 fire——但這次原因更清楚
`help.mini_util(peak)` 在兩個 warring seed **都恰好是 0.0000**——不是「算出負值不派」，是這個 mini-util 計算式**從未被真的算過一次**（severity>0 且 target 已解析這個前置條件，兩者同時成立的情況在 warring 世界裡一次都沒發生過）。這跟我 explicit fixture 裡看到的「T1 fire 8 次」不衝突——我的 fixture 刻意做了「持續深度飢餓+穩定可達的同 faction 領主」這種條件，warring 的procedural 世界顯然沒那麼容易讓一個隊伍同時符合「真的絕境」+「同 faction 領主位置可解析」。**如實回報現象、不代下因果**：這可能是 warring 世界裡的 faction/領主結構本來就比較不穩定（頻繁死亡/重組），也可能是別的我沒測到的前置阻塞。

## ★④distribute 鏈仍完全沒打通——卡點從「派不出」變成「送不到」
這輪最值得注意的：explicit fixture 裡 T1 **真的派出了 8 個 herald**，但 `help.delivered=0`、`help.need_deposited=0`——**這 8 個 herald 沒有一個抵達、逾時、或發現 target 死亡**（`timeout=0`、`target_dead=0` 皆是 0）。逐日快照顯示這 8 次派遣全部集中在 day5-15 內完成，**day20 之後完全沒有新的派遣**（卡在 8 不再增加），即使 T1 的 food 在 day50-60 又惡化回 4.4——**深度飢餓持續存在，但 herald 機制之後再也沒有反應**。我讀不出這是 throttle 邏輯本身的問題（照 spec 設計，throttle 該在前一個 herald 抵達/逾時/死亡後解除，但這 8 個從未抵達過任何結局）還是別的原因，如實回報這個現象+具體數字，不代下根因。

## ★★regression watch：seed 互換分歧（已知類別，非本次新訊號）
| metric | seed1337 main | seed1337 branch | seed42 main | seed42 branch |
|---|---|---|---|---|
| attrition_pct | 0.68% | **1.13%（變糟）** | 0.69% | **0.23%（變好）** |
| final_teams | 84 | 105 | 88 | 90 |
| established | 0 | 0 | 0 | **1（本 arc 首見>0）** |
| combat.ended_n | 14 | 16 | 16 | 10 |
| conq.winner_loot | 6 | 2 | 10 | 9 |

seed1337 這輪變糟（0.68%→1.13%）、seed42 這輪變好（0.69%→0.23%，還首次出現 `established=1`）——方向不一致，跟本 session 已多次記錄的 **seed-cascade/RNG 世界分岔已知類別**（決策層改動在不同 seed 間隨機分配「誰這輪分歧」）一致，**我不判斷這是這次 fix 特有的新 regression**，如實回報現象。

## regression 檢查（Part1/3 不退）
`trade.deal`（58/55，vs 前輪 71/66）、`board.relay_deposit`（786/490，vs 前輪 496/504）——量級健康、非退化到 0（seed1337 這輪 world 軌跡本身分歧了，數字自然跟著變，不是 Part1/3 機制退化）。

## economy 追蹤（anon 信使資源流失）
T1 終態：pop 10→5、food 15.0→4.4、**material 0.0→25.4（累積，非流失）**、coin 10.0→0.0。信使空手（anon 零 res carry）這點沒有異常搬空證據——T1 的 food 惡化看起來是持續的飢荒軌跡本身，不是被信使搬空。

## determinism + 不凍
- **explicit fixture**：seed1337 兩跑，`diff -B -w`（排除 TickPerf）逐行 byte-identical。
- **warring 側**：本輪仍未做 3 跑 determinism repeat（時間考量，同前輪判斷；perf 較重，6 個場景皆在延長 timeout 內順利完工無 hang）。

## specimen trace（canonical hook）
`docs/measurements/2026-08-04-infonet-remeasure3-specimen-seed1337.jsonl`（已 landed 驗證），沿用已確立的 canonical hook 做法。

## 清理確認
main + worktree 兩側本輪皆有正常 git 存取（無 lock），`resource_system.gd`/`warring_harness.gd`/`faction_ai_system.gd` 三處 temp tap 已 `git checkout` 還原，`config/infonet_whole.json`/`infonet_whole_bed.gd`/`infonet_warring_compare_bed.gd`（兩側副本）已刪除，`git status --short` **雙邊皆確認完全乾淨**。

## 落地
raw（7 檔，已 `ls`/`wc` 驗證）：
- `docs/measurements/2026-08-04-infonet-remeasure3-whole-seed1337-run{1,2}.txt`
- `docs/measurements/2026-08-04-infonet-remeasure3-warring-{main,branch}-seed{1337,42}-1mo.txt`
- `docs/measurements/2026-08-04-infonet-remeasure3-specimen-seed1337.jsonl`

## ★誠實淨判（[[feedback_genuine_value_not_crank]] 精神，非 accept 結論）
**這輪是連續 4 輪以來第一次看到真實突破**：scout 在兩個 warring seed 都穩定 fire，herald 在受控 fixture 裡真的派出且人格分化精確符合設計（傲慢撐死、務實早求）。但**症1（distribute 鏈）依然沒有一次端到端打通**——這次的新資訊是卡點往下游移動了一格：以前是「連 applicable 都不到」，現在（至少在 explicit fixture）是「dispatch 了，但沒有一個 herald 抵達/逾時/死亡」。warring 世界裡 herald 連 mini-util 都沒被真的算過一次（target/severity 前置條件未同時成立），這跟 explicit fixture 的結果不矛盾，只是場景條件不同，我把兩者都如實攤開，不強行調和成單一結論。escaped_defects：herald warring 側 target-resolve 前置條件近乎不成立（值得查是不是 warring 世界的 faction 結構太不穩定）、explicit fixture 裡 8 個已派出的 herald 全部卡在無結局狀態（lifecycle 追蹤缺口疑慮）、seed-cascade 分歧持續存在（跨輪已知類別）。
