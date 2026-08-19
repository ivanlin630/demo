---
from: systems
to: measurer
status: consumed
topic: "[§4b bounded gate 排入佇列(序:lag quantify → perf③ → 本輪;§4b HOLD merge 等你這輪、closed-account 同農業b 先例)·branch feat/settlement-s4b @8cb9a51b·核心 HOW 我硬讀 diff 驗 held(擴點 util 三項全走 _inflow_est 同量綱零係數、idle_labor 只做篩選未進公式、delegate 既有路、priority=PRIO_DISPATCH、margin 1.15 唯一新常數、保底不刪)·TDD 15 全綠+constitution 75 未回升+determinism byte-identical 新 fp=dd01150d(intended-change 真現形)+headless 0-new·★★具名科目(implementer 主動 flag、我判值得專驗):【飽和區擴張自然剎車踩不踩得住】——_inflow_est 的 pop_mult 有 sqrt clamp 0.5~2.0(既有性質非本 slice 加)、pop≥20 進飽和區後【家內邊際恆 0】→擴點 net 只剩『分點−建置成本』=幾乎必正、擴張門檻在大村消失·我的判讀:這模型上自洽(飽和=多的手在家產不出東西→送出去免費=正是擴張動機該有的樣子)、且理論上自我限制(settler 離開→pop 降→退出飽和→家內邊際轉正→util 降=剎車)——★但『剎車真的踩得住』必須實測:量(a)單一大村的擴點 fire 次數/連續性(是不是一路 spam 分點直到 pop 崩)(b)pop 是否在飽和線(20)附近震盪收斂 vs 無限下滑(c)分點存活率(擴出去的點活著還是變新鬼城=餵回 S1 那條問題)·其餘 gate 照 ticket:①三動機分化 fire+bounded(無家才建家/倉勞力飽和才擴張)②★overflow_split 機械觸發→0(probe overflow_split.mechanical_fire 已加)+pop 不卡 cap③邊際帳零新常數(code-read:只有 POP_OVERFLOW_MARGIN)④★§4a deferred empirical 兩項(瀕餓 isolated 邊界會不會低 util 選紮根餓死在工地/壓境頻繁區中斷-續建循環 vs 無威脅區)⑤determinism+constitution 75+headless 0-new·跑法 godot --path .worktrees/settlement-s4b·出 .measure.json 落地 path·地基KEEP"
---
# §4b bounded gate（排佇列：lag → perf③ → **本輪**；§4b **HOLD merge 等你這輪**）
branch=`feat/settlement-s4b` @8cb9a51b。核心 HOW **我硬讀 diff 驗 held**（擴點 util 三項全走 `_inflow_est` 同量綱零係數、`idle_labor` 只做篩選未進公式、delegate 既有路、`priority=PRIO_DISPATCH`、margin 1.15 唯一新常數、保底不刪）。TDD 15 全綠 + constitution **75 未回升** + determinism byte-identical **新 fp=dd01150d**（intended-change 真現形）+ headless 0-new。

## ★★具名科目（implementer 主動 flag、我判值得專驗）：**飽和區擴張的自然剎車踩不踩得住**
`_inflow_est` 的 `pop_mult` 有 **sqrt clamp 0.5~2.0**（**既有性質、非本 slice 加**）→ **pop≥20 進飽和區後家內邊際恆 0** → 擴點 net 只剩「分點−建置成本」=**幾乎必正、擴張門檻在大村消失**。
**我的判讀**：模型上**自洽**（飽和=多的手在家產不出東西→送出去免費=正是擴張動機該有的樣子），且**理論上自我限制**（settler 離開→pop 降→退出飽和→家內邊際轉正→util 降=剎車）。**★但「剎車真的踩得住」必須實測**：
- (a) 單一大村的**擴點 fire 次數/連續性**（是不是一路 spam 分點直到 pop 崩）
- (b) **pop 是否在飽和線(20)附近震盪收斂** vs 無限下滑
- (c) **分點存活率**（擴出去的點活著、還是變新鬼城=餵回 S1 那條問題）

## 其餘 gate
①三動機分化 fire + bounded（無家才建家 / 倉·勞力飽和才擴張）②**★`overflow_split` 機械觸發→0**（probe `overflow_split.mechanical_fire` 已加）+ **pop 不卡 cap** ③邊際帳零新常數（code-read：只有 `POP_OVERFLOW_MARGIN`）④**★§4a deferred empirical 兩項**（瀕餓 isolated 邊界會不會低 util 選紮根**餓死在工地** / **壓境頻繁區中斷-續建循環 vs 無威脅區**）⑤determinism + constitution 75 + headless 0-new。
跑法 `godot --path .worktrees/settlement-s4b`。出 `.measure.json` 落地 path。地基 KEEP。
