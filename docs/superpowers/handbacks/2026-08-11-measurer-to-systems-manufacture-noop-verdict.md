---
from: measurer
to: systems
status: consumed
topic: "[manufacture noop診斷完成——★★決定性:no_facility是主因兩scenario皆然,QA code-read假說用真tap數字確認,labor(no_worker)是次要因素]seed8181 concentrated vs dispersed(4mo)真實tap breakdown:concentrated{noop_no_outpost:575,noop_no_worker:126,noop_no_facility:1161★主因,noop_no_material:0};dispersed{noop_no_outpost:477,noop_no_worker:78,noop_no_facility:644★主因,noop_no_material:197}。no_facility在兩邊都是最大noop原因(concentrated超no_worker9倍,dispersed超no_worker8倍)——直接確認QA的code-read推論:4個月短窗內manufacturing專屬設施(區別於基礎outpost civilian site)從未真正蓋到level>0,連candidate的demand entry都沒生成過,這是precondition未滿足非labor不夠或優先序被威脅佔走。labor短缺(no_worker)確實存在但是次要因素,不是主要擋點——這代表你原本假說『labor_pool崩=擋manufacture=同擋care-loop relief那根』只對了一半:labor短缺有貢獻但不是主因,主因是manufacturing facility建設進度本身太慢(4個月連level1的專屬製造設施都還沒蓋出來,同期construct.complete_upgrade_facility雖有非零成長但那多半是基礎civilian outpost升級非manufacturing專屬設施)。material短缺在concentrated完全不缺(0)但dispersed偶爾短缺(197)——小村資源餘裕較薄的合理差異,非決定性但值得記錄。★裁bar建議:no_facility為主因≠anon-cohort/care-loop那個deferred根blocker,是一個不同的、獨立的『manufacturing facility建設速度太慢』問題——不建議跟anon-overflow那條線合併判定,是新的、獨立的斷點。"
---

# manufacture noop 診斷完成 —— ★★决定性：no_facility 是主因，兩 scenario 皆然

ticket `2026-08-11-systems-to-measurer-manufacture-noop-diagnose.md` 消費。已用真 tap 數字（既有 `manufacture.noop_<reason>`，非新 production 改動）取代 QA 的 code-read 推論。

## 真實 tap breakdown（seed8181，4mo）

```
                  no_outpost    no_worker    no_facility(★主因)    no_material
concentrated:        575           126            1161                  0
dispersed:            477            78             644                197
```

**`no_facility` 在兩邊都是最大 noop 原因**（concentrated 超過 no_worker 9 倍、dispersed 超過 8 倍）——**直接確認 QA 的 code-read 推論**：4 個月短窗內 manufacturing 專屬設施（區別於基礎 outpost civilian site）從未真正蓋到 level>0，連 candidate 的 demand entry 都沒生成過。這是 **precondition 未滿足**，不是 labor 不夠、也不是優先序被威脅佔走。

## ★回你原本的假說：只對了一半

你的假說「labor_pool 崩=擋 manufacture=同擋 care-loop relief 那根」——**labor 短缺（no_worker）確實存在但是次要因素**，不是主要擋點。主因是 **manufacturing facility 建設進度本身太慢**（4 個月連 level1 的專屬製造設施都還沒蓋出來；同期 `construct.complete_upgrade_facility` 雖有非零成長，那多半是基礎 civilian outpost 升級，不是 manufacturing 專屬設施）。

## 補充：material 短缺的邊際差異

concentrated 完全不缺料（0），dispersed 偶爾短缺（197）——小村資源餘裕較薄的合理差異，非決定性但值得記錄。

## ★裁 bar 建議（供你/blueprint 判斷，非我越界）

`no_facility` 為主因 **≠** anon-cohort/care-loop 那個 deferred 根 blocker——是一個不同、獨立的「manufacturing facility 建設速度太慢」問題。**不建議跟 anon-overflow 那條線合併判定**，是新的、獨立的斷點，值得單獨排優先序（可能是「manufacturing 專屬設施升級路徑優先序太低/門檻太高」這類 WHAT/HOW 問題，非我判斷範圍）。

## 落地檔案（已 git commit `ab3b9e25`）

- `docs/measurements/2026-08-11-scale-econ-manufacture-noop-seed8181-{concentrated,dispersed}-raw.txt`
- 更新版 `docs/measurements/2026-08-11-scale-econ-production-ledger-seed8181-{CONCENTRATED_fair,DISPERSED}.json`（含 `manufacture_noop` breakdown）

別下 accept，這是 cheap 診斷回報，`no_facility` 這個新斷點要不要接續深挖交你/blueprint 排序。
