<div align="center">

# 🛡️ Ultimate Security Tools Installer

### The Most Comprehensive Automated Security Tools Installation Framework

[![Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Tools](https://img.shields.io/badge/Tools-500+-red?style=for-the-badge&logo=kalilinux&logoColor=white)](.)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen.svg?style=for-the-badge)](pulls)
[![Maintenance](https://img.shields.io/badge/Maintained-Yes-blue.svg?style=for-the-badge)](.)

<img src="https://raw.githubusercontent.com/github/explore/main/topics/security/security.png" width="120" alt="Security">

**Install 500+ penetration testing, bug bounty, red teaming & security auditing tools with a single command.**

**Zero interruptions. Full error handling. Every failure is logged, never stops.**

[Features](#-features) •
[Quick Start](#-quick-start) •
[Tool Categories](#-tool-categories) •
[Custom Scripts](#-custom-scripts-included) •
[Screenshots](#-screenshots) •
[FAQ](#-faq)

---

<img width="800" alt="banner" src="<img width="596" height="219" alt="image" src="https://github.com/user-attachments/assets/5388ca9e-2e6d-4891-9ce6-fa9c0b5f0b40" />
">

</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Tool Categories](#-tool-categories)
- [Complete Tool List](#-complete-tool-list)
- [Custom Scripts Included](#-custom-scripts-included)
- [Directory Structure](#-directory-structure)
- [Logging & Reports](#-logging--reports)
- [Wordlists](#-wordlists-included)
- [Post-Installation](#-post-installation)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)
- [Contributing](#-contributing)
- [Legal Disclaimer](#%EF%B8%8F-legal-disclaimer)
- [License](#-license)
- [Star History](#-star-history)

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🔧 Installation Engine
- **500+ tools** across 48 security categories
- **Zero-interruption** — errors are caught and logged, never stops
- **Smart skip detection** — already installed tools are skipped
- **Multi-package manager** support (apt, pip, go, cargo, gem, npm, snap)
- **Automatic dependency resolution**
- **Architecture detection** (x86_64, ARM64)

</td>
<td width="50%">

### 📊 Reporting & Logging
- **Color-coded output** (✓ green, ✗ red, → yellow)
- **Separate log files** for success, errors, and full trace
- **Final summary report** with success rates
- **Installation timer** with elapsed time tracking
- **Tool index** auto-generated after installation
- **Per-tool error messages** for debugging

</td>
</tr>
<tr>
<td>

### 🚀 Automation
- **10+ custom scripts** for common workflows
- **Full recon automation** pipeline included
- **One-liner cheatsheet** generated
- **PATH auto-configuration** for bash and zsh
- **Wordlist downloads** (SecLists, Assetnote, etc.)

</td>
<td>

### 🛡️ Coverage
- Bug Bounty • Pentesting • Red Teaming
- Cloud Security • Container Auditing
- Active Directory • Network Infrastructure
- Forensics • Malware Analysis • OSINT
- Wireless • IoT • Mobile • VoIP
- Reverse Engineering • Cryptography

</td>
</tr>
</table>

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/ultimate-security-tools-installer.git

# Navigate to the directory
cd ultimate-security-tools-installer

# Make executable
chmod +x install.sh

# Run the installer
sudo ./install.sh
```

> **That's it.** Sit back and let it install 500+ tools. Errors won't stop execution.

---

## 📦 Requirements

| Requirement | Details |
|------------|---------|
| **OS** | Ubuntu 20.04+, Debian 11+, Kali Linux, Parrot OS |
| **RAM** | 4 GB minimum, 8 GB recommended |
| **Disk Space** | 15–25 GB free space |
| **Internet** | Stable broadband connection |
| **Privileges** | `sudo` access required |
| **Time** | 1–3 hours depending on connection speed |

### Tested On

| Distribution | Version | Status |
|-------------|---------|--------|
| Kali Linux | 2024.x | ✅ Fully Tested |
| Parrot OS | 6.x | ✅ Fully Tested |
| Ubuntu | 22.04 / 24.04 | ✅ Fully Tested |
| Debian | 11 / 12 | ✅ Fully Tested |
| Arch Linux | Latest | ⚠️ Partial (apt tools skip) |
| WSL2 Ubuntu | 22.04 | ✅ Fully Tested |

---

## 📥 Installation

### Method 1: Git Clone (Recommended)

```bash
git clone https://github.com/yourusername/ultimate-security-tools-installer.git
cd ultimate-security-tools-installer
chmod +x install.sh
sudo ./install.sh
```

### Method 2: One-Liner

```bash
curl -sSL https://raw.githubusercontent.com/yourusername/ultimate-security-tools-installer/main/install.sh | sudo bash
```

### Method 3: Wget

```bash
wget -qO install.sh https://raw.githubusercontent.com/yourusername/ultimate-security-tools-installer/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

### After Installation

```bash
# Apply PATH changes
source ~/.bashrc

# Verify installation
subfinder -version
nuclei -version
httpx -version
```

---

## 📂 Tool Categories

The installer covers **48 security categories** with **500+ tools**:

<details>
<summary><b>🔍 1. Subdomain Enumeration (20 tools)</b></summary>

| Tool | Type | Description |
|------|------|-------------|
| Subfinder | Go | Fast passive subdomain discovery |
| Amass | Go | In-depth attack surface mapping |
| Assetfinder | Go | Find domains and subdomains |
| Findomain | Rust | Cross-platform subdomain finder |
| Chaos | Go | ProjectDiscovery Chaos integration |
| Sublist3r | Python | Fast subdomain enumeration |
| Knockpy | Python | Subdomain scan with dictionary attack |
| DNSRecon | Python | DNS enumeration tool |
| Fierce | Python | DNS reconnaissance tool |
| MassDNS | C | High-performance DNS resolver |
| PureDNS | Go | Fast domain resolver and bruteforcer |
| ShuffleDNS | Go | MassDNS wrapper for active bruteforcing |
| GitHub-Subdomains | Go | Find subdomains on GitHub |
| OneForAll | Python | All-in-one subdomain collection |
| Sudomy | Bash | Subdomain enumeration & analysis |
| crt.sh | Script | Certificate transparency search |
| CertSpotter | Script | SSL certificate monitoring |
| Shodan CLI | Python | Shodan command-line interface |
| Censys CLI | Python | Censys search engine CLI |
| DNSgen | Python | Generate domain name permutations |

</details>

<details>
<summary><b>🌐 2. ASN & IP Intelligence (10 tools)</b></summary>

| Tool | Type | Description |
|------|------|-------------|
| ASNMap | Go | Map ASN to CIDR ranges |
| Metabigor | Go | OSINT tool for ASN and IP |
| BGPView | Script | BGP/ASN lookup |
| IPInfo CLI | Binary | IP address information |
| WHOIS | System | Domain registration lookup |
| IP2Location | Python | IP geolocation |
| Mapcidr | Go | CIDR range operations |
| DNSx | Go | Fast DNS toolkit |
| Nrich | Binary | Quickly analyze IPs |

</details>

<details>
<summary><b>🖥️ 3. Live Host Discovery (12 tools)</b></summary>

| Tool | Type | Description |
|------|------|-------------|
| httpx | Go | Fast HTTP toolkit |
| httprobe | Go | Probe for working HTTP servers |
| Masscan | C | TCP port scanner (fastest) |
| RustScan | Rust | Modern port scanner |
| Aquatone | Go | Visual inspection of websites |
| GoWitness | Go | Website screenshot utility |
| EyeWitness | Python | Website screenshot and info |
| WhatWeb | Ruby | Website fingerprinting |
| Webanalyze | Go | Technology detection |
| ZGrab2 | Go | Application layer scanner |
| Nmap | C | Network exploration tool |

</details>

<details>
<summary><b>🔌 4. Port Scanning (7 tools)</b></summary>

| Tool | Type | Description |
|------|------|-------------|
| Nmap | C | The industry standard |
| Naabu | Go | Fast port scanner |
| Masscan | C | Fastest TCP scanner |
| RustScan | Rust | Adaptive port scanner |
| ZMap | C | Internet-wide scanner |
| Smap | Go | Shodan-based port scanner |
| Unicornscan | C | Asynchronous scanner |

</details>

<details>
<summary><b>⚡ 5. Vulnerability Scanning (10 tools)</b></summary>

| Tool | Type | Description |
|------|------|-------------|
| Nuclei | Go | Template-based vulnerability scanner |
| Nuclei Templates | YAML | 7000+ vulnerability templates |
| Nikto | Perl | Web server scanner |
| OWASP ZAP | Java | Web application security scanner |
| Wapiti | Python | Web application vulnerability scanner |
| Skipfish | C | Active web application recon |
| Jaeles | Go | Automation testing framework |
| Sn1per | Bash | Automated pentest framework |
| OpenVAS | C | Full vulnerability scanner |
| Arachni | Ruby | Web application security scanner |

</details>

<details>
<summary><b>💉 6. XSS Hunting (11 tools)</b></summary>

| Tool | Type | Description |
|------|------|-------------|
| Dalfox | Go | Parameter analysis and XSS scanning |
| XSStrike | Python | Advanced XSS scanner |
| Gxss | Go | Check reflected parameters |
| Kxss | Go | XSS reflection checker |
| XSSer | Python | Automatic XSS detection |
| XSpear | Ruby | Powerfull XSS scanning |
| Freq | Go | Fast reflected XSS scanner |
| PwnXSS | Python | XSS vulnerability scanner |
| XSS-Loader | Python | XSS payload generator |
| Airixss | Go | XSS scanner |
| BruteXSS | Python | Cross-site scripting bruteforcer |

</details>

<details>
<summary><b>💾 7. SQL Injection (7 tools)</b></summary>

| Tool | Type | Description |
|------|------|-------------|
| SQLMap | Python | Automatic SQL injection tool |
| NoSQLMap | Python | NoSQL injection tool |
| Ghauri | Python | Advanced SQL injection tool |
| DSSS | Python | Damn Small SQLi Scanner |
| Blisqy | Python | Blind SQL injection exploitation |
| SleuthQL | Python | SQLi discovery tool |
| SQLiScanner | Python | Automatic SQL injection scanner |

</details>

<details>
<summary><b>📁 8. Sensitive File Discovery (7 tools)</b></summary>

| Tool | Type | Description |
|------|------|-------------|
| GF Patterns | Go | Grep pattern matching |
| Cloud Enum | Python | Cloud resource enumeration |
| S3Scanner | Python/Go | S3 bucket finder |
| TruffleHog | Python | Secret scanner |
| GitLeaks | Go | Git secret scanner |
| CloudBrute | Go | Cloud infrastructure finder |
| Sensitive Scanner | Script | Custom sensitive file finder |

</details>

<details>
<summary><b>🔑 9. Parameter Discovery (12 tools)</b></summary>

| Tool | Type | Description |
|------|------|-------------|
| Arjun | Python | HTTP parameter discovery |
| ParamSpider | Python | Parameter mining from archives |
| x8 | Rust | Hidden parameter discovery |
| GAU | Go | Get All URLs |
| Waybackurls | Go | Wayback Machine URLs |
| Hakrawler | Go | Simple web crawler |
| Katana | Go | Next-gen web crawler |
| GoSpider | Go | Fast web spider |
| Unfurl | Go | URL analysis tool |
| QSReplace | Go | Query string replacer |
| Uro | Python | URL deduplication |

</details>

<details>
<summary><b>📖 10. Directory Bruteforce (10 tools)</b></summary>

| Tool | Type | Description |
|------|------|-------------|
| ffuf | Go | Fast web fuzzer |
| Gobuster | Go | Directory/DNS/VHost busting |
| Dirsearch | Python | Web path scanner |
| Feroxbuster | Rust | Recursive content discovery |
| Dirb | C | URL bruteforcer |
| Wfuzz | Python | Web application fuzzer |
| Kiterunner | Go | API endpoint discovery |
| Photon | Python | Fast crawler for OSINT |
| Meg | Go | Fetch many URLs at once |

</details>

<details>
<summary><b>📜 11. JavaScript Analysis (10 tools)</b></summary>

| Tool | Type | Description |
|------|------|-------------|
| LinkFinder | Python | Find endpoints in JS files |
| SecretFinder | Python | Find secrets in JS files |
| GetJS | Go | Extract JavaScript sources |
| SubJS | Go | Find JS files |
| JSFScan | Bash | JS file scanner automation |
| Retire.js | Node | Vulnerable JS library detection |
| Mantra | Go | Hunt secrets in JS files |
| JSParser | Python | Parse JS files for URLs |
| Source-Map-Explorer | Node | Analyze source maps |
| JS-Beautify | Node | JavaScript beautifier |

</details>

<details>
<summary><b>📝 12. WordPress Testing (5 tools)</b></summary>

| Tool | Description |
|------|-------------|
| WPScan | WordPress vulnerability scanner |
| WPSeku | WordPress security scanner |
| Droopescan | CMS vulnerability scanner |
| CMSmap | CMS vulnerability scanner |
| CMSeek | CMS detection and exploitation |

</details>

<details>
<summary><b>🔗 13. API Security Testing (8 tools)</b></summary>

| Tool | Description |
|------|-------------|
| GraphQLmap | GraphQL exploitation |
| InQL | GraphQL security testing |
| JWT Tool | JWT token testing |
| RESTler | REST API fuzzer |
| Clairvoyance | GraphQL schema extraction |
| GraphW00f | GraphQL fingerprinting |
| Newman | Postman CLI |
| Hoppscotch CLI | API testing |

</details>

<details>
<summary><b>🌍 14–18. Web Exploitation (20+ tools)</b></summary>

| Category | Tools |
|----------|-------|
| **CORS** | Corsy, CORScanner, CORS Check Script |
| **Subdomain Takeover** | Subjack, SubOver, DNSReaper, TKO-Subs |
| **Git Disclosure** | git-dumper, GitTools, Gitleaks, GitHound |
| **SSRF** | SSRFmap, Gopherus, Interactsh |
| **Open Redirect** | OpenRedirex, Oralyzer |

</details>

<details>
<summary><b>⚔️ 19–22. Injection Attacks (15+ tools)</b></summary>

| Category | Tools |
|----------|-------|
| **LFI/Path Traversal** | dotdotpwn, LFISuite, Kadimus, Fimap |
| **RCE** | Commix, tplmap, SSTImap, Log4j Scanner, YSoSerial, PHPGGC |
| **CRLF** | CRLFuzz, CRLF Check Script |
| **XXE** | XXEinjector, XXE OOB Server |

</details>

<details>
<summary><b>🔒 23–24. Defense & Bypass (9 tools)</b></summary>

| Category | Tools |
|----------|-------|
| **Security Headers** | Shcheck, Header Scanner, CSP Evaluator |
| **WAF/403 Bypass** | WAFw00f, WhatWAF, byp4xx, WAFNinja, IdentYwaf |

</details>

<details>
<summary><b>🕵️ 25. OSINT & Recon (12 tools)</b></summary>

| Tool | Description |
|------|-------------|
| theHarvester | Email, subdomain, IP harvester |
| Recon-ng | Full-featured recon framework |
| SpiderFoot | OSINT automation tool |
| Sherlock | Social media username hunter |
| Holehe | Email to registered accounts |
| Social Analyzer | Social media analyzer |
| PhoneInfoga | Phone number OSINT |

</details>

<details>
<summary><b>☁️ 26–27. Cloud & Container Security (20 tools)</b></summary>

| Category | Tools |
|----------|-------|
| **Cloud** | ScoutSuite, Prowler, Pacu, CloudMapper, CloudFox, Trivy, AWS CLI, Steampipe |
| **Container** | Docker Bench, Grype, Kube-hunter, Kube-bench, Checkov, Terrascan, Hadolint |

</details>

<details>
<summary><b>🏢 28–34. Infrastructure & Post-Exploitation (60+ tools)</b></summary>

| Category | Key Tools |
|----------|-----------|
| **Advanced Web** | Smuggler, H2CSmuggler, WebSocket testing |
| **Mobile** | MobSF, Apktool, Jadx, Frida, Objection |
| **Network** | NetExec, Impacket, Evil-WinRM, Chisel, Responder |
| **Wireless** | Aircrack-ng, Wifite, Reaver, Bettercap, Kismet |
| **Privilege Escalation** | LinPEAS, WinPEAS, Linux Exploit Suggester, pspy |
| **Active Directory** | BloodHound, Kerbrute, Mimikatz, Certipy, Coercer |
| **C2 Frameworks** | Metasploit, Empire, Sliver, Havoc, Mythic, Villain |

</details>

<details>
<summary><b>🔐 35–37. Crypto, RE & Hardware (27 tools)</b></summary>

| Category | Key Tools |
|----------|-----------|
| **Hash Cracking** | Hashcat, John, Hydra, Medusa, Ncrack |
| **Reverse Engineering** | GDB/GEF, Radare2, Ghidra, Pwntools, ROPgadget |
| **IoT/Hardware** | Binwalk, Firmwalker, RouterSploit, OpenOCD |

</details>

<details>
<summary><b>🔬 38–46. Specialized Security (50+ tools)</b></summary>

| Category | Key Tools |
|----------|-----------|
| **CMS Auditing** | JoomScan, MageScan, BlindElephant |
| **Email Security** | SpoofCheck, CheckDMARC, Swaks |
| **Source Code** | Semgrep, Bandit, Brakeman, Gosec, Snyk |
| **Fuzzing** | AFL++, Honggfuzz, Radamsa, Boofuzz |
| **Forensics** | Volatility3, Autopsy, Sleuth Kit, Foremost |
| **Malware** | Yara, ClamAV, Capa, Oletools |
| **Social Engineering** | GoPhish, SET, Evilginx2, Zphisher |
| **Threat Hunting** | Velociraptor, OSQuery, Suricata, Sigma, Chainsaw |
| **VoIP** | SIPVicious, SIPp, SIPcrack |

</details>

<details>
<summary><b>🛠️ 47–48. Utilities & Automation (23 tools)</b></summary>

| Category | Key Tools |
|----------|-----------|
| **Utilities** | Anew, Notify, PDTM, Uncover, CyberChef, Proxychains, Tor, SSLyze |
| **Automation** | ReconFTW, AutoRecon, Osmedeus, Full Recon Script, Quick Vuln Scanner |

</details>

---

## 🔧 Custom Scripts Included

The installer creates **12 custom automation scripts** in `~/security-tools/bin/`:

| Script | Usage | Description |
|--------|-------|-------------|
| `full-recon` | `full-recon <domain>` | Complete recon pipeline (subdomains → live hosts → ports → URLs → nuclei) |
| `quick-vuln` | `quick-vuln <url>` | Quick security header + tech detection + nuclei scan |
| `sensitive-scan` | `sensitive-scan <url>` | Check for 20+ sensitive files (.env, .git, backups, etc.) |
| `header-check` | `header-check <url>` | Audit all security headers |
| `bypass403` | `bypass403 <url> <path>` | Attempt 40+ methods to bypass 403 forbidden |
| `cors-check` | `cors-check <url>` | Test for CORS misconfigurations |
| `crlf-check` | `crlf-check <url>` | Test for CRLF injection |
| `email-sec-check` | `email-sec-check <domain>` | Check SPF, DKIM, DMARC, MX, BIMI |
| `gdork` | `gdork <domain>` | Generate Google dork queries |
| `crtsh` | `crtsh <domain>` | Certificate transparency search |
| `certspotter` | `certspotter <domain>` | CertSpotter certificate search |
| `bgpview` | `bgpview <asn>` | BGP/ASN information lookup |

### Example Usage

```bash
# Full automated recon
full-recon hackerone.com

# Quick vulnerability check
quick-vuln https://example.com

# Check for sensitive files
sensitive-scan https://target.com

# 403 bypass attempts
bypass403 https://target.com admin/panel

# CORS misconfiguration check
cors-check https://api.target.com

# Email security audit
email-sec-check target.com

# Generate Google dorks
gdork target.com
```

---

## 📁 Directory Structure

```
~/security-tools/
├── bin/                    # Custom scripts & symlinks
│   ├── full-recon
│   ├── quick-vuln
│   ├── sensitive-scan
│   ├── header-check
│   ├── bypass403
│   ├── cors-check
│   ├── crlf-check
│   ├── email-sec-check
│   ├── gdork
│   ├── crtsh
│   ├── certspotter
│   └── bgpview
├── repos/                  # Cloned Git repositories
│   ├── XSStrike/
│   ├── SSRFmap/
│   ├── SecretFinder/
│   ├── LinkFinder/
│   └── ... (100+ repos)
├── scripts/                # Standalone scripts
│   ├── linpeas.sh
│   ├── winPEASany.exe
│   ├── LinEnum.sh
│   ├── les.sh
│   └── pspy64
├── wordlists/              # Downloaded wordlists
│   ├── SecLists/
│   ├── assetnote/
│   ├── lfi-payloads.txt
│   ├── xxe-payloads.txt
│   ├── cmd-injection.txt
│   ├── special-chars.txt
│   └── param-miner-wordlist.txt
├── java-tools/             # Java-based tools
│   └── ysoserial.jar
├── logs/                   # Installation logs
│   ├── install_20240101_120000.log
│   ├── errors_20240101_120000.log
│   ├── success_20240101_120000.log
│   └── summary_20240101_120000.txt
├── configs/                # Tool configurations
├── CyberChef/              # CyberChef offline
├── gophish/                # GoPhish server
├── ghidra/                 # Ghidra RE tool
├── hayabusa/               # Hayabusa log analyzer
└── TOOL_INDEX.md           # Auto-generated tool reference
```

---

## 📊 Logging & Reports

Every installation run generates **4 log files**:

| File | Contents |
|------|----------|
| `install_<timestamp>.log` | Complete installation trace with all output |
| `success_<timestamp>.log` | List of successfully installed tools |
| `errors_<timestamp>.log` | Failed tools with error messages |
| `summary_<timestamp>.txt` | Final summary report |

### Sample Summary Report

```
╔══════════════════════════════════════════════════════════════╗
║              INSTALLATION SUMMARY REPORT                     ║
╠══════════════════════════════════════════════════════════════╣
║  Total Tools Processed:       487                            ║
║  ✓ Successfully Installed:    421                            ║
║  → Already Installed (Skip):  38                             ║
║  ✗ Failed:                    28                             ║
║  Success Rate:                94%                            ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 📚 Wordlists Included

| Wordlist | Size | Source |
|----------|------|--------|
| **SecLists** | ~1 GB | Daniel Miessler's comprehensive collection |
| **Assetnote Best DNS** | ~50 MB | Best subdomain wordlist |
| **LFI Payloads** | ~50 KB | Jhaddix LFI wordlist |
| **XXE Payloads** | ~2 KB | Common XXE attack payloads |
| **Command Injection** | ~30 KB | Commix command injection list |
| **Special Characters** | ~5 KB | Fuzzing special characters |
| **ParamMiner** | ~100 KB | Parameter discovery wordlist |

---

## 🔄 Post-Installation

### Apply PATH Changes

```bash
source ~/.bashrc
# or
source ~/.zshrc
```

### Verify Key Tools

```bash
# Check Go tools
subfinder -version
nuclei -version
httpx -version
naabu -version
katana -version

# Check Python tools
sqlmap --version
wapiti --version
arjun --version

# Check System tools
nmap --version
masscan --version
hashcat --version

# Check Custom scripts
which full-recon
which bypass403
```

### Update Tools Later

```bash
# Update Go tools
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest

# Update Nuclei templates
nuclei -update-templates

# Update pip tools
pip3 install --upgrade sqlmap arjun wafw00f

# Update system tools
sudo apt update && sudo apt upgrade -y

# Re-run installer (skips already installed)
sudo ./install.sh
```

---

## 🔧 Troubleshooting

<details>
<summary><b>Go tools not found after installation</b></summary>

```bash
# Add Go to PATH
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc
```

</details>

<details>
<summary><b>pip install fails with "externally-managed-environment"</b></summary>

```bash
# The script handles this automatically with --break-system-packages
# If running manually:
pip3 install --user --break-system-packages <package>

# Or use pipx:
pipx install <package>
```

</details>

<details>
<summary><b>Permission denied errors</b></summary>

```bash
# Run with sudo
sudo ./install.sh

# Or fix Go directory permissions
sudo chown -R $USER:$USER ~/go
sudo chown -R $USER:$USER ~/security-tools
```

</details>

<details>
<summary><b>Specific tool failed to install</b></summary>

```bash
# Check the error log
cat ~/security-tools/logs/errors_*.log

# Install manually
# For Go tools:
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# For Python tools:
pip3 install --user <tool-name>

# For Apt tools:
sudo apt install <tool-name>

# Re-run installer (will skip already installed ones)
sudo ./install.sh
```

</details>

<details>
<summary><b>Disk space issues</b></summary>

```bash
# Check disk space
df -h

# Skip SecLists (largest download ~1GB)
# Edit install.sh and comment out the SecLists section

# Clean up after installation
sudo apt autoremove -y
sudo apt clean
pip3 cache purge
go clean -cache
```

</details>

<details>
<summary><b>Slow installation</b></summary>

The script downloads from many sources. To speed up:
- Use a fast internet connection
- Run during off-peak hours
- Consider a VPN closer to GitHub/PyPI servers
- Already-installed tools are automatically skipped on re-run

</details>

---

## ❓ FAQ

<details>
<summary><b>Q: Will the script stop if a tool fails to install?</b></summary>

**No.** Every tool installation is wrapped in error handling. If a tool fails, it logs the error and continues to the next tool. You'll see a complete report at the end showing what succeeded and what failed.

</details>

<details>
<summary><b>Q: Can I run it again without reinstalling everything?</b></summary>

**Yes.** The script detects already-installed tools and skips them. You'll see `[→] Tool already installed, skipping` for tools that are already present.

</details>

<details>
<summary><b>Q: Does it work on macOS?</b></summary>

**No.** This script is designed for Debian/Ubuntu-based Linux distributions. For macOS, you would need significant modifications (Homebrew instead of apt, different binary URLs, etc.).

</details>

<details>
<summary><b>Q: Is this safe to run on a production server?</b></summary>

**No.** This is designed for dedicated security testing machines. Many of these tools are offensive security tools and should only be installed on systems you own and use for authorized testing.

</details>

<details>
<summary><b>Q: How much disk space does it need?</b></summary>

Approximately **15–25 GB** for all tools, repositories, and wordlists. The largest single download is SecLists at ~1 GB.

</details>

<details>
<summary><b>Q: Can I select specific categories to install?</b></summary>

Currently, the script installs all categories. You can comment out specific `install_*` function calls in the `main()` function to skip categories you don't need.

</details>

<details>
<summary><b>Q: How do I update tools after installation?</b></summary>

Re-running the script will update Git repositories (via `git pull`) and skip already-installed binaries. For specific updates, use the package manager directly (`go install ...@latest`, `pip3 install --upgrade ...`, etc.).

</details>

---

## 🤝 Contributing

Contributions are welcome! Here's how:

### Adding a New Tool

1. Fork the repository
2. Add the tool in the appropriate section function
3. Follow this pattern:

```bash
install_tool "Tool Name" '
    command_exists toolname && return 2
    # Installation command here
    safe_go_install "github.com/author/tool@latest"
'
```

4. Update the section tool count
5. Submit a pull request

### Reporting Issues

- Check the error log: `~/security-tools/logs/errors_*.log`
- Include your OS version and architecture
- Provide the relevant log output
- Open an issue with the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md)

### Guidelines

- Every `install_tool` block must handle its own errors
- Always check if tool exists before installing (`command_exists` or directory check)
- Use `return 2` for "already installed" skipping
- Test on a clean Ubuntu 22.04 installation
- Update the README tool count when adding tools

---

## ⚠️ Legal Disclaimer

```
THIS TOOL IS PROVIDED FOR EDUCATIONAL AND AUTHORIZED SECURITY TESTING PURPOSES ONLY.

By using this installer and the tools it installs, you agree that:

1. You will only use these tools on systems you own or have explicit written
   authorization to test.

2. You understand that unauthorized access to computer systems is illegal
   in most jurisdictions.

3. The authors are not responsible for any misuse or damage caused by
   these tools.

4. You will comply with all applicable local, state, national, and
   international laws and regulations.

5. You assume all responsibility for your actions when using these tools.

UNAUTHORIZED ACCESS TO COMPUTER SYSTEMS IS A CRIMINAL OFFENSE.
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

## 📈 Star History

If you find this project useful, please consider giving it a ⭐!

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/ultimate-security-tools-installer&type=Date)](https://star-history.com/#yourusername/ultimate-security-tools-installer&Date)

---

## 🙏 Acknowledgments

This project stands on the shoulders of giants. Thanks to:

- [ProjectDiscovery](https://github.com/projectdiscovery) — Nuclei, httpx, Subfinder, Katana, and more
- [Tom Hudson (tomnomnom)](https://github.com/tomnomnom) — Assetfinder, Waybackurls, GF, Anew, and more
- [OWASP](https://owasp.org) — ZAP, JoomScan, and security standards
- [Kali Linux](https://www.kali.org) — The original security distribution
- [Daniel Miessler](https://github.com/danielmiessler) — SecLists wordlists
- All the individual tool authors and contributors

---

<div align="center">

### Built with ❤️ for the Security Community

