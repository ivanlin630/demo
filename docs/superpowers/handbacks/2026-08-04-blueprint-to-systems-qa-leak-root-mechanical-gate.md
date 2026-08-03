---
from: blueprint
to: systems
status: open
topic: "[用戶問QA-hook為何寫死還連漏·root=結構非個站失職:①提醒打在跑床站(量測)但因果結論在下游鎖(你verdict→我鎖spec)=提醒與執行點錯位,鎖點零gate②提醒非硬擋+隔時/compact洗context=最終還是靠記憶(7/22綁hook就為避記憶,但hook仍靠被提醒者記得)③無機械路由(說送QA但不自動生to:qa信)·三站都漏(量測沒附specimen送QA/你verdict沒過QA=主漏點鏈樞紐/我鎖spec沒問QA)·治本=gate裝到鎖的位置不靠記憶:①我站立即生效=spec鎖在長跑因果上→handback無QA verdict ref我拒鎖②你verdict模板加欄:含因果結論的信必帶『QA:<ref或PENDING>』,PENDING不得拿來鎖spec③寫進process docs(你owner:01_architect verdict流程+03b量測findings必附specimen→QA+00_roles鏈序:長跑→量測→QA故事稽核→你verdict→我)·請你落②③+記memory(hook提醒≠gate,gate要裝在執行點=鎖/merge,advisory在上游必漏)·不影響現infonet build/QA回溯(照跑)"
---

# QA-hook 連漏 root = 結構(提醒與執行點錯位)→ 機械 gate 裝到鎖點

用戶問:寫死 hook 為何還連漏?是量測站還是 01 問題?

## root(結構、非個站失職)
1. **提醒打在跑床站(量測),因果結論在下游鎖**(你 verdict → 我鎖 spec)——**鎖點零 gate**、錯位。
2. **提醒非硬擋** + 隔時/compact 洗 context = 最終還是靠記憶(7/22 綁 hook 就為避記憶,但 hook 仍靠被提醒者記得)。
3. **無機械路由**(說「送 QA」但不自動生 to:qa 信)。
- 三站都漏:量測沒附 specimen 送 QA / **你 verdict 沒過 QA = 主漏點(鏈樞紐)** / 我鎖 spec 沒問 QA。

## 治本 = gate 裝到「鎖」的位置(不靠記憶)
1. **我站(立即生效)**:spec 要鎖在長跑因果結論上 → handback **無 QA verdict ref = 我拒鎖**。
2. **你 verdict 模板加欄**:含因果結論的信必帶 `QA: <ref 或 PENDING>`;**PENDING 不得拿來鎖 spec**。
3. **寫進 process docs**(你 owner):`01_architect`(verdict 流程)+ `03b_measurer`(findings 必附 specimen → QA)+ `00_roles`(鏈序:長跑→量測→**QA 故事稽核**→你 verdict→我)。

## 記 memory(你單寫者)
**hook 提醒 ≠ gate;gate 要裝在執行點(鎖/merge),advisory 在上游必漏。** 同 [[feedback_self_approve_gate]] 家族(靠自覺的閘必失效)。

不影響現 infonet build / QA 回溯(照跑)。
