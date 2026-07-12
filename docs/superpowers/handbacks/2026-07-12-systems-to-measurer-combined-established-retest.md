---
from: systems
to: measurer
status: consumed
topic: [組合重測·established B2] forage+command-tenure併入feat/command-tenure-growth(main已含forage)—重測B2是否鬆動;3mo快答+established苗頭右尺寸
---

# 組合重測：forage + command-tenure → established B2 鬆動了嗎

forage-floor-tune 已 merge main。**已把 main（含 forage）merge 進 `feat/command-tenure-growth` worktree** → 該 worktree 現 = **forage苟活 + command-tenure統領成長 組合**（已驗:FORAGE_FLOOR_DAYS=5 + PASSIVE=0.30 + _grow_leadership_tenure 全在）。

## 假設（blueprint）
command-tenure 單獨測 B2 100% 卡（leader 週轉吃成長）。**現急性崩腰斬（attrition 47%→17-31%）→ leader 活久了 → tenure 累積前提可能變**。重測組合:B2 鬆動嗎？

## 要你（跑 `--path .worktrees/command-tenure-growth`）
1. **established B2 funnel**（既有 probe）：`gate_fail_b2_command` vs `gate_b1_ok`——**還 100% 全等（卡死）還是有通過案例**？+ `gate_all_pass`/`established` 有無 >0。
2. **★leader tenure 交叉**（blueprint 要，若 B2 仍卡才需）：tune 後 **leader 平均在任天數** vs 爬 B2 門檻所需 170-430 日。在任中位數若仍 << 170 → 還缺多少（判要不要加碼 succession 繼承/授XP）。
3. **統領值軌跡**：leader 統領 12mo 內爬升（凍 ~0.25 → 有無漸升過門檻）。

## 右尺寸（承前砍法）
- **3mo 快答先報**：急性崩已知緩解;3mo 看 B2 有無「鬆動苗頭」+ leader 在任是否拉長。**established 是慢變量,3mo 可能還沒 >0**——標「苗頭/趨勢」非判失敗。
- **12mo 續跑 winner/代表 seed 1-2 個**看 established 完整趨勢（不必 3seed×12mo 滿跑）。
- config default.json,seed 沿用 1337/42/7 跨輪對照。

## 判讀分岔（回報帶你的數字，blueprint 判方向）
- **B2 鬆動 + established>0** → 「一修多解」實證,四層門一起鬆假說成立 → command-tenure 可 merge。
- **B2 仍卡** → leader 在任改善不夠 → 量交叉點缺口 → 回報「需加碼」（succession 繼承/授XP/速率提）。

## 註
- 這是組合測（forage 已 merged 當上游 + tenure 疊加），非各自獨立。
- 3mo 報 blueprint（不等 12mo）。determinism 若組合後變（tenure+forage 疊）順帶驗 byte-identical。
