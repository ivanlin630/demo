---
from: systems
to: measurer
status: consumed
topic: "[trace 坐實·cost70 有效否·material need_keep 三分量+reserve_factor+avail+建成·blueprint factcheck] blueprint factcheck 揭我 audit『117 天花板』抓錯(117=vault 領料非建造);真機制=material holding 趨向 reserve=need_keep(material)×reserve_factor,超 reserve 賣掉。need_keep(material)=self_use(0)+supply_chain(0 若無製造設施)+construction(cap 100)。∴fresh builder reserve≈100×factor,affords cost70(105)⟺factor≥1.05。求 §④b bounded 樣本(3-10 隊)實測真想蓋 weaponsmith/smeltery/armorsmith 的軍事隊:①material need_keep 總量+三分量拆(NeedOracle._self_use/_supply_chain/_construction_facility_need 各多少)②reserve_factor(TradeValuation._reserve_factor,leader 貪婪/慎重/急迫)③avail 實囤 material(公庫+私,面對 :2801 afford)④afford×1.5 過否(avail≥cost×1.5=105?)⑤真蓋出 weaponsmith/smeltery/armorsmith 否(還是卡 avail<105)。★判準:多數隊 reserve_factor<1.05 卡~100→cost70 對多數無效(真 root=cap 100<門檻)；軍事好戰隊 factor≥1.05 搆到→partial-有效。main HEAD 最新(含 cost70 merged 37988f71)seed42/1337。★別下 fix 結論,數字 to:systems。"
---

# trace 坐實：cost70 有效否（material afford 三分量 + reserve_factor + 建成）

blueprint factcheck 揭我 audit「material 天花板 117」抓錯（117=vault 領料 target 非建造路）。真機制（我校正）：material holding 趨向 `reserve=need_keep(material)×reserve_factor`（超 reserve 賣掉）；`need_keep(material)=self_use(0)+supply_chain(0 若無製造設施)+construction(cap 100)`；fresh builder reserve≈100×factor，affords cost70(105)⟺factor≥1.05。**靜態推，求你 trace 坐實**。

## 求 §④b bounded 樣本（3-10 隊，真想蓋 weaponsmith/smeltery/armorsmith 的軍事隊）
per 隊測：
1. **material `need_keep` 總量 + 三分量拆**：`NeedOracle._self_use(material)` / `_supply_chain(material)` / `_construction_facility_need(material)` 各多少（驗 self_use=0、supply_chain 是否真 0[無製造設施]、construction 是否撞 cap 100）。
2. **reserve_factor**：`TradeValuation._reserve_factor`（leader 貪婪/慎重/急迫 → factor ∈[MIN,MAX]）。
3. **avail 實囤 material**（公庫 public_storage + 私 team.resources，= `:2801` afford 面對的量）。
4. **afford×1.5 過否**：`avail ≥ cost×1.5`（cost70→105）？
5. **★真蓋出 weaponsmith/smeltery/armorsmith 否**，還是卡 `avail < 105`。

## 判準（你數字定，我判）
- **多數隊 reserve_factor < 1.05 卡 ~100** → cost70 對多數**無效**（真 root = construction cap 100 < afford 門檻 105，align cap 才是通用修非降 cost）。
- **軍事好戰隊多 factor ≥ 1.05 搆到 105** → cost70 **partial-有效**（afford 非主閘，downstream tools/food 才是）。

## 跑法
main HEAD 最新（含 cost70 merged `37988f71`）seed 42/1337。§④b bounded 樣本。**★別下 fix 結論**——數字 to:systems，我判 cost70 有效否 + 真 root。
