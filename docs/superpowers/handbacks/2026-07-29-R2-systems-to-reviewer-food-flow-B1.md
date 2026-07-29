---
from: systems
to: reviewer
status: open
topic: "[R²·糧流B1糧橋+top-up·91fe5741·機制正確(go/no-go測sub.resources.food+通用food top-up收編礦山bootstrap接_dispatch_builder)+unit 4/4+gate74+determinism+世界不凍·★但bridge從不fire(bridge_nogo=0/topup=0)=A1 founding warring中從不dispatch(上游無動機)非B1缺陷·B1 execution-verified驗不了target(A1 build)因founding從不發起=A1上游economy問題非糧橋·判B1機制merge否] B1機制對但糧橋從不fire=A1上游(founding從不dispatch)。判機制merge vs hold。"
---

# R²：糧流 B1（糧橋 + food top-up）

## 做（機制正確）
- 糧橋 go/no-go（測 `sub.resources.food` 非 carry_capacity）+ 通用 food top-up（母隊撥、收編礦山 bootstrap）接 `_dispatch_builder`。
- unit 4/4 + headless 0-new + gate 74 + determinism byte-identical(ff152f30) + 世界不凍(attrition 2.03%)。

## ★execution-verified：糧橋從不 fire = A1 上游（非 B1 缺陷）
- seed1337 2mo：**complete_build=0 未變 + bridge_nogo=0/topup=0＝糧橋從不觸發** → `_dispatch_builder` warring 中**從不呼 for founding** → **A1 build 非 starvation（非糧橋 binding），是 founding 從不 dispatch（上游無動機）**。
- ∴ B1 機制正確（糧橋+top-up 邏輯對），但 **target(A1 build)沒 fire 因 founding 從不發起=A1 上游 economy 問題、非 B1 缺陷**（cross-slice tripwire 揭：target 沒 fire 但這次是上游沒發起、非機制覆蓋缺口）。坐實 Slice4(b)：A1 build 需和平 economy measure。

## ★reviewer focus（refute）
1. **B1 機制正確否**（go/no-go 測 sub.resources.food 非 carry_capacity、top-up 母隊撥、收編礦山 bootstrap 非疊加、接 _dispatch_builder）？
2. **世界不凍 + 純算術零 RNG**？
3. **★判 B1 merge vs hold**：糧橋從不 fire（bridge_nogo=0）＝A1 founding 上游從不 dispatch（非 B1 缺陷）——**B1 機制對、merge（未來 founding dispatch 時 gate 生效）vs hold（無 execution-verified target fire）**？我傾向 **merge 機制**（B1 邏輯對、A1 上游是別的根、糧橋是 dispatch 時的正確 gate 只是 warring 沒 dispatch），但 target(A1)驗不了因上游——你判這算 B1 execution-verified 過否。

**CLEAN+merge → B1 入袋（機制備好）；A1 build=0 上游 economy 問題我另回報 blueprint judge measure-scope。** 有洞 → 回 `to:systems`。
