#!/bin/bash

# ============================================================
#  adportv2 - Advanced Port Forwarding Tool
#  Author: admi
#  Version: 2.0.0
# ============================================================

VERSION="2.0.0"
CONFIG_DIR="$HOME/.adportv2"
PORTS_FILE="$CONFIG_DIR/ports.json"
AUTH_FILE="$CONFIG_DIR/auth.json"
PID_FILE="$CONFIG_DIR/pids"
LOG_FILE="$CONFIG_DIR/adportv2.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Init config dir ──────────────────────────────────────────
init() {
  mkdir -p "$CONFIG_DIR" "$PID_FILE"
  [ ! -f "$PORTS_FILE" ] && echo "[]" > "$PORTS_FILE"
  [ ! -f "$AUTH_FILE"  ] && echo "{}" > "$AUTH_FILE"
}

# ── Banner ───────────────────────────────────────────────────
banner() {
  echo -e "${CYAN}${BOLD}"
  echo "  ██████╗ ██████╗  ██████╗ ██████╗ ████████╗██╗   ██╗██████╗ "
  echo "  ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██║   ██║╚════██╗"
  echo "  ██████╔╝██████╔╝██║   ██║██████╔╝   ██║   ██║   ██║ █████╔╝"
  echo "  ██╔══██╗██╔═══╝ ██║   ██║██╔══██╗   ██║   ╚██╗ ██╔╝██╔═══╝ "
  echo "  ██║  ██║██║     ╚██████╔╝██║  ██║   ██║    ╚████╔╝ ███████╗"
  echo "  ╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝     ╚═══╝  ╚══════╝"
  echo -e "${NC}${DIM}  Advanced Port Forwarding Manager v${VERSION} by admi${NC}"
  echo ""
}

# ── Help ─────────────────────────────────────────────────────
cmd_help() {
  banner
  echo -e "${BOLD}${YELLOW}USAGE:${NC}"
  echo -e "  ${CYAN}adportv2${NC} <command> [arguments]"
  echo ""
  echo -e "${BOLD}${YELLOW}COMMANDS:${NC}"
  echo -e "  ${GREEN}help${NC}                            Show this help message"
  echo -e "  ${GREEN}version${NC}                         Show version info"
  echo -e "  ${GREEN}ping${NC}                            Ping all method servers"
  echo -e "  ${GREEN}list${NC}                            List all open/active ports"
  echo -e "  ${GREEN}method${NC}                          Show all available methods"
  echo -e "  ${GREEN}install${NC}                         Install all method dependencies"
  echo -e "  ${GREEN}login <method>${NC}                  Login/authenticate a method"
  echo -e "  ${GREEN}forward <name> <port> <proto> <method>${NC}"
  echo -e "                                  Start port forwarding"
  echo -e "  ${GREEN}stop [name|all]${NC}                 Stop port(s) — temp ones removed from list"
  echo -e "  ${GREEN}credit${NC}                          Show credits"
  echo ""
  echo -e "${BOLD}${YELLOW}EXAMPLES:${NC}"
  echo -e "  ${DIM}adportv2 forward myserver 25565 tcp serveo${NC}"
  echo -e "  ${DIM}adportv2 forward mc2 25545 both bore${NC}"
  echo -e "  ${DIM}adportv2 stop myserver${NC}"
  echo -e "  ${DIM}adportv2 stop all${NC}"
  echo ""
  echo -e "${BOLD}${YELLOW}PROTOCOLS:${NC}  tcp | udp | both"
  echo ""
}

# ── Version ──────────────────────────────────────────────────
cmd_version() {
  banner
  echo -e "  ${BOLD}Version   :${NC} ${GREEN}${VERSION}${NC}"
  echo -e "  ${BOLD}Author    :${NC} admi"
  echo -e "  ${BOLD}OS        :${NC} $(uname -s) $(uname -r)"
  echo -e "  ${BOLD}Shell     :${NC} $SHELL"
  echo -e "  ${BOLD}Config    :${NC} $CONFIG_DIR"
  echo ""
}

# ── Credit ───────────────────────────────────────────────────
cmd_credit() {
  banner
  echo -e "  ${BOLD}${MAGENTA}Created by:${NC}  ${BOLD}admi${NC}"
  echo -e "  ${DIM}adportv2 — free & open port forwarding manager${NC}"
  echo -e "  ${DIM}Supports 15 methods, zero cost, works on Ubuntu 22.04${NC}"
  echo ""
}

# ── Methods table ────────────────────────────────────────────
declare -A METHOD_DESC METHOD_PERM METHOD_ACCOUNT METHOD_REGIONS

METHOD_DESC=(
  [serveo]="SSH-based tunnel, no install needed"
  [bore]="Rust-based, gives bore.pub/xxxx links"
  [localtonet]="Has Middle East & India servers"
  [localhost_run]="SSH tunnel, no install needed"
  [pinggy]="SSH-based, free tier, fast"
  [ngrok]="Popular tunnel, needs account"
  [cloudflared]="Cloudflare global network"
  [frp]="Self-hosted, needs your own VPS"
  [rathole]="Rust reverse proxy, self-hosted"
  [chisel]="TCP/UDP tunnel over HTTP"
  [telebit]="Free relay, JS-based"
  [inlets]="OSS tunnel, free OSS version"
  [zrok]="OpenZiti based, account needed"
  [loophole]="Dev tunnel, free tier"
  [tmate]="SSH sharing tunnel"
)

METHOD_PERM=(
  [serveo]="no"
  [bore]="no"
  [localtonet]="yes"
  [localhost_run]="no"
  [pinggy]="no"
  [ngrok]="no"
  [cloudflared]="yes"
  [frp]="yes"
  [rathole]="yes"
  [chisel]="yes"
  [telebit]="no"
  [inlets]="yes"
  [zrok]="yes"
  [loophole]="no"
  [tmate]="no"
)

METHOD_ACCOUNT=(
  [serveo]="no"
  [bore]="no"
  [localtonet]="yes"
  [localhost_run]="no"
  [pinggy]="no"
  [ngrok]="yes"
  [cloudflared]="yes"
  [frp]="no"
  [rathole]="no"
  [chisel]="no"
  [telebit]="yes"
  [inlets]="no"
  [zrok]="yes"
  [loophole]="yes"
  [tmate]="no"
)

METHOD_REGIONS=(
  [serveo]="Global"
  [bore]="Global"
  [localtonet]="India, ME, EU, US"
  [localhost_run]="Global"
  [pinggy]="Global"
  [ngrok]="Global"
  [cloudflared]="Global (CF network)"
  [frp]="Your VPS location"
  [rathole]="Your VPS location"
  [chisel]="Your VPS location"
  [telebit]="US"
  [inlets]="Your VPS location"
  [zrok]="US, EU"
  [loophole]="EU, US"
  [tmate]="Global"
)

METHODS=(serveo bore localtonet localhost_run pinggy ngrok cloudflared frp rathole chisel telebit inlets zrok loophole tmate)

# ── Method list ───────────────────────────────────────────────
cmd_method() {
  echo ""
  echo -e "${BOLD}${CYAN}  ╔══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}${CYAN}  ║              adportv2 — Available Methods (15)                      ║${NC}"
  echo -e "${BOLD}${CYAN}  ╚══════════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  printf "  ${BOLD}%-16s %-7s %-9s %-20s %s${NC}\n" "METHOD" "PERM" "ACCOUNT" "REGIONS" "DESCRIPTION"
  echo -e "  ${DIM}────────────────────────────────────────────────────────────────────────${NC}"
  for m in "${METHODS[@]}"; do
    perm="${METHOD_PERM[$m]}"
    acct="${METHOD_ACCOUNT[$m]}"
    reg="${METHOD_REGIONS[$m]}"
    desc="${METHOD_DESC[$m]}"
    perm_col="${RED}no${NC}"
    acct_col="${GREEN}no${NC}"
    [ "$perm" = "yes" ] && perm_col="${GREEN}yes${NC}"
    [ "$acct" = "yes" ] && acct_col="${YELLOW}yes${NC}"
    printf "  ${GREEN}%-16s${NC} " "$m"
    echo -ne "${perm_col}    "
    printf "%-9s" ""
    echo -ne "${acct_col}  "
    printf "%-20s %s\n" "$reg" "$desc"
  done
  echo ""
  echo -e "  ${DIM}PERM = permanent IP/link | ACCOUNT = needs signup${NC}"
  echo -e "  ${DIM}Use: ${CYAN}adportv2 login <method>${DIM} to authenticate methods that need accounts${NC}"
  echo ""
}

# ── Ping all methods ──────────────────────────────────────────
cmd_ping() {
  echo ""
  echo -e "${BOLD}${CYAN}  Pinging method servers...${NC}"
  echo ""
  declare -A PING_HOSTS=(
    [serveo]="serveo.net"
    [bore]="bore.pub"
    [localtonet]="localtonet.com"
    [localhost_run]="localhost.run"
    [pinggy]="pinggy.io"
    [ngrok]="ngrok.com"
    [cloudflared]="cloudflare.com"
    [frp]="github.com"
    [rathole]="github.com"
    [chisel]="github.com"
    [telebit]="telebit.cloud"
    [inlets]="inlets.dev"
    [zrok]="zrok.io"
    [loophole]="loophole.cloud"
    [tmate]="tmate.io"
  )
  for m in "${METHODS[@]}"; do
    host="${PING_HOSTS[$m]}"
    result=$(ping -c 1 -W 2 "$host" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [ -n "$result" ]; then
      echo -e "  ${GREEN}✔${NC} ${BOLD}$m${NC} (${host}) — ${GREEN}${result} ms${NC}"
    else
      echo -e "  ${RED}✘${NC} ${BOLD}$m${NC} (${host}) — ${RED}unreachable${NC}"
    fi
  done
  echo ""
}

# ── Install all methods ───────────────────────────────────────
cmd_install() {
  echo ""
  echo -e "${BOLD}${CYAN}  Installing adportv2 method dependencies...${NC}"
  echo ""

  _ok()   { echo -e "  ${GREEN}✔ $1${NC}"; }
  _fail() { echo -e "  ${RED}✘ $1 — $2${NC}"; }
  _skip() { echo -e "  ${YELLOW}⊘ $1 — already installed${NC}"; }

  # bore
  if command -v bore &>/dev/null; then _skip "bore"
  else
    if command -v cargo &>/dev/null; then
      cargo install bore-cli &>/dev/null && _ok "bore" || _fail "bore" "cargo install failed"
    else
      _fail "bore" "cargo not found — install Rust first: https://rustup.rs"
    fi
  fi

  # chisel
  if command -v chisel &>/dev/null; then _skip "chisel"
  else
    curl -sSL https://i.jpillora.com/chisel! | bash &>/dev/null && _ok "chisel" || _fail "chisel" "install script failed"
  fi

  # ngrok
  if command -v ngrok &>/dev/null; then _skip "ngrok"
  else
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc &>/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list &>/dev/null
    sudo apt-get update -qq && sudo apt-get install -y -qq ngrok &>/dev/null && _ok "ngrok" || _fail "ngrok" "apt install failed"
  fi

  # cloudflared
  if command -v cloudflared &>/dev/null; then _skip "cloudflared"
  else
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -O /tmp/cloudflared.deb &>/dev/null
    sudo dpkg -i /tmp/cloudflared.deb &>/dev/null && _ok "cloudflared" || _fail "cloudflared" "dpkg install failed"
  fi

  # localtonet
  if command -v localtonet &>/dev/null; then _skip "localtonet"
  else
    wget -q "https://localtonet.com/download/localtonet-linux-x64.tar.gz" -O /tmp/localtonet.tar.gz &>/dev/null
    sudo tar -xzf /tmp/localtonet.tar.gz -C /usr/local/bin/ &>/dev/null && sudo chmod +x /usr/local/bin/localtonet &>/dev/null
    command -v localtonet &>/dev/null && _ok "localtonet" || _fail "localtonet" "extraction failed"
  fi

  # rathole
  if command -v rathole &>/dev/null; then _skip "rathole"
  else
    RATHOLE_URL=$(curl -s https://api.github.com/repos/rapiz1/rathole/releases/latest | grep browser_download_url | grep x86_64-unknown-linux-gnu | head -1 | cut -d'"' -f4)
    if [ -n "$RATHOLE_URL" ]; then
      wget -q "$RATHOLE_URL" -O /tmp/rathole.zip &>/dev/null
      unzip -q /tmp/rathole.zip -d /tmp/rathole_bin &>/dev/null
      sudo cp /tmp/rathole_bin/rathole /usr/local/bin/ &>/dev/null && _ok "rathole" || _fail "rathole" "copy failed"
    else
      _fail "rathole" "could not fetch release URL"
    fi
  fi

  # frp
  if command -v frpc &>/dev/null; then _skip "frp"
  else
    FRP_VER=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep tag_name | cut -d'"' -f4 | sed 's/v//')
    FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_amd64.tar.gz"
    wget -q "$FRP_URL" -O /tmp/frp.tar.gz &>/dev/null
    tar -xzf /tmp/frp.tar.gz -C /tmp/ &>/dev/null
    sudo cp /tmp/frp_${FRP_VER}_linux_amd64/frpc /usr/local/bin/ &>/dev/null && _ok "frp (frpc)" || _fail "frp" "install failed"
  fi

  # inlets
  if command -v inlets &>/dev/null; then _skip "inlets"
  else
    curl -sSL https://get.inlets.dev | sudo bash &>/dev/null && _ok "inlets" || _fail "inlets" "install script failed"
  fi

  # zrok
  if command -v zrok &>/dev/null; then _skip "zrok"
  else
    wget -q $(curl -s https://api.github.com/repos/openziti/zrok/releases/latest | grep browser_download_url | grep linux_amd64.tar.gz | head -1 | cut -d'"' -f4) -O /tmp/zrok.tar.gz &>/dev/null
    sudo tar -xzf /tmp/zrok.tar.gz -C /usr/local/bin/ zrok &>/dev/null && _ok "zrok" || _fail "zrok" "extraction failed"
  fi

  # tmate
  if command -v tmate &>/dev/null; then _skip "tmate"
  else
    sudo apt-get install -y -qq tmate &>/dev/null && _ok "tmate" || _fail "tmate" "apt install failed"
  fi

  # SSH-based (no install needed)
  _ok "serveo       (no install needed — uses SSH)"
  _ok "localhost.run (no install needed — uses SSH)"
  _ok "pinggy       (no install needed — uses SSH)"
  _ok "telebit      (no install needed — uses SSH/web)"
  _ok "loophole     (no install needed — uses SSH)"

  echo ""
  echo -e "  ${BOLD}${GREEN}Done!${NC} Run ${CYAN}adportv2 method${NC} to see all methods."
  echo ""
}

# ── Login ─────────────────────────────────────────────────────
cmd_login() {
  local method="$1"
  if [ -z "$method" ]; then
    echo -e "${RED}Error:${NC} specify a method. Usage: adportv2 login <method>"
    echo -e "Methods needing login: ${YELLOW}ngrok, cloudflared, localtonet, zrok, telebit, loophole${NC}"
    return 1
  fi
  case "$method" in
    ngrok)
      echo -e "${CYAN}ngrok login:${NC} Get your token at https://dashboard.ngrok.com/get-started/your-authtoken"
      read -rp "  Paste your ngrok authtoken: " token
      ngrok config add-authtoken "$token" && echo -e "${GREEN}✔ ngrok authenticated!${NC}" || echo -e "${RED}✘ Failed${NC}"
      ;;
    cloudflared)
      echo -e "${CYAN}cloudflared login:${NC} A browser will open to authenticate with Cloudflare."
      cloudflared tunnel login
      ;;
    localtonet)
      echo -e "${CYAN}localtonet login:${NC} Get your token at https://localtonet.com/UserApiToken"
      read -rp "  Paste your localtonet authtoken: " token
      localtonet authtoken "$token" && echo -e "${GREEN}✔ localtonet authenticated!${NC}" || echo -e "${RED}✘ Failed${NC}"
      ;;
    zrok)
      echo -e "${CYAN}zrok login:${NC} Register at https://zrok.io then get your token."
      read -rp "  Paste your zrok token: " token
      zrok enable "$token" && echo -e "${GREEN}✔ zrok enabled!${NC}" || echo -e "${RED}✘ Failed${NC}"
      ;;
    telebit)
      echo -e "${CYAN}telebit login:${NC} Register at https://telebit.cloud"
      read -rp "  Your telebit email: " email
      ssh "$email"@telebit.cloud
      ;;
    loophole)
      echo -e "${CYAN}loophole login:${NC} Register at https://loophole.cloud"
      read -rp "  Paste your loophole token: " token
      loophole account login --authtoken "$token" && echo -e "${GREEN}✔ loophole authenticated!${NC}" || echo -e "${RED}✘ Failed${NC}"
      ;;
    *)
      echo -e "${YELLOW}⊘ '$method' doesn't need login — it's free & anonymous!${NC}"
      ;;
  esac
}

# ── Add port to list ──────────────────────────────────────────
_add_port() {
  local name="$1" port="$2" proto="$3" method="$4" ip="$5" link="$6" perm="$7" pid="$8"
  local entry="{\"name\":\"$name\",\"port\":$port,\"proto\":\"$proto\",\"method\":\"$method\",\"ip\":\"$ip\",\"link\":\"$link\",\"perm\":$perm,\"pid\":$pid,\"started\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
  local current
  current=$(cat "$PORTS_FILE")
  # Remove existing entry with same name
  current=$(echo "$current" | python3 -c "import sys,json; d=json.load(sys.stdin); d=[x for x in d if x.get('name')!='$name']; print(json.dumps(d))" 2>/dev/null || echo "[]")
  echo "$current" | python3 -c "import sys,json; d=json.load(sys.stdin); d.append($entry); print(json.dumps(d,indent=2))" > "$PORTS_FILE" 2>/dev/null
}

# ── Remove port from list ─────────────────────────────────────
_remove_port() {
  local name="$1"
  local current
  current=$(cat "$PORTS_FILE")
  echo "$current" | python3 -c "import sys,json; d=json.load(sys.stdin); d=[x for x in d if x.get('name')!='$name']; print(json.dumps(d,indent=2))" > "$PORTS_FILE" 2>/dev/null
}

# ── Forward ───────────────────────────────────────────────────
cmd_forward() {
  local name="$1" port="$2" proto="$3" method="$4"
  if [ -z "$name" ] || [ -z "$port" ] || [ -z "$proto" ] || [ -z "$method" ]; then
    echo -e "${RED}Error:${NC} Usage: adportv2 forward <name> <port> <tcp|udp|both> <method>"
    return 1
  fi

  local perm="${METHOD_PERM[$method]}"
  local perm_val="false"
  [ "$perm" = "yes" ] && perm_val="true"

  echo ""
  echo -e "${CYAN}${BOLD}  Starting forward:${NC} ${BOLD}$name${NC} | port ${YELLOW}$port${NC} | proto ${YELLOW}$proto${NC} | method ${GREEN}$method${NC}"
  echo -e "  ${DIM}Waiting for tunnel to come up...${NC}"
  echo ""

  local ip="" link="" pid=""

  case "$method" in

    serveo)
      ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 \
        -R "$port":localhost:"$port" serveo.net > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      link="serveo.net:$port"
      ip=$(dig +short serveo.net | head -1)
      ;;

    bore)
      bore local "$port" --to bore.pub > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      local bore_port
      bore_port=$(grep -oP 'listening on bore\.pub:\K[0-9]+' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      link="bore.pub:${bore_port:-?}"
      ip=$(dig +short bore.pub | head -1)
      ;;

    localhost_run)
      ssh -o StrictHostKeyChecking=no -R "$port":localhost:"$port" \
        nokey@localhost.run > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 4
      link=$(grep -oP 'https://[^\s]+' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      [ -z "$link" ] && link="localhost.run (check log)"
      ip=$(dig +short localhost.run | head -1)
      ;;

    pinggy)
      ssh -o StrictHostKeyChecking=no -p 443 \
        -R0:localhost:"$port" a.pinggy.io > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 4
      link=$(grep -oP 'https?://[^\s]+' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      [ -z "$link" ] && link="pinggy.io (check log)"
      ip=$(dig +short a.pinggy.io | head -1)
      ;;

    ngrok)
      ngrok tcp "$port" --log=stdout > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 4
      link=$(grep -oP 'tcp://[^\s]+' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      [ -z "$link" ] && link=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['tunnels'][0]['public_url'])" 2>/dev/null)
      [ -z "$link" ] && link="ngrok.io (check log)"
      ip=$(echo "$link" | grep -oP '\d+\.tcp\.[^:]+' | head -1)
      ;;

    cloudflared)
      cloudflared tunnel --url tcp://localhost:"$port" > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 5
      link=$(grep -oP 'https://[^\s]+trycloudflare\.com[^\s]*' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      [ -z "$link" ] && link="trycloudflare.com (check log)"
      ip="Cloudflare CDN"
      ;;

    localtonet)
      localtonet tcp --portnumber "$port" > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 5
      link=$(grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      [ -z "$link" ] && link="localtonet.com (check log)"
      ip=$(echo "$link" | cut -d: -f1)
      ;;

    chisel)
      echo -e "  ${YELLOW}⚠ chisel needs a chisel server.${NC} Run server: ${DIM}chisel server --port 9090 --reverse${NC}"
      read -rp "  Enter your chisel server address (host:port): " server
      chisel client "$server" "R:$port:localhost:$port" > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      ip=$(echo "$server" | cut -d: -f1)
      link="$ip:$port"
      ;;

    frp)
      echo -e "  ${YELLOW}⚠ frp needs a frps server.${NC}"
      read -rp "  Enter your frps server IP: " frp_ip
      read -rp "  Enter frps bind port (default 7000): " frp_port
      frp_port="${frp_port:-7000}"
      cat > "$CONFIG_DIR/${name}_frpc.toml" <<EOF
serverAddr = "$frp_ip"
serverPort = $frp_port

[[proxies]]
name = "$name"
type = "tcp"
localIP = "127.0.0.1"
localPort = $port
remotePort = $port
EOF
      frpc -c "$CONFIG_DIR/${name}_frpc.toml" > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      ip="$frp_ip"
      link="$frp_ip:$port"
      ;;

    rathole)
      echo -e "  ${YELLOW}⚠ rathole needs a rathole server.${NC}"
      read -rp "  Enter your rathole server IP: " rh_ip
      read -rp "  Enter rathole server port (default 2333): " rh_port
      rh_port="${rh_port:-2333}"
      cat > "$CONFIG_DIR/${name}_rathole.toml" <<EOF
[client]
remote_addr = "$rh_ip:$rh_port"

[client.services.$name]
local_addr = "127.0.0.1:$port"
EOF
      rathole "$CONFIG_DIR/${name}_rathole.toml" > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      ip="$