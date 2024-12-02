
#!/bin/bash

# Log file
LOG_FILE="install.log"

# Helper Functions
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1" | tee -a $LOG_FILE
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" | tee -a $LOG_FILE
}

# Detect package manager
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    else
        log_error "Unsupported package manager. Please install the required tools manually."
        exit 1
    fi
}

# Install base dependencies
install_dependencies() {
    package_manager=$(detect_package_manager)
    log_info "Using $package_manager to install base dependencies."

    if [ "$package_manager" == "apt" ]; then
        sudo apt update && sudo apt install -y curl git python3 python3-pip build-essential
    elif [ "$package_manager" == "yum" ] || [ "$package_manager" == "dnf" ]; then
        sudo $package_manager install -y curl git python3 python3-pip gcc
    fi
}

# Install tools
install_tools() {
    for tool in python3 pip3 subfinder httpx nuclei nmap figlet parallel gau hakrawler arjun dirsearch whatweb theHarvester CloudEnum GitDorker Amass Waybackurls dnsx assetfinder crt.sh SecurityTrails masscan gowitness aquatone jaeles xsser truffleHog gitrob dnsrecon dnsprobe zmap webanalyze gf dnsgen; do
        if ! command -v "$tool" &> /dev/null; then
            log_info "Installing $tool..."
            case $tool in
                subfinder)
                    GO111MODULE=on go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
                    ;;
                httpx)
                    GO111MODULE=on go install github.com/projectdiscovery/httpx/cmd/httpx@latest
                    ;;
                nuclei)
                    GO111MODULE=on go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
                    ;;
                hakrawler)
                    GO111MODULE=on go install github.com/hakluke/hakrawler@latest
                    ;;
                gau)
                    GO111MODULE=on go install github.com/lc/gau/v2/cmd/gau@latest
                    ;;
                dnsx)
                    GO111MODULE=on go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest
                    ;;
                waybackurls)
                    GO111MODULE=on go install github.com/tomnomnom/waybackurls@latest
                    ;;
                nuclei-templates)
                    git clone https://github.com/projectdiscovery/nuclei-templates.git ~/tools/nuclei-templates
                    ;;
                *)
                    log_error "$tool requires manual installation or is not supported."
                    ;;
            esac
        else
            log_info "$tool is already installed."
        fi
    done
}

# Final checks
final_verification() {
    log_info "Verifying installation of all tools..."
    for tool in python3 pip3 subfinder httpx nuclei nmap figlet parallel gau hakrawler arjun dirsearch whatweb theHarvester CloudEnum GitDorker Amass Waybackurls dnsx assetfinder crt.sh SecurityTrails masscan gowitness aquatone jaeles xsser truffleHog gitrob dnsrecon dnsprobe zmap webanalyze gf dnsgen; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool installation failed. Please check the log."
        else
            log_info "$tool installed successfully."
        fi
    done
}

# Main script logic
main() {
    install_dependencies
    install_tools
    final_verification
}

main
