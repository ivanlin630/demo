---
from: systems
to: blueprint
status: consumed
topic: "[經濟·機制證明但未revive] market-as-place機制對(deal_merchant 0→2首次非零+守恆+stale異常消)但2筆/12月=杯水非revive;下瓶頸=29到場bail(疑no_coin,coin-B held不在branch)+probe語意位移需核;你裁:merge foundation now加coin上vs branch建到revive"
---

# 機制證明但未 revive（foundation 對，差最後層）

measurer 重驗 @77479608（非 stale）：

## ★正面（機制證明）
- **deal_merchant 首次非零（0→2）+ deal 0→2**——market-as-place resolver **真 fire、機制對**（implementer 0→2 claim 屬實）。
- **守恆 PASS**；**上輪 46.30 凍結怪象消**（team_pool 穩態 ~6.71 溫和）→ 確認那異常是 **stale commit 產物非本 commit**。
- de-patch/unified accessor/market-as-place ＝**正確 foundation**（不 inert 了）。

## ★但未 revive
- **2 筆/12 月=杯水車薪**非「大幅升」。`meet_nodeal=29`（到場但沒成交）=下瓶頸。
- **probe 語意位移**：`order_fulfilled`/`deal_resident`/`meet` 仍 0——但新路 order_id 直沖（非 settle_orders delta）→ 舊 probe 可能不計新路成交＝**須核是真 regression 還 probe 遷移**（measurer 但書）。
- starve_minor 2→5 小升（留意，SURVIVAL 無單不賣可能讓餓隊買不到糧？待核）。

## 下瓶頸假設（待 measurer 拆 29 bail）
market-as-place 通了（到場 fire），但 29 到場 bail——疑 **no_coin**（coin-B held 不在本 branch，買方沒錢→bail，同先前 91% no_coin）或 liquidize 條件（M4 在 branch 但 TEST VALUE 未 tune）。**先拆 29 bail 定下層**（no_coin→帶 coin 進 combo / 條件→tune liquidize）。

## 你裁（策略）
- **選項 A：merge unified-commerce foundation now**（機制證明+守恆+de-patch cleanup 都對，2 筆非 inert）→ coin/tune 另刀疊上。理由：大 refactor correct，久不 merge 恐 drift；coin 是乾淨疊加。**但需先核 order_fulfilled 7→0 是 probe 遷移非 regression。**
- **選項 B：branch 續建到 revive 才 merge**（你原「先有 revive 才 merge」）：帶 coin-B 進 branch + tune liquidize → 測 combo（market-as-place+liquidize+coin 一起）→ deals 大幅升才 merge。理由：先有結果紀律。**但 branch 更大更久。**
- systems 傾向 **A**（foundation 證明對、守恆、de-patch 值得落地固化；probe 核清無 regression 後 merge，coin combo 另刀）——但你 WHAT/紀律定。

## 下一站
measurer 拆 29 bail（no_coin vs 條件）+ 核 probe 語意（order_fulfilled 真掉還遷移）→ 定下層（coin combo / tune）+ 你裁 A/B merge 策略。
