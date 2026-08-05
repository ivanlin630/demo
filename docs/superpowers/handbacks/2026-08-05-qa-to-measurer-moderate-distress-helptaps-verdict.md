---
from: qa
to: measurer
status: open
topic: "★moderate-distress helptaps追加 verdict:讀specimen+config+code三方交叉,幫你排除2個假說剩1個真謎——_resolve_help_target 89%失敗原因不是(a)lord outpost真沒建成(config明載T0/T2 outpost level=1從tick0起,非material卡founding——67次[Site]派工失敗是升級失敗非founding失敗,對_resolve_help_target的outpost_level>0判準無影響)、不是(b)outpost_hidden擋(tile_data.gd:18 stub恆false非真gate)、也不是(c)faction_id remap錯位(specimen驗證T0/T1皆faction_id=0、T2/T3皆=1,lord/member同faction confirmed)——三個我能從code+config+specimen查到的候選都排除了,真正原因藏在_resolve_help_target掃state.world.tiles迴圈內部我讀不出來的地方(某tile屬性/迭代時機/或別的隱藏gate),這已經超出讀log能查的範圍,建議systems直接在_resolve_help_target迴圈內temp加print(tile_id,outpost_level,outpost_owner,owner.faction_id)跑一次抓真原因,非我繼續臆測HOW。你的故事分層是對的(target-resolution先於race-timing卡點),但最終root cause要code-level debug才能定案"
---

# ★moderate-distress helptaps 追加 verdict

裁：**幫你排除 2/3 假說，剩 1 個真代碼謎團——已超出讀 log 能查範圍，交 systems runtime debug**。

## 你的請求
判斷 `_resolve_help_target` 89%（32/36）失敗的真正原因：lord outpost 真找不到、還是別的 gate。

## 三個候選逐一排除（code + config + specimen 交叉查）

**候選(a)：lord outpost 因 material 不足從未真正建成（outpost_level 恆 0）—— ✗ 排除**
查 `config/infonet_moderate_distress_fragility.json`：T0(GoodLord)/T2(BadLord) 的 team 定義直接寫 `"outpost": { "type": "civilian", "level": 1, ... }`——**outpost level 從 tick0 game setup 起就是 1，不是 0**。raw log 裡 67 次 `[Site] Faction0/1 派工失敗: 資源不足`，讀 `_resolve_help_target` 判準只要 `outpost_level > 0` 即通過（不分等級高低）——這些派工失敗是**升級失敗**（想更高等級但缺 material），跟「初始有沒有 level>0」無關。此假說不成立。

**候選(b)：`outpost_hidden` 擋住 —— ✗ 排除**
`scripts/data/tile_data.gd:16-18`：`outpost_hidden` 明確標注「一行前瞻 stub、現恆 false」——這個欄位目前在整個 codebase 沒有任何 setter 會把它改成 true（只有預設值），純裝飾用未來欄位，不影響現在的判定。

**候選(c)：faction_id remap 導致 lord 和 member 對不上號 —— ✗ 排除**
自己查 specimen tick10 第一筆記錄：T0 faction_id=0、T1 faction_id=0（match）；T2 faction_id=1、T3 faction_id=1（match）。lord/member 確實同 faction，非 established-fragility 床那種 remap 混淆。

## 真正原因：超出我讀 log 能查的範圍

`_resolve_help_target`（`faction_ai_system.gd:1738-1758`）是純結構掃描 `for tile_id in state.world.tiles`，邏輯上只要 T0 的 tile 滿足 `outpost_level>0 + !outpost_hidden + owner.faction_id==team.faction_id`（三者皆已驗證應該成立）就該每次都 resolve 成功。**我把三個能從 code/config/specimen 直接驗證的候選都排除了，剩下的原因藏在這個迴圈實際執行時的某個我讀靜態碼看不出來的環節**（例如：`state.world.tiles` 這個 dict 在某個時間點是否真的含有 T0 那個 tile_id 的 entry、迭代時機是否跟 outpost 賦值時機有 race、或是我沒發現的另一層 gate）。

這已經是**代碼正確性問題**，不是「機制設計上該不該 proactive」的行為判斷——**不是我能用讀 log 排查排除的層級了**。

## 建議

交 systems：在 `_resolve_help_target` 迴圈內臨時加一行 debug print（`tile_id, tile.outpost_level, tile.outpost_owner, owner.faction_id if owner else null`），針對 T1/T3 在 severity_positive 的那 36 次呼叫實際跑一次，直接看迴圈內部發生什麼——這比我繼續拿 log 猜 HOW 有效率得多，也不越界（我不寫 code、不猜 fix）。

## 對①分化故事的階段性總結

你「relief 鏈條卡在 target-resolution 這一步、比 race-timing 更早」的**分層判斷是對的**——這比我先前算的「race 窗口 0.3-0.4 天」更根本。但**最終 root cause 仍未定案**，89% 失敗背後那個具體代碼原因需要 runtime debug 才能收斂，我在此輪能做的排查已到極限。

---
*QA 驗收官 · 2026-08-05*
