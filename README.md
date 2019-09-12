# jsonparsing
Json Parser in Prolog and Lisp

Prolog

Nel file json-parsing.prolog i principali predicati sono:
- json_parse,
- json_write,
- json_load,
- json_get.

Nella json_parse viene passato in input una stringa json che verrà trasformata in una lista di caratteri. Su questa lista ricorsivamente viene controllata la correttezza dell'input e allo stesso tempo viene creato l'oggetto json.
La json-parse si appoggia sui predicati ausiliari in particolare json_array e json_obj
che ricorsivamente contribuiscono alla creazione dell'oggetto.

Nella json_write viene passato in input l'oggetto parsato che verrà scritto su un file, se non esiste viene creato e se esiste viene sovrascritto (passando il nome del file che verrà salvato nel formato desiderato e nella stessa cartella contente il file json-parsing.prolog ) effettuando ricorsivamente delle conversioni da oggetto json-prolog a una stringa json standard.
Osservazione: il file per essere chiuso si deve utilizzare il predicato close.
	Per scrivere dentro al file viene utilizzata il predicato write che prende in input lo stream ricevuto dall'output del predicato open e scrive la stringa ,che gli viene passata, nel file.

Nella json_get viene passato in input l'oggetto sulla quale effettuare le ricerche, una variabile che può essere: un numero, una stringa oppure una lista contente numeri e stringhe e in output sarà dato il value della rispettiva ricerca.
Le ricerche effettuate vengono fatte ricorsivamente sul risultato di ogni ricerca precedente.

Nella json_load apre un file specificato tramite parametro in lettura se esiste altrimenti mi da un errore su lettura file.
Il file se esiste viene aperto e viene trasformato in una lista di cartteri che dopo sarà trasformato in un atomo, che sarà poi passato sulla json_parse.
in ouput la json_load mi restituisce l'oggetto parsato. 

Lisp

Nel file json-parsing.lisp le funzioni principali definiite sono:
- json-parse,
- json-write,
- json-load,
- json-get.

Osservazione: a ogni definizione di funzione viene passato un qualsiasi input, la funzione viene calcolata usando l'input dato e il risultato sarà il valore prodotto dalla funzione.

Nella json-parse viene passato come input una stringa, viene verificato che sia effettivamente una stringa e ricorsivamente viene controllata la correttezza dell'input e allo stesso tempo viene creato l'oggetto json.
L'input potrebbe anche non essere una stringa, ma uno stream (come nel caso della json-load), ma l'esecuzione rimane uguale.
La json-parse si appoggia su funzioni ausiliarie in particolare json-array e json-obj
che ricorsivamente contribuiscono alla creazione dell'oggetto.

Nella json-write viene passato in input l'oggetto parsato che verrà scritto su un file, se non esiste viene creato, mentre se esiste viene sovrascritto (passando il nome del file che verrà salvato nel formato desiderato e, di default, nella cartella C:\Users\(utente)\AppData\Local\VirtualStore\Windows\SysWOW64) effettuando ricorsivamente delle conversioni da oggetto json-prolog a stringa json standard.
Per scrivere nel file si utilizza la funzione format.
Osservazione: rispetto a prolog il file viene chiuso da solo grazie alla macro with-open-file.

Nella json-get viene passato in input l'oggetto sulla quale effettuare le ricerche, una variabile che può essere: un numero, una stringa oppure una lista contente numeri e stringhe e in output sarà data una lista contente un value della rispettiva ricerca.
Le ricerche effettuate vengono fatte ricorsivamente sul risultato di ogni ricerca precedente.

La json-load apre un file (specificato tramite parametro) in lettura.
Il file, se esiste, viene aperto grazie alla macro with-open file, altrimenti restituisce un errore.
In ouput la json-load mi restituisce l'oggetto parsato. 
Osservazione: rispetto a prolog il file viene chiuso da solo grazie alla macro with-open-file e passa alla json-parse uno stream.
