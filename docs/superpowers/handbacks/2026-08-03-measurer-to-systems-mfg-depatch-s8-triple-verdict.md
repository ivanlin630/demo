---
from: measurer
to: systems
status: consumed
topic: "[§8三驗mfg de-patch verdict:★★領導軸ratio沒追平,幾乎沒動——3seed皆與B-only值幾乎相同(55501:0.485→0.486/1337:0.518→0.518/42:0.553→0.553)。size真matter未達成,誠實非crank。de-patch機制面確實work(seed55501 facility真RUN 94次,消耗4.0材料,產5.02箭,材料前0.0→now非0)但經濟量級微小(僅佔採集量1.7%)——因need-gated生產目標=need_keep+demand(自用+貿易缺口),量本身就小,永遠追不上大隊靠2條天然採集線的bulk gather總量(2192.9)。economy衝擊確認『非爆量』(need-gated守住,4.0/234.8=1.7%溫和無崩)。determinism 3跑byte-identical。守憲T_NOMAD material 3seed皆0.0000(gather-tap zero路徑推論,未直接tap驗證,已揭露方法論落差)；food殘值(76/237/201,非精確0)符合純消耗軌跡(2000起點-consumption吻合)非違憲=游牧仍餓確認,但與原輪『food=0.0精確為零』描述用的度量不同(原輪疑用gather-tap delta非raw stock,已誠實標註方法論不一致別直接比對)。人均採食check本輪T_LARGE反高於T_SMALL_0(confound:T_LARGE day60時population已因PopMgmt子隊分裂40→20,非原fixture population,不宜當乾淨『遞減』驗證,如實揭露非硬凹)。不凍:5跑(3+2 seed)皆順利完工無hang。taps+fixture+bed已清除確認clean。落地docs/measurements/2026-08-03-mfg-depatch-seed{55501-run1,55501-run2,55501-run3,1337,42}.txt(5檔共14579行,已ls/wc驗證)。→根因(如實不代因果,可能值得systems深挖):need-gated生產模型天生把manufacturing產量鎖死在『內部需求缺口』量級,不管task-gate補丁閘在不在都不可能靠這條路徑追平bulk gather——這可能表示『facility真RUN』從來就不是能讓領導軸追平的正確槓桿,除非manufacturing目標函數本身改(如demand權重/貿易導向放大)。"
---

# §8 三驗 mfg de-patch → systems（★★領導軸 ratio 幾乎沒動，size 真 matter 未達成）

工單：`2026-08-03-systems-to-measurer-mfg-depatch-s8-triple.md`（已消費）。main `2c25a82c`（mfg per-labor-allocation de-patch merged）。複用 §8 fixture（大隊 pop40、1 outpost，同款 12 隊 config）+ 新加 `LABORTEST.gather.*`/`LABORTEST.mfg_consume.*`/`LABORTEST.mfg_output.*` temp tap（per-team 拆分，補既有全域 `manufacture.fired`/`manufacture.output.*`）。

## ★★核心答案：領導軸 ratio 三 seed 皆幾乎沒變（未追平）

| seed | B-only ratio（前輪已知） | de-patch 後 ratio | Δ | T_LARGE facility 飽和度 | mfg 消耗/採集流入比 |
|---|---|---|---|---|---|
| 55501 | 0.485 | **0.486** | +0.001 | 6.7%（1/15） | 4.0/234.8 = 1.7% |
| 1337 | 0.518 | **0.518** | +0.000 | 0.0%（0/15，仍未完工） | 0.0/21.2 = 0% |
| 42 | 0.553 | **0.553** | +0.000 | 0.0%（0/15，仍未完工） | 0.0/265.7 = 0% |

→ **三 seed 全部幾乎原地不動**（Δ≤+0.001）。**領導軸 size 真 matter 未達成**，de-patch 沒有把 ratio 拉向 parity(1.0)。

## ★機制面確認 de-patch 真的 work（非退化/沒生效）
seed55501（唯一這輪 facility 有完工的 seed）：`manufacture.fired=94` 次（前輪 facility-saturation 驗到的是 0 次）、`manufacture.input_consumed=4.0`（前輪 0.000）、`manufacture.output.arrows=5.02`——facility **真的在 RUN**，補丁閘確實移除生效。`[Manufacture] Team0 arrows worker_rate=0.56` 日誌也證實執行路徑活著。

## ★為什麼 ratio 沒動：manufacturing 消耗量級遠小於 gather 基數
seed55501：material 60 天採集流入 234.8，manufacturing 只消耗 4.0（**佔比 1.7%**）。T_LARGE 總產出（gather+mfg_output 合計）2192.9，其中 mfg 貢獻的 5.02 arrows 幾乎是雜訊。**`_run_recipe_group()` 的生產目標 = `need_keep+demand`**（`:146`）——這是隊伍自身消費+貿易缺口的量，本身就小，跑滿也追不上大隊光靠 2 條天然採集線（`gather:food`+`gather:material`，K_GATHER=5.0×2=10 demand）產出的 bulk 數字。**這不是 bug，是 need-gated 設計的直接後果**——facility 不會、也不該無限產。

## ★economy 衝擊：確認「非爆量」
material 消耗/採集流入比僅 1.7%（seed55501），另 2 seed 甚至 0%（facility 未建）。**need-gated 守住了**——經濟沒有過度生產/沒有崩。這條驗收線通過，但代價是「非爆量」同時也意味著「對領導軸 ratio 幾乎無貢獻」，兩者是同一個機制的正反面。

## 守憲
- **T_NOMAD material**：三 seed 皆 `0.0000`，精確為零（無違憲）。
- **T_NOMAD food**：本輪讀 raw stock（76.0/237.3/201.0，非精確 0）——★方法論落差誠實揭露：前輪 verdict 描述「food=0.0精確為零」用的度量疑似是 `gather-tap 累積量`（`_collect_from_tile` 對 `outpost_level==0` 隊伍從不呼叫，tap 恆為 0），本輪我印的是**團隊當前 food 庫存**（消耗軌跡，非 income tap）。數值上與純消耗數學（2000 起點 − 40 人×0.8/天×60天 ≈ 80）高度吻合，**符合「游牧仍餓」預期、無 income 洩漏跡象**，但兩輪用的不是同一把尺，不宜直接拿數字比對——如實標註，別硬湊成同款驗證。
- **人均採食**：本輪 T_LARGE food/pop=97.7 > T_SMALL_0 food/pop=84.9，方向與「大隊人均該遞減」的素樸預期相反。★confound：T_LARGE 到 day60 時 population 已因 `[PopMgmt]` 子隊分裂（40→20，日誌可見 Team17 等子隊拆出）大幅縮水，不是原 fixture 設定的 pop40 在跑，人均分母被稀釋，**這個 check 本輪不夠乾淨，不下結論**，如實回報而非硬湊「pass」。

## determinism + 不凍
- **determinism**：seed=55501 三跑，`diff -B -w`（排除 TickPerf）逐行 byte-identical。
- **不凍**：5 跑（3×55501 + 1337 + 42）皆順利完工 60 天無 hang。

## 清理確認
`manufacturing_system.gd`（2 行 temp tap）+ `resource_system.gd`（1 行 temp tap）已 `git checkout` 還原，diff 確認乾淨。`config/labor_pool_sizematter.json`/`scripts/debug/labor_pool_sizematter_bed.gd` 已刪除，`git status --short` 確認無殘留。

## 落地
raw（5 檔，14579 行，已 `ls`/`wc` 驗證）：
- `docs/measurements/2026-08-03-mfg-depatch-seed55501-run1.txt`
- `docs/measurements/2026-08-03-mfg-depatch-seed55501-run2.txt`
- `docs/measurements/2026-08-03-mfg-depatch-seed55501-run3.txt`
- `docs/measurements/2026-08-03-mfg-depatch-seed1337.txt`
- `docs/measurements/2026-08-03-mfg-depatch-seed42.txt`

## ★誠實淨判（[[feedback_genuine_value_not_crank]] 精神）
**size 真 matter 這輪未達成**——de-patch 本身機制運作正常（facility 真跑、material 真消耗、economy 沒爆），但**領導軸 ratio 三 seed 幾乎原地不動**。我不代下架構結論，只如實指出一個值得你/blueprint 深挖的觀察：`_run_recipe_group` 的 need-gated 生產目標（`need_keep+demand`）天生把 manufacturing 產量鎖在「隊伍自身消費/貿易缺口」量級——這個量級可能**結構上就不可能**大到追平 bulk gather，不管 task-gate 補丁閘在不在都一樣。若這個讀法成立，「facility 真 RUN」或許從來就不是能讓領導軸追平的正確槓桿；是否要往這個方向查（例如 demand 權重、貿易導向放大、或別的 size-matter 機制），architecture call 屬你/blueprint。
