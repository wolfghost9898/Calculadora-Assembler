
include Funcion.asm
;##############################################################################
;########################## MOSTRAR UNA CADENA     ###################
;##############################################################################
mostrarCadena macro cadena
    mov ah,09h
    xor al,al
    mov dx, offset cadena
    int 21h 
endm

;##############################################################################
;########################## MOSTRAR UNA CARACTER     ###################
;##############################################################################
mostrarCaracter macro caracter
   mov ah,2
   mov dl,caracter
   int 21h
endm
;##############################################################################
;########################## PEDIR UN CARACTER      ###################
;##############################################################################
ingresarCaracter macro 
   mov ah,1
   int 21h
   mov bl,al
endm

;##############################################################################
;########################## LIMPIAR PANTALLA     ###################
;##############################################################################
clearScreen macro
    mov ax,03h
    int 10h
endm

;##############################################################################
;########################## INGRESAR UNA CADENA    ###################
;##############################################################################
ingresarCadena macro variable
    xor ax,ax
    
    mov ah,0AH               
    lea dx,variable
    int 21h
endm


.model small
.stack
.data
    ;######################################################### MENSAJES #############################################################
        cabecera   db "Universidad de San Carlos de Guatemala",10,"Facultad de Ingenieria",10,"Ciencias y Sistemas",10,
        "Arquitectura de computadores y ensambladores 1 A",10,"Primer Semestre 2020",10,"Carlos Eduardo Hernandez Molina",10,"201612118",10,"Quinta Practica",10,"$"
        
        msgMenu db 10,"1. Ingresar Funcion f(x)",10,"2. Funcion Memoria",10,"3. Derivada de F(x)",10,"4. Integral F(x)",10,"5. Graficar Funciones",10,"6. Reporte",10,"7. Reporte Calculadora",10,"8. Salir",10,"$"

        msgMenuGrafica db 10,"1. Graficar Funcion Original",10,"2. Graficar Derivada",10,"3.Graficar Integral",10,"4. Regresar",10,"$"

        msgDespedida db 10,"Adios :(",10,"$"

        msgCoeficiente4 db 10,"Coeficiente de x4: $"
        msgCoeficiente3 db 10,"Coeficiente de x3: $"
        msgCoeficiente2 db 10,"Coeficiente de x2: $"
        msgCoeficiente1 db 10,"Coeficiente de x1: $"
        msgCoeficiente0 db 10,"Coeficiente de x0: $"

        msgConstante db 10,"Ingrese el valor de C: $"

        msgValorInicial db 10,"Ingrese el valor Inicial: $"
        msgValorFinal db 10,"Ingrese el valor Final: $"
        msgErrorCoeficiente db 10,"Se ingreso un valor erroneo $"
        msgErrorFuncion db 10,"No hay funcion en memoria $"
        msgErrorTamanios db 10,"El limite inferior tiene que ser menor que el limite mayor $"

    ;############################################# FUNCIONES ##################################################################
        flagFuncion db 2 DUP(0)
        
        coeficiente0 db 4 DUP(0)
        coeficiente1 db 4 DUP(0)
        coeficiente2 db 4 DUP(0)
        coeficiente3 db 4 DUP(0)
        coeficiente4 db 4 DUP(0)
        xInicial db 2 DUP(0)
        xFinal db 2 DUP(0)
        escala dw ?
        limiteSuperior dw ?
        limiteSuperiorN dw ?
        lastValor dw ?
        lastValorX dw ?
        firstValor dw ? 
        firstValorX dw ?
        terminarTemp db ? 
    ;############################################# DERIVADA ##################################################################
        coeficiente0D db 4 DUP(0)
        coeficiente1D db 4 DUP(0)
        coeficiente2D db 4 DUP(0)
        coeficiente3D db 4 DUP(0)
    ;############################################# INTEGRAL ##################################################################
        coeficiente0I db 4 DUP(0)
        coeficiente1I db 4 DUP(0)
        coeficiente2I db 4 DUP(0)
        coeficiente3I db 4 DUP(0)
        coeficiente4I db 4 DUP(0)
        coeficiente5I db 4 DUP(0)
    ;######################################### LIMITES ############################################################################
        tempI db ?
        tempF db ?
        temp db ?
        temp2 db ?
        temporalY dw ?
        temp3 db ?
        valor db 5 DUP("$")
        valor2 db 5 DUP("$")
.code

inicio:
    mov ax,@data
    mov ds,ax
    mov dx,ax
    
    menu:
        clearScreen
        mostrarCadena cabecera
        mostrarCadena msgMenu

        ingresarCaracter 
        cmp bl,'1'
        je ingresarFuncion 
        cmp bl,'2'
        je funcionMemoria 
        cmp bl,'3'
        je derivada
        cmp bl,'4'
        je integral 
        cmp bl,'5' 
        je graficarFuncion 
        cmp bl,'6'
        je reporte 
        cmp bl,'7'
        je modoCalculadora 
        cmp bl,'8'
        je salir
        
        clearScreen
        jmp menu

        ;####################################################### INGRESAR FUNCION ###########################################
        ;####################################################################################################################
        ingresarFuncion:
            clearScreen
            almacenarCoeficientes

            cmp bx,0d
            je salida 

            errorCoeficiente:
                mostrarCadena msgErrorCoeficiente
                ingresarCaracter
                mov flagFuncion,0d
                jmp menu

            salida:
                mov flagFuncion,1d
                jmp menu

        ;####################################################### FUNCION MEMORIA ###########################################
        ;####################################################################################################################
        funcionMemoria:
            clearScreen
            mostrarFuncionOTexto
            ingresarCaracter
            jmp menu
        ;####################################################### DERIVADA ###########################################
        ;####################################################################################################################
        derivada:
            
            clearScreen
            mostrarCaracter 10
            mostrarCaracter 10
            mostrarCaracter 10
            mostrarDerivadaTexto
            ingresarCaracter 
            jmp menu    

        ;####################################################### INTEGRAL ###########################################
        ;####################################################################################################################
        integral:
            clearScreen
            mostrarCaracter 10
            mostrarCaracter 10
            mostrarCaracter 10
            mostrarIntegralTexto
            ingresarCaracter 
            jmp menu    

        ;####################################################### GRAFICAR FUNCION ###########################################
        ;####################################################################################################################
        graficarFuncion:
            clearScreen
            ;cmp flagFuncion,0d
            ;je noHayFuncion

            mostrarCadena msgMenuGrafica
            
            ingresarCaracter

            cmp bl,'1'
            je graficarOriginal
            cmp bl,'2'
            je graficarDerivada
            cmp bl,'3' 
            je graficarIntegral 
            jmp graficarFuncion


            noHayFuncion:
                mostrarCadena msgErrorFuncion
                ingresarCaracter
                jmp menu

        ;####################################################### GRAFICAR ORIGINAL ###########################################
        ;####################################################################################################################
        graficarOriginal:
            clearScreen
            ; Limite Inferior
            mostrarCadena msgValorInicial
             
            ingresarCadena valor
            verificarLimiteS xInicial 
            cmp bx,1d
            je errorLimite 

            ;Limite Superior

            mostrarCadena msgValorFinal
            ingresarCadena valor
            verificarLimiteS xFinal 
            cmp bx,1d
            je errorLimite 

            compararLimites
            cmp bx,1d
            je errorLimiteTamanio
            
            controlEscalaOriginal
            graphOriginal
            jmp menu



            errorLimite:
                mostrarCadena msgErrorCoeficiente
                ingresarCaracter
                jmp graficarOriginal
            
            errorLimiteTamanio:
                mostrarCadena msgErrorTamanios
                ingresarCaracter
                jmp graficarOriginal

            
        ;####################################################### GRAFICAR DERIVADA ###########################################
        ;####################################################################################################################
        graficarDerivada:
            clearScreen
            ; Limite Inferior
            mostrarCadena msgValorInicial
             
            ingresarCadena valor
            verificarLimiteS xInicial 
            cmp bx,1d
            je errorLimite2 

            ;Limite Superior

            mostrarCadena msgValorFinal
            ingresarCadena valor
            verificarLimiteS xFinal 
            cmp bx,1d
            je errorLimite2 

            compararLimites
            cmp bx,1d
            je errorLimiteTamanio2
            
            controlEscalaDerivada
            graphDerivada
            jmp menu



            errorLimite2:
                mostrarCadena msgErrorCoeficiente
                ingresarCaracter
                jmp graficarDerivada
            
            errorLimiteTamanio2:
                mostrarCadena msgErrorTamanios
                ingresarCaracter
                jmp graficarDerivada


        ;####################################################### GRAFICAR INTEGRAL ###########################################
        ;####################################################################################################################
        graficarIntegral:
            clearScreen
            ; Limite Inferior
            mostrarCadena msgValorInicial
             
            ingresarCadena valor
            verificarLimiteS xInicial 
            cmp bx,1d
            je errorLimite3 

            ;Limite Superior

            mostrarCadena msgValorFinal
            ingresarCadena valor
            verificarLimiteS xFinal 
            cmp bx,1d
            je errorLimite3 

            compararLimites
            cmp bx,1d
            je errorLimiteTamanio3
            
            mostrarCadena msgConstante 
            ingresarCadena valor 
            verificarLimiteS coeficiente0I
            cmp bx,1d
            je errorLimite3

            controlEscalaIntegral
            graphIntegral
            jmp menu



            errorLimite3:
                mostrarCadena msgErrorCoeficiente
                ingresarCaracter
                jmp graficarDerivada
            
            errorLimiteTamanio3:
                mostrarCadena msgErrorTamanios
                ingresarCaracter
                jmp graficarDerivada
        ;####################################################### REPORTE ###########################################
        ;####################################################################################################################
        reporte:


        ;####################################################### MODO CALCULADORA###########################################
        ;####################################################################################################################
        modoCalculadora:

    salir:
    mostrarCadena msgDespedida
    mov   ax,4c00h       
    int   21h 
end