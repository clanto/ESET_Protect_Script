# Monitoraggio degli Endpoint tramite Zabbix
Il template permette di monitorare molte delle informazioni direttamente sugli Endpoint in modalità RMM Safe (solo lettura, senza scrittura).

## Abilitare RMM da console Protect o dai singoli Endpoint
Per poter usufruire del template bisogna abilitare le opzioni di RMM sugli Endpoint tramite console Protect o sui singoli computer.
Per farlo basta andare su Configurazione Avanzata -> Strumenti -> ESET RMM.
Qui bisogna:
- Attivare RMM
- Modalità operativa impostare "Solo operazioni sicure"
- Metodo di autorizzazione impostiamo "Percorso Applicazione"
- Percorsi Applicazione impostiamo il percorso della cartella delle applicazioni di Zabbix "C:\Program Files\Zabbix Agent\*"

## Funzionamento
Il template utilizza di base 4 elementi con cui recupera i log dall' Endpoint per creare tutti gli elementi ed i Trigger.
I log sono impostati per essere recuperati ogni 10 secondi così da dare uno stato del software quasi in tempo reale.
Per una lista dei comandi RMM utilizzati:
https://help.eset.com/eea/7/en-US/rmm_json_commands_application.html?rmm_json_commands.html

## Script esterni
Il template fa uso del file checkviruslog.ps1 per creare dei log temporanei per inviare a Zabbix informazioni sul rilevamento dei Virus negli ultimi 5 minuti.

## Template collegati
Non ci sono template collegati

## Regole di Discovery
Non ci sono regole di discovery

# Macro usate
Non ci sono macro

## Elementi Principali
| Nome        | Tipo           | Chiave  | Tipo di informazione  | Intervallo| Tag | Preprocesso|
| ------------- |:-------------|:-------------|:-------------|:-----|:-----|:-----|
|Stato del servizio ESET|Agente Zabbix| ``` service.info["ekrn",state] ``` |Testo|10s|`Antivirus:ESET` `ESET:Componenti`|
|Log Info Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get application-info]```|Testo|10s|`Antivirus:ESET` `ESET:Log`|
|Log Licenza Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get license-info]```|Testo|10s|`Antivirus:ESET` `ESET:Log`|
|Log Stato Protezione Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get protection-status]```|Testo|10s|`Antivirus:ESET` `ESET:Log`|```JSONPath -> $.result.description```<br><br>```Sostituisci: You are protected -> Protezione attiva```<br><br>```Sostituisci: Security alert -> Protezione Disattivata```|
|Log Aggiornamenti Endpoint ESET|Agente Zabbix|```system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get update-status]```|Testo|10s|`Antivirus:ESET` `ESET:Log`|
|Deploy ESET Script<br><br>Scarica da questa repository di github il file checkviruslog.ps1 e lo inserisce nella cartella script di Zabbix così da poterlo utilizzare per le informazioni ed i trigger sulle minacce|Agente Zabbix|```system.run[mkdir C:\PROGRA~1\ZABBIX~1\script & powershell.exe -NoProfile -ExecutionPolicy Bypass -command Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/clanto/ESET_Protect_Script/main/zabbix/checkviruslog.ps1' -OutFile "$Env:Programfiles\ZABBIX~1\script\checkviruslog.ps1",nowait]```|Testo|1d|`Antivirus:ESET` `ESET:Log`|
|Log Minacce ultimi 5 minuti<br><br>All'interno della chiave il valore ```-time_check 5``` equivale ai 5 minuti, si può modificare questo numero ed impostare il numero di minuti per cui si vuole recuperare il log|Agente Zabbix|```system.run[powershell -NoProfile -ExecutionPolicy bypass -File "C:\PROGRA~1\ZABBIX~1\script\checkviruslog.ps1" -time_check 5]```|Testo|10s|`Antivirus:ESET` `ESET:Log`|

## Elementi Dipendenti Info
| Nome        | Tipo           | Chiave  | Master Item  |Tipo di informazione | Tag | Preprocesso|
| ------------- |:-------------|:-------------|:-------------|:-----|:-----|:-----|
|Info Versione Endpoint ESET|Dependent Item| ```versione.endpoint``` |```ESET: Log Info Endpoint ESET```|Testo|`Antivirus:ESET` `ESET:Info`|```JSONPath -> $.result.version```|
|Info Prodotto Endpoint ESET|Dependent Item| ```prodotto.endpoint``` |```ESET: Log Info Endpoint ESET```|Testo|`Antivirus:ESET` `ESET:Info`|```JSONPath -> $.result.description```|
|Info Lingua Endpoint ESET|Dependent Item| ```info.endpoint.lang``` |```ESET: Log Info Endpoint ESET```|Testo|`Antivirus:ESET` `ESET:Info`|```JSONPath -> $.result.lang_id```<br><br>```Sostituisci: 1040 -> Italiano```|

## Elementi Dipendenti Aggiornamenti
| Nome        | Tipo           | Chiave  | Master Item  |Tipo di informazione | Tag | Preprocesso|
| ------------- |:-------------|:-------------|:-------------|:-----|:-----|:-----|
|Aggiornamenti Risultato ultimo tentativo|Dependent Item| ```aggiornamento.risultato``` |```ESET: Log Aggiornamenti Endpoint ESET```|Testo|`Antivirus:ESET` `ESET:Aggiornamenti`|```JSONPath -> $.result.last_update_result```|
|Aggiornamenti ultimo eseguito con successo|Dependent Item| ```aggiornamento.riuscito``` |```ESET: Log Aggiornamenti Endpoint ESET```|Testo|`Antivirus:ESET` `ESET:Aggiornamenti`|```JSONPath -> $.result.last_successful_update_time```|
|Aggiornamenti Ultimo Tentativo ESET|Dependent Item| ```aggiornamento.tentato``` |```ESET: Log Aggiornamenti Endpoint ESET```|Testo|`Antivirus:ESET` `ESET:Aggiornamenti`|```JSONPath -> $.result.last_update_time```|

## Elementi Dipendenti Licenza
In Aggiornamento

## Elementi Dipendenti Minacce
In Aggiornamento

## Triggers
| Nome        | Descrizione           | Severità  | Tag  | Espressione  |
| ------------- |:-------------|:-------------|:-------------|:-----|
| 	Licenza ESET in scadenza     | Controlla la scadenza della licenza ed avvisa in caso di problemi. | Media |`Antivirus:ESET` `ESET:Alert`|``` last(/ESET/ESET.licenza.stato)<>"ok" ```
| Minaccia Rilevata      | Non appena viene rilevata una minaccia viene creato un trigger della minaccia |   Media |`Antivirus:ESET` `ESET:Alert`|``` last(/ESET/ESET.Rilevamento)="Minaccia Rilevata" ```
| Protezione ESET Disattivata | E' stato disabilitato un conponente di ESET      |    Media |`Antivirus:ESET` `ESET:Alert`|``` last(/ESET/system.run[C:\PROGRA~1\ESET\ESETSE~1\eRmm.exe get protection-status],#10)<>"Protezione attiva" ```
| Servizio ESET Disattivato | Il servizio non è in esecuzione      |    Media |`Antivirus:ESET` `ESET:Alert`|``` last(/ESET/service.info["ekrn",state])<>0 ```

## Autore
Lingua: Italiano<br>
Autore: Clanto Services<br>
Sito: https://clanto.it<br>
Repository: https://github.com/clanto<br>
