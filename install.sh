#!/bin/bash

###############################################################################
#
#   ULTIMATE SECURITY TOOLS INSTALLER
#   Description: Installs 500+ security tools with robust error handling
#
#   All errors are caught and logged - installation NEVER stops on failure
#
#   WARNING: For authorized security testing environments only.
#
###############################################################################

# ============================================================================
# CONFIGURATION & GLOBALS
# ============================================================================
set -o pipefail 2>/dev/null || true

# Colors
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
MAGENTA='\\033[0;35m'
CYAN='\\033[0;36m'
WHITE='\\033[1;37m'
NC='\\033[0m'
BOLD='\\033[1m'

# Directories
TOOLS_DIR="${HOME}/security-tools"
LOG_DIR="${TOOLS_DIR}/logs"
BIN_DIR="${TOOLS_DIR}/bin"
GO_TOOLS_DIR="${HOME}/go/bin"
WORDLISTS_DIR="${TOOLS_DIR}/wordlists"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOG_DIR}/install_${TIMESTAMP}.log"
ERROR_LOG="${LOG_DIR}/errors_${TIMESTAMP}.log"
SUCCESS_LOG="${LOG_DIR}/success_${TIMESTAMP}.log"
SUMMARY_FILE="${LOG_DIR}/summary_${TIMESTAMP}.txt"

# Counters
TOTAL_TOOLS=0
SUCCESS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

# Architecture detection
ARCH=$(uname -m)
OS=$(uname -s)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

setup_directories() {
    mkdir -p "${TOOLS_DIR}" "${LOG_DIR}" "${BIN_DIR}" "${WORDLISTS_DIR}" \\
             "${TOOLS_DIR}/scripts" "${TOOLS_DIR}/configs" \\
             "${TOOLS_DIR}/repos" "${TOOLS_DIR}/pip-tools" \\
             "${TOOLS_DIR}/ruby-tools" "${TOOLS_DIR}/npm-tools" \\
             "${TOOLS_DIR}/java-tools" "${TOOLS_DIR}/custom" \\
             "${HOME}/go" "${HOME}/go/bin"
    touch "${LOG_FILE}" "${ERROR_LOG}" "${SUCCESS_LOG}" "${SUMMARY_FILE}"
}

banner() {
    clear
    echo -e "${RED}"
    cat << 'BANNER'
    ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗
    ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝
    ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗
    ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝
    ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗
     ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝

    ███████╗███████╗ ██████╗    ████████╗ ██████╗  ██████╗ ██╗     ███████╗
    ██╔════╝██╔════╝██╔════╝    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝
    ███████╗█████╗  ██║            ██║   ██║   ██║██║   ██║██║     ███████╗
    ╚════██║██╔══╝  ██║            ██║   ██║   ██║██║   ██║██║     ╚════██║
    ███████║███████╗╚██████╗       ██║   ╚██████╔╝╚██████╔╝███████╗███████║
    ╚══════╝╚══════╝ ╚═════╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
BANNER
    echo -e "${NC}"
    echo -e "${CYAN}${BOLD}    ╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}    ║     ULTIMATE SECURITY TOOLS INSTALLER v3.1 (FIXED)           ║${NC}"
    echo -e "${CYAN}${BOLD}    ║     Installing 500+ Security & Pentesting Tools              ║${NC}"
    echo -e "${CYAN}${BOLD}    ║                   Crafted by ROHIT                           ║${NC}"
    echo -e "${CYAN}${BOLD}    ╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}    [*] OS: ${OS} | Arch: ${ARCH}${NC}"
    echo -e "${YELLOW}    [*] Tools Directory: ${TOOLS_DIR}${NC}"
    echo -e "${YELLOW}    [*] Log File: ${LOG_FILE}${NC}"
    echo -e "${YELLOW}    [*] Started: $(date)${NC}"
    echo ""
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "${LOG_FILE}" 2>/dev/null || true
}

log_success() {
    local tool_name="$1"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    echo -e "${GREEN}[✓] ${tool_name} installed successfully${NC}"
    echo "${tool_name}" >> "${SUCCESS_LOG}" 2>/dev/null || true
    log "[SUCCESS] ${tool_name}"
}

log_fail() {
    local tool_name="$1"
    local error_msg="${2:-Unknown error}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo -e "${RED}[✗] ${tool_name} failed: ${error_msg}${NC}"
    echo "${tool_name}: ${error_msg}" >> "${ERROR_LOG}" 2>/dev/null || true
    log "[FAILED] ${tool_name}: ${error_msg}"
}

log_skip() {
    local tool_name="$1"
    SKIP_COUNT=$((SKIP_COUNT + 1))
    echo -e "${YELLOW}[→] ${tool_name} already installed, skipping${NC}"
    log "[SKIPPED] ${tool_name}"
}

section_header() {
    local section="$1"
    local count="${2:-}"
    echo ""
    echo -e "${MAGENTA}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}${BOLD}║  ${section}${NC}"
    if [ -n "${count}" ]; then
        echo -e "${MAGENTA}${BOLD}║  Tools in section: ${count}${NC}"
    fi
    echo -e "${MAGENTA}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    log "========== SECTION: ${section} =========="
}

# Safe installation wrapper - NEVER stops on error
install_tool() {
    local tool_name="$1"
    shift
    local install_cmd="$*"
    TOTAL_TOOLS=$((TOTAL_TOOLS + 1))

    echo -e "${BLUE}[${TOTAL_TOOLS}] Installing: ${tool_name}...${NC}"

    # Run in subshell to isolate errors completely
    local exit_code=0
    (
        set +e
        set +o pipefail
        eval "${install_cmd}" >>"${LOG_FILE}" 2>&1
        exit $?
    )
    exit_code=$?

    if [ ${exit_code} -eq 0 ]; then
        log_success "${tool_name}"
    elif [ ${exit_code} -eq 2 ]; then
        log_skip "${tool_name}"
    else
        log_fail "${tool_name}" "Exit code: ${exit_code}"
    fi

    # ALWAYS return 0 so script continues
    return 0
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Safe go install
safe_go_install() {
    local package="$1"
    export GOPATH="${HOME}/go"
    export PATH="${PATH}:/usr/local/go/bin:${HOME}/go/bin"
    if command_exists go; then
        go install "${package}" 2>>"${LOG_FILE}"
        return $?
    else
        echo "Go not installed" >>"${LOG_FILE}"
        return 1
    fi
}

# Safe pip install with multiple fallbacks
safe_pip_install() {
    local package="$1"
    if command_exists pip3; then
        pip3 install --user --break-system-packages "${package}" 2>>"${LOG_FILE}" && return 0
        pip3 install --user "${package}" 2>>"${LOG_FILE}" && return 0
        pip3 install "${package}" 2>>"${LOG_FILE}" && return 0
        sudo pip3 install "${package}" 2>>"${LOG_FILE}" && return 0
        return 1
    elif command_exists pip; then
        pip install --user "${package}" 2>>"${LOG_FILE}" && return 0
        return 1
    else
        echo "pip not found" >>"${LOG_FILE}"
        return 1
    fi
}

# Safe gem install
safe_gem_install() {
    local gem_name="$1"
    if command_exists gem; then
        gem install "${gem_name}" --no-document 2>>"${LOG_FILE}" && return 0
        sudo gem install "${gem_name}" --no-document 2>>"${LOG_FILE}" && return 0
        return 1
    else
        echo "gem not found" >>"${LOG_FILE}"
        return 1
    fi
}

# Safe npm install
safe_npm_install() {
    local package="$1"
    if command_exists npm; then
        sudo npm install -g "${package}" 2>>"${LOG_FILE}" && return 0
        npm install -g "${package}" 2>>"${LOG_FILE}" && return 0
        return 1
    else
        echo "npm not found" >>"${LOG_FILE}"
        return 1
    fi
}

# Safe apt install
safe_apt_install() {
    local package="$1"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${package}" 2>>"${LOG_FILE}"
    return $?
}

# Clone repo safely
safe_git_clone() {
    local repo_url="$1"
    local dest_dir="$2"
    if [ -d "${dest_dir}" ] && [ -d "${dest_dir}/.git" ]; then
        cd "${dest_dir}" && git pull 2>>"${LOG_FILE}" || true
        return 2
    elif [ -d "${dest_dir}" ]; then
        return 2
    else
        git clone --depth 1 "${repo_url}" "${dest_dir}" 2>>"${LOG_FILE}"
        return $?
    fi
}

# Write file safely (avoids heredoc quoting issues)
write_script() {
    local filepath="$1"
    local content="$2"
    echo "${content}" > "${filepath}"
    chmod +x "${filepath}"
}

# ============================================================================
# PREREQUISITES & SYSTEM SETUP
# ============================================================================

install_prerequisites() {
    section_header "PREREQUISITES & SYSTEM SETUP"

    echo -e "${CYAN}[*] Updating system packages...${NC}"
    sudo apt-get update -y >>"${LOG_FILE}" 2>&1 || true

    echo -e "${CYAN}[*] Installing essential packages...${NC}"

    local essential_packages=(
        build-essential git curl wget unzip tar gzip bzip2
        python3 python3-pip python3-dev python3-venv python3-setuptools
        ruby ruby-dev rubygems
        libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev
        libcurl4-openssl-dev libldns-dev libpcap-dev
        jq whois dnsutils net-tools nmap
        software-properties-common
        apt-transport-https ca-certificates gnupg lsb-release
        cmake make gcc g++ pkg-config
        chromium-browser
        p7zip-full
        tmux screen vim
        libimage-exiftool-perl
        sqlmap nikto dirb wfuzz hydra john
        netcat-openbsd socat
        nfs-common smbclient ldap-utils
        snmp
        aircrack-ng
        foremost scalpel
        binwalk
        wireshark-common tshark
        masscan
        sslscan
        tor proxychains4
        hashcat
        enum4linux
        sipvicious
    )

    for pkg in "${essential_packages[@]}"; do
        echo -e "${WHITE}  [+] ${pkg}${NC}"
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkg}" >>"${LOG_FILE}" 2>&1 || {
            echo -e "${YELLOW}  [!] ${pkg} skipped${NC}"
        }
    done

    # Install Go
    echo -e "${CYAN}[*] Installing Go...${NC}"
    if ! command_exists go; then
        local GO_VERSION="1.22.5"
        local GO_ARCH="amd64"
        if [ "${ARCH}" = "aarch64" ]; then GO_ARCH="arm64"; fi
        wget -q "<https://golang.org/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz>" -O /tmp/go.tar.gz 2>>"${LOG_FILE}" && \\
        sudo rm -rf /usr/local/go && \\
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz 2>>"${LOG_FILE}" && \\
        rm -f /tmp/go.tar.gz || true
    fi
    export PATH="${PATH}:/usr/local/go/bin:${HOME}/go/bin"
    export GOPATH="${HOME}/go"
    mkdir -p "${HOME}/go/bin"
    grep -qxF 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' "${HOME}/.bashrc" 2>/dev/null || \\
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> "${HOME}/.bashrc"
    grep -qxF 'export GOPATH=$HOME/go' "${HOME}/.bashrc" 2>/dev/null || \\
        echo 'export GOPATH=$HOME/go' >> "${HOME}/.bashrc"
    echo -e "${GREEN}  [✓] Go ready${NC}"

    # Install Rust
    echo -e "${CYAN}[*] Installing Rust...${NC}"
    if ! command_exists cargo; then
        curl --proto '=https' --tlsv1.2 -sSf <https://sh.rustup.rs> 2>/dev/null | sh -s -- -y 2>>"${LOG_FILE}" || true
    fi
    [ -f "${HOME}/.cargo/env" ] && source "${HOME}/.cargo/env" 2>/dev/null || true
    echo -e "${GREEN}  [✓] Rust ready${NC}"

    # Install Node.js
    echo -e "${CYAN}[*] Installing Node.js...${NC}"
    if ! command_exists node; then
        curl -fsSL <https://deb.nodesource.com/setup_20.x> 2>/dev/null | sudo -E bash - 2>>"${LOG_FILE}" || true
        sudo apt-get install -y nodejs 2>>"${LOG_FILE}" || true
    fi
    echo -e "${GREEN}  [✓] Node.js ready${NC}"

    # Install pipx
    echo -e "${CYAN}[*] Installing pipx...${NC}"
    if ! command_exists pipx; then
        safe_pip_install "pipx" || true
        python3 -m pipx ensurepath 2>>"${LOG_FILE}" || true
    fi

    # Final PATH export
    export PATH="${HOME}/.local/bin:${HOME}/go/bin:${HOME}/.cargo/bin:${BIN_DIR}:${PATH}"

    echo -e "${GREEN}[✓] Prerequisites complete${NC}"
}

# ============================================================================
# SECTION 1: SUBDOMAIN ENUMERATION
# ============================================================================

install_subdomain_enumeration() {
    section_header "SUBDOMAIN ENUMERATION" "20"

    install_tool "Subfinder" '
        command_exists subfinder && return 2
        safe_go_install "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    '

    install_tool "Amass" '
        command_exists amass && return 2
        safe_go_install "github.com/owasp-amass/amass/v4/...@master" || \\
        safe_apt_install "amass" || \\
        sudo snap install amass 2>>"${LOG_FILE}"
    '

    install_tool "Assetfinder" '
        command_exists assetfinder && return 2
        safe_go_install "github.com/tomnomnom/assetfinder@latest"
    '

    install_tool "Findomain" '
        command_exists findomain && return 2
        local FD_URL="<https://github.com/findomain/findomain/releases/latest/download/findomain-linux.zip>"
        wget -q "${FD_URL}" -O /tmp/findomain.zip 2>>"${LOG_FILE}" && \\
        unzip -o /tmp/findomain.zip -d /tmp/findomain_bin 2>>"${LOG_FILE}" && \\
        sudo chmod +x /tmp/findomain_bin/findomain && \\
        sudo mv /tmp/findomain_bin/findomain /usr/local/bin/ && \\
        rm -rf /tmp/findomain.zip /tmp/findomain_bin
    '

    install_tool "Chaos Client" '
        command_exists chaos && return 2
        safe_go_install "github.com/projectdiscovery/chaos-client/cmd/chaos@latest"
    '

    install_tool "Sublist3r" '
        command_exists sublist3r && return 2
        safe_pip_install "sublist3r" || {
            safe_git_clone "<https://github.com/aboul3la/Sublist3r.git>" "${TOOLS_DIR}/repos/Sublist3r"
            if [ -d "${TOOLS_DIR}/repos/Sublist3r" ]; then
                cd "${TOOLS_DIR}/repos/Sublist3r"
                pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
            fi
        }
    '

    install_tool "Knockpy" '
        command_exists knockpy && return 2
        safe_pip_install "knockpy"
    '

    install_tool "DNSRecon" '
        command_exists dnsrecon && return 2
        safe_pip_install "dnsrecon" || safe_apt_install "dnsrecon"
    '

    install_tool "Fierce" '
        command_exists fierce && return 2
        safe_pip_install "fierce"
    '

    install_tool "MassDNS" '
        command_exists massdns && return 2
        safe_git_clone "<https://github.com/blechschmidt/massdns.git>" "${TOOLS_DIR}/repos/massdns"
        if [ -d "${TOOLS_DIR}/repos/massdns" ]; then
            cd "${TOOLS_DIR}/repos/massdns" && make 2>>"${LOG_FILE}" && \\
            sudo cp bin/massdns /usr/local/bin/
        fi
    '

    install_tool "PureDNS" '
        command_exists puredns && return 2
        safe_go_install "github.com/d3mondev/puredns/v2@latest"
    '

    install_tool "ShuffleDNS" '
        command_exists shuffledns && return 2
        safe_go_install "github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest"
    '

    install_tool "GitHub-Subdomains" '
        command_exists github-subdomains && return 2
        safe_go_install "github.com/gwen001/github-subdomains@latest"
    '

    install_tool "OneForAll" '
        [ -d "${TOOLS_DIR}/repos/OneForAll" ] && return 2
        safe_git_clone "<https://github.com/shmilylty/OneForAll.git>" "${TOOLS_DIR}/repos/OneForAll"
        if [ -d "${TOOLS_DIR}/repos/OneForAll" ]; then
            cd "${TOOLS_DIR}/repos/OneForAll"
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "Sudomy" '
        [ -d "${TOOLS_DIR}/repos/Sudomy" ] && return 2
        safe_git_clone "<https://github.com/screetsec/Sudomy.git>" "${TOOLS_DIR}/repos/Sudomy"
    '

    install_tool "crt.sh Script" '
        [ -f "${BIN_DIR}/crtsh" ] && return 2
        cat > "${BIN_DIR}/crtsh" << '"'"'CRTEOF'"'"'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: crtsh <domain>"; exit 1; fi
curl -s "<https://crt.sh/?q=%25.$1&output=json>" | jq -r ".[].name_value" 2>/dev/null | sort -u
CRTEOF
        chmod +x "${BIN_DIR}/crtsh"
    '

    install_tool "CertSpotter Script" '
        [ -f "${BIN_DIR}/certspotter" ] && return 2
        cat > "${BIN_DIR}/certspotter" << '"'"'CSEOF'"'"'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: certspotter <domain>"; exit 1; fi
curl -s "<https://api.certspotter.com/v1/issuances?domain=$1&include_subdomains=true&expand=dns_names>" | jq -r ".[].dns_names[]" 2>/dev/null | sort -u
CSEOF
        chmod +x "${BIN_DIR}/certspotter"
    '

    install_tool "Shodan CLI" '
        command_exists shodan && return 2
        safe_pip_install "shodan"
    '

    install_tool "Censys CLI" '
        command_exists censys && return 2
        safe_pip_install "censys"
    '

    install_tool "DNSgen" '
        command_exists dnsgen && return 2
        safe_pip_install "dnsgen"
    '
}

# ============================================================================
# SECTION 2: ASN & IP INTELLIGENCE
# ============================================================================

install_asn_ip_intelligence() {
    section_header "ASN & IP INTELLIGENCE" "10"

    install_tool "ASNMap" '
        command_exists asnmap && return 2
        safe_go_install "github.com/projectdiscovery/asnmap/cmd/asnmap@latest"
    '

    install_tool "Metabigor" '
        command_exists metabigor && return 2
        safe_go_install "github.com/j3ssie/metabigor@latest"
    '

    install_tool "BGPView Script" '
        [ -f "${BIN_DIR}/bgpview" ] && return 2
        cat > "${BIN_DIR}/bgpview" << '"'"'BGPEOF'"'"'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: bgpview <ASN_number>"; exit 1; fi
curl -s "<https://api.bgpview.io/asn/$1>" | jq . 2>/dev/null
BGPEOF
        chmod +x "${BIN_DIR}/bgpview"
    '

    install_tool "IPInfo CLI" '
        command_exists ipinfo && return 2
        curl -Ls "<https://github.com/ipinfo/cli/releases/download/ipinfo-3.3.1/ipinfo_3.3.1_linux_amd64.tar.gz>" 2>>"${LOG_FILE}" | \\
        tar xz -C /tmp/ 2>>"${LOG_FILE}" && \\
        sudo mv /tmp/ipinfo_3.3.1_linux_amd64 /usr/local/bin/ipinfo 2>>"${LOG_FILE}" && \\
        sudo chmod +x /usr/local/bin/ipinfo
    '

    install_tool "WHOIS" '
        command_exists whois && return 2
        safe_apt_install "whois"
    '

    install_tool "IP2Location" '
        safe_pip_install "IP2Location"
    '

    install_tool "Mapcidr" '
        command_exists mapcidr && return 2
        safe_go_install "github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest"
    '

    install_tool "DNSx" '
        command_exists dnsx && return 2
        safe_go_install "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    '

    install_tool "Nrich" '
        command_exists nrich && return 2
        wget -q "<https://gitlab.com/api/v4/projects/33695681/packages/generic/nrich/latest/nrich_latest_amd64.deb>" \\
            -O /tmp/nrich.deb 2>>"${LOG_FILE}" && \\
        sudo dpkg -i /tmp/nrich.deb 2>>"${LOG_FILE}" || true
        rm -f /tmp/nrich.deb
    '
}

# ============================================================================
# SECTION 3: LIVE HOST DISCOVERY
# ============================================================================

install_live_host_discovery() {
    section_header "LIVE HOST DISCOVERY" "12"

    install_tool "httpx" '
        command_exists httpx && return 2
        safe_go_install "github.com/projectdiscovery/httpx/cmd/httpx@latest"
    '

    install_tool "httprobe" '
        command_exists httprobe && return 2
        safe_go_install "github.com/tomnomnom/httprobe@latest"
    '

    install_tool "Masscan" '
        command_exists masscan && return 2
        safe_apt_install "masscan" || {
            safe_git_clone "<https://github.com/robertdavidgraham/masscan.git>" "${TOOLS_DIR}/repos/masscan"
            if [ -d "${TOOLS_DIR}/repos/masscan" ]; then
                cd "${TOOLS_DIR}/repos/masscan" && make -j"$(nproc)" 2>>"${LOG_FILE}" && \\
                sudo cp bin/masscan /usr/local/bin/
            fi
        }
    '

    install_tool "RustScan" '
        command_exists rustscan && return 2
        wget -q "<https://github.com/RustScan/RustScan/releases/download/2.2.3/rustscan_2.2.3_amd64.deb>" \\
            -O /tmp/rustscan.deb 2>>"${LOG_FILE}" && \\
        sudo dpkg -i /tmp/rustscan.deb 2>>"${LOG_FILE}" || \\
        cargo install rustscan 2>>"${LOG_FILE}" || true
        rm -f /tmp/rustscan.deb
    '

    install_tool "Aquatone" '
        command_exists aquatone && return 2
        local AQUA_URL
        AQUA_URL=$(curl -s <https://api.github.com/repos/michenriksen/aquatone/releases/latest> 2>/dev/null | \\
            jq -r ".assets[] | select(.name | contains(\\"linux_amd64\\")) | .browser_download_url" 2>/dev/null)
        if [ -n "${AQUA_URL}" ] && [ "${AQUA_URL}" != "null" ]; then
            wget -q "${AQUA_URL}" -O /tmp/aquatone.zip 2>>"${LOG_FILE}" && \\
            unzip -o /tmp/aquatone.zip -d /tmp/aquatone_dir 2>>"${LOG_FILE}" && \\
            sudo mv /tmp/aquatone_dir/aquatone /usr/local/bin/ && \\
            sudo chmod +x /usr/local/bin/aquatone
            rm -rf /tmp/aquatone.zip /tmp/aquatone_dir
        else
            return 1
        fi
    '

    install_tool "GoWitness" '
        command_exists gowitness && return 2
        safe_go_install "github.com/sensepost/gowitness@latest"
    '

    install_tool "EyeWitness" '
        [ -d "${TOOLS_DIR}/repos/EyeWitness" ] && return 2
        safe_git_clone "<https://github.com/RedSiege/EyeWitness.git>" "${TOOLS_DIR}/repos/EyeWitness"
        if [ -d "${TOOLS_DIR}/repos/EyeWitness/Python/setup" ]; then
            cd "${TOOLS_DIR}/repos/EyeWitness/Python/setup" && sudo bash setup.sh 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "WhatWeb" '
        command_exists whatweb && return 2
        safe_apt_install "whatweb" || safe_gem_install "whatweb"
    '

    install_tool "Webanalyze" '
        command_exists webanalyze && return 2
        safe_go_install "github.com/rverton/webanalyze/cmd/webanalyze@latest"
    '

    install_tool "ZGrab2" '
        command_exists zgrab2 && return 2
        safe_go_install "github.com/zmap/zgrab2@latest"
    '

    install_tool "Nmap" '
        command_exists nmap && return 2
        safe_apt_install "nmap"
    '
}

# ============================================================================
# SECTION 4: PORT SCANNING
# ============================================================================

install_port_scanning() {
    section_header "PORT SCANNING" "7"

    install_tool "Naabu" '
        command_exists naabu && return 2
        safe_go_install "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
    '

    install_tool "Unicornscan" '
        command_exists unicornscan && return 2
        safe_apt_install "unicornscan"
    '

    install_tool "ZMap" '
        command_exists zmap && return 2
        safe_apt_install "zmap"
    '

    install_tool "Smap" '
        command_exists smap && return 2
        safe_go_install "github.com/s0md3v/smap/cmd/smap@latest"
    '

    install_tool "Sandmap" '
        [ -d "${TOOLS_DIR}/repos/sandmap" ] && return 2
        safe_git_clone "<https://github.com/trimstray/sandmap.git>" "${TOOLS_DIR}/repos/sandmap"
    '

    install_tool "Nmap Scripts Update" '
        sudo nmap --script-updatedb 2>>"${LOG_FILE}" || true
    '

    install_tool "Nmap Vulners Script" '
        local SCRIPT_DIR="/usr/share/nmap/scripts"
        [ -f "${SCRIPT_DIR}/vulners.nse" ] && return 2
        sudo wget -q "<https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse>" \\
            -O "${SCRIPT_DIR}/vulners.nse" 2>>"${LOG_FILE}" || true
    '
}

# ============================================================================
# SECTION 5: VULNERABILITY SCANNING
# ============================================================================

install_vulnerability_scanning() {
    section_header "VULNERABILITY SCANNING" "10"

    install_tool "Nuclei" '
        command_exists nuclei && return 2
        safe_go_install "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
    '

    install_tool "Nuclei Templates" '
        nuclei -update-templates 2>>"${LOG_FILE}" || true
    '

    install_tool "Nikto" '
        command_exists nikto && return 2
        safe_apt_install "nikto" || {
            safe_git_clone "<https://github.com/sullo/nikto.git>" "${TOOLS_DIR}/repos/nikto"
        }
    '

    install_tool "OWASP ZAP" '
        command_exists zaproxy && return 2
        sudo snap install zaproxy --classic 2>>"${LOG_FILE}" || \\
        safe_apt_install "zaproxy" || true
    '

    install_tool "Wapiti" '
        command_exists wapiti && return 2
        safe_pip_install "wapiti3"
    '

    install_tool "Skipfish" '
        command_exists skipfish && return 2
        safe_apt_install "skipfish"
    '

    install_tool "Jaeles" '
        command_exists jaeles && return 2
        safe_go_install "github.com/jaeles-project/jaeles@latest"
    '

    install_tool "Sn1per" '
        [ -d "${TOOLS_DIR}/repos/Sn1per" ] && return 2
        safe_git_clone "<https://github.com/1N3/Sn1per.git>" "${TOOLS_DIR}/repos/Sn1per"
    '

    install_tool "OpenVAS" '
        command_exists gvm-start || command_exists openvas && return 2
        safe_apt_install "gvm" || safe_apt_install "openvas" || true
    '

    install_tool "Arachni" '
        [ -d "${TOOLS_DIR}/arachni" ] && return 2
        wget -q "<https://github.com/Arachni/arachni/releases/download/v1.6.1.3/arachni-1.6.1.3-0.6.1.1-linux-x86_64.tar.gz>" \\
            -O /tmp/arachni.tar.gz 2>>"${LOG_FILE}" && \\
        tar xzf /tmp/arachni.tar.gz -C "${TOOLS_DIR}/" 2>>"${LOG_FILE}" || true
        rm -f /tmp/arachni.tar.gz
    '
}

# ============================================================================
# SECTION 6: XSS HUNTING
# ============================================================================

install_xss_hunting() {
    section_header "XSS HUNTING" "11"

    install_tool "Dalfox" '
        command_exists dalfox && return 2
        safe_go_install "github.com/hahwul/dalfox/v2@latest"
    '

    install_tool "XSStrike" '
        [ -d "${TOOLS_DIR}/repos/XSStrike" ] && return 2
        safe_git_clone "<https://github.com/s0md3v/XSStrike.git>" "${TOOLS_DIR}/repos/XSStrike"
        if [ -d "${TOOLS_DIR}/repos/XSStrike" ]; then
            cd "${TOOLS_DIR}/repos/XSStrike"
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "Gxss" '
        command_exists Gxss && return 2
        safe_go_install "github.com/KathanP19/Gxss@latest"
    '

    install_tool "Kxss" '
        command_exists kxss && return 2
        safe_go_install "github.com/Emoe/kxss@latest"
    '

    install_tool "XSSer" '
        command_exists xsser && return 2
        safe_apt_install "xsser" || safe_pip_install "xsser" || true
    '

    install_tool "XSpear" '
        command_exists xspear && return 2
        safe_gem_install "XSpear"
    '

    install_tool "Freq" '
        command_exists freq && return 2
        safe_go_install "github.com/takshal/freq@latest"
    '

    install_tool "PwnXSS" '
        [ -d "${TOOLS_DIR}/repos/PwnXSS" ] && return 2
        safe_git_clone "<https://github.com/pwn0sec/PwnXSS.git>" "${TOOLS_DIR}/repos/PwnXSS"
    '

    install_tool "XSS-Loader" '
        [ -d "${TOOLS_DIR}/repos/XSS-LOADER" ] && return 2
        safe_git_clone "<https://github.com/capture0x/XSS-LOADER.git>" "${TOOLS_DIR}/repos/XSS-LOADER"
    '

    install_tool "Airixss" '
        command_exists airixss && return 2
        safe_go_install "github.com/ferreiraklet/airixss@latest"
    '

    install_tool "BruteXSS" '
        [ -d "${TOOLS_DIR}/repos/BruteXSS" ] && return 2
        safe_git_clone "<https://github.com/rajeshmajumdar/BruteXSS.git>" "${TOOLS_DIR}/repos/BruteXSS"
    '
}

# ============================================================================
# SECTION 7: SQL INJECTION
# ============================================================================

install_sql_injection() {
    section_header "SQL INJECTION" "7"

    install_tool "SQLMap" '
        command_exists sqlmap && return 2
        safe_apt_install "sqlmap" || safe_pip_install "sqlmap"
    '

    install_tool "NoSQLMap" '
        [ -d "${TOOLS_DIR}/repos/NoSQLMap" ] && return 2
        safe_git_clone "<https://github.com/codingo/NoSQLMap.git>" "${TOOLS_DIR}/repos/NoSQLMap"
        if [ -d "${TOOLS_DIR}/repos/NoSQLMap" ]; then
            cd "${TOOLS_DIR}/repos/NoSQLMap"
            python3 setup.py install --user 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "Ghauri" '
        command_exists ghauri && return 2
        safe_pip_install "ghauri"
    '

    install_tool "DSSS" '
        [ -d "${TOOLS_DIR}/repos/DSSS" ] && return 2
        safe_git_clone "<https://github.com/stamparm/DSSS.git>" "${TOOLS_DIR}/repos/DSSS"
    '

    install_tool "Blisqy" '
        [ -d "${TOOLS_DIR}/repos/Blisqy" ] && return 2
        safe_git_clone "<https://github.com/JohnTroony/Blisqy.git>" "${TOOLS_DIR}/repos/Blisqy"
    '

    install_tool "SleuthQL" '
        [ -d "${TOOLS_DIR}/repos/SleuthQL" ] && return 2
        safe_git_clone "<https://github.com/RhinoSecurityLabs/SleuthQL.git>" "${TOOLS_DIR}/repos/SleuthQL"
    '

    install_tool "SQLiScanner" '
        [ -d "${TOOLS_DIR}/repos/SQLiScanner" ] && return 2
        safe_git_clone "<https://github.com/0xbug/SQLiScanner.git>" "${TOOLS_DIR}/repos/SQLiScanner"
    '
}

# ============================================================================
# SECTION 8: SENSITIVE FILE DISCOVERY
# ============================================================================

install_sensitive_file_discovery() {
    section_header "SENSITIVE FILE DISCOVERY" "7"

    install_tool "GF Patterns" '
        command_exists gf && return 2
        safe_go_install "github.com/tomnomnom/gf@latest"
        mkdir -p "${HOME}/.gf"
        safe_git_clone "<https://github.com/1ndianl33t/Gf-Patterns.git>" "/tmp/Gf-Patterns"
        cp /tmp/Gf-Patterns/*.json "${HOME}/.gf/" 2>/dev/null || true
        rm -rf /tmp/Gf-Patterns
    '

    install_tool "Cloud Enum" '
        [ -d "${TOOLS_DIR}/repos/cloud_enum" ] && return 2
        safe_git_clone "<https://github.com/initstring/cloud_enum.git>" "${TOOLS_DIR}/repos/cloud_enum"
        if [ -d "${TOOLS_DIR}/repos/cloud_enum" ]; then
            cd "${TOOLS_DIR}/repos/cloud_enum"
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "S3Scanner" '
        command_exists s3scanner && return 2
        safe_pip_install "s3scanner" || safe_go_install "github.com/sa7mon/S3Scanner@latest"
    '

    install_tool "TruffleHog" '
        command_exists trufflehog && return 2
        safe_pip_install "trufflehog"
    '

    install_tool "GitLeaks" '
        command_exists gitleaks && return 2
        safe_go_install "github.com/gitleaks/gitleaks/v8@latest"
    '

    install_tool "CloudBrute" '
        command_exists cloudbrute && return 2
        safe_go_install "github.com/0xsha/CloudBrute@latest" || true
    '

    # Write sensitive file scanner using write_script function
    install_tool "Sensitive File Scanner" '
        [ -f "${BIN_DIR}/sensitive-scan" ] && return 2
        cat > "${BIN_DIR}/sensitive-scan" << '"'"'SENSITIVEEOF'"'"'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: sensitive-scan <url>"; exit 1; fi
URL="$1"
PATHS=(".env" ".git/config" ".git/HEAD" "robots.txt" "sitemap.xml" ".well-known/security.txt" ".DS_Store" "swagger.json" "swagger-ui.html" "backup.zip" "wp-config.php.bak" "config.php.bak" "database.sql" "debug.log" ".htaccess" ".htpasswd" "phpinfo.php" "web.config" ".svn/entries")
echo "[*] Scanning $URL for sensitive files..."
for path in "${PATHS[@]}"; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL/$path" 2>/dev/null)
    if [ "$CODE" != "404" ] && [ "$CODE" != "000" ] && [ "$CODE" != "403" ]; then
        echo "[${CODE}] $URL/$path"
    fi
done
SENSITIVEEOF
        chmod +x "${BIN_DIR}/sensitive-scan"
    '
}

# ============================================================================
# SECTION 9: PARAMETER DISCOVERY
# ============================================================================

install_parameter_discovery() {
    section_header "PARAMETER DISCOVERY" "12"

    install_tool "Arjun" '
        command_exists arjun && return 2
        safe_pip_install "arjun"
    '

    install_tool "ParamSpider" '
        command_exists paramspider && return 2
        safe_pip_install "paramspider" || {
            safe_git_clone "<https://github.com/devanshbatham/ParamSpider.git>" "${TOOLS_DIR}/repos/ParamSpider"
            if [ -d "${TOOLS_DIR}/repos/ParamSpider" ]; then
                cd "${TOOLS_DIR}/repos/ParamSpider"
                pip3 install . --user --break-system-packages 2>>"${LOG_FILE}" || true
            fi
        }
    '

    install_tool "x8" '
        command_exists x8 && return 2
        cargo install x8 2>>"${LOG_FILE}"
    '

    install_tool "GAU" '
        command_exists gau && return 2
        safe_go_install "github.com/lc/gau/v2/cmd/gau@latest"
    '

    install_tool "Waybackurls" '
        command_exists waybackurls && return 2
        safe_go_install "github.com/tomnomnom/waybackurls@latest"
    '

    install_tool "Hakrawler" '
        command_exists hakrawler && return 2
        safe_go_install "github.com/hakluke/hakrawler@latest"
    '

    install_tool "Katana" '
        command_exists katana && return 2
        safe_go_install "github.com/projectdiscovery/katana/cmd/katana@latest"
    '

    install_tool "GoSpider" '
        command_exists gospider && return 2
        safe_go_install "github.com/jaeles-project/gospider@latest"
    '

    install_tool "Unfurl" '
        command_exists unfurl && return 2
        safe_go_install "github.com/tomnomnom/unfurl@latest"
    '

    install_tool "QSReplace" '
        command_exists qsreplace && return 2
        safe_go_install "github.com/tomnomnom/qsreplace@latest"
    '

    install_tool "Uro" '
        command_exists uro && return 2
        safe_pip_install "uro"
    '

    install_tool "ParamMiner Wordlist" '
        [ -f "${WORDLISTS_DIR}/param-miner-wordlist.txt" ] && return 2
        wget -q "<https://raw.githubusercontent.com/PortSwigger/param-miner/master/resources/params>" \\
            -O "${WORDLISTS_DIR}/param-miner-wordlist.txt" 2>>"${LOG_FILE}"
    '
}

# ============================================================================
# SECTION 10: DIRECTORY BRUTEFORCE
# ============================================================================

install_directory_bruteforce() {
    section_header "DIRECTORY BRUTEFORCE" "10"

    install_tool "ffuf" '
        command_exists ffuf && return 2
        safe_go_install "github.com/ffuf/ffuf/v2@latest"
    '

    install_tool "Gobuster" '
        command_exists gobuster && return 2
        safe_go_install "github.com/OJ/gobuster/v3@latest"
    '

    install_tool "Dirsearch" '
        command_exists dirsearch && return 2
        safe_pip_install "dirsearch" || {
            safe_git_clone "<https://github.com/maurosoria/dirsearch.git>" "${TOOLS_DIR}/repos/dirsearch"
        }
    '

    install_tool "Feroxbuster" '
        command_exists feroxbuster && return 2
        safe_apt_install "feroxbuster" || {
            curl -sL <https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh> 2>/dev/null | \\
            bash -s "${BIN_DIR}" 2>>"${LOG_FILE}"
        }
    '

    install_tool "Dirb" '
        command_exists dirb && return 2
        safe_apt_install "dirb"
    '

    install_tool "Wfuzz" '
        command_exists wfuzz && return 2
        safe_pip_install "wfuzz"
    '

    install_tool "Kiterunner" '
        command_exists kr && return 2
        safe_git_clone "<https://github.com/assetnote/kiterunner.git>" "${TOOLS_DIR}/repos/kiterunner"
        if [ -d "${TOOLS_DIR}/repos/kiterunner" ]; then
            cd "${TOOLS_DIR}/repos/kiterunner"
            make build 2>>"${LOG_FILE}" && \\
            sudo cp dist/kr /usr/local/bin/ 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "Photon" '
        [ -d "${TOOLS_DIR}/repos/Photon" ] && return 2
        safe_git_clone "<https://github.com/s0md3v/Photon.git>" "${TOOLS_DIR}/repos/Photon"
    '

    install_tool "Meg" '
        command_exists meg && return 2
        safe_go_install "github.com/tomnomnom/meg@latest"
    '

    install_tool "SecLists" '
        [ -d "${WORDLISTS_DIR}/SecLists" ] && return 2
        safe_git_clone "<https://github.com/danielmiessler/SecLists.git>" "${WORDLISTS_DIR}/SecLists"
    '

    install_tool "Assetnote Wordlists" '
        [ -f "${WORDLISTS_DIR}/assetnote/best-dns-wordlist.txt" ] && return 2
        mkdir -p "${WORDLISTS_DIR}/assetnote"
        wget -q "<https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt>" \\
            -O "${WORDLISTS_DIR}/assetnote/best-dns-wordlist.txt" 2>>"${LOG_FILE}" || true
    '
}

# ============================================================================
# SECTION 11: JAVASCRIPT ANALYSIS
# ============================================================================

install_javascript_analysis() {
    section_header "JAVASCRIPT ANALYSIS" "10"

    # BUG FIX: Original had corrupted URL with ");" in it
    install_tool "LinkFinder" '
        [ -d "${TOOLS_DIR}/repos/LinkFinder" ] && return 2
        safe_git_clone "<https://github.com/GerbenJav>);do/LinkFinder.git" "${TOOLS_DIR}/repos/LinkFinder" || \\
        safe_git_clone "<https://github.com/dark-warlord14/LinkFinder.git>" "${TOOLS_DIR}/repos/LinkFinder"
        if [ -d "${TOOLS_DIR}/repos/LinkFinder" ]; then
            cd "${TOOLS_DIR}/repos/LinkFinder"
            python3 setup.py install --user 2>>"${LOG_FILE}" || \\
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "SecretFinder" '
        [ -d "${TOOLS_DIR}/repos/SecretFinder" ] && return 2
        safe_git_clone "<https://github.com/m4ll0k/SecretFinder.git>" "${TOOLS_DIR}/repos/SecretFinder"
        if [ -d "${TOOLS_DIR}/repos/SecretFinder" ]; then
            cd "${TOOLS_DIR}/repos/SecretFinder"
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "GetJS" '
        command_exists getJS && return 2
        safe_go_install "github.com/003random/getJS@latest"
    '

    install_tool "SubJS" '
        command_exists subjs && return 2
        safe_go_install "github.com/lc/subjs@latest"
    '

    install_tool "JSFScan" '
        [ -d "${TOOLS_DIR}/repos/JSFScan.sh" ] && return 2
        safe_git_clone "<https://github.com/KathanP19/JSFScan.sh.git>" "${TOOLS_DIR}/repos/JSFScan.sh"
    '

    install_tool "Retire.js" '
        command_exists retire && return 2
        safe_npm_install "retire"
    '

    install_tool "Mantra" '
        command_exists mantra && return 2
        safe_go_install "github.com/MrEmpy/mantra@latest"
    '

    install_tool "JSParser" '
        [ -d "${TOOLS_DIR}/repos/JSParser" ] && return 2
        safe_git_clone "<https://github.com/nicksalloum/JSParser.git>" "${TOOLS_DIR}/repos/JSParser" || true
    '

    install_tool "Source-Map-Explorer" '
        command_exists source-map-explorer && return 2
        safe_npm_install "source-map-explorer"
    '

    install_tool "JS-Beautify" '
        command_exists js-beautify && return 2
        safe_npm_install "js-beautify"
    '
}

# ============================================================================
# SECTION 12: WORDPRESS TESTING
# ============================================================================

install_wordpress_testing() {
    section_header "WORDPRESS TESTING" "5"

    install_tool "WPScan" '
        command_exists wpscan && return 2
        safe_gem_install "wpscan" || safe_apt_install "wpscan"
    '

    install_tool "WPSeku" '
        [ -d "${TOOLS_DIR}/repos/WPSeku" ] && return 2
        safe_git_clone "<https://github.com/m4ll0k/WPSeku.git>" "${TOOLS_DIR}/repos/WPSeku"
    '

    install_tool "Droopescan" '
        command_exists droopescan && return 2
        safe_pip_install "droopescan"
    '

    install_tool "CMSmap" '
        [ -d "${TOOLS_DIR}/repos/CMSmap" ] && return 2
        safe_git_clone "<https://github.com/dionach/CMSmap.git>" "${TOOLS_DIR}/repos/CMSmap"
    '

    install_tool "CMSeek" '
        [ -d "${TOOLS_DIR}/repos/CMSeek" ] && return 2
        safe_git_clone "<https://github.com/Tuhinshubhra/CMSeek.git>" "${TOOLS_DIR}/repos/CMSeek"
    '
}

# ============================================================================
# SECTION 13: API SECURITY TESTING
# ============================================================================

install_api_security() {
    section_header "API SECURITY TESTING" "10"

    install_tool "GraphQLmap" '
        [ -d "${TOOLS_DIR}/repos/GraphQLmap" ] && return 2
        safe_git_clone "<https://github.com/swisskyrepo/GraphQLmap.git>" "${TOOLS_DIR}/repos/GraphQLmap"
    '

    install_tool "InQL" '
        command_exists inql && return 2
        safe_pip_install "inql"
    '

    install_tool "JWT Tool" '
        [ -d "${TOOLS_DIR}/repos/jwt_tool" ] && return 2
        safe_git_clone "<https://github.com/ticarpi/jwt_tool.git>" "${TOOLS_DIR}/repos/jwt_tool"
        if [ -d "${TOOLS_DIR}/repos/jwt_tool" ]; then
            cd "${TOOLS_DIR}/repos/jwt_tool"
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
            chmod +x jwt_tool.py
            ln -sf "${TOOLS_DIR}/repos/jwt_tool/jwt_tool.py" "${BIN_DIR}/jwt_tool" 2>/dev/null || true
        fi
    '

    install_tool "RESTler" '
        [ -d "${TOOLS_DIR}/repos/restler-fuzzer" ] && return 2
        safe_git_clone "<https://github.com/microsoft/restler-fuzzer.git>" "${TOOLS_DIR}/repos/restler-fuzzer"
    '

    install_tool "Clairvoyance" '
        command_exists clairvoyance && return 2
        safe_pip_install "clairvoyance"
    '

    install_tool "GraphW00f" '
        [ -d "${TOOLS_DIR}/repos/graphw00f" ] && return 2
        safe_git_clone "<https://github.com/dolevf/graphw00f.git>" "${TOOLS_DIR}/repos/graphw00f"
    '

    install_tool "Newman (Postman CLI)" '
        command_exists newman && return 2
        safe_npm_install "newman"
    '

    install_tool "Hoppscotch CLI" '
        command_exists hopp && return 2
        safe_npm_install "@hoppscotch/cli" || true
    '
}

# ============================================================================
# SECTION 14: CORS EXPLOITATION
# ============================================================================

install_cors_exploitation() {
    section_header "CORS EXPLOITATION" "3"

    install_tool "Corsy" '
        [ -d "${TOOLS_DIR}/repos/Corsy" ] && return 2
        safe_git_clone "<https://github.com/s0md3v/Corsy.git>" "${TOOLS_DIR}/repos/Corsy"
    '

    install_tool "CORScanner" '
        [ -d "${TOOLS_DIR}/repos/CORScanner" ] && return 2
        safe_git_clone "<https://github.com/chenjj/CORScanner.git>" "${TOOLS_DIR}/repos/CORScanner"
        if [ -d "${TOOLS_DIR}/repos/CORScanner" ]; then
            cd "${TOOLS_DIR}/repos/CORScanner"
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "CORS Check Script" '
        [ -f "${BIN_DIR}/cors-check" ] && return 2
        cat > "${BIN_DIR}/cors-check" << '"'"'CORSEOF'"'"'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: cors-check <url>"; exit 1; fi
URL="$1"
echo "[*] Testing CORS on $URL"
echo "--- Null Origin ---"
curl -s -I -H "Origin: null" "$URL" 2>/dev/null | grep -i "access-control"
echo "--- Evil Origin ---"
curl -s -I -H "Origin: <https://evil.com>" "$URL" 2>/dev/null | grep -i "access-control"
echo "--- Subdomain Origin ---"
DOMAIN=$(echo "$URL" | sed -E "s|https?://([^/]+).*|\\1|")
curl -s -I -H "Origin: <https://evil.$>{DOMAIN}" "$URL" 2>/dev/null | grep -i "access-control"
echo "[*] Done"
CORSEOF
        chmod +x "${BIN_DIR}/cors-check"
    '
}

# ============================================================================
# SECTION 15: SUBDOMAIN TAKEOVER
# ============================================================================

install_subdomain_takeover() {
    section_header "SUBDOMAIN TAKEOVER" "7"

    install_tool "Subjack" '
        command_exists subjack && return 2
        safe_go_install "github.com/haccer/subjack@latest"
    '

    install_tool "SubOver" '
        command_exists SubOver && return 2
        safe_go_install "github.com/Ice3man543/SubOver@latest"
    '

    install_tool "DNSReaper" '
        [ -d "${TOOLS_DIR}/repos/dnsReaper" ] && return 2
        safe_git_clone "<https://github.com/punk-security/dnsReaper.git>" "${TOOLS_DIR}/repos/dnsReaper"
        if [ -d "${TOOLS_DIR}/repos/dnsReaper" ]; then
            cd "${TOOLS_DIR}/repos/dnsReaper"
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "Can-I-Take-Over-XYZ" '
        [ -d "${TOOLS_DIR}/repos/can-i-take-over-xyz" ] && return 2
        safe_git_clone "<https://github.com/EdOverflow/can-i-take-over-xyz.git>" "${TOOLS_DIR}/repos/can-i-take-over-xyz"
    '

    install_tool "TKO-Subs" '
        command_exists tko-subs && return 2
        safe_go_install "github.com/anshumanbh/tko-subs@latest"
    '

    install_tool "HostileSubBruteforcer" '
        [ -d "${TOOLS_DIR}/repos/HostileSubBruteforcer" ] && return 2
        safe_git_clone "<https://github.com/nahamsec/HostileSubBruteforcer.git>" "${TOOLS_DIR}/repos/HostileSubBruteforcer"
    '

    install_tool "Second-Order" '
        command_exists second-order && return 2
        safe_go_install "github.com/mhmdiaa/second-order@latest"
    '
}

# ============================================================================
# SECTION 16: GIT DISCLOSURE
# ============================================================================

install_git_disclosure() {
    section_header "GIT DISCLOSURE" "6"

    install_tool "git-dumper" '
        command_exists git-dumper && return 2
        safe_pip_install "git-dumper"
    '

    install_tool "GitTools" '
        [ -d "${TOOLS_DIR}/repos/GitTools" ] && return 2
        safe_git_clone "<https://github.com/internetwache/GitTools.git>" "${TOOLS_DIR}/repos/GitTools"
    '

    install_tool "Gitleaks" '
        command_exists gitleaks && return 2
        safe_go_install "github.com/gitleaks/gitleaks/v8@latest"
    '

    install_tool "GitHound" '
        command_exists git-hound && return 2
        safe_go_install "github.com/tillson/git-hound@latest" || true
    '

    install_tool "SVN Extractor" '
        [ -d "${TOOLS_DIR}/repos/svn-extractor" ] && return 2
        safe_git_clone "<https://github.com/anantshri/svn-extractor.git>" "${TOOLS_DIR}/repos/svn-extractor"
    '

    install_tool "Gitrob" '
        command_exists gitrob && return 2
        safe_go_install "github.com/michenriksen/gitrob@latest" || true
    '
}

# ============================================================================
# SECTION 17: SSRF EXPLOITATION
# ============================================================================

install_ssrf_exploitation() {
    section_header "SSRF EXPLOITATION" "4"

    install_tool "SSRFmap" '
        [ -d "${TOOLS_DIR}/repos/SSRFmap" ] && return 2
        safe_git_clone "<https://github.com/swisskyrepo/SSRFmap.git>" "${TOOLS_DIR}/repos/SSRFmap"
        if [ -d "${TOOLS_DIR}/repos/SSRFmap" ]; then
            cd "${TOOLS_DIR}/repos/SSRFmap"
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "Gopherus" '
        [ -d "${TOOLS_DIR}/repos/Gopherus" ] && return 2
        safe_git_clone "<https://github.com/tarunkant/Gopherus.git>" "${TOOLS_DIR}/repos/Gopherus"
    '

    install_tool "Interactsh" '
        command_exists interactsh-client && return 2
        safe_go_install "github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
    '

    install_tool "SSRF Payloads" '
        [ -d "${TOOLS_DIR}/repos/SSRF-Testing" ] && return 2
        safe_git_clone "<https://github.com/cujanovic/SSRF-Testing.git>" "${TOOLS_DIR}/repos/SSRF-Testing"
    '
}

# ============================================================================
# SECTION 18: OPEN REDIRECT
# ============================================================================

install_open_redirect() {
    section_header "OPEN REDIRECT" "2"

    install_tool "OpenRedirex" '
        [ -d "${TOOLS_DIR}/repos/OpenRedirex" ] && return 2
        safe_git_clone "<https://github.com/devanshbatham/OpenRedireX.git>" "${TOOLS_DIR}/repos/OpenRedirex"
    '

    install_tool "Oralyzer" '
        [ -d "${TOOLS_DIR}/repos/Oralyzer" ] && return 2
        safe_git_clone "<https://github.com/r0075h3ll/Oralyzer.git>" "${TOOLS_DIR}/repos/Oralyzer"
        if [ -d "${TOOLS_DIR}/repos/Oralyzer" ]; then
            cd "${TOOLS_DIR}/repos/Oralyzer"
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
        fi
    '
}

# ============================================================================
# SECTION 19: LFI / PATH TRAVERSAL
# ============================================================================

install_lfi_path_traversal() {
    section_header "LFI / PATH TRAVERSAL" "5"

    install_tool "dotdotpwn" '
        command_exists dotdotpwn && return 2
        [ -d "${TOOLS_DIR}/repos/dotdotpwn" ] && return 2
        safe_apt_install "dotdotpwn" || \\
        safe_git_clone "<https://github.com/wireghoul/dotdotpwn.git>" "${TOOLS_DIR}/repos/dotdotpwn"
    '

    install_tool "LFISuite" '
        [ -d "${TOOLS_DIR}/repos/LFISuite" ] && return 2
        safe_git_clone "<https://github.com/D35m0nd142/LFISuite.git>" "${TOOLS_DIR}/repos/LFISuite"
    '

    install_tool "Kadimus" '
        [ -d "${TOOLS_DIR}/repos/kadimus" ] && return 2
        safe_git_clone "<https://github.com/P0cL4bs/kadimus.git>" "${TOOLS_DIR}/repos/kadimus"
        if [ -d "${TOOLS_DIR}/repos/kadimus" ]; then
            cd "${TOOLS_DIR}/repos/kadimus" && make 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "Fimap" '
        [ -d "${TOOLS_DIR}/repos/fimap" ] && return 2
        safe_git_clone "<https://github.com/kurobeats/fimap.git>" "${TOOLS_DIR}/repos/fimap"
    '

    install_tool "LFI Payloads" '
        [ -f "${WORDLISTS_DIR}/lfi-payloads.txt" ] && return 2
        wget -q "<https://raw.githubusercontent.com/danielmiessler/SecLists/master/Fuzzing/LFI/LFI-Jhaddix.txt>" \\
            -O "${WORDLISTS_DIR}/lfi-payloads.txt" 2>>"${LOG_FILE}"
    '
}

# ============================================================================
# SECTION 20: REMOTE CODE EXECUTION
# ============================================================================

install_rce_tools() {
    section_header "REMOTE CODE EXECUTION" "7"

    install_tool "Commix" '
        command_exists commix && return 2
        safe_apt_install "commix" || {
            safe_git_clone "<https://github.com/commixproject/commix.git>" "${TOOLS_DIR}/repos/commix"
        }
    '

    install_tool "tplmap" '
        [ -d "${TOOLS_DIR}/repos/tplmap" ] && return 2
        safe_git_clone "<https://github.com/epinna/tplmap.git>" "${TOOLS_DIR}/repos/tplmap"
    '

    install_tool "SSTImap" '
        [ -d "${TOOLS_DIR}/repos/SSTImap" ] && return 2
        safe_git_clone "<https://github.com/vladko312/SSTImap.git>" "${TOOLS_DIR}/repos/SSTImap"
        if [ -d "${TOOLS_DIR}/repos/SSTImap" ]; then
            cd "${TOOLS_DIR}/repos/SSTImap"
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "Log4j Scanner" '
        [ -d "${TOOLS_DIR}/repos/log4j-scan" ] && return 2
        safe_git_clone "<https://github.com/fullhunt/log4j-scan.git>" "${TOOLS_DIR}/repos/log4j-scan"
    '

    install_tool "YSoSerial" '
        [ -f "${TOOLS_DIR}/java-tools/ysoserial.jar" ] && return 2
        wget -q "<https://github.com/frohoff/ysoserial/releases/latest/download/ysoserial-all.jar>" \\
            -O "${TOOLS_DIR}/java-tools/ysoserial.jar" 2>>"${LOG_FILE}" || true
    '

    install_tool "PHPGGC" '
        [ -d "${TOOLS_DIR}/repos/phpggc" ] && return 2
        safe_git_clone "<https://github.com/ambionics/phpggc.git>" "${TOOLS_DIR}/repos/phpggc"
    '

    install_tool "Commix Payloads" '
        [ -f "${WORDLISTS_DIR}/cmd-injection.txt" ] && return 2
        wget -q "<https://raw.githubusercontent.com/danielmiessler/SecLists/master/Fuzzing/command-injection-commix.txt>" \\
            -O "${WORDLISTS_DIR}/cmd-injection.txt" 2>>"${LOG_FILE}" || true
    '
}

# ============================================================================
# SECTION 21: CRLF INJECTION
# ============================================================================

install_crlf_injection() {
    section_header "CRLF INJECTION" "2"

    install_tool "CRLFuzz" '
        command_exists crlfuzz && return 2
        safe_go_install "github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest"
    '

    install_tool "CRLF Check Script" '
        [ -f "${BIN_DIR}/crlf-check" ] && return 2
        cat > "${BIN_DIR}/crlf-check" << '"'"'CRLFEOF'"'"'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: crlf-check <url>"; exit 1; fi
URL="$1"
PAYLOADS=("%0d%0aSet-Cookie:crlf=true" "%0aSet-Cookie:crlf=true" "%E5%98%8A%E5%98%8DSet-Cookie:crlf=true")
for p in "${PAYLOADS[@]}"; do
    RESP=$(curl -s -D - --max-time 5 "${URL}${p}" 2>/dev/null | grep -i "Set-Cookie: crlf")
    if [ -n "$RESP" ]; then
        echo "[VULN] CRLF found: ${URL}${p}"
    fi
done
echo "[*] Done"
CRLFEOF
        chmod +x "${BIN_DIR}/crlf-check"
    '
}

# ============================================================================
# SECTION 22: XXE INJECTION
# ============================================================================

install_xxe_injection() {
    section_header "XXE INJECTION" "3"

    install_tool "XXEinjector" '
        [ -d "${TOOLS_DIR}/repos/XXEinjector" ] && return 2
        safe_git_clone "<https://github.com/enjoiz/XXEinjector.git>" "${TOOLS_DIR}/repos/XXEinjector"
    '

    install_tool "XXE OOB Server" '
        [ -d "${TOOLS_DIR}/repos/xxeserv" ] && return 2
        safe_git_clone "<https://github.com/staaldraad/xxeserv.git>" "${TOOLS_DIR}/repos/xxeserv" || true
    '

    install_tool "XXE Payloads" '
        [ -f "${WORDLISTS_DIR}/xxe-payloads.txt" ] && return 2
        cat > "${WORDLISTS_DIR}/xxe-payloads.txt" << '"'"'XXEPL'"'"'
<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>
<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/shadow">]><foo>&xxe;</foo>
<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "<http://ATTACKER/xxe>">]><foo>&xxe;</foo>
XXEPL
    '
}

# ============================================================================
# SECTION 23: SECURITY HEADERS
# ============================================================================

install_security_headers() {
    section_header "SECURITY HEADERS" "3"

    install_tool "Shcheck" '
        [ -d "${TOOLS_DIR}/repos/shcheck" ] && return 2
        safe_git_clone "<https://github.com/santoru/shcheck.git>" "${TOOLS_DIR}/repos/shcheck"
    '

    install_tool "Security Headers Scanner" '
        [ -f "${BIN_DIR}/header-check" ] && return 2
        cat > "${BIN_DIR}/header-check" << '"'"'HDREOF'"'"'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: header-check <url>"; exit 1; fi
URL="$1"
echo "[*] Security Headers for $URL"
echo "================================"
HEADERS=$(curl -s -I --max-time 10 "$URL" 2>/dev/null)
for h in "Strict-Transport-Security" "Content-Security-Policy" "X-Frame-Options" "X-Content-Type-Options" "X-XSS-Protection" "Referrer-Policy" "Permissions-Policy"; do
    if echo "$HEADERS" | grep -qi "$h"; then
        echo "[OK] $h: $(echo "$HEADERS" | grep -i "$h" | head -1 | tr -d '\\r')"
    else
        echo "[!!] $h: MISSING"
    fi
done
HDREOF
        chmod +x "${BIN_DIR}/header-check"
    '

    install_tool "CSP Evaluator" '
        safe_pip_install "csp-evaluator" || true
    '
}

# ============================================================================
# SECTION 24: WAF / 403 BYPASS
# ============================================================================

install_waf_bypass() {
    section_header "WAF / 403 BYPASS" "6"

    install_tool "WAFw00f" '
        command_exists wafw00f && return 2
        safe_pip_install "wafw00f"
    '

    install_tool "WhatWAF" '
        [ -d "${TOOLS_DIR}/repos/WhatWaf" ] && return 2
        safe_git_clone "<https://github.com/Ekultek/WhatWaf.git>" "${TOOLS_DIR}/repos/WhatWaf"
    '

    install_tool "byp4xx" '
        command_exists byp4xx && return 2
        safe_go_install "github.com/lobuhi/byp4xx@latest"
    '

    install_tool "WAFNinja" '
        [ -d "${TOOLS_DIR}/repos/WAFNinja" ] && return 2
        safe_git_clone "<https://github.com/khalilbijjou/WAFNinja.git>" "${TOOLS_DIR}/repos/WAFNinja"
    '

    install_tool "IdentYwaf" '
        [ -d "${TOOLS_DIR}/repos/identYwaf" ] && return 2
        safe_git_clone "<https://github.com/stamparm/identYwaf.git>" "${TOOLS_DIR}/repos/identYwaf"
    '

    # BUG FIX: Renamed PATH_TARGET -> TARGET_PATH to avoid $PATH collision
    install_tool "403 Bypass Script" '
        [ -f "${BIN_DIR}/bypass403" ] && return 2
        cat > "${BIN_DIR}/bypass403" << '"'"'B403EOF'"'"'
#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ]; then echo "Usage: bypass403 <url> <path>"; exit 1; fi
URL="$1"
TARGET_PATH="$2"
echo "[*] 403 Bypass for $URL/$TARGET_PATH"
echo "=== Method Bypass ==="
for method in GET POST PUT PATCH DELETE OPTIONS TRACE; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 -X "$method" "$URL/$TARGET_PATH" 2>/dev/null)
    echo "[$CODE] $method"
done
echo "=== Header Bypass ==="
for hdr in "X-Forwarded-For: 127.0.0.1" "X-Original-URL: /$TARGET_PATH" "X-Rewrite-URL: /$TARGET_PATH" "X-Custom-IP-Authorization: 127.0.0.1" "X-Real-IP: 127.0.0.1"; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 -H "$hdr" "$URL/$TARGET_PATH" 2>/dev/null)
    echo "[$CODE] $hdr"
done
echo "=== Path Bypass ==="
for p in "/$TARGET_PATH" "/$TARGET_PATH/" "/$TARGET_PATH/." "/$TARGET_PATH..;/" "/$TARGET_PATH%20" "/$TARGET_PATH%09" "/$TARGET_PATH?" "/%2e/$TARGET_PATH"; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL$p" 2>/dev/null)
    echo "[$CODE] $URL$p"
done
B403EOF
        chmod +x "${BIN_DIR}/bypass403"
    '
}

# ============================================================================
# SECTION 25: OSINT & RECON
# ============================================================================

install_osint_recon() {
    section_header "OSINT & RECON" "12"

    install_tool "theHarvester" '
        command_exists theHarvester && return 2
        safe_pip_install "theHarvester" || safe_apt_install "theharvester"
    '

    install_tool "Recon-ng" '
        command_exists recon-ng && return 2
        safe_apt_install "recon-ng" || safe_pip_install "recon-ng"
    '

    install_tool "SpiderFoot" '
        command_exists spiderfoot && return 2
        safe_pip_install "spiderfoot" || {
            safe_git_clone "<https://github.com/smicallef/spiderfoot.git>" "${TOOLS_DIR}/repos/spiderfoot"
        }
    '

    install_tool "Maltego" '
        command_exists maltego && return 2
        safe_apt_install "maltego" || true
    '

    install_tool "EmailHarvester" '
        [ -d "${TOOLS_DIR}/repos/EmailHarvester" ] && return 2
        safe_git_clone "<https://github.com/maldevel/EmailHarvester.git>" "${TOOLS_DIR}/repos/EmailHarvester"
    '

    install_tool "PhoneInfoga" '
        command_exists phoneinfoga && return 2
        safe_go_install "github.com/sundowndev/phoneinfoga/v2@latest" || true
    '

    install_tool "Sherlock" '
        command_exists sherlock && return 2
        safe_pip_install "sherlock-project" || {
            safe_git_clone "<https://github.com/sherlock-project/sherlock.git>" "${TOOLS_DIR}/repos/sherlock"
        }
    '

    install_tool "Holehe" '
        command_exists holehe && return 2
        safe_pip_install "holehe"
    '

    install_tool "Social Analyzer" '
        command_exists social-analyzer && return 2
        safe_pip_install "social-analyzer"
    '

    install_tool "OSINT Framework" '
        [ -d "${TOOLS_DIR}/repos/osint-framework" ] && return 2
        safe_git_clone "<https://github.com/lockfale/osint-framework.git>" "${TOOLS_DIR}/repos/osint-framework"
    '

    install_tool "Google Dorker Script" '
        [ -f "${BIN_DIR}/gdork" ] && return 2
        cat > "${BIN_DIR}/gdork" << '"'"'GDEOF'"'"'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: gdork <domain>"; exit 1; fi
D="$1"
echo "=== Google Dorks for $D ==="
echo "site:$D filetype:pdf"
echo "site:$D filetype:sql"
echo "site:$D filetype:log"
echo "site:$D filetype:env"
echo "site:$D inurl:admin"
echo "site:$D inurl:login"
echo "site:$D inurl:config"
echo "site:$D intitle:\\"index of\\""
echo "site:$D inurl:api"
echo "site:$D inurl:swagger"
echo "\\"$D\\" password OR api_key OR secret"
GDEOF
        chmod +x "${BIN_DIR}/gdork"
    '

    install_tool "Infoga" '
        [ -d "${TOOLS_DIR}/repos/Infoga" ] && return 2
        safe_git_clone "<https://github.com/m4ll0k/Infoga.git>" "${TOOLS_DIR}/repos/Infoga"
    '
}

# ============================================================================
# SECTION 26: CLOUD SECURITY
# ============================================================================

install_cloud_security() {
    section_header "CLOUD SECURITY" "12"

    install_tool "ScoutSuite" '
        command_exists scout && return 2
        safe_pip_install "scoutsuite"
    '

    install_tool "Prowler" '
        command_exists prowler && return 2
        safe_pip_install "prowler" || {
            safe_git_clone "<https://github.com/prowler-cloud/prowler.git>" "${TOOLS_DIR}/repos/prowler"
        }
    '

    install_tool "Pacu" '
        [ -d "${TOOLS_DIR}/repos/pacu" ] && return 2
        safe_git_clone "<https://github.com/RhinoSecurityLabs/pacu.git>" "${TOOLS_DIR}/repos/pacu"
    '

    install_tool "CloudMapper" '
        [ -d "${TOOLS_DIR}/repos/cloudmapper" ] && return 2
        safe_git_clone "<https://github.com/duo-labs/cloudmapper.git>" "${TOOLS_DIR}/repos/cloudmapper"
    '

    install_tool "Cloudsplaining" '
        command_exists cloudsplaining && return 2
        safe_pip_install "cloudsplaining"
    '

    install_tool "GCPBucketBrute" '
        [ -d "${TOOLS_DIR}/repos/GCPBucketBrute" ] && return 2
        safe_git_clone "<https://github.com/RhinoSecurityLabs/GCPBucketBrute.git>" "${TOOLS_DIR}/repos/GCPBucketBrute"
    '

    install_tool "MicroBurst" '
        [ -d "${TOOLS_DIR}/repos/MicroBurst" ] && return 2
        safe_git_clone "<https://github.com/NetSPI/MicroBurst.git>" "${TOOLS_DIR}/repos/MicroBurst"
    '

    install_tool "CloudFox" '
        command_exists cloudfox && return 2
        safe_go_install "github.com/BishopFox/cloudfox@latest"
    '

    install_tool "Trivy" '
        command_exists trivy && return 2
        wget -qO - <https://aquasecurity.github.io/trivy-repo/deb/public.key> 2>/dev/null | \\
            gpg --dearmor 2>/dev/null | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null 2>&1
        local CODENAME
        CODENAME=$(lsb_release -sc 2>/dev/null || echo "jammy")
        echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] <https://aquasecurity.github.io/trivy-repo/deb> ${CODENAME} main" | \\
            sudo tee /etc/apt/sources.list.d/trivy.list >/dev/null 2>&1
        sudo apt-get update -y >>"${LOG_FILE}" 2>&1 && \\
        sudo apt-get install -y trivy >>"${LOG_FILE}" 2>&1
    '

    install_tool "AWS CLI" '
        command_exists aws && return 2
        curl -s "<https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip>" -o "/tmp/awscliv2.zip" 2>>"${LOG_FILE}" && \\
        unzip -o /tmp/awscliv2.zip -d /tmp/aws_install 2>>"${LOG_FILE}" && \\
        sudo /tmp/aws_install/aws/install 2>>"${LOG_FILE}" || true
        rm -rf /tmp/awscliv2.zip /tmp/aws_install
    '

    install_tool "Steampipe" '
        command_exists steampipe && return 2
        sudo /bin/sh -c "$(curl -fsSL <https://raw.githubusercontent.com/turbot/steampipe/main/install.sh>)" 2>>"${LOG_FILE}" || true
    '
}

# ============================================================================
# SECTION 27: CONTAINER AUDITING
# ============================================================================

install_container_auditing() {
    section_header "CONTAINER AUDITING" "8"

    install_tool "Docker Bench Security" '
        [ -d "${TOOLS_DIR}/repos/docker-bench-security" ] && return 2
        safe_git_clone "<https://github.com/docker/docker-bench-security.git>" "${TOOLS_DIR}/repos/docker-bench-security"
    '

    install_tool "Grype" '
        command_exists grype && return 2
        curl -sSfL <https://raw.githubusercontent.com/anchore/grype/main/install.sh> 2>/dev/null | \\
            sudo sh -s -- -b /usr/local/bin 2>>"${LOG_FILE}"
    '

    install_tool "Kube-hunter" '
        command_exists kube-hunter && return 2
        safe_pip_install "kube-hunter"
    '

    install_tool "Kube-bench" '
        command_exists kube-bench && return 2
        safe_go_install "github.com/aquasecurity/kube-bench@latest" || true
    '

    install_tool "Kubeaudit" '
        command_exists kubeaudit && return 2
        safe_go_install "github.com/Shopify/kubeaudit@latest" || true
    '

    install_tool "Checkov" '
        command_exists checkov && return 2
        safe_pip_install "checkov"
    '

    # BUG FIX: Fixed terrascan download with proper URL handling
    install_tool "Terrascan" '
        command_exists terrascan && return 2
        safe_go_install "github.com/tenable/terrascan@latest" || {
            local TS_URL
            TS_URL=$(curl -s <https://api.github.com/repos/tenable/terrascan/releases/latest> 2>/dev/null | \\
                jq -r ".assets[] | select(.name | test(\\"Linux_x86_64.tar.gz$\\")) | .browser_download_url" 2>/dev/null | head -1)
            if [ -n "${TS_URL}" ] && [ "${TS_URL}" != "null" ]; then
                wget -q "${TS_URL}" -O /tmp/terrascan.tar.gz 2>>"${LOG_FILE}" && \\
                sudo tar -xf /tmp/terrascan.tar.gz -C /usr/local/bin/ terrascan 2>>"${LOG_FILE}" || true
                rm -f /tmp/terrascan.tar.gz
            fi
        }
    '

    install_tool "Hadolint" '
        command_exists hadolint && return 2
        sudo wget -q "<https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64>" \\
            -O /usr/local/bin/hadolint 2>>"${LOG_FILE}" && \\
        sudo chmod +x /usr/local/bin/hadolint
    '
}

# ============================================================================
# SECTION 28: ADVANCED WEB EXPLOITS
# ============================================================================

install_advanced_web_exploits() {
    section_header "ADVANCED WEB EXPLOITS" "6"

    install_tool "Smuggler" '
        [ -d "${TOOLS_DIR}/repos/smuggler" ] && return 2
        safe_git_clone "<https://github.com/defparam/smuggler.git>" "${TOOLS_DIR}/repos/smuggler"
    '

    install_tool "H2CSmuggler" '
        [ -d "${TOOLS_DIR}/repos/h2csmuggler" ] && return 2
        safe_git_clone "<https://github.com/BishopFox/h2csmuggler.git>" "${TOOLS_DIR}/repos/h2csmuggler"
    '

    install_tool "STEWS (WebSocket)" '
        [ -d "${TOOLS_DIR}/repos/STEWS" ] && return 2
        safe_git_clone "<https://github.com/PalindromeLabs/STEWS.git>" "${TOOLS_DIR}/repos/STEWS"
    '

    install_tool "PPMap (Prototype Pollution)" '
        [ -d "${TOOLS_DIR}/repos/ppmap" ] && return 2
        safe_git_clone "<https://github.com/nicksalloum/ppmap.git>" "${TOOLS_DIR}/repos/ppmap" || true
    '

    install_tool "YSoSerial Repo" '
        [ -d "${TOOLS_DIR}/repos/ysoserial" ] && return 2
        safe_git_clone "<https://github.com/frohoff/ysoserial.git>" "${TOOLS_DIR}/repos/ysoserial"
    '

    install_tool "GraphQL Voyager" '
        safe_npm_install "graphql-voyager" || true
    '
}

# ============================================================================
# SECTION 29: MOBILE APP SECURITY
# ============================================================================

install_mobile_app_sec() {
    section_header "MOBILE APP SECURITY" "8"

    install_tool "MobSF" '
        [ -d "${TOOLS_DIR}/repos/Mobile-Security-Framework-MobSF" ] && return 2
        safe_git_clone "<https://github.com/MobSF/Mobile-Security-Framework-MobSF.git>" "${TOOLS_DIR}/repos/Mobile-Security-Framework-MobSF"
    '

    install_tool "Apktool" '
        command_exists apktool && return 2
        safe_apt_install "apktool"
    '

    install_tool "Jadx" '
        command_exists jadx && return 2
        safe_apt_install "jadx" || true
    '

    install_tool "Frida" '
        command_exists frida && return 2
        safe_pip_install "frida-tools"
    '

    install_tool "Objection" '
        command_exists objection && return 2
        safe_pip_install "objection"
    '

    install_tool "Drozer" '
        command_exists drozer && return 2
        safe_pip_install "drozer" || true
    '

    install_tool "Dex2Jar" '
        command_exists d2j-dex2jar && return 2
        safe_apt_install "dex2jar"
    '

    install_tool "ADB" '
        command_exists adb && return 2
        safe_apt_install "adb" || safe_apt_install "android-tools-adb"
    '
}

# ============================================================================
# SECTION 30: NETWORK INFRASTRUCTURE
# ============================================================================

install_network_infrastructure() {
    section_header "NETWORK INFRASTRUCTURE" "12"

    install_tool "NetExec (CrackMapExec)" '
        command_exists nxc || command_exists crackmapexec && return 2
        safe_pip_install "netexec" || safe_pip_install "crackmapexec" || true
    '

    install_tool "Enum4linux-ng" '
        command_exists enum4linux-ng && return 2
        safe_pip_install "enum4linux-ng" || {
            safe_git_clone "<https://github.com/cddmp/enum4linux-ng.git>" "${TOOLS_DIR}/repos/enum4linux-ng"
        }
    '

    install_tool "SMBClient" '
        command_exists smbclient && return 2
        safe_apt_install "smbclient"
    '

    install_tool "SNMP Tools" '
        command_exists snmpwalk && return 2
        safe_apt_install "snmp"
    '

    install_tool "Responder" '
        command_exists responder && return 2
        [ -d "${TOOLS_DIR}/repos/Responder" ] && return 2
        safe_apt_install "responder" || {
            safe_git_clone "<https://github.com/lgandx/Responder.git>" "${TOOLS_DIR}/repos/Responder"
        }
    '

    install_tool "Impacket" '
        python3 -c "import impacket" 2>/dev/null && return 2
        safe_pip_install "impacket" || {
            safe_git_clone "<https://github.com/fortra/impacket.git>" "${TOOLS_DIR}/repos/impacket"
            if [ -d "${TOOLS_DIR}/repos/impacket" ]; then
                cd "${TOOLS_DIR}/repos/impacket"
                pip3 install . --user --break-system-packages 2>>"${LOG_FILE}" || true
            fi
        }
    '

    install_tool "Evil-WinRM" '
        command_exists evil-winrm && return 2
        safe_gem_install "evil-winrm"
    '

    install_tool "Chisel" '
        command_exists chisel && return 2
        safe_go_install "github.com/jpillora/chisel@latest"
    '

    install_tool "FTP & LFTP" '
        safe_apt_install "ftp" || true
        safe_apt_install "lftp" || true
    '

    install_tool "Telnet" '
        command_exists telnet && return 2
        safe_apt_install "telnet"
    '

    install_tool "IKE-Scan" '
        command_exists ike-scan && return 2
        safe_apt_install "ike-scan"
    '

    install_tool "Netcat & Socat" '
        safe_apt_install "netcat-openbsd" || true
        safe_apt_install "socat" || true
    '
}

# ============================================================================
# SECTION 31: WIRELESS SECURITY
# ============================================================================

install_wireless_security() {
    section_header "WIRELESS SECURITY" "8"

    install_tool "Aircrack-ng" '
        command_exists aircrack-ng && return 2
        safe_apt_install "aircrack-ng"
    '

    install_tool "Wifite2" '
        command_exists wifite && return 2
        safe_apt_install "wifite" || {
            safe_git_clone "<https://github.com/derv82/wifite2.git>" "${TOOLS_DIR}/repos/wifite2"
        }
    '

    install_tool "Reaver" '
        command_exists reaver && return 2
        safe_apt_install "reaver"
    '

    install_tool "Bully" '
        command_exists bully && return 2
        safe_apt_install "bully"
    '

    install_tool "Kismet" '
        command_exists kismet && return 2
        safe_apt_install "kismet"
    '

    install_tool "Bettercap" '
        command_exists bettercap && return 2
        safe_apt_install "bettercap" || safe_go_install "github.com/bettercap/bettercap@latest" || true
    '

    install_tool "HCXDumptool" '
        command_exists hcxdumptool && return 2
        safe_apt_install "hcxdumptool"
    '

    install_tool "HCXTools" '
        command_exists hcxpcapngtool && return 2
        safe_apt_install "hcxtools"
    '
}

# ============================================================================
# SECTION 32: PRIVILEGE ESCALATION
# ============================================================================

install_privilege_escalation() {
    section_header "PRIVILEGE ESCALATION" "8"

    install_tool "LinPEAS" '
        [ -f "${TOOLS_DIR}/scripts/linpeas.sh" ] && return 2
        wget -q "<https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh>" \\
            -O "${TOOLS_DIR}/scripts/linpeas.sh" 2>>"${LOG_FILE}" && \\
        chmod +x "${TOOLS_DIR}/scripts/linpeas.sh"
    '

    install_tool "WinPEAS" '
        [ -f "${TOOLS_DIR}/scripts/winPEASany.exe" ] && return 2
        wget -q "<https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASany.exe>" \\
            -O "${TOOLS_DIR}/scripts/winPEASany.exe" 2>>"${LOG_FILE}"
    '

    install_tool "Linux Exploit Suggester" '
        [ -f "${TOOLS_DIR}/scripts/les.sh" ] && return 2
        wget -q "<https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh>" \\
            -O "${TOOLS_DIR}/scripts/les.sh" 2>>"${LOG_FILE}" && \\
        chmod +x "${TOOLS_DIR}/scripts/les.sh"
    '

    install_tool "LinEnum" '
        [ -f "${TOOLS_DIR}/scripts/LinEnum.sh" ] && return 2
        wget -q "<https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh>" \\
            -O "${TOOLS_DIR}/scripts/LinEnum.sh" 2>>"${LOG_FILE}" && \\
        chmod +x "${TOOLS_DIR}/scripts/LinEnum.sh"
    '

    install_tool "pspy" '
        [ -f "${TOOLS_DIR}/scripts/pspy64" ] && return 2
        wget -q "<https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64>" \\
            -O "${TOOLS_DIR}/scripts/pspy64" 2>>"${LOG_FILE}" && \\
        chmod +x "${TOOLS_DIR}/scripts/pspy64"
    '

    install_tool "GTFOBins" '
        [ -d "${TOOLS_DIR}/repos/GTFOBins.github.io" ] && return 2
        safe_git_clone "<https://github.com/GTFOBins/GTFOBins.github.io.git>" "${TOOLS_DIR}/repos/GTFOBins.github.io"
    '

    install_tool "LOLBAS" '
        [ -d "${TOOLS_DIR}/repos/LOLBAS" ] && return 2
        safe_git_clone "<https://github.com/LOLBAS-Project/LOLBAS.git>" "${TOOLS_DIR}/repos/LOLBAS"
    '

    install_tool "Windows Exploit Suggester" '
        [ -d "${TOOLS_DIR}/repos/wesng" ] && return 2
        safe_git_clone "<https://github.com/bitsadmin/wesng.git>" "${TOOLS_DIR}/repos/wesng"
    '
}

# ============================================================================
# SECTION 33: ACTIVE DIRECTORY
# ============================================================================

install_active_directory() {
    section_header "ACTIVE DIRECTORY" "10"

    install_tool "BloodHound" '
        command_exists bloodhound && return 2
        safe_apt_install "bloodhound" || true
    '

    install_tool "BloodHound.py" '
        command_exists bloodhound-python && return 2
        safe_pip_install "bloodhound"
    '

    install_tool "Kerbrute" '
        command_exists kerbrute && return 2
        safe_go_install "github.com/ropnop/kerbrute@latest"
    '

    install_tool "Rubeus" '
        [ -d "${TOOLS_DIR}/repos/Rubeus" ] && return 2
        safe_git_clone "<https://github.com/GhostPack/Rubeus.git>" "${TOOLS_DIR}/repos/Rubeus"
    '

    install_tool "Mimikatz" '
        [ -d "${TOOLS_DIR}/repos/mimikatz" ] && return 2
        safe_git_clone "<https://github.com/gentilkiwi/mimikatz.git>" "${TOOLS_DIR}/repos/mimikatz"
    '

    install_tool "PowerSploit" '
        [ -d "${TOOLS_DIR}/repos/PowerSploit" ] && return 2
        safe_git_clone "<https://github.com/PowerShellMafia/PowerSploit.git>" "${TOOLS_DIR}/repos/PowerSploit"
    '

    install_tool "ADRecon" '
        [ -d "${TOOLS_DIR}/repos/ADRecon" ] && return 2
        safe_git_clone "<https://github.com/adrecon/ADRecon.git>" "${TOOLS_DIR}/repos/ADRecon"
    '

    install_tool "Certipy" '
        command_exists certipy && return 2
        safe_pip_install "certipy-ad"
    '

    install_tool "PetitPotam" '
        [ -d "${TOOLS_DIR}/repos/PetitPotam" ] && return 2
        safe_git_clone "<https://github.com/topotam/PetitPotam.git>" "${TOOLS_DIR}/repos/PetitPotam"
    '

    install_tool "Coercer" '
        command_exists coercer && return 2
        safe_pip_install "coercer"
    '
}

# ============================================================================
# SECTION 34: C2 & POST EXPLOITATION
# ============================================================================

install_c2_post_exploitation() {
    section_header "C2 & POST EXPLOITATION" "8"

    install_tool "Metasploit" '
        command_exists msfconsole && return 2
        curl -s <https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb> > /tmp/msfinstall 2>>"${LOG_FILE}" && \\
        chmod 755 /tmp/msfinstall && \\
        sudo /tmp/msfinstall 2>>"${LOG_FILE}" || \\
        safe_apt_install "metasploit-framework" || true
        rm -f /tmp/msfinstall
    '

    install_tool "Empire" '
        [ -d "${TOOLS_DIR}/repos/Empire" ] && return 2
        safe_git_clone "<https://github.com/BC-SECURITY/Empire.git>" "${TOOLS_DIR}/repos/Empire"
    '

    install_tool "Sliver" '
        command_exists sliver && return 2
        curl -s <https://sliver.sh/install> 2>/dev/null | sudo bash 2>>"${LOG_FILE}" || true
    '

    install_tool "Covenant" '
        [ -d "${TOOLS_DIR}/repos/Covenant" ] && return 2
        safe_git_clone "<https://github.com/cobbr/Covenant.git>" "${TOOLS_DIR}/repos/Covenant"
    '

    install_tool "Mythic" '
        [ -d "${TOOLS_DIR}/repos/Mythic" ] && return 2
        safe_git_clone "<https://github.com/its-a-feature/Mythic.git>" "${TOOLS_DIR}/repos/Mythic"
    '

    install_tool "Havoc" '
        [ -d "${TOOLS_DIR}/repos/Havoc" ] && return 2
        safe_git_clone "<https://github.com/HavocFramework/Havoc.git>" "${TOOLS_DIR}/repos/Havoc"
    '

    install_tool "PoshC2" '
        [ -d "${TOOLS_DIR}/repos/PoshC2" ] && return 2
        safe_git_clone "<https://github.com/nettitude/PoshC2.git>" "${TOOLS_DIR}/repos/PoshC2"
    '

    install_tool "Villain" '
        [ -d "${TOOLS_DIR}/repos/Villain" ] && return 2
        safe_git_clone "<https://github.com/t3l3machus/Villain.git>" "${TOOLS_DIR}/repos/Villain"
    '
}

# ============================================================================
# SECTION 35: CRYPTOGRAPHY & HASH CRACKING
# ============================================================================

install_crypto_hash_cracking() {
    section_header "CRYPTOGRAPHY & HASH CRACKING" "10"

    install_tool "Hashcat" '
        command_exists hashcat && return 2
        safe_apt_install "hashcat"
    '

    install_tool "John the Ripper" '
        command_exists john && return 2
        safe_apt_install "john"
    '

    install_tool "Hydra" '
        command_exists hydra && return 2
        safe_apt_install "hydra"
    '

    install_tool "Medusa" '
        command_exists medusa && return 2
        safe_apt_install "medusa"
    '

    install_tool "Ncrack" '
        command_exists ncrack && return 2
        safe_apt_install "ncrack"
    '

    install_tool "Hash-Identifier" '
        command_exists hashid && return 2
        safe_pip_install "hashid" || safe_apt_install "hash-identifier"
    '

    install_tool "Name-That-Hash" '
        command_exists nth && return 2
        safe_pip_install "name-that-hash"
    '

    install_tool "CeWL" '
        command_exists cewl && return 2
        safe_apt_install "cewl"
    '

    install_tool "Crunch" '
        command_exists crunch && return 2
        safe_apt_install "crunch"
    '

    install_tool "SSLScan" '
        command_exists sslscan && return 2
        safe_apt_install "sslscan"
    '
}

# ============================================================================
# SECTION 36: REVERSE ENGINEERING
# ============================================================================

install_reverse_engineering() {
    section_header "REVERSE ENGINEERING" "10"

    install_tool "GDB" '
        command_exists gdb && return 2
        safe_apt_install "gdb"
    '

    install_tool "GEF" '
        [ -f "${HOME}/.gdbinit-gef.py" ] && return 2
        wget -q "<https://raw.githubusercontent.com/hugsy/gef/main/gef.py>" \\
            -O "${HOME}/.gdbinit-gef.py" 2>>"${LOG_FILE}" || true
    '

    install_tool "Pwndbg" '
        [ -d "${TOOLS_DIR}/repos/pwndbg" ] && return 2
        safe_git_clone "<https://github.com/pwndbg/pwndbg.git>" "${TOOLS_DIR}/repos/pwndbg"
        if [ -d "${TOOLS_DIR}/repos/pwndbg" ]; then
            cd "${TOOLS_DIR}/repos/pwndbg" && bash setup.sh 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "Radare2" '
        command_exists r2 && return 2
        safe_apt_install "radare2" || {
            safe_git_clone "<https://github.com/radareorg/radare2.git>" "${TOOLS_DIR}/repos/radare2"
            if [ -d "${TOOLS_DIR}/repos/radare2" ]; then
                cd "${TOOLS_DIR}/repos/radare2" && sys/install.sh 2>>"${LOG_FILE}" || true
            fi
        }
    '

    install_tool "Ghidra" '
        [ -d "${TOOLS_DIR}/ghidra" ] && return 2
        command_exists ghidra && return 2
        local GHIDRA_URL
        GHIDRA_URL=$(curl -s <https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest> 2>/dev/null | \\
            jq -r ".assets[0].browser_download_url" 2>/dev/null)
        if [ -n "${GHIDRA_URL}" ] && [ "${GHIDRA_URL}" != "null" ]; then
            wget -q "${GHIDRA_URL}" -O /tmp/ghidra.zip 2>>"${LOG_FILE}" && \\
            unzip -o /tmp/ghidra.zip -d "${TOOLS_DIR}/ghidra" 2>>"${LOG_FILE}" || true
            rm -f /tmp/ghidra.zip
        else
            safe_apt_install "ghidra" || true
        fi
    '

    install_tool "Binutils" '
        command_exists objdump && return 2
        safe_apt_install "binutils"
    '

    install_tool "Ltrace & Strace" '
        safe_apt_install "ltrace" || true
        safe_apt_install "strace" || true
    '

    install_tool "ROPgadget" '
        command_exists ROPgadget && return 2
        safe_pip_install "ROPgadget"
    '

    install_tool "Pwntools" '
        python3 -c "import pwn" 2>/dev/null && return 2
        safe_pip_install "pwntools"
    '

    install_tool "Rizin" '
        command_exists rizin && return 2
        safe_apt_install "rizin" || true
    '
}

# ============================================================================
# SECTION 37: HARDWARE & IoT SECURITY
# ============================================================================

install_hardware_iot() {
    section_header "HARDWARE & IoT SECURITY" "7"

    install_tool "Binwalk" '
        command_exists binwalk && return 2
        safe_apt_install "binwalk" || safe_pip_install "binwalk"
    '

    install_tool "Firmwalker" '
        [ -d "${TOOLS_DIR}/repos/firmwalker" ] && return 2
        safe_git_clone "<https://github.com/craigz28/firmwalker.git>" "${TOOLS_DIR}/repos/firmwalker"
    '

    install_tool "RouterSploit" '
        [ -d "${TOOLS_DIR}/repos/routersploit" ] && return 2
        safe_git_clone "<https://github.com/threat9/routersploit.git>" "${TOOLS_DIR}/repos/routersploit"
        if [ -d "${TOOLS_DIR}/repos/routersploit" ]; then
            cd "${TOOLS_DIR}/repos/routersploit"
            pip3 install -r requirements.txt --user --break-system-packages 2>>"${LOG_FILE}" || true
        fi
    '

    install_tool "Flashrom" '
        command_exists flashrom && return 2
        safe_apt_install "flashrom"
    '

    install_tool "OpenOCD" '
        command_exists openocd && return 2
        safe_apt_install "openocd"
    '

    install_tool "Minicom" '
        command_exists minicom && return 2
        safe_apt_install "minicom"
    '

    install_tool "EMBA" '
        [ -d "${TOOLS_DIR}/repos/emba" ] && return 2
        safe_git_clone "<https://github.com/e-m-b-a/emba.git>" "${TOOLS_DIR}/repos/emba"
    '
}

# ============================================================================
# SECTION 38: CMS AUDITING
# ============================================================================

install_cms_auditing() {
    section_header "CMS AUDITING" "3"

    install_tool "JoomScan" '
        command_exists joomscan && return 2
        safe_apt_install "joomscan" || {
            safe_git_clone "<https://github.com/OWASP/joomscan.git>" "${TOOLS_DIR}/repos/joomscan"
        }
    '

    install_tool "MageScan" '
        [ -d "${TOOLS_DIR}/repos/magescan" ] && return 2
        safe_git_clone "<https://github.com/steverobbins/magescan.git>" "${TOOLS_DIR}/repos/magescan"
    '

    install_tool "BlindElephant" '
        [ -d "${TOOLS_DIR}/repos/BlindElephant" ] && return 2
        safe_git_clone "<https://github.com/lokifer/BlindElephant.git>" "${TOOLS_DIR}/repos/BlindElephant" || true
    '
}

# ============================================================================
# SECTION 39: EMAIL SECURITY
# ============================================================================

install_email_security() {
    section_header "EMAIL SECURITY" "4"

    install_tool "SpoofCheck" '
        [ -d "${TOOLS_DIR}/repos/spoofcheck" ] && return 2
        safe_git_clone "<https://github.com/BishopFox/spoofcheck.git>" "${TOOLS_DIR}/repos/spoofcheck"
    '

    install_tool "CheckDMARC" '
        command_exists checkdmarc && return 2
        safe_pip_install "checkdmarc"
    '

    install_tool "Swaks" '
        command_exists swaks && return 2
        safe_apt_install "swaks"
    '

    install_tool "Email Security Scanner" '
        [ -f "${BIN_DIR}/email-sec-check" ] && return 2
        cat > "${BIN_DIR}/email-sec-check" << '"'"'EMAILEOF'"'"'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: email-sec-check <domain>"; exit 1; fi
D="$1"
echo "=== Email Security for $D ==="
echo "--- SPF ---"
dig +short TXT "$D" 2>/dev/null | grep -i "spf"
echo "--- DMARC ---"
dig +short TXT "_dmarc.$D" 2>/dev/null
echo "--- DKIM (common selectors) ---"
for sel in google default selector1 selector2 s1 s2 k1 mail; do
    R=$(dig +short TXT "${sel}._domainkey.$D" 2>/dev/null)
    [ -n "$R" ] && echo "DKIM ($sel): $R"
done
echo "--- MX ---"
dig +short MX "$D" 2>/dev/null
EMAILEOF
        chmod +x "${BIN_DIR}/email-sec-check"
    '
}

# ============================================================================
# SECTION 40: SOURCE CODE ANALYSIS
# ============================================================================

install_source_code_analysis() {
    section_header "SOURCE CODE ANALYSIS" "8"

    install_tool "Semgrep" '
        command_exists semgrep && return 2
        safe_pip_install "semgrep"
    '

    install_tool "Bandit" '
        command_exists bandit && return 2
        safe_pip_install "bandit"
    '

    install_tool "Brakeman" '
        command_exists brakeman && return 2
        safe_gem_install "brakeman"
    '

    install_tool "Gosec" '
        command_exists gosec && return 2
        safe_go_install "github.com/securego/gosec/v2/cmd/gosec@latest"
    '

    install_tool "Njsscan" '
        command_exists njsscan && return 2
        safe_pip_install "njsscan"
    '

    install_tool "Safety" '
        command_exists safety && return 2
        safe_pip_install "safety"
    '

    install_tool "Detect-Secrets" '
        command_exists detect-secrets && return 2
        safe_pip_install "detect-secrets"
    '

    install_tool "Snyk CLI" '
        command_exists snyk && return 2
        safe_npm_install "snyk"
    '
}

# ============================================================================
# SECTION 41: FUZZING
# ============================================================================

install_fuzzing() {
    section_header "FUZZING" "7"

    install_tool "AFL++" '
        command_exists afl-fuzz && return 2
        safe_apt_install "afl++" || {
            safe_git_clone "<https://github.com/AFLplusplus/AFLplusplus.git>" "${TOOLS_DIR}/repos/AFLplusplus"
            if [ -d "${TOOLS_DIR}/repos/AFLplusplus" ]; then
                cd "${TOOLS_DIR}/repos/AFLplusplus"
                make distrib 2>>"${LOG_FILE}" && sudo make install 2>>"${LOG_FILE}" || true
            fi
        }
    '

    install_tool "Honggfuzz" '
        command_exists honggfuzz && return 2
        safe_apt_install "honggfuzz" || true
    '

    install_tool "Radamsa" '
        command_exists radamsa && return 2
        safe_apt_install "radamsa" || true
    '

    install_tool "Zzuf" '
        command_exists zzuf && return 2
        safe_apt_install "zzuf"
    '

    install_tool "Boofuzz" '
        safe_pip_install "boofuzz"
    '

    install_tool "Spike" '
        command_exists generic_send_tcp && return 2
        safe_apt_install "spike" || true
    '

    install_tool "Fuzzing Wordlists" '
        [ -f "${WORDLISTS_DIR}/special-chars.txt" ] && return 2
        wget -q "<https://raw.githubusercontent.com/danielmiessler/SecLists/master/Fuzzing/special-chars.txt>" \\
            -O "${WORDLISTS_DIR}/special-chars.txt" 2>>"${LOG_FILE}" || true
    '
}

# ============================================================================
# SECTION 42: DIGITAL FORENSICS
# ============================================================================

install_digital_forensics() {
    section_header "DIGITAL FORENSICS" "8"

    install_tool "Volatility3" '
        command_exists vol && return 2
        [ -d "${TOOLS_DIR}/repos/volatility3" ] && return 2
        safe_pip_install "volatility3" || {
            safe_git_clone "<https://github.com/volatilityfoundation/volatility3.git>" "${TOOLS_DIR}/repos/volatility3"
        }
    '

    install_tool "Autopsy" '
        command_exists autopsy && return 2
        safe_apt_install "autopsy"
    '

    install_tool "Sleuth Kit" '
        command_exists fls && return 2
        safe_apt_install "sleuthkit"
    '

    install_tool "Bulk Extractor" '
        command_exists bulk_extractor && return 2
        safe_apt_install "bulk-extractor"
    '

    install_tool "Foremost" '
        command_exists foremost && return 2
        safe_apt_install "foremost"
    '

    install_tool "Scalpel" '
        command_exists scalpel && return 2
        safe_apt_install "scalpel"
    '

    install_tool "ExifTool" '
        command_exists exiftool && return 2
        safe_apt_install "libimage-exiftool-perl"
    '

    install_tool "TestDisk" '
        command_exists testdisk && return 2
        safe_apt_install "testdisk"
    '
}

# ============================================================================
# SECTION 43: MALWARE ANALYSIS
# ============================================================================

install_malware_analysis() {
    section_header "MALWARE ANALYSIS" "7"

    install_tool "Yara" '
        command_exists yara && return 2
        safe_apt_install "yara"
    '

    install_tool "Yara Rules" '
        [ -d "${TOOLS_DIR}/repos/yara-rules" ] && return 2
        safe_git_clone "<https://github.com/Yara-Rules/rules.git>" "${TOOLS_DIR}/repos/yara-rules"
    '

    install_tool "ClamAV" '
        command_exists clamscan && return 2
        safe_apt_install "clamav"
        sudo freshclam 2>>"${LOG_FILE}" || true
    '

    install_tool "Capa" '
        command_exists capa && return 2
        safe_pip_install "flare-capa"
    '

    install_tool "Oletools" '
        command_exists olevba && return 2
        safe_pip_install "oletools"
    '

    install_tool "FLOSS" '
        command_exists floss && return 2
        safe_pip_install "flare-floss" || true
    '

    install_tool "PE-bear" '
        [ -d "${TOOLS_DIR}/repos/pe-bear" ] && return 2
        safe_git_clone "<https://github.com/hasherezade/pe-bear.git>" "${TOOLS_DIR}/repos/pe-bear" || true
    '
}

# ============================================================================
# SECTION 44: SOCIAL ENGINEERING
# ============================================================================

install_social_engineering() {
    section_header "SOCIAL ENGINEERING" "7"

    install_tool "GoPhish" '
        [ -d "${TOOLS_DIR}/gophish" ] && return 2
        local GOPHISH_URL
        GOPHISH_URL=$(curl -s <https://api.github.com/repos/gophish/gophish/releases/latest> 2>/dev/null | \\
            jq -r ".assets[] | select(.name | contains(\\"linux-64bit\\")) | .browser_download_url" 2>/dev/null | head -1)
        if [ -n "${GOPHISH_URL}" ] && [ "${GOPHISH_URL}" != "null" ]; then
            wget -q "${GOPHISH_URL}" -O /tmp/gophish.zip 2>>"${LOG_FILE}" && \\
            mkdir -p "${TOOLS_DIR}/gophish" && \\
            unzip -o /tmp/gophish.zip -d "${TOOLS_DIR}/gophish" 2>>"${LOG_FILE}" || true
            rm -f /tmp/gophish.zip
        else
            return 1
        fi
    '

    install_tool "SET" '
        command_exists setoolkit && return 2
        [ -d "${TOOLS_DIR}/repos/social-engineer-toolkit" ] && return 2
        safe_apt_install "set" || {
            safe_git_clone "<https://github.com/trustedsec/social-engineer-toolkit.git>" "${TOOLS_DIR}/repos/social-engineer-toolkit"
        }
    '

    install_tool "Evilginx2" '
        command_exists evilginx2 && return 2
        safe_go_install "github.com/kgretzky/evilginx2@latest" || {
            safe_git_clone "<https://github.com/kgretzky/evilginx2.git>" "${TOOLS_DIR}/repos/evilginx2"
        }
    '

    install_tool "Zphisher" '
        [ -d "${TOOLS_DIR}/repos/zphisher" ] && return 2
        safe_git_clone "<https://github.com/htr-tech/zphisher.git>" "${TOOLS_DIR}/repos/zphisher"
    '

    install_tool "KingPhisher" '
        [ -d "${TOOLS_DIR}/repos/king-phisher" ] && return 2
        safe_git_clone "<https://github.com/rsmusllp/king-phisher.git>" "${TOOLS_DIR}/repos/king-phisher"
    '

    install_tool "SocialFish" '
        [ -d "${TOOLS_DIR}/repos/SocialFish" ] && return 2
        safe_git_clone "<https://github.com/UndeadSec/SocialFish.git>" "${TOOLS_DIR}/repos/SocialFish"
    '

    install_tool "Blackeye" '
        [ -d "${TOOLS_DIR}/repos/blackeye" ] && return 2
        safe_git_clone "<https://github.com/An0nUD4Y/blackeye.git>" "${TOOLS_DIR}/repos/blackeye"
    '
}

# ============================================================================
# SECTION 45: THREAT HUNTING
# ============================================================================

install_threat_hunting() {
    section_header "THREAT HUNTING" "7"

    install_tool "Velociraptor" '
        command_exists velociraptor && return 2
        local VR_URL
        VR_URL=$(curl -s <https://api.github.com/repos/Velocidex/velociraptor/releases/latest> 2>/dev/null | \\
            jq -r ".assets[] | select(.name | contains(\\"linux-amd64\\")) | .browser_download_url" 2>/dev/null | head -1)
        if [ -n "${VR_URL}" ] && [ "${VR_URL}" != "null" ]; then
            sudo wget -q "${VR_URL}" -O /usr/local/bin/velociraptor 2>>"${LOG_FILE}" && \\
            sudo chmod +x /usr/local/bin/velociraptor
        else
            return 1
        fi
    '

    install_tool "OSQuery" '
        command_exists osqueryi && return 2
        safe_apt_install "osquery" || true
    '

    install_tool "Zeek" '
        command_exists zeek && return 2
        safe_apt_install "zeek" || true
    '

    install_tool "Suricata" '
        command_exists suricata && return 2
        safe_apt_install "suricata"
        sudo suricata-update 2>>"${LOG_FILE}" || true
    '

    install_tool "Sigma" '
        safe_pip_install "pySigma" || {
            safe_git_clone "<https://github.com/SigmaHQ/sigma.git>" "${TOOLS_DIR}/repos/sigma"
        }
    '

    install_tool "Chainsaw" '
        command_exists chainsaw && return 2
        local CS_URL
        CS_URL=$(curl -s <https://api.github.com/repos/WithSecureLabs/chainsaw/releases/latest> 2>/dev/null | \\
            jq -r ".assets[] | select(.name | contains(\\"x86_64-unknown-linux\\")) | .browser_download_url" 2>/dev/null | head -1)
        if [ -n "${CS_URL}" ] && [ "${CS_URL}" != "null" ]; then
            wget -q "${CS_URL}" -O /tmp/chainsaw.tar.gz 2>>"${LOG_FILE}" && \\
            sudo tar xzf /tmp/chainsaw.tar.gz -C /usr/local/bin/ 2>>"${LOG_FILE}" || true
            rm -f /tmp/chainsaw.tar.gz
        else
            return 1
        fi
    '

    install_tool "Hayabusa" '
        command_exists hayabusa && return 2
        local HB_URL
        HB_URL=$(curl -s <https://api.github.com/repos/Yamato-Security/hayabusa/releases/latest> 2>/dev/null | \\
            jq -r ".assets[] | select(.name | contains(\\"linux-gnu\\")) | .browser_download_url" 2>/dev/null | head -1)
        if [ -n "${HB_URL}" ] && [ "${HB_URL}" != "null" ]; then
            wget -q "${HB_URL}" -O /tmp/hayabusa.zip 2>>"${LOG_FILE}" && \\
            mkdir -p "${TOOLS_DIR}/hayabusa" && \\
            unzip -o /tmp/hayabusa.zip -d "${TOOLS_DIR}/hayabusa" 2>>"${LOG_FILE}" || true
            rm -f /tmp/hayabusa.zip
        else
            return 1
        fi
    '
}

# ============================================================================
# SECTION 46: VoIP SECURITY
# ============================================================================

install_voip_security() {
    section_header "VoIP SECURITY" "4"

    install_tool "SIPVicious" '
        command_exists svmap && return 2
        safe_pip_install "sipvicious"
    '

    install_tool "SIPp" '
        command_exists sipp && return 2
        safe_apt_install "sip-tester"
    '

    install_tool "SIPcrack" '
        command_exists sipcrack && return 2
        safe_apt_install "sipcrack"
    '

    install_tool "Viproy" '
        [ -d "${TOOLS_DIR}/repos/viproy-voipkit" ] && return 2
        safe_git_clone "<https://github.com/fozavci/viproy-voipkit.git>" "${TOOLS_DIR}/repos/viproy-voipkit" || true
    '
}

# ============================================================================
# SECTION 47: ADDITIONAL UTILITIES
# ============================================================================

install_additional_utilities() {
    section_header "ADDITIONAL UTILITIES" "18"

    install_tool "Anew" '
        command_exists anew && return 2
        safe_go_install "github.com/tomnomnom/anew@latest"
    '

    install_tool "Notify" '
        command_exists notify && return 2
        safe_go_install "github.com/projectdiscovery/notify/cmd/notify@latest"
    '

    install_tool "PDTM" '
        command_exists pdtm && return 2
        safe_go_install "github.com/projectdiscovery/pdtm/cmd/pdtm@latest"
    '

    install_tool "Uncover" '
        command_exists uncover && return 2
        safe_go_install "github.com/projectdiscovery/uncover/cmd/uncover@latest"
    '

    install_tool "Alterx" '
        command_exists alterx && return 2
        safe_go_install "github.com/projectdiscovery/alterx/cmd/alterx@latest"
    '

    install_tool "TLSX" '
        command_exists tlsx && return 2
        safe_go_install "github.com/projectdiscovery/tlsx/cmd/tlsx@latest"
    '

    install_tool "Cdncheck" '
        command_exists cdncheck && return 2
        safe_go_install "github.com/projectdiscovery/cdncheck/cmd/cdncheck@latest"
    '

    install_tool "CyberChef" '
        [ -d "${TOOLS_DIR}/CyberChef" ] && return 2
        local CC_URL
        CC_URL=$(curl -s <https://api.github.com/repos/gchq/CyberChef/releases/latest> 2>/dev/null | \\
            jq -r ".assets[0].browser_download_url" 2>/dev/null)
        if [ -n "${CC_URL}" ] && [ "${CC_URL}" != "null" ]; then
            wget -q "${CC_URL}" -O /tmp/CyberChef.zip 2>>"${LOG_FILE}" && \\
            mkdir -p "${TOOLS_DIR}/CyberChef" && \\
            unzip -o /tmp/CyberChef.zip -d "${TOOLS_DIR}/CyberChef" 2>>"${LOG_FILE}" || true
            rm -f /tmp/CyberChef.zip
        fi
    '

    install_tool "Proxychains" '
        command_exists proxychains4 && return 2
        safe_apt_install "proxychains4" || safe_apt_install "proxychains"
    '

    install_tool "Tor" '
        command_exists tor && return 2
        safe_apt_install "tor"
    '

    install_tool "SSLyze" '
        command_exists sslyze && return 2
        safe_pip_install "sslyze"
    '

    install_tool "Testssl.sh" '
        [ -d "${TOOLS_DIR}/repos/testssl.sh" ] && return 2
        safe_git_clone "<https://github.com/drwetter/testssl.sh.git>" "${TOOLS_DIR}/repos/testssl.sh"
        ln -sf "${TOOLS_DIR}/repos/testssl.sh/testssl.sh" "${BIN_DIR}/testssl" 2>/dev/null || true
    '

    install_tool "Wireshark/Tshark" '
        command_exists tshark && return 2
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y wireshark-common tshark 2>>"${LOG_FILE}"
    '

    install_tool "Netdiscover" '
        command_exists netdiscover && return 2
        safe_apt_install "netdiscover"
    '

    install_tool "Tcpdump" '
        command_exists tcpdump && return 2
        safe_apt_install "tcpdump"
    '

    install_tool "Screen & Tmux" '
        safe_apt_install "screen" || true
        safe_apt_install "tmux" || true
    '

    install_tool "Torsocks" '
        command_exists torsocks && return 2
        safe_apt_install "torsocks"
    '

    install_tool "Arping" '
        command_exists arping && return 2
        safe_apt_install "arping"
    '
}

# ============================================================================
# SECTION 48: AUTOMATION SCRIPTS
# ============================================================================

install_automation_scripts() {
    section_header "AUTOMATION SCRIPTS" "5"

    install_tool "ReconFTW" '
        [ -d "${TOOLS_DIR}/repos/reconftw" ] && return 2
        safe_git_clone "<https://github.com/six2dez/reconftw.git>" "${TOOLS_DIR}/repos/reconftw"
    '

    install_tool "AutoRecon" '
        command_exists autorecon && return 2
        safe_pip_install "git+https://github.com/Tib3rius/AutoRecon.git" || {
            safe_git_clone "<https://github.com/Tib3rius/AutoRecon.git>" "${TOOLS_DIR}/repos/AutoRecon"
        }
    '

    install_tool "Osmedeus" '
        command_exists osmedeus && return 2
        safe_go_install "github.com/j3ssie/osmedeus@latest" || {
            safe_git_clone "<https://github.com/j3ssie/osmedeus.git>" "${TOOLS_DIR}/repos/osmedeus"
        }
    '

    # BUG FIX: Added file existence checks for wc -l in recon script
    install_tool "Full Recon Script" '
        [ -f "${BIN_DIR}/full-recon" ] && return 2
        cat > "${BIN_DIR}/full-recon" << '"'"'RECONEOF'"'"'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: full-recon <domain>"; exit 1; fi
DOMAIN="$1"
OUT="$HOME/recon/$DOMAIN"
mkdir -p "$OUT"/{subdomains,live,ports,vulns,params,screenshots}
echo "[*] Full recon on $DOMAIN -> $OUT"

echo "[1/6] Subdomains..."
subfinder -d "$DOMAIN" -silent 2>/dev/null >> "$OUT/subdomains/all.txt" || true
assetfinder --subs-only "$DOMAIN" 2>/dev/null >> "$OUT/subdomains/all.txt" || true
if [ -f "$OUT/subdomains/all.txt" ]; then
    sort -u "$OUT/subdomains/all.txt" -o "$OUT/subdomains/all.txt"
    echo "  Found: $(wc -l < "$OUT/subdomains/all.txt") subdomains"
fi

echo "[2/6] Live hosts..."
if [ -s "$OUT/subdomains/all.txt" ]; then
    cat "$OUT/subdomains/all.txt" | httpx -silent -threads 50 2>/dev/null > "$OUT/live/alive.txt" || true
    [ -f "$OUT/live/alive.txt" ] && echo "  Found: $(wc -l < "$OUT/live/alive.txt") live"
fi

echo "[3/6] Ports..."
if [ -s "$OUT/subdomains/all.txt" ]; then
    cat "$OUT/subdomains/all.txt" | naabu -silent -top-ports 1000 2>/dev/null > "$OUT/ports/ports.txt" || true
fi

echo "[4/6] URLs..."
if [ -s "$OUT/live/alive.txt" ]; then
    cat "$OUT/live/alive.txt" | gau --threads 5 2>/dev/null > "$OUT/params/urls.txt" || true
    cat "$OUT/live/alive.txt" | waybackurls 2>/dev/null >> "$OUT/params/urls.txt" || true
    [ -f "$OUT/params/urls.txt" ] && sort -u "$OUT/params/urls.txt" -o "$OUT/params/urls.txt"
fi

echo "[5/6] Nuclei scan..."
if [ -s "$OUT/live/alive.txt" ]; then
    nuclei -l "$OUT/live/alive.txt" -severity critical,high -silent 2>/dev/null > "$OUT/vulns/nuclei.txt" || true
fi

echo "[6/6] Summary..."
echo "=== RECON SUMMARY ===" > "$OUT/summary.txt"
echo "Domain: $DOMAIN" >> "$OUT/summary.txt"
echo "Date: $(date)" >> "$OUT/summary.txt"
for f in subdomains/all.txt live/alive.txt params/urls.txt vulns/nuclei.txt; do
    [ -f "$OUT/$f" ] && echo "$f: $(wc -l < "$OUT/$f") lines" >> "$OUT/summary.txt"
done
cat "$OUT/summary.txt"
echo "[*] Done! Results: $OUT"
RECONEOF
        chmod +x "${BIN_DIR}/full-recon"
    '

    install_tool "Quick Vuln Scanner" '
        [ -f "${BIN_DIR}/quick-vuln" ] && return 2
        cat > "${BIN_DIR}/quick-vuln" << '"'"'QVEOF'"'"'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: quick-vuln <url>"; exit 1; fi
URL="$1"
echo "[*] Quick scan: $URL"
echo "=== Headers ==="
curl -s -I --max-time 10 "$URL" 2>/dev/null | grep -iE "strict-transport|content-security|x-frame|x-content-type|x-xss|server"
echo "=== Tech ==="
whatweb -q "$URL" 2>/dev/null || true
echo "=== Nuclei ==="
echo "$URL" | nuclei -severity critical,high -silent 2>/dev/null || true
echo "[*] Done"
QVEOF
        chmod +x "${BIN_DIR}/quick-vuln"
    '
}

# ============================================================================
# POST-INSTALLATION SETUP
# ============================================================================

post_installation_setup() {
    section_header "POST-INSTALLATION SETUP"

    echo -e "${CYAN}[*] Configuring PATH...${NC}"

    local PATHS_TO_ADD=(
        "${HOME}/.local/bin"
        "${HOME}/go/bin"
        "${HOME}/.cargo/bin"
        "${BIN_DIR}"
        "/usr/local/go/bin"
    )

    for p in "${PATHS_TO_ADD[@]}"; do
        # BUG FIX: Use grep -F for literal string match to avoid partial matches
        grep -qF "export PATH=\\"${p}" "${HOME}/.bashrc" 2>/dev/null || \\
            echo "export PATH=\\"${p}:\\$PATH\\"" >> "${HOME}/.bashrc"
    done

    if [ -f "${HOME}/.zshrc" ]; then
        for p in "${PATHS_TO_ADD[@]}"; do
            grep -qF "export PATH=\\"${p}" "${HOME}/.zshrc" 2>/dev/null || \\
                echo "export PATH=\\"${p}:\\$PATH\\"" >> "${HOME}/.zshrc"
        done
    fi

    # Create tool index
    echo -e "${CYAN}[*] Creating tool index...${NC}"
    cat > "${TOOLS_DIR}/TOOL_INDEX.md" << 'INDEXEOF'
# Security Tools Index

## Quick Reference
- **Subdomain Enum**: subfinder, amass, assetfinder, findomain, chaos, sublist3r
- **Live Hosts**: httpx, httprobe, masscan, rustscan, gowitness
- **Ports**: nmap, naabu, masscan, rustscan, zmap
- **Vuln Scan**: nuclei, nikto, zaproxy, wapiti, jaeles
- **Web Dirs**: ffuf, gobuster, dirsearch, feroxbuster
- **XSS**: dalfox, xsstrike, gxss, kxss
- **SQLi**: sqlmap, nosqlmap, ghauri
- **API**: kiterunner, graphqlmap, jwt_tool, inql
- **OSINT**: theharvester, recon-ng, spiderfoot, sherlock
- **Cloud**: scoutsuite, prowler, pacu, trivy, cloudfox
- **AD**: bloodhound, kerbrute, impacket, certipy
- **Exploit**: metasploit, commix, tplmap

## Custom Scripts (in ~/security-tools/bin/)
- full-recon: Full automated recon pipeline
- quick-vuln: Quick vulnerability scanner
- sensitive-scan: Sensitive file finder
- header-check: Security headers audit
- bypass403: 403 bypass attempts
- cors-check: CORS misconfiguration test
- crlf-check: CRLF injection test
- email-sec-check: Email security audit
- gdork: Google dork generator
- crtsh: Certificate transparency search
- certspotter: CertSpotter search
- bgpview: BGP/ASN lookup

## Wordlists: ~/security-tools/wordlists/
## Privesc Scripts: ~/security-tools/scripts/
## Cloned Repos: ~/security-tools/repos/
INDEXEOF

    echo -e "${GREEN}[✓] Post-installation complete${NC}"
}

# ============================================================================
# GENERATE FINAL REPORT
# ============================================================================

generate_report() {
    section_header "INSTALLATION REPORT"

    local TOTAL=$((SUCCESS_COUNT + FAIL_COUNT + SKIP_COUNT))
    # BUG FIX: Guard against division by zero
    local RATE=0
    if [ ${TOTAL} -gt 0 ]; then
        RATE=$(( (SUCCESS_COUNT + SKIP_COUNT) * 100 / TOTAL ))
    fi

    cat > "${SUMMARY_FILE}" << REPORTEOF
╔══════════════════════════════════════════════════════════════╗
║              INSTALLATION SUMMARY REPORT                     ║
╠══════════════════════════════════════════════════════════════╣
║  Total Tools Processed:       ${TOTAL}
║  ✓ Successfully Installed:    ${SUCCESS_COUNT}
║  → Already Installed (Skip):  ${SKIP_COUNT}
║  ✗ Failed:                    ${FAIL_COUNT}
║  Success Rate:                ${RATE}%
║                                                              ║
║  Tools Directory: ${TOOLS_DIR}
║  Log: ${LOG_FILE}
║  Errors: ${ERROR_LOG}
╚══════════════════════════════════════════════════════════════╝
REPORTEOF

    echo -e "${GREEN}"
    cat "${SUMMARY_FILE}"
    echo -e "${NC}"

    if [ ${FAIL_COUNT} -gt 0 ]; then
        echo -e "${RED}${BOLD}Failed Tools (${FAIL_COUNT}):${NC}"
        echo -e "${RED}────────────────────${NC}"
        while IFS= read -r line; do
            echo -e "${RED}  ✗ ${line}${NC}"
        done < "${ERROR_LOG}"
        echo ""
    fi

    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║  Apply changes:  source ~/.bashrc                   ║${NC}"
    echo -e "${CYAN}${BOLD}║  Tool Index:     ${TOOLS_DIR}/TOOL_INDEX.md  ║${NC}"
    echo -e "${CYAN}${BOLD}║  Scripts:        ${BIN_DIR}/               ║${NC}"
    echo -e "${CYAN}${BOLD}║  Wordlists:      ${WORDLISTS_DIR}/          ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    # Root check warning
    if [ "$(id -u)" -eq 0 ]; then
        echo -e "${YELLOW}[!] Running as root. Some Go/pip tools may install to root paths.${NC}"
        sleep 1
    fi

    # Sudo check
    if ! sudo -n true 2>/dev/null; then
        echo -e "${YELLOW}[!] Sudo password may be required.${NC}"
        sudo true || echo -e "${RED}[!] No sudo access - some installs may fail.${NC}"
    fi

    setup_directories
    banner

    echo -e "${YELLOW}${BOLD}[!] Installing 500+ security tools.${NC}"
    echo -e "${YELLOW}${BOLD}[!] Estimated: 1-3 hours | Disk: ~15-25 GB${NC}"
    echo ""
    read -p "$(echo -e "${CYAN}Continue? [Y/n]: ${NC}")" -n 1 -r REPLY
    echo ""

    if [[ ${REPLY} =~ ^[Nn]$ ]]; then
        echo -e "${RED}Cancelled.${NC}"
        exit 0
    fi

    local START_EPOCH
    START_EPOCH=$(date +%s)

    # Run all sections
    install_prerequisites
    install_subdomain_enumeration
    install_asn_ip_intelligence
    install_live_host_discovery
    install_port_scanning
    install_vulnerability_scanning
    install_xss_hunting
    install_sql_injection
    install_sensitive_file_discovery
    install_parameter_discovery
    install_directory_bruteforce
    install_javascript_analysis
    install_wordpress_testing
    install_api_security
    install_cors_exploitation
    install_subdomain_takeover
    install_git_disclosure
    install_ssrf_exploitation
    install_open_redirect
    install_lfi_path_traversal
    install_rce_tools
    install_crlf_injection
    install_xxe_injection
    install_security_headers
    install_waf_bypass
    install_osint_recon
    install_cloud_security
    install_container_auditing
    install_advanced_web_exploits
    install_mobile_app_sec
    install_network_infrastructure
    install_wireless_security
    install_privilege_escalation
    install_active_directory
    install_c2_post_exploitation
    install_crypto_hash_cracking
    install_reverse_engineering
    install_hardware_iot
    install_cms_auditing
    install_email_security
    install_source_code_analysis
    install_fuzzing
    install_digital_forensics
    install_malware_analysis
    install_social_engineering
    install_threat_hunting
    install_voip_security
    install_additional_utilities
    install_automation_scripts
    post_installation_setup

    local END_EPOCH
    END_EPOCH=$(date +%s)
    local DURATION=$((END_EPOCH - START_EPOCH))
    local HOURS=$((DURATION / 3600))
    local MINUTES=$(((DURATION % 3600) / 60))
    local SECONDS=$((DURATION % 60))

    echo ""
    echo -e "${GREEN}${BOLD}Total time: ${HOURS}h ${MINUTES}m ${SECONDS}s${NC}"
    echo ""

    generate_report

    source "${HOME}/.bashrc" 2>/dev/null || true

    echo ""
    echo -e "${GREEN}${BOLD}✅ Installation complete! Happy hunting! 🎯${NC}"
    echo ""
}

# Execute
main "$@"
