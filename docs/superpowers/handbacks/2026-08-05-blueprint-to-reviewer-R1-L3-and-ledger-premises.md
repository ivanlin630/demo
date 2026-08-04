---
from: blueprint
to: reviewer
status: open
topic: "[R① factcheck×2·補完批兩spec前提·(1)L3循環貿易=docs/superpowers/specs/2026-08-05-L3-circuit-trade-design.md:P1 read_market_board(order_system:194)=到場firsthand讀板·P2 best_arbitrage_order+MERCHANT_MAX_RANGE=20(order_system:233/240)=商人只對已聽聞單反應、無『主動去讀板』決策(=缺口本體,重點驗)·P3 settled隊無訪外市集候選生成路(§5 measured board_read沒fire)·P4 L2同格撮合+keep-line已merged活·(2)失聯帳本=docs/superpowers/specs/2026-08-05-missing-contact-ledger-design.md:P1派出單位無統一tracking(herald/scout有lifecycle taps但母隊側無預期回報帳;subteam/convoy各自無失聯感知——★重點驗:若已有散落tracking要找出來統一非新建,同3旋鈕教訓)·P2 scout side-dispatch已merged活(反應端既有)·P3 belief store可承載失聯flag(加類型非新store)·兩spec核心guardrail已用戶ratified(L3路線湧現非waypoint/帳本人格反應非死常數),R①只驗code前提·CLEAN→鎖→systems R²→build(各自新slice branch)"
---

# R① ×2 — L3 循環貿易 + 失聯帳本 前提

兩 spec 的 WHAT guardrail 已用戶 ratified；R① 只驗 code 前提。

## (1) L3（`2026-08-05-L3-circuit-trade-design.md`）
| # | 斷言 | 重點 |
|---|---|---|
| P1 | `read_market_board`（order_system:194）= 到場 firsthand 讀板 | 事實 |
| **P2** | `best_arbitrage_order` + `MERCHANT_MAX_RANGE=20`（:233/240）= 商人**只對已聽聞單反應、無「主動去讀板」決策** | **缺口本體、重點驗**（若已有主動訪市路 = spec 白做） |
| P3 | settled 隊無訪外市集候選生成路（§5 measured） | 事實+詮釋 |
| P4 | L2 同格撮合 + keep-line 已 merged 活 | 事實 |

## (2) 失聯帳本（`2026-08-05-missing-contact-ledger-design.md`）
| # | 斷言 | 重點 |
|---|---|---|
| **P1** | 派出單位**無統一 tracking**（herald/scout 有 lifecycle taps 但母隊側無預期回報帳；subteam/convoy 各自無失聯感知） | **重點驗：若已有散落 tracking → 找出來統一、非新建**（3 旋鈕教訓） |
| P2 | scout side-dispatch 已 merged 活（反應端既有） | 事實 |
| P3 | belief store 可承載「失聯」flag（加類型、非新 store） | 事實+詮釋 |

CLEAN → 我鎖 → systems R² → build（各自新 slice branch）。contradiction → 回我修根。
