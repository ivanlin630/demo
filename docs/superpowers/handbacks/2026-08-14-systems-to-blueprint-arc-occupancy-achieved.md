---
from: systems
to: blueprint
status: open
topic: "[★★生存經濟 access arc 佔據率目標達成(全 slice MERGED、你帶用戶)·A4 佔據率終測綠+MERGED(survival_a4_test PASS/constitution 75)·佔據率 baseline 7.69%→11.02%(+43%相對)·arc 全 slice done:B4/B5(gather cache+food-famine-escalate)/A1(camp anti-crank)/A2(invite-widen)/A4(forage de-patch survival_pressure隨food_days衰減+solo-convert去pairwise pair+9筆ENGINE_SOURCES)·三修合力驗證:convert_via_settle=1真通(A2單獨=0全滅、solo-convert補下游)、A4讓位乾淨(覓食718→335 -53%、吃飽團food_days≥14桶64.5%→5.1%改選)、瀕餓<7 floor analytic保證不誤傷、無顯著餓死regression、無over-invite churn、determinism byte-identical雙獨立複驗·★★誠實caveat(measurer非阻塞、我照實帶):佔升+6resident裡僅1筆走settle-into-existing(A2/A4直修路、真通但低量、1月窗只fire 1次)、主貢獻是founding路build_outpost 13→24(+11)=A4-spillover(解放覓食卡死團→argmax轉found outpost自救)vs RNG-cascade confound、single-seed無法乾淨拆→佔升方向確定為正but精確歸因待multi-seed·∴用戶『settle進42既有據點』直路技術上unblock(convert=1證)but低量、真win是A4解放團去found/settle泛化·★arc核心(佔據率脫stuck)達成、剩:①multi-seed乾淨歸因(你判值不值、非阻塞)②12/24月長局e2e驗收(spec§5)③perf arc(scoped待)④threat genuine留不動·closed-account memory-rule待用戶bank(我build期4次over-claim含labeled-FACT錯=證據極強)·序:你帶用戶看arc佔據率達成+caveat、裁後續(multi-seed/長局/perf序)·地基KEEP"
---

# ★★生存經濟 access arc 佔據率目標達成（全 slice MERGED、你帶用戶）

## arc 全 slice done + MERGED
| slice | 內容 | gate |
|---|---|---|
| B4/B5 | gather cache 刷 + food need 隨飢餓升 | 兩象限綠 |
| A1 | 紮營價值 MarginalEconomy anti-crank | 四象限綠(correctness) |
| A2 | 拓寬 invite 候選(funnel 頂) | groundwork綠 |
| A4 | forage de-patch(survival_pressure隨food_days衰減)+solo-convert+9筆 | ★佔據率終測綠 |

## ★佔據率目標達成
- **baseline 7.69%(7/91) → branch 11.02%(13/118)、+43% 相對**。
- 三修合力驗證：`convert_via_settle=1` 真通（A2 單獨=0 全滅、solo-convert 補下游）、A4 讓位乾淨（覓食 718→335 **-53%**、吃飽團 food_days≥14 桶 64.5%→5.1% argmax 改選）、瀕餓<7 floor **analytic 保證**不誤傷、無顯著餓死 regression、無 over-invite churn、**determinism byte-identical 雙獨立複驗**。

## ★★誠實 caveat（measurer 非阻塞、我照實帶）
佔升 +6 resident 裡**僅 1 筆走 settle-into-existing**（A2/A4 直修路、**真通但低量**、1 月窗只 fire 1 次）；主貢獻是 **founding 路 `build_outpost` 13→24（+11）**= **A4-spillover**（解放覓食卡死團→argmax 轉 found outpost 自救）**vs RNG-cascade confound**、single-seed 無法乾淨拆。
- ∴佔升**方向確定為正** but **精確歸因待 multi-seed**。
- 用戶「settle 進 42 既有據點」直路**技術上 unblock**（convert=1 證）**但低量**；真 win 是 **A4 解放團去 found/settle 泛化**。

## ★arc 核心達成、剩
- arc 核心（佔據率脫 stuck）**達成**。
- 剩：①multi-seed 乾淨歸因（你判值不值、非阻塞）②12/24 月長局 e2e 驗收（spec §5）③perf arc（scoped 待）④threat genuine 留不動。

## closed-account memory-rule 待用戶 bank
我 build 期 **4 次 over-claim**（A1 camp.fire=0 / A2 流亡 structural / try_set latch / exit≈3 labeled-FACT 錯）、measure/review 連環接住=**證據極強**。write-side discipline 我已套用（fact-vs-hypothesis 分清）。

序：你帶用戶看 arc 佔據率達成 + caveat、裁後續（multi-seed / 長局 / perf 序）。地基 KEEP。
