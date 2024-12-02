
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
    local tools=("python3" "subfinder" "httpx" "nuclei" "nmap" "figlet" "parallel")
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
    
    log_info "Running Subfinder in parallel..."
    echo "$domain" | parallel -j4 subfinder -silent -d {} -o "$recon_dir/subdomains.txt"

    # Notify results
    if [ "$NOTIFY" == "true" ]; then
        cat "$recon_dir/subdomains.txt" | $NOTIFY_CMD
    fi
}

# Active Recon
active_recon() {
    domain=$1
    log_info "Starting Active Recon for $domain"
    
    recon_dir="$TARGETS_DIR/$domain/$RECON_DIR"
    mkdir -p "$recon_dir"
    
    log_info "Running Nmap and HTTPX in parallel..."
    parallel -j2 :::         "nmap -p- --open -T4 -oN $recon_dir/nmap.txt $domain"         "httpx -silent -u $domain -o $recon_dir/httpx.txt"

    # Notify results
    if [ "$NOTIFY" == "true" ]; then
        cat "$recon_dir/nmap.txt" | $NOTIFY_CMD
        cat "$recon_dir/httpx.txt" | $NOTIFY_CMD
    fi
}

# Main script logic
main() {
    check_tools
    prepare_environment

    while getopts "d:p:nh" opt; do
        case $opt in
            d) domain="$OPTARG" ;;
            p) passive="true" ;;
            n) NOTIFY="true" ;;
            h) 
                echo "Usage: $0 -d <domain> [-p] [-n] [-h]"
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
    else
        active_recon "$domain"
    fi
}

# Run the script
main "$@"
