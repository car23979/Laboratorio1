/*
* Laboratorio1.asm
*
* Created: 07-Feb-25 18:00:00 PM
* Author : David Carranza
* Descripci�n: Implementaci�n de un segundo contador de 4 bits y dos bushbottoms 
*/
// Encabezado
.include "M328PDEF.inc"

.cseg
.org	0x0000

// Configuraci�n de pila
LDI		R16, LOW(RAMEND)
OUT		SPL, R16
LDI		R16, HIGH(RAMEND)
OUT		SPL, R16

// Configurar el MCU
SETUP:
	// Configuraci�n de los pines de entrada y salida (DDRx, PORTX, PINx)
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

	LDI R17, 0x7F	// Variable que guarda el estado de los botones
	LDI R18, 0x00	// Contador 1 incializaci�n en 0
	LDI R19, 0x00	// Contador 2

// Loop Infinito
MAIN:
	IN R16, PINC	// Leer estadode botones
	CP R17, R16		// Comparar con estado previo
	BREQ MAIN		// Si no hay cambio, vuelve a leer
	
	CALL DELAY		// Retardo para antirrebote
	
	IN R16, PINC	// Leer estadode botones
	CP R17, R16		// Comparar con estado previo
	BREQ MAIN		// Si no hay cambio, vuelve a leer

	MOV R17, R16	// Guardar copia de estado actual
	SBRS R16, 0		// Revisar si el bit 2 no se presiono
	CALL INCREMENT	// Llamar subrutina de incremento
	SBRS R16, 1		// Si el bit 3 se presiono
	CALL DECREMENT	// Llamar subrutina de decremento

	OUT PORTB, R18	// Mostrar el contador en los LEDs
	RJMP MAIN		// Repetir el ciclo

// Subrutina para incrementar el contador
INCREMENT:
	INC R18			// Incrementra contador
	CPI R18, 0x10 
	BRNE NO_CARRY	// Si no hubo overflow, continuar
	LDI	R18, 0x00	// Si hubo carry, reiniciar contador a 0
NO_CARRY:
	RET

// Subrutina para decrementar el contador
DECREMENT:
	DEC R18			// Decrementar contador
	CPI R18, 0xFF	// Comprobar si se gener� borrow
	BRNE NO_BORROW	// Si no hubo borrow
	LDI R18, 0x0F	// Si hubo borrow, el contador decrementa
NO_BORROW:
	RET

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
