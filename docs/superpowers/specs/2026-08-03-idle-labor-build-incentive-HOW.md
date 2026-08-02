# B：idle-labor→建設 genuine 激勵 HOW（2026-08-03）

**WHAT owner**：blueprint（用戶裁 B）。**HOW**：systems。**目標**：領導軸 size-matter——大隊 idle PRODUCE 勞力（pool−Σ設施 demand-cap）＝**真浪費** → 建產能用它＝genuine 期望價值 → 大隊早建 facility → size 真 matter（治 §8 領導軸 ratio 0.38-0.45）。★**genuine 非 crank**（乙教訓）：build util 升**因雇用閒勞力真期望產出**、禁 flat 建造分數 boost。

## §0 grounding（file:line、Q1-Q6）
- **Q1 建設**（options.gd:40-45）：`applicable 恆 true`、`terms=[settle_fit(0.4 const)、ambition_drive(ambition_gap×0.3)]`（terms.gd:116,193）。**labor-blind**。建**新 facility 類型**（§8 measurer 證 day50 建 manufacturing 新增第3線 fill=1.0）。
- **Q2 紮營**（options.gd:168-176）：`food_days<DESPERATION AND has_farmable AND NOT has_own_outpost`、camp_drive=1.0。**labor-blind + 絕境 gated + 有 outpost 不能 found 第2個**。
- **Q3 recruit ABSENT** / **Q4 militarize ABSENT**（TASK_TRAIN 是野心階梯非 pop→軍）。
- **Q5 idle 可算**：`labor_system.pool_of(state,tile)`（Σ 共址 PRODUCE pop）+ `tile.labor_alloc[k].demand`（rebalance 存）。**但 DecisionContext 無 idle_labor 欄、決策從不呼 LaborSystem**（intake gap）。
- **Q6 產能家族**：建設/紮營/佔村/訓練/吸納；★guardrail 排除 combat/survival/trade/move/social。

## §1 idle_labor intake（新 ctx 欄、唯一 channel）
`DecisionContext.idle_labor`（gather 時算、team 所在 tile）：
```
pool  = LaborSystem.pool_of(state, tile)              # Σ 共址 PRODUCE pop
dcap  = Σ tile.labor_alloc[k].demand （所有 active workstation）  # 現產能吸得掉的手數
idle_labor = maxf(pool - dcap, 0.0)                   # 超產能的閒 PRODUCE 勞力=真浪費
```
- **只 PRODUCE**（軍隊 TAG_MILITARY 天然不在 pool_of → guardrail 自然、碰不到預備軍）。
- lazy：labor_alloc 已 per-tile 存（勞力池 cadence）、直讀不重算（頻率解耦沿用）。

## §2 genuine idle-labor 價值項（★只加產能投資、genuine 非 crank）
**核心 genuine 論證**：建一座 facility 類型 T（新增 workstation demand `d_T`）→ 雇用 `min(idle_labor, d_T)` 閒手 → 那些手產 `d_T`-worth 輸出 × rate × **need_value(T 的產物)** ＝**真期望產出**（need-weighted、非憑空）。
- **建設 util += `idle_employ_value`**（terms.gd 建設 drive 或 settle_fit 擴）：
  `idle_employ_value = min(idle_labor, D_NEW_WORKSTATION) × PER_HAND_OUTPUT × need_weight(candidate facility 產物)`
  - `D_NEW_WORKSTATION`：待建 facility 新增的 demand（level×K_MFG）。
  - `need_weight`：走 need_oracle（該產物 need_keep+demand）＝**只在真需求的產能才有價值**（無需求貨的 facility idle-value=0、不亂建）。
  - **self-limit**：idle_labor 隨 facility 吸收遞減 → 建到夠就停（genuine、非無限建）。
- **禁 crank**：非 `建設 util += K×(idle>0)` flat boost；是 `× 真雇用手數 × 真產物 need_value`（雇用閒勞力真期望產出）。無需求/無閒勞力 → term=0。

## §3 guardrail（scope 硬約束、R² grep 硬檢）
- **idle-labor term 只加 `建設`**（MVP、develop 路）。**禁漏進** combat/survival/trade/move/social（grep 無 idle_labor 在那些 drive）。
- **只 PRODUCE-idle**（pool_of 天然排軍隊）。
- **憲法決策**：idle_labor 是 util 的 genuine 輸入項、非硬 gate（無 `if idle>X` 階梯、連續乘）。

## §4 ★三路張力 gap flag（呈 blueprint 裁 scope）
blueprint 要 develop/spread/defend 三路 need 秤，但 grounding 顯：
- **develop（建設）**：本 spec 加 idle-labor＝MVP 直修 §8 根（大隊建 manufacturing 用掉閒勞力、正是 day50 證的行為只是更早）。✓
- **spread（開新據點）**：**紮營 gated NOT has_own_outpost + 絕境**——**大隊有 outpost 無法 found 第2據點**。要 spread 需 **un-gate 紮營（允許有 outpost 也 found）+ 加 idle-labor 觸發**＝新 applicable、中 scope。
- **defend（militarize）**：**ABSENT**（無 pop→軍決策）＝新決策、大 scope。
- **recruit（壓招募）**：**ABSENT**（pop 非決策）＝「壓過度招募」無對象。
- ∴ **MVP＝建設-only（develop 路、直修 §8 領導軸）**；**spread/militarize/recruit 三路完整張力需新/un-gate 決策＝blueprint 裁要不要本 arc 做**（我建議 MVP 先驗 §8 追平、spread/militarize 另 slice，避免一次過大）。

## §5 dev-verify + §8 re-measure（交付前+measurer）
- **dev-verify 硬斷**：
  1. **idle→build 因果**：team pool>Σdemand（idle>0）+ 有真需求可建 facility → 建設 util 升 → 選建（vs idle=0 不升）。
  2. **genuine 非 crank**：idle=0 → term=0（不亂建）；無需求產物 → need_weight=0 → term=0（不建沒用的）。
  3. **guardrail**：grep idle_labor 只在建設 drive、combat/survival/trade/move 零。
  4. determinism 三跑 byte-identical + gates 綠 + headless baseline。
- **★§8 re-measure（measurer、真世界驗才宣稱）**：領導軸 ratio——大隊**真早 build up 產能 + 產出 ratio → 追平/超 1**？（同 §8 框架、誠實 measured 非搬數字、[[feedback_genuine_value_not_crank]]）。

## §6 工序
本 spec → **R² 自審**（genuine 非 crank/guardrail 無漏/憲法非 gate/gap flag）→ reviewer R²（gap flag 一併裁）→ implementer（隔離 `feat/idle-labor-build`）→ dev-verify → §8 re-measure 領導軸 → §5 合量（labor pool+甲）。labor pool 506aaa64 別 revert（foundation 對）。
