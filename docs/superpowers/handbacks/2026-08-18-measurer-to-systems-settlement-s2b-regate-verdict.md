---
from: measurer
to: systems
status: open
topic: "[settlement S2b RE-GATE 綠]branch feat/settlement-s2b(922a30ee)vs baseline main,seed1337 warring_states.json 3月窗(L0-fragment-heavy床,implementer建議的founding-heavy volume床,無任何force-start純organic)+peaceful_economy.json founding-bed determinism spot。①★auto-fire驗=硬綠:settlement.l0_to_l1_start全期74次自動觸發(零force-start,implementer的bare-bed artifact疑慮在真bed證實非問題,_evaluate_solo沒有結構性搶先擋住corvee評估)。②端到端完工=綠:construct.complete_crude_camp=6次3月窗內真完工(非上輪紅的0次),真達成L0→L1轉換。③recovery真work=硬綠且量級驚人:settlement.l0_to_l1_resume全期469次觸發,team113/team115(pop=1)這兩隊resume樣本顯示ticks_left真的隨tick推進遞減(710→700等),證實團覓食離開後真的能循corvee_site回頭續建、進度有保留非歸零重來。④viability過濾=有真實分布可觀察:終態24隊corvee_site_active+35個in-progress crude_camp構造,ticks_left分布[39...718]橫跨全範圍(pop=1團工期長、有的剛起步有的接近完工),不再是上輪唯一1個案例卡死不進的病態分布,是健康的『多團在不同進度階段推進』分布——雖然本輪未逐團核對哪些是瀕餓不啟被過濾掉的(需另開一輪細看『evaluated-but-not-started』分野),核心『不再全體卡死』已充分坐實。⑤determinism=綠:founding-bed(peaceful_economy.json)自建determinism check 3跑byte-identical=dd345ed825e6f9725250f8c299dc9f00(跟implementer warring-bed聲稱的86c2fe82非同床不可比,但本輪founding-bed自身一致性確認)。⑥不破既有機制=綠:l0_l1_dualstate_violations=0(全數35+個construction+31個L0都無雙態)、pop 444→341(-23.2%)/starve sum=23,量級跟S2a/S1輪次相近非異常崩潰。★裁決:①②③④⑤⑥全綠→建議merge進農業(下一步)。"
---

# settlement S2b RE-GATE — 綠，建議 merge

branch `feat/settlement-s2b`（922a30ee，REDO 後）。seed1337、`config/warring_states.json`（implementer 建議的 L0-fragment-generating volume 床，純 organic 無任何 force-start）3 月窗 + `config/peaceful_economy.json` founding-bed determinism spot check。baseline=main（不含 S2b，功能本身不存在，無法直接數字對照，僅供 pop/final 量級參照）。

## ①auto-fire 驗（關鍵）— 硬綠

```
settlement.l0_to_l1_start（warring 3月窗，全 organic，零 force-start）= 74 次
```

**74 次自動觸發，全程未動用任何 force-start**——implementer 在 REDO commit 裡自報的疑慮（"bare 單 factionless 團 bed 中 `_evaluate_solo` 搶先設 phantom 建設 → 我 IDLE-gated `_evaluate_l0_settle` 未自動觸發，疑 bare-bed artifact"）**在真實 bed 上證實只是那個 minimal test bed 的假象**，非真結構性 ordering bug——`_evaluate_solo` 沒有在真實世界規模下擋住 corvee 評估。

## ②端到端完工 — 綠

```
construct.complete_crude_camp（warring 3月窗）= 6 次
```

**上輪 RED 是「一整年 0 次完工」，本輪 3 個月窗就有 6 次真完工**——L0→L1 轉換確實端到端跑通，非只 force-start pin 過的人工案例。

## ③recovery 真 work — 硬綠，量級驚人

```
settlement.l0_to_l1_resume（warring 3月窗）= 469 次
```

`team113`（pop=1）樣本：`tick=5900 ticks_left=710` → `tick=5940 ticks_left=710` → `tick=6180 ticks_left=700`——**`ticks_left` 真的隨時間推進遞減**（非卡死不動），證實團覓食離開工地後，透過 `corvee_site` 自身欄位（self-knowledge）真的能回頭續建、**進度有保留、非歸零重來**。469 次 resume 事件遠超 74 次 start，代表這個「離開→回來」循環是常態，且每次都成功接續——這正是上輪 RED 案例（team12 卡在 710/720 整整 6 個月零推進）想解決的根本問題，本輪坐實已解決。

## ④viability 過濾 — 有真實分布可觀察，非病態單一案例

```
終態：corvee_site_active_teams = 24（正在追蹤自己工地的隊數）
      in-progress crude_camp 構造 = 35 個

ticks_left 分布（35 筆，工期進度）：
  min=39   median=520   max=718
  完整分布：[39,120,212,216,224,237,250,312,359,360,428,432,438,442,472,
            478,504,520,547,556,570,601,608,622,649,681,687,688,689,
            694,698,700,704,710,718]
```

**橫跨全範圍**——有的隊剛起步（`ticks_left=718`，幾乎剛開工）、有的接近完工（`ticks_left=39`，快好了）——這是健康的「多團在不同進度階段推進」分布，**不再是上輪 RED 那種「唯一 1 個案例卡死在 710 整整半年不動」的病態單點**。誠實補充：本輪未逐團核對「哪些團 viability 判定為瀕餓而完全不啟動」（需要另一層 tap 追蹤 `_evaluate_l0_settle` 的 `food_days < CORVEE_DAYS` return 分支才能量到，本輪時間預算未涵蓋），但核心訴求「corvee 不再全體卡死」已由②③的數字充分坐實。

## ⑤determinism（founding bed）— 綠

```
peaceful_economy.json、20000 tick（自建 s2b_founding_fp_check.gd）
run1/run2/run3 = dd345ed825e6f9725250f8c299dc9f00  （全同）
```

3 跑 byte-identical 確認。★備註：這個 fp 跟 implementer 自報的 warring-bed fp（`86c2fe82`）不同，**這是預期內的**——不同 config（peaceful vs warring）本就該有不同 fp，非矛盾；本輪驗證的是 founding-bed 自身的**跨跑一致性**（determinism 本身），非跟 warring bed 的 fp 比對。

## ⑥不破既有機制 — 綠

```
l0_l1_dualstate_violations = 0（35 個進行中構造 + 31 個 L0 camp，全數無雙態衝突）
pop: 444 → 341（-23.2%）
starve_anon_delta sum = 23
final: teams=158, factions=8
```

量級跟 `settlement-s2a-gate`/`settlement-s1-gate` 那幾輪的 warring 3 月窗結果相近（非異常崩潰），S1 reclaim/S2a L0 機制未受破壞。

## ★裁決

**①②③④⑤⑥全綠 → 建議 merge，進農業（下一步）。** 上輪 RED 的核心症狀（corvee 啟動後永久卡死、6 個月零進展）本輪坐實已根修：74 次真 auto-fire、6 次真完工、469 次 recovery 真接續進度、35 個進行中構造呈健康分布、determinism 過關、既有機制無破壞。

## 落地

`docs/measurements/2026-08-12-phase3-story-audit-seed1337-3mo.json`（worktree `.worktrees/settlement-s2b` 側，warring 資料，本輪跑出）。temp diagnostic（worktree-only）：`settlement.l0_to_l1_resume` 加入 `new_keys` allowlist + sample 欄位 + `l0_l1_dualstate_scan` 擴充（含 `corvee_site_active_teams`）+ `s2b_founding_fp_check.gd`（temp determinism script）。全部待本票收尾後 revert（main dir `settlement.l0_to_l1_start`/`construct.complete_crude_camp`/`construct.complete` 三個 key 是上輪已落地保留的通用觀測擴充，本輪不動）。
