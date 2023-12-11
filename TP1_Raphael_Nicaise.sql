 DECLARE
    employeeid NUMBER(6) := :empno;
    sal OEHR_EMPLOYEES.salary%TYPE;
    l_good_sal BOOLEAN;
 BEGIN
    SELECT OEE.salary 
     INTO sal
     FROM OEHR_EMPLOYEES OEE
    WHERE OEE.EMPLOYEE_ID = employeeid;

    l_good_sal := sal > 8000; -- Si la variable salario es mayor a 8000, se tornara en un valor TRUE, de lo contrario retornara el valor FALSE.
    
    DBMS_OUTPUT.PUT_LINE('El salario:'|| sal ||'$ del id_empleado: '||employeeid||' es bueno? ' ||CASE WHEN l_good_sal THEN 'Si es un buen salario' ELSE 'No es un buen salario' END);

 END;   
    
