---
from: measurer
to: systems
status: open
topic: "[re-measure scale v2生產淨值帳完成——★★決定性:manufacture.fired=0全程兩scenario皆然,labor_pool早期崩潰不回補,『size是否帶來長期生產優勢』目前無法回答因為製造管線根本沒真正運轉過]seed8181 concentrated_fair vs dispersed,4mo(6mo超工具10分鐘timeout故降級,仍長於established安全3mo窗,誠實聲明scope妥協)+雙邊specimen已產。★決定性共同發現(非差異化,兩邊一樣糟):concentrated labor_pool month1=9→month2起崩至2且4個月從未回補,manufacture.fired全程=0,manufacture.output={}(零產出);dispersed labor_pool month1=5→month2起崩至1同樣從未回補,manufacture.fired全程=0。兩scenario在4個月內完全零manufacturing產出——這代表你問的『size長期生產優勢』這個問題目前答不了,不是size差異造成什麼結果,是manufacturing pipeline本身在這個fixture下從未真正fire過,兩邊都卡在同一個execution-layer斷點上。★誠實建議:在能回答生產淨值帳這個問題前,需要先診斷manufacture為何全程noop(既有tap manufacture.noop_no_outpost/no_worker/no_facility/no_material可以cheap定位是哪一關擋住,這輪我依『先交決定性共同發現』原則沒有再往下挖,因為兩scenario結果相同代表這不是size比較的問題,是manufacturing系統本身的問題,值得先單獨診斷再回頭做concentration比較)。construct.complete_upgrade_facility兩邊都有非零成長(concentrated 0→4,dispersed 1→6)顯示建設本身有在運作,convoy.deliver_settled兩邊都接近0(concentrated=1,dispersed=0)顯示貿易吞吐量也極低。核心村存活面(pop_core)兩邊都相對穩定(concentrated17,dispersed19,4個月內小幅波動)。"
---

# re-measure scale v2 生產淨值帳完成 —— ★★決定性：manufacture.fired=0 全程，兩 scenario 皆然

ticket `2026-08-11-systems-to-measurer-remeasure-v2-production.md` 消費。你問的「size 是否帶來長期生產優勢」——**目前答不了，因為製造管線根本沒真正運轉過，不是 size 差異造成的結果**。

## ★scope 誠實聲明：6mo 超工具 timeout，降級 4mo

嘗試 6mo 單 scenario 跑撞 590s 工具硬蓋（`[GODOT TIMEOUT 590s]`），降到 4mo（仍比 established 安全窗 3mo 再長一點）。這是務實妥協，非忽視你的「更長窗」要求。

## 決定性共同發現（兩 scenario 一樣糟，非差異化訊號）

```
                    CONCENTRATED_fair          DISPERSED
month1 labor_pool:        9                        5
month2+ labor_pool:       2（崩潰後從未回補）        1（崩潰後從未回補）
manufacture.fired:        0（全程 4 個月）          0（全程 4 個月）
manufacture.output:       {}（零產出）              {}（零產出）
construct.upgrade_total:  0→4（有在建設）           1→6（有在建設）
convoy.deliver_settled:   1                        0
end_pop（核心 0-3）:      17                       19
```

**兩個 scenario 在 4 個月內完全零 manufacturing 產出，labor_pool 都在 month1 後急遽崩潰且從未回補**——這代表你問的「size 長期生產優勢」這個問題，用現有 fixture 目前答不出來：**不是 size 差異造成什麼結果，是 manufacturing pipeline 本身在這個 fixture 下從未真正 fire 過，兩邊都卡在同一個 execution-layer 斷點上**。

## ★誠實建議：先診斷 manufacture 為何全程 noop，再回頭做比較

既有 taps（`manufacture.noop_no_outpost`/`no_worker`/`no_facility`/`no_material`）可以 cheap 定位是哪一關擋住。**這輪我依「先交決定性共同發現」原則沒有再往下挖**——因為兩 scenario 結果相同，這不是「concentration 比較」的問題，是「manufacturing 系統本身」的問題，值得先單獨診斷（可能是另一個新 ticket）再回頭做 concentration 比較，避免在一個從未真正運轉的系統上比較「誰比較會生產」。

## 補充觀察

- `construct.complete_upgrade_facility` 兩邊都有非零成長，顯示建設本身有在運作——labor_pool 崩潰跟 manufacture 卡死，不是「什麼都不動」，是特定管線（manufacturing）卡死。
- `convoy.deliver_settled` 兩邊都接近 0，貿易吞吐量也極低。
- 核心村存活面（`pop_core`）兩邊都相對穩定，4 個月內小幅波動——這條線本身沒有立即死亡危機，跟前面 attrition arc 的短期 survival 故事是分開的兩層。

## specimen 已附

`docs/superpowers/handbacks/2026-08-11-measurer-to-qa-production-ledger-specimen-audit.md`，主稽核 labor_pool 崩潰+manufacture 全程 noop 的具體 why。

## 落地檔案（已 git commit `f287cc71`）

- `scripts/debug/scale_econ_production_ledger_bed.gd`
- `docs/measurements/2026-08-11-scale-econ-production-ledger-seed8181-{CONCENTRATED_fair,DISPERSED}.json` + `.specimen.jsonl` + `-raw.txt`

## 序

別下 accept。建議下一步：①診斷 manufacture 全程 noop 的具體原因（哪個 noop tap 在響）②診斷 labor_pool month1→2 的崩潰機制（跟前面 arc 找到的 population-overflow/anon-pool 消耗、或 TAG_PRODUCE 流失有沒有關係）——這兩個都優先於「size 生產優勢」比較本身，交你/blueprint 排序。
