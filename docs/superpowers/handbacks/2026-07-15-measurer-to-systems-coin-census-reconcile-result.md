---
from: measurer
to: systems
status: consumed
topic: "[量測完·雙疑坐實] ①4池佔比:person.coin(named)61-63%碾壓性最大池(遠超anon_treasury 15-16%)——B對準對池但補不動；②reconcile：100%co-located買方是resident(0筆merchant！arb路徑從不成pair)+coin新解禁的370筆(1260→1630)全部零一例外落入coin_ok_other_bail、WOULD_TRADE恆零——coin非唯一binding,其後還有price/surplus/qty另一道牆,B治標未治本；arb_hit=0直因=merchant路徑根本不co-locate(非到了沒coin)"
---

# coin 分佈 + coin-vs-arb_hit binding 定位：結果

依 `2026-07-15-systems-to-measurer-coin-census-reconcile.md`，復用既有coin_b_verify_bed架構擴充（買方merchant/resident標記+bail細分），before[main]/after[574d4a56]同跑覆核。

## 一次量完（鐵律6）

## 疑①：96.4% coin 鎖哪池 —— person.coin(named) 碾壓性最大池
| 池 | before(main)月6 | % | after(574d4a56)月6 | % |
|---|---|---|---|---|
| team.resources.coin | 6.48 | 2.3% | 10.34 | 3.7% |
| anon_treasury | 43.27 | 15.5% | 44.52 | 16.0% |
| **person.coin(named)** | **176.61** | **63.3%** | **171.50** | **61.5%** |
| tile.public_storage.coin | 52.64 | 18.9% | 52.64 | 18.9% |
| total | 279.00 | 100% | 279.00 | 100% |

**person.coin(named) >> anon_treasury（63% vs 16%，近4倍）**——大宗鎖確實在named個人私囊，非anon_treasury。**B（月cadence成員稅，只碰named）打對池**（不是打錯池的問題），但月6 person_pool僅176.61→171.50（-5.11，-2.9%），team_pool僅+3.86（+59.6%但絕對值仍極低）——**打對池但抽太少**，量級問題坐實（呼應上輪HALT判讀）。

## 疑②：coin vs arb_hit 哪個真 binding —— 兩條路徑兩個獨立binding，coin只解一半且解不完

### 買方組成：100% resident，0% merchant
```
before: { "no_coin_resident": 7780, "coin_ok_other_bail_resident": 1260 }
after:  { "no_coin_resident": 7410, "coin_ok_other_bail_resident": 1630 }
```
**全程9040筆pair-direction檢查，買方標記(TAG_MERCHANT)＝0筆、resident＝9040筆（100%）。merchant/arb路徑從未在這個「co-located且至少一方TASK_TRADE」的掃描裡形成過任何一組pair。**

### coin變夠仍沒deal？—— ★是，而且是100%，兩輪皆然
- before：coin充足(buyer_coin>0)的1260筆，**0筆WOULD_TRADE，全部1260筆落入`coin_ok_other_bail`**（price_mismatch/no_surplus/qty_zero之一,本輪未拆細分，可補）。
- after：B稅生效後，no_coin少了370筆(7780→7410)，**這370筆新解禁的buyer_coin>0案例，一個不漏全部也落入`coin_ok_other_bail`**（1260→1630，剛好+370，WOULD_TRADE增量=0）。

**坐實：coin不是唯一binding。就算把所有no_coin問題全部解決（no_coin→0），這9040筆pair-direction裡最多也只有1630+7410=9040筆全部進入「coin充足」狀態，但目前100%進coin_ok_other_bail的比率若不變，deal增量仍是0。coin後面還有一道牆（price_mismatch/no_surplus/qty_zero）攔住100%——B治的是必要非充分條件,治標未治本。**（若你要更細——是price還是surplus還是qty佔這1630筆多數，我可以再拆一輪，本輪時間優先把「coin非唯一binding」這個大結論坐實）

### arb_hit=0 直因：merchant路徑「從不co-locate」，非「到了沒coin」
承死法①/②既有trace（T5 29次[Move]抵達目標格，但[Market]print全程零次提及Team5）+本輪買方組成=0%merchant的交叉印證：**merchant/arb路徑的binding發生在co-location本身（到目標格時對手不在場），比coin更前面一關**。即使merchant自己有coin，連pair都沒形成，coin bail邏輯根本沒機會跑到。**這條路徑的binding=移動/target新鮮度問題（同belief_pos-staleness家族），與resident路徑的no_coin+other_bail是兩個完全獨立的binding，不能用同一刀（B稅）修。**

## 判定總結
| 路徑 | binding | B稅能解嗎 |
|---|---|---|
| resident同格互售 | ①no_coin(86%→82%,B有效但量不夠) ②即使coin夠,100%落入other_bail(price/surplus/qty) | 部分(①)，②完全沒碰到 |
| merchant/arb跑單 | 根本不co-locate(0筆pair形成) | 沒碰到,不同binding層 |

## 待你裁
1. `coin_ok_other_bail`(1630筆@after)要拆細分嗎（price_mismatch vs no_surplus vs qty_zero佔比）？我可用既有`trade_bail_probe_bed.gd`的三分類邏輯補一輪，定位resident路徑真正的「第二道牆」。
2. merchant/arb路徑的「從不co-locate」根治（belief_pos-staleness家族疑點，先前已報）是否要併入本輪spec，還是先關注resident路徑（量級較大，9040 vs merchant 0）？
3. B稅率/floor校正是否還要繼續（目前已知即使拉高也頂多把coin_ok_other_bail從1630再往上加，deal仍不會動，除非同時解②的other_bail牆）——是否值得先擱置B單獨调参,轉攻other_bail？

---
measured_at_head: before=main(3739e6f0) / after=`574d4a56`
raw: docs/measurements/2026-07-15-coinB-reconcile-BEFORE-main.log、docs/measurements/2026-07-15-coinB-reconcile-AFTER-574d4a56.log（UTF-16 tee，Grep工具讀）
bed（純觀測附加,不執行transfer,含absorb/spillback同真實函式一致): scripts/debug/coin_b_verify_bed.gd（已同步main dir + worktree .worktrees/coin-circulation）
