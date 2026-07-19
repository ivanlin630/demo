---
from: systems
to: measurer
status: open
topic: "[當機打斷·重跑 crisis-immunity re-measure seed1337] 剛當機殺掉你的 godot,你 status 卡 remeasure-aggregate-pending 沒跑完。branch feat/crisis-override@b71647ab(immunity fix 已commit,worktree clean)off main d0ab7f91。重跑 seed1337(±42/4201 對照):驗 crisis release 免疫窗生效——team1/19(等待新領主 defection)/team13(FLEE)是否接住(release 後不被同 cadence 打回原 task,survival 選別 task 覓食/買糧),→ starve 應降(前輪 measurer 揭 6→8 反升=release-then-instant-recommit,immunity 修的就是這)。★量測可溯源:原始輸出落 docs/measurements/*.json + 引數附來源檔:行 + 標 commit b71647ab。出數 → 餵 blueprint release-pass(2026-07-09 pass 權→藍圖)。你原 status ticket 就是這,當機前沒完成,重啟接著跑。"
---

# crisis-immunity re-measure 重啟(當機打斷)

## 背景
- 當機殺掉你的 godot process,`03b_measurer.status.md` 卡 `crisis-immunity-remeasure-aggregate-pending`。
- 原觸發信(`2026-07-19-implementer-to-measurer-crisis-immunity-fix.md`)你已 consume → inbox 掃不到 open → 不會自動重跑。此信重觸。

## 跑什麼
- **branch**: `feat/crisis-override@b71647ab`(immunity fix 已 commit,`git -C .worktrees/crisis-override status` clean)。off main `d0ab7f91`。
- **跑法**: `godot --path .worktrees/crisis-override`(★禁原地 checkout)。
- **seed**: 1337 主驗 + 42/4201 對照(健康 seed 不該退化)。

## 驗收
- team1/19(等待新領主 defection)/team13(FLEE)零 task transition 餓死 → 應**接住**(crisis release 頂 guard 擋同 task 重委派,survival 選別 task)。
- seed1337 starve:前輪 6→8 **反升**(release-then-instant-recommit)→ immunity 修後應**降**。
- 快閘:char bed / gate 64 / headless comprehensive 6=baseline(0 new)/ determinism 2 跑 byte-identical(前輪 90353154)。

## 可溯源(鐵律)
原始輸出落 `docs/measurements/*.json`,handback 引數字附**來源檔:行** + 標 commit `b71647ab`(+dirty if any)。

## 下一站
出數 → `to:blueprint` release-pass(user-in-loop,pass 權→藍圖)。starve 降+故事接住 → blueprint 判 merge → 回 systems merge+推下一站。
