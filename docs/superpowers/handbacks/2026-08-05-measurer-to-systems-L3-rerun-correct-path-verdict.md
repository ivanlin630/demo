---
from: measurer
to: systems
status: consumed
topic: "L3 rerun-correct-path verdict:★★QA『stale --path』假說本身查核後不成立(我上輪specimen run的--path確實正確指到.worktrees/L3-circuit-trade),真根因=我自己那輪只temp掛SpecimenDumpHelper hook、忘記重掛market.visit_util/g1.arb_attempt兩個temp PROBE_KEYS(該輪從乾淨revert狀態重開始編輯,只加了specimen 2行,沒帶回上一票的tap行)→_probe_subset()回傳字典裡沒這兩key→我print用.get(k,0)預設吐0,誤讀成『功能沒fire』,非code真沒跑;此次rerun(同worktree同HEAD 06c8b452,git rev-parse驗證過)補齊兩tap後market.visit_util=1186/g1.arb_attempt=744——跟我最早『L3 behavior verdict』那輪(第一次量測時就有這兩tap)數字逐位元相同,trade.deal=8/merchant1/resident7/market_arrive17也跟QA讀到的stale版數字完全一樣(=這組數字從頭到尾都是真數,不是main假數字，QA的symptom觀察對but root-cause歸因猜錯,我自己漏tap的責任)。specimen v2(同config同seed同SPECIMEN_TEAM_ID)產出同2717 entries(byte-size相同),侧面confirm determinism。★★根因2(床不足factions:1/established:0)confirm屬實維持不變,非我能單解如工單所述,交blueprint床策略。已誠實認錯+補正數字，別下accept，等blueprint床策略+QA重讀"
---

# L3 rerun-correct-path：QA『stale --path』假說查核後不成立，真根因是我自己漏補 tap

## ★★誠實認錯：QA 的 symptom 觀察對，root-cause 歸因猜錯——真正原因是我自己漏補 temp tap

先重驗了 `--path` 本身：`git -C .worktrees/L3-circuit-trade rev-parse HEAD` = `06c8b452`（`feat/L3-circuit-trade` 分支頭），跟我上輪 specimen 跑的路徑一致——**`--path` 從頭到尾都是對的，指的就是 L3 branch**。

真正原因：上輪「L3 specimen for QA」那張票，我從**乾淨 revert 過的狀態**重新開始編輯 `warring_harness.gd`，**只加了 `SpecimenDumpHelper` hook 2 行**，**忘記把上一票（L3 behavior verdict）用過的 `market.visit_util`/`g1.arb_attempt` 兩個 temp PROBE_KEYS 條目也帶回來**（每次 revert 都是乾淨的，temp 條目不會自動殘留，我需要每輪重加）。少了這兩 key，`_probe_subset()` 回傳的字典裡根本沒這兩項，我 print 時用 `.get(k, 0)` 預設吐 0——**我自己誤讀成「功能沒 fire」，寫進上輪 verdict 時沒有把這個落差攔下來，是我的疏漏**，不是 code 真的沒跑（QA/systems 順著這個 0 值去推「stale main 碼」是合理的懷疑方向，但實際成因不是 `--path`）。

## 本輪 rerun 結果（同 worktree、同 HEAD、補齊 tap）

```
attrition=18.03% final={teams:16, factions:1, established:0}
g1.seek_market=523  g1.arb_attempt=744  market.visit_util=1186
trade.deal=8  trade.deal_market=8  trade.deal_merchant=1  trade.deal_resident=7  g1.market_arrive=17
```

**跟我最早「L3 behavior verdict」那輪（第一次量測、當時就有這兩 tap）數字逐位元相同**——`market.visit_util=1186`/`g1.arb_attempt=744` 完全一致。**`trade.deal=8`/`merchant=1`/`resident=7`/`market_arrive=17` 也跟 QA 讀到的「疑似 stale」那版數字完全一樣**——這組數字從第一次量測起就是真數，L3 機制真的有在跑，只是我在 specimen 那輪的 print 輸出漏了兩個 key 導致誤導性的 0 值。specimen v2（同 config/seed/SPECIMEN_TEAM_ID）也產出同 **2717 entries**（檔案 byte 數相同）——側面確認 determinism，不是 stale run 造成的偶然巧合。

## ★★根因 2（床不足）確認屬實，維持不變

`factions:1 / established:0` 確實是這個 rep 床的真實收斂結果——跟我在 T3-attribution/faction-rich-rep 兩輪查到的「event_faction_defect + uprising 造成 member 自行脫 faction」結構性 pattern 一致。**這不是我這輪能單解的問題**（如工單所述），交 blueprint 床策略判斷是否需要一個更穩定的 ≥2-faction+established 床。

## 落地檔案（已 ls/wc 驗證存在）

- `docs/measurements/2026-08-05-l3-rerun-correctpath-run.txt`（12342行，完整 log）
- `docs/measurements/2026-08-05-l3-rep-specimen-v2-correctpath.jsonl`（2717 entries，跟上輪同大小）

## 清理狀態

- `warring_harness.gd` temp PROBE_KEYS + SpecimenDumpHelper hook 已 `git checkout --` 還原確認乾淨。
- temp `l3_rerun_correct_path_bed.gd` + 借測 config + worktree 內重複 jsonl 皆已刪除。

## ★誠實淨判

- QA 抓到的 symptom（0 值可疑）是對的，merge-gate 起作用值得肯定——但**歸因（stale --path）本輪查核後不成立**，真根因是我自己的 tap 覆蓋疏漏，已認錯更正。
- L3 機制數字（visit_util/deal/market_arrive）**從頭到尾都是真數**，不需要因為這次誤會而重新懷疑機制本身。
- 床不足（factions:1/established:0）依然是真實、獨立的問題，交 blueprint 判床策略。

別下 accept。等 blueprint 床策略決議 + QA 重讀這輪更正數字。
