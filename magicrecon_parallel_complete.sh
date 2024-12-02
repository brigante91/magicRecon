
#!/bin/bash

# Load Configuration
source ./configuration.cfg

# Define directories and variables
TOOLS_DIR=~/tools
TARGETS_DIR="targets"
RECON_DIR="recon_results"
NOTIFY_CMD="notify -silent"

# Helper Functions
log_info() {
    printf "${BOLD}${GREEN}[*] $1${NORMAL}\n"
}

log_error() {
    printf "${BOLD}${RED}[!] $1${NORMAL}\n"
}

# Ensure required tools are installed
check_tools() {
    local tools=("python3" "subfinder" "httpx" "nuclei" "nmap" "figlet" "parallel" "gau" "hakrawler" "arjun" "dirsearch")
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
    log_info "Starting Passive Recon for $domain"
    
    recon_dir="$TARGETS_DIR/$domain/$RECON_DIR"
    mkdir -p "$recon_dir"

    log_info "Running Passive Recon Tools in parallel..."
    parallel -j4 :::         "subfinder -silent -d $domain -o $recon_dir/subdomains.txt"         "gau $domain | tee -a $recon_dir/urls.txt"         "hakrawler -url $domain -depth 3 | tee -a $recon_dir/hakrawler.txt"
    
    # Notify results
    if [ "$NOTIFY" == "true" ]; then
        cat "$recon_dir/subdomains.txt" | $NOTIFY_CMD
        cat "$recon_dir/urls.txt" | $NOTIFY_CMD
        cat "$recon_dir/hakrawler.txt" | $NOTIFY_CMD
    fi
}

# Active Recon
active_recon() {
    domain=$1
    log_info "Starting Active Recon for $domain"
    
    recon_dir="$TARGETS_DIR/$domain/$RECON_DIR"
    mkdir -p "$recon_dir"
    
    log_info "Running Active Recon Tools in parallel..."
    parallel -j4 :::         "arjun -u https://$domain -oT $recon_dir/parameters.txt"         "dirsearch -u $domain -w $dictionary --format plain -o $recon_dir/dirsearch.txt"         "nmap -p- --open -T4 -oN $recon_dir/nmap.txt $domain"         "httpx -silent -u $domain -o $recon_dir/httpx.txt"

    # Notify results
    if [ "$NOTIFY" == "true" ]; then
        cat "$recon_dir/parameters.txt" | $NOTIFY_CMD
        cat "$recon_dir/dirsearch.txt" | $NOTIFY_CMD
        cat "$recon_dir/nmap.txt" | $NOTIFY_CMD
        cat "$recon_dir/httpx.txt" | $NOTIFY_CMD
    fi
}

# Vulnerability Scanning
vulnerability_scan() {
    domain=$1
    log_info "Starting Vulnerability Scan for $domain"
    
    recon_dir="$TARGETS_DIR/$domain/$RECON_DIR"
    mkdir -p "$recon_dir"
    
    log_info "Running Vulnerability Tools in parallel..."
    parallel -j4 :::         "nuclei -u $domain -t ~/tools/nuclei-templates/ -o $recon_dir/nuclei.txt"         "python3 ~/tools/shcheck/shcheck.py $domain | tee -a $recon_dir/headers.txt"         "python3 ~/tools/Corsy/corsy.py -u $domain | tee -a $recon_dir/cors.txt"         "gau $domain | gf xss | tee -a $recon_dir/xss.txt"

    # Notify results
    if [ "$NOTIFY" == "true" ]; then
        cat "$recon_dir/nuclei.txt" | $NOTIFY_CMD
        cat "$recon_dir/headers.txt" | $NOTIFY_CMD
        cat "$recon_dir/cors.txt" | $NOTIFY_CMD
        cat "$recon_dir/xss.txt" | $NOTIFY_CMD
    fi
}

# Main script logic
main() {
    check_tools
    prepare_environment

    while getopts "d:panh" opt; do
        case $opt in
            d) domain="$OPTARG" ;;
            p) passive="true" ;;
            a) active="true" ;;
            n) NOTIFY="true" ;;
            h) 
                echo "Usage: $0 -d <domain> [-p] [-a] [-n] [-h]"
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

    if [ -z "$passive" ] && [ -z "$active" ]; then
        passive_recon "$domain"
        active_recon "$domain"
        vulnerability_scan "$domain"
    fi
}

# Run the script
main "$@"
