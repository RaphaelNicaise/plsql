
--EJECUCION 1: CREACION DE FUNCION get_employee_sal 
CREATE OR REPLACE FUNCTION get_employee_sal (e_id OEHR_EMPLOYEES.EMPLOYEE_ID%TYPE)
    RETURN NUMBER
IS l_salary         OEHR_EMPLOYEES.SALARY%TYPE;
BEGIN
    SELECT SALARY INTO l_salary
      FROM OEHR_EMPLOYEES
    WHERE EMPLOYEE_ID = e_id;
     
        RETURN (l_salary);
EXCEPTION 
    WHEN NO_DATA_FOUND THEN -- ME DABA ERROR 00933, que corresponde a NO_DATA_FOUND, no se pueden colocar los codigos de error en el WHEN.
       RETURN NULL;
    WHEN OTHERS THEN
        RAISE;
        
END;

--EJECUCION 2: EJECUCION DE FUNCION get_employee_sal()

BEGIN
    DBMS_OUTPUT.PUT_LINE(get_employee_sal(100));
END;

-- EJECUCION 3: CREACION DE SP cambiarSalario
CREATE OR REPLACE PROCEDURE cambiarSalario (emp_id IN NUMBER,cantidad IN NUMBER)
AS
    salario_antiguo     OEHR_EMPLOYEES.SALARY%TYPE;
    nuevo_salario       OEHR_EMPLOYEES.SALARY%TYPE;
BEGIN
    salario_antiguo := get_employee_sal(emp_id); -- uso de la funcion get_employee_sal para obtener el salario del usuario ingresado en el procedure
    nuevo_salario := (salario_antiguo + cantidad); -- al salario antiguo le aumentamos la cantidad ingresada en el procedure
   
    UPDATE OEHR_EMPLOYEES 
        SET SALARY = nuevo_salario
    WHERE employee_id = emp_id;

    COMMIT;

    IF nuevo_salario > salario_antiguo THEN
        DBMS_OUTPUT.PUT_LINE('Al usuario: '||emp_id||' se le aumento el salario de '||salario_antiguo||'$ a '||nuevo_salario||'$');
    ELSIF nuevo_salario < salario_antiguo THEN
        DBMS_OUTPUT.PUT_LINE('Al usuario: '||emp_id||' se le redujo el salario de '||salario_antiguo||'$ a '||nuevo_salario||'$');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Al usuario: '||emp_id||' no se le modifico su salario: '||nuevo_salario||'$');
    
    END IF;    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrio este Error: ' || SQLERRM); -- SQLERRM DEVUELVE EL MENSAJE DEL ERROR QUE OCURRO
        ROLLBACK; -- ROLLBACK ANULA LA ACTUALIZACION DE DATOS, ANTES DE QUE OCURRA EL COMMIT;
END cambiarSalario; 

-- EJECUCION 4: cambiarSalario Procedure
BEGIN
    cambiarSalario(100,-250); -- VALORES A ELECCIONES (id_usuario,cantidad de salario(aumento+/decremento-))
END;