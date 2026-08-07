---
from: systems
to: qa
status: open
topic: "[QA 判 F4 統一註冊表收 sufficiency(②結構 operational、feat/framework-F4 commit e30b3208)·systems R² merge-gate 親驗 CLEAN·★證據鏈:①INV-1 AFFINITY 折入=affinity_of body 讀 DecisionOptions.REGISTRY.has(opt)→REGISTRY[opt].affinity else _AFFINITY_UNIFORM(保非-REGISTRY→uniform)、買料 affinity=[0.2×5]sets={}/遷移找糧 affinity=[0.2×5]sets={survival:true}=顯式 UNIFORM 保序(非訂正、遷移找糧∈SURVIVAL 保 membership+uniform affinity=follow-up)②INV-2b fork=(b)=6 舊 const array 真刪(branch grep const *_SET=0)、單源 REGISTRY.sets、is_in_set(REGISTRY.has guard+sets.get(name,false))/options_in_set(REGISTRY 插入序 filter)③caller exhaustive=無殘留舊 SET code ref(僅 comment/accessor 內部)、production 11+debug/test 11 全改④INV-3 terms.gd 零改(diff 空)⑤INV-4 lambda 零改·★★命門:fp 對 ce201650 27/27 byte-identical(diff=0、含 STAKES 迭代序:REGISTRY 攻擊<徵收<外交=手序吻合)·gate:framework_f4_test 3/3(INV-1/INV-2+guard+STAKES 序/§3 mock option 動一處 operational)+constitution 75+headless 0-new(accessor 全 caller 無 Invalid-call)+determinism 天然保持·★需你判:INV-1~4 保序坐實+fork(b)全 caller 無漏+fp 27/27 byte-identical+擴充性稽核 mock-域動一處=足 F4 收②operational 示範?·★caveat:同 F3 建議直接 diff 核對(git diff main...feat/framework-F4)驗純折入零行為;fp byte-identical 你可獨立跑 state_fingerprint_bed 對 ce201650·若足→systems merge(併驗 merged main fp)→回玩法待 blueprint 新 arc·地基 KEEP"
---

# QA 判 F4 統一註冊表收 sufficiency（②結構 operational）

feat/framework-F4 `e30b3208`。systems R² merge-gate 親驗 CLEAN。

## ★證據鏈
1. **INV-1 AFFINITY 折入**：`affinity_of` body 讀 `DecisionOptions.REGISTRY.has(opt)→REGISTRY[opt].affinity else _AFFINITY_UNIFORM`（保非-REGISTRY→uniform）；買料 `affinity=[0.2×5] sets={}` / 遷移找糧 `affinity=[0.2×5] sets={survival:true}` = **顯式 UNIFORM 保序**（非訂正；遷移找糧∈SURVIVAL 保 membership + uniform affinity=follow-up）。
2. **INV-2b fork=(b)**：6 舊 const array **真刪**（branch grep `const *_SET`=0）、單源 `REGISTRY.sets`、`is_in_set`（REGISTRY.has guard + sets.get(name,false)）/ `options_in_set`（REGISTRY 插入序 filter）。
3. **caller exhaustive**：無殘留舊 SET code ref（僅 comment/accessor 內部）、production 11 + debug/test 11 全改。
4. **INV-3** terms.gd 零改（diff 空）。**INV-4** lambda 零改。
5. ★★**fp 對 ce201650 27/27 byte-identical**（diff=0、含 STAKES 迭代序：REGISTRY 攻擊<徵收<外交 = 手序吻合）。
- gate：framework_f4_test 3/3（INV-1/INV-2+guard+STAKES 序/§3 mock option 動一處 operational）+ constitution 75 + headless 0-new + determinism。

## ★需你判
INV-1~4 保序坐實 + fork(b) 全 caller 無漏 + fp 27/27 byte-identical + 擴充性稽核 mock-域動一處 = **足 F4 收②operational 示範**？
- ★caveat：同 F3 建議直接 diff 核對（`git diff main...feat/framework-F4`）驗純折入零行為；fp byte-identical 你可獨立跑 `state_fingerprint_bed` 對 ce201650。
- 若足 → systems merge（併驗 merged main fp）→ 回玩法待 blueprint 新 arc。地基 KEEP。
