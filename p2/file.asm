; directivas
.model small
.radix 16 ; base hexadecimal
.stack 100h
.386 ; instrucciones 386
.data
    filename db "D:\auth.txt",0 ; nombre del archivo

    buffer db 256 dup(0), '$' ; buffer de lectura
    countBuff dw 0 ; contador de buffer
    
    quotes db '"' ; comillas

    outBuff db 256 dup(0); buffer de salida
    countOutBuff dw 0 ; contador de buffer de salida
.code

; limpia el buffer de salida
clearOutBuff proc
    mov countOutBuff, 0
    begin_clear:
        mov bx, countOutBuff
        mov outBuff[bx], 0
        inc countOutBuff
        cmp countOutBuff, 256
        jne begin_clear ; limpia el buffer de salida

    mov countOutBuff, 0
    ret
clearOutBuff endp

; extrae la cita del buffer
extract_quote proc
    ; busca la primera comilla
     find_quotes:
        mov bx, countBuff
        mov al, buffer[bx]
        cmp al, quotes
        jne next_char ; si no es comilla, avanza al siguiente caracter
        inc countBuff

    save_char:
        mov bx, countBuff
        mov al, buffer[bx]
        cmp al, quotes
        je end_quotes ; si es comilla, termina la extracción
        mov bx, countOutBuff
        mov outBuff[bx], al
        inc countOutBuff
        inc countBuff
        jmp save_char ; guarda el caracter y avanza al siguiente

    next_char:
        inc countBuff
        mov bx, countBuff
        cmp buffer[bx], '$'
        jne find_quotes ; si no es fin de cadena, busca la siguiente comilla

    end_quotes:
        mov bx, countOutBuff
        mov outBuff[bx], '$' ; agrega fin de cadena
        ret
extract_quote endp

; programa principal
main proc
    mov ax,@data ; inicializa el segmento de datos
    mov ds,ax ; inicializa el segmento de datos

    ; abre el archivo
    mov ah, 3Dh ; servicio para abrir archivo
    mov al, 0
    lea dx, filename
    int 21h

    jc error
    mov bx, ax ; guarda el handle del archivo

    ; lee el archivo
    mov ah, 3Fh ; servicio para leer archivo
    lea dx, buffer
    mov cx, 255
    int 21h

    jc error
    or ax, ax ; verifica si se leyó algo
    jz end_read

    mov countBuff, 0
    call clearOutBuff 

    call extract_quote ; extrae la primera cita

    ; imprime la cita
    mov ah, 2 ; servicio para imprimir caracter
    mov dl, '.'
    int 21h
    
    mov ah, 9 ; servicio para imprimir cadena
    lea dx, outBuff
    int 21h

    ; avanza al siguiente caracter
    inc countBuff

    call clearOutBuff 
    call extract_quote

   ; imprime la cita 
    mov ah, 2 ; servicio para imprimir caracter
    mov dl, '.'
    int 21h
    
    mov ah, 9
    lea dx, outBuff
    int 21h
    
    mov ah, 2 ; servicio para imprimir caracter
    mov dl, '.'
    int 21h
end_read:
    mov ah, 3Eh  ; servicio para cerrar archivo
    int 21h

    mov ax, 4C00h ; servicio para terminar programa
    int 21h


error:
    mov ax, 4C01h ; servicio para terminar programa con error
    int 21h
 
main endp
end main