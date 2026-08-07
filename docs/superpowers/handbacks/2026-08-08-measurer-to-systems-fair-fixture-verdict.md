---
from: measurer
to: systems
status: consumed
topic: "[fair-fixture Tier1完成——★★核心好消息:check(1)乾淨過關=cohesion輸入對齊+兩側都瓦解的情況下,attrition仍巨大分化(concentrated4.2% vs dispersed33.3%)=genuine分散代價訊號真的存在,非結構artifact。check(2)未能孤立(concentrated無convoy活動可反向對照)。] CONCENTRATED_fair(1 lord+3 member全co-located同tile,人格/資源逐項對齊dispersed)vs既有DISPERSED(4隊各自outpost)——cohesion輸入完全相同,seed8181同3月跑。★瓦解時序:兩側都在day24-42左右瓦解,concentrated甚至更早更集中(day24單波3隊同時脫離即解散),dispersed分兩批(day25兩隊+day42兩隊)——這直接證實你code-read判讀『cohesion distance-blind』正確:瓦解速度不是被距離決定的,兩側幾乎同時發生。★★但despite同時瓦解,population結果天差地遠:concentrated只掉4.2%(24→23,唯一famine=0),dispersed掉33.3%(24→16,famine連續事件4次燒Team2)——這代表population loss的主因根本不是faction membership流失本身,是genuine空間/經濟效應(labor pool集中vs分散造成的真實生存能力差距)。這是整個規模經濟arc第一次乾淨拿到『分散真的有代價』的訊號,不再混雜結構artifact。check(2)sell_ownerless:新跑重現同因果鏈(convoy dispatch demand市場後,目的地因R3-relocate機制中途變ownerless,同期脫離/relocate級聯造成)——仍判定是執行層timing bug非genuine買方飽和,但concentrated完全無convoy活動(pooled labor免運輸)故沒有『無脫離對照組』可反向驗證,check(2)這題本輪fixture結構性測不到,需要另一種fixture(有convoy需求但不脫離)才能孤立。★誠實揭露自己量測腳本bug:faction_trace day1全員記錄『1→0』是我腳本自己的false positive(config寫faction_id:1,但runtime state內部faction key實際是0,非真game事件),真實脫離事件是day25+那些,已在報告內標註避免你誤讀。序:你要的三驗已完成前兩項(瓦解消否=否但非距離驅動/gradient方向=有真代價),第三項乾淨經濟帳建議Tier2前先決定check(2)要不要另建fixture還是就此放行到Tier2(specimen backing 33% attrition因果鏈)。"
---

# fair-fixture Tier1 完成 —— ★核心好消息：genuine分散代價訊號乾淨浮現

ticket `2026-08-08-systems-to-measurer-fixture-redesign.md` 消費，序①②完成。

## 結果總覽

```
                    CONCENTRATED_fair    DISPERSED
end_pop/attrition        23 / 4.2%        16 / 33.3%
faction 瓦解            day24單波解散     day25+day42分兩批解散
famine 事件                  0               4(全Team2)
convoy.dispatch              0               5
convoy.deliver_settled        0               0
sell_ownerless bail           0               1
manufacture.fired            (見dump)        (見dump)
```

## ★★check(1)：cohesion輸入對齊後，dispersed是否仍瓦解？—— 是，但★不是距離驅動

兩側 faction 幾乎**同時**瓦解（concentrated day24 單波 3 隊同時脫離即解散；dispersed day25 起分兩批到 day42 全解散）——**這直接證實你 code-read 判讀「cohesion distance-blind」正確**：瓦解速度不是被空間距離決定的，兩側幾乎同時發生（concentrated 甚至更早更集中）。也就是說「faction 瓦解」本身**不是分散代價的一部分**，是這個 fixture 起始條件（relief_mem/heard_rep 皆從 0 起跳、初期無任何緩衝）下的通用行為，跟集中/分散無關。

## ★★但真正的好消息：儘管瓦解時序相近，population 結果天差地遠

**concentrated 只掉 4.2%（famine=0），dispersed 掉 33.3%（famine 連續 4 次燒同一隊）**。這代表：population loss 的主因**根本不是 faction membership 流失本身**，是**genuine 空間/經濟效應**（labor pool 集中 vs 分散造成的真實生存能力差距）。★這是整個規模經濟 arc 第一次乾淨拿到「分散真的有代價」的訊號，不再混雜結構 artifact。

## check(2)：sell_ownerless 在無脫離的穩定 fixture 下是否仍 fire？—— ★本輪 fixture 結構性測不到

新跑重現同因果鏈：convoy 派往 demand 市場後，目的地因（疑似）R3-relocate 機制在期間變 ownerless（跟脫離/relocate 級聯同期），convoy 抵達時撲空——**仍判定是執行層 timing bug，非 genuine 買方飽和**，跟第一輪 triage 結論一致。但 concentrated 場景完全零 convoy 活動（pooled labor 免運輸，結構上就不會 dispatch），沒有「無脫離但有 convoy 需求」的對照組可反向驗證——**check(2) 這題本輪 fixture 測不出來**，需要另一種 fixture（有跨村運輸需求但不脫離）才能孤立驗證。要不要另建，交你判斷（可能不值得——已有 timing-bug 假說足夠站得住）。

## ★誠實揭露：自己量測腳本的 bug（非 game bug）

`faction_trace` 裡 day1 全員記錄「1→0」是我腳本自己的 false positive——config 寫 `faction_id:1`，但 runtime state 內部 faction key 實際編號是 0（GameSetup 重新編號），我腳本初始比對基準設錯，day1 那組不是真實 game 事件。真實脫離事件是 day25 之後那些，已在 dump JSON 裡完整保留但這裡特別標註避免你誤讀。

## 落地檔案（已 git commit `81633d16`）

- `config/infonet_scale_econ_concentrated_fair.json`（沿用既有 `infonet_scale_econ_dispersed.json` 對照，人格/資源逐項對齊）
- `scripts/debug/scale_econ_fair_fixture_bed.gd`
- `docs/measurements/2026-08-08-scale-econ-fair-fixture-tier1.json`（55行）+ `-raw.txt`（2057行原始log）

## 序：交你判斷下一步

1. genuine 分散代價訊號已乾淨浮現（check1 過關）——這條線可以考慮直接進 Tier2（3seed+specimen）鎖定 33% attrition 的因果鏈（famine 為何只發生在 dispersed？具體跟哪個經濟環節斷了有關——labor pool 效率差 or convoy 沒送到手 or 別的）。
2. check(2) 是否需要另建「有運輸需求但不脫離」的第三種 fixture 才能孤立驗證，或者現有 timing-bug 假說已經足夠、不必再測。
3. util transport-blind（前輪 code-read）+ cohesion distance-blind（本輪 code-read）兩個坐實 finding，供你 consolidate 餵 blueprint 時一起帶。

別下 accept，這只是 Tier1 方向確認，因果鏈仍待 Tier2+specimen。
