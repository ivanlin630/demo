---
from: systems
to: reviewer
status: consumed
topic: "[R²·observer-RNG靜態閘實作·feat/observer-rng-freeze-gate f79bd8ac·observability_gate③ RNG scan(observe-pure marker檔禁7向量,negative lookbehind (?<![\\w.])逃生口,pick_random/shuffle方法型照抓,seed裸括號抓rng.seed=不抓)+constitution_gate RNG_RE擴4新向量+3核心檔marker+marker-missing WARN·驗observer_rng_gate_test 14/14+constitution 74 removed=0+headless 0-new·★①drift我已ratify(baseline 10→9 subsumption已驗)] 實作審機制:逃生口regex真擋真放+7向量齊+constitution baseline一致。①drift systems已解。"
---

# R²：observer-RNG 靜態閘實作

## impl
branch `feat/observer-rng-freeze-gate` f79bd8ac（off 7620b605）。spec §2/§2a/§2b（R² 訂正 7 向量版）。

## 做（implementer handback）
- `observability_gate.gd` ③ RNG scan：`scripts/debug/` 全 `.gd`、只對 `# @observe-pure` marker 檔跑 7 向量。函式型 `RNG_FUNC_RE`（randf/randi/randf_range/randi_range/randfn/randomize/seed）+ **negative lookbehind `(?<![\w.])` 逃生口**（`rng.randf(` 本地放行、bare 抓）；方法型 `RNG_METHOD_RE`（`.pick_random`/`.shuffle` 照抓不吃逃生口）；`seed` 裸括號抓 / `rng.seed = x` 賦值不抓；marker-missing 非阻斷 WARN。
- `constitution_gate.gd` `RNG_RE` 擴全 4 新向量（兩閘一致）。
- 核心 3 檔 marker（specimen_dump_helper/specimen_tracer/probe_stats）。
- 驗：`observer_rng_gate_test` **14/14** + constitution **74 removed=0** + headless **0-new**（sim 未動）。

## ★reviewer focus（複審實作 vs spec）
1. **negative lookbehind `(?<![\w.])` 真擋真放**：`rng.randf(`/`_local.randi_range(` 放行、bare ` randf(`/`=randf(`/行首 `seed(` 抓——**GDScript RegEx 的 lookbehind 支援真如此**否（14/14 test 涵蓋但你獨立驗 regex 本身）？
2. **pick_random/shuffle 方法型不吃逃生口**對否（你 R² 已核斷言、確認實作真分兩條 regex）？
3. **constitution_gate baseline 一致**：RNG_RE 擴後 74 removed=0（sim 決策檔本無新向量）——親驗 sim 無 pick_random/shuffle/seed/randfn 漏網？
4. **marker 只 3 檔**夠否（你 R² 標 marker-missing 記性依賴＝我納 WARN 緩解，複查 WARN 真觸發）？

## ★① drift systems 已解（非本 R² 標的、告知）
`observability_gate` ① capture_decision 9<baseline 10 = **d5b5cb73 threat-oracle-S3 converge 移 Fix3 threat tap**（threat 決策 converge 進 `_decide_unified`、由統一 commit loop capture_decision(:1621) 承接＝**subsumption 非 coverage gap**，commit msg「specimen 由 _decide_unified commit loop 承 DRY」佐證）。**已驗 subsumption 才 ratify** baseline 10→9（main 669b52b3，gate 現綠）。順帶 tryset 6→3（unified 用 `_prio` 變數逃 tryset_re＝check② 對 unified 主路徑部分失明，regex 盲區已記 known_issues 待未來 refine）。

## 判
CLEAN → merge-gate 接入（orchestrator merge 前跑 observability_gate；merge 帶 main 669b52b3 ratified baseline）。framework 閘、measurer/QA 無需。有洞（尤其 regex 真擋真放）→ 回 `to:systems`。
