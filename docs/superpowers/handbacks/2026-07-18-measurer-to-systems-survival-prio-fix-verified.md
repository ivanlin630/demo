---
from: measurer
to: systems
status: consumed
topic: "[量測完·survival PRIO fix中性複核·CONFIRMED決定性成功] branch feat/survival-prio-fix@d286e21a。單元層(char bed 4/4含survival preempt threat+self-replace+瀕死覓食@80/gate 64-removed0/threat_dissolution ALL PASS/headless殘3同名同行)皆CONFIRMED。★organic seed42 8mo(同我診斷用的seed/窗長)：extinct.starve從破損版15(全no_forage傻站死)直接歸零——非僅恢復成while_fleeing分類,是問題根本解除,同seed同窗0隊餓死滅團,pop月1後完全持平(423→420持平7個月),attrition_pct=2.78%(遠低於pre-threat-oracle原生~9%水位)。threat黏性未受損(迎戰4.61%/備戰4.63%/求和13.74%,對比破損版甚至更活躍)。B(絕境經濟)前置blocker乾淨解方,可判merge"
---

# survival PRIO fix：中性複核 CONFIRMED 決定性成功

依 `2026-07-18-implementer-to-measurer-survival-prio-fix-done.md`。**同我診斷用的 seed42/8mo 窗**重跑，直接對照。

## 單元層：全部 CONFIRMED

- **char bed**（`survival_prio_fix_test.gd`）：4/4 ALL PASS——survival 派 @80、threat@70 不能 stomp survival@80、survival→survival@80 self-replace 換手不退化、瀕死 survival 選項 commit@80。
- **constitution_gate**：`PASS sites=64 removed=0`。
- **threat_dissolution_check**：ALL PASS。
- **headless_test**：殘 3 assertion 同名同行號。

## ★organic 驗證：決定性成功，超出預期

**同 seed42、同 8mo 窗**，三版對照：

```
                        extinct.starve   breakdown
pre-threat-oracle:            4          100% while_fleeing（有逃沒逃成）
破損版(623d3e77 S3):          15          100% no_forage（傻站死，bug）
★fix版(d286e21a):             0          （零！）
```

**不是只恢復成「有逃沒逃成」的 while_fleeing 分類——是問題根本消失，同 seed 同窗 0 隊餓死滅團。** pop 軌跡 `423,420,420,420,420,420,420,420`（月1後完全持平），`attrition_pct=2.78%`——**遠低於 pre-threat-oracle 原生水位（~9%）**，比修 bug 前更健康。

**survival preempt threat**：char bed 直接驗證 threat@70 不能 stomp survival@80。

**threat 黏性仍 OK**：迎戰 4.61%/備戰 4.63%/求和 13.74%——threat repertoire 仍顯著活躍（非被壓到 0），對比破損版同 seed（迎戰 2.08%/備戰 3.67%/求和 4.01%）**甚至更活躍**（尤其求和 13.74%>4.01%）——threat 機制沒被閹割，只是絕境時正確讓位。

## 判定

**決定性成功**。這是 **B（絕境經濟）前置 blocker 的乾淨解方**——survival PRIO 階層修正後，starvation-extinction 問題完全解除，threat 機制活性未受損。可判 merge。

## 流向
綠 → 你判 merge。B（economy/scaling）前置 blocker 已清。

---
measured_at_head: `d286e21a`（`.worktrees/survival-prio-fix`）
raw_logs: `docs/measurements/2026-07-18-survivalprio-charbed-*.log`、`...-constitution-*.log`、`...-threatdissolution-*.log`、`...-headless-*.log`、`...-42-d286e21a.json`
measure.json: `docs/process/verdicts/survival-prio-fix.measure.json`
