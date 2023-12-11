DECLARE

    dep_id        OEHR_EMPLOYEES.department_id%TYPE := :depno; -- SELECCIONA UN DEPARTAMENTO, 30 por ejemplo.
    l_empno       OEHR_EMPLOYEES.employee_id%TYPE;
    l_name        OEHR_EMPLOYEES.last_name%TYPE;
    l_salary      OEHR_EMPLOYEES.salary%TYPE;
    l_quantity    NUMBER;

    CURSOR c_emp_cursor IS -- CURSOR QUE SELECCIONA TODOS LOS EMPLEADOS DE UN DEPARTMENT_ID VARIABLE
        SELECT employee_id, last_name, salary
          FROM OEHR_EMPLOYEES 
        WHERE department_id = dep_id;

BEGIN
    SELECT COUNT(*) INTO l_quantity -- SELECCIONA LA CANTIDAD DE EMPLEADOS EN LA VARIABLE l_quantity
      FROM OEHR_EMPLOYEES
    WHERE department_id = dep_id; 

    DBMS_OUTPUT.PUT_LINE('Quantity of Employees of department_id '||dep_id||' = '||l_quantity);
   
    OPEN c_emp_cursor;
 
    FOR EMPLOYEE IN 1..l_quantity LOOP -- RECORRE CADA EMPLEADO "ALMACENADO" EN EL CURSOR, DE 1 A l_quantity
        FETCH c_emp_cursor INTO l_empno, l_name, l_salary; -- FETCH SELECCIONA E INSERTA EN LAS VARIABLES LO QUE ESTE EN EL PUNTERO Y, ADELANTA UNA FILA.
        CASE
            WHEN l_salary > 3000 THEN
                DBMS_OUTPUT.PUT_LINE(l_empno || ' ' || l_name || ' ' || l_salary || '$ Good Salary' );

            WHEN l_salary <= 3000 AND l_salary >= 2700 THEN 
                DBMS_OUTPUT.PUT_LINE(l_empno || ' ' || l_name || ' ' || l_salary || '$ Medium Salary' );

            WHEN l_salary < 2700 THEN

                IF l_salary > 1500 THEN
                    DBMS_OUTPUT.PUT_LINE(l_empno || ' ' || l_name || ' ' || l_salary || '$ Bad Salary' );
                ELSE                   
                    DBMS_OUTPUT.PUT_LINE(l_empno || ' ' || l_name || ' ' || l_salary || '$ Awful Salary' );
                END IF;

        END CASE;
    END LOOP;

    CLOSE c_emp_cursor;
END
/