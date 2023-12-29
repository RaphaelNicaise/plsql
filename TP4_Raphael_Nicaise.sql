CREATE OR REPLACE PACKAGE Salarios_PKG AS
    PROCEDURE cambiarSalario (emp_id IN NUMBER, cantidad IN NUMBER);
END Salarios_PKG;

CREATE OR REPLACE PACKAGE BODY Salarios_PKG AS

    FUNCTION get_employee_sal (e_id OEHR_EMPLOYEES.EMPLOYEE_ID%TYPE)
        RETURN NUMBER IS l_salary OEHR_EMPLOYEES.SALARY%TYPE;
    BEGIN

        SELECT SALARY INTO l_salary
            FROM OEHR_EMPLOYEES
        WHERE EMPLOYEE_ID = e_id;

        RETURN (l_salary);

    EXCEPTION

        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RAISE;

    END;

    PROCEDURE cambiarSalario (emp_id IN NUMBER,cantidad IN NUMBER)
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
            DBMS_OUTPUT.PUT_LINE('Al usuario: '||emp_id ||' se le aumento el salario de '||salario_antiguo||'$ a '||nuevo_salario||'$');
        ELSIF nuevo_salario < salario_antiguo THEN
            DBMS_OUTPUT.PUT_LINE('Al usuario: '||emp_id ||' se le redujo el salario de '||salario_antiguo||'$ a '||nuevo_salario||'$');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Al usuario: '||emp_id ||' no se le modifico su salario: '||nuevo_salario||'$');
        END IF;

    EXCEPTION
    WHEN OTHERS THEN

        DBMS_OUTPUT.PUT_LINE('Ocurrio este Error: ' || SQLERRM); -- SQLERRM DEVUELVE EL MENSAJE DEL ERROR QUE OCURRO
        ROLLBACK; -- ROLLBACK ANULA LA ACTUALIZACION DE DATOS, ANTES DE QUE OCURRA EL COMMIT;

    END cambiarSalario;


END Salarios_PKG;

-- drop table log_cambios_Salario;

CREATE TABLE log_cambios_Salario (
    log_id NUMBER GENERATED BY DEFAULT AS IDENTITY,
    employee_id NUMBER,
    salario_viejo NUMBER,
    salario_nuevo NUMBER,
    fecha TIMESTAMP,
    PRIMARY KEY (log_id)
);

CREATE OR REPLACE PROCEDURE autonomous_insert(
    p_employee_id NUMBER,p_old_salary NUMBER,
    p_new_salary NUMBER,fecha_de_cambio TIMESTAMP
) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO log_cambios_Salario (employee_id, salario_viejo, salario_nuevo, fecha)
    VALUES (p_employee_id, p_old_salary, p_new_salary, fecha_de_cambio);
COMMIT;
END autonomous_insert;

CREATE OR REPLACE TRIGGER cambios_salario
AFTER UPDATE ON OEHR_EMPLOYEES
FOR EACH ROW
BEGIN
    IF :NEW.SALARY <> :OLD.SALARY THEN
        autonomous_insert(:NEW.EMPLOYEE_ID, :OLD.SALARY, :NEW.SALARY, SYSTIMESTAMP);
    END IF;
END cambios_salario;

DECLARE
    empleado_id     NUMBER := :id;
    cantidad        NUMBER := :cantidad;
    salario_nuevo   OEHR_EMPLOYEES.SALARY%TYPE;
BEGIN
    Salarios_PKG.cambiarSalario(empleado_id,cantidad); -- PROCEDURE INVOCADO
    salario_nuevo := Salarios_PKG.get_employee_sal(empleado_id);
    DBMS_OUTPUT.PUT_LINE('El salario de '||empleado_id||' ahora es '||salario_nuevo);
END;