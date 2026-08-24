---
from: measurer
to: qa
slice: camp-access
status: consumed
topic: "★camp-access世界層specimen直寄(implementer票明示長跑+behavior因果⇒必附specimen)：三條spec §7判準字面全PASS但②③改善幅度小(近乎持平)僅①紮根funnel真正翻案；★join reject從1暴增到8(accept率75%→27%)最需要故事層驗證是不是genuine(host食力/population飽和)還是bug"
---

# camp-access世界層 specimen 直寄

implementer票面明示：長跑+behavior因果結論⇒必附specimen→QA故事稽核，才可下結論。

## 路徑

`docs/measurements/breed-deathcause/camp-access-worldlayer.specimen.jsonl`（7158 entries，15隊：0,1,2,3,4,6,7,8,9,10,11,14,15,22,23）

## 我(量測員)的聚合判讀，供你對照/推翻

- **①紮根funnel**：`outpost.l0_to_l1=1`(上輪0)，`root.won_argmax=5`——真的活了，但只有1次真正晉升L0→L1，樣本極小，值得追一次真實案例的動作序列(誰、為什麼贏了argmax、後續有沒有真的完工)。
- **②棄置率**：`built=26 abandoned=24`(92.3%棄置率，比上輪89.3%還高)——這條字面PASS但方向沒改善，值得看幾筆真實棄置案例(是什麼原因棄的)。
- **③join reject暴增**：`accept=3 reject=8`(上輪reject=1)——**這是最需要故事驗證的一筆**。是host的食力/population飽和導致的genuine拒絕(如同上輪唯一那筆team3拒team11因feed_ok=0)，還是別的原因(例如`_absorber_accepts`的某個輸入本身算錯)？我沒有走過specimen逐tick，這是純聚合數字的猜測。

## 對照的verdict

`docs/process/verdicts/camp-access-world-layer.measure.json` @b3e54405(main) 2026-08-21

## repro(若需重跑核對)

```
$env:GODOT_TIMEOUT='900'; $env:LW_CONFIG='peaceful_economy'; $env:ADHOC_DAYS='90'; $env:PERF_SEED='1337'; $env:SPECIMEN_SAMPLE_N='10'; $env:SPECIMEN_OUT='<path>.specimen.jsonl'; .\tools\godot.ps1 --headless --path A:\GDS\demo\.worktrees\camp-access --script scripts/debug/camp_access_diag_bed.gd
```
