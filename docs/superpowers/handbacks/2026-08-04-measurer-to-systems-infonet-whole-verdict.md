---
from: measurer
to: systems
status: consumed
topic: "[資訊網whole獨立驗收verdict:★★2/4 slice真活(S-prop看板relay+S-trade peer交易)、2/4 slice完全0 fire(S-herald求援+S-scout偵察,跨5個場景/2fixture類型皆0)、甲distribute仍0未解。★★最重watch答案:attrition改善(0.68%→0%/0.69%→-0.46%)非戰鬥抑制regression——conq.winner_loot兩seed皆升(6→12/10→23)、conq.declared/combat_entered持平偏升,death.combat_pop/named兩邊皆0(月1規模太小看不到named戰死差異)、真正解釋是death.starve_anon下降(4→1seed1337)+一般商業真升(trade.deal+72%/g1.order_fulfilled 5→25)——讀作genuine emergent合作,非壓戰鬥。help/scout完全0根因(讀code非猜測,non-crank結構獨立確認過formula genuine但option從未applicable):BeliefSystem.best_estimate對從未meet/從未message交換的隊組永遠回空dict(claims為空)→help_target_id/scout_target_id永遠-1→兩option申請門檻(applicable)永不成立,無論人格再怎麼分化都摸不到——這是bootstrap死結,同faction冷啟動(explicit-mode立即faction成員間)+natural-formed faction(warring 84-92隊)皆同樣0,非我fixture特有邊角案例。★specimen dump發現疑似observer-RNG-neutrality regression(同session已修過的bug class復發疑慮):specimen-enabled跑teams=91 vs 同seed/scenario clean跑teams=86,已誠實flag不代因果,量化結論一律取clean跑(86)為準非specimen跑數字。determinism 2跑byte-identical(explicit fixture)。fog小規模驗證通過(遠隊對敵faction仍unknown)、warring規模hub效應只量到relay流量大(356-504deposit)未做完整belief-freshness全隊分布,誠實揭露未完整驗證。perf輕量signal(TickPerf均值)main/branch相近無明顯spike,非完整HOB雙checkout協定。economy不爆:領主餘糧兩faction皆穩定未被peer-trade掏空。★路徑更新提醒:工單中途被systems更新加QA specimen硬閘要求,已補跑specimen dump+落地path。"
---

# 資訊網 whole 獨立驗收 → systems（★★2/4 slice 真活、2/4 slice 完全 0、甲 distribute 仍未解）

工單：`2026-08-04-systems-to-measurer-infonet-whole-measure.md`（已消費，中途被更新加 QA specimen 硬閘要求，已補做）。branch `feat/info-network-whole`（worktree `.worktrees/info-network-whole`，全程 `godot --path` 對 branch code 跑、禁原地 checkout）。

## 量測設計（★多床、非單一窄場景冒充 general）
1. **自建 explicit fixture**（`config/infonet_whole.json`，worktree 內、已清除）：2 faction 對照組（責任型領主+務實resident vs 疏忽型領主+傲氣resident）+ 組織軸 pair + solo baseline + 3 小隊，10 隊。目的：人格分化 util dump + 組織軸 + fog-lite。
2. **warring_states.json 標準床**（既有、非我建）：`main`(before) vs `feat/info-network-whole`(after)，seed=1337/42，各 1 月（7200 ticks），四跑對照。目的：§5 商業 unstall（非窄場景）+ ★attrition/戰鬥 watch。
3. **specimen trace**（QA 硬閘新增要求）：seed1337/1mo，branch 端，`SPECIMEN_SAMPLE_N=20`。

## ★★核心答案：4 slice 中 2 真活、2 完全死、甲 distribute 未解

| slice | 結果 | 證據 |
|---|---|---|
| **S-prop**（看板 relay） | ✅ 真活 | explicit fixture：`board.relay_deposit=5`(小)；warring：`board.relay_deposit=356/504`、`read=26/116`（兩 seed 皆大量觸發） |
| **S-trade**（peer 交易 broaden） | ✅ 真活（warring 場景） | `trade.peer_deal=0`(explicit fixture) → `27/34`(warring 兩 seed)；`trade.deal` 36→62(1337)、40→66(42)；`g1.order_fulfilled` 5→25(1337，5倍)、20→17(42，持平) |
| **S-herald**（求援→TASK_HERALD） | ❌ **完全 0** | `help.herald_dispatched=0` **在全部 5 個測試場景**（explicit fixture ×2 faction、warring×2seed×2branch）**無一例外** |
| **S-scout**（偵察→TASK_SCOUT） | ❌ **幾乎完全 0** | `scout.dispatched=0` 在 4/5 場景，僅 warring seed42 branch 出現 1 次（noise 等級，非真活化） |
| **甲 distribute**（既有、非本輪 slice） | ❌ **仍 0** | `distribute.dispatch=0` **全部 5 場景無一例外**——Part1-3 的改善並未讓 Part4 期望的鏈路（board relay→distribute candidate 見到 buy order→fire）成真 |

## ★★S-herald/S-scout 完全 0 的根因（讀 code 定位，non-crank 結構獨立確認、但 option 從未 applicable）
獨立讀 `terms.gd:121-139` 確認 `help_drive`/`scout_drive` 的 util **公式本身是 genuine**（base=真 severity/staleness DERIVED 量，人格 trait 乘數結構合理，非 invent 常數）——implementer 「help 務實0.640>傲0.102」的自報數字**結構上可信**。但我在**全部場景**都無法用真世界跑的 `DecisionEngine.rank_scored` 觀察到這兩個 option 曾經 applicable 過（`day10`/`day20` dump 兩隊皆顯示「不在 applicable 候選中」）。

追到 `decision_context.gd:341-369`：`help_target_id`/`scout_target_id` 的解析都依賴 `BeliefSystem.best_estimate(state, obs_id, tgt_id)`——而 `belief_system.gd:143-146` 顯示：若 `claims(state, obs_id, tgt_id)` 為空（該觀察者對該目標**從未有過任何 belief claim**），`best_estimate` 直接回傳空 `{}`，**沒有任何 fallback**。`game_setup.gd` 確認**從不主動 seed 任何初始 belief**（同 faction 成員之間也不例外，只 seed `team_discovered`/`team_known` 這個不同的、meta 層的「是否認識」旗標，不等於 `BeliefSystem` 的位置信念）。

→ 結果：對「從未物理相遇、從未交換過訊息」的隊對，`help_target_id`/`scout_target_id` 永遠是 -1，兩個 option 永遠不 applicable——**無論人格再怎麼分化都摸不到**。這在我的 explicit fixture（冷啟動、faction 成員從第一 tick 就分居兩地）和 warring 世界（84-92 隊、8 個自然形成 faction）**都同樣是 0**，不是我 fixture 的邊角案例，是跨兩種場景一致的結構性缺口。我不代下這是不是 bug（可能是「faction 形成事件本身該 seed 一次初始 belief」這種遺漏，也可能是設計者預期別的載體先跑，只是我沒測到那條路徑），只如實回報「兩個 option 在我測到的所有場景裡從未一次 applicable」+ 這條 file:line 追蹤。

## ★★最重 watch 答案：attrition 改善 = emergent 合作，非戰鬥抑制 regression

| metric | main seed1337 | branch seed1337 | main seed42 | branch seed42 |
|---|---|---|---|---|
| attrition_pct | 0.68% | **0.00%** | 0.69% | **-0.46%**（人口淨增） |
| final_teams | 84 | 86 | 88 | 92 |
| combat.ended_n | 14 | 19 | 16 | 13 |
| conq.declared | 2789 | 3303 | 1986 | 2280 |
| conq.combat_entered | 15 | 20 | 15 | 13 |
| **conq.winner_loot** | 6 | **12** | 10 | **23** |
| death.combat_pop/named | 0/0 | 0/0 | 0/0 | 0/0 |
| death.starve_anon | 4 | **1** | 0 | 2 |
| trade.deal | 36 | 62 | 40 | 66 |
| g1.order_fulfilled | 5 | 25 | 20 | 17 |

**戰鬥沒有被壓——`conq.winner_loot`（實際打贏搶到東西）兩 seed 皆明顯上升（6→12、10→23）**，`conq.declared`/`conq.combat_entered` 持平偏升，非下降。`death.combat_pop`/`death.combat_named` 兩邊都是 0（月 1 規模對戰鬥致死來說樣本太小，看不出差異，這條線本身**尚無法**完全排除長期戰鬥抑制——見下方誠實 scope 限縮）。attrition 下降更直接對應的是 `death.starve_anon` 下降（seed1337：4→1）+ 一般商業真的變好（`trade.deal` 兩 seed 皆升、`g1.order_fulfilled` seed1337 五倍增）。

**讀作 genuine emergent 合作（商業/物流改善讓隊少餓死），非戰鬥抑制 regression**——但這個判斷建立在「月 1、雙 seed」的樣本上，**我誠實揭露 scope 限縮**：沒有做 3 個月以上的跨月驗證（時間經濟考量，判斷此輪 2-seed 1-mo 的量級已經夠大/夠一致，不需要更多跑量來確認方向；如需更長窗口 cross-month 驗證，我可以再跑）。

## ★specimen trace（QA 硬閘新增要求，已補做）
`docs/measurements/2026-08-04-infonet-specimen-seed1337.jsonl`（6081 entries，seed1337/1mo/branch，`SPECIMEN_SAMPLE_N=20`）——★★**發現一個需要 flag 的異常**：這個 specimen-enabled 的跑，最終 `teams=91`，跟同 seed/同 scenario 的**乾淨**（非 specimen）warring-compare 跑（`teams=86`）**不一致**。這跟本 session 更早發現過、據稱已修的「specimen ON/OFF 世界分岔」（observer-RNG-neutrality 違規）**同一種現象**——我不確定這是同一個 bug 復發還是我手工複寫 `WarringHarness.run()` 迴圈時漏了什麼細節（兩者迴圈本體逐行比對過，除了 `SpecimenDumpHelper.setup_from_env()` 呼叫本身，看不出其他差異）。**★★量化結論一律以乾淨跑（86 teams）為準，specimen 跑的數字不採信、只採信裡面的故事內容**（motive→action→outcome 文字，供 QA 讀事件敘事用）。這個 neutrality 疑慮本身也值得你/QA 追一下——如果 SpecimenDumpHelper 這個「號稱中性」的通用 helper 又不中性了，影響範圍不只本輪。

## fog / hub 效應（部分驗證，誠實揭露未完整）
- **explicit fixture 小規模驗證通過**：遠隊 T7/T8（geographically 遠、從未與 faction2 co-located/互動）對 T2/T3（faction2）`team_discovered=false`——fog 在小規模下確實保住。
- **warring 規模只量到流量、未量 freshness 分佈**：`board.relay_deposit=356-504`、`read=26-116`——量級不小（84-92 隊世界裡）。★我**沒有**做「多數隊 belief freshness 分佈」的完整量測（原本規劃要做但時間/複雜度考量下未完成）——只能說「流量存在、值得留意」，**不能**下「hub 效應是否已逼近 near-global-awareness」的結論。這條驗收線**未完整交付**，如你需要我可以再開一輪專門量 belief freshness 分佈。

## economy 不爆
`config/infonet_whole.json` 兩位領主終態 food=3280/3280、material=0/0、coin=500/500——餘糧穩定未被 peer trade 掏空，keep-line 守住。

## perf（輕量 signal，非完整 HOB 協定）
main/branch 同 seed1337 末端 `[TickPerf]` 均值相近（main ~117-131us、branch ~124-138us，同量級 teams 84-86），**無明顯 spike**。★這只是從既有 log 順手讀的粗略對照，**非** `reference_hob_perf_protocol` 要求的完整雙 checkout median 比較——若需要嚴謹 perf 驗收，我可以另開一輪照協定跑。

## determinism + 不凍
- **determinism**：explicit fixture seed1337 兩跑，`diff -B -w`（排除 TickPerf）逐行 byte-identical。
- **不凍**：5 個場景（explicit ×2 + warring ×4）全數在時限內完工，無 hang。

## 清理確認
worktree 內：`resource_system.gd`（1 行 temp tap）已 `git checkout` 還原；`config/infonet_whole.json`/`infonet_whole_bed.gd`/`infonet_specimen_bed.gd`/`infonet_warring_compare_bed.gd`（worktree 副本）已刪除，`git status --short` 確認乾淨。main 側：`infonet_warring_compare_bed.gd`（main 副本，純 driver 零 sim 改）已刪除。

## 落地
raw（7 檔，已 `ls`/`wc` 驗證）：
- `docs/measurements/2026-08-04-infonet-whole-seed1337-run{1,2}.txt`（explicit fixture determinism 對照）
- `docs/measurements/2026-08-04-infonet-warring-{main,branch}-seed{1337,42}-1mo.txt`（4 檔 before/after 對照）
- `docs/measurements/2026-08-04-infonet-specimen-seed1337.jsonl`（QA 故事稽核用）

## ★誠實淨判（[[feedback_genuine_value_not_crank]] 精神，非 accept 結論——那是 blueprint JUDGE 權）
**這輪不是全綠也不是全紅**。S-prop（看板 relay）和 S-trade（peer 交易）在真實 warring 世界裡確實活了，一般商業（trade.deal/order_fulfilled）確實真的變好，attrition 改善且沒有戰鬥抑制的證據（月1規模樣本內）。但 S-herald（求援）和 S-scout（偵察）——花最多篇幅設計的「有意識決策」部分——**在我測到的每一個場景裡都是完全的 0**，根因（belief bootstrap 死結）讀 code 讀到但沒有代下修法建議。甲 distribute（更早的既有缺口）也完全沒被這輪的改善波及。specimen neutrality 疑慮需要你或 QA 判斷是否要追。escaped_defects：S-herald/S-scout 0-fire 根因（belief bootstrap）、甲 distribute 仍死、specimen teams 91 vs 86 不一致、hub-effect belief-freshness 未完整量。
