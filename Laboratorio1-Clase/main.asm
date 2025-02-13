/*
* Laboratorio1.asm
*
* Created: 07-Feb-25 18:00:00 PM
* Author : David Carranza
* Descripción: Implementación de un segundo contador de 4 bits y dos bushbottoms 
*/
// Encabezado
.include "M328PDEF.inc"

.cseg
.org	0x0000

// Configuración de pila
LDI		R16, LOW(RAMEND)
OUT		SPL, R16
LDI		R16, HIGH(RAMEND)
OUT		SPL, R16

// Configurar el MCU
SETUP:
	// Configuración de los pines de entrada y salida (DDRx, PORTX, PINx)
	// PORTC se configura como la entrada con pull-up habilitado
	LDI R16, 0x00
	OUT DDRC, R16	// Se establece el puerto C como entrada
	LDI R16, 0xFF
	OUT PORTC, R16	// Se habilita los pull-ups en el puerto C

	// PORTB y PORTD se configura como salidas inicialmente apagado
	LDI R16, 0xFF
	OUT DDRB, R16	// Se establece el puerto B como salida (contador 1)
	OUT DDRD, R16	// Se establece el puerto D como salida (contador 2)
	LDI R16, 0X00
	OUT PORTB, R16	// Todos los bits del puerto B se encuentran apagados
	OUT PORTD, R16	// Todos los bits del puerto D se encuentran apagados

	// Inicializar variables
	LDI R17, 0x7F	// Guarda el estado anterior de los botones (contador 1)
	LDI R18, 0x00	// Valor del contador 1
	LDI R19, 0xFF	// Guarda el estado anterior de los botones (contador 2)
	LDI R20, 0x00	// Valor del contador 2

// Loop Infinito
MAIN:
	CALL CONTADOR_1 // Llamar la subrutina del contador 1
	CALL CONTADOR_2 // Llamar la subrutina del contador 2
	RJMP MAIN		// Repetir ciclo
	
// Subrutina para el contador 1 (PC0 y PC1)
CONTADOR_1:
	IN R16, PINC	// Leer estados de botones
	ANDI R16, 0x03	// Máscara para PC0 y PC1
	CP R17, R16		// Comparar con estado previo
	BREQ CONTADOR_1	// Si no hay cambio, vuelve a leer
	
	CALL DELAY		// Retardo para antirrebote
	
	IN R16, PINC	// Leer estadode botones
	ANDI R16, 0x03	// Máscara para PC0 y PC1
	CP R17, R16		// Comparar con estado previo
	BREQ CONTADOR_1		// Si no hay cambio, vuelve a leer

	MOV R17, R16	// Guardar copia de estado actual
	SBRS R16, 0		// Revisar si PC0 no se presiono
	CALL INCREMENT1	// Llamar subrutina de incremento 1
	SBRS R16, 1		// Si PC1 se presiono
	CALL DECREMENT1	// Llamar subrutina de decremento 1

	OUT PORTB, R18	// Mostrar el contador en los LEDs

FIN_CONTADOR1:
	RET				// Regresa a Main

// Subrutina para el contador 2 (PC2 y PC3)
CONTADOR_2:
	IN R16, PINC	// Leer estados de botones
	ANDI R16, 0x03	// Máscara para PC2 y PC3
	CP R19, R16		// Compara con estado previo
	BREQ CONTADOR_2 // Si no hay cambio, vuelve a leer

	CALL DELAY		// Retardo para antirrebote

	IN R16, PINC	// Leer estados de botones
	ANDI R16, 0x03	// Máscara para PC2 y PC3
	CP R19, R16		// Compara con estado previo
	BREQ CONTADOR_2 // Si no hay cambio, vuelve a leer

	MOV R19, R16	// Guardar copia de estado actual
	SBRS R16, 2		// Si PC2 se presiono
	CALL INCREMENT2 // Llamar subrutina de incremento 2
	SBRS R16, 3		// Revisar si PC3 no se presiono
	CALL DECREMENT2	// Llamar subrutina de decremento 2

	OUT PORTD, R20	// Mostrar el contador en los LEDs

FIN_CONTADOR2:
	RET				// Regresa a Main

// Logica Contador 1
// Subrutina para incrementar el contador
INCREMENT1:
	INC R18			// Incrementra contador
	CPI R18, 0x10 
	BRNE NO_CARRY1	// Si no hubo overflow, continuar
	LDI	R18, 0x00	// Si hubo carry, reiniciar contador a 0
NO_CARRY1:
	RET

// Subrutina para decrementar el contador
DECREMENT1:
	DEC R18			// Decrementar contador
	CPI R18, 0xFF	// Comprobar si se generó borrow
	BRNE NO_BORROW1	// Si no hubo borrow
	LDI R18, 0x0F	// Si hubo borrow, el contador decrementa
NO_BORROW1:
	RET

// Logica Contador 2

// Subrutina de retardo para antirrebote
DELAY:
	LDI R20, 0xFF
SUB_DELAY1:
	DEC R20
	CPI R20, 0
	BRNE SUB_DELAY1
	LDI R20, 0xFF
SUB_DELAY2:
	DEC R20
	CPI R20, 0
	BRNE SUB_DELAY2
	LDI R20, 0xFF
SUB_DELAY3:
	DEC R20
	CPI R20, 0
	BRNE SUB_DELAY3
	LDI R20, 0xFF
SUB_DELAY4:
	DEC R20
	CPI R20, 0
	BRNE SUB_DELAY4
	RET
/*	LDI R19, 0xFF
SUB_DELAY5:
	DEC R19
	CPI R19, 0
	BRNE SUB_DELAY5
	LDI R19, 0xFF
SUB_DELAY6:
	DEC R19
	CPI R19, 0
	BRNE SUB_DELAY6
	RET*/
