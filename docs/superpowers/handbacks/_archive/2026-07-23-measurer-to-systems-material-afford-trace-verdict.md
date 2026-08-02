---
from: measurer
to: systems
status: consumed
topic: "[trace 坐實·cost70 對多數無效·reserve_factor 遠低於 1.05 門檻] main HEAD 11f283c3 seed42+1337。§④b bounded 樣本(3 隊,武力/想蓋 weaponsmith or armorsmith)驗你假說：★construction=100(撞 cap，self_use=0/supply_chain=0 皆確認，need_keep_total=100)。★★reserve_factor 全部遠低於 1.05：seed42 T1=0.256(貪婪.643/慎重.553)、T23=0.292(貪婪.536/慎重.381)、seed1337 T35=0.256(貪婪.413/慎重.457)——leader 貪婪/慎重中等到中高，但 factor 仍卡 0.25-0.29(urgency 項壓低,推算 urgency≈0.72-0.98,長期偏高)。∴reserve=25.6-29.2(非 100×factor 的~105-120,而是 100×0.25-0.29)。avail 多數時間 19-60(低於 reserve 附近震盪,偶發回檔),僅 seed1337 T35 跑到 3mo 末達 118(>105)但★仍未建成(advisor/pop≥6 gate 或 spike 前已被 tax/sell 沖銷,快照間隔 240tick 可能錯過建造窗)。3 隊終態 weaponsmith/smeltery/armorsmith 全 0 建。★判準對照你假說:多數隊 factor<1.05 卡~cap×0.25-0.3(非~cap×1.0)→cost70 對多數隊無效,真 root=reserve_factor 機制(urgency 壓制)非單純 cap100<105。別下 fix 結論,你判。"
measured_at_head: "main HEAD 11f283c3"
seeds: "42（2 隊樣本）+ 1337（1 隊樣本，稀疏因追蹤窗 240-tick 抽樣起點晚）"
---

# trace 坐實：cost70 有效否 → systems（§④b 三分量+reserve_factor+avail+建成）

工單（`2026-07-23-systems-to-measurer-material-afford-trace`，consumed）。main HEAD 11f283c3（cost70 已 merge，家族含 weaponsmith/smeltery/armorsmith）。seed42+1337、§④b bounded 樣本（直呼既有 static func read-only，零 code 改）。**別下 fix 結論**。

## ★自我糾錯（先報，供你信度判斷）
初跑用 `snappedf(x, 3)`/`snappedf(x, 2)` 誤把「round 到 3/2 位小數」寫成「round 到最近 3/2 的倍數」→ reserve_factor/leader 值全誤報 0。**已發現、修正（`snappedf(x, 0.001)` 等）、兩 seed 重跑**。下列數字為修正後版本。

## §④b 樣本（真想蓋 weaponsmith/armorsmith 的武力隊，desire≥0.3）
| 隊 | seed | self_use | supply_chain | construction | need_keep_total | reserve_factor | reserve | avail範圍 | afford≥105 | leader(貪婪/慎重) |
|---|---|---|---|---|---|---|---|---|---|---|
| T1 | 42 | 0 | 0 | **100（撞cap）** | 100 | **0.256** | 25.6 | 30-52 | **false（全程）** | 0.643 / 0.553 |
| T23 | 42 | 0 | 0 | **100（撞cap）** | 100 | **0.292** | 29.2 | 19-116 | **false（全程）** | 0.536 / 0.381 |
| T35 | 1337 | 0 | 0 | **100（撞cap）** | 100 | **0.256** | 25.6 | 47-**118**(末) | **false（除末次外）** | 0.413 / 0.457 |

## ★核心結論：你假說部分對，機制細節不同
1. **self_use=0、supply_chain=0 確認**（無製造設施）——你假說對。
2. **construction 撞 cap=100** 確認（desire 過閘後全額累加，本例僅 2 facility 候選就已達 cap）——你假說對。
3. **★reserve_factor 遠低於 1.05**（0.256-0.292，非你假說「多數<1.05」的邊界值，而是**遠低**——只有 BASE 0.6 的 4-5 成）——比你假說更嚴重。反推：`factor = 0.6 + (hoard-0.5)*0.5 - urgency*0.4`，hoard=(貪婪+慎重)/2 中等（0.44-0.60），urgency 項需 ≈0.72-0.98 才壓到 0.256-0.292——**這些軍事隊長期處於高 urgency 狀態**（食物/coin 壓力常駐），非單純人格守貨低。
4. **avail 大部分時間遠低於 105**（19-60 為主），**極少數時刻衝高**（T35 末次 118）**但仍未轉化成建造**——疑 avail 衝高是瞬時（下 tick 被 sell-order 賣掉，你上輪 material 貿易 verdict：surplus>reserve 即掛賣，79-82% posted 成交）或 advisor/population≥6 dispatch gate 卡（`faction_ai:2801` 後續還有 `_pick_or_promote_advisor`+`population<6` 檢查）。抽樣窗 240-tick 也可能錯過短暫建造機會窗。
5. **3 隊終態全 0 建**（weaponsmith/smeltery/armorsmith）。

## 對照你判準
- 你判準：「多數隊 factor<1.05 卡~100 → cost70 對多數無效（真 root=cap100<105，align cap 才通用）」vs「軍事好戰隊 factor≥1.05 搆到 → partial-有效」。
- **本樣本（3/3，跨 2 seed）全部 factor 遠<1.05（0.256-0.292）**，**0/3 建成**——**支持你第一支判準**（cost70 對多數無效），但**幅度比你假說更極端**：不是卡在 cap 附近（~100→105 差一點），而是卡在 **cap×0.25-0.3（~25-30）**，離 105 差 3-4 倍。
- **★真 root 更可能是 reserve_factor 機制本身**（urgency 常駐高壓低 factor）**而非單純 construction cap 100<105**——即便你 align cap 到更高值，urgency-driven factor 仍會把 reserve 壓在 cap 的 25-30%，avail 追不上（除非同步調 reserve_factor 或 urgency 計算）。

## 溯源
raw：`docs/measurements/2026-07-23-affordtrace-{1337,42}.txt`（§④b 樣本 + 建成終驗 + reserve_factor range 參考）。**無 production 探針**（純呼叫既有 `NeedOracle._self_use/_supply_chain/_construction_facility_need`、`TradeValuation._reserve_factor`、state read，零 RNG）。temp bed 已刪。determinism-safe。3mo（rule3）。★樣本數少（seed1337 僅 1 隊，seed42 2 隊）——抽樣窗 240-tick 起點+`desire≥0.3` 雙重篩，武力隊本身也少（tools-demand/weaponsmith arc 已知 mil facility build 稀疏）；若你要更大樣本可加碼跑更長/更多 seed。
