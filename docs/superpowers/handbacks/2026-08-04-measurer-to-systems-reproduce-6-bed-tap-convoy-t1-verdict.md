---
from: measurer
to: systems
status: open
topic: "reproducibility缺口解verdict:①已重現RE-measure#6 whole床(config/infonet_whole.json seed1337 10隊2勢力60天)against ff785b96,fixture+診斷床(infonet_whole_diag_bed.gd)本輪已commit進branch(0b599dc8,治reproducibility缺口不再ephemeral刪)②真值:(a)convoy-lifecycle——distribute.dispatch=6全數6次都到達convoy.deliver(arrive)tap,非黑洞,卡在settle站:僅1/6真settle(food_delivered=1.0),5/6在settle bail(sell_owner_no_coin×4/sell_ownerless×1)(b)T1死因——T1確派herald(detach 1 anon day1造成pop10→9)但day2-10連續掉到pop2遠超-1量級主因既有食物短缺;T3(從未派letter)同tick10080同步滅團,曲線形狀近似,讀作系統性餓死底線非機制特異or seed偶發,唯一送達1.0單位食物時機/量皆不足救援。★純觀測zero行為變,只交真值不下修結論，交systems定2 root"
---

# reproducibility 缺口解：convoy/T1 診斷真值（只交真值，不下修結論）

## ①重現 + persist 完成

- 重建你們要的 RE-measure#6 whole 床原始 setup（`config/infonet_whole.json`：seed1337、10 teams/2 factions、T0/T2 領主+T1/T3 餓 resident、60天），against `feat/info-network-whole ff785b96`。
- 寫診斷床 `scripts/debug/infonet_whole_diag_bed.gd`（照抄 implementer `convoy_t1_diag_bed.gd` 的手法，擴充成同時追 T1+T3）。
- **★★已 commit 進 branch，不再 ephemeral 刪**：`0b599dc8`（`config/infonet_whole.json` + `scripts/debug/infonet_whole_diag_bed.gd`，2 files, 258 insertions）。往後任何人可直接 `godot --path .worktrees/info-network-whole --script scripts/debug/infonet_whole_diag_bed.gd` 重跑，治死 reproducibility 缺口。
- `GODOT_TIMEOUT=1200`，純觀測（inline advance_tick，同 peaceful_economy_bed 手法，零 randf、零 sim-code 改），跑一次即可（非探索性不需 determinism 三跑）。

## ②(a) convoy-lifecycle 真值：★不是黑洞，卡在 settle 站

```
distribute.dispatch=6 convoy.deliver(arrive)=6 convoy.deliver_settled=1 distribute.deliver(settle)=1 food_delivered=1.0
convoy.deliver_bail_sell_owner_no_coin=4
convoy.deliver_bail_sell_ownerless=1
porter10 spawn@400 ldr=2001 pop=1 home(14,8)→market(18,14) cargo=food×29
  phases={OUTBOUND:5100, RETURN:5100} arrived=true cargo_min=3 → ★DELIVERED_then_gone
```

- **6/6 distribute.dispatch 全部到達 `convoy.deliver`(arrive) tap** —— 不是 spawn/travel/timeout/cull 黑洞，convoy 每次都真的走到市場。
- 卡點在 **settle 站**：6 次 arrive 裡只有 1 次真 settle（`distribute.deliver=1`／`food_delivered=1.0`），其餘 5 次在 settle 階段 bail：4 次 `sell_owner_no_coin`、1 次 `sell_ownerless`。
- 讀作：settle 邏輯走的是「賣方需要一個有現金的 owner」的交易路徑，5/6 次因為找不到有 coin 的 owner（或 order 已無 owner）被 bail 掉——這是純觀察到的 tap 分佈，**未讀 settle 實作 code，不下因果/修法結論**。
- 只追到 **1 個 porter id（team10）**橫跨全部 6 次 dispatch（同 id 重複被派出/merge 回/再派），非 6 個獨立 porter。log 也顯示同一 team10 在 day46 merge 回家（14,8）後，team_id=10 被 Team6 的無關 advisor-overflow 機制重用（day47-60 大量 `[Sub]Team6派出子隊Team10`/`[Merge]Team6←Team10`），跟 distribute convoy 無關，純 id 巧合重用，已排除混淆。

## ②(b) T1/T3 死因真值

**T1**：`alive_at_end=false death_tick=10080(day42) last_task=覓食 last_pop=2 min_pop=2`
- 確有派 herald：`letter_dispatched=true @tick100`（day1 內，detach 1 anon）。
- pop 逐日：day1=9(從10)、day2=8、day3=7(food已=0)、day4=7、day5=6...day10=2，之後穩定在2直到day41，day42滅團。
- herald 的 -1 anon 只能解釋 day1 那一步（10→9）；day2-10 又連掉 7 人（9→2）遠超 herald 單次代價，且 food 從 day1 末=10 一路降到 day3=0 並持續整段——起點本來就設計成近餓死（fixture food=15）。
- 讀作：**主因是既有食物短缺（fixture 設計本身），herald 造成的 -1 是真實但次要的加速項**，不是死亡主因。

**T3**：`alive_at_end=false death_tick=10080(day42) last_task=覓食 last_pop=2 min_pop=2`
- **從未派 letter**（`letter_dispatched=false`，人格「傲氣寧撐死不求援」設計符合預期）。
- pop 曲線形狀跟 T1 近似（day1=10維持到day9才開始掉→day17掉到2），food 同樣 day3 起長期=0。
- **T1/T3 死亡 tick 完全相同（10080=day42）**——兩隊一個有 herald 一個完全沒有，卻同日滅團，讀作**系統性餓死底線（同步觸發某種 pop 下限機制）而非機制特異或單純 seed 偶發**，但未查 code 確認同步的真實成因，不下因果結論。
- 全跑 60 天裡**唯一一次真 settle**（食物送達，仅 1.0 單位）恰好與 T1/T3 滅團同期（day42 前後），量級（1.0單位）跟時機都明顯不足以真正救援——observation only。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-04-infonet-whole-convoy-t1death-diagnostic-run.txt`（961 行，原始 print log）
- `docs/measurements/2026-08-04-infonet-whole-convoy-t1death-diagnostic.json`（646 行，結構化 dump，含逐 porter 生命站表 + T1/T3 全 task 序+pop/food 逐日）
- worktree 內同一份 JSON 也已落地：`.worktrees/info-network-whole/docs/measurements/2026-08-04-infonet-whole-convoy-t1death-diagnostic.json`

## 清理狀態

- 本輪唯一新增 code 是**依指示 persist** 的 `config/infonet_whole.json` + `scripts/debug/infonet_whole_diag_bed.gd`，已 commit（`0b599dc8`），**不清除**（跟過去每輪 revert 慣例不同，這是本工單明確授權的例外）。
- 未動任何 production code，零 randf，純觀測。
- worktree `git status --short` 除上述已 commit 的兩檔外，無殘留 diff。

★只交真值，未下修結論。交你們定 2 root。
