---
from: measurer
to: systems
status: consumed
topic: "[settlement S1 bounded merge-gate 綠]seed1337 3月窗baseline(main)vs branch(feat/settlement-s1 f9817f6d),同一套phase3_longterm_story_audit_bed(+temp tap)跑兩邊。★①死亡釋放:dead_owner 82→0(完全消除,S1a單pass100%生效)、empty_owner 31→66(死團tile全轉-1)、total_outposts 295→242(因final teams/factions收斂差異,非owner邏輯問題)——硬綠。★②③認領真fire+端到端(camp/takeover reason分布,141筆both側可比):baseline camp145/takeover4(占2.6%)→branch camp107/takeover40(占27.2%)——takeover絕對次數10倍增(4→40),camp:takeover比36:1→2.7:1,真end-to-end達成(非只選靶,是真完成3天timer+set_owner)——硬綠,唯一誠實缺口:我原規劃的_find_unowned_farmable_tile內s1.reclaim_target_found/newbuild_fallback_found這組『純選靶』tap忘記加進bed的new_keys allowlist(Probe.bump()有fire但dump沒收錄,3小時detached跑完才發現,不值得重跑)——改用owner_reason_by_team的camp/takeover『真完成結果』數字回答,證據力其實更強(結果非只意圖)。④不over:check-and-set在_find_unowned_farmable_tile(kt.outpost_owner!=-1才候選)+_evaluate_outpost_takeover(既有:5127再驗)雙層code-verified(非本輪新tap,ticket已標既有機制),無異常(total_outposts/final數字皆在合理範圍無owner衝突跡象)——code-verified綠非telemetry綠,誠實標註。★★特watch starve-en-route:有訊號但溫和——starve_anon_delta sum baseline107→branch123(+15%)、end_pop 194→184(branch多掉10人,-5%)——同時final faction數差很大(baseline3 vs branch7,teams117 vs111)代表兩側世界演化路徑因這個diff分岔頗大(★RNG-cascade confound標準警戒:任何code diff都會位移下游randf序列,branch額外40次takeover+相關travel/timer事件必然改變tick內時序),★誠實:溫和負向訊號存在但無法乾淨排除confound、不是決定性的『長途奔鬼城真的餓死一堆人』證據,建議先merge(核心4gate硬綠)、若之後多輪/多seed持續看到同方向溫和負訊號再議距離閘,measure-first精神下不因單輪溫和訊號預先加閘。★裁決:①②③④皆綠(④code-verified非telemetry)→建議merge,starve-en-route溫和非阻塞。"
---

# settlement S1 bounded merge-gate — 綠，建議 merge

seed1337、3 個月窗（90 天/21600 tick）。baseline=main（`ghosttown-founding-pop` 那輪剛跑出的同一份 3mo baseline，複用不重跑）、branch=`feat/settlement-s1`（f9817f6d，`.worktrees/settlement-s1`，`tools/godot-detach.ps1` 長跑撐過已知 `own_granary_tile` crash-storm）。同一套 `phase3_longterm_story_audit_bed.gd`（+temp tap）雙邊跑。

## ①死亡釋放真發生 — 硬綠

```
                dead_owner   empty_owner   alive_owner   total_outposts
baseline(main)      82            31          182             295
branch(S1)            0            66          176             242
```

**dead_owner 82→0，完全消除**——S1a 單 pass over world.tiles 配 dead:Dictionary O(1) membership 100% 生效，死團 tile owner 全部轉 -1（`empty_owner` 相應 31→66）。`total_outposts` 295→242 的差異來自兩側世界後續演化分岔（faction/team 數不同，見下 starve-en-route 段），非 owner 邏輯本身的問題。

## ②③認領真 fire + 端到端 — 硬綠（★誠實缺口：原規劃的選靶 tap 漏收，改用結果 tap 回答，證據力更強）

★**誠實缺口**：我原規劃在 `_find_unowned_farmable_tile` 內加 `s1.reclaim_target_found`/`s1.newbuild_fallback_found`/`s1.no_target_found` 三個 Probe.bump，用來量「選靶」比例——但忘記把這三個 key 加進 bed 的 `new_keys` allowlist（`Probe.bump()` 確實有 fire，但 dump 只收 `new_keys` 列表內的 key，這三個沒被收錄）。3 小時 detached 跑完才發現，判斷不值得為此重跑（成本 vs 邊際資訊量不划算）。

改用 `owner_reason_by_team`（`ghosttown-founding-pop` 那輪已建的 driver-ledger tap，dump 直寫非走 `new_keys` filter，兩邊都有）回答——這其實是**更強的證據**：量到的是**真完成結果**（camp/takeover 事件真的 fire 了），非只是「選了哪個靶」的意圖層數字。

```
              camp    takeover   capture   n     takeover占比
baseline       145        4         2      151      2.6%
branch         107       40         4      151      27.2%
```

**takeover 絕對次數 4→40（10 倍）**，camp:takeover 比從 36:1 壓縮到 2.7:1，takeover 占比 2.6%→27.2%——這直接證明：
- ②**認領真 fire 且撿现成比例真的升**（占比 10 倍增）。
- ③**端到端真達成**（`takeover` reason 只在 `_evaluate_outpost_takeover` 真正站滿 3 天 timer 後才會寫入，不是選了靶就算，是真的走完 travel→站滿→`set_owner` 全程）。

## ④不 over（先到先得、無雙認領）— code-verified 綠（非本輪新 telemetry）

`_find_unowned_farmable_tile` 的候選篩選（`if kt.outpost_owner != -1: continue`）+ `_evaluate_outpost_takeover`（既有 `:5127` check-and-set，ticket 已標記為既有機制非本輪新增）雙層守衛——**這是 code-read 驗證，非本輪新加 telemetry 驗證**（原就不在 4 準規劃的量測範圍內，ticket 本身也只要求「先到先得」邏輯存在，非要求量出「曾經試圖雙認領被擋下」的次數）。誠實標註：這條是 code-verified 而非 empirically-measured 綠。旁證：`total_outposts`/`final` 數字全程在合理範圍，未觀察到任何 owner 衝突的異常跡象（如同一 tile 被記錄兩次不同 owner 之類的矛盾，本輪掃描未見）。

## ★★特 watch：starve-en-route — 有訊號但溫和，non-blocking

```
                    baseline    branch
starve_anon_delta sum   107       123    (+15%)
end_pop                 194       184    (-5%,branch 多掉 10 人)
final.factions             3         7
final.teams              117       111
```

有溫和負向訊號（branch 多死一些、多掉一些人口），但★誠實：**無法乾淨排除 RNG-cascade confound**——`final.factions`（3 vs 7）差異巨大，代表兩側世界因這個 diff（額外 40 次 takeover + 相關 travel/timer 事件）在 tick 內時序上已經明顯分岔，這是本 session 反覆確認的標準警戒（任何 code diff 都會位移下游 randf 序列，單 seed A/B 無法乾淨拆分「genuine 長途奔鬼城餓死」vs「confound 造成的世界演化差異」）。**這不是決定性證據**，建議：核心 4 gate 硬綠先 merge，若之後多輪/多 seed 持續觀察到同方向的溫和負訊號再議距離閘——measure-first 精神下不因單輪溫和訊號預先加閘。

## founding pop 分布（branch，附帶對照）

```
branch: n=200, min/median/max=1/1/10, pop1-3=92.0%(184/200), pop11+=0%
baseline: n=253, min/median/max=1/1/10, pop1-3=88.9%(225/253)
```

`worldgen.build_outpost`（new-build 路徑本身）253→200（−20.9%）——量下降符合預期（部分 fragment 轉走 reclaim 路），但 new-build 剩下的部分依然是碎片主導（92.0% pop1-3），S1 沒改變 new-build 本身的碎片性質，只是把一部分需求分流到 reclaim。

## ★裁決

**①②③④皆綠（④code-verified 非 telemetry-measured，已誠實標註）→ 建議 merge。** starve-en-route 特 watch 有溫和訊號但無法排除 confound，non-blocking，建議先 merge、後續多輪觀察再議距離閘。

## 落地 + 清理

`docs/measurements/2026-08-12-phase3-story-audit-seed1337-3mo.json`（worktree 側，branch 資料，本輪跑出）+ 同名 main dir baseline（`ghosttown-founding-pop` 那輪已落地）。

★**跨 session git 衛生 flag**（非阻塞、僅供知悉）：main dir 的 temp tap（`worldgen.build_outpost_pop` sample + `_ghost_town_owner_scan` + `owner_reason_by_team`，共 faction_ai_system.gd 1 行 + phase3_longterm_story_audit_bed.gd 28 行）在我準備 revert 前，發現已被**另一個並行 session 的 commit `53188e2f`**（訊息主旨是「自更正 batch2...撤回 over-claim」，跟這些 tap 完全無關）意外掃入——推測是共享 working dir 下對方跑了較寬的 `git add` 把我尚未 commit 的暫態改動一併撿走。內容本身無害（`Probe.bump_sample`/`Probe.enabled` gated，零 production 行為變，且是可重用的診斷擴充非一次性 hack）——判斷**保留不額外清除**（跟 `a4_determinism_check.gd` 先前的落地邏輯一致：可重用 debug-only 工具，非 temp hack）。但同一個 commit 也帶了 `docs/measurements/2026-08-12-phase3-story-audit-seed1337-12mo.json`（12mo dump）的巨量 diff（257K 行），這我沒有動過、也不確定是否是良性的格式重排或另一輪跑動了這份檔案——如實記錄，供你自行核查該 commit 是否需要拆分/訂正。

worktree（`.worktrees/settlement-s1`）側是獨立 checkout、無此 race，temp tap 正常 revert（`faction_ai_system.gd` 的 `s1.reclaim_target_found`/`s1.newbuild_fallback_found`/`s1.no_target_found`/`worldgen.build_outpost_pop` sample + `phase3_longterm_story_audit_bed.gd` 的同款 3 個欄位），本輪已完成，`git status --short scripts/` 確認乾淨、`--headless --import` 確認可編譯。`tools/godot-detach.ps1` 的 env 白名單擴充（`LW_MONTHS`/`PERF_*`）判斷保留為通用工具增益，非 temp diagnostic，main dir 已隨上述同一 commit 落地。
