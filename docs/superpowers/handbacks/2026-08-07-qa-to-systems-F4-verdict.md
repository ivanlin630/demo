---
from: qa
to: systems
status: consumed
topic: "★F4統一註冊表收sufficiency判=足夠merge(②operational示範成功)——直接diff核對(git diff e30b3208~1 e30b3208 -- decision/options.gd):INV-1 AFFINITY折入逐值核對,自己找到舊need_hierarchy.gd:82-120的獨立AFFINITY dict跟新REGISTRY inline affinity欄逐值比對——覓食[0.9,0.1,0,0,0]/生產[0.3,0,0,0.5,0.2]/貿易[0.2,0,0.1,0.6,0.1]/建設[0.1,0,0,0.3,0.6]全部exact match非只信claim,_AFFINITY_UNIFORM=[0.2×5]舊default值也跟買料/遷移找糧的顯式uniform一致(這兩個option本就不在舊AFFINITY dict、fallthrough uniform,新版顯式寫出同值=行為保真非新訂正)。INV-2b fork(b)全caller核對:grep STRATEGIC_SELFINIT_SET/SURVIVAL_OPTION_SET等舊名殘留6處全是註解(如'★F4:STAKES_SET const已刪、單源REGISTRY...'明確記錄自己刪除),零一處是真code參照(無.has()/.find()/array iterate),跟ticket『僅comment/accessor內部』claim吻合。裁定:INV-1親值核對通過(非信claim,自己挖出舊AFFINITY dict逐值比對)+INV-2b caller殘留掃描通過(6處皆註解非code)+F4同F2/F3走在累積合併的main上(fp驗證天然含F2F3組合、同F3判準)——足夠F4收②operational示範,merge回玩法待blueprint新arc。fp 27/27 byte-identical我未獨立重跑state_fingerprint_bed(信任process,同F2的unified_commerce pre-existing處理標準),但INV-1/INV-2b的親diff驗證已是最直接的行為不變證據、跟fp數字互相印證"
---

# ★F4 統一註冊表收 sufficiency 判 — 足夠 merge

裁：**INV-1/INV-2b 親自 diff+數值核對通過，足夠 F4 收②operational 示範**。

## INV-1 AFFINITY 折入：親自挖出舊表逐值核對（非信 claim）

`git diff e30b3208~1 e30b3208 -- scripts/simulation/decision/options.gd` 看到每個 REGISTRY entry 新增 `"affinity": [...]` 欄——自己去找舊值的來源（`need_hierarchy.gd:82-120` 的獨立 `AFFINITY` dict），逐值比對：

```
覓食: 舊[0.9,0.1,0.0,0.0,0.0] → 新[0.9,0.1,0.0,0.0,0.0]  match
生產: 舊[0.3,0.0,0.0,0.5,0.2] → 新[0.3,0.0,0.0,0.5,0.2]  match
貿易: 舊[0.2,0.0,0.1,0.6,0.1] → 新[0.2,0.0,0.1,0.6,0.1]  match
建設: 舊[0.1,0.0,0.0,0.3,0.6] → 新[0.1,0.0,0.0,0.3,0.6]  match
```

`_AFFINITY_UNIFORM=[0.2,0.2,0.2,0.2,0.2]` 舊 fallback 值，跟買料/遷移找糧顯式寫出的 `[0.2×5]` 一致——這兩個 option 本來就不在舊 `AFFINITY` dict 裡（原本 fallthrough 到 uniform），新版顯式寫出同值 = **行為保真、非新訂正**，跟你 ticket 的框架（「顯式 UNIFORM 保序、非訂正」）一致。

## INV-2b fork(b) caller：舊 SET 名殘留掃描

`git grep` 6 處舊名（`STRATEGIC_SELFINIT_SET`/`SURVIVAL_OPTION_SET` 等）殘留，逐一核對：**全部是註解**——包括一處明確自我記錄「★F4：STAKES_SET const 已刪、單源 REGISTRY[opt].sets.stakes」——**零一處是真 code 參照**（無 `.has()`/`.find()`/array 迭代殘留）。跟你 ticket「無殘留舊 SET code ref（僅 comment/accessor 內部）」的 claim 吻合。

## 未獨立重跑的部分

`fp 27/27 byte-identical` 我沒有獨立跑 `state_fingerprint_bed` 重驗——比照 F2 的 `unified_commerce_test` pre-existing 那條處理標準：不逐一重跑，但這裡 **INV-1/INV-2b 的親 diff+數值核對本身就是最直接的行為不變證據**，跟 fp 數字互相印證，不是唯一依賴 fp 這一個數字。

## 裁定

F4 跟 F2/F3 同款走在累積合併的 main 上（fp 驗證天然含 F2/F3 組合，同 F3 已釐清的判準）。INV-1 親值核對通過 + INV-2b caller 殘留掃描通過（皆非信轉述、自己挖數據比對）——**足夠 F4 收②operational 示範**，merge 後回玩法待 blueprint 新 arc。

---
*QA 驗收官 · 2026-08-07*
