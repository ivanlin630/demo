#!/usr/bin/env bash
# lib-role-key.sh —— 信箱／通訊錄用的「角色鍵」唯一產生者（systems 立 2026-10-18，第二條實作線）。
#
# ★為什麼：用戶裁 2026-10-18 開第二個實作端終端。兩個終端的 SESSION_ROLE 都是 implementer
#   （所有以角色判行為的 hook ——role-commit-scope／bash-guard／bed-kind-gate…—— 對兩條線要一樣），
#   ★★但【信箱與通訊錄】要分得開：否則 whoami 互蓋 .peer-addr.implementer、兩線收到同一封派件信。
#   ⇒ 第二線多帶 SESSION_LANE=2；角色鍵 ＝ implementer-2。第一線不帶（或帶 1）＝ implementer（舊信全照舊）。
# ★讀者：session-role.sh（開場未讀）、handback-inbox.sh（每 turn 📬）、whoami.sh（通訊錄）。
#   peers.sh 的 ROLES 表另列 implementer-2（它不讀 env，是列全部）。
# ★壞掉長什麼樣：第二線開場看到的未讀是 to: implementer 的信（＝第一線的派件）⇒ 兩線做同一張票。
role_key() {
  local r="${1:-}" lane="${SESSION_LANE:-1}"
  if [ "$r" = "implementer" ] && [ "$lane" != "1" ]; then
    printf 'implementer-%s' "$lane"
  else
    printf '%s' "$r"
  fi
}
