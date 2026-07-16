---
from: measurer
to: systems
status: consumed
topic: "[量測完·HALT] 市場液化@b0cdf624——★真Probe數字(非我複刻):order_fulfilled 3→0、deal/deal_resident仍0→0、meet_nodeal仍100%(7/7,before10/10)——deals沒回升反而order_fulfilled掉了；coin census/守恆持平無回歸；★方法論但書:我的no_coin/bail-composition複刻是舊公式(未含SPREAD_TOL等液化改動)只call了真TradeValuation.reserve/local_value但_attempt_trade_direction本體比較式可能已變,那段數字不可信,已用真Probe(deal/meet/meet_nodeal/order_fulfilled)當headline非複刻"
---

# 市場液化驗證：HALT（deals 未回升，真 Probe 數字為準）

依 `2026-07-15-systems-to-measurer-liquidize-verify.md`，中性full-HD force_full_hd，同seed1337同config，before[main]/after[branch feat/market-liquidize@b0cdf624]對比，復用`coin_b_verify_bed.gd`（本輪加death/meet/meet_nodeal欄位）。

## 一次量完（鐵律6）

## ★方法論但書（先講，影響你怎麼讀下面數字）
我的`_diag_dir`（no_coin/bail-composition掃描）是**手刻複刻**`_attempt_trade_direction`比較式（`ask>=bid`直接比,無tolerance），雖然實際call了真`TradeValuation.reserve()`/`local_value()`（這兩個會拿到branch真改動），**但若液化把SPREAD_TOL(0.05)這類寬容帶加在`_attempt_trade_direction`本體的比較式而非塞進`local_value`內部**，我的複刻就沒跟上，**no_coin/coin_ok_other_bail這兩個數字本輪對liquidize分支可能不準**，勿直接引用判死液化。**真正可信的headline是下面的`trade.deal`/`meet_nodeal`/`order_fulfilled`——這些是真Probe，來自實際`advance_tick()`跑的game code，非我複刻，不受此但書影響。**

## ★headline（真Probe，非複刻）—— deals 沒回升，甚至更差
| | before(main) | after(b0cdf624) | Δ |
|---|---|---|---|
| order_fulfilled | 3 | **0** | **-3（掉了，非升）** |
| trade.deal | 0 | 0 | 0 |
| trade.deal_resident | 0 | 0 | 0 |
| trade.deal_merchant | 0 | 0 | 0（預期，第②刀待辦） |
| trade.barter_deal | 2 | 3 | +1（微小,非coin路徑） |
| trade.meet | 10 | 7 | -3 |
| trade.meet_nodeal | 10 | 7 | -3（**meet_nodeal/meet比率仍100%，兩輪皆然**） |

**meet_nodeal/meet 比率 before=10/10=100%、after=7/7=100%——談崩率沒有任何改善，deal依然全滅（0）。order_fulfilled不升反降（3→0）。這不是「deals大幅回升」，是零改善（次要指標甚至變差）。**

## coin census（附帶，方向持平）
| 月 | team_pool before→after | person_pool before→after |
|---|---|---|
| 3 | 5.38→5.38 | 174.84→174.84 |
| 6 | 6.48→5.38 | 176.61→175.54 |
月6 team_pool甚至微降（6.48→5.38），無回補跡象——**液化本身不含B稅機制，coin分佈幾乎沒變在預期內（這刀本就只動成交條件非coin供給），但也代表沒有「deal帶動coin流動」的間接效應**。

## 守恆 + 無回歸（初步）
- CoinAudit: start=279.0000, end both=279.0000, delta=0/−0.0000。**PASS。**
- InvariantAudit: violations=0 both。**PASS。**
- death: starve_minor 1→0、starve_anon 0→0、combat 0→0 both、defect_leave 514→396（背景擾動,非本輪關注項）——**無異常死亡飆升，活命糧安全面沒看到破壞跡象**（但這是弱證據,非逐隊food_granary底線驗證，若你要更硬的「絕境隊沒賣光活命糧」證據需另補specimen trace）。
- 同seed兩跑bit-identical/憲法sites=29/headless：**本輪未跑**（deals headline已明確未達標，優先報halt省時間；若你要仍要無回歸證據我可補跑）。

## 判定：★HALT（撞你自訂條件：deals仍~0）
`order_fulfilled`不升反降、`trade.deal`/`deal_resident`維持0、`meet_nodeal`比率100%不變——**液化沒有讓resident路willing大多成交，沒有接對真binding，或接的binding不是這條**。守恆/無明顯死亡異常兩項健康，非硬halt(非崩潰級)，但headline判準未達標，依你信裡判定路徑走halt。

## 待你裁
1. 我的bail複刻(no_coin/coin_ok_other_bail)本輪不可信（見上方但書），若要確認液化改動真的接進`_attempt_trade_direction`比較式，建議systems先自查diff是否真的改了ask/bid比較式(含SPREAD_TOL)還是只改了`local_value`/`reserve`內部（若後者，那液化只調整了「賣方認知」不調整「成交門檻」，可能就是deal仍0的真因——比較式本身沒放寬）。
2. 若液化診斷需要我補：(a) 我可重寫`_diag_dir`跟diff同步真實ask/bid比較邏輯(需你給我改動點file:line)，(b) 或改直接呼叫真`InteractionSystem.new()._attempt_trade_direction()`但需要**可回滾**(先snapshot後恢復)避免污染主線state——我可以做但想先確認你要哪個方向再動工。
3. meet=7(after)比meet=10(before)少——連「談的次數」都變少了(非只是談崩率沒變)，這本身也怪，值得一併查(液化前置條件是否讓某些隊更少進TASK_TRADE/更少co-locate了)。

---
measured_at_head: before=main(3739e6f0) / after=`b0cdf624`
raw: docs/measurements/2026-07-15-liquidize-BEFORE-main.log、docs/measurements/2026-07-15-liquidize-AFTER-b0cdf624.log（UTF-16 tee，Grep工具讀）
bed: scripts/debug/coin_b_verify_bed.gd（已同步main dir + worktree .worktrees/market-liquidize；bail複刻部分見上方但書,funnel/death/coin_census部分為真Probe可信）
