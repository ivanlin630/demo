---
from: systems
to: implementer
status: open
topic: "[dispatch 農業b(⑥據點結構放大器 pop-cap乘法)·base post-農業a main c18a32ce·spec=2026-08-18-settlement-agriculture-HOW.md §2農業b R²-CLEAN(整spec含農業a+b已R²審過、乘法建議定案)·★核心:effective_pop_cap=pop_cap_from_leadership(領導基數)×據點結構放大器(outpost_level/設施發展)乘法非加法(reviewer建議定案、MarginalEconomy._inflow_est outpost_mult×pop_mult乘性合成先例、語意符據點是領導力放大器⑥字面)·①放大器=據點結構函數(outpost_level為主、設施發展可加成)、發展越高承載越大=genuine投資回報非死曲線查表②pop_cap整合:現team_data:48 pop_cap_from_leadership(skill)是領導基數→包一層effective_pop_cap=base×amplifier(找pop_cap全caller路由到effective、如既有overflow check_overflow_for_team用effective)③★L0不放大auto:L0 outpost_level=0→放大器天然=1(S2a camp_level獨立flag已確保L0無outpost_level>0結構自動、零額外code)④基數(領導)+放大器一起tune·★禁死常數pop曲線(命門):放大器=據點level/設施結構函數非查表死曲線·感知鐵律:讀自家據點自家level self-knowledge·TDD:①據點level↑→effective_pop_cap↑放大器生效②領導基數仍為底(無據點=領導帽、L0不放大×1守S2a界線)③overflow(pop>effective_cap)走既有check_overflow_for_team④基數+放大器tune後合理量級不爆不塌·gate:據點放大器genuine(據點發展→cap↑size matter via據點非死曲線L0不放大)+determinism byte-identical(純算術)+constitution+不破·fp intended-change(pop-cap行為變)·worktree feat/agriculture-b·完→handback附measurer·地基KEEP"
---

# dispatch 農業b（⑥ 據點結構放大器 pop-cap 乘法）

spec=`docs/superpowers/specs/2026-08-18-settlement-agriculture-HOW.md` §2 農業b（**R²-CLEAN**、整 spec 含農業a+b 已 R² 審過、乘法建議定案）。base=post-農業a main `c18a32ce`。

## ★核心：乘法放大器
`effective_pop_cap = pop_cap_from_leadership(領導基數) × 據點結構放大器(outpost_level/設施發展)`——**乘法非加法**（reviewer 建議定案、MarginalEconomy._inflow_est outpost_mult×pop_mult 乘性合成先例、語意符「據點是領導力**放大器**」⑥字面）。
- ①**放大器=據點結構函數**（outpost_level 為主、設施發展可加成）、發展越高承載越大=genuine 投資回報**非死曲線查表**。
- ②**pop_cap 整合**：現 `team_data:48 pop_cap_from_leadership(skill)`=領導基數 → 包一層 `effective_pop_cap=base×amplifier`（找 pop_cap 全 caller 路由到 effective、如既有 overflow `check_overflow_for_team` 用 effective）。
- ③**★L0 不放大 auto**：L0 outpost_level=0→放大器天然=1（S2a camp_level 獨立 flag 已確保 L0 無 outpost_level>0、結構自動、零額外 code）。
- ④基數(領導)+放大器一起 tune。

## 守則
**★禁死常數 pop 曲線（命門）**：放大器=據點 level/設施結構函數非查表死曲線。感知鐵律：讀自家據點自家 level self-knowledge。

## TDD
①據點 level↑→effective_pop_cap↑放大器生效 ②領導基數仍為底（無據點=領導帽、L0 不放大×1 守 S2a 界線）③overflow(pop>effective_cap)走既有 check_overflow_for_team ④基數+放大器 tune 後合理量級不爆不塌。

## gate
據點放大器 genuine（據點發展→cap↑ size matter via 據點非死曲線、L0 不放大）+ determinism byte-identical（純算術）+ constitution + 不破。fp intended-change。

worktree `feat/agriculture-b`。完 → handback 附 measurer。地基 KEEP。
