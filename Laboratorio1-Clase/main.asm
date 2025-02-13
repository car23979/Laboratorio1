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
	OUT DDRB, R16	// Se establece el puerto B como sumador
	OUT DDRD, R16	// Se establece el puerto D como salida (contador 2)
	LDI R16, 0X00
	OUT PORTB, R16	// Todos los bits del puerto B se encuentran apagados
	OUT PORTD, R16	// Todos los bits del puerto D se encuentran apagados

	// Inicializar variables
	LDI R17, 0x7F	// Guarda el estado anterior de los botones (contador 1)
	LDI R18, 0x00	// Valor del contador 1
	LDI R19, 0x7F	// Guarda el estado anterior de los botones (contador 2)
	LDI R20, 0x00	// Valor del contador 2
	CLR R23			// Valor del sumador

// Loop Infinito
MAIN:
// Leer botones	
	IN R16, PINC	// Leer estados de botones
	CP R17, R16		// Comparar con estado previo
	BREQ MAIN	// Si no hay cambio, vuelve a leer
	
	CALL DELAY		// Retardo para antirrebote
	
	IN R16, PINC	// Leer estadode botones
	CP R17, R16		// Comparar con estado previo
	BREQ MAIN		// Si no hay cambio, vuelve a leer
	
	CALL DELAY		// Retardo para antirrebote

	MOV R17, R16	// Guardar copia de estado actual
	SBRS R16, 0		// Revisar si PC0 no se presiono
	CALL INCREMENT1	// Llamar subrutina de incremento 1
	SBRS R16, 1		// Si PC1 se presiono
	CALL DECREMENT1	// Llamar subrutina de decremento 1
	SBRS R16, 2		// Si PC2 se presiono
	CALL INCREMENT2 // Llamar subrutina de incremento 2
	SBRS R16, 3		// Revisar si PC3 no se presiono
	CALL DECREMENT2	// Llamar subrutina de decremento 2

	// Verificar el botón de suma
	SBIS PINC, 4	// Revisar si PC4 no se presiono

	CALL SUMA		// Se llama a la subrutina de suma

	RJMP MAIN

// Subrutina para incrementar el contador 1
INCREMENT1:
	INC R18			// Incrementra contador 1
	CPI R18, 0x10 
	BRNE NO_CARRY1	// Si no hubo overflow, continuar
	LDI	R18, 0x00	// Si hubo carry, reiniciar contador 1 a 0
NO_CARRY1:
	MOV R22, R18	// Se guarda en otro registro para poder modificarlo
	LSL R22			// Se corre R18 4 espacios
	LSL R22
	LSL R22
	LSL R22
	OR	R22, R20	// Unir con el contador 2
	OUT PORTD, R22	// Mostrar en LEDs
	RET

// Subrutina para decrementar el contador 1
DECREMENT1:
	DEC R18			// Decrementar contador 1
	CPI R18, 0xFF	// Comprobar si se generó borrow
	BRNE NO_BORROW1	// Si no hubo borrow
	LDI R18, 0x0F	// Si hubo borrow, el contador 1 decrementa
NO_BORROW1:
	MOV R22, R18	// Se guarda en otro registro para poder modificarlo
	LSL R22			// Se corre R18 4 espacios
	LSL R22
	LSL R22
	LSL R22
	OR	R22, R20	// Unir con el contador 2
	OUT PORTD, R22	// Mostrar en LEDs
	RET

// Logica Contador 2
// Subrutina para incrementar el contador 2
INCREMENT2:
	INC R20			// Incrementra contador 2
	CPI R20, 0x10 
	BRNE NO_CARRY2	// Si no hubo overflow, continuar
	LDI	R20, 0x00	// Si hubo carry, reiniciar contador 2 a 0
NO_CARRY2:
	MOV R22, R20	// Se guarda en otro registro para poder modificarlo
	OUT PORTD, R22	// Mostrar en LEDs
	RET

// Subrutina para decrementar el contador 2
DECREMENT2:
	DEC R20			// Decrementar contador 2
	CPI R20, 0xFF	// Comprobar si se generó borrow
	BRNE NO_BORROW2	// Si no hubo borrow
	LDI R20, 0x0F	// Si hubo borrow, el contador 2 decrementa
NO_BORROW2:
	MOV R22, R20	// Se guarda en otro registro para poder modificarlo
	OUT PORTD, R22	// Mostrar en LEDs
	RET

// Subrutina para el botón de sumador
SUMA:
	MOV R23, R18	// Se guarda en otro registro para modificarlo
	ADD R23, R20	// Se suman los registros
	CPI R23, 0X10	// Comprobar si se genero Carry
	BRNE NO_CARRYS	// Si no hubo overflow, continuar
	LDI R23, 0X10	// Encender PB4 si hay overflow
	OUT PORTB, R23	// Mostrar en LEDs
	RET
NO_CARRYS:
	OUT PORTB, R23	// Mostrar resultado
	RET

// Subrutina de retardo para antirrebote
DELAY:
	LDI R21, 0xFF
SUB_DELAY1:
	DEC R21
	CPI R21, 0
	BRNE SUB_DELAY1
	LDI R21, 0xFF
SUB_DELAY2:
	DEC R21
	CPI R21, 0
	BRNE SUB_DELAY2
	LDI R21, 0xFF
SUB_DELAY3:
	DEC R21
	CPI R21, 0
	BRNE SUB_DELAY3
	LDI R21, 0xFF
SUB_DELAY4:
	DEC R21
	CPI R21, 0
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
