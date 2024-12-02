
# InfinityRecon

InfinityRecon è un framework di ricognizione e scansione delle vulnerabilità altamente automatizzato progettato per aiutare i professionisti della sicurezza a raccogliere informazioni, eseguire scansioni di vulnerabilità e generare report dettagliati su un obiettivo.

## Caratteristiche principali

- **Ricognizione Passiva**:
  - Raccolta di subdomini, informazioni DNS, tecnologie usate, e molto altro.
  - Strumenti inclusi: `subfinder`, `assetfinder`, `crt.sh`, `SecurityTrails`, `Waybackurls`, `CloudEnum`, e altri.

- **Ricognizione Attiva**:
  - Scansioni di porte aperte, enumerazione di endpoint e directory, screenshot automatici.
  - Strumenti inclusi: `httpx`, `arjun`, `hakrawler`, `dirsearch`, `masscan`, `gowitness`, `aquatone`.

- **Analisi di vulnerabilità**:
  - Identificazione di XSS, SQLi, problemi di configurazione CORS, e altro.
  - Strumenti inclusi: `nuclei`, `jaeles`, `xsser`, `truffleHog`, `gitrob`, `sqlmap`.

- **Supporto per parallelizzazione**:
  - Esecuzione simultanea di comandi con `parallel` per ridurre i tempi di esecuzione.

## Prerequisiti

- **Strumenti richiesti**:
  - `python3`, `subfinder`, `httpx`, `nuclei`, `nmap`, `figlet`, `parallel`, `gau`, `hakrawler`, `arjun`, `dirsearch`
  - `whatweb`, `theHarvester`, `CloudEnum`, `GitDorker`, `Amass`, `Waybackurls`, `dnsx`
  - `assetfinder`, `crt.sh`, `SecurityTrails`, `masscan`, `gowitness`, `aquatone`
  - `jaeles`, `xsser`, `truffleHog`, `gitrob`, `dnsrecon`, `dnsprobe`, `zmap`, `webanalyze`, `gf`

- **Configurazioni aggiuntive**:
  - Passa il file dizionario come parametro tramite l'opzione `--dictionary`., il protocollo predefinito (`http/https`), e altre impostazioni.

## Installazione

1. Clona il repository:
   ```bash
   git clone https://github.com/tuo-repository/magicrecon.git
   cd magicrecon
   ```

2. Installa i tool richiesti con lo script `install.sh`:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. Configura il file `configuration.cfg` con le impostazioni necessarie.

## Utilizzo

Esegui il tool con le seguenti opzioni:

- **Ricognizione Passiva**:
  ```bash
  ./InfinityRecon.sh -d <domain> --dictionary <dictionary_file> -p
  ```

- **Ricognizione Attiva**:
  ```bash
  ./InfinityRecon.sh -d <domain> --dictionary <dictionary_file> -a
  ```

- **Analisi di Vulnerabilità**:
  ```bash
  ./InfinityRecon.sh -d <domain> --dictionary <dictionary_file> -v
  ```

- **Tutte le modalità**:
  ```bash
  ./InfinityRecon.sh -d <domain> --dictionary <dictionary_file> -p -a -v
  ```

## Directory di output

I risultati saranno salvati nella directory `targets/<domain>/recon_results` e organizzati per tipo di analisi.

## Struttura del codice

- **`check_tools`**: Verifica che tutti gli strumenti richiesti siano installati.
- **`prepare_environment`**: Configura l'ambiente di lavoro.
- **`passive_recon`**: Esegue la ricognizione passiva.
- **`active_recon`**: Esegue la ricognizione attiva.
- **`vulnerability_scan`**: Analizza le vulnerabilità.

## Contributi

Contributi e suggerimenti sono benvenuti! Sentiti libero di aprire una issue o inviare una pull request.

## Licenza

InfinityRecon è distribuito sotto licenza MIT. Consulta il file `LICENSE` per maggiori dettagli.
