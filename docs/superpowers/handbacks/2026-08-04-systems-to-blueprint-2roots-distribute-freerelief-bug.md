---
from: systems
to: blueprint
status: consumed
topic: "[2 root定位(diagnostic重現#6 bed已persist 0b599dc8治缺口)·(a)機制bug=distribute賑濟走定價sell非免費直注:convoy非黑洞(6/6真arrive travel正常),卡settle站僅1/6真settle,5/6 bail sell_owner_no_coin×4/sell_ownerless×1·code-located(interaction:765 distribute注override_ask=local_value×price_factor):『免費仁君』路free_dist=(override_ask==0.0)實質UNREACHABLE(price_factor=(0.5+greed)/(0.5+honor)永不為0,max-honor仍pf≈0.33)→override_ask恆>0→distribute恆對餓resident定價→餓resident無coin→sell_owner_no_coin bail·=賑濟該直注gift卻走定價sell、免費路dead code=機制bug(info-net execution scope,你preview convoy issue=info-net)·fix:distribute→免費直注(override_ask=0領主給餓子民,relief=gift非交易,mini-util已用仁慈/責任gate該不該送,送了就給)·(b)T1死=系統性餓死底線非機制害死非seed:T1 pop10→2主因既有食物短缺(herald detach 1 anon negligible),T3從未派letter同tick同步滅團曲線近似=systemic starvation=economy-balance follow-up非fix-regression·∴blueprint兩concern清:(a)機制bug真存在→修(免費直注)、(b)T1死非fix害的=economy-balance(relief量級/timing不足救人,你preview判對)·序:fix(a)免費直注→R²→build→re-measure症1端到端(修後5/6該真settle糧真到resident)→若糧到但仍不足救=economy-balance follow-up→QA→arc-done判·誠實:機制最後一bug(免費路dead code)+T1死歸因清(非regression)·地基KEEP"
---

# 2 root 定位（diagnostic 重現 #6 bed、已 persist 0b599dc8 治 reproducibility 缺口）

## (a) ★機制 bug：distribute 賑濟走定價 sell、非免費直注
- **convoy 非黑洞**：6/6 真 arrive（travel 正常）、卡 **settle 站**——僅 1/6 真 settle、**5/6 bail（`sell_owner_no_coin×4 / sell_ownerless×1`）**。
- **code-located（`interaction:765`）**：distribute 注 `override_ask = local_value × price_factor`。**「免費/仁君」路 `free_dist=(override_ask==0.0)` 實質 UNREACHABLE**——`price_factor=(0.5+greed)/(0.5+honor)` **永不為 0**（max-honor 仍 pf≈0.33）→ override_ask 恆 >0 → **distribute 恆對餓 resident 定價 → 餓 resident 無 coin → `sell_owner_no_coin` bail**。
- ＝**賑濟該直注 gift、卻走定價 sell、免費路 dead code**＝機制 bug（info-net execution scope、你 preview convoy issue=info-net）。
- **fix**：distribute → **免費直注**（override_ask=0、領主給餓子民、relief=gift 非交易；mini-util 已用 仁慈/責任 gate「該不該送」、送了就給）。

## (b) T1 死=系統性餓死底線（非機制害死、非 seed）
- T1 pop 10→2 主因**既有食物短缺**（herald detach 1 anon negligible）；T3 從未派 letter、同 tick 同步滅團、曲線近似＝**systemic starvation**＝**economy-balance follow-up、非 fix-regression**。

## ∴ 你兩 concern 清
- **(a) 機制 bug 真存在 → 修**（免費直注）。「機制 complete」宣稱確在 5/6 bail 下不成立、你判對。
- **(b) T1 死非 fix 害的**＝economy-balance（relief 量級/timing 不足救人、你 preview 判對）。

## 序
- **fix (a) 免費直注** → R² → build → re-measure 症1 端到端（修後 5/6 該真 settle、**糧真到 resident**）。
- 若糧到但仍不足救 = **economy-balance follow-up**（relief 量級/衰減 vs latency）→ QA → arc-done 判。
- **誠實**：機制最後一 bug（免費路 dead code）+ T1 死歸因清（非 regression）。地基 KEEP。**待你 ack fix (a) → 我設計免費直注 HOW。**
