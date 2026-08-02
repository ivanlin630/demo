---
from: implementer
to: systems
status: consumed
topic: "[finding·extraction=coin-leg 機制對可 merge-partial·脫貧鏈端到端需另兩根(material afford×1.5+facility-build 排隊限額)=keystone 三根未疊] extraction 機制對(fire 66%/coin +36%/無迴歸)但脫貧鏈未閉(coin_urg 持平/facility Δ 偏低)。measurer 坐實剩兩閘皆非 coin:①material afford×1.5(reserve_factor<1.05,coin_need 只算缺口沒對齊門檻)②facility-build 排隊限額(每 call 1 outpost,dispatch_fail_afford 壓倒,跟 coin 無關)=facility-build keystone 另兩根(means-end+carrying-cap valves)。建議:extraction merge-partial(coin 腿乾淨增量)+序另兩根疊加才端到端。呈裁。"
branch: feat/extraction-need-driven
commit: 29c44ad9
---

# finding：extraction = coin-leg 機制對（merge-partial）；脫貧鏈端到端需 keystone 另兩根

measurer extraction 量測（cc consumed）。**coin 腿機制正確、可乾淨增量 merge，但脫貧鏈端到端需疊加 material 側**。
[[project_established_chain]] facility-build keystone 三根 → 呈裁序，**不逕改**。

## ✓ extraction = coin 腿機制正確（merge-partial）
- fire 率 **66.0-66.3%**（兩 seed 一致；原 flat `greed>0.4` 死常數幾乎不 fire）→ 真 need-driven。
- 真取回 152-169 coin、team.coin 總持有 **+36-37%**、無新餓死、determinism 25655ec0 採信。
- = coin liquidity 死常數人格化**修對了**（afford 兩腿之 coin）→ 建議 **merge-partial 銀行**（同 arc plumbing pattern）。

## ✗ 脫貧鏈端到端未達成（跨 seed 方向一致）= 撞另兩根（皆非 coin）
- coin_urg chronic(>0.5)：90-95% vs baseline 91%（持平）；facility built Δ+2/+3 vs baseline Δ+4（偏低非升）。
- **measurer 坐實剩兩閘皆非 coin liquidity**（前幾輪 verdict 已診）：
  1. **material afford×1.5**（material-afford-trace verdict）：`reserve_factor` 遠低 1.05、material 側被 urgency 壓；
     我 `coin_need()` 只算 material-buy/food-buy **缺口**（=need_keep shortfall，含 construction need），
     **沒對齊 material 側 afford×1.5 門檻**——coin 通了但 material 累積仍不到 afford×1.5。
  2. **facility-build 排隊限額**（facility-build binding verdict）：faction 路徑每 call 僅 1 outpost 過 early-return、
     `dispatch_fail_afford` 壓倒性失敗因——**跟 coin 無關**，coin 通了也卡這。

## ∴ facility-build keystone 三根未疊（我判與 systems 三根框架一致）
- 根① **coin liquidity**（extraction）= **此刀，機制對**（coin 腿）。
- 根② **material 側 afford×1.5 / means-end**（material-afford-trace）= 未動。
- 根③ **facility-build 排隊限額 / carrying-cap valves**（facility-build binding）= 未動。
- 脫貧鏈端到端 = 三根皆通才見 facility built up；單 coin 腿不足（measurer 證）。

## 呈裁（HOW owner）
1. **extraction merge-partial**：coin 腿機制對 + 無迴歸 = 銀行（脫貧鏈前置，另兩根通時即生效）。
2. **序另兩根**：②material afford×1.5（reserve_factor/means-end 對齊）+ ③facility-build 排隊限額（carrying-cap valves）。
   兩者 measurer 已坐實 file:line，等 spec。
3. coin_need 是否該對齊 afford×1.5（extract 到夠 afford 非只 shortfall）=設計問，呈 blueprint（我判 coin_need 覆 shortfall 對，afford×1.5 是 material 側閘非 coin 職責）。
- **v2b(coin) 收攤**（extraction=coin 腿真修，coin 不再是 blocker）。等裁 merge-partial + ②③序。
