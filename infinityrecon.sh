
#!/bin/bash

# Load Configuration
source ./configuration.cfg

# Define directories and variables
TOOLS_DIR=~/tools
TARGETS_DIR="targets"
RECON_DIR="recon_results"
LOG_FILE="magicrecon.log"
NOTIFY_CMD="notify -silent"
DEFAULT_PROTOCOL="https://"

# Helper Functions
log_info() {
    printf "${BOLD}${GREEN}[*] $1${NORMAL}\n" | tee -a $LOG_FILE
}

log_error() {
    printf "${BOLD}${RED}[!] $1${NORMAL}\n" | tee -a $LOG_FILE
}

# Ensure required tools are installed
check_tools() {
    local tools=("python3" "subfinder" "httpx" "nuclei" "nmap" "figlet" "parallel" "gau" "hakrawler" "arjun" "dirsearch"
                  "whatweb" "theHarvester" "CloudEnum" "GitDorker" "Amass" "Waybackurls" "dnsx" "assetfinder"
                  "crt.sh" "SecurityTrails" "shodan" "masscan" "gowitness" "aquatone" "metabigor" "jaeles" "xsser"
                  "truffleHog" "gitrob" "bucket-stream" "dnsrecon" "dnsprobe" "zmap" "webanalyze" "gf" "dnsgen")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool is not installed. Please install it using ./install.sh."
            exit 1
        fi
    done
}

# Prepare environment
prepare_environment() {
    if [ ! -d "$TARGETS_DIR" ]; then
        mkdir -p "$TARGETS_DIR"
    fi
    log_info "Environment prepared."
}

# Passive Recon
passive_recon() {
    domain=$1
    url="$DEFAULT_PROTOCOL$domain"  # Combine protocol with domain for tools requiring URLs
    log_info "Starting Passive Recon for $domain"
    
    recon_dir="$TARGETS_DIR/$domain/$RECON_DIR"
    mkdir -p "$recon_dir"

    log_info "Running Passive Recon Tools in parallel..."
    parallel -j4 ::: \
        "subfinder -d $domain -silent | tee $recon_dir/subdomains.txt" \
        "whois $domain | tee $recon_dir/whois.txt" \
        "nslookup $domain | tee $recon_dir/nslookup.txt" \
        "Amass enum -d $domain | tee $recon_dir/amass.txt" \
        "Waybackurls $domain | tee $recon_dir/waybackurls.txt" \
        "assetfinder $domain | tee $recon_dir/assetfinder.txt" \
        "crt.sh $domain | tee $recon_dir/crtsh.txt" \
        "SecurityTrails $domain | tee $recon_dir/securitytrails.txt" \
        "whatweb $url | tee $recon_dir/whatweb.txt" \
        "CloudEnum -d $domain | tee $recon_dir/cloud.txt" \
        "dnsx -d $domain -silent | tee $recon_dir/dnsx.txt" \
        "GitDorker -d $domain -o $recon_dir/dorks.txt"
}

# Active Recon
active_recon() {
    domain=$1
    url="$DEFAULT_PROTOCOL$domain"
    log_info "Starting Active Recon for $domain"
    
    recon_dir="$TARGETS_DIR/$domain/$RECON_DIR"
    mkdir -p "$recon_dir"
    
    log_info "Running Active Recon Tools in parallel..."
    parallel -j4 ::: \
        "httpx -silent -u $url -o $recon_dir/httpx.txt" \
        "arjun -u $url -oT $recon_dir/parameters.txt" \
        "hakrawler -url $url | tee $recon_dir/hakrawler.txt" \
        "dirsearch -u $url -w $dictionary --format plain -o $recon_dir/dirsearch.txt" \
        "masscan -p1-65535,U:1-65535 $domain --rate=10000 -oX $recon_dir/masscan.xml" \
        "gowitness file -f $recon_dir/httpx.txt -d $recon_dir/screenshots/" \
        "aquatone -ports xlarge -out $recon_dir/aquatone"
}

# Vulnerability Scanning
vulnerability_scan() {
    domain=$1
    url="$DEFAULT_PROTOCOL$domain"
    log_info "Starting Vulnerability Scan for $domain"
    
    recon_dir="$TARGETS_DIR/$domain/$RECON_DIR"
    mkdir -p "$recon_dir"

    log_info "Running Vulnerability Tools in parallel..."
    parallel -j4 ::: \
        "nuclei -u $url -t ~/tools/nuclei-templates/ -severity low,medium,high,critical -silent -o $recon_dir/nuclei.txt" \
        "python3 ~/tools/Corsy/corsy.py -u $url | tee $recon_dir/cors.txt" \
        "gau $domain | gf xss | dalfox pipe -o $recon_dir/xss.txt" \
        "gau $domain | gf sqli | sqlmap --batch --random-agent -m $recon_dir/sqlmap.txt | tee -a $recon_dir/sqlmap_results.txt" \
        "jaeles scan -u $url -o $recon_dir/jaeles.txt" \
        "xsser --url $url -v -o $recon_dir/xsser.txt" \
        "truffleHog --repo-path $domain | tee $recon_dir/trufflehog.txt" \
        "gitrob -d $domain -o $recon_dir/gitrob.txt" \
        "metabigor net -t $domain | tee $recon_dir/metabigor.txt"
}

# Main script logic
main() {
    check_tools
    prepare_environment

    while getopts "d:pavh" opt; do
        case $opt in
            d) domain="$OPTARG" ;;
            p) passive="true" ;;
            a) active="true" ;;
            v) vulnerabilities="true" ;;
            h) 
                echo "Usage: $0 -d <domain> [-p] [-a] [-v] [-h]"
                exit 0
                ;;
            *) log_error "Invalid option"; exit 1;;
        esac
    done

    if [ -z "$domain" ]; then
        log_error "Domain is required. Use -d to specify."
        exit 1
    fi

    if [ "$passive" == "true" ]; then
        passive_recon "$domain"
    fi

    if [ "$active" == "true" ]; then
        active_recon "$domain"
    fi

    if [ "$vulnerabilities" == "true" ]; then
        vulnerability_scan "$domain"
    fi
}

# Run the script
main "$@"
