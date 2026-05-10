#!/bin/bash
VERSION="2.0.0"
CONFIG_DIR="$HOME/.adportv2"
PORTS_FILE="$CONFIG_DIR/ports.json"
PID_FILE="$CONFIG_DIR/pids"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'
METHODS=(serveo bore localtonet localhost_run pinggy ngrok cloudflared frp rathole chisel telebit inlets zrok loophole tmate)

init() {
  mkdir -p "$CONFIG_DIR" "$PID_FILE"
  [ ! -f "$PORTS_FILE" ] && echo "[]" > "$PORTS_FILE"
}

banner() {
  echo -e "${CYAN}${BOLD}"
  echo "   ___  ___  ____  ___  ____  ____     ___  "
  echo "  / _ \/ _ \/ __ \/ _ \/_  / / __/  _/ / /  "
  echo " / ___/ // / /_/ / , _/ / /__\ \   / __/ _ \ "
  echo "/_/  /____/\____/_/|_| /___/___/  /_/ /_//_/ "
  echo -e "${NC}${DIM}  Advanced Port Forwarding Manager v${VERSION} by admi${NC}"
  echo ""
}

cmd_help() {
  banner
  echo -e "${BOLD}${YELLOW}USAGE:${NC}  adportv2 <command> [args]"
  echo ""
  echo -e "${BOLD}${YELLOW}COMMANDS:${NC}"
  echo -e "  ${GREEN}help${NC}                            Show this help"
  echo -e "  ${GREEN}version${NC}                         Show version"
  echo -e "  ${GREEN}ping${NC}                            Ping all method servers"
  echo -e "  ${GREEN}list${NC}                            List all open ports"
  echo -e "  ${GREEN}method${NC}                          Show all 15 methods"
  echo -e "  ${GREEN}install${NC}                         Install all dependencies"
  echo -e "  ${GREEN}login <method>${NC}                  Authenticate a method"
  echo -e "  ${GREEN}forward <name> <port> <proto> <method>${NC}  Start forwarding"
  echo -e "  ${GREEN}stop <name|all>${NC}                 Stop port(s)"
  echo -e "  ${GREEN}credit${NC}                          Show credits"
  echo ""
  echo -e "${BOLD}${YELLOW}EXAMPLES:${NC}"
  echo -e "  ${DIM}adportv2 forward mymc 25565 tcp serveo${NC}"
  echo -e "  ${DIM}adportv2 forward mc2 25545 both bore${NC}"
  echo -e "  ${DIM}adportv2 stop all${NC}"
  echo ""
}

cmd_version() {
  banner
  echo -e "  ${BOLD}Version :${NC} ${GREEN}${VERSION}${NC}"
  echo -e "  ${BOLD}Author  :${NC} admi"
  echo -e "  ${BOLD}OS      :${NC} $(uname -s) $(uname -r)"
  echo -e "  ${BOLD}Config  :${NC} $CONFIG_DIR"
  echo ""
}

cmd_credit() {
  banner
  echo -e "  ${BOLD}${MAGENTA}Created by:${NC} ${BOLD}admi${NC}"
  echo -e "  ${DIM}adportv2 - free port forwarding manager for Linux${NC}"
  echo -e "  ${DIM}15 methods, zero cost, Ubuntu 22.04${NC}"
  echo ""
}

cmd_method() {
  echo ""
  echo -e "${BOLD}${CYAN}  adportv2 - Available Methods (15)${NC}"
  echo -e "  ${DIM}──────────────────────────────────────────────────────────────${NC}"
  printf "  ${BOLD}%-16s %-5s %-8s %-18s %s${NC}\n" "METHOD" "PERM" "ACCOUNT" "REGIONS" "DESCRIPTION"
  echo -e "  ${DIM}──────────────────────────────────────────────────────────────${NC}"
  echo -e "  ${GREEN}serveo${NC}          no    no       Global             SSH tunnel, no install"
  echo -e "  ${GREEN}bore${NC}            no    no       Global             bore.pub/xxxx links"
  echo -e "  ${GREEN}localtonet${NC}      yes   yes      India,ME,EU,US     Best ping for Jordan!"
  echo -e "  ${GREEN}localhost_run${NC}   no    no       Global             SSH, no install"
  echo -e "  ${GREEN}pinggy${NC}          no    no       Global             SSH-based, fast"
  echo -e "  ${GREEN}ngrok${NC}           no    yes      Global             Popular tunnel"
  echo -e "  ${GREEN}cloudflared${NC}     yes   yes      Global CF          Cloudflare network"
  echo -e "  ${GREEN}frp${NC}             yes   no       Your VPS           Self-hosted"
  echo -e "  ${GREEN}rathole${NC}         yes   no       Your VPS           Rust reverse proxy"
  echo -e "  ${GREEN}chisel${NC}          yes   no       Your VPS           TCP/UDP over HTTP"
  echo -e "  ${GREEN}telebit${NC}         no    yes      US                 SSH relay"
  echo -e "  ${GREEN}inlets${NC}          yes   no       Your VPS           OSS tunnel"
  echo -e "  ${GREEN}zrok${NC}            yes   yes      US,EU              OpenZiti based"
  echo -e "  ${GREEN}loophole${NC}        no    yes      EU,US              Dev tunnel"
  echo -e "  ${GREEN}tmate${NC}           no    no       Global             SSH sharing"
  echo ""
  echo -e "  ${DIM}PERM=permanent link | Use: adportv2 login <method> for account methods${NC}"
  echo ""
}

cmd_ping() {
  echo ""
  echo -e "${BOLD}${CYAN}  Pinging method servers...${NC}"
  echo ""
  declare -A HOSTS
  HOSTS[serveo]="serveo.net"
  HOSTS[bore]="bore.pub"
  HOSTS[localtonet]="localtonet.com"
  HOSTS[localhost_run]="localhost.run"
  HOSTS[pinggy]="pinggy.io"
  HOSTS[ngrok]="ngrok.com"
  HOSTS[cloudflared]="cloudflare.com"
  HOSTS[frp]="github.com"
  HOSTS[rathole]="github.com"
  HOSTS[chisel]="github.com"
  HOSTS[telebit]="telebit.cloud"
  HOSTS[inlets]="inlets.dev"
  HOSTS[zrok]="zrok.io"
  HOSTS[loophole]="loophole.cloud"
  HOSTS[tmate]="tmate.io"
  for m in "${METHODS[@]}"; do
    host="${HOSTS[$m]}"
    result=$(ping -c 1 -W 2 "$host" 2>/dev/null | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
    if [ -n "$result" ]; then
      echo -e "  ${GREEN}OK${NC} ${BOLD}$m${NC} ($host) - ${GREEN}${result}ms${NC}"
    else
      echo -e "  ${RED}XX${NC} ${BOLD}$m${NC} ($host) - ${RED}unreachable${NC}"
    fi
  done
  echo ""
}

cmd_install() {
  echo ""
  echo -e "${BOLD}${CYAN}  Installing dependencies...${NC}"
  echo ""
  _ok()   { echo -e "  ${GREEN}OK $1${NC}"; }
  _fail() { echo -e "  ${RED}FAIL $1 - $2${NC}"; }
  _skip() { echo -e "  ${YELLOW}SKIP $1 - already installed${NC}"; }

  if command -v bore &>/dev/null; then _skip "bore"
  elif command -v cargo &>/dev/null; then
    cargo install bore-cli &>/dev/null && _ok "bore" || _fail "bore" "cargo install failed"
  else _fail "bore" "install Rust first: https://rustup.rs"; fi

  if command -v chisel &>/dev/null; then _skip "chisel"
  else
    curl -sSL https://i.jpillora.com/chisel! | bash &>/dev/null && _ok "chisel" || _fail "chisel" "script failed"
  fi

  if command -v ngrok &>/dev/null; then _skip "ngrok"
  else
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc &>/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list &>/dev/null
    sudo apt-get update -qq && sudo apt-get install -y -qq ngrok &>/dev/null && _ok "ngrok" || _fail "ngrok" "apt failed"
  fi

  if command -v cloudflared &>/dev/null; then _skip "cloudflared"
  else
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -O /tmp/cf.deb &>/dev/null
    sudo dpkg -i /tmp/cf.deb &>/dev/null && _ok "cloudflared" || _fail "cloudflared" "dpkg failed"
  fi

  if command -v localtonet &>/dev/null; then _skip "localtonet"
  else
    wget -q "https://localtonet.com/download/localtonet-linux-x64.tar.gz" -O /tmp/ltn.tar.gz &>/dev/null
    sudo tar -xzf /tmp/ltn.tar.gz -C /usr/local/bin/ &>/dev/null && sudo chmod +x /usr/local/bin/localtonet &>/dev/null
    command -v localtonet &>/dev/null && _ok "localtonet" || _fail "localtonet" "extraction failed"
  fi

  if command -v frpc &>/dev/null; then _skip "frp"
  else
    FV=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep tag_name | cut -d'"' -f4 | sed 's/v//')
    wget -q "https://github.com/fatedier/frp/releases/download/v${FV}/frp_${FV}_linux_amd64.tar.gz" -O /tmp/frp.tar.gz &>/dev/null
    tar -xzf /tmp/frp.tar.gz -C /tmp/ &>/dev/null
    sudo cp "/tmp/frp_${FV}_linux_amd64/frpc" /usr/local/bin/ &>/dev/null && _ok "frp" || _fail "frp" "failed"
  fi

  if command -v tmate &>/dev/null; then _skip "tmate"
  else
    sudo apt-get install -y -qq tmate &>/dev/null && _ok "tmate" || _fail "tmate" "apt failed"
  fi

  if command -v zrok &>/dev/null; then _skip "zrok"
  else
    ZURL=$(curl -s https://api.github.com/repos/openziti/zrok/releases/latest | grep browser_download_url | grep linux_amd64.tar.gz | head -1 | cut -d'"' -f4)
    wget -q "$ZURL" -O /tmp/zrok.tar.gz &>/dev/null
    sudo tar -xzf /tmp/zrok.tar.gz -C /usr/local/bin/ zrok &>/dev/null && _ok "zrok" || _fail "zrok" "failed"
  fi

  _ok "serveo       (uses SSH - no install needed)"
  _ok "localhost_run (uses SSH - no install needed)"
  _ok "pinggy       (uses SSH - no install needed)"
  _ok "telebit      (uses SSH - no install needed)"
  _ok "loophole     (uses SSH - no install needed)"
  _ok "rathole      (self-hosted - needs your own VPS)"
  _ok "chisel       (self-hosted - needs your own VPS)"
  _ok "inlets       (self-hosted - needs your own VPS)"
  echo ""
  echo -e "  ${GREEN}Done!${NC} Run ${CYAN}adportv2 method${NC} to see all methods."
  echo ""
}

cmd_login() {
  local method="$1"
  [ -z "$method" ] && echo -e "${RED}Usage: adportv2 login <method>${NC}" && return 1
  case "$method" in
    ngrok)
      echo -e "${CYAN}Get token: https://dashboard.ngrok.com/get-started/your-authtoken${NC}"
      read -rp "  Paste ngrok token: " token
      ngrok config add-authtoken "$token" && echo -e "${GREEN}OK ngrok authenticated!${NC}" || echo -e "${RED}FAIL${NC}"
      ;;
    cloudflared)
      echo -e "${CYAN}Opening Cloudflare login...${NC}"
      cloudflared tunnel login
      ;;
    localtonet)
      echo -e "${CYAN}Get token: https://localtonet.com/UserApiToken${NC}"
      read -rp "  Paste localtonet token: " token
      localtonet authtoken "$token" && echo -e "${GREEN}OK localtonet authenticated!${NC}" || echo -e "${RED}FAIL${NC}"
      ;;
    zrok)
      echo -e "${CYAN}Register: https://zrok.io${NC}"
      read -rp "  Paste zrok token: " token
      zrok enable "$token" && echo -e "${GREEN}OK zrok enabled!${NC}" || echo -e "${RED}FAIL${NC}"
      ;;
    loophole)
      echo -e "${CYAN}Register: https://loophole.cloud${NC}"
      read -rp "  Paste loophole token: " token
      loophole account login --authtoken "$token" && echo -e "${GREEN}OK!${NC}" || echo -e "${RED}FAIL${NC}"
      ;;
    *)
      echo -e "${YELLOW}$method does not need login - it is free and anonymous!${NC}"
      ;;
  esac
}

_add_port() {
  local name="$1" port="$2" proto="$3" method="$4" ip="$5" link="$6" perm="$7" pid="$8"
  local entry="{\"name\":\"$name\",\"port\":$port,\"proto\":\"$proto\",\"method\":\"$method\",\"ip\":\"$ip\",\"link\":\"$link\",\"perm\":$perm,\"pid\":$pid}"
  local current
  current=$(cat "$PORTS_FILE")
  current=$(echo "$current" | python3 -c "import sys,json; d=json.load(sys.stdin); d=[x for x in d if x.get('name')!='$name']; print(json.dumps(d))" 2>/dev/null || echo "[]")
  echo "$current" | python3 -c "import sys,json; d=json.load(sys.stdin); d.append($entry); print(json.dumps(d,indent=2))" > "$PORTS_FILE" 2>/dev/null
}

_remove_port() {
  local name="$1"
  cat "$PORTS_FILE" | python3 -c "import sys,json; d=json.load(sys.stdin); d=[x for x in d if x.get('name')!='$name']; print(json.dumps(d,indent=2))" > "$PORTS_FILE.tmp" 2>/dev/null && mv "$PORTS_FILE.tmp" "$PORTS_FILE"
}

cmd_forward() {
  local name="$1" port="$2" proto="$3" method="$4"
  if [ -z "$name" ] || [ -z "$port" ] || [ -z "$proto" ] || [ -z "$method" ]; then
    echo -e "${RED}Usage: adportv2 forward <name> <port> <tcp|udp|both> <method>${NC}"
    return 1
  fi
  local perm_val="false"
  case "$method" in localtonet|cloudflared|frp|rathole|chisel|inlets|zrok) perm_val="true" ;; esac

  echo ""
  echo -e "${CYAN}${BOLD}  Starting: ${NC}${BOLD}$name${NC} | port ${YELLOW}$port${NC} | ${YELLOW}$proto${NC} | method ${GREEN}$method${NC}"
  echo -e "  ${DIM}Please wait...${NC}"
  echo ""

  local ip="" link="" pid=""

  case "$method" in
    serveo)
      ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 \
        -R "$port":localhost:"$port" serveo.net > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      link="serveo.net:$port"
      ip=$(dig +short serveo.net 2>/dev/null | head -1)
      ;;
    bore)
      bore local "$port" --to bore.pub > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      bport=$(grep -oP 'listening on bore\.pub:\K[0-9]+' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      link="bore.pub:${bport:-check_log}"
      ip=$(dig +short bore.pub 2>/dev/null | head -1)
      ;;
    localhost_run)
      ssh -o StrictHostKeyChecking=no -R "$port":localhost:"$port" \
        nokey@localhost.run > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 4
      link=$(grep -oP 'https://[^\s]+' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      [ -z "$link" ] && link="localhost.run:$port"
      ip=$(dig +short localhost.run 2>/dev/null | head -1)
      ;;
    pinggy)
      ssh -o StrictHostKeyChecking=no -p 443 \
        -R0:localhost:"$port" a.pinggy.io > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 4
      link=$(grep -oP 'https?://[^\s]+' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      [ -z "$link" ] && link="pinggy.io (check log)"
      ip=$(dig +short a.pinggy.io 2>/dev/null | head -1)
      ;;
    ngrok)
      ngrok tcp "$port" --log=stdout > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 4
      link=$(grep -oP 'tcp://[^\s]+' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      [ -z "$link" ] && link=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['tunnels'][0]['public_url'])" 2>/dev/null)
      [ -z "$link" ] && link="ngrok (check log)"
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
      echo -e "  ${YELLOW}chisel needs a chisel server running somewhere.${NC}"
      read -rp "  Enter chisel server address (host:port): " server
      chisel client "$server" "R:$port:localhost:$port" > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      ip=$(echo "$server" | cut -d: -f1)
      link="$ip:$port"
      ;;
    frp)
      echo -e "  ${YELLOW}frp needs a frps server running somewhere.${NC}"
      read -rp "  Enter frps server IP: " frp_ip
      read -rp "  Enter frps bind port (default 7000): " frp_port
      frp_port="${frp_port:-7000}"
      printf '[common]\nserver_addr = %s\nserver_port = %s\n\n[%s]\ntype = tcp\nlocal_ip = 127.0.0.1\nlocal_port = %s\nremote_port = %s\n' \
        "$frp_ip" "$frp_port" "$name" "$port" "$port" > "$CONFIG_DIR/${name}_frpc.ini"
      frpc -c "$CONFIG_DIR/${name}_frpc.ini" > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      ip="$frp_ip"
      link="$frp_ip:$port"
      ;;
    rathole)
      echo -e "  ${YELLOW}rathole needs a rathole server running somewhere.${NC}"
      read -rp "  Enter rathole server IP: " rh_ip
      read -rp "  Enter rathole server port (default 2333): " rh_port
      rh_port="${rh_port:-2333}"
      printf '[client]\nremote_addr = "%s:%s"\n\n[client.services.%s]\nlocal_addr = "127.0.0.1:%s"\n' \
        "$rh_ip" "$rh_port" "$name" "$port" > "$CONFIG_DIR/${name}_rathole.toml"
      rathole "$CONFIG_DIR/${name}_rathole.toml" > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      ip="$rh_ip"
      link="$rh_ip:$port"
      ;;
    inlets)
      echo -e "  ${YELLOW}inlets needs an inlets server running somewhere.${NC}"
      read -rp "  Enter inlets server URL (ws://host:port): " il_url
      read -rp "  Enter token: " il_token
      inlets client --remote="$il_url" --upstream="localhost:$port" --token="$il_token" > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      ip=$(echo "$il_url" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
      link="$ip:$port"
      ;;
    zrok)
      zrok share public "localhost:$port" --backend-mode tcpTunnel > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 5
      link=$(grep -oP '[a-z0-9]+\.share\.zrok\.io' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      [ -z "$link" ] && link="zrok.io (check log)"
      ip=$(dig +short zrok.io 2>/dev/null | head -1)
      ;;
    loophole)
      loophole http "$port" --hostname "$name" > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 4
      link=$(grep -oP 'https://[^\s]+loophole\.cloud[^\s]*' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      [ -z "$link" ] && link="loophole.cloud (check log)"
      ip=$(dig +short loophole.cloud 2>/dev/null | head -1)
      ;;
    tmate)
      tmate -S "/tmp/tmate-$name.sock" new-session -d > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 3
      link=$(tmate -S "/tmp/tmate-$name.sock" display -p '#{tmate_web}' 2>/dev/null)
      [ -z "$link" ] && link="tmate.io (check log)"
      ip=$(dig +short tmate.io 2>/dev/null | head -1)
      ;;
    telebit)
      ssh -o StrictHostKeyChecking=no -R "80:localhost:$port" telebit.cloud > "$CONFIG_DIR/${name}.log" 2>&1 &
      pid=$!
      sleep 4
      link=$(grep -oP 'https?://[^\s]+' "$CONFIG_DIR/${name}.log" 2>/dev/null | tail -1)
      [ -z "$link" ] && link="telebit.cloud (check log)"
      ip=$(dig +short telebit.cloud 2>/dev/null | head -1)
      ;;
    *)
      echo -e "${RED}Unknown method: $method${NC} — run ${CYAN}adportv2 method${NC} to see all."
      return 1
      ;;
  esac

  echo "$pid" > "$PID_FILE/${name}.pid"
  _add_port "$name" "$port" "$proto" "$method" "$ip" "$link" "$perm_val" "$pid"

  echo -e "  ${GREEN}${BOLD}Tunnel started!${NC}"
  echo ""
  echo -e "  ${BOLD}Name   :${NC} $name"
  echo -e "  ${BOLD}Port   :${NC} $port ($proto)"
  echo -e "  ${BOLD}Method :${NC} $method"
  [ -n "$ip"   ] && echo -e "  ${BOLD}IP     :${NC} ${YELLOW}$ip${NC}"
  [ -n "$link" ] && echo -e "  ${BOLD}Link   :${NC} ${CYAN}$link${NC}"
  echo -e "  ${BOLD}PID    :${NC} $pid"
  echo -e "  ${BOLD}Log    :${NC} $CONFIG_DIR/${name}.log"
  echo ""
  [ "$perm_val" = "false" ] && echo -e "  ${DIM}Note: temp link - removed from list on stop.${NC}"
  echo ""
}

cmd_list() {
  echo ""
  echo -e "${BOLD}${CYAN}  adportv2 - Active Ports${NC}"
  echo -e "  ${DIM}──────────────────────────────────────────────────────────────${NC}"
  local count
  count=$(python3 -c "import json; print(len(json.load(open('$PORTS_FILE'))))" 2>/dev/null || echo 0)
  if [ "$count" -eq 0 ]; then
    echo -e "  ${DIM}No active forwards. Use: adportv2 forward <name> <port> <proto> <method>${NC}"
    echo ""
    return
  fi
  printf "  ${BOLD}%-14s %-6s %-5s %-14s %-24s %s${NC}\n" "NAME" "PORT" "PROTO" "METHOD" "LINK" "STATUS"
  echo -e "  ${DIM}──────────────────────────────────────────────────────────────${NC}"
  python3 - "$PORTS_FILE" "$PID_FILE" <<PYEOF
import json, os, sys
f = sys.argv[1]
pid_dir = sys.argv[2]
data = json.load(open(f))
G="\033[0;32m"; R="\033[0;31m"; Y="\033[1;33m"; C="\033[0;36m"; B="\033[1m"; N="\033[0m"
for e in data:
    name=e.get("name","?"); port=str(e.get("port","?")); proto=e.get("proto","?")
    method=e.get("method","?"); link=e.get("link","?"); perm=e.get("perm",False); pid=e.get("pid",None)
    alive=False
    if pid:
        try: os.kill(int(pid),0); alive=True
        except: pass
    status=G+"LIVE"+N if alive else R+"DOWN"+N
    perm_s=G+"perm"+N if perm else Y+"temp"+N
    link_s=link[:24] if link else "?"
    print(f"  {B}{name:<14}{N} {C}{port:<6}{N} {proto:<5} {method:<14} {link_s:<24} {status} {perm_s}")
PYEOF
  echo ""
}

cmd_stop() {
  local target="$1"
  [ -z "$target" ] && echo -e "${RED}Usage: adportv2 stop <name|all>${NC}" && return 1

  _stop_one() {
    local n="$1"
    local pidfile="$PID_FILE/${n}.pid"
    if [ -f "$pidfile" ]; then
      local pid; pid=$(cat "$pidfile")
      kill "$pid" 2>/dev/null && echo -e "  ${GREEN}Stopped: $n (PID $pid)${NC}" || echo -e "  ${YELLOW}Already stopped: $n${NC}"
      rm -f "$pidfile"
    else
      echo -e "  ${YELLOW}No PID found for: $n${NC}"
    fi
    local perm
    perm=$(python3 -c "import json; d=json.load(open('$PORTS_FILE')); e=[x for x in d if x['name']=='$n']; print(e[0].get('perm',False) if e else False)" 2>/dev/null)
    if [ "$perm" != "True" ] && [ "$perm" != "true" ]; then
      _remove_port "$n"
      echo -e "  ${DIM}Removed $n from list (temp method)${NC}"
    fi
    rm -f "$CONFIG_DIR/${n}.log" "$CONFIG_DIR/${n}_frpc.ini" "$CONFIG_DIR/${n}_rathole.toml"
  }

  if [ "$target" = "all" ]; then
    local names
    names=$(python3 -c "import json; d=json.load(open('$PORTS_FILE')); [print(x['name']) for x in d]" 2>/dev/null)
    [ -z "$names" ] && echo -e "  ${DIM}Nothing to stop.${NC}" && return
    echo ""
    while IFS= read -r n; do _stop_one "$n"; done <<< "$names"
    for pf in "$PID_FILE"/*.pid; do
      [ -f "$pf" ] || continue
      kill "$(cat "$pf")" 2>/dev/null; rm -f "$pf"
    done
  else
    echo ""
    _stop_one "$target"
  fi
  echo ""
}

init

case "$1" in
  help|-h|--help)       cmd_help ;;
  version|-v|--version) cmd_version ;;
  ping)                 cmd_ping ;;
  list)                 cmd_list ;;
  method|methods)       cmd_method ;;
  install)              cmd_install ;;
  login)                cmd_login "$2" ;;
  forward)              cmd_forward "$2" "$3" "$4" "$5" ;;
  stop)                 cmd_stop "$2" ;;
  credit|credits)       cmd_credit ;;
  "")                   cmd_help ;;
  *)
    echo -e "${RED}Unknown command: $1${NC}"
    echo -e "Run ${CYAN}adportv2 help${NC} for usage."
    exit 1
    ;;
esac
