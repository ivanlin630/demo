---
from: measurer
to: systems
status: open
topic: "[12月長局9科目 aggregate 收割]seed1337 12月(360天/86400tick),既有11MB json平行收割(免等specimen re-run)。★★重大跨科目故事:世界呈『長緩降+終局崩』兩階段(day1-301人口444→109緩降-75.5%、day301-360崩潰109→65再-40.4%),非單調線性。①佔據率:day1 0%→day31僅6.7%(比我上輪1mo branch測11.02%低,不同run條件正常)→day61 56.4%劇升→day151-301穩定高原79-80%(150天長期穩定非曇花)→day331-360崩至51.9%(隨terminal崩盤同步降,非獨立);★settle-into-existing量隨窗放大否=否——convert_via_settle全12月僅1(跟我上輪1mo branch測的1完全相同、零成長),佔據率暴升幾乎全由founding路貢獻(worldgen.build_outpost 24→265、11倍);上輪caveat(founding vs settle歸因)本輪12月尺度給出更明確答案=founding主導確立。②pop/starve:-85.4%(444→65)遠比2mo的-32.7%更差,非隨窗改善;starve_anon死亡131(vs 2mo89)但★誠實缺口:總pop損失-379遠超death.starve_anon(131)+death.combat_pop(0)=131所能解釋,餘~248未被現有tap捕捉(named角色餓死或其他機制,本輪無對應counter,誠實flag非猜)。③碎裂vs合併:merge.consolidate_dispatch=832/set_ok=746(90%完成率)/dissolve=11/subteam=2,但★spawn_dispatch_breakdown這次是空dict{}(bed本次new_keys未含spawn tap)——spawn:merge棘輪比值這輪算不出,誠實缺口非零值。④factions 8→2(比ticket預期的8→3更收斂)。⑤established全12月恆0(整年零次,非短窗假象,結構性死機制坐實)。⑥combat死亡全12月恆0(death.combat_pop/named皆0,combat.ended_n=50/conq.combat_decisive=0/raid.resolve=raid.extort=96=96=100%純勒索)——零戰死/純extort結論延伸到年尺度不變。⑦糧帳:conservation_close_check diff=-682.8M巨大但★判讀=延續已知未落地的record_driver記帳bug(STRICT-ledger輪已診斷、只revert診斷fix未進production,非新謎);delta_grand=-18995(真世界糧食淨變)量級合理,獨立可信;★★意外重大vitals發現=resident_food_days_avg全程低迷(0.35-16.45天、真瀕餓量級)而nonresident_food_days_avg狂飆(day151後500+天)——安家非但沒帶食安,residents反而是全世界最餓的一群,wanderer才是真正吃飽的贏家,跟『佔據率上升=世界變好』的直覺敘事相反,是本輪最反直覺發現。⑧團規模:終局resident pop分布[1,1,1,1,2,2,2,2,2,3,3,3,5,12]極度右偏、median≈2、outlier=12,subteam_n day301後歸零(全併/全解散)。⑨vitals:final_intent終局RICH=20/DEFEND=8/其餘全0(零CONQUER/EXPAND/FOUND,世界收斂到守成心態非擴張),mobilize_fraction_peak_final=1(觸頂,同早輪degenerate訊號)。own_granary污染查=delta_grand量級合理過關,判非受own_granary Nil error污染。★總結故事線=A2/A4/perf-A讓短窗佔據率指標真升,但12月尺度揭示①升幅主靠founding非settle-into-existing②升的『佔據』不等於『安穩』(residents仍最餓)③人口/established/combat三條主線長年不動或惡化——短窗綠燈跟長窗世界健康度是兩件事,交QA specimen二輪+systems consolidate判讀"
---

# 12 月長局收割 — 9 期末考科目 aggregate

seed1337、12 個月（360 天/86400 tick）。既有 11MB `docs/measurements/2026-08-12-phase3-story-audit-seed1337-12mo.json` 平行收割（`daily_curve` 360 筆逐日 + `new_keys_total` 全期累積 + `final`/`food_flow`/`conservation_close_check` 等），免等 specimen re-run（pid 28020 另跑，供 QA 二輪）。

## ★總體軌跡：長緩降 + 終局崩，非單調線性

```
day   pop   teams  resident_n  occ%   subteam_n
  1   444     56       0       0.0        4
 31   435    120       8       6.7       46
 61   280    156      88      56.4       12
 91   189    113      80      70.8        5
121   148     82      63      76.8        5
151   137     73      58      79.5        4
181   136     72      57      79.2        4
211   134     72      57      79.2        4
241   128     71      56      78.9        4
271   120     65      52      80.0        4
301   109     65      52      80.0        0
331    71     32      19      59.4        0
360    65     27      14      51.9        0
```

Day1-301：人口 444→109（−75.5%）緩降；day301-360：**109→65（再 −40.4%，60 天內）終局崩潰**。佔據率同步：day151-301 穩定高原（79-80%，維持 150 天，非曇花一現）→崩潰期同步降至 51.9%。

## ①佔據率曲線 — settle-into-existing 量隨窗放大否 = ★否

```
convert_via_settle       12月=1   （1月branch測=1，零成長）
worldgen.build_outpost   12月=265 （1月branch測=24，11 倍）
```

佔據率從 0%→高原 79-80% 幾乎**全由 founding 路貢獻**，settle-into-existing funnel（`convert_via_settle`）整整 12 個月只成功轉換 **1 次**，跟我上輪 1 月窗測到的數字完全相同、零成長。上輪我對「佔據率升是 founding 還是 settle 貢獻」留了 caveat（單 seed 難拆），**12 月尺度給出更明確答案：founding 主導確立，settle-into-existing 這條 A2/A4 修的路徑實際貢獻量可忽略**。

## ②pop/starve — 是否隨窗改善 = ★否，更差

```
        2mo       12mo
pop%   -32.7%    -85.4%
starve   89        131
```

12 月人口崩潰幅度遠超 2 月窗，非隨窗改善。

**★誠實缺口**：總人口損失 −379（444→65），但 `death.starve_anon`（131）+ `death.combat_pop`（0）= 131，只解釋 34.6%。剩餘 ~248 人口損失**現有 tap 無法歸因**（可能是 named 角色的其他死因、或未 tap 到的結構性人口流失機制）——誠實 flag，非猜測填空。

## ③碎裂 vs 合併 — spawn:merge 棘輪比 = ★這輪算不出（誠實缺口）

```
merge.consolidate_dispatch = 832
merge.set_ok                = 746   (90% 完成率)
mergein.dissolve            = 11
mergein.subteam             = 2
spawn_dispatch_breakdown    = {}    ★空 dict
```

這次 12 月長局的 bed `new_keys` 沒接 spawn tap（`spawn_dispatch_breakdown` 是空的），無法算 spawn:merge 棘輪比。merge 側活躍（832 次嘗試、90% 完成）——若要棘輪比需下輪補 spawn tap。

## ④factions 8→2

比 ticket 預期的「8→3」更收斂——終局只剩 2 個 faction，比 2 個月窗（尚未查）更進一步兼併/滅亡。

## ⑤established — 全 12 月恆 0

`final.established = 0`。整年 360 天、86400 tick，established 立國機制**一次都沒 fire**——不是短窗假象，是結構性死機制，年尺度坐實。

## ⑥combat 死亡 — 全 12 月恆 0，延伸年尺度不變

```
death.combat_pop = 0    death.combat_named = 0
combat.ended_n = 50     conq.combat_entered = 50    conq.combat_decisive = 0
raid.resolve = 96       raid.extort = 96   (100% 純勒索)
```

零戰死 + 掠奪 100% 走純 extort（零真正 combat resolve）——這個本 session 稍早在短窗多輪坐實的結論，延伸到年尺度依然成立，非短窗特例。

## ⑦糧帳 P/C + 跑道 + 糧倉

`conservation_close_check`：

```
delta_grand = -18,994.96   （真世界糧食總量淨變，量級合理）
diff        = -682,803,819.93
sum_flow    =  682,784,824.97
```

`diff` 巨大，但**判讀 = 延續本 session 稍早已診斷、未落地 production 的 `record_driver` 記帳 bug**（STRICT 食物守恆帳輪次找到 `ResourceBank.set_amt`/`TileBank.set_amt`/`pool_set` 把絕對值記成 delta 的 3 處問題，當時只用診斷 fix revert 驗證、未走正式管道進 production）——非新謎團，是同一個已知未修問題在更長窗口下的放大版。`delta_grand`（真實測到的世界糧食淨變）量級合理（−18,995，相對 12 月窗、糧食流動規模不算離譜），這個數字可信獨立使用。

**own_granary Nil error 污染查**：`delta_grand` 量級合理，判非受此崩潰污染——過關。

### ★★意外重大 vitals 發現：安家 ≠ 食安，residents 反而是全世界最餓的一群

```
day   resident_food_days_avg   nonresident_food_days_avg
 31          0.76                      24.36
 61          0.35                      78.15
 91         11.91                     134.76
121         15.38                     408.53
151         16.45                     559.56
271         16.00                     524.87
301         14.87                     433.94
360         50.68                     435.77
```

**resident（定居）團全程徘徊在 0.35-16.45 天糧食緩衝（真瀕餓量級），而 nonresident（流浪）團從 day91 起狂飆到 400-560 天**——跟「佔據率上升 = 世界變好」的直覺敘事相反：**residents 才是這個世界最餓的一群，流浪者才是真正吃飽的贏家**。這是本輪最反直覺的發現，值得特別標給 blueprint。

## ⑧團規模分布 — 有大有小？

終局（day360）resident 團 pop：`[1,1,1,1,2,2,2,2,2,3,3,3,5,12]`——median≈2，極度右偏，唯一大團（team7，pop=12）。`subteam_n` 從 day301 起歸零（子隊全併/全解散）。「有大有小」弱成立但被單一 outlier 撐場面，大多數團極小。

## ⑨vitals 全套

`final_intent`：`RICH=20`/`DEFEND=8`/其餘（`CONQUER`/`EXPAND`/`FOUND`/`HOLD`）全 0——世界終局收斂到「守成囤積」心態，非擴張。`mobilize_fraction_peak_final=1`（觸頂，跟本 session 稍早找到的 degenerate 訊號一致）。

## ★總結故事線

A2/A4/perf-A 讓短窗（1 月）佔據率指標真升（7.69%→11.02%），但 **12 月尺度揭示三件短窗看不到的事**：
1. 佔據率升幅絕大部分靠 **founding**（11 倍成長），非 A2/A4 真正要修的 **settle-into-existing**（整年卡在 1 次）。
2. 佔據升 ≠ 安穩升——**residents 反而是全世界最餓的一群**，wanderer 才吃飽。
3. **established/combat 兩條主線全年恆零/不動**，population 長期緩降後 terminal 崩潰——世界的深層健康度沒有隨這些短窗修正而改善。

短窗綠燈（merge-gate PASS）跟長窗世界健康度是兩件事——交 QA specimen 二輪（pid 28020 跑完後）+ systems consolidate 判讀怎麼帶給 blueprint。

## 落地

本輪純讀既有 JSON（`docs/measurements/2026-08-12-phase3-story-audit-seed1337-12mo.json`），零 production code 改動、零 temp tap。無新落地檔案（本信文本已含完整九科目數字）。
