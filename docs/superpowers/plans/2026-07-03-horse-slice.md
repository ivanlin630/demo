# 馬經濟最小 slice — Plan

> Spec：`docs/superpowers/specs/2026-07-03-gift-alliance-horse-slice-design.md` **§B**（先讀,§A 是結盟軌勿做）。
> 消費端全在（movement 騎乘/速度/carry）,只建來源+入交易網。

## Task 1 — 產馬區
`world_generator.gd`:部分 plains tile 撒 `resource_cap["mounts"]`,**集中成帶**（產馬帶=戰略不對稱地基,非均撒;密度/量 TEST VALUE）。不加地形 enum。seed 化下確定性（world_gen 用 config seed,確認撒點走 seeded rng 流）。

## Task 2 — stable 轉化鏈
`outpost_system.gd` stable tick（**僅此函數**,佔村軌同檔勿越）:有 mounts resource_cap 的 tile 上 stable 產 mounts 入 owner（複用 harvest/mint 產出 pattern;速率 TEST VALUE）。資源語意走既有 regen/harvest（非憑空,coin_eq 無關但 pop/資源守恆審計過）。

## Task 3 — 馬入交易網
mounts 補 `local_value`（高值）+驗訂單鏈一單流通（賣盤含 mounts→他隊買→到手）。config 改自由（任何層可改）。

## Task 4 — 驗收
- seeded/longwindow:世界 mounts>0;至少一隊經貿易/收成獲馬;**信使獲馬 3× 速**——default config 跑對照 envoy timeout 降（前 5/6 timeout）。
- 回歸全綠（1 FAIL pre-existing 容忍/framework 7/7/coin_eq/InvariantAudit）;headless 測:產馬/stable 轉化/貿易一單。

## Handback
`2026-07-03-horse-slice.md`:產馬帶佈局、mounts 流通證據、envoy timeout 前後、TEST VALUE 清單。

## 注意
平行紀律:**勿碰** `diplomatic_ai`/`npc_combat`/faction_ai 決策函數（他軌）。禁運/馬政/騎兵戰=hook 不做。Godot wrapper;1 FAIL pre-existing。
