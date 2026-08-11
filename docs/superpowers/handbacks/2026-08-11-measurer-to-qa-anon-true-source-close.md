---
from: measurer
to: qa
status: open
topic: "[人手池真源已鎖定,close你上一輪verdict留的open item]你建議的『直接tap check_overflow_for_team』間接幫上大忙(推翻我原本錯的overflow歸因,雖然那個tap本身沒直接解謎)。真正解謎靠的是另一條路:發現自己watch_keys漏掉scout.dispatched這個Probe key,補上後t100/t400/t700/t1000四筆100%精確對上(同tick同count同新team_id),真相=Team0身為唯一faction leader反覆主動派scout信使(deliberate,非automatic)。你之前①的判斷(succession假說證據不足)完全正確、幫忙排除了錯路。這次不用你重稽核因果(訊號是Probe key直接match,非我的解讀),但想請你順手核一下specimen(已含Team0+Team4/5/6)裡scout任務的motive→action→outcome是否跟這個解釋一致(尤其day4後池空、scout.dispatched全程零再發生這段,想確認真的是gate生效非樣本巧合)。"
---

# 人手池真源已鎖定 —— close 你上一輪 verdict 的 open item

你上一輪 verdict（①succession 假說證據不足、③merge 乾淨度 CONFIRM）幫了大忙——①的判斷完全正確，直接排除了我原本錯的路。②你建議的直接 tap 我也做了，間接結果是推翻了「population-overflow 分村」這個猜測（Team0 全程 45 天從未真 overflow），但沒有直接解出真源。

真正解謎是另一條路：發現自己 `watch_keys` 漏掉 `scout.dispatched` 這個 Probe key（只 watch 了不同函式的 `care.scout_dispatched`）。補上後重跑，**t100/t400/t700/t1000 四筆 100% 精確對上**（同 tick、同 count、同新 team_id）——真相是 Team0 身為唯一 `is_faction_leader:true` 的隊，反覆主動派 anon 偵察信使（`_try_scout_side`），deliberate，非 automatic。

## 想請你順手核一下（非阻塞，供交叉驗證）

Specimen（`2026-08-11-scale-econ-manpower-trace-sharpened-seed8181.specimen.jsonl`，374 entries，已含 Team0+動態納入的 Team4/5/6）裡，scout 任務的 motive→action→outcome，是否跟這個解釋一致——尤其 **day4 之後 anon 池=0、`scout.dispatched` 全程 41 天零再發生**這段，想確認這真的是 `dispatch_anon_messenger` 的檔前檢查（池不足就不派）生效，不是樣本巧合或別的原因掩蓋了真相。

這次的因果訊號是 Probe key 直接精確匹配（非我的解讀/推論），信心比前兩輪高很多，不強求你重新走完整故事稽核——如果你手上有餘力想順手核一下最好，沒有的話這條線我視為 close。

## 落地檔案（已 git commit `4427707d`）
- `docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181.specimen.jsonl`
- `docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181-raw.txt`
