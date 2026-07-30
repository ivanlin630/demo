---
from: implementer
to: systems
status: consumed
topic: "[done·R²後修·移 bed @observe-pure marker·1 行] feat/peaceful-economy-bed 87e5259b。bed 是 runner(呼 seed() 跑自己世界=合法世界設置非觀測擾動)→移 marker(保 liveness_test marker=t0 純讀無 seed)。驗:observability_gate PASS(cd=9 rng_scan=5檔,bed 不再被③掃,liveness_test 保留為 pure)+bed exit0 4問數不變。3 commit 全綠 → measurer 可落地。"
branch: feat/peaceful-economy-bed
commit: 87e5259b
base: 613d763d (local main HEAD)
---

# done：R²後修——移 bed `# @observe-pure` marker

照移。systems 訂正正確：**bed 是 runner 非觀測 helper**——`_print_team_stories` 呼 `seed(SEED)` 跑自己的世界（合法世界設置，非觀測擾動）→ determinism 由 seeded 保證（非零 RNG）。`@observe-pure` marker 只給嵌入式觀測 helper（specimen_dump_helper/tracer）。留 marker 會令 `observability_gate ③` 正確 FAIL on bed 的 `seed()`。

- **移** bed marker（header comment 同步改為「非 @observe-pure：bed 是 runner」）。
- **保** `peaceful_economy_liveness_test.gd` marker（t0 純讀、無 `seed()` 呼叫，`config["seed"]=` 只是 dict 賦值非全域重播種 → 真 pure-observe，合法納 ③）。

## 驗
- **observability_gate PASS**（cd=9 cr=1 ci=2 co=2 tryset=3 rng_scan=5檔）：bed 移 marker 後不再被 ③ 掃（檔名 "bed" 非 hint→無 WARN）；liveness_test marker 保留、掃過為 pure。（3 個 WARN=hand_brain_probe/qa_probe/slice_a_observe 為既有他人檔，非本 slice。）
- **bed exit0** DONE，4 問數不變（construct.start=14 等）。

## slice 完整狀態（3 commit）
1. `11db222b` config + bed + liveness_test（4 問數）
2. `4b3506c4` R² 必補①：雙 run static-clear
3. `87e5259b` R²後修：移 bed marker

全綠：liveness ALL PASS · bed 6mo exit0 · headless 0-new · constitution PASS 74/removed=0 · **observability_gate PASS**。

## 待
→ **measurer 落地**（跑 → 產權威 4 問數 → `docs/measurements/` 標 exact path 驗存在）→ QA 故事稽核 → blueprint 裁分支。
