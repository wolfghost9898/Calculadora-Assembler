
;##############################################################################
;#################### ELIMINA LOS CARACTERES DE MAS EN LA DIRECCION ###########
;#################################### DEL ARCHIVO #############################
corregirDireccion macro
    LOCAL recursivo,salida,error,fin
    xor bx,bx
    mov SI,offset direccion + 4
    mov cl,10d
    mostrarCaracter cl
    recursivo:
        mov cl,[SI + BX]
        cmp cl,'$'
        je salida
        cmp cl,'#'
        je salida 

        mov [fileAdress + bx],cl
        mostrarCaracter cl

        inc bx
        jmp recursivo


    salida:
    abrirArchivo fileAdress
    cmp bx,0d
    je error 
    mov cl,10d
    mostrarCaracter cl
    mostrarCaracter cl
    leerArchivo
    analisisLexico
    cmp bx,1d 
    je error 
    analisisSintactico
    cmp bx,1d 
    je error
    convertirPostFijo
    jmp fin

    error: 
        ingresarCaracter 

    fin: 
        cerrarArchivo
endm



;##############################################################################
;########################## VERIFICA QUE TODOS LOS CARACTERES ###################
;##################################### LOS ACEPTE EL LENGUAJE ###################
analisisLexico macro
    LOCAL salto,recursividad,error,fin,seguir
    xor bx,bx

    recursividad:
        cmp bx,fileSize
        jge salto 

        mov cl,[buffer + bx]
        cmp cl,'-'
        je seguir 
        cmp cl,'+'
        je seguir 
        cmp cl,'/'
        je seguir 
        cmp cl,'*'
        je seguir 
        cmp cl,59d 
        je seguir 
        cmp cl,10d
        je seguir 
        cmp cl,32d 
        je seguir

        cmp cl,'0'
        jl error 

        cmp cl,'9'
        jg error


        seguir:
        inc bx
        jmp recursividad 
    
    error:
        mov bx,1d
        mostrarCadena msgErrorLexico
        mostrarCaracter cl
        jmp fin 
    
    salto:
        mov bx,0d

    fin:

endm 


;##############################################################################
;#################### ANALISIS SINTACTICO DE LOS CARACTERES ###########
analisisSintactico macro
    LOCAL salto,recursividad,error,espacio,signo,seguir
    xor bx,bx
    xor dx,dx
    xor ax,ax
    recursividad:
        cmp bx,fileSize
        jge salto 

        mov cl,[buffer + bx]
        cmp cl,'-'
        je signo 
        cmp cl,'+'
        je signo 
        cmp cl,'/'
        je signo 
        cmp cl,'*'
        je signo

        cmp cl,59d 
        je espacio 
        cmp cl,10d
        je espacio 
        cmp cl,32d 
        je espacio

        cmp ax,2d
        jge error

        inc ax
        mov dx,0d

        jmp seguir

        signo:
            cmp dx,1d 
            je error
            cmp ax,0d
            je error 
            mov dx,1d
            mov ax,0d
            
        espacio:
            cmp ax,1d 
            je error
           

        seguir:
        inc bx
        jmp recursividad 
    
    error:
        
        mostrarCadena msgErrorSintactico
        mostrarCaracter cl
        mov bx,1d
        jmp fin 
    
    salto:
        cmp dx,1d 
        je error
        mov bx,0d

    fin: 
endm


;##############################################################################
;####################            POSTFIJO ###########
;##############################################################################

convertirPostFijo macro
    LOCAL recursividad,seguir,fin,positivo,negativo,multiplicacion,division
    mov cantSimbolos,0d
    xor bx,bx
    xor dx,dx
    xor ax,ax
    recursividad:
        cmp bx,fileSize
        jge fin 

        mov cl,[buffer + bx]
        
        cmp cl,32d 
        je seguir 
        cmp cl,10d 
        je seguir 

        
        cmp cl,'+' 
        je positivo
        cmp cl,'-' 
        je negativo
        cmp cl,'*' 
        je multiplicacion
        cmp cl,'/' 
        je division      
        push bx 
        mov bx,ax
        mov [postFijo + bx],cl
        pop bx
        inc ax
        jmp seguir 

        positivo:
            precedenciaDeOperadores 1d,'+'
            inc ax
            jmp seguir 
        
        negativo:
            precedenciaDeOperadores 1d,'-' 
            inc ax 
            jmp seguir

        multiplicacion:
            precedenciaDeOperadores 2d,'*' 
            inc ax 
            jmp seguir
        
         division:
            precedenciaDeOperadores 2d,'/' 
            inc ax 
        seguir:
            inc bx
            jmp recursividad 
    


    fin:
    

    vaciarPila
    mov bx,ax 
    mov [postFijo + bx],"$"
    mostrarCaracter 10d
    mostrarCadena postFijo 
endm

;##############################################################################
;####################            PRECEDENCIA DE OPERADORES  ###########
;##############################################################################
precedenciaDeOperadores macro operador,signo
    LOCAL vacio,igual,fin,mayor
    cmp cantSimbolos,0d
    je vacio

    pop cx
    cmp cl,operador
    je igual
    
    cmp cl,operador
    jl mayor

    push cx
    mov temporalB,bx 
    vaciarPila
    mov bx,temporalB

    jmp vacio

    igual:
        push bx 
        mov bx,ax 
        mov [postFijo + bx],ch
        pop bx 

        mov cl,operador
        mov ch,signo
        push cx 
        jmp fin

    mayor:
        dec ax
        push cx
        inc cantSimbolos
        mov cl,operador
        mov ch,signo
        push cx 
        jmp fin

    vacio:
        dec ax
        inc cantSimbolos
        mov cl,operador
        mov ch,signo
        push cx
    
    fin:
endm

;##############################################################################
;#################### VACIA LA PILA CON OPERADORES RESTANTES ###########
;##############################################################################
vaciarPila macro
    LOCAL recursividad,salto,fin,positivo
    xor bx,bx 
    mov bl,cantSimbolos 

    recursividad:
        cmp bx,0d 
        jle salto

        pop cx 

        push bx
        mov bx,ax 
        mov [postFijo + bx],ch
        pop bx 
        inc ax
            
        jmp fin

        fin:
            dec cantSimbolos
            dec bx
            jmp recursividad
    
    salto: 
endm 