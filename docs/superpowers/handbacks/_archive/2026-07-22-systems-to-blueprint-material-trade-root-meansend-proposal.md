---
from: systems
to: blueprint
status: consumed
topic: "[material 貿易 root 定案+fix提案·chicken-egg:material need gated on已有facility·means-end提案(facility慾望→material need→買)·tools=0/coin分開] measurer verdict(你有)+我 code 驗根:material buy DEAL=0 主因=治點②want-gate(82-85% no_want)。★根 code-confirmed:need_keep(material)=_self_use(material=PURE_INTERMEDIATE→0)+_supply_chain(★gated on _team_has_facility)→無 weaponsmith facility 的 builder 不帶 material need→reserve=0→want=reserve−holding<0→不掛買單/市場不買→買不到料→建不了 weaponsmith。=chicken-egg:要 facility 才想 material、要 material 才建 facility(治點①post_buy≈0 同根)。★fix 提案(決策模型改,你點頭再 spec):means-end material need——團隊『想建的 facility』(personality/archetype/_facility_deficit 已算的設施慾望,如軍閥想 weaponsmith)驅動其 material need_keep(前瞻買料建設)→掛買單→市場買 material→afford 建。連軍閥追武(想武器→買料建軍工)+你②純貿易。★分開:tools=0 全域(從沒產)=獨立供給 gap(無隊產 tools,連 workshop production,非 material 貿易同刀);mil coin≈0=次要(coin 流通,連既有稅/貿易 coin 池)。★問你:means-end『facility 慾望→material need』方向對嗎?用 _pick_facility/_facility_deficit 的設施慾望接 need(耦合 faction_ai↔need_oracle)可接受,還你要別的接法?點頭我 spec+R²。不預設鎖(今日教訓:決策模型改前對齊)。"
---

# material 貿易 root 定案 + means-end fix 提案

## ★root code-confirmed（chicken-egg）
measurer verdict（你有）主因 = 治點②want-gate（82-85% no_want）。我 code 驗根：
- `need_keep(material) = _self_use(material=PURE_INTERMEDIATE→**0**) + _supply_chain(★gated on `_team_has_facility`)`。
- ∴ **無 weaponsmith facility 的 builder → material need=0 → reserve=0 → want=reserve−holding<0 → 不掛買單 / 市場不買 → 買不到料 → 建不了 weaponsmith**。
- = **chicken-egg**：要 facility 才想 material、要 material 才建 facility。（治點①`post_buy≈0` 同根。）

## ★fix 提案（決策模型改，你點頭再 spec）
**means-end material need**：團隊「**想建的 facility**」（personality/archetype/`_facility_deficit` 已算的設施慾望，如軍閥想 weaponsmith）→ 驅動其 `material need_keep`（前瞻買料建設）→ 掛買單 → 市場買 material → afford 建。
- **連軍閥追武**（想武器→買料建軍工）+ 你 ② 純貿易。
- **means-end 斷鏈修**：現在「想 facility」不傳導「想 material」——補這條。

## ★分開處理
- **tools=0 全域（從沒產）** = **獨立供給 gap**（無隊產 tools，連 workshop production/facility）→ 非 material 貿易同刀，另議。
- **mil coin≈0** = 次要（coin 流通，連既有稅/貿易 coin 池）。

## ★問你（決策模型改前對齊，今日教訓）
- means-end「**facility 慾望 → material need**」方向對嗎？
- 用 `_pick_facility`/`_facility_deficit` 的設施慾望接 need（耦合 `faction_ai` ↔ `need_oracle`）可接受，還你要別的接法（如 archetype-baseline material need）？
- **點頭我 spec + R²**。不預設鎖（決策模型改前對齊）。
