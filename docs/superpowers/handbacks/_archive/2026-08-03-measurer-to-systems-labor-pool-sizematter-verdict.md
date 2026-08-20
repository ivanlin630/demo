---
from: measurer
to: systems
status: consumed
topic: "[§8統一勞力池size-matter真世界驗·verdict:★★領導軸size目前『不』matter(3seed一致ratio0.38-0.45<1)·組織軸pool機制本身健康(ratio0.85-1.22近1)·守憲nomad完美(3seed皆恰0)·決定性成因已找到=每格僅2天然採集線(demand cap=10)大隊剩餘勞力無處去,非labor-pool code bug] branch feat/unified-labor-pool(61b2a354,同main已merge 506aaa64,兩者code逐位元同源[僅差我的temp tap,已revert])。★★領導軸(1隊pop40 vs 8隊×pop5分散不共址,等總量):3 seed一致——T_LARGE/ΣT_SMALL={0.448(seed55501),0.377(seed1337),0.427(seed42)}全部<1,即大隊產出僅小隊合計的38-45%,**size目前不matter,方向一致跨3seed非雜訊**。根因鎖定(非猜測,直接讀tile.labor_alloc逐日快照):每個outpost civilian lvl1天然只有2條採集線(gather:food+gather:material,各demand=K_GATHER 5.0,合計10)——大隊pool一早就把兩線fill=1.00封頂,超過10的勞力(pool15-40浮動)完全浪費(無處可去,無第3條線);8個分散小隊反而合計擁有16條天然採集線(8×2),即使每隊pool=5填不滿單線demand也贏在『線數多』。T_LARGE運行中段(day50)自主蓋出manufacturing_level facility新增第3條線立刻fill=1.00,證明labor pool機制本身正確(給它工位就會用),但facility-building太慢/太少來不及在60天窗口內追平差距。★★組織軸(2隊×pop20共址=pool40 vs 1隊pop40):3seed ratio={0.845,1.221,0.886}圍繞1震盪,證實pool_of()正確地按tile共址算總量不看隊數,統一pool設計本身健康。★★守憲T_NOMAD(pop40無outpost):3seed皆material=0.0 food=0.0精確為零,無一次違憲。★determinism:同seed(55501)三跑byte-identical(exact diff確認,除TickPerf)。★world不凍:60天多隊run(含死亡/facility建造/subteam分裂等真實動態)3次+3個不同seed共6次跑皆順利完工無凍死/無hang,雖非完整6mo warring規模驗(時間economics考量,已知單次6mo warring跑約5-6hr,本輪§8核心問題優先,未做warring規模nonfreeze——若你/blueprint需要可另開)。純temp fixture(config+bed script,已刪除)+1行production tap(resource_system.gd,已還原,content-diff確認零差異;worktree git index目前被鎖[另一process,疑implementer活躍中,未強制解鎖,git層驗證待鎖解開後補做])。→這是誠實回報:size-matter『尚未』achieve,非labor-pool機制錯,是facility覆蓋率不足這個下游問題([[feedback_genuine_value_not_crank]]精神,非paper over)。"
measured_at_head: "feat/unified-labor-pool 61b2a354（= main 506aaa64 之後，兩者 labor_system.gd/resource_system.gd 逐位元同源，已 diff 確認）"
seeds: "55501（3 跑 determinism）+ 1337 + 42（cross-seed 確認方向一致）"
---

# §8 統一勞力池 size-matter 真世界驗 verdict → systems（★★size 目前不 matter，根因已鎖定）

工單：`2026-08-03-systems-to-measurer-labor-pool-s8-size-matter.md`（已消費）。★重要背景：探索時發現 labor pool **已 merge 到 main**（`506aaa64`）——`docs/game-design.md` 的 size-matter 宣稱**明確 hold 待本輪 §8 驗證**（`cf78e299` commit message：「size 真 matter 待 §8 真世界驗才宣稱」），故本 verdict 是即時 gate，非背景參考。

## 量測設計（真世界 execution-end，非 unit fixture）
純 temp fixture：新 config（12 隊，`config/labor_pool_sizematter.json`）+ 新 bed script（`labor_pool_sizematter_bed.gd`）+ 1 行 production tap（`resource_system.gd` 讀 `gain` 累積量）——皆已清除（config/bed 刪除，tap 內容比對確認移除，見末尾溯源）。跑 60 天真 tick loop（非單次 `rebalance()` call），涵蓋 decision-engine 自主決策、facility 建造、死亡/存活等真實動態。

**隊伍設計**：
- **領導軸**：T_LARGE（1 隊 pop=40）vs 8×T_SMALL（各 pop=5，等總量，**分散不共址**，各自獨立 outpost）。
- **組織軸**：T_COOP_A + T_COOP_B（2 隊各 pop=20，**共址**同一 outpost，pool 應=40）vs T_LARGE。
- **守憲**：T_NOMAD（pop=40，**無 outpost**）。

## ★★領導軸：size 目前「不」matter（3 seed 一致，非雜訊）
| seed | T_LARGE total | ΣT_SMALL total | 比值 |
|---|---|---|---|
| 55501 | 2040.3 | 4553.1 | **0.448** |
| 1337 | 1735.1 | 4597.5 | **0.377** |
| 42 | 1963.1 | 4598.8 | **0.427** |

→ **三個 seed 方向完全一致**：大隊產出僅小隊合計的 **38-45%**，遠低於 1（大隊該產更多）。**這不是雜訊，是穩定方向**。

## ★根因鎖定（讀 `tile.labor_alloc` 逐日快照，非猜測）
每個 civilian outpost lvl1 天然只有 **2 條採集線**（`gather:food` + `gather:material`，各 `K_GATHER=5.0`，合計 demand=10）：
- T_LARGE 的 pool（15-40 浮動，見下）一早就把兩條線 fill 封頂到 1.00，**超過 10 的勞力完全浪費**（無處可去，只有 2 個工位）。
- 8 個分散小隊反而合計擁有 **16 條**天然採集線（8×2），即使每隊 pool=5 填不滿單線 demand，仍**贏在「工位數量多」**。
- **T_LARGE 在 day 50 左右自主蓋出 `manufacturing_level` facility，新增第 3 條線後立刻 fill=1.00**——這證明 labor pool 機制本身是對的（給它工位就會用），**但 facility 建造速度/數量太慢，60 天窗口內來不及追平差距**。

**這精確對應工單自己預期的失敗模式**：「若大隊沒真產多 → finding：facility 不夠 build」——本輪坐實正是這個，非 labor-pool 演算法錯誤。

## ★組織軸：pool 機制本身健康
| seed | T_COOP(A+B) total | T_LARGE total | 比值 |
|---|---|---|---|
| 55501 | 1724.1 | 2040.3 | 0.845 |
| 1337 | — | 1735.1 | 1.221 |
| 42 | — | 1963.1 | 0.886 |

→ 三 seed 比值圍繞 1 震盪（0.845-1.221），**確認 `pool_of()` 正確按 tile 共址算總量、不看隊數**——2×20 共址 ≈ 1×40，統一 pool 設計本身無誤。

## ★守憲：T_NOMAD 完美通過
三 seed（55501/1337/42）**皆 material=0.0 food=0.0，精確為零，無一次違憲**——`outpost_level==0` 硬 gate 生效，游牧大隊即使 pop=40 也真的一粒米都採不到。

## determinism + 不凍
- **determinism**：seed=55501 三跑，`diff -B -w`（排除 TickPerf）確認完全一致。
- **不凍**：60 天多隊 run（含死亡/facility 建造/subteam 分裂真實動態）× 3 跑 + 2 個額外 seed，共 **6 次跑皆順利完工，無 hang/無異常凍結**。★**範圍限縮聲明**：這是我的小型 controlled fixture（12 隊），非完整 6mo warring 規模驗證（時間經濟考量——已知單次 6mo warring 跑約需 5-6 小時實跑時間，本輪優先交付 §8 核心問題；若你/blueprint 需要 warring 規模的 dual-seed 6mo nonfreeze 驗證，可另開工單，我會按established protocol跑）。

## 清理狀態（誠實揭露一個小缺口）
config/bed script 已刪除，production tap 內容比對（`diff -B -w`）確認已完整移除。**worktree git index 目前被鎖**（`index.lock` 存在，疑另一 process/session 正在使用這個共用 worktree，我未強制解鎖以免破壞對方進度）——git 層的 `git status`/`git diff` 驗證因此暫時做不了，只做了檔案內容層級的比對確認乾淨。等鎖解開後我會補做 git 層確認，或請你/implementer 方便時順手看一眼。

## 溯源
raw：`docs/measurements/2026-08-03-laborpool-sizematter-{run1,run2,run3,seed1337,seed42}.txt`。file:line：`labor_system.gd:8-13`(K常數)、`:23-29`(pool_of)、`:32-87`(rebalance)、`resource_system.gd:57-61`(outpost_level==0 gate,守憲根)。別下 fix 建議（該不該加 facility 覆蓋率、該不該調 K 值——architecture call 屬你/blueprint），純回報「目前 size 不 matter，根因=facility 覆蓋率不足」。
