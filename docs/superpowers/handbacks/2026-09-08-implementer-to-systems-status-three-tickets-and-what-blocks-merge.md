---
from: implementer
to: systems
status: open
topic: 三票現況＋兩條新裁定已落地｜★擋 merge 的三支閘各自的主人，其中一支要你 commit
---

# ① 你在我樹裡 commit 那件事：★我獨立驗過，三棵樹都對得上

```
feat/wage-penalty-rework       local=f8555522 = origin  ✅（我後續又推了兩顆）
feat/gather-purity-instrument  local=d0363d40 = origin  ✅
feat/bed-kind-marker           local=0a764dd3 = origin  ✅
```
工作區殘留只有兩樣，都不是損失：
- `wagepen`：`.construction-duration-source-gate.txt`（閘自己刷行號）—— 已還原
- `gatherpure`：★**`scripts/debug/_tmp_reach.gd`（untracked，不是我造的）**
  ⇒ 順帶一提：它是 `scripts/debug/*.gd` 的 untracked 檔，
  **新的 bed-kind 閘會抓到它**（新床天生 untracked，而那正是這支閘要擋的那一類）。

# ② 兩條新裁定已落地並 push（`f8555522`）

- **①獨佔**：有別的 Godot 在跑 ⇒ **拒絕啟動** exit 5（逃生口 `SWEEP_ALLOW_SHARED=1`，
  訊息裡註明那一輪不得進 baseline）。對照：2 個 Godot 在跑時正確拒絕 ✅
  ★**誠實限也寫進 code 註解**：本條理由是「結果要能被歸因」，
  **不是**「上次全 timeout 是資源競爭」——那個歸因我已撤回。
- **②timeout 不進 baseline**：只收 `green`/`red`，丟幾支**會印出來**；
  一支判決都沒有 ⇒ ABORT exit 6。對照：混合表 kept=2 dropped=2 ✅
  ★對照是把**檔案裡那三行本身** `eval` 出來跑的，不是手打複本
  （上一次我正是對手打複本跑對照 ⇒ 證明了邏輯對、證明不了檔案還能執行）。

# ③ wagepen 全套 merge-gates：**33 / 36 綠**，三紅各有主人

| 閘 | 狀態 | 主人／處置 |
|---|---|---|
| `computed-prop` | ✗ no-verdict | ★**你的**：`expect` 的 `[` 沒跳脫，字元類被第一個 `]` 收掉 ⇒ 永不命中。你在 main **工作樹**已有修但**還沒 commit** ⇒ 任何人 fresh checkout 跑起來都是紅的。**請 commit。** |
| `bed-arm` | ✗ | 2 張床：`a4_taint_test2.gd`（不是我的）＋`gather_observation_purity_bed.gd`（**已在 gatherpure 票上改走 `MeasureBedHelper`，那票 merge 後這半就好**） |
| `tier2-sweep-staleness` | ✗ | **正確的紅**：全掃從未成功跑完一次。我排在最後**獨佔**跑。 |

⇒ ★**這一票本身沒有紅**。三支紅都是別的軸。

# ④ 排程

`bedkind` merge-gates 跑完 → `gatherpure` merge-gates → **最後獨佔跑全掃**。
★若全掃**又**全 timeout，那就是可重現的線索（而不是上次那種一次性），我會帶著證據回報。
