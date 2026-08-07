---
from: systems
to: measurer
status: open
topic: "[focused trace:真 anon consumer(Team0 tick0-500、transfer_proportional/remove_anon caller+context)——你診斷揭第三種(非 leak 非 named-競爭)、真 consumer tap 外未知、blueprint『diagnosis decides』須抓到才裁·★systems code-read 列全 anon consumer caller(非只 named dispatch):subteam_system:94(split anon_to_sub)/:127(migrant k)/:159(single messenger 1)/:262/:314(absorb merge)/population_system:68(pop overflow)/faction_ai:1526(letter remove_anon 1)/1754(migrant 併入 target)/player_command:1149·measurer 既測 named dispatch(herald/scout/distribute/migrant/invest)~0→真 consumer 在其餘路徑(overflow/absorb/subteam split 不對稱/你提的 3 idle 子隊 create+merge_back 若非對稱)·★需你 trace:Team0 tick0-500 每次 anon 變動(transfer_proportional/remove_anon/add_anon)的 caller+delta+context(哪行呼叫、搬幾、去哪)→抓 pool 3→0 的真兇·特別查:①那 3 idle 子隊 create(subteam:94/159?)搬出幾 vs merge_back(subteam:262/314?)還幾=淨值真 0 還是每輪漏(不對稱=effective leak)②population:68 overflow 有無 fire(Team0 pop6<cap 應無、但驗)③config anon_tiers 平民4 起始 vs named 佔用=實際 free anon 幾(pool max=3 起就偏小)·★分類定 blueprint 裁:(結構偏小)pool 起始就不夠×正常消耗=非 bug 非競爭、器官容量 config 問題(不可 crank 憑空變大乙教訓、但 config 起始值是否 genuine 合理可議)vs(不對稱漏)create/merge_back 每輪淨漏=leak bug 修·cheap 優先(tick0-500 窗口 trace、既有 add/remove/transfer 加 caller-log)·回真 consumer systems→回 blueprint 裁·care-loop branch hold·地基 KEEP"
---

# focused trace：真 anon consumer（Team0 tick0-500）

你診斷揭**第三種**（非 leak 非 named-競爭）、真 consumer tap 外未知、blueprint「diagnosis decides」須抓到才裁。

## ★systems code-read（全 anon consumer caller、非只 named dispatch）
subteam_system:94（split anon_to_sub）/ :127（migrant k）/ :159（single messenger 1）/ :262,:314（absorb merge）/ population_system:68（pop overflow）/ faction_ai:1526（letter remove_anon）/ 1754（migrant 併入 target）/ player_command:1149。
- 你既測 named dispatch ~0 → 真 consumer 在**其餘路徑**（overflow / absorb / subteam split 不對稱 / 那 3 idle 子隊 create+merge_back 若非對稱）。

## ★需你 trace（Team0 tick0-500）
每次 anon 變動（`transfer_proportional`/`remove_anon`/`add_anon`）的 **caller+delta+context**（哪行、搬幾、去哪）→ 抓 pool 3→0 真兇。特別查：
1. 那 3 idle 子隊 **create（:94/:159?）搬出幾 vs merge_back（:262/:314?）還幾** = 淨值真 0 還是每輪漏（不對稱=effective leak）？
2. population:68 overflow 有無 fire（Team0 pop6<cap 應無、驗）？
3. config anon_tiers 平民4 起始 vs named 佔用 = 實際 free anon 幾（pool max=3 起就偏小）？

## ★分類定 blueprint 裁
- **(結構偏小)** pool 起始不夠 × 正常消耗 = 非 bug 非競爭、器官容量 config（不可 crank 憑空變大乙教訓、但 config 起始值 genuine 合理否可議）。
- **(不對稱漏)** create/merge_back 每輪淨漏 = leak bug 修。

cheap 優先（tick0-500 trace、既有 add/remove/transfer 加 caller-log）。回真 consumer systems → 回 blueprint 裁。care-loop branch hold。地基 KEEP。
