---
from: systems
to: reviewer
status: consumed
topic: "[R²審Part2 dispatch fix spec(2026-08-04-infonet-part2-dispatch-anon-herald-HOW.md,blueprint裁GO)·root=RE-measure揭bootstrap修好applicable但dispatch=0(_dispatch_help_herald:1446需spare named,小餓resident送不出)+seed1337 regression·fix兩part:①applicable gate於spawn-ability(can_send_herald=pop≥2,can_send_scout=named≥2,look-before-leap同has_buyable_food)→unexecutable永不進rank治regression+option誠實②求援herald reframe=anon 1人messenger(≠subteam無named leader,leader_id=-1,pop從anon扣1真成本,物理走+delay,simple distress內容我餓在X,途中可死真風險)·偵察保留named subteam互補待驗領主spare named·★審點:①gate genuine非crank(util一字不改,發不發=leader人格秤,gate=可執行性look-before-leap非crank)②anon carrier零特權知識(不讀target live state只送simple distress,名冊target_pos仍position-only組織常識,守5硬界)③determinism零新randf(spawn/travel確定性,死走既有encounter)④無框內平行求解器(reframe既有_dispatch_help_herald spawn路換非增殖)·CLEAN→build續feat/info-network-whole→re-measure(herald_dispatched>0+distribute>0+regression消)→QA"
---

# R² 審 Part2 dispatch fix（①gate + ②anon 信使、blueprint 裁 GO）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-part2-dispatch-anon-herald-HOW.md`
**WHAT 裁**：blueprint `anon-messenger-ruling`（①gate GO；②信使≠subteam=anon 1人跑腿=用戶核心例）。
**root**：RE-measure 揭 bootstrap 修好 applicable 但 dispatch=0（`_dispatch_help_herald:1446` 需 spare named、小餓 resident 送不出）+ seed1337 regression。

## 一句話修法
①applicable gate 於 spawn-ability（治 regression+誠實）；②求援 herald reframe=**anon 1人 messenger**（≠subteam、無 named leader、pop 扣 1、物理走+delay、simple distress、途中可死）。

## ★審點（R² refute checklist）
1. **①gate genuine 非 crank**：help/scout **util 一字不改**（發不發=leader 人格秤、傲撐/務實早求不變）；gate=**可執行性 look-before-leap**（`can_send_herald=pop≥2`、`can_send_scout=named≥2`、同 買糧 `has_buyable_food` 前例）、**非 crank 讓 fire**。確認 gate 是「能不能執行」非藉機動分數。
2. **★②anon carrier 零特權知識（守 5 硬界、②非新感知）**：anon 信使**不讀 target live state**（只送 simple distress「我餓、在 X」）、名冊 target_pos 仍 position-only 組織常識。確認**沒藉 anon carrier 開 god-view/live-state 後門**。`constitution_gate` 綠。
3. **determinism 零新 randf**：anon spawn/travel 確定性；途中死走既有 encounter 結算（不新引 RNG）。確認零新 randf。
4. **無框內平行求解器**：reframe 既有 `_dispatch_help_herald`（spawn 路：named subteam → anon 1人）、非增殖平行機制。confirm reframe 非新 solver。

## 邊界（spec 已列、可加戳）
- 偵察保留 named subteam（(b) 互補）+ `can_send_scout` gate；**待 re-measure 驗領主真有 spare named**（若普遍無→標 tracking 未來 scout 亦 anon）。
- pop≥2 gate + 1-pop 隊自己走（既有 relocate）不重複。

**CLEAN → 回 systems → build（續 `feat/info-network-whole`）→ re-measure whole（`help.herald_dispatched>0` + `distribute.dispatch/food_delivered>0` + seed1337 regression 消 + scout 領主假設驗、canonical harness）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 對用戶驗收。** 卡/BLOCKER → 報 `to:systems`。
